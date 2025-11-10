/**
 * @description Evaluates promotion eligibility rules from JSON configuration
 *              Supports volume slabs, bundles, buy-X-get-Y schemes
 * @group Pricing
 */
public with sharing class SchemeEligibility {
    
    /**
     * @description Evaluate a promotion rule against an order
     */
    public static AppliedPromotion__c evaluateRule(
        SecondaryOrder__c order,
        List<SecondaryOrderLine__c> lines,
        Promotion__c promo,
        PromoEligibilityRule__c rule
    ) {
        if (String.isBlank(rule.RuleJSON__c)) {
            return null;
        }
        
        try {
            Map<String, Object> ruleData = (Map<String, Object>) JSON.deserializeUntyped(rule.RuleJSON__c);
            String ruleType = (String) ruleData.get('type');
            
            if (ruleType == 'volume') {
                return evaluateVolumeRule(order, lines, promo, rule, ruleData);
            } else if (ruleType == 'bundle') {
                return evaluateBundleRule(order, lines, promo, rule, ruleData);
            } else if (ruleType == 'buyXgetY') {
                return evaluateBuyXGetYRule(order, lines, promo, rule, ruleData);
            }
            
            return null;
        } catch (Exception e) {
            Util.logError('SchemeEligibility', e);
            return null;
        }
    }
    
    /**
     * @description Evaluate volume-based discount rule
     */
    @TestVisible
    private static AppliedPromotion__c evaluateVolumeRule(
        SecondaryOrder__c order,
        List<SecondaryOrderLine__c> lines,
        Promotion__c promo,
        PromoEligibilityRule__c rule,
        Map<String, Object> ruleData
    ) {
        Decimal minQty = (Decimal) ruleData.get('minQty');
        Decimal discountPct = (Decimal) ruleData.get('discountPct');
        
        Decimal totalQty = 0;
        Decimal totalValue = 0;
        
        for (SecondaryOrderLine__c line : lines) {
            totalQty += line.QtyBase__c;
            totalValue += line.NetLineAmount__c != null ? line.NetLineAmount__c : 0;
        }
        
        if (totalQty >= minQty) {
            AppliedPromotion__c applied = new AppliedPromotion__c(
                SecondaryOrder__c = order.Id,
                Promotion__c = promo.Id,
                Value__c = totalValue * (discountPct / 100),
                Basis__c = 'Volume: ' + totalQty + ' units >= ' + minQty,
                ProofRef__c = rule.Id
            );
            return applied;
        }
        
        return null;
    }
    
    /**
     * @description Evaluate bundle discount rule
     */
    @TestVisible
    private static AppliedPromotion__c evaluateBundleRule(
        SecondaryOrder__c order,
        List<SecondaryOrderLine__c> lines,
        Promotion__c promo,
        PromoEligibilityRule__c rule,
        Map<String, Object> ruleData
    ) {
        // TODO: Implement bundle logic - check if required SKUs are present
        return null;
    }
    
    /**
     * @description Evaluate buy-X-get-Y rule
     */
    @TestVisible
    private static AppliedPromotion__c evaluateBuyXGetYRule(
        SecondaryOrder__c order,
        List<SecondaryOrderLine__c> lines,
        Promotion__c promo,
        PromoEligibilityRule__c rule,
        Map<String, Object> ruleData
    ) {
        // TODO: Implement buy-X-get-Y logic
        return null;
    }
}
