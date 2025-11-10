#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Running validation checks..."

# Check if required tools are installed
command -v sf >/dev/null 2>&1 || { echo "❌ Salesforce CLI (sf) not found"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "❌ Node.js not found"; exit 1; }

echo "✅ Required tools found"

# Run Apex tests
echo "🧪 Running Apex tests..."
sf apex run test -o rcg --code-coverage --result-format human --wait 10

# Run LWC tests
echo "🧪 Running LWC Jest tests..."
npm run test:unit:coverage

# Run lint checks
echo "🔧 Running lint checks..."
npm run lint || echo "⚠️  Lint warnings found"

echo "✅ Validation complete!"
