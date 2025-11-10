/**
 * @description Rule evaluation from PromoEligibilityRule__c.RuleJSON__c (slabs, bundles, buyX-getY)
 * @author RCG Team
 * @date 2024
 */
public with sharing class SchemeEligibility {
    
    /**
     * @description Evaluates eligibility for a promotion
     * @param ruleJSON Rule JSON string
     * @param order Order context
     * @param lines Order lines
     * @return Eligibility result
     */
    public static EligibilityResult evaluate(String ruleJSON, SecondaryOrder__c order, List<SecondaryOrderLine__c> lines) {
        EligibilityResult result = new EligibilityResult();
        result.eligible = false;
        result.discountAmount = 0;
        result.explanation = '';
        
        if (String.isBlank(ruleJSON)) {
            return result;
        }
        
        try {
            RuleDefinition rule = (RuleDefinition) JSON.deserialize(ruleJSON, RuleDefinition.class);
            
            // Evaluate based on rule type
            if (rule.type == 'SLAB') {
                result = evaluateSlab(rule, order, lines);
            } else if (rule.type == 'BUNDLE') {
                result = evaluateBundle(rule, order, lines);
            } else if (rule.type == 'BUYXGETY') {
                result = evaluateBuyXGetY(rule, order, lines);
            }
            
        } catch (Exception e) {
            result.eligible = false;
            result.explanation = 'Error evaluating rule: ' + e.getMessage();
            Util.logError('SchemeEligibility', 'evaluate', e);
        }
        
        return result;
    }
    
    /**
     * @description Evaluates slab-based rule
     * @param rule Rule definition
     * @param order Order
     * @param lines Order lines
     * @return Eligibility result
     */
    private static EligibilityResult evaluateSlab(RuleDefinition rule, SecondaryOrder__c order, List<SecondaryOrderLine__c> lines) {
        EligibilityResult result = new EligibilityResult();
        result.eligible = false;
        
        Decimal totalAmount = order.NetAmount__c != null ? order.NetAmount__c : 0;
        
        // Check if total amount falls in any slab
        for (Slab slab : rule.slabs) {
            if (totalAmount >= slab.min && (slab.max == null || totalAmount <= slab.max)) {
                result.eligible = true;
                result.discountAmount = calculateDiscount(totalAmount, slab.discountType, slab.discountValue);
                result.explanation = String.format('Order total {0} qualifies for {1}% discount', 
                    new String[]{ String.valueOf(totalAmount), String.valueOf(slab.discountValue) });
                break;
            }
        }
        
        return result;
    }
    
    /**
     * @description Evaluates bundle-based rule
     * @param rule Rule definition
     * @param order Order
     * @param lines Order lines
     * @return Eligibility result
     */
    private static EligibilityResult evaluateBundle(RuleDefinition rule, SecondaryOrder__c order, List<SecondaryOrderLine__c> lines) {
        EligibilityResult result = new EligibilityResult();
        result.eligible = false;
        
        // Check if required products are in order
        Set<Id> productIds = new Set<Id>();
        for (SecondaryOrderLine__c line : lines) {
            productIds.add(line.Product__c);
        }
        
        Boolean allProductsPresent = true;
        for (String requiredProductId : rule.requiredProducts) {
            if (!productIds.contains(Id.valueOf(requiredProductId))) {
                allProductsPresent = false;
                break;
            }
        }
        
        if (allProductsPresent) {
            result.eligible = true;
            result.discountAmount = rule.discountAmount;
            result.explanation = 'Bundle discount applied';
        }
        
        return result;
    }
    
    /**
     * @description Evaluates buy-X-get-Y rule
     * @param rule Rule definition
     * @param order Order
     * @param lines Order lines
     * @return Eligibility result
     */
    private static EligibilityResult evaluateBuyXGetY(RuleDefinition rule, SecondaryOrder__c order, List<SecondaryOrderLine__c> lines) {
        EligibilityResult result = new EligibilityResult();
        result.eligible = false;
        
        // Find qualifying product line
        for (SecondaryOrderLine__c line : lines) {
            if (line.Product__c == Id.valueOf(rule.qualifyingProductId)) {
                Decimal qty = line.QtyBase__c != null ? line.QtyBase__c : 0;
                if (qty >= rule.buyQuantity) {
                    result.eligible = true;
                    result.discountAmount = (qty / rule.buyQuantity).intValue() * rule.getQuantity * line.UnitPrice__c;
                    result.explanation = String.format('Buy {0} get {1} free', 
                        new String[]{ String.valueOf(rule.buyQuantity), String.valueOf(rule.getQuantity) });
                    break;
                }
            }
        }
        
        return result;
    }
    
    /**
     * @description Calculates discount amount
     * @param amount Base amount
     * @param discountType Discount type (PERCENTAGE or FIXED)
     * @param discountValue Discount value
     * @return Discount amount
     */
    private static Decimal calculateDiscount(Decimal amount, String discountType, Decimal discountValue) {
        if (discountType == 'PERCENTAGE') {
            return amount * (discountValue / 100);
        } else {
            return discountValue;
        }
    }
    
    /**
     * @description Rule definition wrapper
     */
    public class RuleDefinition {
        public String type;
        public List<Slab> slabs;
        public List<String> requiredProducts;
        public Decimal discountAmount;
        public String qualifyingProductId;
        public Decimal buyQuantity;
        public Decimal getQuantity;
    }
    
    /**
     * @description Slab definition
     */
    public class Slab {
        public Decimal min;
        public Decimal max;
        public String discountType;
        public Decimal discountValue;
    }
    
    /**
     * @description Eligibility result
     */
    public class EligibilityResult {
        public Boolean eligible;
        public Decimal discountAmount;
        public String explanation;
    }
}
