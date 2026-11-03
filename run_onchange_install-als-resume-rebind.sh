#!/bin/bash
# Rebind the Framework laptop's light sensor after every resume.
#
# Why: the sensor behind the Framework 13's embedded-controller sensor hub
# (ACPI FRMW0005) comes back from suspend reading a flat 0 until
# hid_sensor_als binds again, which leaves auto brightness at its darkest. A
# rebind during the resume itself is too early to take, and a system-sleep
# hook cannot outlive it, so this is a unit ordered after the sleep targets.
# Other HID light sensors, a Studio Display's included, are left alone.
#
# TODO: drop this once the EC firmware is fixed upstream:
# https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues/179
#
# Installed only where that hub exists; elsewhere it is removed. Idempotent:
# writes, reloads and enables only on a real change.
set -e

SCRIPT=/usr/local/lib/als-rebind
UNIT=/etc/systemd/system/als-rebind.service
OLD_HOOK=/etc/systemd/system-sleep/als-rebind
TARGETS="suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target"

read -r -d '' SCRIPT_CONTENT <<'SCRIPT' || true
#!/bin/sh
# Managed by chezmoi (joaodrp/omarchy). Rebinds the light sensor on the
# Framework sensor hub (FRMW0005) while it reads 0 after a resume, up to 5
# tries.
drv=/sys/bus/platform/drivers/hid_sensor_als
ours() { case $(readlink -f "$1") in *FRMW0005*) return 0 ;; esac; return 1; }
stuck() {
    for dev in /sys/bus/iio/devices/iio:device*; do
        ours "$dev" || continue
        [ "$(cat "$dev/in_illuminance_raw" 2>/dev/null)" = 0 ] && return 0
    done
    return 1
}
for try in 1 2 3 4 5; do
    sleep 3
    if ! stuck; then
        echo "light sensors reading (after $((try - 1)) rebinds)"
        exit 0
    fi
    for dev in "$drv"/HID-SENSOR-*; do
        { [ -e "$dev" ] && ours "$dev"; } || continue
        name=${dev##*/}
        echo "$name" > "$drv/unbind"
        echo "$name" > "$drv/bind"
    done
    echo "rebound light sensors (try $try)"
done
SCRIPT

read -r -d '' UNIT_CONTENT <<UNIT || true
# Managed by chezmoi (joaodrp/omarchy).
[Unit]
Description=Rebind the Framework light sensor after resume
After=$TARGETS

[Service]
Type=oneshot
ExecStart=$SCRIPT

[Install]
WantedBy=$TARGETS
UNIT

[ -e "$OLD_HOOK" ] && sudo rm -f "$OLD_HOOK"

framework_als() {
    local dev
    for dev in /sys/bus/platform/drivers/hid_sensor_als/HID-SENSOR-*; do
        [[ $(readlink -f "$dev") == *FRMW0005* ]] && return 0
    done
    return 1
}

if ! framework_als; then
    if [ -e "$UNIT" ]; then
        sudo systemctl disable als-rebind.service >/dev/null 2>&1 || true
        sudo rm -f "$UNIT" "$SCRIPT"
        sudo systemctl daemon-reload
    fi
    exit 0
fi

if [ "$(cat "$SCRIPT" 2>/dev/null)" != "$SCRIPT_CONTENT" ] || [ ! -x "$SCRIPT" ]; then
    printf '%s\n' "$SCRIPT_CONTENT" | sudo install -D -m 755 /dev/stdin "$SCRIPT"
fi
if [ "$(cat "$UNIT" 2>/dev/null)" != "$UNIT_CONTENT" ]; then
    printf '%s\n' "$UNIT_CONTENT" | sudo install -D -m 644 /dev/stdin "$UNIT"
    sudo systemctl daemon-reload
fi
systemctl is-enabled --quiet als-rebind.service 2>/dev/null || sudo systemctl enable --quiet als-rebind.service
