# RCG Retail Execution + DMS Solution Blueprint

## Executive Summary

This document outlines the complete solution architecture for the Retail Execution + Distributor Management System (DMS) built on Salesforce Platform, Experience Cloud, and Mobile (React Native).

## Solution Components

### 1. Core Platform Components

#### Custom Objects (25+ objects)
- **Planning**: BeatPlan, BeatRoute, BeatStop
- **Execution**: Visit, Activity, RetailInventorySnapshot, PhotoEvidence
- **Orders**: SecondaryOrder, SecondaryOrderLine, PrimaryOrder, PrimaryOrderLine
- **Inventory**: BatchLot, InventoryLedger, GRN, GRNLine
- **Promotions**: Promotion, PromoEligibilityRule, Fund, Commitment, AppliedPromotion, PromoAccrual
- **Claims**: Claim, ClaimEvidence
- **Replenishment**: ReplenishmentPolicy, ReplenishmentProposal
- **POSM**: POSMAsset

#### Platform Events (3 events)
- OrderSubmittedEvent__e
- GRNPostedEvent__e
- ClaimRaisedEvent__e

### 2. Apex Classes

#### Core Services
- **PricingEngine** (Global Invocable): Price calculation, tax computation, promotion application
- **SchemeEligibility**: JSON-based rule evaluation (slabs, bundles, buyX-getY)
- **FEFOAllocator**: First Expiry First Out batch lot allocation
- **LedgerService**: Idempotent inventory ledger posting
- **ReplenishmentService**: Replenishment quantity calculation
- **CreditControl**: Credit limit validation and hold management
- **ImageAIHook**: Vision API integration stub
- **Util**: Common utilities (rounding, JSON, distance calculation)
- **Logging**: Error logging with correlation IDs

#### Trigger Handlers
- SecondaryOrderLineTriggerHandler: Quantity/UoM normalization
- GRNLineTriggerHandler: Auto-create BatchLot on GRN line insert

#### Test Classes
- All classes have corresponding test classes with ≥85% coverage target
- Test factories using @testSetup for efficient data creation

### 3. Flows

#### Record-Triggered Flows
- **BeatPlan_Publish_RT**: Creates BeatRoute and BeatStop records when plan is published
- **Visit_CheckIn_RT**: Validates geo-fence (150m radius) and spawns Activity records
- **Visit_CheckOut_RT**: Computes compliance score and summary
- **SecondaryOrder_Pricing_BeforeSave_RT**: Invokes PricingEngine before save
- **GRN_Posted_Ledger_RT**: Creates InventoryLedger entries and fires GRNPostedEvent

#### Screen Flows
- **Claim_Submit_Approval**: Claim submission with approval routing

#### Scheduled Flows
- **Replenishment_Scheduler**: Daily at 06:00 - generates ReplenishmentProposal records
- **Accrual_Sweep_Weekly**: Weekly on Monday at 02:00 - rolls up AppliedPromotion to PromoAccrual

### 4. Lightning Web Components

#### Mobile (FSR) Components
- **appHomeKpi**: KPI tiles (coverage, drop size, lines/order, promo uptake)
- **beatToday**: Route list with map, SLA timers, check-in button
- **visitStart**: Retailer snapshot, selfie capture
- **activityRunner**: JSON-driven checklist renderer, photo capture
- **orderCart**: Barcode scan, typeahead, pack/UoM switcher, promo application
- **inventoryCheck**: On-hand quantity and expiry entry
- **posmManager**: POSM issue/receive with photos
- **visitClose**: Signature pad, summary, follow-ups

#### Desktop (HO/Manager) Components
- **beatPlannerPro**: Drag-drop route planner, heatmaps, conflict detector
- **tpmDesigner**: Promotion rule composer (JSON), budget controls, simulator
- **dmsControlTower**: Stock/ledger views, FEFO alerts, OOS heatmap
- **claimsBoard**: Kanban with SLA timers and filters

### 5. Experience Cloud (Distributor Portal)

#### Site Configuration
- **Network**: Distributor_Portal
- **Template**: Customer Service
- **Sharing Sets**: Distributor_Sharing_Set (scoped by Account ownership)

#### Exposed Objects
- GRN, GRNLine
- InventoryLedger
- PrimaryOrder, PrimaryOrderLine
- ReplenishmentProposal
- Claim, ClaimEvidence
- Invoice

### 6. Permission Sets & Groups

- **RCG_FSR_Mobile**: Mobile app access, Visit/Activity/Order CRUD
- **RCG_ASM_Manager**: Planning & approvals, all planning objects
- **RCG_Distributor_Admin**: Portal objects (GRN, Ledger, Claims)
- **RCG_TPM_Manager**: Promotion, Rules, Funds, Accruals
- **RCG_Finance_Settlement**: Claims approval/settle, Accruals
- **RCG_Integration_User**: API, Events, CDC
- **RCG_All_Internal**: Permission Set Group bundling ASM, TPM, Finance

### 7. Validation Rules

- **InventoryLedger__c.Qty_Not_Zero**: Quantity must not be zero
- **InventoryLedger__c.BatchLot_Required**: BatchLot required for batch-managed products
- **SecondaryOrder__c.Distributor_Required**: Distributor is required
- **SecondaryOrder__c.NetAmount_Non_Negative**: Net amount must be non-negative
- **GRN__c.DamagedQty_Check**: Posted cannot be true if DamagedQty > AcceptedQty
- **Claim__c.Amount_Greater_Than_Zero**: Amount must be greater than zero

### 8. React Native Mobile App

