/**
 * @description Computes ProposedQty__c based on DaysCover, demand avg, SafetyStock
 * @author RCG Team
 * @date 2024
 */
public with sharing class ReplenishmentService {
    
    /**
     * @description Computes replenishment proposal for a product
     * @param policy Replenishment policy
     * @return Proposed quantity
     */
    public static Decimal computeProposedQty(ReplenishmentPolicy__c policy) {
        // Get current inventory level
        Decimal currentStock = getCurrentStock(policy.Distributor__c, policy.Product__c);
        
        // Calculate average demand
        Decimal avgDemand = calculateAverageDemand(policy.Distributor__c, policy.Product__c, policy.DaysCover__c);
        
        // Calculate required quantity
        Decimal requiredQty = (avgDemand * policy.DaysCover__c) + policy.SafetyStock__c - currentStock;
        
        // Apply min/max constraints
        if (requiredQty < policy.MinQty__c) {
            requiredQty = policy.MinQty__c;
        }
        if (requiredQty > policy.MaxQty__c) {
            requiredQty = policy.MaxQty__c;
        }
        
        return requiredQty > 0 ? requiredQty : 0;
    }
    
    /**
     * @description Gets current stock level
     * @param distributorId Distributor ID
     * @param productId Product ID
     * @return Current stock quantity
     */
    private static Decimal getCurrentStock(Id distributorId, Id productId) {
        AggregateResult[] results = [
            SELECT SUM(Qty__c) total
            FROM InventoryLedger__c
            WHERE Distributor__c = :distributorId
            AND Product__c = :productId
            AND MovementType__c IN ('StockIn', 'StockOut', 'Adjust')
        ];
        
        if (results.isEmpty() || results[0].get('total') == null) {
            return 0;
        }
        
        return (Decimal) results[0].get('total');
    }
    
    /**
     * @description Calculates average demand
     * @param distributorId Distributor ID
     * @param productId Product ID
     * @param daysCover Days cover period
     * @return Average daily demand
     */
    private static Decimal calculateAverageDemand(Id distributorId, Id productId, Decimal daysCover) {
        Date startDate = Date.today().addDays(-Integer.valueOf(daysCover));
        
        AggregateResult[] results = [
            SELECT SUM(Qty__c) total, COUNT_DISTINCT(DAY_ONLY(TxnTs__c)) dayCount
            FROM InventoryLedger__c
            WHERE Distributor__c = :distributorId
            AND Product__c = :productId
            AND MovementType__c = 'StockOut'
            AND TxnTs__c >= :startDate
        ];
        
        if (results.isEmpty() || results[0].get('total') == null) {
            return 0;
        }
        
        Decimal totalQty = (Decimal) results[0].get('total');
        Integer dayCount = (Integer) results[0].get('dayCount');
        
        if (dayCount == 0) {
            return 0;
        }
        
        return totalQty / dayCount;
    }
}
