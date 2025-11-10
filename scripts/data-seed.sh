#!/usr/bin/env bash
set -euo pipefail

echo "🌱 Seeding data into org..."

# Import data using the plan
if [ -f "data/plan.json" ]; then
  echo "📊 Importing data via import plan..."
  sf data import tree -o rcg -p data/plan.json || echo "⚠️  Some data imports may have failed - continuing..."
else
  echo "⚠️  No data/plan.json found - skipping tree import"
fi

echo "✅ Data seeding complete!"
echo "Run ./scripts/run-demo.sh to execute the demo scenario"
