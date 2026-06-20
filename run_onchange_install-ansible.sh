#!/bin/bash
# Install Ansible (full distribution: ansible-core + community collections).
# Idempotent: omarchy pkg add is a no-op once installed.
set -e

omarchy pkg add ansible
