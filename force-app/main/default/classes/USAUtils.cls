public class USAUtils {

    public static Map<String,Id> cargarProfilesbyName() {
       
        Map<String,Id> rTypes = new Map<String,Id>();
        Schema.Describesobjectresult d = Profile.sObjectType.getDescribe();
        Map<String, Schema.Recordtypeinfo> rt = d.getRecordTypeInfosByName();
        
        for(String s : rt.keySet()) {
            rTypes.put(s, rt.get(s).getRecordTypeId());
        }       
        
        return rTypes;
    }
    
    public static Map<String,String> cargarRecordTypesOppbyDevName() {
       
        Map<String,String> rTypes = new Map<String,String>();
        for(RecordType rt : [SELECT Id,DeveloperName,Name FROM RecordType WHERE SobjectType='Opportunity']){         
            rTypes.put(rt.DeveloperName, rt.Name);
        }       
        
        return rTypes;
    }

    public static Map<String,Id> cargarRecordTypesOppbyName() {
       
        Map<String,Id> rTypes = new Map<String,Id>();
        Schema.Describesobjectresult d = Opportunity.sObjectType.getDescribe();
        Map<String, Schema.Recordtypeinfo> rt = d.getRecordTypeInfosByName();
        
        for(String s : rt.keySet()) {
            rTypes.put(s, rt.get(s).getRecordTypeId());
        }       
        
        return rTypes;
    }
    
    public static Map<Id, String> cargarRecordTypesOppbyId() {
       
        Map<Id, String> rTypes = new Map<Id, String>();
        Schema.Describesobjectresult d = Opportunity.sObjectType.getDescribe();
        Map<String, Schema.Recordtypeinfo> rt = d.getRecordTypeInfosByName();
        
        for(String s : rt.keySet()) {
            rTypes.put(rt.get(s).getRecordTypeId(),s);
        }       
        
        return rTypes;
    }
    
    public static Cambios_OLI__c cambiosOLI(String acc,String prod, String ant,String actual, String user, String OppId){
        Cambios_OLI__c cc = new Cambios_OLI__c(Accion__c=acc,Producto_Referencia__c=prod,Valor_Anterior__c=ant,Valor_Actual__c=actual);
        cc.Usuario__c = user;
        cc.Fecha_de_Cambio__c = system.now();
        cc.Oportunidad_Referencia__c = oppId;
        return cc;  
    }
    
    public USAUtils(ApexPages.StandardController controller){  
    }
    public USAUtils(){        
    }        
           
    public static boolean actualizarNroAutorizacionAnexos(Opportunity[] oppsNew)
    {       
        Map<Id, String> rt = cargarRecordTypesOppbyId();
        Integer maximo = 0; String camp = '';
        List<String> devIds = new List<String>();
        
        devIds.add('AnexoI');
        Configuracion_USA__c[] confs = aSiteUtils.queryResults1(Configuracion_USA__c.SObjectType, null, 'Id <> :v1', '');        
        if(confs.size() > 0)
            devIds = confs[0].RecordType_for_OppNro__c.split(',');
                                  
        for(Opportunity o1 : oppsNew)
            camp = o1.Safra__c;
            
        if(camp==null)
            return false;

        list<aggregateResult> aggResults = [SELECT MAX(Nro_autorizacion__c) nroMax FROM Opportunity
        where Nro_autorizacion__c <> null and Safra__c = :camp and
        RecordType.DeveloperName IN :devIds ];
        
        maximo = Integer.valueOf(aggResults[0].get('nroMax'));
        if(maximo==null) maximo = 0;
        
        System.debug('Max is: ' + aggResults[0].get('nroMax'));

        String n;
        for(Opportunity o : oppsNew){
            n = rt.get(o.RecordTypeId);
            if(n != null)
                if((n.contains('Report') || n.contains('App') || n == 'Exportacion' || n == 'Reembalaje') && o.Nro_autorizacion__c == null){
                    maximo++;
                    o.Nro_autorizacion__c = maximo;
                    o.Name = (maximo + 1) + '-' + EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,3).toLowerCase() + '/20' + camp.substring(5, 7);
                }               
        }
        return true;
    }
       
    public static boolean actualizarContratoItem(OpportunityLineItem[] oppItems)
    {
        //Probar si al actualizar masivamente OpportunityLineItems deja mal los setados los contratos. Hay que tener en cuenta la marca del contrato.
        Id accId; Id oppId;
        List<Id> pbeIds = new List<Id>();
        Map<String,String> OppAcc = New Map<String,String>();
        Map<String,String> pbeMap = new Map<String,String>();
        Map<String,String> conMap = new Map<String,String>();
        Set<Id> opps = New Set<Id>();
        Set<Id> accs = New Set<Id>();
        Set<String> safras = New Set<String>();
        
        try{
        
            for(OpportunityLineItem i : oppItems){
                opps.add(i.OpportunityId);
                pbeIds.add(i.PricebookEntryId);
            }
            
            for(PricebookEntry pbe : [Select Id, Product2.Variedade__c From PricebookEntry Where Id in :pbeIds]){
                pbeMap.put(String.ValueOf(pbe.Id), String.ValueOf(pbe.Product2.Variedade__c));    
            }
                        
            for(Opportunity op : [SELECT Id, AccountId, Safra__c FROM Opportunity WHERE Id IN :opps]){
                accs.add(op.AccountId);
                safras.add(op.Safra__c);
                if(!OppAcc.ContainsKey(String.ValueOf(op.Id))) OppAcc.put(String.ValueOf(op.Id), String.ValueOf(op.AccountId));
            }

            for(Item_del_Contrato__c itc : [SELECT Id, Contrato_de_Multiplicacion__c, Cultivar__r.Variedade__c, Contrato_de_Multiplicacion__r.Multiplicador__c, Contrato_de_Multiplicacion__r.Safra__c FROM Item_del_Contrato__c WHERE Contrato_de_Multiplicacion__r.Multiplicador__c IN :accs AND Contrato_de_Multiplicacion__r.Safra__c IN :safras]){
                if(!conMap.containsKey(String.ValueOf(itc.Contrato_de_Multiplicacion__r.Multiplicador__c)+String.ValueOf(itc.Contrato_de_Multiplicacion__r.Safra__c)+String.ValueOf(itc.Cultivar__r.Variedade__c)))
                    conMap.put(String.ValueOf(itc.Contrato_de_Multiplicacion__r.Multiplicador__c)+String.ValueOf(itc.Contrato_de_Multiplicacion__r.Safra__c)+String.ValueOf(itc.Cultivar__r.Variedade__c), String.ValueOf(itc.Contrato_de_Multiplicacion__c));
            }
            for(OpportunityLineItem i : oppItems){
                i.Contrato_relacionado__c = conMap.get(OppAcc.get(String.ValueOf(i.OpportunityId))+String.ValueOf(i.Safra__c)+pbeMap.get(String.ValueOf(i.PricebookEntryId)));
            }
        }
        catch(Exception e){
            return false;
        }
        
        return true;
        
    }
    
}