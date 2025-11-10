# RCG Retail Execution + DMS (Distributor Management System)

A comprehensive Salesforce solution for Retail Consumer Goods (RCG) industry implementing Retail Execution and Distributor Management capabilities across Platform, Experience Cloud, and Mobile.

## Overview

This solution provides:
- **Field Sales Execution**: Beat planning, route optimization, visit management, order capture
- **Distributor Management**: GRN processing, inventory ledger, replenishment, claims
- **Trade Promotion Management**: Promotions, eligibility rules, accruals, settlements
- **Mobile-First Experience**: React Native app with offline capability (Salesforce Mobile SDK)
- **Distributor Portal**: Experience Cloud site for distributor self-service

## Prerequisites

- Salesforce CLI (sf) v2.x or later
- Node.js 18+ and npm
- Java 11+ (for PMD)
- Git

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd rcg-retail-execution-dms
   ```

2. **Authenticate with Salesforce**
   ```bash
   sf org login web -a rcg
   ```

3. **Create scratch org and deploy**
   ```bash
   ./scripts/org-init.sh
   ```

4. **Seed data**
   ```bash
   ./scripts/data-seed.sh
   ```

5. **Run demo**
   ```bash
   ./scripts/run-demo.sh
   ```

## Project Structure

```
rcg-retail-execution-dms/
├── force-app/main/default/
│   ├── classes/          # Apex classes and tests
│   ├── triggers/         # Apex triggers
│   ├── flows/           # Salesforce Flows
│   ├── lwc/             # Lightning Web Components
│   ├── objects/         # Custom objects and fields
│   ├── permissionsets/  # Permission sets
│   └── ...
├── data/                # CSV seed data files
├── scripts/             # Deployment and utility scripts
├── config/              # Scratch org configuration
└── mobile/              # React Native mobile app (see mobile/README.md)
```

## Key Components

### Custom Objects

- **Planning**: `BeatPlan__c`, `BeatRoute__c`, `BeatStop__c`
- **Execution**: `Visit__c`, `Activity__c`, `RetailInventorySnapshot__c`
- **Orders**: `SecondaryOrder__c`, `SecondaryOrderLine__c`, `PrimaryOrder__c`
- **Inventory**: `BatchLot__c`, `InventoryLedger__c`, `GRN__c`
- **Promotions**: `Promotion__c`, `PromoEligibilityRule__c`, `AppliedPromotion__c`
- **Claims**: `Claim__c`, `ClaimEvidence__c`
- **Replenishment**: `ReplenishmentPolicy__c`, `ReplenishmentProposal__c`

### Apex Classes

- `PricingEngine` - Global invocable pricing engine
- `SchemeEligibility` - Promotion rule evaluation
- `FEFOAllocator` - First Expiry First Out batch allocation
- `LedgerService` - Idempotent inventory ledger posting
- `ReplenishmentService` - Replenishment calculation
- `CreditControl` - Credit limit management
- `ImageAIHook` - Vision API integration stub

### Flows

- `BeatPlan_Publish_RT` - Creates routes when plan is published
- `Visit_CheckIn_RT` - Validates geo-fence and spawns activities
- `SecondaryOrder_Pricing_BeforeSave_RT` - Applies pricing engine
- `GRN_Posted_Ledger_RT` - Posts to inventory ledger
- `Replenishment_Scheduler` - Daily replenishment proposals
- `Accrual_Sweep_Weekly` - Weekly promo accrual sweep

### Lightning Web Components

**Mobile (FSR)**:
- `appHomeKpi` - KPI dashboard
- `beatToday` - Today's route list
- `visitStart` - Visit initiation
- `activityRunner` - Activity checklist
- `orderCart` - Order capture
- `inventoryCheck` - Inventory snapshot
- `posmManager` - POSM management
- `visitClose` - Visit completion

**Desktop (HO/Manager)**:
- `beatPlannerPro` - Route planner
- `tpmDesigner` - Promotion designer
- `dmsControlTower` - DMS dashboard
- `claimsBoard` - Claims Kanban

## Permission Sets

- `RCG_FSR_Mobile` - Field Sales Rep mobile access
- `RCG_ASM_Manager` - Area Sales Manager
- `RCG_Distributor_Admin` - Distributor portal admin
- `RCG_TPM_Manager` - Trade Promotion Manager
- `RCG_Finance_Settlement` - Finance settlement
- `RCG_Integration_User` - Integration user
- `RCG_All_Internal` - Permission set group

## Data Model

```
Promotion__c
  └── PromoEligibilityRule__c
  └── Fund__c
      └── Commitment__c

BeatPlan__c
  └── BeatRoute__c
      └── BeatStop__c

Visit__c
  ├── Activity__c
  ├── RetailInventorySnapshot__c
  ├── PhotoEvidence__c
  └── SecondaryOrder__c
      ├── SecondaryOrderLine__c
      └── AppliedPromotion__c

PrimaryOrder__c
  └── PrimaryOrderLine__c
  └── GRN__c
      └── GRNLine__c

BatchLot__c
InventoryLedger__c

ReplenishmentPolicy__c
  └── ReplenishmentProposal__c

Claim__c
  └── ClaimEvidence__c
```

## Platform Events

- `OrderSubmittedEvent__e` - Fired when order is submitted
- `GRNPostedEvent__e` - Fired when GRN is posted
- `ClaimRaisedEvent__e` - Fired when claim is raised

## Validation Rules

- `InventoryLedger__c.Qty_Not_Zero` - Quantity must not be zero
- `SecondaryOrder__c.Distributor_Required` - Distributor is required
- `SecondaryOrder__c.NetAmount_Non_Negative` - Net amount must be non-negative
- `Claim__c.Amount_Greater_Than_Zero` - Claim amount must be greater than zero

## Testing

Run tests with coverage:
```bash
sf apex run test --code-coverage --result-format human --wait 10
```

Run validation script:
```bash
./scripts/validate.sh
```

## CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`) runs:
- PMD linting
- ESLint for LWCs
- Apex tests with coverage check (≥85%)
- Deployment to scratch org

## Packaging

Create unlocked package:
```bash
./scripts/package-create-install.sh
```

## Mobile App

See `mobile/README.md` for React Native mobile app setup and usage.

## Troubleshooting

### Deployment Issues

1. **Permission Set Assignment Fails**
   - Ensure permission sets are deployed before assignment
   - Check that user has necessary permissions

2. **Flow Activation Errors**
   - Verify all referenced Apex classes are deployed
   - Check flow element configurations

3. **Test Failures**
   - Ensure test data setup methods create required records
   - Check for hardcoded IDs or record type dependencies

### Common Gotchas

- Record Types: Some objects may require record types (Distributor/Retailer on Account)
- Territory2: BeatPlan references Territory2 - ensure Territories are set up
- Pricebooks: Standard pricebook must exist for pricing engine

## Demo Path

1. Create BeatPlan for current month
2. Publish BeatPlan (triggers route creation)
3. Create Visit and check in (validates geo-fence)
4. Create SecondaryOrder with lines
5. Apply pricing (triggers PricingEngine)
6. Create PrimaryOrder and GRN
7. Post GRN (creates ledger entries)
8. Raise Claim and route for approval

## Contributing

1. Create feature branch
2. Make changes
3. Run validation script
4. Ensure tests pass with ≥85% coverage
5. Submit pull request

## License

MIT

## Support

For issues and questions, please open an issue in the repository.
