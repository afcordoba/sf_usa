public class FlujoDocBO  {
    @Future(callout=true)
    public static void opportunityEnableValidation(String OpportunityId) {

        Opportunity actualOpportunity = [
            SELECT Id, Nro_Pedido_SAP__c, RecordTypeId, docRel__c, CreatedDate, StageName
            FROM Opportunity
            WHERE Id = :OpportunityId
        ];

        if(actualOpportunity.StageName != 'Approved' && actualOpportunity.StageName != 'Locked by Credit') {
            return;
        }

        Map<Id, OpportunityLineItem> olis = new Map<Id, OpportunityLineItem>([
            SELECT Id, DocRel__c, name
            FROM OpportunityLineItem
            WHERE OpportunityId = :OpportunityId
        ]);

        for(OpportunityLineItem oli : olis.values()){
            oli.DocRel__c = '';
        }
        
            Map<String, String> FKART = new Map<String, String>();
            List<String> docTypes = new List<String>();
            docTypes.add('O');
            docTypes.add('P');
            docTypes.add('M');
            docTypes.add('T');
            docTypes.add('J');
    
            flujoDocV3S4.ZSD_FLUJO_DOC_3 instance = new flujoDocV3S4.ZSD_FLUJO_DOC_3();
            flujoDocV3S4.TABLE_OF_ZSSD_FLUJO_DOC_V3 EFlujoDoc = new flujoDocV3S4.TABLE_OF_ZSSD_FLUJO_DOC_V3();
            
            List<flujoDocV3S4.ZSD_FLUJO_DOC_3Response_element> results = new List<flujoDocV3S4.ZSD_FLUJO_DOC_3Response_element>();
    
            if(!String.isBlank(actualOpportunity.Nro_Pedido_SAP__c))
            {
                string startingDate = formatStartingDate(actualOpportunity.CreatedDate.date());
                string endingDate = formatStartingDate(System.today().adddays(1));
                FOR(String val : docTypes) {
                    results.add(instance.ZSD_FLUJO_DOC_3(
                        EFlujoDoc, 
                        '', 
                        startingDate, 
                        endingDate, 
                        '', 
                        '', 
                        '',
                        '',
                        '',
                        actualOpportunity.Nro_Pedido_SAP__c,   
                        val));
                }
            }
    
            
            Map<Id, String> oliResults = new Map<Id, String>();
            OpportunityLineItem oliUnit;
            for(flujoDocV3S4.ZSD_FLUJO_DOC_3Response_element element : results) {
                if(element.E_FLUJO_DOC.item != null) {
                    for(flujoDocV3S4.ZSSD_FLUJO_DOC_V3 item : element.E_FLUJO_DOC.item) {
                        if(item.Zzpossf != null && item.Zzpossf != '') {
                            if(oliResults.containsKey(item.Zzpossf)) {
                                oliUnit = olis.get(item.Zzpossf);
                                oliUnit.DocRel__c += item.Fkart;
                                olis.put(oliUnit.Id, oliUnit);
                            }
                            else {
                                oliResults.put(item.Zzpossf, '');
                                oliUnit = olis.get(item.Zzpossf);
                                oliUnit.DocRel__c = item.Fkart;
                                olis.put(oliUnit.Id, oliUnit);
                            }
                        }
                    }
                }
            }
        
        string docRelItem = null;
        //Id saleRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sale - Locked').getRecordTypeId();
        for(OpportunityLineItem oli : olis.values()) {
            if(String.isNotBlank(oli.DocRel__c)) { 
                docRelItem = oli.docRel__c;
                break;
            }
            
        }
        Approval.unlock(actualOpportunity.Id);
        actualOpportunity.StageName = 'Editable';
        //actualOpportunity.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sale').getRecordTypeId();
        actualOpportunity.Status_Integracion__c = null;
        
        actualOpportunity.docRel__c = docRelItem;

        if(olis.size() > 0){
            update olis.values();
        }
        update actualOpportunity;
    }

    public static String formatStartingDate(Date value) {

        String auxMonth = String.valueOf(value.month());
        if(auxMonth.length() < 2) {
            auxMonth = '0' + auxMonth;
        }
        String auxDay = String.valueOf(value.day());
        if(auxDay.length() < 2) {
            auxDay = '0' + auxDay;
        }

        String result = value.year() + '-' + auxMonth + '-' + auxDay;
        return result;
    }
}