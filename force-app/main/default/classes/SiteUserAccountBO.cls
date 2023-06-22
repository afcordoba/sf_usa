public class SiteUserAccountBO {

    private static final SiteUserAccountBO instance = new SiteUserAccountBO();    
    private SiteUserAccountBO(){}
    
    public static SiteUserAccountBO getInstance() {
        return instance;
    }

    /*
    public void executeProcessingUser( List<SiteUserAccount__c> objToProcessing ) {
        List<Id> userIds = new List<Id>();
        List<SiteUser__c> users = new List<SiteUser__c>();
        
        Map<String,SiteUser__c > mapOppItem = new Map<String,SiteUser__c >();
        
        for( SiteUserAccount__c obj : objToProcessing ) {            
            userIds.add(obj.SiteUser__c);            
        }
        for(SiteUser__c su : [Select Id From SiteUser__c where Id in:userIds]){
            mapOppItem.put(su.Id, su);
        }
        
        for(SiteUserAccount__c s : objToProcessing){        
            if(mapOppItem.containsKey(s.SiteUser__c)){    
                mapOppItem.get(s.SiteUser__c).Account__c = s.Account__c;
            }
        }
                    
        update mapOppItem.values();
    } */
         
}