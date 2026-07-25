#!/bin/bash
# Install tooling for the YubiKey Bio FIDO unlock of 1Password via polkit/PAM:
# pam-u2f provides pam_u2f.so and pamu2fcfg (authfile generation), yubikey-manager
# provides ykman (fingerprint/PIN management), libfido2 provides fido2-token.
set -e

omarchy pkg add pam-u2f yubikey-manager libfido2
