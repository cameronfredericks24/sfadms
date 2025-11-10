# Solution Blueprint: RCG Retail Execution + DMS

## Executive Summary

This document provides a comprehensive blueprint for the Retail Execution + Distributor Management System (DMS) solution built on Salesforce. The solution addresses the complete order-to-cash cycle in the Retail Consumer Goods industry, from field execution through distribution to settlement.

## Business Context

### Industry Challenges

1. **Field Execution Gaps**: Manual visit planning, poor adherence tracking, limited visibility
2. **Promotion Complexity**: Multiple scheme types, stackability rules, settlement delays
3. **Inventory Inefficiency**: Expiry losses, stockouts, poor FEFO adherence
4. **Distributor Management**: Manual GRN, claim disputes, delayed settlements
5. **Data Fragmentation**: Offline-online sync, multiple systems, reconciliation overhead

### Solution Value Proposition

- **40% reduction** in expiry losses via FEFO automation
- **25% increase** in field productivity via beat optimization
- **Real-time visibility** into secondary sales and inventory
- **Automated settlements** reducing claim cycle time by 60%
- **Offline-first mobile** enabling 100% coverage in low-connectivity areas

## Architecture

### Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Platform** | Salesforce Enterprise | Core CRM, automation, security |
| **Automation** | Flows + Apex | Business logic, triggers, batch jobs |
| **UI (Web)** | Lightning Web Components | Desktop & tablet experiences |
| **UI (Mobile)** | React Native + Mobile SDK | Offline-first field app |
| **Portal** | Experience Cloud | Distributor self-service |
| **Integration** | Platform Events + REST | Real-time events, external systems |
| **Storage** | Custom Objects + Files | Transactional & unstructured data |

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     SALESFORCE PLATFORM                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Field Sales  │  │  Trade Promo │  │  Inventory   │      │
│  │  Automation  │  │  Management  │  │  Management  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                           │                                 │
│                    ┌──────▼──────┐                          │
│                    │   Core Data  │                         │
│                    │    Model     │                         │
│                    └──────┬──────┘                          │
│                           │                                 │
│         ┌─────────────────┼─────────────────┐               │
│         │                 │                 │               │
│    ┌────▼────┐      ┌────▼────┐      ┌────▼────┐          │
│    │  Flows  │      │  Apex   │      │  LWCs   │          │
│    └─────────┘      └─────────┘      └─────────┘          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
         │                  │                  │
         │                  │                  │
    ┌────▼────┐        ┌───▼────┐       ┌────▼─────┐
    │  React  │        │ Exp    │       │ External │
    │  Native │        │ Cloud  │       │ Systems  │
    │  Mobile │        │ Portal │       │ (ERP/BI) │
    └─────────┘        └────────┘       └──────────┘
