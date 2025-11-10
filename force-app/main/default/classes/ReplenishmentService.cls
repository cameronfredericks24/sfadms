/**
 * @description Replenishment calculation service
 */
public with sharing class ReplenishmentService {
    
    public static ReplenishmentProposal__c calculateProposal(
        ReplenishmentPolicy__c policy,
        Decimal currentStock,
        Decimal avgDailyDemand
    ) {
        Decimal daysCover = policy.DaysCover__c != null ? policy.DaysCover__c : 30;
        Decimal safetyStock = policy.SafetyStock__c != null ? policy.SafetyStock__c : 0;
        Decimal leadTimeDays = policy.LeadTimeDays__c != null ? policy.LeadTimeDays__c : 7;
        
        // Calculate proposed quantity
        Decimal demandDuringLeadTime = avgDailyDemand * leadTimeDays;
        Decimal targetStock = (avgDailyDemand * daysCover) + safetyStock;
        Decimal proposedQty = Math.max(0, targetStock - currentStock);
        
        // Apply min/max constraints
        if (policy.MinQty__c != null && proposedQty < policy.MinQty__c) {
            proposedQty = policy.MinQty__c;
        }
        if (policy.MaxQty__c != null && proposedQty > policy.MaxQty__c) {
            proposedQty = policy.MaxQty__c;
        }
        
        // Create proposal
        ReplenishmentProposal__c proposal = new ReplenishmentProposal__c(
            Distributor__c = policy.Distributor__c,
            Product__c = policy.Product__c,
            ProposedQty__c = proposedQty,
            BasisJSON__c = JSON.serialize(new Map<String, Object>{
                'currentStock' => currentStock,
                'avgDailyDemand' => avgDailyDemand,
                'daysCover' => daysCover,
                'safetyStock' => safetyStock,
                'leadTimeDays' => leadTimeDays,
                'targetStock' => targetStock,
                'calculatedAt' => Datetime.now().isoFormat()
            })
        );
        
        return proposal;
    }
    
    public static Decimal calculateAverageDailyDemand(Id distributorId, Id productId, Integer days) {
        Date startDate = Date.today().addDays(-days);
        
        // Calculate from InventoryLedger StockOut movements
        AggregateResult[] results = [
            SELECT SUM(Qty__c) totalQty
            FROM InventoryLedger__c
            WHERE Distributor__c = :distributorId
            AND Product__c = :productId
            AND MovementType__c = 'StockOut'
            AND TxnTs__c >= :startDate
        ];
        
        Decimal totalQty = 0;
        if (!results.isEmpty() && results[0].get('totalQty') != null) {
            totalQty = (Decimal) results[0].get('totalQty');
        }
        
        return days > 0 ? totalQty / days : 0;
    }
}
