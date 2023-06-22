public class aSeedTrackingManager{
    
    public aSeedTrackingManager(){}        
    
    public static Set<String> getVarietiesSeedTracking(Id accId){
        try{
            List<Seed_Tracking__c> tmpOppItems = new List<Seed_Tracking__c>();
            Set<String> variedades = new Set<String>();
                                 
            tmpOppItems = aSiteUtils.queryResults1(Seed_Tracking__c.SObjectType, null, 'Account__c = :v1', accId);
            for(Seed_Tracking__c s : tmpOppItems){
                if (s.Brand__c != null && s.Brand__c != '')
                    variedades.add(s.Brand__c);                
            }
            return variedades;
        }
        catch(Exception e){
            return null;
        }
    }
    
    public static Set<String> getStatusSeedTracking(Id accId){
        try{
            List<Seed_Tracking__c> tmpOppItems = new List<Seed_Tracking__c>();
            Set<String> status = new Set<String>();
                                 
            tmpOppItems = aSiteUtils.queryResults1(Seed_Tracking__c.SObjectType, null, 'Account__c = :v1', accId);
            for(Seed_Tracking__c s : tmpOppItems){
                if (s.Status__c != null && s.Status__c != '')
                    status.add(s.Status__c);                
            }
            return status;
        }
        catch(Exception e){
            return null;
        }
    }
    
    public static Set<String> getSeedTypeSeedTracking(Id accId){
        try{
            List<Seed_Tracking__c> tmpOppItems = new List<Seed_Tracking__c>();
            Set<String> types = new Set<String>();
                                 
            tmpOppItems = aSiteUtils.queryResults1(Seed_Tracking__c.SObjectType, null, 'Account__c = :v1', accId);
            for(Seed_Tracking__c s : tmpOppItems){
                if (s.Type__c != null && s.Type__c != '')
                    types.add(s.Type__c);                
            }
            return types;
        }
        catch(Exception e){
            return null;
        }
    }
    
    public static List<Seed_Tracking__c> getItemsSeedTracking(Id accId, String variety, String status, String seedType){
        try{
        
            String query = 'Select ' + string.join(new list<string>(Seed_Tracking__c.SObjectType.getdescribe().fields.getmap().keyset()),',');
            query += ' From Seed_Tracking__c Where Account__c = \'' + accId + '\'';
            if (variety != '' && variety != null)
                query += ' And Brand__c = \'' + variety + '\'';
            if (status != '' && status != null)
                query += ' And Status__c = \'' + status + '\'';
            if (seedType!= '' && seedType!= null)
                query += ' And Type__c = \'' + seedType + '\'';
                               
            return Database.query(query);                                
            
        }
        catch(Exception e){
            return null;
        }
    }
    
}