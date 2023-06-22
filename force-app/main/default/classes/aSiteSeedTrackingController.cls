global without sharing class aSiteSeedTrackingController {
        
    private String token;
    private String type;
    private SiteUser__c logUser;
    private SiteUserSession__c activeSession;
    private Account activeAccount;
         
    public String language {get;set;}
    public String titulo {get;set;}
    public String subtitulo {get;set;}
     
    public Seed_Tracking__c[] relatedItems {get; set;}
               
    public string varietyFilter{get;set;}
    public string statusFilter{get;set;}
    public string seedTypeFilter{get;set;}
        
    global aSiteSeedTrackingController () {
        try{
            language = [select id, LanguageLocaleKey from User where id =: UserInfo.getUserId()].LanguageLocaleKey;
            titulo = 'Seed Order Tracker';                                                
        }
        catch(Exception e){
        }
    }
    
    public PageReference validate() {        
        token = System.currentPageReference().getParameters().get('token');
        if(token!=null){
            logUser = aSiteAuthManager.VerifyUserSession(token);
            if(logUser!=null){
                activeSession = aSiteAuthManager.getUserSession(token);
                activeAccount = aSiteAuthManager.getActiveAccount_byUser(logUser);   
                searchSeedTracking();                                 
                return null;                 
            }          
        }
                
        PageReference p = new PageReference('/apex/aSiteLogin');
        p.setRedirect(true);
        return p;

    }        
    
    public List<SelectOption> getOptionVariety(){       
       List<SelectOption> lista = new List<SelectOption>();
       Set<String> opciones = aSeedTrackingManager.getVarietiesSeedTracking(activeAccount.Id); 
       lista.add(new SelectOption('','All'));       
       if (opciones != null){
           for (String i : opciones){               
                lista.add(new SelectOption(i,i));
            }
       }       
       return lista;
    }
    
    public List<SelectOption> getOptionStatus(){       
       List<SelectOption> lista = new List<SelectOption>();
       Set<String> opciones = aSeedTrackingManager.getStatusSeedTracking(activeAccount.Id); 
       lista.add(new SelectOption('','All'));       
       if (opciones != null){
           for (String i : opciones){               
                lista.add(new SelectOption(i,i));
            }
       }       
       return lista;
    }
    
    public List<SelectOption> getOptionSeedType(){       
       List<SelectOption> lista = new List<SelectOption>();
       Set<String> opciones = aSeedTrackingManager.getSeedTypeSeedTracking(activeAccount.Id); 
       lista.add(new SelectOption('','All'));       
       if (opciones != null){
           for (String i : opciones){               
                lista.add(new SelectOption(i,i));
            }
       }       
       return lista;
    }
                                
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Seed_Tracking__c.FieldSets.Seed_Tracking.getFields();        
    }
            
    public void searchSeedTracking(){
        try{
            relatedItems = new List<Seed_Tracking__c>();
            relatedItems = aSeedTrackingManager.getItemsSeedTracking(activeAccount.Id, varietyFilter, statusFilter, seedTypeFilter);                                    
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,e.getMessage()));
        }        
    }                      
    
    public SiteUser__c getUser(){
        return logUser;
    }
    public Account getAccount(){
        return activeAccount;
    }
}