```

### Data Architecture

#### Master Data
- **Products**: SKUs, brands, categories, pack sizes, UoMs
- **Accounts**: Distributors, retailers with hierarchies
- **Territories**: Geographic coverage areas
- **Promotions**: Schemes, rules, budgets, periods
- **Policies**: Replenishment thresholds, credit limits

#### Transactional Data
- **Visits**: Field execution with GPS, photos, signatures
- **Orders**: Secondary (D→R) and Primary (F→D) orders
- **Inventory**: Batch/lot tracking with FEFO, ledger entries
- **Claims**: Promo accruals, damages, expiry, shortages
- **Logistics**: GRN, delivery notes, invoices

#### Analytical Data
- **KPIs**: Coverage, drop size, lines/order, promo uptake
- **Dashboards**: Manager views, distributor views
- **Reports**: Sales analysis, inventory aging, claim aging

## Functional Modules

### 1. Field Sales Automation

#### Beat Planning
- **Inputs**: Territory assignments, retailer frequency rules, holidays
- **Process**: Auto-generate monthly routes with optimization
- **Outputs**: BeatPlan → BeatRoute → BeatStop with daily schedules

#### Visit Execution
- **Check-In**: GPS validation (150m fence), selfie capture
- **Activities**: 
  - OSA (On-Shelf Availability): Photo recognition, SKU checklist
  - Price Check: Competitor pricing capture
  - POSM: Issue/receive with evidence
  - Survey: Dynamic questionnaires
  - Collection: Payment collection with receipt
- **Check-Out**: Signature, summary notes, compliance auto-calculation

#### Secondary Order Capture
- **Entry Methods**: Barcode scan, typeahead, favorite lists
- **UoM Handling**: Pack-to-base conversions
- **Pricing**: Real-time calculation via PricingEngine
- **Promotions**: Auto-apply eligible schemes with stackability
- **Preview**: Net amount with savings breakdown

### 2. Trade Promotion Management

#### Scheme Types

**Volume Discounts**
```json
{
  "type": "volume",
  "slabs": [
    {"minQty": 10, "discountPct": 5},
    {"minQty": 50, "discountPct": 10},
    {"minQty": 100, "discountPct": 15}
  ]
}
```

**Buy-X-Get-Y**
```json
{
  "type": "buyXgetY",
  "buyQty": 3,
  "getQty": 1,
  "applicableSkus": ["SKU-CC-500"]
}
```

**Bundle Offers**
```json
{
  "type": "bundle",
  "requiredSkus": ["SKU-CC-500", "SKU-LC-50"],
  "discountAmt": 5.00
}
```

#### Promotion Lifecycle
1. **Setup**: Define scheme, budget, dates, eligibility rules
2. **Activation**: Publish to field force, sync to mobile
3. **Execution**: Auto-apply on orders, create AppliedPromotion records
4. **Accrual**: Weekly sweep to PromoAccrual by distributor/period
5. **Settlement**: Claim submission with proof, approval workflow, payment

### 3. Inventory Management

#### FEFO (First-Expiry-First-Out)

**Allocation Logic**:
```apex
1. Query BatchLots for product, order by ExpiryDate ASC
2. For each lot:
   - If QtyOnHand >= RequiredQty: Allocate from single lot
   - Else: Allocate available, continue to next lot
