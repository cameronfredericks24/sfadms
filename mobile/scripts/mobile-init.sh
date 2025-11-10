#!/usr/bin/env bash
set -euo pipefail

echo "Initializing React Native mobile app..."

cd mobile/app

echo "Installing dependencies..."
npm install

echo "Installing iOS pods..."
cd ios && pod install && cd ..

echo "Mobile app initialization complete!"
echo "Run 'npm run ios' or 'npm run android' to start the app"
