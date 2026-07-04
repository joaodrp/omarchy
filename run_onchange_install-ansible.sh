#!/bin/bash
# Install Ansible (full distribution: ansible-core + community collections).
# Idempotent.
set -e

omarchy pkg add ansible
