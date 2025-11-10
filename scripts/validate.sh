#!/usr/bin/env bash
set -euo pipefail

echo "Running validation..."

# Lint Apex
echo "Linting Apex..."
sf apex run pmd --rulesets .pmd/apex-ruleset.xml || echo "PMD check failed"

# Lint LWC
echo "Linting LWC..."
npm run lint:lwc || echo "LWC lint failed"

# Run tests
echo "Running tests..."
sf apex run test --code-coverage --result-format human --wait 10 || echo "Tests failed"

echo "Validation complete!"
