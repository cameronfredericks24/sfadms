#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="rcg_retail_execution_dms"
VERSION_NAME="Spring 2025"

echo "📦 Creating unlocked package..."

# Create package version
PACKAGE_VERSION=$(sf package version create \
  --package "$PACKAGE_NAME" \
  --version-name "$VERSION_NAME" \
  --code-coverage \
  --installation-key-bypass \
  --wait 20 \
  --json | jq -r '.result.SubscriberPackageVersionId')

echo "✅ Package version created: $PACKAGE_VERSION"

# Promote package
echo "🚀 Promoting package version..."
sf package version promote --package "$PACKAGE_VERSION" --no-prompt

echo "✅ Package promoted!"
echo ""
echo "📥 Install URL:"
echo "https://login.salesforce.com/packaging/installPackage.apexp?p0=$PACKAGE_VERSION"
echo ""
echo "Install command:"
echo "sf package install --package $PACKAGE_VERSION --wait 10 --target-org <your-org-alias>"