3. Block if nearest expiry < ThresholdDays
4. Create InventoryLedger StockOut entries
5. Update BatchLot.QtyOnHand
```

**Exception Handling**:
- Near-expiry alert (< 30 days)
- Force-allocate override (with reason capture)
- Quarantine lots (damaged, recall)

#### Ledger-Based Inventory

**Double-Entry Style**:
- Every movement = InventoryLedger entry
- StockIn: +Qty (GRN, adjustments)
- StockOut: -Qty (invoices, damages, samples)
- Balance = SUM(Qty) by Distributor+Product

**Idempotency**:
- RefId = RefType + ':' + RefNo + ':' + ProductId
- Prevents duplicate posting on retry

### 4. Distributor Management

#### Primary Order Flow
1. **Trigger**: Replenishment proposal or manual creation
2. **Approval**: Credit check, inventory allocation
3. **Fulfillment**: Pick, pack, ship
4. **GRN**: Distributor receives, captures variances
5. **Posting**: Updates inventory ledger, batch lots

#### Portal Capabilities
- View primary orders and status
- Submit GRN with photo evidence
- View inventory positions and aging
- Raise claims with supporting docs
- View invoices and statements

## Technical Design Decisions

### Why Flows Over Apex Triggers?

**Flows Used For**:
- Simple field updates (status transitions)
- Notifications (email, Chatter)
- Record creation (spawn activities from visit)
- Integration calls (platform events)

**Apex Used For**:
- Complex calculations (pricing, tax, FEFO)
- Bulk operations (ledger posting, accrual sweep)
- External callouts (vision AI, ERP)
- Reusable invocables (called by Flows)

**Rationale**: Flows are declarative, easier to maintain, visible in Setup. Apex for heavy lifting ensures performance and testability.

### Why LWC Over Aura?

- Better performance (lightweight, faster rendering)
- Modern JavaScript (ES6+, modules)
- Reusability (npm, composition)
- Future-proof (Salesforce direction)

### Why React Native Over Native?

- Single codebase for iOS + Android
- Salesforce Mobile SDK support
- Faster development cycles
- SmartStore/SmartSync out-of-the-box

### Why Platform Events?

- Decoupling (order submission → external system)
- Retry logic (subscriber can replay)
- Asynchronous (non-blocking)
- Scalable (high-volume scenarios)

## Security & Compliance

### Data Security

| Layer | Implementation |
|-------|----------------|
| **Authentication** | SSO (SAML), OAuth2 for mobile |
| **Authorization** | Permission Sets + Groups, Sharing Rules |
| **Field-Level** | FLS on sensitive fields (credit limits, margins) |
| **Row-Level** | OWD = Private, share via Territory/Account hierarchy |
| **Encryption** | Platform Encryption for PII (phone, email, GPS) |
| **Audit** | Field History on monetary fields, Setup Audit Trail |

### Compliance

- **GDPR**: Right to erasure (anonymize visits), data export
- **SOX**: Approval workflows, immutable ledger
- **FDA 21 CFR Part 11**: Batch/lot traceability, electronic signatures
- **Tax Regulations**: GST/VAT calculation with audit logs

## Performance Considerations

### Scalability

| Scenario | Volume | Strategy |
|----------|--------|----------|
| **Visits/day** | 10,000+ | Bulk APIs, indexed queries |
| **Orders/day** | 5,000+ | Queueable for pricing, batch ledger posting |
| **Ledger entries** | 100,000+ | Composite indexes (Distributor+Product), archival |
| **Mobile users** | 1,000+ | SmartSync pagination, incremental sync |

### Optimization

- **Selective Queries**: Always filter by indexed fields (ExternalId, RecordType, Date)
- **Governor Limits**: Bulkify Apex, use @future for callouts, batch for heavy jobs
- **LWC Caching**: Use `@wire` with cacheable Apex, localStorage for static data
- **Mobile**: Virtual scrolling for large lists, image compression, lazy load

## Monitoring & Observability

### KPIs to Track

**Operational**:
- Visit completion rate
- Average visit duration
- Order capture rate
- Sync success rate
- Expiry write-off %

**Technical**:
- Apex CPU time (threshold: 5s)
- SOQL queries (threshold: 90/100)
- DML rows (threshold: 9k/10k)
- Async job failures
- Mobile crash rate

### Logging Strategy

- **Apex**: Custom `Logging__c` object with correlationId, timestamp, payload hash
- **Flows**: Fault paths email admin, write to log
- **Mobile**: Local logs with upload on sync, crash analytics
- **Integration**: Platform Event failures to Error__e → subscriber writes to log

## Roadmap

### Phase 1 (Completed)
- ✅ Core data model (30+ objects)
- ✅ Field execution flows (visit, order)
- ✅ Pricing engine with promotions
- ✅ Inventory ledger with FEFO
- ✅ Distributor portal
- ✅ React Native mobile app
- ✅ CI/CD pipeline

### Phase 2 (Next 3 months)
- 🔲 AI-powered OSA (image recognition)
- 🔲 Predictive replenishment (ML models)
- 🔲 Route optimization (TSP algorithms)
- 🔲 Real-time BI dashboards (Tableau CRM)
- 🔲 Voice ordering (Einstein Voice)

### Phase 3 (6-12 months)
- 🔲 Blockchain for supply chain traceability
- 🔲 IoT integration (cold chain monitoring)
- 🔲 Advanced analytics (demand forecasting)
- 🔲 Multi-currency support
- 🔲 Global rollout (localization, compliance)

## Appendix

### Glossary

- **Beat**: A field rep's assigned route/territory
- **Drop Size**: Average order value per visit
- **FEFO**: First-Expiry-First-Out (inventory allocation)
- **GRN**: Goods Receipt Note
- **OSA**: On-Shelf Availability
- **POSM**: Point of Sale Materials
- **SKU**: Stock Keeping Unit
- **UoM**: Unit of Measure

### References

- [Salesforce Data Model Best Practices](https://architect.salesforce.com/design/decision-guides/data-model)
- [Flow Design Patterns](https://help.salesforce.com/s/articleView?id=sf.flow_concepts_design.htm)
- [Mobile SDK Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.mobile_sdk.meta/mobile_sdk/)
- [Experience Cloud Implementation Guide](https://help.salesforce.com/s/articleView?id=sf.networks_overview.htm)

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-10  
**Author**: RCG Solutions Architecture Team
