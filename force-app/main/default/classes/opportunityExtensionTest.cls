@isTest
private class opportunityExtensionTest {

/*
    static testMethod void EstandarOppTest() {        
        Opportunity opp = new Opportunity();             
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);     
        opportunityExtension anexos0 = New opportunityExtension(controller);
        System.assertNotEquals(anexos0,null);        
    }
*/
/*
    static testMethod void test(){
 
        opportunityExtension anexos = New opportunityExtension();
       
        String a;
        anexos.setetapaAnexo(a);
        a = anexos.getetapaAnexo();        
        
        anexos.anexo = 'A1';
        anexos.listarAnexos();        
        anexos.getResultAnexos();
        
        List<SelectOption> op = New List<SelectOption>();
        op = anexos.getEtapasAnexos();
        op = anexos.getTiposAnexos();
        
   }
  */ 
   static testMethod void theTestsAnexos(){    
        
        Map<String,Id> rtype = USAUtils.cargarRecordTypesOppbyName();       
        Pricebook2 pb1 = new Pricebook2(Name='Lista Canal Multiplicadores',isActive=true); insert pb1;
        Account cuenta =  new Account(Name='ACME', CodigoSAP__c='6000000000'); insert cuenta;   
        
        Opportunity Opp1 = new Opportunity(Safra__c='16/2016',Name='New Opp',RecordTypeId=rtype.get('Appendix I'),StageName='Approved',Amount=10,closeDate=System.Today()+30,AccountId=cuenta.Id);
        insert(Opp1);
        
        PageReference pageRef = new PageReference('/006/e');
        pageRef.getParameters().put('Id',Opp1.Id);
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(Opp1);
        opportunityExtension anexos = New opportunityExtension(controller);
        
        anexos.getItems();
        
        Opportunity Opp2 = new Opportunity(Safra__c='16/2016',Name='New Opp',RecordTypeId=rtype.get('Sales Report'),StageName='Approved',Amount=10,closeDate=System.Today()+30,AccountId=cuenta.Id);
        insert(Opp2);
        pageRef.getParameters().put('Id',Opp2.Id);
        Test.setCurrentPageReference(pageRef);
        anexos.getItems();
        Opportunity Opp3 = new Opportunity(Safra__c='17/2017',Name='New Opp',RecordTypeId=rtype.get('Production Report'),StageName='Editable',Amount=10,closeDate=System.Today()+30,AccountId=cuenta.Id);
        insert(Opp3);
        pageRef.getParameters().put('Id',Opp3.Id);
        Test.setCurrentPageReference(pageRef);
        anexos.getItems();       
   }
}