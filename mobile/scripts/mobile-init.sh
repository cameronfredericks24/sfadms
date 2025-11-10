#!/usr/bin/env bash
set -euo pipefail

echo "Initializing RCG Mobile App..."

cd "$(dirname "$0")/.."

# Install dependencies
echo "Installing npm dependencies..."
npm install

# iOS setup
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing iOS pods..."
    cd ios && pod install && cd ..
fi

# Android setup
echo "Android setup complete (run ./gradlew build in android/ if needed)"

echo "Mobile app initialization complete!"
echo "Run ./scripts/mobile-run-ios.sh or ./scripts/mobile-run-android.sh to start"
