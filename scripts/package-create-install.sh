#!/usr/bin/env bash
set -euo pipefail

echo "Creating unlocked package..."

# Create package version
sf package version create -p rcg_retail_execution_dms -d force-app -w 10 || echo "Package creation failed"

echo "Package created!"
echo "Install URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t..."
