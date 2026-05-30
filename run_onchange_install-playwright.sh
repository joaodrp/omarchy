#!/bin/bash
# Install Playwright CLI via mise (npm backend). Browsers are not
# downloaded here — run `playwright install` manually if you need them.
set -e

mise use -g npm:playwright@latest
