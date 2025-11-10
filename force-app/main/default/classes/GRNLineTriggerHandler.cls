/**
 * @description Handler for GRNLine__c trigger
 */
public with sharing class GRNLineTriggerHandler {
    
    public void afterInsert(List<GRNLine__c> newLines) {
        List<BatchLot__c> lotsToCreate = new List<BatchLot__c>();
        
        // Fetch GRN details
        Set<Id> grnIds = new Set<Id>();
        for (GRNLine__c line : newLines) {
            grnIds.add(line.GRN__c);
        }
        
        Map<Id, GRN__c> grnMap = new Map<Id, GRN__c>([
            SELECT Id, PrimaryOrder__c
            FROM GRN__c
            WHERE Id IN :grnIds
        ]);
        
        for (GRNLine__c line : newLines) {
            // Create BatchLot if not provided and AcceptedQty > 0
            if (line.BatchLot__c == null && line.AcceptedQty__c != null && line.AcceptedQty__c > 0) {
                BatchLot__c lot = new BatchLot__c(
                    Product__c = line.Product__c,
                    LotNo__c = 'AUTO-' + String.valueOf(DateTime.now().getTime()) + '-' + line.Id,
                    QtyOnHand__c = line.AcceptedQty__c,
                    Status__c = 'Available'
                );
                lotsToCreate.add(lot);
            }
        }
        
        if (!lotsToCreate.isEmpty()) {
            insert lotsToCreate;
            
            // Update GRNLine__c with BatchLot__c
            List<GRNLine__c> linesToUpdate = new List<GRNLine__c>();
            Integer idx = 0;
            for (GRNLine__c line : newLines) {
                if (line.BatchLot__c == null && line.AcceptedQty__c != null && line.AcceptedQty__c > 0) {
                    GRNLine__c lineToUpdate = new GRNLine__c(Id = line.Id);
                    lineToUpdate.BatchLot__c = lotsToCreate[idx].Id;
                    linesToUpdate.add(lineToUpdate);
                    idx++;
                }
            }
            if (!linesToUpdate.isEmpty()) {
                update linesToUpdate;
            }
        }
    }
}
