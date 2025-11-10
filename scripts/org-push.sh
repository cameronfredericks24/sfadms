#!/usr/bin/env bash
set -euo pipefail

echo "⬆️  Pushing source to scratch org..."
sf project deploy start -o rcg -d force-app

echo "✅ Source pushed successfully!"
