# RCG Retail Execution + DMS Asset for Salesforce

A comprehensive, deployable Salesforce asset implementing Retail Execution + Distributor Management (DMS) for the Retail Consumer Goods (RCG) industry. This solution includes Platform, Experience Cloud, and Mobile capabilities.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Object Model](#object-model)
- [Features](#features)
- [Setup Instructions](#setup-instructions)
- [Demo Script](#demo-script)
- [Troubleshooting](#troubleshooting)
- [Quality Gates](#quality-gates)
- [CI/CD](#cicd)
- [Packaging](#packaging)
- [Mobile App](#mobile-app)
- [Contributing](#contributing)

## 🎯 Overview

This solution provides:

- **Retail Execution**: Beat planning, route optimization, visit management, field activities, order capture
- **Distributor Management**: GRN processing, inventory ledger, batch lot tracking, FEFO allocation
- **Promotion Management**: Scheme eligibility, promotion application, accrual tracking
- **Claims Management**: Damage, expiry, shortage, and promo claims with approval workflows
- **Replenishment**: Automated replenishment proposals based on policies
- **Experience Cloud**: Distributor portal for self-service operations
- **Mobile App**: React Native app with Salesforce Mobile SDK for field sales reps

## 📦 Prerequisites

- **Salesforce CLI** (sf): Latest version
- **Node.js**: v18 or higher
- **Java**: JDK 11 or higher (for PMD)
- **Git**: For version control
- **Salesforce Org**: Enterprise edition or higher

### Install Salesforce CLI

```bash
npm install -g @salesforce/cli
sf plugins install @salesforce/plugin-data
```

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd rcg-retail-execution-dms
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Initialize scratch org**
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

## 📁 Project Structure

```
rcg-retail-execution-dms/
├── README.md
├── sfdx-project.json
├── package.json
├── .forceignore
├── .prettierrc
├── .eslintrc.json
├── .pmd/
│   └── apex-ruleset.xml
├── scripts/
│   ├── org-init.sh          # Initialize scratch org
│   ├── data-seed.sh          # Seed sample data
│   ├── run-demo.sh           # Run demo scenario
│   ├── validate.sh           # Run linting and tests
│   └── package-create-install.sh  # Create unlocked package
├── config/
│   └── project-scratch-def.json
├── force-app/
│   └── main/default/
│       ├── classes/          # Apex classes
│       ├── objects/           # Custom objects
│       ├── flows/            # Flow automations
│       ├── lwc/              # Lightning Web Components
│       ├── permissionsets/   # Permission sets
│       ├── networks/         # Experience Cloud sites
│       └── ...
├── data/
│   ├── products.csv
│   ├── distributors.csv
│   ├── retailers.csv
│   ├── batchlots.csv
│   ├── promotions.csv
│   └── plan.json
├── mobile/                   # React Native app
│   └── app/
└── .github/
    └── workflows/
        └── ci.yml
```

## 🗂️ Object Model

### Core Objects

#### Promotion Management
- **Promotion__c**: Promotion programs (Visibility, Volume, Consumer, Retailer)
- **PromoEligibilityRule__c**: Rule definitions (slabs, bundles, buy-X-get-Y)
- **Fund__c**: Budget allocation
- **Commitment__c**: Retailer/distributor commitments
- **AppliedPromotion__c**: Applied promotions on orders
- **PromoAccrual__c**: Accrual tracking by period

#### Planning
- **BeatPlan__c**: Monthly beat plans
- **BeatRoute__c**: Daily routes
- **BeatStop__c**: Route stops with planned activities

#### Field Execution
- **Visit__c**: Field visits with geo-tracking
- **Activity__c**: Visit activities (OSA, PriceCheck, POSM, Survey, Collection)
- **RetailInventorySnapshot__c**: Inventory snapshots
- **PhotoEvidence__c**: Photo evidence with AI labels

#### Orders & Inventory
- **SecondaryOrder__c**: Retailer orders
- **SecondaryOrderLine__c**: Order lines with pricing
- **PrimaryOrder__c**: Distributor orders
- **PrimaryOrderLine__c**: Primary order lines
- **BatchLot__c**: Batch/lot tracking with FEFO
- **InventoryLedger__c**: Inventory movements

#### Logistics & Claims
- **GRN__c**: Goods Receipt Note
- **GRNLine__c**: GRN lines
- **DeliveryNote__c**: Delivery documentation
- **Invoice__c**: Invoicing
- **Claim__c**: Claims (Promo, Damage, Expiry, Short)
- **ClaimEvidence__c**: Claim evidence

#### Replenishment
- **ReplenishmentPolicy__c**: Replenishment policies
- **ReplenishmentProposal__c**: Automated proposals

#### Platform Events
- **OrderSubmittedEvent__e**: Order submission events
- **GRNPostedEvent__e**: GRN posting events
- **ClaimRaisedEvent__e**: Claim raising events
- **Logging__e**: Logging events

## ✨ Features

### Retail Execution
- ✅ Beat planning with territory management
- ✅ Route optimization and scheduling
- ✅ Visit check-in/out with geo-fencing (150m radius)
- ✅ Activity checklists (JSON-driven)
- ✅ Photo capture with AI labeling
- ✅ Order capture with barcode scanning
- ✅ Inventory snapshot
- ✅ POSM management

### Distributor Management
- ✅ GRN processing with scanner integration
- ✅ Inventory ledger with idempotency
- ✅ Batch lot tracking with FEFO allocation
- ✅ Primary order management
- ✅ Replenishment automation

### Promotion Management
- ✅ Promotion rule engine (slabs, bundles, buy-X-get-Y)
- ✅ Scheme eligibility evaluation
- ✅ Auto-apply promotions
- ✅ Accrual tracking and settlement

### Claims Management
- ✅ Multi-type claims (Promo, Damage, Expiry, Short)
- ✅ Approval workflows
- ✅ Evidence attachment
- ✅ Settlement tracking

### Experience Cloud
- ✅ Distributor portal
- ✅ Self-service GRN entry
- ✅ Inventory ledger views
- ✅ Claim submission
- ✅ Replenishment proposal review

### Mobile App
- ✅ React Native with Salesforce Mobile SDK
- ✅ Offline-first with SmartStore
- ✅ Background sync
- ✅ Barcode scanning
- ✅ Photo capture
- ✅ Geo-fenced check-in

## 🛠️ Setup Instructions

### 1. Authenticate to Salesforce

```bash
sf org login web -a myorg
```

### 2. Create Scratch Org

```bash
./scripts/org-init.sh
```

This script:
- Creates a scratch org
- Deploys all metadata
- Assigns permission sets
- Imports seed data
- Opens the org

### 3. Configure Experience Cloud

1. Navigate to **Setup > Digital Experiences > All Sites**
2. Create a new site: **Distributor_Portal**
3. Configure sharing sets to scope by Distributor Account
4. Activate the site

### 4. Assign Permission Sets

```bash
sf org assign permset -o myorg -n RCG_FSR_Mobile
sf org assign permset -o myorg -n RCG_ASM_Manager
sf org assign permset -o myorg -n RCG_Distributor_Admin
```

## 🎬 Demo Script

Run the demo script to see the solution in action:

```bash
./scripts/run-demo.sh
```

The demo creates:
1. Beat plan and routes
2. Visit with check-in/out
3. Secondary order with promotions
4. Primary order and GRN
5. Claim submission

### Demo Flow

1. **Beat Planning**: Create a beat plan, approve, and publish routes
2. **Field Visit**: Check-in at retailer, complete activities, capture order
3. **Order Processing**: Apply promotions, calculate pricing, submit order
4. **GRN Processing**: Receive goods, post to ledger
5. **Claim Management**: Raise claim, route for approval, settle

## 🔧 Troubleshooting

### Common Issues

#### 1. Deployment Errors

**Issue**: Metadata deployment fails
**Solution**: 
- Check API version compatibility
- Verify required features are enabled
- Review deployment logs: `sf project deploy report -i <job-id>`

#### 2. Permission Set Assignment Fails

**Issue**: Permission set not found
**Solution**:
- Verify permission sets are deployed
- Check namespace prefix
- Ensure user has "Manage Users" permission

#### 3. Experience Cloud Site Not Accessible

**Issue**: Site returns 404
**Solution**:
- Verify site is activated
- Check sharing sets configuration
- Ensure guest user has appropriate permissions

#### 4. Flow Errors

**Issue**: Flow fails with error
**Solution**:
- Check flow debug logs
- Verify required fields are populated
- Review invocable method parameters

#### 5. Test Coverage Below 85%

**Issue**: Test coverage insufficient
**Solution**:
- Run tests: `sf apex run test --code-coverage`
- Review coverage report
- Add test methods for uncovered code

### Debug Commands

```bash
# View deployment status
sf project deploy report -i <job-id>

# Run tests with coverage
sf apex run test --code-coverage --result-format human

# Check org limits
sf org limits api display -o myorg

# View flow debug logs
sf apex tail log -o myorg
```

## ✅ Quality Gates

### Code Quality

- **Apex**: PMD rules pass
- **LWC**: ESLint rules pass
- **Test Coverage**: ≥85%
- **Code Style**: Prettier formatted

### Run Validation

```bash
./scripts/validate.sh
```

This runs:
- Apex PMD linting
- LWC ESLint
- Apex tests with coverage check

## 🔄 CI/CD

GitHub Actions workflow runs on push/PR:

1. **Lint**: Apex PMD + LWC ESLint
2. **Test**: Apex tests with coverage check
3. **Deploy**: Deploy to scratch org

### GitHub Secrets

Configure these secrets:
- `SF_USERNAME`: Salesforce username
- `SF_ORG_ALIAS`: Org alias

## 📦 Packaging

Create an unlocked package:

```bash
./scripts/package-create-install.sh
```

This creates a package version and provides an install URL.

### Package Installation

1. Navigate to the install URL
2. Authenticate to target org
3. Review package contents
4. Install package

## 📱 Mobile App

The React Native mobile app is located in `mobile/app/`.

### Setup

```bash
cd mobile/app
npm install
cd ios && pod install && cd ..
```

### Run

```bash
# iOS
npm run ios

# Android
npm run android
```

### Features

- Offline-first with SmartStore
- Background sync
- Barcode scanning
- Photo capture
- Geo-fenced check-in

## 🏗️ Architecture

### Apex Classes

- **PricingEngine**: Global invocable for price resolution
- **SchemeEligibility**: Promotion rule evaluation
- **FEFOAllocator**: Batch lot allocation (First Expiry First Out)
- **LedgerService**: Idempotent ledger writes
- **ReplenishmentService**: Replenishment calculation
- **CreditControl**: Credit limit checks
- **ImageAIHook**: External vision API integration
- **Util**: Common utilities
- **Logging**: Platform event logging

### Flows

- **BeatPlan_Publish_RT**: Publishes routes when plan approved
- **Visit_CheckIn_RT**: Validates geo-fence and spawns activities
- **Visit_CheckOut_RT**: Computes compliance score
- **SecondaryOrder_Pricing_BeforeSave_RT**: Applies pricing
- **GRN_Posted_Ledger_RT**: Posts to ledger
- **Claim_Submit_Approval**: Routes claim for approval
- **Replenishment_Scheduler**: Daily replenishment proposals
- **Accrual_Sweep_Weekly**: Weekly accrual rollup

### Lightning Web Components

#### Mobile (FSR)
- **appHomeKpi**: KPI dashboard
- **beatToday**: Today's route
- **visitStart**: Visit initiation
- **activityRunner**: Activity checklist
- **orderCart**: Order capture
- **inventoryCheck**: Inventory snapshot
- **posmManager**: POSM management
- **visitClose**: Visit closure

#### Desktop (HO/Manager)
- **beatPlannerPro**: Route planner
- **tpmDesigner**: Promotion designer
- **dmsControlTower**: DMS dashboard
- **claimsBoard**: Claims Kanban

## 📊 Data Model Diagram

```
Promotion__c
├── PromoEligibilityRule__c
├── Fund__c
│   └── Commitment__c
└── AppliedPromotion__c

BeatPlan__c
├── BeatRoute__c
│   └── BeatStop__c
└── Visit__c
    ├── Activity__c
    ├── RetailInventorySnapshot__c
    ├── PhotoEvidence__c
    └── SecondaryOrder__c
        ├── SecondaryOrderLine__c
        └── AppliedPromotion__c

PrimaryOrder__c
├── PrimaryOrderLine__c
└── GRN__c
    └── GRNLine__c
        └── InventoryLedger__c

BatchLot__c
└── InventoryLedger__c

ReplenishmentPolicy__c
└── ReplenishmentProposal__c

Claim__c
└── ClaimEvidence__c
```

## 🔐 Security

- **Field-Level Security**: Enforced in Apex with `with sharing`
- **Platform Encryption**: Enabled for PII fields
- **Audit Trail**: Enabled for monetary fields
- **Sharing Sets**: Experience Cloud scoped by Account ownership

## 📈 Performance

- **Selective Queries**: All SOQL queries use indexed fields
- **Bulkification**: All triggers and invocable methods handle bulk
- **Queueable**: Heavy operations use Queueable for async processing
- **Caching**: Client-side caching for master data

## 🐛 Known Issues

- ImageAIHook requires external API configuration
- Mobile app requires Salesforce Mobile SDK setup
- Some flows require manual configuration in org

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Run validation: `./scripts/validate.sh`
5. Submit pull request

## 📄 License

[Specify License]

## 👥 Authors

RCG Team

## 🙏 Acknowledgments

- Salesforce Platform
- Salesforce Mobile SDK
- React Native Community

---

**Note**: This is a comprehensive solution. Refer to individual component documentation for detailed usage.
