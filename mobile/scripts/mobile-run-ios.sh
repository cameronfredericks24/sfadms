#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Running iOS app..."
react-native run-ios
