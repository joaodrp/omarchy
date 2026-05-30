#!/bin/bash
# Install gitleaks for the global pre-commit secret-scan hook.
set -e

omarchy pkg add gitleaks
