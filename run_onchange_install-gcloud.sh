#!/bin/bash
# Install the Google Cloud CLI.
#
# The package disables gcloud's own component manager, so extras (bq, gsutil,
# gke-gcloud-auth-plugin) are separate AUR packages, not `gcloud components
# install`.
#
# AUR package. Idempotent.
set -e

omarchy pkg aur add google-cloud-cli
