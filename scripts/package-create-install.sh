#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="rcg_retail_execution_dms"
PACKAGE_VERSION="1.0.0"

echo "Creating unlocked package..."
sf package create -n "$PACKAGE_NAME" -t Unlocked -o rcg

echo "Creating package version..."
sf package version create -p "$PACKAGE_NAME" -d force-app -k install-key-here --wait 10 -o rcg

echo "Package created successfully!"
echo "Install URL will be displayed above."
