#!/bin/bash
# Install radare2, a disassembler for static analysis of binaries, including
# Windows PE files such as installer tooling.
#
# Idempotent.
set -e

omarchy pkg add radare2
