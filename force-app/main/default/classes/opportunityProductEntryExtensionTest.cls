@isTest
private class opportunityProductEntryExtensionTest {

    @IsTest(SeeAllData=false)
    static void theTestSales(){             
        
        Test.startTest();
        Map<String,Id> rt = USAUtils.cargarRecordTypesOppbyName();
        
        Product2 p1 = new Product2(Name='DM3810'); insert p1;
        Pricebook2 pb = new Pricebook2(Name='Portal PriceList',isActive=true); insert pb;
        
        PricebookEntry pStd_aux = new PricebookEntry(pricebook2Id=Test.getStandardPricebookId(), Product2Id=p1.id, UnitPrice=0, isActive=true, useStandardPrice=false); insert pStd_aux;
        PricebookEntry pbe = new PricebookEntry(Product2Id=p1.Id,UnitPrice=2,Pricebook2Id=pb.Id,isActive=true); insert pbe;
        Opportunity o1 = new Opportunity(RecordTypeId=rt.get('Sales Report'), Name='PEPE3', Safra__c ='18/2018', Stagename='Editable', CloseDate=System.Today()); insert o1;
        OpportunityLineItem oli = new OpportunityLineItem (OpportunityId=o1.Id,Quantity=1000,UnitPrice=32,PricebookEntryId=pbe.Id); insert oli;
              
        ////////////////////////////////////////
        //  test opportunityProductEntry
        ////////////////////////////////////////
   
        PageReference pageRef = Page.opportunityProductEntry;
        pageRef.getParameters().put('Id',oli.OpportunityId);
        Test.setCurrentPageReference(pageRef);

        opportunityProductEntryExtension oPEE = new opportunityProductEntryExtension(new ApexPages.StandardController(o1));

        oPEE.searchString = 'haciendo caca';
        oPEE.updateAvailableList();
        oPEE.setforcePricebookSelection(true);
        oPEE.priceBookCheck();
        
        oPEE.toUnselect = '0';
        oPEE.removeFromShoppingCart();
                
        oPEE.onSave();
        oPEE = new opportunityProductEntryExtension(new ApexPages.StandardController(o1));

        oPEE.searchString = oli.PricebookEntry.Name;
        oPEE.updateAvailableList();
        oPEE.onSave();

        for(OpportunityLineItem o : oPEE.ShoppingCart){
            o.quantity = 5;
            o.unitprice = 300;
        }
        oPEE.onSave();
        
        Test.stopTest();
        
    } 
 
    @IsTest(SeeAllData=false)
    static void theTestProd(){
        
        Test.startTest();
        
        Map<String,Id> rt = USAUtils.cargarRecordTypesOppbyName();
        Product2 p1 = new Product2(Name='DM3810'); insert p1;
        Pricebook2 pb = new Pricebook2(Name='Portal PriceList',isActive=true); insert pb;
        
        Account cuenta =  new Account(Name='ACME', CodigoSAP__c='6000000000'); insert cuenta;
                
        PricebookEntry pStd_aux = new PricebookEntry(pricebook2Id=Test.getStandardPricebookId(), Product2Id=p1.id, UnitPrice=0, isActive=true, useStandardPrice=false); insert pStd_aux;
        PricebookEntry pbe = new PricebookEntry(Product2Id=p1.Id,UnitPrice=2,Pricebook2Id=pb.Id,isActive=true); insert pbe;
        Opportunity o1 = new Opportunity(Marca__c='GDM',RecordTypeId=rt.get('Production Report'), Name='PEPE3', Safra__c ='18/2018', Stagename='Editable', CloseDate=System.Today()); insert o1;               
       
        opportunityProductEntryExtension oPEE = new opportunityProductEntryExtension(new ApexPages.StandardController(o1));
       
        System.assert(oPEE.onCancel()!=null);
        
        oPEE.updateAvailableList();
        oPEE.getFields();
        oPEE.addToShoppingCart();
     
        Test.stopTest();
     
    }

}