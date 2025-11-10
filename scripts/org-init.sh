#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Creating scratch org for RCG Retail Execution DMS..."
sf org create scratch -f config/project-scratch-def.json -a rcg -y 7 -w 10

echo "📦 Deploying metadata to scratch org..."
sf project deploy start -o rcg -d force-app

echo "👤 Assigning permission sets..."
sf org assign permset -o rcg -n RCG_FSR_Mobile
sf org assign permset -o rcg -n RCG_ASM_Manager
sf org assign permset -o rcg -n RCG_Distributor_Admin

echo "✅ Scratch org created and configured!"
echo "Run ./scripts/data-seed.sh to load sample data"
sf org open -o rcg
