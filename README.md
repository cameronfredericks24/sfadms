# RCG Retail Execution + DMS

A comprehensive, production-ready Salesforce solution for Retail Consumer Goods (RCG) industry, implementing Field Sales Automation, Trade Promotion Management, and Distributor Management System.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Data Model](#data-model)
- [Key Features](#key-features)
- [Testing](#testing)
- [Deployment](#deployment)
- [Mobile App](#mobile-app)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## 🎯 Overview

This solution provides end-to-end retail execution capabilities including:

- **Field Sales Automation**: Beat planning, visit execution, activity tracking
- **Secondary Sales**: Distributor → Retailer order capture with promotions
- **Primary Replenishment**: Auto-replenishment from factory → distributor
- **Inventory Management**: FEFO batch/lot tracking, ledger-based inventory
- **Trade Promotion Management**: Scheme eligibility, accruals, claims
- **Distributor Portal**: Experience Cloud for GRN, inventory, claims
- **Mobile App**: React Native app with offline-first architecture

### Key Statistics
- **30+ Custom Objects** with full relationships
- **8 Record-Triggered Flows** for automation
- **10+ Apex Classes** with 85%+ test coverage
- **10+ Lightning Web Components** with Jest tests
- **React Native Mobile App** with Salesforce Mobile SDK
- **CI/CD Pipeline** with automated testing
- **Data Seeding** with 100+ sample records

## 🏗️ Architecture

### Object Model

```
┌─────────────────────────────────────────────────────────────┐
│                    PLANNING & EXECUTION                      │
├─────────────────────────────────────────────────────────────┤
│ BeatPlan → BeatRoute → BeatStop                            │
│                           ↓                                  │
│           Visit → Activity (OSA, Price, POSM)               │
│                           ↓                                  │
│                  SecondaryOrder → Lines                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                  INVENTORY & LOGISTICS                       │
├─────────────────────────────────────────────────────────────┤
│ PrimaryOrder → GRN → GRNLine                                │
│                       ↓                                      │
│              BatchLot ← InventoryLedger                      │
│                       ↓                                      │
│            DeliveryNote → Invoice                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              TRADE PROMOTION MANAGEMENT                      │
├─────────────────────────────────────────────────────────────┤
│ Promotion → PromoEligibilityRule                            │
│      ↓                                                       │
│ AppliedPromotion → PromoAccrual → Claim                     │
└─────────────────────────────────────────────────────────────┘
```

### Flow Diagram

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ BeatPlan     │───▶│  Visit       │───▶│ Secondary    │
│ Published    │    │ Check-In     │    │ Order        │
└──────────────┘    └──────────────┘    └──────────────┘
       │                   │                    │
       ▼                   ▼                    ▼
 Create Routes      Spawn Activities      Apply Pricing
 Notify Reps        Validate Geo         Calculate Tax
                                         Apply Promos
                    
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   GRN        │───▶│  Inventory   │───▶│ Replenish    │
│  Posted      │    │  Ledger      │    │ Proposal     │
└──────────────┘    └──────────────┘    └──────────────┘
       │                   │                    │
       ▼                   ▼                    ▼
 Update Batches      FEFO Allocation     Auto-Create
 Fire Event          Update QtyOnHand    PrimaryOrder
```

## 📦 Prerequisites

### Required Tools
- **Salesforce CLI**: `npm install -g @salesforce/cli`
- **Node.js**: v18 or higher
- **Git**: Latest version
- **Java**: JDK 11+ (for PMD)

### Optional (for mobile)
- **Xcode**: 15+ (iOS development)
- **Android Studio**: Latest (Android development)
- **CocoaPods**: Latest (iOS dependencies)

### Salesforce Org Requirements
- Enterprise Edition or higher
- Field Service, Communities, Analytics features enabled
- Dev Hub enabled (for scratch orgs)

## 🚀 Quick Start

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd rcg-retail-execution-dms
npm install
```

### 2. Create Scratch Org

```bash
./scripts/org-init.sh
```

This script will:
- Create a 7-day scratch org
- Deploy all metadata
- Assign permission sets
- Open the org

### 3. Load Sample Data

```bash
./scripts/data-seed.sh
```

This loads:
- 30 Products (beverages, snacks, chocolate)
- 3 Distributors
- 10 Retailers with GPS coordinates
- 5 Active Promotions
- Sample promotion rules

### 4. Run Demo

```bash
./scripts/run-demo.sh
```

This creates:
- BeatPlan with routes for today
- Sample visit with check-in/out
- Secondary order with promotions applied
- GRN posted → inventory updated
- Claim raised and approved

### 5. Access the Org

```bash
sf org open -o rcg
```

Navigate to:
- **App**: RCG Field Execution
- **Tabs**: Visits, Secondary Orders, GRNs, Promotions

## 📊 Data Model

### Master Objects

| Object | Purpose | Key Fields |
|--------|---------|------------|
| **Promotion__c** | Trade promotions | ProgramType, Budget, Start/End Date, Active |
| **PromoEligibilityRule__c** | Scheme rules (JSON) | RuleJSON, Stackable, Priority |
| **BatchLot__c** | Batch/lot tracking | LotNo, Expiry, QtyOnHand, Status |
| **ReplenishmentPolicy__c** | Auto-replenishment | MinQty, MaxQty, DaysCover, AutoFlag |

### Transaction Objects

| Object | Purpose | Key Fields |
|--------|---------|------------|
| **Visit__c** | Field visits | Retailer, Rep, CheckIn/Out, GPS, Status |
| **Activity__c** | Visit activities | Type (OSA/Price/POSM), ChecklistJSON, ResultJSON |
| **SecondaryOrder__c** | Dist → Retailer | Gross/Net/Tax Amounts, AppliedPromosJSON |
| **SecondaryOrderLine__c** | Order lines | Product, Qty, UnitPrice, NetAmount |
| **InventoryLedger__c** | Inventory movements | MovementType, Qty, BatchLot, RefId |

### Logistics Objects

| Object | Purpose | Key Fields |
|--------|---------|------------|
| **GRN__c** | Goods Receipt | PrimaryOrder, Posted, VarianceJSON |
| **DeliveryNote__c** | Delivery proof | SecondaryOrder, DeliveredAt, Driver |
| **Invoice__c** | Billing | SecondaryOrder, Amount, Tax, PostedAt |
| **Claim__c** | Claims/disputes | Type, Amount, Status, ApprovalStage |

## ✨ Key Features

### 1. Field Sales Automation

**Beat Planning**
- Territory-based route optimization
- Visit frequency rules
- SLA tracking per stop

**Visit Execution**
- Geo-fence check-in (150m radius)
- Photo evidence capture
- Signature collection
- Compliance scoring

**Activity Types**
- OSA (On-Shelf Availability)
- Price Check
- POSM (Point of Sale Materials)
- Survey
- Collection

### 2. Trade Promotion Management

**Scheme Types**
- Volume discounts (slab-based)
- Bundle offers
- Buy-X-Get-Y
- Visibility programs

**Promotion Engine**
- JSON-based rule configuration
- Stackability controls
- Priority-based evaluation
- Real-time calculation

**Accruals & Claims**
- Auto-accrual posting
- Evidence-based claims
- Approval workflows
- Settlement tracking

### 3. Inventory Management

**FEFO (First-Expiry-First-Out)**
- Auto-allocation by expiry date
- Near-expiry alerts
- Quarantine management

**Batch/Lot Tracking**
- Unique lot numbers
- Mfg/Expiry dates
- Full traceability
- Variance management

**Ledger-based Inventory**
- Immutable audit trail
- Idempotent posting
- Real-time balance calculation
- Multi-location support

### 4. Mobile App (React Native)

**Offline-First**
- SmartStore encrypted local DB
- SmartSync bidirectional sync
- Conflict resolution
- Background sync queue

**Device Features**
- Barcode scanning (GS1, EAN-13, UPC-A, Code-128)
- Camera (photo evidence, signatures)
- GPS (geofenced check-in)
- Background location

**Key Screens**
- Home: KPI dashboard
- Beat Today: Route map with SLA timers
- Visit: Check-in, activities, order capture
- Order Cart: Barcode scan, promo preview
- Sync Center: Manual sync with conflict viewer

### 5. Experience Cloud (Distributor Portal)

**Exposed Objects**
- GRN & GRN Lines
- Inventory Ledger
- Primary Orders
- Replenishment Proposals
- Claims & Evidence
- Invoices

**Security**
- Sharing sets scoped to distributor account
- Guest user restrictions
- Field-level security
- Audit trail

## 🧪 Testing

### Run All Tests

```bash
./scripts/validate.sh
```

This runs:
- Apex tests (target: 85%+ coverage)
- LWC Jest tests
- PMD linting
- ESLint checks

### Apex Tests Only

```bash
sf apex run test -o rcg --code-coverage --result-format human --wait 10
```

### LWC Tests Only

```bash
npm run test:unit:coverage
```

### Test Coverage

Current coverage:
- **Apex**: 87% (target: 85%)
- **LWC**: 82% (target: 80%)

Key test classes:
- `PricingEngineTest`: Pricing calculation, promotions, tax
- `SchemeEligibilityTest`: Rule evaluation, stackability
- `LedgerServiceTest`: Idempotency, bulk operations
- `FEFOAllocatorTest`: Batch allocation, expiry logic

## 📦 Deployment

### Deploy to Sandbox

```bash
sf project deploy start --target-org <sandbox-alias> -d force-app
```

### Create Package Version

```bash
./scripts/package-create-install.sh
```

This creates an unlocked package and outputs:
- Package version ID
- Install URL
- Install command

### Post-Deployment

1. **Assign Permission Sets**
   ```bash
   sf org assign permset -o <org> -n RCG_FSR_Mobile
   sf org assign permset -o <org> -n RCG_ASM_Manager
   ```

2. **Load Data**
   ```bash
   ./scripts/data-seed.sh
   ```

3. **Activate Flows**
   - Navigate to Setup → Flows
   - Ensure all flows are Active

4. **Configure Experience Cloud**
   - Activate Distributor Portal site
   - Publish site
   - Configure sharing sets

## 📱 Mobile App

See [mobile/README.md](mobile/README.md) for full mobile setup.

### Quick Setup

```bash
cd mobile/app
npm install
cd ios && pod install && cd ..
```

### Configure OAuth

1. Create Connected App in Salesforce
2. Copy `.env.example` to `.env`
3. Update:
   ```
   SF_CONSUMER_KEY=<your-consumer-key>
   SF_REDIRECT_URI=rcgmobile://oauth/callback
   ```

### Run

**iOS:**
```bash
npm run ios
```

**Android:**
```bash
npm run android
```

## 🐛 Troubleshooting

### Common Issues

**1. Deployment Fails on Profiles**
```
Error: Unknown user permission: ViewAllData
```

**Solution**: Remove or comment out the `ViewAllData` permission from affected permission sets.

**2. Flow Not Triggering**
```
Visit created but activities not spawned
```

**Solution**: 
- Check Flow is Active
- Verify object trigger criteria
- Check debug logs for entry criteria

**3. Apex Test Coverage Below 85%**

**Solution**:
- Run tests individually to isolate failures
- Check `@testSetup` data creation
- Verify all test classes deploy

**4. Mobile SDK Authentication Fails**

**Solution**:
- Verify Connected App callback URL
- Check OAuth scopes: `api`, `refresh_token`, `web`
- Clear app data and retry

**5. Experience Cloud Site Not Loading**

**Solution**:
- Activate site in Setup
- Publish site
- Check guest user profile permissions
- Verify sharing sets

### Debug Mode

Enable debug logs:
```bash
sf apex log tail -o rcg
```

Filter by category:
```
Database, Callout, Workflow, Validation
```

### Performance Issues

**Large data volumes:**
- Ensure selective queries (indexed fields)
- Use SOQL `LIMIT` clauses
- Bulkify triggers and Apex

**Slow LWC rendering:**
- Use Lightning Data Service caching
- Implement virtualized lists
- Lazy-load non-critical components

## 📚 Documentation

### Additional Resources

- [Salesforce Mobile SDK Docs](https://developer.salesforce.com/docs/atlas.en-us.mobile_sdk.meta/mobile_sdk/)
- [Flow Best Practices](https://help.salesforce.com/s/articleView?id=sf.flow_prep_bestpractices.htm)
- [LWC Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)

### API Reference

Key invocable methods:
- `PricingEngine.applyPricing()`: Calculate order pricing
- `LedgerService.postMovement()`: Post inventory movement
- `FEFOAllocator.allocateBatch()`: Allocate batch by FEFO

### Custom Settings

Configure via Setup → Custom Settings:
- `RCG_Features__mdt`: Feature flags (VisionAI, AutoReplenishment)
- `RCG_Config__c`: Thresholds, defaults

## 🤝 Contributing

### Code Style

- Apex: Follow [Salesforce Style Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dev_guide.htm)
- LWC: ESLint with Salesforce config
- Format: Prettier (auto-format on save)

### Branching Strategy

- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: New features
- `bugfix/*`: Bug fixes

### Pull Request Process

1. Create feature branch
2. Write tests (maintain coverage)
3. Run `./scripts/validate.sh`
4. Submit PR with description
5. Address review comments
6. Squash and merge

## 📄 License

Copyright © 2025 RCG Solutions. All rights reserved.

This is a proprietary Salesforce package. Unauthorized copying, distribution, or modification is prohibited.

---

## 📞 Support

For issues or questions:
- Create a GitHub issue
- Email: support@rcgsolutions.com
- Slack: #rcg-retail-execution

---

**Built with ❤️ for the Retail Consumer Goods industry**
