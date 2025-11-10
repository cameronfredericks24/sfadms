#!/usr/bin/env bash
set -euo pipefail

echo "🎬 Running RCG Retail Execution DMS Demo..."

# Get the org username
ORG_USERNAME=$(sf org display -o rcg --json | jq -r '.result.username')

echo "📍 Step 1: Creating Beat Plan for Today..."
sf apex run -o rcg -f scripts/apex/demo-create-beatplan.apex

echo "🚶 Step 2: Simulating Field Visit..."
sf apex run -o rcg -f scripts/apex/demo-create-visit.apex

echo "🛒 Step 3: Creating Secondary Order with Promotions..."
sf apex run -o rcg -f scripts/apex/demo-create-order.apex

echo "📦 Step 4: Creating Primary Order and GRN..."
sf apex run -o rcg -f scripts/apex/demo-create-grn.apex

echo "💰 Step 5: Raising and Settling Claim..."
sf apex run -o rcg -f scripts/apex/demo-create-claim.apex

echo "✅ Demo completed! Opening org..."
sf org open -o rcg

echo ""
echo "🎯 Demo Highlights:"
echo "  • BeatPlan → BeatRoute → BeatStops created"
echo "  • Visit with Check-in/out and Activities"
echo "  • SecondaryOrder with automatic promotions applied"
echo "  • GRN posted → InventoryLedger updated"
echo "  • Claim raised and processed"
echo ""
echo "Navigate to:"
echo "  • App: RCG Field Execution"
echo "  • Tabs: Visits, Secondary Orders, GRNs, Claims"
