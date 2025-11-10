#!/usr/bin/env bash
set -euo pipefail

echo "Seeding data..."

# Create accounts (distributors and retailers)
echo "Creating accounts..."
sf data import tree -o rcg -p data/accounts-plan.json || echo "Accounts import failed"

# Create products and pricebooks
echo "Creating products..."
sf data import tree -o rcg -p data/products-plan.json || echo "Products import failed"

# Create batch lots
echo "Creating batch lots..."
sf data import tree -o rcg -p data/batchlots-plan.json || echo "Batch lots import failed"

# Create promotions
echo "Creating promotions..."
sf data import tree -o rcg -p data/promotions-plan.json || echo "Promotions import failed"

# Create replenishment policies
echo "Creating replenishment policies..."
sf data import tree -o rcg -p data/replenishment-policies-plan.json || echo "Replenishment policies import failed"

echo "Data seeding complete!"
