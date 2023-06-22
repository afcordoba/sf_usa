/**
 * @description       : Test class for the salesRegionalizationComponentController
 * @author            : Santiago Muñoz
 * @group             : 
 * @last modified on  : 04-25-2023
 * @last modified by  : Santiago Muñoz
**/
@IsTest
public with sharing class salesRegionalizationControllerTest {
    static Opportunity opp;

    static {
        List<Location__c> lList = new List<Location__c>();

        lList.add(new Location__c(Name = 'A Localization 1',Automatization_of_Sales_Regionalization__c = true));
        lList.add(new Location__c(Name = 'A Localization 2',Automatization_of_Sales_Regionalization__c = false));

        insert lList;

        Variedad__c aVariety = new Variedad__c();
        aVariety.Name = 'Test Var';
        insert aVariety;

        Account account = new Account();
        account.Name = 'AGENTE';
        account.CodigoSAP__c = '12456554';
        insert account;

        Account account2 = new Account();
        account2.Name = 'AGENTE2';
        account2.CodigoSAP__c = '124565543';
        insert account2;
        
        Product2 produto002           = new Product2();
        produto002.Name               = 'ROYALTY';
        produto002.ProductCode        = '40026418';
        produto002.isActive           = true; 
        produto002.Variedade__c = aVariety.Id;
        insert produto002;

        Product2 produto_2           = new Product2();

        produto_2.Name               = 'SEED';
        produto_2.ProductCode        = '40026418';
        produto_2.isActive           = true;
        produto_2.Variedade__c = aVariety.Id;

        insert produto_2;

        Pricebook2 price1                 = new Pricebook2();
        price1.Name                       = 'Teste';
        price1.Description                = 'Teste';
        price1.IsActive                   = true;

        insert price1;

        PricebookEntry priceBookEntry1 = new PricebookEntry();
        priceBookEntry1.Pricebook2Id = Test.getStandardPricebookId();
        priceBookEntry1.Product2Id = produto_2.id;
        priceBookEntry1.UseStandardPrice = false;
        priceBookEntry1.IsActive = true;
        priceBookEntry1.UnitPrice = 100.00;

        insert priceBookEntry1;

        opp = new Opportunity();
        opp.RecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sale').getRecordTypeId();
        opp.Safra__c = '23/2023';    
        opp.AccountId = account.Id;
        opp.Ship_To__c = account.Id;
        opp.Branch_name__c = account2.Id; 
        opp.Name   = 'UnitTest';
        opp.Tipo__c = 'ZPLO - Local Order';
        opp.StageName  = 'Edition'; 
        opp.CloseDate = System.today()+60;
        opp.Condicion_de_Pago__c = 'ZC05 Net 30 days from shipping date';
        opp.Type = 'Z17 - PARENT SEED';
        opp.Pricebook2Id = Test.getStandardPricebookId();

        insert opp;

        OpportunityLineItem oppli1 = new OpportunityLineItem();
        oppli1.OpportunityId = opp.id;
        oppli1.PricebookEntryId = priceBookEntry1.id;
        oppli1.UnitPrice = 1;
        oppli1.Quantity = 40;
        oppli1.Pallet_Charge__c = 10;
        oppli1.Centro_de_Despacho__c = 'UD01';

        insert oppli1;

        
        insert new Sales_Volume_Estimation__c(Account__c = account.Id, Season__c = '23/2023');
    }

    @IsTest
    public static void getLocalizationsTest() {
        List<Location__c> lList = new List<Location__c>();

        Test.startTest();
        lList = salesRegionalizationComponentController.getLocations();
        Test.stopTest();

        System.assertEquals(1, lList.size(), 'Only one location should have been retrieved');
    }

    @IsTest
    public static void getDataTest() {
        List<salesRegionalizationComponentController.SalesLocalizationWrapper> wList = new List<salesRegionalizationComponentController.SalesLocalizationWrapper>();


        Test.startTest();
        wList = salesRegionalizationComponentController.getSalesVolumeDetailData(opp.id);
        Test.stopTest();

        System.assertEquals(1, wList.size(), 'Only one wrapper should have been retrieved');
        System.assertEquals(1, wList[0].sLocalizationList.size(), 'Only one Localization should have been created');
    }

    
    @IsTest
    public static void getVolumeDataTest() {
        List<salesRegionalizationComponentController.SalesLocalizationWrapper> wList = new List<salesRegionalizationComponentController.SalesLocalizationWrapper>();

        Sales_Volume_Estimation__c sve = [SELECT Id FROM Sales_Volume_Estimation__c LIMIT 1];

        //Creates the base data to cover the test
        salesRegionalizationComponentController.getSalesVolumeDetailData(opp.id);

        Test.startTest();
        wList = salesRegionalizationComponentController.getRecordSalesVolumeDetailData(sve.id);
        Test.stopTest();

        System.assertEquals(1, wList.size(), 'Only one wrapper should have been retrieved');
        System.assertEquals(1, wList[0].sLocalizationList.size(), 'Only one Localization should have been created');
    }
    @IsTest
    public static void saveDataTest() {
        List<salesRegionalizationComponentController.SalesLocalizationWrapper> wList = new List<salesRegionalizationComponentController.SalesLocalizationWrapper>();

        wList = salesRegionalizationComponentController.getSalesVolumeDetailData(opp.id);
        wList[0].sLocalizationList[0].Percentage__c = 100;

        Test.startTest();
        String result = salesRegionalizationComponentController.saveSalesRegionalizationData(wList);
        Test.stopTest();

        Sales_Localization__c sl = [SELECT Id, Percentage__c FROM Sales_Localization__c WHERE Id = :wList[0].sLocalizationList[0].Id];

        System.assertEquals('SUCCESS', result, 'Wrong result string');
        System.assertEquals(100, sl.Percentage__c, 'Percentage should be 100%');
    }
}