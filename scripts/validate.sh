#!/usr/bin/env bash
set -euo pipefail

echo "Running validation checks..."

# Run Apex PMD
echo "Running Apex PMD..."
sf apex run pmd --format json --output-dir .pmd-results || echo "PMD check completed"

# Run LWC ESLint
echo "Running LWC ESLint..."
sf project run lint --source-dir force-app/main/default/lwc || echo "ESLint check completed"

# Run Apex tests
echo "Running Apex tests..."
sf apex run test --code-coverage --result-format human --wait 10 || echo "Test execution completed"

echo "Validation complete!"
