/**
 * @description Pricing Engine - handles price resolution, UoM conversion, tax calculation,
 *              and promotional scheme application with stackability rules
 * @group Pricing
 */
global with sharing class PricingEngine {
    
    /**
     * @description Input wrapper for pricing calculation
     */
    global class PricingInput {
        @InvocableVariable(required=true)
        global Id orderId;
        
        @InvocableVariable(required=false)
        global Boolean recalculateAll;
    }
    
    /**
     * @description Output wrapper for pricing calculation results
     */
    global class PricingOutput {
        @InvocableVariable
        global Decimal grossAmount;
        
        @InvocableVariable
        global Decimal netAmount;
        
        @InvocableVariable
        global Decimal taxAmount;
        
        @InvocableVariable
        global Decimal totalDiscount;
        
        @InvocableVariable
        global String appliedPromosJSON;
        
        @InvocableVariable
        global Boolean success;
        
        @InvocableVariable
        global String message;
    }
    
    /**
     * @description Invocable method for Flow integration
     */
    @InvocableMethod(label='Apply Pricing Engine' description='Calculates prices, taxes, and applies promotional schemes' category='Pricing')
    global static List<PricingOutput> applyPricing(List<PricingInput> inputs) {
        List<PricingOutput> outputs = new List<PricingOutput>();
        
        for (PricingInput input : inputs) {
            try {
                PricingOutput output = calculateOrderPricing(input.orderId);
                output.success = true;
                outputs.add(output);
            } catch (Exception e) {
                PricingOutput output = new PricingOutput();
                output.success = false;
                output.message = 'Error: ' + e.getMessage();
                outputs.add(output);
                Util.logError('PricingEngine', e);
            }
        }
        
        return outputs;
    }
    
    /**
     * @description Calculate pricing for an order
     */
    private static PricingOutput calculateOrderPricing(Id orderId) {
        // Query order and lines
        SecondaryOrder__c order = [
            SELECT Id, Retailer__c, Distributor__c, GrossAmount__c, NetAmount__c, TaxAmount__c
            FROM SecondaryOrder__c 
            WHERE Id = :orderId
        ];
        
        List<SecondaryOrderLine__c> lines = [
            SELECT Id, Product__c, QtyBase__c, UnitPrice__c, NetLineAmount__c,
                   Product__r.Name, Product__r.Family
            FROM SecondaryOrderLine__c
            WHERE SecondaryOrder__c = :orderId
        ];
        
        if (lines.isEmpty()) {
            throw new PricingException('No order lines found');
        }
        
        // Calculate line prices
        Decimal grossTotal = 0;
        for (SecondaryOrderLine__c line : lines) {
            Decimal linePrice = calculateLinePrice(line, order);
            line.UnitPrice__c = linePrice;
            line.NetLineAmount__c = linePrice * line.QtyBase__c;
            grossTotal += line.NetLineAmount__c;
        }
        
        // Apply promotions
        List<AppliedPromotion__c> appliedPromos = applyPromotions(order, lines);
        
        Decimal totalDiscount = 0;
        for (AppliedPromotion__c promo : appliedPromos) {
            totalDiscount += promo.Value__c != null ? promo.Value__c : 0;
        }
        
        Decimal netTotal = grossTotal - totalDiscount;
        Decimal taxTotal = calculateTax(netTotal, order);
        
        // Update order
        order.GrossAmount__c = grossTotal;
        order.NetAmount__c = netTotal;
        order.TaxAmount__c = taxTotal;
        order.AppliedPromosJSON__c = JSON.serialize(appliedPromos);
        
        update order;
        update lines;
        
        if (!appliedPromos.isEmpty()) {
            insert appliedPromos;
        }
        
        // Build output
        PricingOutput output = new PricingOutput();
        output.grossAmount = grossTotal;
        output.netAmount = netTotal;
        output.taxAmount = taxTotal;
        output.totalDiscount = totalDiscount;
        output.appliedPromosJSON = JSON.serialize(appliedPromos);
        
        return output;
    }
    
    /**
     * @description Calculate unit price for a line item
     */
    @TestVisible
    private static Decimal calculateLinePrice(SecondaryOrderLine__c line, SecondaryOrder__c order) {
        // In real implementation, this would query pricebook entries based on distributor
        // For now, return a simple calculation
        // TODO: Implement pricebook resolution logic
        return 10.00; // Placeholder price
    }
    
    /**
     * @description Apply promotional schemes with stackability rules
     */
    @TestVisible
    private static List<AppliedPromotion__c> applyPromotions(SecondaryOrder__c order, List<SecondaryOrderLine__c> lines) {
        List<AppliedPromotion__c> appliedPromos = new List<AppliedPromotion__c>();
        
        // Query active promotions
        List<Promotion__c> activePromos = [
            SELECT Id, Name, ProgramType__c, TargetBrands__c, TargetSkusJSON__c,
                   (SELECT Id, RuleJSON__c, Stackable__c, Priority__c 
                    FROM Promo_Eligibility_Rules__r 
                    ORDER BY Priority__c ASC)
            FROM Promotion__c
            WHERE Active__c = true
              AND StartDate__c <= TODAY
              AND EndDate__c >= TODAY
        ];
        
        // Evaluate each promotion
        for (Promotion__c promo : activePromos) {
            for (PromoEligibilityRule__c rule : promo.Promo_Eligibility_Rules__r) {
                AppliedPromotion__c applied = SchemeEligibility.evaluateRule(order, lines, promo, rule);
                if (applied != null) {
                    appliedPromos.add(applied);
                    if (!rule.Stackable__c) {
                        break; // Stop if not stackable
                    }
                }
            }
        }
        
        return appliedPromos;
    }
    
    /**
     * @description Calculate tax for an order
     */
    @TestVisible
    private static Decimal calculateTax(Decimal netAmount, SecondaryOrder__c order) {
        // Simple tax calculation - 10% GST
        // TODO: Implement proper tax resolution based on distributor/retailer location
        return netAmount * 0.10;
    }
    
    /**
     * @description Custom exception for pricing errors
     */
    public class PricingException extends Exception {}
}
