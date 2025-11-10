#!/usr/bin/env bash
set -euo pipefail

echo "Creating scratch org..."
sf org create scratch -f config/project-scratch-def.json -a rcg -y 7

echo "Deploying metadata..."
sf project deploy start -o rcg

echo "Assigning permission sets..."
sf org assign permset -o rcg -n RCG_FSR_Mobile || echo "Permission set assignment skipped"
sf org assign permset -o rcg -n RCG_ASM_Manager || echo "Permission set assignment skipped"
sf org assign permset -o rcg -n RCG_Distributor_Admin || echo "Permission set assignment skipped"

echo "Opening org..."
sf org open -o rcg

echo "Setup complete!"
