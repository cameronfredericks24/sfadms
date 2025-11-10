/**
 * @description Global invocable class for price resolution, UoM conversion, taxes, and promo stackability
 * @author RCG Team
 * @date 2024
 */
global with sharing class PricingEngine {
    
    /**
     * @description Invocable method to apply pricing to order lines
     * @param requests List of pricing requests
     * @return List of pricing results
     */
    @InvocableMethod(label='Apply Pricing' description='Applies pricing, taxes, and promotions to order lines')
    global static List<PricingResult> applyPricing(List<PricingRequest> requests) {
        List<PricingResult> results = new List<PricingResult>();
        
        for (PricingRequest req : requests) {
            PricingResult result = processPricing(req);
            results.add(result);
        }
        
        return results;
    }
    
    /**
     * @description Processes pricing for a single request
     * @param req Pricing request
     * @return Pricing result
     */
    private static PricingResult processPricing(PricingRequest req) {
        PricingResult result = new PricingResult();
        result.orderId = req.orderId;
        result.orderLineIds = req.orderLineIds;
        result.success = true;
        result.errors = new List<String>();
        
        try {
            // Query order and lines
            SecondaryOrder__c order = [
                SELECT Id, Retailer__c, Distributor__c, GrossAmount__c, NetAmount__c, TaxAmount__c
                FROM SecondaryOrder__c
                WHERE Id = :req.orderId
                LIMIT 1
            ];
            
            List<SecondaryOrderLine__c> lines = [
                SELECT Id, Product__c, QtyBase__c, QtyDisplay__c, UoM__c, UnitPrice__c,
                       LineDiscount__c, Tax__c, NetLineAmount__c, BatchLot__c
                FROM SecondaryOrderLine__c
                WHERE SecondaryOrder__c = :req.orderId
            ];
            
            if (lines.isEmpty()) {
                result.success = false;
                result.errors.add('No order lines found');
                return result;
            }
            
            // Get pricebook entries for products
            Set<Id> productIds = new Set<Id>();
            for (SecondaryOrderLine__c line : lines) {
                productIds.add(line.Product__c);
            }
            
            Map<Id, PricebookEntry> pricebookMap = getPricebookEntries(productIds, order.Distributor__c);
            
            // Process each line
            Decimal totalGross = 0;
            Decimal totalNet = 0;
            Decimal totalTax = 0;
            
            for (SecondaryOrderLine__c line : lines) {
                PricebookEntry pbe = pricebookMap.get(line.Product__c);
                if (pbe == null) {
                    result.errors.add('No pricebook entry found for product: ' + line.Product__c);
                    continue;
                }
                
                // Set unit price
                line.UnitPrice__c = pbe.UnitPrice;
                
                // Normalize quantity
                Decimal qtyBase = normalizeQuantity(line.QtyDisplay__c, line.UoM__c);
                line.QtyBase__c = qtyBase;
                
                // Calculate line amounts
                Decimal lineGross = qtyBase * line.UnitPrice__c;
                Decimal lineDiscount = calculateDiscount(line, order);
                Decimal lineNet = lineGross - lineDiscount;
                Decimal lineTax = calculateTax(lineNet, getTaxRate(line.Product__c));
                
                line.LineDiscount__c = lineDiscount;
                line.NetLineAmount__c = lineNet;
                line.Tax__c = lineTax;
                
                totalGross += lineGross;
                totalNet += lineNet;
                totalTax += lineTax;
            }
            
            // Apply promotions
            List<AppliedPromotion__c> appliedPromos = applyPromotions(order, lines);
            
            // Update order totals
            order.GrossAmount__c = totalGross;
            order.NetAmount__c = totalNet;
            order.TaxAmount__c = totalTax;
            
            // Update records
            update order;
            update lines;
            if (!appliedPromos.isEmpty()) {
                insert appliedPromos;
            }
            
            result.appliedPromotionIds = new List<Id>();
            for (AppliedPromotion__c ap : appliedPromos) {
                result.appliedPromotionIds.add(ap.Id);
            }
            
        } catch (Exception e) {
            result.success = false;
            result.errors.add('Error: ' + e.getMessage());
            Util.logError('PricingEngine', 'applyPricing', e);
        }
        
        return result;
    }
    
    /**
     * @description Gets pricebook entries for products
     * @param productIds Product IDs
     * @param distributorId Distributor ID
     * @return Map of product ID to pricebook entry
     */
    private static Map<Id, PricebookEntry> getPricebookEntries(Set<Id> productIds, Id distributorId) {
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        
        // TODO: Get standard pricebook or distributor-specific pricebook
        Id pricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : getStandardPricebookId();
        
        List<PricebookEntry> entries = [
            SELECT Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :productIds
            AND Pricebook2Id = :pricebookId
            AND IsActive = true
        ];
        
        for (PricebookEntry pbe : entries) {
            pricebookMap.put(pbe.Product2Id, pbe);
        }
        
        return pricebookMap;
    }
    
    /**
     * @description Normalizes quantity based on UoM
     * @param qtyDisplay Display quantity string
     * @param uom Unit of measure
     * @return Normalized quantity
     */
    private static Decimal normalizeQuantity(String qtyDisplay, String uom) {
        if (String.isBlank(qtyDisplay)) {
            return 0;
        }
        
        Decimal qty = Decimal.valueOf(qtyDisplay);
        
        // Convert to base units (EA)
        if (uom == 'CS') {
            qty = qty * 12; // Case = 12 EA
        } else if (uom == 'PK') {
            qty = qty * 6; // Pack = 6 EA
        } else if (uom == 'CTN') {
            qty = qty * 24; // Carton = 24 EA
        }
        
        return qty;
    }
    
    /**
     * @description Calculates discount for a line
     * @param line Order line
     * @param order Order
     * @return Discount amount
     */
    private static Decimal calculateDiscount(SecondaryOrderLine__c line, SecondaryOrder__c order) {
        // TODO: Implement discount logic based on promotions
        return 0;
    }
    
    /**
     * @description Calculates tax for an amount
     * @param amount Amount
     * @param taxRate Tax rate
     * @return Tax amount
     */
    private static Decimal calculateTax(Decimal amount, Decimal taxRate) {
        return amount * (taxRate / 100);
    }
    
    /**
     * @description Gets tax rate for a product
     * @param productId Product ID
     * @return Tax rate percentage
     */
    private static Decimal getTaxRate(Id productId) {
        // TODO: Get tax rate from product or custom metadata
        return 18.0; // Default 18% GST
    }
    
    /**
     * @description Applies promotions to order
     * @param order Order
     * @param lines Order lines
     * @return List of applied promotions
     */
    private static List<AppliedPromotion__c> applyPromotions(SecondaryOrder__c order, List<SecondaryOrderLine__c> lines) {
        List<AppliedPromotion__c> appliedPromos = new List<AppliedPromotion__c>();
        
        // TODO: Implement promotion eligibility and application logic
        // Use SchemeEligibility class to evaluate rules
        
        return appliedPromos;
    }
    
    /**
     * @description Gets standard pricebook ID
     * @return Standard pricebook ID
     */
    private static Id getStandardPricebookId() {
        Pricebook2 stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        return stdPb.Id;
    }
    
    /**
     * @description Pricing request wrapper
     */
    global class PricingRequest {
        @InvocableVariable(label='Order ID' required=true)
        global Id orderId;
        
        @InvocableVariable(label='Order Line IDs')
        global List<Id> orderLineIds;
    }
    
    /**
     * @description Pricing result wrapper
     */
    global class PricingResult {
        @InvocableVariable
        global Id orderId;
        
        @InvocableVariable
        global List<Id> orderLineIds;
        
        @InvocableVariable
        global Boolean success;
        
        @InvocableVariable
        global List<String> errors;
        
        @InvocableVariable
        global List<Id> appliedPromotionIds;
    }
}
