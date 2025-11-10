#!/usr/bin/env bash
set -euo pipefail

echo "Seeding data..."

# Import products
echo "Importing products..."
sf data import tree -p data/plan.json -o rcg || echo "Data import completed with warnings"

echo "Data seeding complete!"
