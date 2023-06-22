global class sapCreditStatus_caller {
    webservice static string consultarOpps(){                

        List<Opportunity> regOpps = [SELECT Id, StageName, Nro_Pedido_SAP__c, Name FROM Opportunity where Stagename = 'Locked by Credit'];
        for(Opportunity opp : regOpps)
            CreditStatusCheck(opp.Id, opp.Nro_Pedido_SAP__c);
        return 'Termino';
    }
    
    @future(callout=true)
    webservice static void CreditStatusCheck(Id oppId, String arg_sap){
    
        SAPEndpoint__c endpoint = SAPEndpoint__c.getOrgDefaults();        
        try{
            String result;
            System.debug('JERE:::'+arg_sap);
        
            sapStatusCreditIS.Z_SD_STATUS_CREDITO soap = new sapStatusCreditIS.Z_SD_STATUS_CREDITO();
        
            soap.inputHttpHeaders_x = new Map<String, String>();
            String encodedusernameandpassword;

            String myData = endpoint.Username__c + ':' + endpoint.Password__c;
            Blob hash = Blob.valueOf(myData);
            encodedusernameandpassword = EncodingUtil.base64Encode(hash);
            
            soap.timeout_x = 110000;
            soap.inputHttpHeaders_x.put('Authorization', 'Basic '+ encodedusernameandpassword);
            
            result = soap.ZSdStatusCredito(arg_sap);
            if (result != null){
                if(result == 'A' || result == 'D'){
                    System.debug('JERE:::Result:'+result);
                    Opportunity o = new Opportunity(Id=oppId,StageName='Approved');
                    update o;
                }
            }
            
        }
        catch(Exception e){                   
        }        
    }
}