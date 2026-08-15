#!/bin/bash
# Make the Thunderbolt dock's keyboard work at the LUKS passphrase prompt.
#
# Why: the dock's USB ports are an xHCI *inside the dock*, reached over a PCIe
# tunnel. At Thunderbolt security level `user` the kernel withholds that tunnel
# until something writes `authorized`, and the only thing that does is boltd —
# which cannot start until the encrypted root is already mounted. So a keyboard
# on the dock does not exist yet when the passphrase is asked for.
#
# This installs an initramfs hook that authorizes the dock, before the `encrypt`
# hook prompts. A watchdog closes the tunnel again if nobody unlocks within the
# window, so a machine that reboots unattended is not left with a DMA-capable
# endpoint open until someone walks past.
#
# The dock is pinned by Thunderbolt UUID, which is a per-unit hardware serial
# and also the credential the initramfs trusts before the disk is unlocked —
# publishing it would tell a targeted attacker exactly what to forge. So it is
# captured from the attached dock at apply time into a file outside this repo,
# never committed. Model strings below are only used to find it.
#
# Idempotent: files are only rewritten when their content differs, the UUID is
# left alone when the dock is absent, and the initramfs is rebuilt only when
# something actually changed.
set -e

DOCK_VENDOR='CalDigit, Inc.'
DOCK_DEVICE='TS5'

INSTALL_HOOK=/etc/initcpio/install/thunderbolt-keyboard
RUNTIME_HOOK=/etc/initcpio/hooks/thunderbolt-keyboard
MKINITCPIO_CONF=/etc/mkinitcpio.conf.d/zz-thunderbolt-keyboard.conf
DOCK_CONF=/etc/thunderbolt-keyboard.conf
# Superseded by MKINITCPIO_CONF, which carries the same MODULES line.
LEGACY_CONF=/etc/mkinitcpio.conf.d/thunderbolt_module.conf

changed=0

# Write $2 to $1 with mode $3, via sudo. Skips identical content so reruns are
# free and leave the initramfs alone.
install_file() {
  local path=$1 content=$2 mode=$3
  if [ "$(sudo cat "$path" 2>/dev/null)" = "$content" ]; then
    return 0
  fi
  sudo install -Dm"$mode" /dev/stdin "$path" <<<"$content"
  changed=1
}

read -r -d '' INSTALL_HOOK_CONTENT <<'EOF' || true
#!/bin/bash

build() {
    # autodetect only bundles what is bound at build time; be explicit so the
    # driver is present even when the dock is unplugged during a rebuild.
    add_module 'thunderbolt'
    # Carries the dock's UUID. Absent on a machine that has never seen the
    # dock, in which case the runtime hook no-ops.
    [[ -f /etc/thunderbolt-keyboard.conf ]] && add_file /etc/thunderbolt-keyboard.conf
    add_runscript
}

help() {
    cat <<'HELPEOF'
Authorizes the Thunderbolt dock before the passphrase prompt so a keyboard
attached to it is usable, then de-authorizes it if nobody unlocks in time.
HELPEOF
}
EOF

read -r -d '' RUNTIME_HOOK_CONTENT <<'EOF' || true
#!/usr/bin/ash

# Seconds the dock stays authorized while waiting for the passphrase. Measured
# from authorization, which happens early in boot — so this is roughly the time
# from power-on, not from when someone sits down. Closing the tunnel after a
# successful unlock is harmless: boltd re-authorizes moments later.
tb_window=300

tb_domain=/sys/bus/thunderbolt/devices/domain0
tb_conf=/etc/thunderbolt-keyboard.conf

# Echo a sysfs attribute, or nothing when it is missing.
tb_attr() {
    [ -r "$1" ] || return 1
    read -r _tb_val <"$1" 2>/dev/null || return 1
    printf '%s' "$_tb_val"
}

# Write $1 to $2, swallowing the redirection error when sysfs rejects it.
tb_write() {
    { printf '%s\n' "$1" >"$2"; } 2>/dev/null
}

