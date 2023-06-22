@isTest
public with sharing class requestSAPOpportunityEditControllerTest {
    static Account acc;
    static Opportunity opp;
    static{

        acc = new Account();
        acc.Name = 'Account1'; 
        insert acc;
        opp = new Opportunity();
        opp.Name = 'opp1';
        opp.StageName = 'Editable';
        opp.CloseDate = System.today();
        opp.AccountId = acc.Id;
        insert opp; 
    
    }

    @isTest
    public static void testConstructor_shouldBeOk(){
        ApexPages.StandardController standardController = new ApexPages.StandardController(opp);
        requestSAPOpportunityEditController controller = new requestSAPOpportunityEditController(standardController);

        System.assertEquals(opp.Id, controller.oportunidadId);
        System.assertEquals(System.Url.getOrgDomainUrl().toExternalForm(), controller.currentUrlOrg);
    }
    @isTest
    public static void test_checkFields_shouldBeOk(){
        ApexPages.StandardController standardController = new ApexPages.StandardController(opp);
        requestSAPOpportunityEditController controller = new requestSAPOpportunityEditController(standardController);

        controller.checkFields();

        opp = [SELECT StageName, Status_Integracion__c, docRel__c FROM Opportunity];

        System.assertEquals('Editable', opp.StageName, 'The opportunity\'s status should be Editable.');
        System.assertEquals(null, opp.Status_Integracion__c, 'The opportunity\'s sap integration status should be null.');
        System.assertEquals(null, opp.docRel__c, 'The opportunity\'s docRel should be null.');
    }
}