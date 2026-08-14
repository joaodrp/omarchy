#!/bin/bash
# Retire the cloned polkit shell plugin once omarchy ships the fix itself.
#
# omarchy 4's polkit agent offers a non-password method only when it finds
# pam_fprintd in the PAM stack, so a pam_u2f-only setup gets a bare password
# field and the assertion never completes. Until the fix lands, a clone of the
# plugin carries the patch from https://github.com/basecamp/omarchy/pull/6515
#
# A clone shadows the first-party plugin forever, so it would silently freeze
# this machine on a snapshot of that branch. Detect the fix in the packaged
# plugin and hand the job back.
#
# Then delete this script from the source too, since it can never fire again.
# That leaves the repo dirty on purpose: the pending deletion is the reminder.
#
# Not reproducible on a fresh machine: the clone is deliberately not vendored
# here, so a rebuild before #6515 merges gets password-only polkit until the
# clone is recreated by hand.
set -e

CLONE_ID=joaodrp.polkit
CLONE_DIR="$HOME/.config/omarchy/plugins/$CLONE_ID"
PACKAGED=/usr/share/omarchy/shell/plugins/polkit/PolkitModel.js

[ -d "$CLONE_DIR" ] || exit 0
grep -q 'pam_u2f' "$PACKAGED" 2>/dev/null || exit 0

echo "polkit: omarchy now handles pam_u2f, retiring the $CLONE_ID clone"
omarchy plugin enable omarchy.polkit
omarchy plugin remove "$CLONE_ID" --yes
omarchy restart shell

# Named literally: chezmoi runs scripts from a temp copy, so $0 is not the
# source path.
self="$(chezmoi source-path 2>/dev/null)/run_after_retire-polkit-plugin-clone.sh"
if [ -f "$self" ]; then
    rm -f "$self"
    echo "polkit: removed $self -- commit the deletion"
fi
