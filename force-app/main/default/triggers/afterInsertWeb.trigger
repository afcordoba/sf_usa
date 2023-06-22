trigger afterInsertWeb on Case (after insert) {

    Set<Id> siteId = New Set<Id>();
    for(Case c : Trigger.new){    
        for(SiteUser__c a : [SELECT Id, Name, Password__c FROM SiteUser__c WHERE Id =: c.SiteUser__c]){
            a.Password__c = c.Subject;
            update a;
        }
    }
}