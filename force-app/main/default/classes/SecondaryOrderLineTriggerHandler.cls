/**
 * @description Handler for SecondaryOrderLine__c trigger
 */
public with sharing class SecondaryOrderLineTriggerHandler {
    
    public void beforeInsert(List<SecondaryOrderLine__c> newLines) {
        normalizeQuantities(newLines);
    }
    
    public void beforeUpdate(List<SecondaryOrderLine__c> newLines, Map<Id, SecondaryOrderLine__c> oldMap) {
        normalizeQuantities(newLines);
    }
    
    private void normalizeQuantities(List<SecondaryOrderLine__c> lines) {
        for (SecondaryOrderLine__c line : lines) {
            // Normalize QtyBase from QtyDisplay if needed
            if (String.isNotBlank(line.QtyDisplay__c) && line.QtyBase__c == null) {
                try {
                    line.QtyBase__c = Decimal.valueOf(line.QtyDisplay__c);
                } catch (Exception e) {
                    line.addError('Invalid quantity format: ' + line.QtyDisplay__c);
                }
            }
            
            // Ensure QtyBase is set
            if (line.QtyBase__c == null) {
                line.QtyBase__c = 0;
            }
            
            // Normalize UoM if not set
            if (String.isBlank(line.UoM__c)) {
                line.UoM__c = 'EA';
            }
        }
    }
}
