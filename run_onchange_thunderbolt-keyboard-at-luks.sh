#!/bin/bash
# Make a keyboard on the Thunderbolt dock work at the LUKS passphrase prompt.
#
# The dock's USB ports are an xHCI inside the dock, reached over a PCIe tunnel.
# Security level `user` withholds that tunnel until something writes
# `authorized`, and only boltd does -- after the encrypted root is mounted. So
# the keyboard does not exist yet when the passphrase is asked for.
#
# An initramfs hook spliced ahead of `encrypt` authorizes the dock; a watchdog
# closes it again if nobody unlocks, so an unattended reboot does not leave a
# DMA-capable endpoint open.
#
# The dock is pinned by Thunderbolt UUID -- a per-unit serial, and the
# credential the initramfs trusts pre-unlock. Captured from the attached dock
# at apply time, kept out of this public repo. Model strings only locate it.
#
# Idempotent: files rewritten only when content differs, the UUID is preserved
# when the dock is absent, and the initramfs is rebuilt only on change.
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
    # Explicit so the driver is present even when the dock is unplugged during
    # a rebuild, which autodetect alone would not guarantee.
    add_module 'thunderbolt'
    # Absent until the dock has been seen once; a missing UUID only makes the
    # hook inert, which beats failing the build.
    if [[ -f /etc/thunderbolt-keyboard.conf ]]; then
        add_file /etc/thunderbolt-keyboard.conf
    fi
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

# Measured from authorization, which happens early in boot -- so roughly time
# from power-on, not from when someone sits down. Closing after a successful
# unlock is harmless: boltd re-authorizes moments later.
tb_window=300

tb_domain=/sys/bus/thunderbolt/devices/domain0
tb_conf=/etc/thunderbolt-keyboard.conf

tb_attr() {
    [ -r "$1" ] || return 1
    read -r _tb_val <"$1" 2>/dev/null || return 1
    printf '%s' "$_tb_val"
}

# Brace group so a rejected sysfs write stays quiet.
tb_write() {
    { printf '%s\n' "$1" >"$2"; } 2>/dev/null
}

tb_keyboards() {
    for _tb_if in /sys/bus/usb/devices/*:*; do
        [ "$(tb_attr "$_tb_if/bInterfaceClass")" = '03' ] || continue
        [ "$(tb_attr "$_tb_if/bInterfaceProtocol")" = '01' ] || continue
        printf '%s\n' "$_tb_if"
    done
}

# cryptdevice=<dev>:<name>[:opts] -- read from the cmdline so no identifier
# from this machine has to be written down.
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

# Falls back to "any mapping appeared" when the cmdline cannot be parsed.
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
    # Read as data, never sourced: a truncated file must no-op rather than
    # abort the init shell before the passphrase can be asked for.
    [ -r "$tb_conf" ] || return 0
    read -r tb_uuid <"$tb_conf" 2>/dev/null || return 0
    case "$tb_uuid" in
    '' | *[!0-9a-fA-F-]*) return 0 ;;
    esac

    command -v modprobe >/dev/null 2>&1 && modprobe -q thunderbolt 2>/dev/null

    # The controller probes asynchronously.
    _tb_i=0
    while [ ! -d "$tb_domain" ] && [ "$_tb_i" -lt 50 ]; do
        sleep 0.1
        _tb_i=$((_tb_i + 1))
    done
    [ -d "$tb_domain" ] || return 0

    # Only tunnel PCIe while the IOMMU is translating DMA for it.
    [ "$(tb_attr "$tb_domain/iommu_dma_protection")" = '1' ] || return 0

    # Snapshot so the wait below can tell the dock's keyboard from one that was
    # already attached to the host.
    _tb_before=$(tb_keyboards)

    # The pinned dock only. Anything chained behind it stays closed until boltd
    # runs, keeping one fewer endpoint open while the passphrase is typed.
    _tb_docks=''
    for _tb_dev in /sys/bus/thunderbolt/devices/*; do
        [ -f "$_tb_dev/authorized" ] || continue
        [ "$(tb_attr "$_tb_dev/unique_id")" = "$tb_uuid" ] || continue
        [ "$(tb_attr "$_tb_dev/authorized")" = '0' ] || continue
        tb_write 1 "$_tb_dev/authorized" || continue
        _tb_docks="$_tb_docks $_tb_dev"
    done
    [ -n "$_tb_docks" ] || return 0

    msg ':: Authorized Thunderbolt dock for the passphrase prompt'

    # Wait for a keyboard that was not already there. Timing out is fine -- boot
    # then continues as it does without this hook.
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
# Splice ahead of `encrypt`; appending would land after it and never run in
# time. Must keep sorting after omarchy_hooks.conf, which assigns HOOKS.
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

# Pin the dock attached right now; when it is unplugged, keep what was captured
# before rather than unpinning.
dock_uuid=
for dev in /sys/bus/thunderbolt/devices/*/; do
  [ -f "$dev/unique_id" ] || continue
  [ "$(cat "$dev/vendor_name" 2>/dev/null)" = "$DOCK_VENDOR" ] || continue
  [ "$(cat "$dev/device_name" 2>/dev/null)" = "$DOCK_DEVICE" ] || continue
  dock_uuid=$(cat "$dev/unique_id")
  break
done

if [ -n "$dock_uuid" ]; then
  install_file "$DOCK_CONF" "$dock_uuid" 600
elif ! sudo test -f "$DOCK_CONF"; then
  echo "No $DOCK_VENDOR $DOCK_DEVICE attached and none pinned yet;" \
    "the hook stays inert until this runs with the dock connected." >&2
fi

if [ "$(sudo cat "$LEGACY_CONF" 2>/dev/null)" = 'MODULES+=(thunderbolt)' ]; then
  sudo rm -f "$LEGACY_CONF"
  changed=1
fi

if [ "$changed" -eq 1 ]; then
  echo "Rebuilding initramfs..."
  # Where limine owns the UKI there are no presets, and the mkinitcpio wrapper
  # only offers this behind an interactive prompt.
  if command -v limine-mkinitcpio >/dev/null 2>&1; then
    sudo limine-mkinitcpio
  else
    sudo mkinitcpio -P
  fi
fi
