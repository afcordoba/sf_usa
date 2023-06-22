/**
 * @description       : 
 * @author            : Santiago Muñoz
 * @group             : 
 * @last modified on  : 04-25-2023
 * @last modified by  : Santiago Muñoz
**/

public with sharing class salesRegionalizationComponentController {

    @AuraEnabled
    /**
     * @description Gets the locations enabled for the Aura component
     *
     * @return      `List<Location__c>`
     * @exception   
     */    
    public static List<Location__c> getLocations(){
        try {
            return new List<Location__c>([SELECT Id, Name, Location_Region__c FROM Location__c WHERE Automatization_Of_Sales_Regionalization__c = TRUE]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Gets the locations map for the Apex class
     *
     * @return      `Map<Id, Location__c>`
     * @exception   
     */    
    public static Map<Id, Location__c> getLocationsMap(){
        try {
            return new Map<Id, Location__c>([SELECT Id, Name, Location_Region__c FROM Location__c WHERE Automatization_Of_Sales_Regionalization__c = TRUE]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    /**
     * @description Retrieves all the sales localization information for the aura component based on the opportunity ID
     *
     * @param oppId Opportunity Id retrieved from the parameters of the aura component.
     * @return      `List<SalesLocalizationWrapper>`
     * @exception   
     */    
    public static List<SalesLocalizationWrapper> getSalesVolumeDetailData(Id oppId){
        try{
            /*
            1- Get the opp, with the products
            2- Get The Sales Volume estimation for the account and season with the Sales localization for the varieties used in the opp
            3- if the Sales Localization is not created, it should create one automatically and send that to the component
            */

            Map<Id,Location__c> locationMap = new Map<Id,Location__c>();
            List<Sales_Localization__c> salesLocalizationList = new List<Sales_Localization__c>();
            Set<Id> varietySet = new Set<Id>();
            Map<Id,SalesLocalizationWrapper> returnWrapper = new Map<Id,SalesLocalizationWrapper>();

            Opportunity theOpp = [
                SELECT Id, AccountId, Safra__c, Marca__c
                FROM Opportunity
                WHERE Id = :oppId   
            ];
            List<OpportunityLineItem> oliList = [
                SELECT Id, PricebookEntry.Product2.Variedade__c FROM OpportunityLineItem WHERE OpportunityId = :oppId
            ];

            locationMap = getLocationsMap();


            for(OpportunityLineItem oli : oliList) {
                varietySet.add(oli.PricebookEntry.Product2.Variedade__c);
            }

            Sales_Volume_Estimation__c sve = [
                SELECT Id, Season__c, Brand__c, Account__c,
                (SELECT Id, Variety__c, Percentage__c, Brand__c, Active__c, Location__c FROM Sales_Localizations__r WHERE Variety__c IN :varietySet AND Location__c IN :locationMap.keySet())
                FROM Sales_Volume_Estimation__c
                WHERE Account__c = :theOpp.AccountId AND Season__c = :theOpp.Safra__c
                LIMIT 1
            ];

            salesLocalizationList = sve.Sales_Localizations__r;

            Map<Id,Variedad__c> varietyMap = new Map<Id,Variedad__c>([SELECT Id, Name FROM Variedad__c WHERE Id IN :varietySet]);

            if(locationMap.values().size() * varietySet.size() > sve.Sales_Localizations__r.size()) {
                salesLocalizationList.addAll(createSalesVolumeDetails(salesLocalizationList, locationMap.values(), varietyMap.values(), sve));
            }

            for(Sales_Localization__c sl : salesLocalizationList) {
                SalesLocalizationWrapper wItem = returnWrapper.get(sl.Variety__c);
                if(wItem == null) {
                    wItem = new SalesLocalizationWrapper();
                    wItem.sLocalizationList = new List<Sales_Localization__c>();
                    wItem.variety = varietyMap.get(sl.Variety__c);
                    wItem.sLocalizationList.add(sl);
                    wItem.tPercentage = 0 + sl.Percentage__c;

                    returnWrapper.put(sl.Variety__c, wItem);
                } else {
                    wItem.sLocalizationList.add(sl);
                    wItem.tPercentage = wItem.tPercentage + sl.Percentage__c;

                    returnWrapper.put(sl.Variety__c, wItem);
                }
            }            

            System.debug(returnWrapper.values());

            return returnWrapper.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SalesLocalizationWrapper> getRecordSalesVolumeDetailData(Id sveId){
        try{
            Map<Id,Location__c> locationMap = new Map<Id,Location__c>();
            List<Sales_Localization__c> salesLocalizationList = new List<Sales_Localization__c>();
            Map<Id,SalesLocalizationWrapper> returnWrapper = new Map<Id,SalesLocalizationWrapper>();

            locationMap = getLocationsMap();
            salesLocalizationList = new List<Sales_Localization__c>([
                SELECT Id, Variety__c, Variety__r.Name, Percentage__c, Brand__c, Active__c, Location__c
                FROM Sales_Localization__c
                WHERE Sales_Estimation__c = :sveId
            ]);

            for(Sales_Localization__c sl : salesLocalizationList) {
                SalesLocalizationWrapper wItem = returnWrapper.get(sl.Variety__c);
                if(wItem == null) {
                    wItem = new SalesLocalizationWrapper();
                    wItem.sLocalizationList = new List<Sales_Localization__c>();
                    wItem.variety = sl.Variety__r;
                    wItem.sLocalizationList.add(sl);
                    wItem.tPercentage = 0 + sl.Percentage__c;

                    returnWrapper.put(sl.Variety__c, wItem);
                } else {
                    wItem.sLocalizationList.add(sl);
                    wItem.tPercentage = wItem.tPercentage + sl.Percentage__c;

                    returnWrapper.put(sl.Variety__c, wItem);
                }
            }            

            System.debug(returnWrapper.values());

            return returnWrapper.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    /**
     * @description                 Update of the information of the Sales Localization information from the component
     *
     * @param salesLocalizationList 
     * @return                      `string`
     * @exception                   
     */    
    public static string saveSalesRegionalizationData(List<SalesLocalizationWrapper> salesLocalizationList){
        try {
            List<Sales_Localization__c> slToUpdate = new List<Sales_Localization__c>();

            for(SalesLocalizationWrapper w : salesLocalizationList) {
                slToUpdate.addAll(w.sLocalizationList);
            }
            update slToUpdate;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description             Creates the Sales Localization records depending on the varieties and locations, also checks that it is not created before.
     *
     * @param sLocalizationList 
     * @param locationList      
     * @param varietyList       
     * @param sve               
     * @return                  `List<Sales_Localization__c>`
     */      
    public static List<Sales_Localization__c> createSalesVolumeDetails(List<Sales_Localization__c> sLocalizationList, List<Location__c> locationList, List<Variedad__c> varietyList, Sales_Volume_Estimation__c sve){
        List<Sales_Localization__c> slToInsert = new List<Sales_Localization__c>();

        for(Variedad__c v : varietyList) {
            for(Location__c location : locationList) {
                Boolean hasLocalizationCreated = false;
                for(Sales_Localization__c sl : sLocalizationList) {
                    if(sl.Location__c == location.Id && sl.Variety__c == v.Id) {
                        hasLocalizationCreated = true;
                        break;
                    }
                }
                if(hasLocalizationCreated == false) {
                    slToInsert.add(new Sales_Localization__c(Sales_Estimation__c = sve.Id, Location__c = location.Id, Percentage__c = 0, Variety__c = v.Id, Active__c = true));
                }
            }
        }
        
        insert slToInsert;

        return slToInsert;
    }

    
    public class SalesLocalizationWrapper {
        @AuraEnabled
        public Variedad__c variety { get; set; }
        @AuraEnabled
        public List<Sales_Localization__c> sLocalizationList { get; set; }
        @AuraEnabled
        public Double tPercentage { get; set; }
    }
}