/**
 * @description Global invocable class for pricing engine
 * Calculates prices, taxes, and applies promotions to order lines
 */
global with sharing class PricingEngine {
    
    global class PricingRequest {
        @InvocableVariable(required=true)
        global Id orderId;
        
        @InvocableVariable(required=false)
        global List<Id> orderLineIds;
    }
    
    global class PricingResult {
        @InvocableVariable
        global Boolean success;
        
        @InvocableVariable
        global String errorMessage;
        
        @InvocableVariable
        global Decimal totalGrossAmount;
        
        @InvocableVariable
        global Decimal totalNetAmount;
        
        @InvocableVariable
        global Decimal totalTaxAmount;
    }
    
    @InvocableMethod(label='Apply Pricing Engine' description='Calculates prices, taxes, and promotions for Secondary Orders')
    global static List<PricingResult> applyPricing(List<PricingRequest> requests) {
        List<PricingResult> results = new List<PricingResult>();
        
        for (PricingRequest req : requests) {
            PricingResult result = new PricingResult();
            try {
                processOrder(req.orderId, req.orderLineIds);
                result.success = true;
                
                // Recalculate totals
                SecondaryOrder__c order = [
                    SELECT GrossAmount__c, NetAmount__c, TaxAmount__c
                    FROM SecondaryOrder__c
                    WHERE Id = :req.orderId
                    LIMIT 1
                ];
                result.totalGrossAmount = order.GrossAmount__c;
                result.totalNetAmount = order.NetAmount__c;
                result.totalTaxAmount = order.TaxAmount__c;
            } catch (Exception e) {
                result.success = false;
                result.errorMessage = e.getMessage();
                rcg.Logging.logError('PricingEngine', 'applyPricing', e);
            }
            results.add(result);
        }
        
        return results;
    }
    
    private static void processOrder(Id orderId, List<Id> orderLineIds) {
        // Fetch order with distributor and retailer
        SecondaryOrder__c order = [
            SELECT Id, Distributor__c, Retailer__c, Status__c
            FROM SecondaryOrder__c
            WHERE Id = :orderId
            LIMIT 1
        ];
        
        // Fetch order lines
        List<SecondaryOrderLine__c> lines = [
            SELECT Id, Product__c, QtyBase__c, UoM__c, UnitPrice__c,
                   LineDiscount__c, Tax__c, NetLineAmount__c, PromoLineRef__c
            FROM SecondaryOrderLine__c
            WHERE SecondaryOrder__c = :orderId
            AND (orderLineIds = null OR Id IN :orderLineIds)
        ];
        
        if (lines.isEmpty()) {
            return;
        }
        
        // Get product IDs and fetch pricebook entries
        Set<Id> productIds = new Set<Id>();
        for (SecondaryOrderLine__c line : lines) {
            productIds.add(line.Product__c);
        }
        
        // Fetch standard pricebook entries
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : [
            SELECT Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :productIds
            AND Pricebook2.IsStandard = true
            AND IsActive = true
        ]) {
            pricebookMap.put(pbe.Product2Id, pbe);
        }
        
        // Fetch active promotions
        List<Promotion__c> activePromos = [
            SELECT Id, ProgramType__c, BudgetAmount__c, StartDate__c, EndDate__c,
                   Channel__c, TargetBrands__c, TargetSkusJSON__c, Active__c
            FROM Promotion__c
            WHERE Active__c = true
            AND StartDate__c <= TODAY
            AND EndDate__c >= TODAY
        ];
        
        // Fetch eligibility rules
        Map<Id, List<PromoEligibilityRule__c>> promoRulesMap = new Map<Id, List<PromoEligibilityRule__c>>();
        for (PromoEligibilityRule__c rule : [
            SELECT Id, Promotion__c, RuleJSON__c, Stackable__c, Priority__c
            FROM PromoEligibilityRule__c
            WHERE Promotion__c IN :new Map<Id, Promotion__c>(activePromos).keySet()
            ORDER BY Priority__c ASC
        ]) {
            if (!promoRulesMap.containsKey(rule.Promotion__c)) {
                promoRulesMap.put(rule.Promotion__c, new List<PromoEligibilityRule__c>());
            }
            promoRulesMap.get(rule.Promotion__c).add(rule);
        }
        
        // Process each line
        Decimal totalGross = 0;
        Decimal totalNet = 0;
        Decimal totalTax = 0;
        
        List<AppliedPromotion__c> appliedPromos = new List<AppliedPromotion__c>();
        
        for (SecondaryOrderLine__c line : lines) {
            // Set base price from pricebook
            PricebookEntry pbe = pricebookMap.get(line.Product__c);
            if (pbe != null) {
                line.UnitPrice__c = pbe.UnitPrice;
            }
            
            // Calculate gross line amount
            Decimal grossLineAmount = (line.UnitPrice__c != null ? line.UnitPrice__c : 0) * 
                                      (line.QtyBase__c != null ? line.QtyBase__c : 0);
            
            // Apply promotions via SchemeEligibility
            Decimal discountAmount = 0;
            List<Promotion__c> applicablePromos = SchemeEligibility.evaluatePromotions(
                line, activePromos, promoRulesMap
            );
            
            for (Promotion__c promo : applicablePromos) {
                Decimal promoValue = calculatePromoValue(promo, line, grossLineAmount);
                discountAmount += promoValue;
                
                AppliedPromotion__c appliedPromo = new AppliedPromotion__c(
                    SecondaryOrder__c = orderId,
                    SecondaryOrderLine__c = line.Id,
                    Promotion__c = promo.Id,
                    Value__c = promoValue,
                    Basis__c = 'Auto-applied via Pricing Engine'
                );
                appliedPromos.add(appliedPromo);
            }
            
            line.LineDiscount__c = discountAmount;
            
            // Calculate net line amount
            Decimal netLineAmount = grossLineAmount - discountAmount;
            line.NetLineAmount__c = netLineAmount;
            
            // Calculate tax (simplified - 10% GST)
            Decimal taxRate = 0.10;
            line.Tax__c = netLineAmount * taxRate;
            
            totalGross += grossLineAmount;
            totalNet += netLineAmount;
            totalTax += line.Tax__c;
        }
        
        // Update order totals
        order.GrossAmount__c = totalGross;
        order.NetAmount__c = totalNet;
        order.TaxAmount__c = totalTax;
        
        // Update lines and insert applied promotions
        update lines;
        update order;
        
        if (!appliedPromos.isEmpty()) {
            insert appliedPromos;
        }
    }
    
    private static Decimal calculatePromoValue(Promotion__c promo, SecondaryOrderLine__c line, Decimal grossAmount) {
        // Simplified calculation - TODO: implement based on RuleJSON
        if (promo.ProgramType__c == 'Volume') {
            return grossAmount * 0.05; // 5% discount
        } else if (promo.ProgramType__c == 'Visibility') {
            return grossAmount * 0.10; // 10% discount
        }
        return 0;
    }
}