#### Architecture
- **Framework**: React Native 0.72+ with TypeScript
- **State**: Redux Toolkit
- **Navigation**: React Navigation
- **Offline**: Salesforce Mobile SDK (SmartStore/SmartSync)
- **Auth**: OAuth2 with SSO/IDP support

#### Core Screens
- Home/KPIs
- Beat Today (route list + map)
- Visit Start
- Activity Runner
- Order Cart
- Inventory Check
- POSM Manager
- Visit Close
- Sync Center

#### Data Model (SmartStore Soups)
- Products, Pricebooks, Promotions/Rules
- Retailers, BeatStops
- Visits, Activities
- OrderDrafts, OrderLines
- InventorySnapshots
- SyncQueue

#### Sync Strategy
- **Sync Down**: Products, Pricebooks, Promotions, BeatStops, Retailers
- **Sync Up**: Visits, Activities, Orders, InventorySnapshots, Photos, Claims

### 9. Integration Points

#### Platform Events
- OrderSubmittedEvent__e → External order processing systems
- GRNPostedEvent__e → ERP/WMS integration
- ClaimRaisedEvent__e → Claims processing system

#### Change Data Capture (CDC)
- SecondaryOrder__c
- InventoryLedger__c

#### External APIs
- ImageAIHook: Vision API for OSA analysis (stub implementation)

### 10. Data Seeding

#### CSV Files
- products.csv (30 SKUs)
- distributors.csv (3 distributors)
- retailers.csv (50 retailers)
- promotions.csv (4 promotions)
- batchlots.csv
- replenishment-policies.csv
- promotion-rules.csv
- posm.csv

#### Import Plan
- data/plan.json for sf data import tree

## Key Business Flows

### 1. Beat Planning Flow
1. ASM creates BeatPlan for month
2. Defines routes and stops
3. Publishes plan → Flow creates BeatRoute/BeatStop records
4. Reps receive assigned routes

### 2. Visit Execution Flow
1. Rep opens beatToday component
2. Selects route and retailer
3. Checks in → Flow validates geo-fence (150m)
4. Flow spawns Activity records from PlannedActivitiesJSON
5. Rep completes activities (OSA, PriceCheck, POSM, etc.)
6. Captures order in orderCart
7. Checks out → Flow computes compliance score

### 3. Order Processing Flow
1. Rep creates SecondaryOrder with lines
2. Before save → Flow invokes PricingEngine
3. PricingEngine applies promotions via SchemeEligibility
4. Creates AppliedPromotion records
5. Calculates totals (gross, net, tax)
6. Fires OrderSubmittedEvent__e

### 4. GRN & Inventory Flow
1. Distributor receives goods
2. Creates GRN with lines
3. Scans/enters BatchLot information
4. Posts GRN → Flow creates InventoryLedger StockIn entries
5. Fires GRNPostedEvent__e
6. Updates BatchLot QtyOnHand

### 5. Replenishment Flow
1. Scheduled Flow runs daily at 06:00
2. Reads ReplenishmentPolicy and InventoryLedger
3. Calculates ProposedQty using ReplenishmentService
4. Creates ReplenishmentProposal records
5. If AutoFlag = true, auto-creates PrimaryOrder

### 6. Claims Flow
1. Distributor/Retailer raises Claim
2. Screen Flow routes for approval
3. Finance approves/settles
4. Accrual_Sweep_Weekly updates PromoAccrual balances

## Security & Compliance

### Field-Level Security
- All custom fields have FLS configured via Permission Sets
- Portal users restricted to Distributor Account scope

### Platform Encryption
- Enabled for PII fields (if configured)
- Device storage encrypted (Mobile SDK)

### Audit Trail
- Field History Tracking on monetary fields
- Logging__c for error tracking with correlation IDs

## Performance Considerations

### Query Optimization
- Selective SOQL queries with indexed fields
- ExternalId fields for efficient lookups
- Bulkified DML operations

### Caching
- Client-side cache for master data (Products, Pricebooks, Promotions)
- LWC @wire cacheable methods

### Async Processing
- Queueable for heavy operations
- Platform Events for async notifications

## Testing Strategy

### Unit Tests
- Apex classes: ≥85% coverage
- LWC components: Jest tests (≥80% statements)
- Mobile: Jest tests (≥80%)

### Integration Tests
- End-to-end flows via demo script
- Platform Event subscribers
- Flow execution paths

### E2E Tests (Mobile)
- Detox for key flows (check-in, order, sync)

## Deployment & CI/CD

### Scratch Org
- Enterprise edition with Communities, Field Service, Platform Encryption
- 7-day expiry

### CI Pipeline
- GitHub Actions workflow
- PMD linting
- ESLint for LWCs
- Apex tests with coverage check (≥85%)
- Deployment to scratch org

### Packaging
- Unlocked package: rcg_retail_execution_dms
- Namespace: rcg

## Demo Script

scripts/run-demo.sh automates:
1. BeatPlan creation and publishing
2. Visit check-in/out simulation
3. SecondaryOrder creation with pricing
4. GRN posting and ledger update
5. Claim creation and approval routing
6. Replenishment proposal generation

## Next Steps

1. **Enhancement Areas**:
   - Complete LWC implementations (currently stubs)
   - Implement full React Native mobile app
   - Add more comprehensive Flow logic
   - Enhance test coverage
   - Add more validation rules

2. **Integration**:
   - Connect ImageAIHook to actual vision API
   - Implement Platform Event subscribers
   - Set up CDC for external systems

3. **Customization**:
   - Adjust pricing rules per client requirements
   - Customize promotion eligibility logic
   - Configure replenishment algorithms

## Support & Documentation

- README.md: Quick start and troubleshooting
- This blueprint: Solution architecture
- Code comments: Inline documentation
- Custom Labels: UI strings externalized
