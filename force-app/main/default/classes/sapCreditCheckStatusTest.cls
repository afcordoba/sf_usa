@isTest
private class sapCreditCheckStatusTest {
    @isTest static void test_method_one() {
        Test.startTest();
        
        Configuracion_USA__c co = new Configuracion_USA__c(FC_mandante_SAP__c='200',RecordType_for_OppNro__c='Sales_Report,Production_Report',link_intra_dm__c='', Link_Sap_Prod__c='', Link_Sap_QA__c='');
        insert co;
       
        Account account = new Account();
        account.Name = 'AGENTE';
        account.CodigoSAP__c = '12456554';
        insert account;    
        
        Product2 produto002           = new Product2();
        produto002.Name               = 'ROYALTY';
        produto002.ProductCode        = '40026418';
        produto002.isActive           = true; 
        insert produto002;
    
        Product2 produto_2           = new Product2();
        produto_2.Name               = 'SEED';
        produto_2.ProductCode        = '40026418';
        produto_2.isActive           = true;
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
    
        Opportunity opp = new Opportunity();
        opp.RecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sale').getRecordTypeId();
        opp.Safra__c = '19/2019';    
        opp.AccountId = account.Id;
        opp.Ship_To__c = account.Id;
        //opp.Branch_name__c = account2.Id; 
        opp.Name   = 'UnitTest';
        opp.Tipo__c = 'ZPLO - Local Order';
        opp.StageName  = 'Locked by Credit'; 
        opp.CloseDate = System.today()+60;
        opp.Condicion_de_Pago__c = 'ZC05 Net 30 days from shipping date';
        opp.Type = 'Z17 - PARENT SEED';
        opp.Nro_Pedido_SAP__c = '00004584525';
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
    
        update opp;
    
        sapCreditStatus_caller.consultarOpps();
        Test.stopTest();
    }
}