#!/usr/bin/env bash
set -euo pipefail

echo "Running RCG Retail Execution + DMS Demo..."

# Create sample BeatPlan
echo "Creating BeatPlan..."
sf data create record -s BeatPlan__c -v "Month__c=2024-07-01 Status__c=Draft" -o rcg || echo "BeatPlan creation skipped"

# Create sample Visit
echo "Creating Visit..."
sf data create record -s Visit__c -v "Status__c=Planned" -o rcg || echo "Visit creation skipped"

# Create sample SecondaryOrder
echo "Creating SecondaryOrder..."
sf data create record -s SecondaryOrder__c -v "Status__c=Draft" -o rcg || echo "SecondaryOrder creation skipped"

echo "Demo setup complete!"
echo "Open the org and navigate to the relevant objects to see the demo data."