# Paths of every USB HID keyboard interface currently present.
tb_keyboards() {
    for _tb_if in /sys/bus/usb/devices/*:*; do
        [ "$(tb_attr "$_tb_if/bInterfaceClass")" = '03' ] || continue
        [ "$(tb_attr "$_tb_if/bInterfaceProtocol")" = '01' ] || continue
        printf '%s\n' "$_tb_if"
    done
}

# The dm name cryptsetup will create, read from the cmdline so no identifier
# from this machine has to be written down. Format: cryptdevice=<dev>:<name>[:opts]
tb_mapper() {
    for _tb_w in $(cat /proc/cmdline 2>/dev/null); do
        case "$_tb_w" in
        cryptdevice=*)
            _tb_v=${_tb_w#cryptdevice=}
            _tb_v=${_tb_v#*:}
            [ -n "${_tb_v%%:*}" ] || return 1
            printf '%s' "${_tb_v%%:*}"
            return 0
            ;;
        esac
    done
    return 1
}

# True once the passphrase has been accepted. Prefers the exact mapping named
# on the cmdline; falls back to "any mapping appeared" when it cannot be read.
tb_unlocked() {
    if [ -n "$tb_mapper_name" ]; then
        [ -e "/dev/mapper/$tb_mapper_name" ]
        return
    fi
    for _tb_m in /dev/mapper/*; do
        [ "$_tb_m" = '/dev/mapper/control' ] && continue
        [ -e "$_tb_m" ] && return 0
    done
    return 1
}

run_hook() {
    # No pinned dock means nothing to trust; leave boot exactly as it was.
    [ -r "$tb_conf" ] || return 0
    . "$tb_conf"
    [ -n "$TB_UUID" ] || return 0

    command -v modprobe >/dev/null 2>&1 && modprobe -q thunderbolt 2>/dev/null

    # The controller probes asynchronously; the domain may not exist yet.
    _tb_i=0
    while [ ! -d "$tb_domain" ] && [ "$_tb_i" -lt 50 ]; do
        sleep 0.1
        _tb_i=$((_tb_i + 1))
    done
    [ -d "$tb_domain" ] || return 0

    # Only open a PCIe tunnel while the IOMMU is translating DMA for it.
    [ "$(tb_attr "$tb_domain/iommu_dma_protection")" = '1' ] || return 0

    # Keyboards already attached to the host, so the wait below can tell the
    # dock's apart from one that was there all along.
    _tb_before=$(tb_keyboards)

    # Authorize the pinned dock only. Anything chained behind it stays closed
    # until boltd runs after unlock, keeping one fewer DMA-capable endpoint
    # open while the passphrase is typed.
    _tb_docks=''
    for _tb_dev in /sys/bus/thunderbolt/devices/*; do
        [ -f "$_tb_dev/authorized" ] || continue
        [ "$(tb_attr "$_tb_dev/unique_id")" = "$TB_UUID" ] || continue
        [ "$(tb_attr "$_tb_dev/authorized")" = '0' ] || continue
        tb_write 1 "$_tb_dev/authorized" || continue
        _tb_docks="$_tb_docks $_tb_dev"
    done
    [ -n "$_tb_docks" ] || return 0

    msg ':: Authorized Thunderbolt dock for the passphrase prompt'

    # Wait for a keyboard that was not already present, so plymouth is not
    # asked for a password before the dock's keyboard exists. Falling through
    # on timeout is fine — boot continues as it does without this hook.
    _tb_i=0
    while [ "$_tb_i" -lt 100 ]; do
        for _tb_kb in $(tb_keyboards); do
            case "
$_tb_before
" in
            *"
$_tb_kb
"*) continue ;;
            *) break 2 ;;
            esac
        done
        sleep 0.1
        _tb_i=$((_tb_i + 1))
    done

    # Close the tunnel again if the passphrase never arrives. Skipped when the
    # domain cannot de-authorize, since the write would only fail.
    [ "$(tb_attr "$tb_domain/deauthorization")" = '1' ] || return 0
    tb_mapper_name=$(tb_mapper) || tb_mapper_name=''
    (
        _tb_i=0
        while [ "$_tb_i" -lt "$tb_window" ]; do
            sleep 1
            tb_unlocked && exit 0
            _tb_i=$((_tb_i + 1))
        done
        for _tb_dev in $_tb_docks; do
            tb_write 0 "$_tb_dev/authorized"
        done
    ) &
}
EOF

read -r -d '' MKINITCPIO_CONF_CONTENT <<'EOF' || true
# Splice the Thunderbolt authorizer in ahead of `encrypt` so the dock's
# keyboard exists before the passphrase is asked for. Appending would land
# after `encrypt` and never run in time.
#
# Must keep sorting after omarchy_hooks.conf, which assigns HOOKS outright.
MODULES+=(thunderbolt)

if [[ " ${HOOKS[*]} " != *" thunderbolt-keyboard "* ]]; then
  _tb_hooks=()
  for _tb_hook in "${HOOKS[@]}"; do
    [[ $_tb_hook == "encrypt" ]] && _tb_hooks+=(thunderbolt-keyboard)
    _tb_hooks+=("$_tb_hook")
  done
  HOOKS=("${_tb_hooks[@]}")
  unset _tb_hooks _tb_hook
fi
EOF

install_file "$INSTALL_HOOK" "$INSTALL_HOOK_CONTENT" 644
install_file "$RUNTIME_HOOK" "$RUNTIME_HOOK_CONTENT" 644
install_file "$MKINITCPIO_CONF" "$MKINITCPIO_CONF_CONTENT" 644

# Pin the dock by UUID, read from the one attached right now. When it is
# unplugged, keep whatever was captured before rather than unpinning.
dock_uuid=
for dev in /sys/bus/thunderbolt/devices/*/; do
  [ -f "$dev/unique_id" ] || continue
  [ "$(cat "$dev/vendor_name" 2>/dev/null)" = "$DOCK_VENDOR" ] || continue
  [ "$(cat "$dev/device_name" 2>/dev/null)" = "$DOCK_DEVICE" ] || continue
  dock_uuid=$(cat "$dev/unique_id")
  break
done

if [ -n "$dock_uuid" ]; then
  install_file "$DOCK_CONF" "TB_UUID='$dock_uuid'" 600
elif ! sudo test -f "$DOCK_CONF"; then
  echo "No $DOCK_VENDOR $DOCK_DEVICE attached and none pinned yet;" \
    "the hook stays inert until this runs with the dock connected." >&2
fi

# Drop the standalone MODULES drop-in now that the splice conf carries it, but
# only when it still holds exactly that line and nothing else.
if [ "$(sudo cat "$LEGACY_CONF" 2>/dev/null)" = 'MODULES+=(thunderbolt)' ]; then
  sudo rm -f "$LEGACY_CONF"
  changed=1
fi

if [ "$changed" -eq 1 ]; then
  echo "Rebuilding initramfs..."
  sudo mkinitcpio -P
fi
