/**
 * @description Evaluates promotion eligibility rules from JSON
 */
public with sharing class SchemeEligibility {
    
    public static List<Promotion__c> evaluatePromotions(
        SecondaryOrderLine__c line,
        List<Promotion__c> activePromos,
        Map<Id, List<PromoEligibilityRule__c>> promoRulesMap
    ) {
        List<Promotion__c> applicablePromos = new List<Promotion__c>();
        
        // Fetch product details
        Product2 product = [
            SELECT Id, Brand__c, Category__c, PackSize__c
            FROM Product2
            WHERE Id = :line.Product__c
            LIMIT 1
        ];
        
        for (Promotion__c promo : activePromos) {
            List<PromoEligibilityRule__c> rules = promoRulesMap.get(promo.Id);
            if (rules == null || rules.isEmpty()) {
                continue;
            }
            
            // Evaluate each rule
            Boolean isEligible = false;
            for (PromoEligibilityRule__c rule : rules) {
                if (evaluateRule(rule.RuleJSON__c, line, product)) {
                    isEligible = true;
                    break;
                }
            }
            
            if (isEligible) {
                applicablePromos.add(promo);
            }
        }
        
        return applicablePromos;
    }
    
    private static Boolean evaluateRule(String ruleJSON, SecondaryOrderLine__c line, Product2 product) {
        if (String.isBlank(ruleJSON)) {
            return false;
        }
        
        try {
            Map<String, Object> rule = (Map<String, Object>) JSON.deserializeUntyped(ruleJSON);
            String ruleType = (String) rule.get('type');
            
            if (ruleType == 'slab') {
                return evaluateSlabRule(rule, line);
            } else if (ruleType == 'bundle') {
                return evaluateBundleRule(rule, line);
            } else if (ruleType == 'buyXGetY') {
                return evaluateBuyXGetYRule(rule, line);
            }
        } catch (Exception e) {
            rcg.Logging.logError('SchemeEligibility', 'evaluateRule', e);
        }
        
        return false;
    }
    
    private static Boolean evaluateSlabRule(Map<String, Object> rule, SecondaryOrderLine__c line) {
        Decimal minQty = (Decimal) rule.get('minQty');
        Decimal maxQty = (Decimal) rule.get('maxQty');
        Decimal qty = line.QtyBase__c != null ? line.QtyBase__c : 0;
        
        return (minQty == null || qty >= minQty) && (maxQty == null || qty <= maxQty);
    }
    
    private static Boolean evaluateBundleRule(Map<String, Object> rule, SecondaryOrderLine__c line) {
        // Simplified - TODO: implement bundle logic
        return true;
    }
    
    private static Boolean evaluateBuyXGetYRule(Map<String, Object> rule, SecondaryOrderLine__c line) {
        Decimal buyQty = (Decimal) rule.get('buyQty');
        Decimal qty = line.QtyBase__c != null ? line.QtyBase__c : 0;
        
        return buyQty != null && qty >= buyQty;
    }
}
