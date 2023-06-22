@isTest
private class OpportunityVtaIntegrationBOTest {
  
    @isTest static void test_method_one() {
     
    Configuracion_USA__c co = new Configuracion_USA__c(FC_mandante_SAP__c='200',RecordType_for_OppNro__c='Sales_Report,Production_Report',link_intra_dm__c='', Link_Sap_Prod__c='', Link_Sap_QA__c='');
    insert co;
   
	//SELECT Id, GDM_Licensing__c, Virtue__c, Don_Mario__c 
    General_Settings__c gs = new General_Settings__c();
    insert gs;
    
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

//    Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = 'GDM - PriceList'];

    PricebookEntry priceBookEntry1 = new PricebookEntry();
    priceBookEntry1.Pricebook2Id = Test.getStandardPricebookId();
//    priceBookEntry1.Pricebook2Id = pb.Id;    
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

    update opp;

    List<Queue__c> queueToInsert = new List<Queue__c>();
    for( Opportunity opportunity : OpportunityDAO.getInstance().getOpportunityByListId( new List<String>{ opp.Id } ) ) {
        String jsonResult;
        if(opportunity.Nro_pedido_SAP__c == null || opportunity.Nro_pedido_SAP__c == ''){
            jsonResult = OpportunityVtaIntegrationBO.outboundRequest( opportunity );
            queueToInsert.add( QueueBO.getInstance().sObjectQueue( opportunity.Id, 'OPPORTUNITY_SALESFORCE_TO_SAP', jsonResult, false ) );
        }
    }

    insert queueToInsert;

    Queue__c result = [SELECT Id, EventName__c, RecordId__c, Payload__c FROM Queue__c WHERE Id = :queueToInsert[0].Id];
 
    OpportunityVtaIntegrationBO.executeQueue(result.Id, result.RecordId__c, result.EventName__c, result.Payload__c, 1);  

  }

  @isTest static void test_method_two() {
   
    Configuracion_USA__c co = new Configuracion_USA__c(RecordType_for_OppNro__c='Sales_Report,Production_Report',link_intra_dm__c='', Link_Sap_Prod__c='', Link_Sap_QA__c='');
    insert co;
    General_Settings__c gs = new General_Settings__c();
    insert gs;
      
    Account account = new Account(Name='123412');
    account.CodigoSAP__c = '12456554';
    insert account;

    Product2 produto01           = new Product2();
    produto01.Name               = 'SS M8808 IPRO COM P1';
    produto01.ProductCode        = '40026418';
    produto01.Unidade__c         = 'LB';
    produto01.isActive           = true; 

    insert produto01;

    Product2 produto02           = new Product2();

    produto02.Name               = 'M 8808 IPRO P1 B5M';
    produto02.ProductCode        = '40026418';
    produto02.isActive           = true;

    insert produto02;

    Pricebook2 price1                 = new Pricebook2();
    price1.Name                       = 'Teste';
    price1.Description                = 'Teste';
    price1.IsActive                   = true;

    insert price1;

    PricebookEntry priceBookEntry1 = new PricebookEntry();
    priceBookEntry1.Pricebook2Id = Test.getStandardPricebookId();
    priceBookEntry1.Product2Id = produto02.id;
    priceBookEntry1.UseStandardPrice = false;
    priceBookEntry1.IsActive = true;
    priceBookEntry1.UnitPrice = 100.00;

    insert priceBookEntry1; 
           
    PricebookEntry priceBookEntry2 = new PricebookEntry();
    priceBookEntry2.Pricebook2Id = Test.getStandardPricebookId();
    priceBookEntry2.Product2Id = produto01.id;
    priceBookEntry2.UseStandardPrice = false;
    priceBookEntry2.IsActive = true;
    priceBookEntry2.UnitPrice = 1.434;

    insert priceBookEntry2;    

    Opportunity opp = new Opportunity();
    opp.RecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sale').getRecordTypeId();
    opp.Safra__c = '19/2019';    
    opp.AccountId = account.Id;
    opp.Ship_To__c = account.Id; 
    opp.Name   = 'UnitTest';
    opp.Tipo__c = 'ZPLO - Local Order';
    opp.Incoterm_1__c = 'FOB - FREE ON BOARD';
    opp.Incoterm_2__c = 'MARION';
    opp.StageName  = 'Pending Approval'; 
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
    oppli1.Shipping_Costs__c = 21;
    oppli1.Pallet_Charge__c = 6;
    oppli1.Centro_de_Despacho__c = 'UD01';
    
    insert oppli1;

    OpportunityLineItem oppli2 = new OpportunityLineItem();
    oppli2.OpportunityId = opp.id;
    oppli2.PricebookEntryId = priceBookEntry2.id;
    oppli2.UnitPrice = 1;
    oppli2.Quantity = 480;
    oppli2.Shipping_Costs__c = 1;
    oppli2.Centro_de_Despacho__c = 'UD01';
    
    insert oppli2;
    
    opp.StageName  = 'Approved'; 
    update opp;

    List<Queue__c> queueToInsert = new List<Queue__c>();
    for( Opportunity opportunity : OpportunityDAO.getInstance().getOpportunityByListId( new List<String>{ opp.Id } ) ) {
        String jsonResult;
        if(opportunity.Nro_Pedido_SAP__c == null || opportunity.Nro_Pedido_SAP__c == ''){
            jsonResult = OpportunityVtaIntegrationBO.outboundRequest( opportunity );
            queueToInsert.add( QueueBO.getInstance().sObjectQueue( opportunity.Id, 'OPPORTUNITY_SALESFORCE_TO_SAP', jsonResult, false ) );
      }
    }

    insert queueToInsert;

    Queue__c result = [SELECT Id, EventName__c, RecordId__c, Payload__c FROM Queue__c WHERE Id = :queueToInsert[0].Id]; 
    OpportunityVtaIntegrationBO.executeQueue(result.Id, result.RecordId__c, result.EventName__c, result.Payload__c,110);  

    //ejecutar una modificacion por rejection
    List<Queue__c> queueToReject = new List<Queue__c>();
    for(Opportunity opportunity : OpportunityDAO.getInstance().getOpportunityByListId( new List<String>{ opp.Id } ) ) {
        String jsonResult;
        jsonResult = OpportunityVtaIntegrationBO.outboundRequestRej( opportunity );
        queueToReject.add( QueueBO.getInstance().sObjectQueue( opportunity.Id, 'OPPORTUNITY_REJ_SALESFORCE_TO_SAP', jsonResult, false ) );
    }

    insert queueToReject;
    Queue__c result2 = [SELECT Id, EventName__c, RecordId__c, Payload__c FROM Queue__c WHERE Id = :queueToReject[0].Id];
    OpportunityVtaIntegrationBO.executeQueue(result2.Id, result2.RecordId__c, result2.EventName__c, result2.Payload__c,110);  
    
  }

  
}