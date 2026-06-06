#!/bin/bash
# Manage HDA audio codec power save per machine, keyed on chassis type.
#
# Why: snd_hda_intel power save lets the codec sleep when idle, which on a
# desktop causes an audible pop and a clipped first ~0.5s of playback after
# silence. On battery-class machines the idle saving is worth keeping, so this
# only acts on AC-powered chassis.
#
# Selection is automatic via `hostnamectl chassis` — no per-machine config:
#   laptop/tablet/handset/convertible/watch -> keep power save (remove our conf)
#   everything else (desktop/server/vm/...)  -> disable power save
#
# Persists via modprobe.d (read whenever snd_hda_intel loads) and also pokes the
# live sysfs param so it takes effect now. Idempotent and reversible: on a
# laptop the conf is removed and the kernel default restored on next boot.
set -e

CONF=/etc/modprobe.d/audio-powersave.conf
CONF_CONTENT='options snd_hda_intel power_save=0 power_save_controller=N'

case "$(hostnamectl chassis 2>/dev/null)" in
    laptop | tablet | handset | convertible | watch)
        # Battery-class machine: keep power save. Drop our override if present.
        [ -f "$CONF" ] && sudo rm -f "$CONF"
        exit 0
        ;;
esac

# AC-powered machine: install the conf (only when it differs, to stay quiet).
if [ "$(cat "$CONF" 2>/dev/null)" != "$CONF_CONTENT" ]; then
    printf '%s\n' "$CONF_CONTENT" | sudo tee "$CONF" >/dev/null
fi

# Apply now (the modprobe.d conf covers future boots / module reloads).
param=/sys/module/snd_hda_intel/parameters/power_save
[ -f "$param" ] && echo 0 | sudo tee "$param" >/dev/null || true
