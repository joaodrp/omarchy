#!/bin/bash
# Install dmidecode to read hardware inventory (RAM part numbers, BIOS, board)
# from the firmware's DMI/SMBIOS tables.
set -e

omarchy pkg add dmidecode
