#!/usr/bin/env bash
set -euo pipefail

echo "Running demo..."

# Create sample beat plan
echo "Creating beat plan..."
sf data create record -o rcg -s BeatPlan__c -v "Month__c=2024-01-01 Status__c=Draft" || echo "Beat plan creation failed"

# Create visit
echo "Creating visit..."
sf data create record -o rcg -s Visit__c -v "Status__c=Planned" || echo "Visit creation failed"

# Create secondary order
echo "Creating secondary order..."
sf data create record -o rcg -s SecondaryOrder__c -v "Status__c=Draft" || echo "Secondary order creation failed"

# Create primary order
echo "Creating primary order..."
sf data create record -o rcg -s PrimaryOrder__c -v "Status__c=Draft" || echo "Primary order creation failed"

# Create GRN
echo "Creating GRN..."
sf data create record -o rcg -s GRN__c -v "Posted__c=false" || echo "GRN creation failed"

# Create claim
echo "Creating claim..."
sf data create record -o rcg -s Claim__c -v "Status__c=Draft Type__c=Damage Amount__c=100" || echo "Claim creation failed"

echo "Demo data created!"
echo "Opening org..."
sf org open -o rcg
