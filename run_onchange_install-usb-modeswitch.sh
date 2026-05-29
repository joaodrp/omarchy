#!/bin/bash
# Install usb_modeswitch for "ZeroCD" USB devices that present as a CD-ROM
# or mass-storage device on first plug-in and need a control sequence to
# switch into their actual function. Bundled udev rules from the
# usb_modeswitch-data package trigger the switch automatically on hotplug.
#
# Concrete reason on my hardware: TP-Link Archer TX20U Nano (Wi-Fi 6 USB
# dongle, Realtek RTL8852BU). The kernel ships the rtw89_8852bu driver
# already, so once usb_modeswitch flips the device out of storage mode the
# kernel takes over and a wlan interface appears with no extra DKMS.
#
# Harmless on machines without ZeroCD devices: the package is a small udev
# helper that only fires when matching VID:PIDs plug in.
set -e

omarchy pkg add usb_modeswitch
