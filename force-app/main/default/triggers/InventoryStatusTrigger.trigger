trigger InventoryStatusTrigger on Inventory_Status__c (before insert) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            Set<Id> oppLiIds = new Set<Id>();
            for(Inventory_Status__c is : Trigger.new) {
                oppLiIds.add(is.Opportunity_Product__c);
                is.Lastest_Status__c = true;
            }
            List<Inventory_Status__c> oldStatus = [SELECT Id FROM Inventory_Status__c WHERE Opportunity_Product__c IN :oppLiIds AND Lastest_Status__c = true];
            for(Inventory_Status__c oldIS : oldStatus) {
                oldIS.Lastest_Status__c = false;
            }
            update oldStatus;
        }
    }
}