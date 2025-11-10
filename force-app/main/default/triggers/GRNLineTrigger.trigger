/**
 * @description Trigger handler for GRNLine__c
 * Creates BatchLot__c if not provided
 */
trigger GRNLineTrigger on GRNLine__c (after insert) {
    GRNLineTriggerHandler handler = new GRNLineTriggerHandler();
    
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.new);
    }
}
