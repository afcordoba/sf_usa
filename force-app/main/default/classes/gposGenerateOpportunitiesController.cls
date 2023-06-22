public class gposGenerateOpportunitiesController {

    @AuraEnabled
    public static resultWrapper getSummaryText(String recordId) {
        
        List<GPOS_Grower_Temp__c> temps = getTemps(recordId);
        Set<String> tempsIds = new Set<String>();
        for(GPOS_Grower_Temp__c t : temps) {
            tempsIds.add(t.Id);
        }
        List<GPOS_Variety_Temp__c> varTemps = getVarietyTemps(tempsIds);

        String message = 'There are ' + temps.size() + ' temporary records with ' + varTemps.size() + ' varieties items.';
        resultWrapper result = new resultWrapper();
        result.message = message;
        if(temps.size() > 0)
            result.hasRecords = true;
        return result;
    }

    @AuraEnabled
    public static void generateOpps(String recordId){

        Dealer_Summary__c ds = [SELECT Id, Blocked__c FROM Dealer_Summary__c WHERE Id =: recordId];
        System.debug(ds.Blocked__c);
        if(ds.Blocked__c) {
            throw new AuraHandledException('This summary is blocked');
        }

        
            List<GPOS_Grower_Temp__c> temps = getTemps(recordId);
            Set<String> tempsIds = new Set<String>();
            for(GPOS_Grower_Temp__c t : temps) {
                tempsIds.add(t.Id);
            }
            List<GPOS_Variety_Temp__c> varTemps = getVarietyTemps(tempsIds);

            // Get Existing Data
            Map<String, List<GPOS_Variety_Temp__c>> varTempsMap = new Map<String, List<GPOS_Variety_Temp__c>>();
            List<GPOS_Variety_Temp__c> varTempList;
            Set<String> varieties = new Set<String>();
            for(GPOS_Variety_Temp__c varTemp : varTemps) {
                if(varTempsMap.containsKey(varTemp.GPOS_Variety_Consolidation__r.GPOS_Grower_Temp__c)) {
                    varTempList = varTempsMap.get(varTemp.GPOS_Variety_Consolidation__r.GPOS_Grower_Temp__c);
                    varTempList.add(varTemp);
                    varTempsMap.put(varTemp.GPOS_Variety_Consolidation__r.GPOS_Grower_Temp__c, varTempList);
                }
                else {
                    varTempList = new List<GPOS_Variety_Temp__c>();
                    varTempList.add(varTemp);
                    varTempsMap.put(varTemp.GPOS_Variety_Consolidation__r.GPOS_Grower_Temp__c, varTempList);
                }
                varieties.add(varTemp.GPOS_Variety_Consolidation__r.Variety__c);
            }
            Pricebook2 standardPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
            List<PricebookEntry> standardPbes = [SELECT Id, Product2.Variedade__c
                                                    FROM PricebookEntry 
                                                    WHERE Product2.Variedade__c IN :varieties 
                                                            AND Product2.Categ__r.Name = 'PARENTAL' 
                                                            AND Product2.UNIDADE__c = 'BAG 140K'
                                                            AND Pricebook2Id = :standardPb.Id
                                                            AND IsActive = true];
            Map<String, PricebookEntry> pbeByVariety = new Map<String, PricebookEntry>();
            for(PricebookEntry entry : standardPbes) {
                pbeByVariety.put(entry.Product2.Variedade__c, entry);
            }

            // Generate Opportunities
            
            Map<String, Opportunity> results = new Map<String, Opportunity>();
            RecordType gposRecordType = [Select Id From RecordType where sobjecttype = 'Opportunity' and name = 'GPOS Opportunity'];
            for(GPOS_Grower_Temp__c t : temps) {
                Opportunity newOpp = new Opportunity();
                newOpp.AccountId = t.Dealer_Summary__r.Client__c;
                newOpp.Grower__c = t.Grower__c;
                newOpp.Dealer__c = t.Dealer__c;
                newOpp.Pricebook2Id = standardPb.Id;
                newOpp.Dealer_Summary__c = recordId;
                newOpp.Name = t.Grower__r.Name + ' - ' + t.Dealer__r.Name + ' - ' + t.Dealer_Summary__r.Season__c;
                newOpp.StageName = 'Editable';
                newOpp.CloseDate = System.today();
                newOpp.RecordTypeId = gposRecordType.Id;
                results.put(t.Grower__c + '' + t.Dealer__c, newOpp);
            }
            insert results.values();

            // Generate Opportunity Line Items

            List<OpportunityLineItem> items = new List<OpportunityLineItem>();
            for(GPOS_Grower_Temp__c t : temps) {
                Opportunity opp = results.get(t.Grower__c + '' + t.Dealer__c);
                
                if(varTempsMap.containsKey(t.Id)) {
                    varTempList = varTempsMap.get(t.Id);
                    for(GPOS_Variety_Temp__c varTemp : varTempList) {
                        OpportunityLineItem item = new OpportunityLineItem();

                        if(!pbeByVariety.containsKey(varTemp.GPOS_Variety_Consolidation__r.Variety__c))
                            throw new AuraHandledException('The ' + varTemp.GPOS_Variety_Consolidation__r.Variety__r.Name + ' is missing a Standard Pricebook Entry or Product');
                        item.PricebookEntryId = pbeByVariety.get(varTemp.GPOS_Variety_Consolidation__r.Variety__c).Id;
                        item.Ship_Date__c = varTemp.Ship_Date__c;
                        item.Invoice_Date__c = varTemp.Invoice_Date__c;
                        item.Invoice_Number__c = varTemp.Invoice_Number__c;
                        item.Invoice_Type__c = varTemp.Invoice_Type__c;
                        item.OpportunityId = opp.Id;
                        item.Quantity = varTemp.Amount__c;
                        item.TotalPrice = 1;
                        items.add(item);
                    }
                }
            }
        try {
            insert items;
            ds.Blocked__c = true;
            update ds;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' in line ' + e.getLineNumber());
        }
    }

    public static List<GPOS_Grower_Temp__c> getTemps(String recordId) {
        List<GPOS_Grower_Temp__c> temps = [SELECT Id, Dealer_Summary__r.Client__c, Grower__c, Dealer__c, Dealer_Summary__r.Season__c,
                                            Grower__r.Name, Dealer__r.Name
                                            FROM GPOS_Grower_Temp__c 
                                            WHERE Dealer_Summary__c =:recordId];
        return temps;
    }

    public static List<GPOS_Variety_Temp__c> getVarietyTemps(Set<String> tempsIds) {
        List<GPOS_Variety_Temp__c> varTemps = [SELECT Id, GPOS_Variety_Consolidation__r.GPOS_Grower_Temp__c,
                                                GPOS_Variety_Consolidation__r.Variety__c, GPOS_Variety_Consolidation__r.Variety__r.Name, Ship_Date__c, Invoice_Date__c,
                                                Invoice_Number__c, Invoice_Type__c, Amount__c
                                                FROM GPOS_Variety_Temp__c 
                                                WHERE GPOS_Variety_Consolidation__r.GPOS_Grower_Temp__c IN :tempsIds];
        return varTemps;
    }
    
    public class resultWrapper {
        @AuraEnabled
        public Boolean hasRecords = false;
        @AuraEnabled
        public String message;
    }
}