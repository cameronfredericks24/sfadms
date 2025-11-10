#!/usr/bin/env bash
set -euo pipefail

echo "Creating scratch org..."
sf org create scratch -f config/project-scratch-def.json -a rcg -y 7

echo "Deploying metadata..."
sf project deploy start -d force-app

echo "Assigning permission sets..."
sf org assign permset -o rcg -n RCG_FSR_Mobile || echo "Permission set RCG_FSR_Mobile not found, skipping..."
sf org assign permset -o rcg -n RCG_ASM_Manager || echo "Permission set RCG_ASM_Manager not found, skipping..."
sf org assign permset -o rcg -n RCG_Distributor_Admin || echo "Permission set RCG_Distributor_Admin not found, skipping..."

echo "Importing data..."
if [ -f "data/plan.json" ]; then
    sf data import tree -o rcg -p data/plan.json || echo "Data import failed, continuing..."
fi

echo "Opening org..."
sf org open -o rcg

echo "Setup complete!"
