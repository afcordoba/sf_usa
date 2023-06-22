/**
 * Clase test de todos los controllers del sitio portal, USA especifico
 * Jere 22.06.02 Complete unit tests
 */
@isTest
global with sharing class aSiteHomeHeaderControllerTest {

    @IsTest(SeeAllData=false)
    global static void testHomeController () {
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM',Production_season__c='20/2020', Sales_season__c='20/2020', Safra__c='20/2020',SiteUser__c=su.Id); insert susess;

        aSiteHomeController controller = new aSiteHomeController();
        controller.validate();
                        
        PageReference pageRef = Page.aSiteHome;
        pageRef.getParameters().put('token',susess.Id);      
        Test.setCurrentPageReference(pageRef);

        controller.validate();
        controller.getUser();
                
        //controller.getHomeMessage();
        
        Map<String,Id> rTypes = Opp_Utils.cargarRecordTypesOportunidades();
        Map<String,String> rTypesD = USAUtils.cargarRecordTypesOppbyDevName();
        String type = 'Production Update 2';
        Opportunity opp = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('Production_Report')),AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='GDM',CloseDate=system.today(),Stagename='Editable',Type=type); insert opp;
        
        Product2 p1 = new Product2(Name='DM3810'); insert p1;
        Pricebook2 pb = new Pricebook2(Name='Portal PriceList',isActive=true); insert pb;
        PricebookEntry pStd_aux = new PricebookEntry(pricebook2Id=Test.getStandardPricebookId(), Product2Id=p1.id, UnitPrice=0, isActive=true, useStandardPrice=false); insert pStd_aux;
        PricebookEntry pbe = new PricebookEntry(Product2Id=p1.Id,UnitPrice=2,Pricebook2Id=pb.Id,isActive=true); insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem (OpportunityId=opp.Id,Quantity=1000,Semente_bruta__c=10000,UnitPrice=32,PricebookEntryId=pbe.Id); insert oli;
        
        controller.getTotalProduction();
        controller.getDiffProduction();
        controller.getDiffSold();
        controller.getTotalSold();
        controller.getDiffFore();
        controller.getTotalForecast();
            
        controller.gotoProdReport();
        controller.gotoProdUpdate3Report();
        controller.gotoProdUpdateAugReport();
        controller.gotoProdUpdateDecReport();
        controller.gotoProd2();
        controller.gotoProd1();
        
        controller.gotoSalesForeUpdate1Report();
        controller.gotoSales2();
        controller.gotoSales3();
        controller.gotoSalesUpdate3Report();
        controller.gotoSales4();
        controller.gotoSalesReport();
        
    }
    
    @IsTest(SeeAllData=false)
    global static void testHomeHeaderController () {
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='16/2016',SiteUser__c=su.Id); insert susess;

        aSiteHomeController controller0 = new aSiteHomeController();
        controller0.validate();
                        
        PageReference pageRef = Page.aSiteHome;
        pageRef.getParameters().put('token',susess.Id);      
        Test.setCurrentPageReference(pageRef);

        controller0.validate();
        controller0.getUser();

        pageRef = new PageReference('/aSiteAppendix2');
        pageRef.getParameters().put('token',susess.Id);      
        Test.setCurrentPageReference(pageRef);

        aSiteHeaderController controller = new aSiteHeaderController();
        controller.getUser();
        controller.gotoDashboard();
        controller.getBrand();
            
        controller.gotoProfile();
        controller.gotoAppend1();
        controller.gotoContract();
        
        controller.gotoUploadFile();
        controller.gotoDataAnalytics();
        controller.gotoSeedTracking();
            
        controller.closeSession();
        controller.gotoUploadFile();
                
    }
        
    @IsTest(SeeAllData=false)
    global static void testHeaderProdReportController () {
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='16/2016',Production_season__c='20/2020',SiteUser__c=su.Id); insert susess;

        PageReference pageRef = Page.aSiteHome;
        pageRef = new PageReference('/aSiteAppendix2');
        pageRef.getParameters().put('token',susess.Id);      
        Test.setCurrentPageReference(pageRef);

        aSiteHeaderController controller = new aSiteHeaderController();
        controller.gotoProdFinalReport();
            
        controller.gotoProd5Report();
        controller.gotoProd4Report();            
        controller.gotoProd3Report();
        controller.gotoProd2Report();
        controller.gotoProd1Report();
        
        Map<String,Id> rTypes = Opp_Utils.cargarRecordTypesOportunidades();
        Map<String,String> rTypesD = USAUtils.cargarRecordTypesOppbyDevName();
        String type = 'Production Update 1';
        Opportunity opp = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('Production_Report')),AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='GDM',CloseDate=system.today(),Stagename='Editable',Type=type); insert opp;
        controller.gotoProd1Report();
        
        opp.type = 'Production Update 2'; update opp;
        controller.gotoProd2Report();
        
        opp.type = 'Production Update 3'; update opp;
        controller.gotoProd3Report();

        controller.closeSession();
        controller.gotoUploadFile();
                
    }
    
    @IsTest(SeeAllData=false)
    global static void testHeaderSalesReportController () {
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='20/2020',SiteUser__c=su.Id,Sales_Season__c='20/2020'); insert susess;

        PageReference pageRef = Page.aSiteHome;
        pageRef = new PageReference('/aSiteAppendix2');
        pageRef.getParameters().put('token',susess.Id);      
        Test.setCurrentPageReference(pageRef);

        aSiteHeaderController controller = new aSiteHeaderController();
        controller.gotoSalesReport();
            
        controller.gotoSalesUpdate4Report();
        controller.gotoSalesUpdate3Report();
        controller.gotoSalesForeUpdate2Report();
        controller.gotoSalesForeUpdate1Report();


        Map<String,Id> rTypes = Opp_Utils.cargarRecordTypesOportunidades();
        Map<String,String> rTypesD = USAUtils.cargarRecordTypesOppbyDevName();
        String type = 'Sales Forecast Update 1';
        Opportunity opp = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('Sales_Report')),AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='GDM',CloseDate=system.today(),Stagename='Editable',Type=type); insert opp;
        controller.gotoSalesForeUpdate1Report();
        
        opp.type = 'Sales Forecast Update 2';
        update opp;
        controller.gotoSalesForeUpdate2Report();
        
        opp.type = 'Sales Forecast Update 3';
        update opp;
        controller.gotoSalesUpdate3Report();
                
        opp.type = 'Sales Forecast Update 4';
        update opp;
        controller.gotoSalesUpdate3Report();

        opp.type = 'Final Sales Report';
        update opp;
        controller.gotoSalesReport();
            
        controller.closeSession();
        controller.gotoUploadFile();
                
    }
    
}