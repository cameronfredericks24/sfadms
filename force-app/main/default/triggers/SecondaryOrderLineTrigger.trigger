/**
 * @description Trigger handler for SecondaryOrderLine__c
 * Normalizes Qty/UoM before insert/update
 */
trigger SecondaryOrderLineTrigger on SecondaryOrderLine__c (before insert, before update) {
    SecondaryOrderLineTriggerHandler handler = new SecondaryOrderLineTriggerHandler();
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
