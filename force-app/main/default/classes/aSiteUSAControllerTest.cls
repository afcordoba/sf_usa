/**
 * Clase test de todos los controllers del sitio portal, USA especifico
 *  Jere 22.06.02 Complete unit tests
 */
@isTest
global with sharing class aSiteUSAControllerTest {
    
    @IsTest (SeeAllData=false)
    global static void testAuthManager () {        
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='18/2018',SiteUser__c=su.Id); insert susess;

        aSiteAuthManager.RefreshUserSession(susess.Id);
        
    }
    
    @IsTest (SeeAllData=false)
    global static void testContractController () {
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='18/2018',SiteUser__c=su.Id); insert susess;
        Contrato__c cont = new Contrato__c(Multiplicador__c=acc.Id, Safra__c='18/2018',Sociedad__c='GDM'); insert cont;
        
        aSiteContractController controller = new aSiteContractController();
        controller.validate();

        PageReference pageRef = Page.aSiteContracts;
        pageRef.getParameters().put('token',susess.Id);
        Test.setCurrentPageReference(pageRef);
        controller.validate();
        controller.getContracts();
        controller.setActiveContract();
        controller.getUser();
        controller.getAccount();
}

    @IsTest (SeeAllData=false)
    global static void testProfileController () {
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='18/2018',SiteUser__c=su.Id); insert susess;

        aSiteProfileController controller = new aSiteProfileController();
        controller.validate();

        PageReference pageRef = Page.aSiteProfile;
        pageRef.getParameters().put('token',susess.Id);
        Test.setCurrentPageReference(pageRef);
        controller.validate();

        controller.getAccounts();
        controller.accSelect=suacc.Id;
        controller.setActiveAccount();
        controller.getUser();
        
        controller.getAccounts();
        controller.editProfile();
        controller.editPassword();
        controller.editCancel();
        controller.saveProfile();
    }

    @IsTest (SeeAllData=false)
    global static void testPasswordController () {
        aSiteForgotPassController controller = new aSiteForgotPassController();
        controller.forgotPassword();

        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123456'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='18/2018',SiteUser__c=su.Id); insert susess;
        
        controller.username = 'test@salesforce.com';
        controller.forgotPassword();
        

        PageReference pageRef = new PageReference('/aSiteChangePass');
        pageRef.getParameters().put('token',susess.Id);
        Test.setCurrentPageReference(pageRef);
        
        aSiteChangePassController controller1 = new aSiteChangePassController();
        controller1.validate();
        controller1.ChangePassword();
        controller1.oldpassword = '123456';
        controller1.ChangePassword();
        controller1.newpassword = '123';
        controller1.ChangePassword();
        controller1.verifynewpassword = '123';
        controller1.ChangePassword();
    }
    
    @IsTest (SeeAllData=false)
    global static void testLoginController () {
        aSiteLoginController controller = new aSiteLoginController ();
        System.assertEquals(controller.login(),null);
        controller.username = 'test@salesforce.com';
        System.assertEquals(controller.login(),null);
        controller.password = '123456';                
        System.assertEquals(controller.login(),null);

        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='test@salesforce.com', Password__c='123456'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        
        controller.login();
        su.Cadastro_pela_primeira_vez__c = true; update su;
        controller.login();
        
        controller.forwardToResetPassword();
        controller.forwardToLogin();
        
        controller.closeSession();
    }
   
    @IsTest (SeeAllData=false)
    global static void testSalesController () {
		
        aSiteSalesReportController controller = new aSiteSalesReportController ();
        controller.validate();
        
        Map<String,Id> rTypes = Opp_Utils.cargarRecordTypesOportunidades();
        Map<String,String> rTypesD = USAUtils.cargarRecordTypesOppbyDevName();
        
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='20/2020',SiteUser__c=su.Id); insert susess;
        
        PageReference pageRef = new PageReference('/aSiteSalesReport');
        pageRef.getParameters().put('token',susess.Id);      
        pageRef.getParameters().put('t','fi');
        Test.setCurrentPageReference(pageRef);        
        
        controller = new aSiteSalesReportController ();
        controller.validate();                
        System.assertEquals(controller.validate(),null);
        
        Opportunity opp3 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('Sales_Report')),AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='GDM', CloseDate=system.today(),Stagename='Editable'); insert opp3;
        controller.getSalesReport();
        controller.recId = 'aa';
        controller.setActiveOpp();
        controller.getSalesReport();
                
        controller.getUser();
        System.assertEquals(controller.getAccount().Name,'JERE');
        controller.getFields();
                
        controller.gotoNew();
        Categoria__c cat = new Categoria__c(Name='BASIC'); insert cat;
        Variedad__c var = new Variedad__c(Name='USG'); insert var;
        Product2 p1 = new Product2(Name='3810', Variedade__c=var.Id,Categ__c=cat.Id,Family='Royalty x Basica'); insert p1;
        Pricebook2 pb2 = new Pricebook2(Name='Portal Pricelist',isActive=true); insert pb2;
        
        PricebookEntry pStd_aux = new PricebookEntry(pricebook2Id=Test.getStandardPricebookId(), Product2Id=p1.id, UnitPrice=0, isActive=true, useStandardPrice=false); insert pStd_aux;
        PricebookEntry pbe = new PricebookEntry(Product2Id=p1.Id,UnitPrice=2,Pricebook2Id=pb2.Id,isActive=true); insert pbe;

        Opportunity opp1 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('AnexoI')),AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='GDM', CloseDate=system.today(),Stagename='Approved'); insert opp1;
        OpportunityLineItem opp1Item = new OpportunityLineItem(Sales_Report_Type__c='Forecast',Area__c=100,Categoria__c=cat.Id,PricebookEntryId=pbe.Id,OpportunityId=opp1.Id,UnitPrice=1,Quantity=1); insert opp1Item;


        controller.saveSalesReport();

      
        controller.saveSalesReport();
                
        pageRef.getParameters().put('e',opp1.Id);
        Test.setCurrentPageReference(pageRef);        

        controller.validate();                
        System.assertEquals(controller.validate(),null);
        controller.gotoEdit();
       

        controller.EditCancel();               
        controller.saveSalesReport();
        controller.submitSalesReport();
        
        aAppManager.getCategorias();
        aAppManager.getEstados();
        aAppManager.getLinkDataAnalytics();
        
        pageRef.getParameters().put('t','up1');
        Test.setCurrentPageReference(pageRef);        
        
        controller = new aSiteSalesReportController ();
        controller.validate();                
        controller.getRepItemsSale();
        
        pageRef.getParameters().put('t','up2');
        Test.setCurrentPageReference(pageRef);        
        
        controller = new aSiteSalesReportController ();
        controller.validate();                
        controller.getRepItemsSale();
        
        pageRef.getParameters().put('t','up3');
        Test.setCurrentPageReference(pageRef);        
        
        controller = new aSiteSalesReportController ();
        controller.validate();                
        controller.getRepItemsSale();
        
    }    
    
    @IsTest (SeeAllData=false)
    global static void testFinalSalesController () {
		
        aSiteSalesReportController controller = new aSiteSalesReportController ();
        controller.validate();
        
        Map<String,Id> rTypes = Opp_Utils.cargarRecordTypesOportunidades();
        Map<String,String> rTypesD = USAUtils.cargarRecordTypesOppbyDevName();
        
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='20/2020',SiteUser__c=su.Id); insert susess;
        
        PageReference pageRef = new PageReference('/aSiteSalesReport');
        pageRef.getParameters().put('token',susess.Id);      
        pageRef.getParameters().put('t','fi');
        Test.setCurrentPageReference(pageRef);        
        
        controller = new aSiteSalesReportController ();
        controller.validate();                
        System.assertEquals(controller.validate(),null);
        
        Opportunity opp3 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('Sales_Report')),Type='Final Sales Report',AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='GDM', CloseDate=system.today(),Stagename='Editable'); insert opp3;
        controller.getSalesReport();
        controller.recId = 'aa';
        controller.setActiveOpp();
        controller.getSalesReport();
                
        controller.getUser();
        System.assertEquals(controller.getAccount().Name,'JERE');        
                
        controller.gotoNew();
        
        Categoria__c cat = new Categoria__c(Name='BASIC'); insert cat;
        Variedad__c var = new Variedad__c(Name='USG'); insert var;
        Product2 p1 = new Product2(Name='3810', Variedade__c=var.Id,Categ__c=cat.Id,Family='Royalty x Basica'); insert p1;
        Pricebook2 pb2 = new Pricebook2(Name='Portal Pricelist',isActive=true); insert pb2;
        
        PricebookEntry pStd_aux = new PricebookEntry(pricebook2Id=Test.getStandardPricebookId(), Product2Id=p1.id, UnitPrice=0, isActive=true, useStandardPrice=false); insert pStd_aux;
        PricebookEntry pbe = new PricebookEntry(Product2Id=p1.Id,UnitPrice=2,Pricebook2Id=pb2.Id,isActive=true); insert pbe;

        Opportunity opp1 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('AnexoI')),AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='GDM', CloseDate=system.today(),Stagename='Approved'); insert opp1;
        OpportunityLineItem opp1Item = new OpportunityLineItem(Sales_Report_Type__c='Forecast',Area__c=100,Categoria__c=cat.Id,PricebookEntryId=pbe.Id,OpportunityId=opp1.Id,UnitPrice=1,Quantity=1); insert opp1Item;
        
        OpportunityLineItem opp3Item = new OpportunityLineItem(Semente_comercializada__c=100,Categoria__c=cat.Id,PricebookEntryId=pbe.Id,OpportunityId=opp3.Id,UnitPrice=1,Quantity=1); insert opp3Item;
        
        opp3.StageName = 'Approved';
        update opp3;
       
    }
        
    @IsTest (SeeAllData=false)
    global static void testProductionController () {
        
        aSiteProductionReportController controller = new aSiteProductionReportController ();
        controller.validate();
        
        Map<String,Id> rTypes = Opp_Utils.cargarRecordTypesOportunidades();
        Map<String,String> rTypesD = USAUtils.cargarRecordTypesOppbyDevName();
        
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='18/2018',SiteUser__c=su.Id); insert susess;
        
        PageReference pageRef = new PageReference('/aSiteProductionReport');
        pageRef.getParameters().put('token',susess.Id);      
        pageRef.getParameters().put('t','fi');
        Test.setCurrentPageReference(pageRef);        
        
        controller.validate();                
        System.assertEquals(controller.validate(),null);
        
        Opportunity opp3 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('Production_Report')),AccountId=acc.Id,Name='NEW',Safra__c='18/2018',Marca__c='GDM', CloseDate=system.today(),Stagename='Editable'); insert opp3;
        controller.getProductionReport();
        controller.recId = 'aa';
        controller.setActiveOpp();
        controller.getProductionReport();
                
        controller.getUser();
        System.assertEquals(controller.getAccount().Name,'JERE');
        controller.getFields();
                
        controller.gotoNew();       
        
        
        Categoria__c cat = new Categoria__c(Name='BASIC'); insert cat;
        Variedad__c var = new Variedad__c(Name='USG'); insert var;
        Product2 p1 = new Product2(Name='3810', Variedade__c=var.Id,Categ__c=cat.Id,Family='Royalty x Basica'); insert p1;
        Pricebook2 pb2 = new Pricebook2(Name='Portal Pricelist',isActive=true); insert pb2;
        
        PricebookEntry pStd_aux = new PricebookEntry(pricebook2Id=Test.getStandardPricebookId(), Product2Id=p1.id, UnitPrice=0, isActive=true, useStandardPrice=false); insert pStd_aux;
        PricebookEntry pbe = new PricebookEntry(Product2Id=p1.Id,UnitPrice=2,Pricebook2Id=pb2.Id,isActive=true); insert pbe;

        Opportunity opp1 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('AnexoI')),AccountId=acc.Id,Name='NEW',Safra__c='18/2018',Marca__c='GDM', CloseDate=system.today(),Stagename='Approved'); insert opp1;
        OpportunityLineItem opp1Item = new OpportunityLineItem(Sales_Report_Type__c='Production',Semente_uso_propio__c=200, Area_Plantada__c=10, Licensee_Variety_Name__c='JERE',Area__c=100,Prev_Parent__c=10,Prev_supply__c=100,Categoria__c=cat.Id,PricebookEntryId=pbe.Id,OpportunityId=opp1.Id,UnitPrice=1,Quantity=1); insert opp1Item;
      
        aSiteUtils.myOppRepItem[] lista = controller.tmpAppItems;

        controller.saveReport();
       
        lista = controller.tmpAppItems;


        controller.saveReport();
                
        pageRef.getParameters().put('e',opp1.Id);
        Test.setCurrentPageReference(pageRef);        

        controller.validate();                
        System.assertEquals(controller.validate(),null);
        controller.gotoEdit();
        

        controller.EditCancel();               
        controller.saveReport();
        controller.submitReport();
        
        pageRef.getParameters().put('t','fi');
        Test.setCurrentPageReference(pageRef);        
        controller = new aSiteProductionReportController ();
        controller.validate();
        
        pageRef.getParameters().put('t','up1');
        Test.setCurrentPageReference(pageRef);        
        controller = new aSiteProductionReportController ();
        controller.validate();
        
        controller.getRepItemsUpdate(); 
       
        
    }

    @IsTest (SeeAllData=false)
    global static void testProductionController2 () {

        aSiteProductionReportController controller = new aSiteProductionReportController ();
        
        
        Map<String,Id> rTypes = Opp_Utils.cargarRecordTypesOportunidades();
        Map<String,String> rTypesD = USAUtils.cargarRecordTypesOppbyDevName();
        
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', production_season__c='18/2018',Safra__c='18/2018',SiteUser__c=su.Id); insert susess;
        
        PageReference pageRef = new PageReference('/aSiteProductionReport');
        pageRef.getParameters().put('token',susess.Id);      
        pageRef.getParameters().put('t','fi');
        Test.setCurrentPageReference(pageRef);        
        
        //controller.validate();                
        //System.assertEquals(controller.validate(),null);
        
        Opportunity opp3 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('Production_Report')),AccountId=acc.Id,Name='NEW',Safra__c='18/2018',Marca__c='GDM', CloseDate=system.today(),Stagename='Editable'); insert opp3;
        controller.getProductionReport();
        controller.recId = 'aa';
        controller.setActiveOpp();
        controller.getProductionReport();
        
        Categoria__c cat = new Categoria__c(Name='BASIC'); insert cat;
        Variedad__c var = new Variedad__c(Name='USG'); insert var;
        Product2 p1 = new Product2(Name='3810', Variedade__c=var.Id,Categ__c=cat.Id,Family='Royalty x Basica'); insert p1;
        Pricebook2 pb2 = new Pricebook2(Name='Portal Pricelist',isActive=true); insert pb2;
        
        PricebookEntry pStd_aux = new PricebookEntry(pricebook2Id=Test.getStandardPricebookId(), Product2Id=p1.id, UnitPrice=0, isActive=true, useStandardPrice=false); insert pStd_aux;
        PricebookEntry pbe = new PricebookEntry(Product2Id=p1.Id,UnitPrice=2,Pricebook2Id=pb2.Id,isActive=true); insert pbe;

        Opportunity opp1 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('AnexoI')),AccountId=acc.Id,Name='NEW',Safra__c='18/2018',Marca__c='GDM', CloseDate=system.today(),Stagename='Approved'); insert opp1;
        OpportunityLineItem opp1Item = new OpportunityLineItem(Sales_Report_Type__c='Production',Area__c=100,Categoria__c=cat.Id,PricebookEntryId=pbe.Id,OpportunityId=opp1.Id,UnitPrice=1,Quantity=1); insert opp1Item;
      
        aSiteUtils.myOppRepItem[] lista = controller.tmpAppItems;

        controller.saveReport();
      
        Opportunity opp2 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('Production_Report')),AccountId=acc.Id,Name='NEW',Safra__c='18/2018',Marca__c='GDM', type='Production Update 1', CloseDate=system.today(),Stagename='Approved'); insert opp2;
        OpportunityLineItem opp2Item = new OpportunityLineItem(Sales_Report_Type__c='Production',Area__c=100,Categoria__c=cat.Id,PricebookEntryId=pbe.Id,OpportunityId=opp2.Id,UnitPrice=1,Quantity=1); insert opp2Item;
        
        pageRef.getParameters().put('t','up2');
        Test.setCurrentPageReference(pageRef);        
        controller = new aSiteProductionReportController ();
        controller.validate();
      
        controller.showConditioned();
        
        pageRef.getParameters().put('t','up3');
        Test.setCurrentPageReference(pageRef);        
        controller = new aSiteProductionReportController ();
        controller.validate();
        
        pageRef.getParameters().put('t','up4');
        Test.setCurrentPageReference(pageRef);        
        controller = new aSiteProductionReportController ();
        controller.validate();
        
        pageRef.getParameters().put('t','up5');
        Test.setCurrentPageReference(pageRef);        
        controller = new aSiteProductionReportController ();
        controller.validate();
      
    }
    
     @IsTest (SeeAllData=false)
    global static void testFinalProductionController () {
        
        aSiteProductionReportController controller = new aSiteProductionReportController ();
        controller.validate();
        
        Map<String,Id> rTypes = Opp_Utils.cargarRecordTypesOportunidades();
        Map<String,String> rTypesD = USAUtils.cargarRecordTypesOppbyDevName();
        
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', production_season__c='20/2020', Safra__c='18/2018',SiteUser__c=su.Id); insert susess;
        
        PageReference pageRef = new PageReference('/aSiteProductionReport');
        pageRef.getParameters().put('token',susess.Id);      
        pageRef.getParameters().put('t','fi');
        Test.setCurrentPageReference(pageRef);        
        
        controller.validate();                
        System.assertEquals(controller.validate(),null);
        
        Opportunity opp3 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('Production_Report')),type='Final Production Report',AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='DONMARIO',CloseDate=system.today(),Stagename='Editable'); insert opp3;
        controller.getProductionReport();
        controller.recId = 'aa';
        controller.setActiveOpp();
        controller.getProductionReport();
                
        controller.getUser();
        System.assertEquals(controller.getAccount().Name,'JERE');
        controller.getFields();
                
        controller.gotoNew();       
        
        Categoria__c cat = new Categoria__c(Name='BASIC'); insert cat;
        Variedad__c var = new Variedad__c(Name='USG'); insert var;
        Product2 p1 = new Product2(Name='3810', Variedade__c=var.Id,Categ__c=cat.Id,Family='Seed',Unidade__c='BAG 140K'); insert p1;
        Pricebook2 pb2 = new Pricebook2(Name='DONMARIO - WHOLESALE PriceList',isActive=true); insert pb2;
        
        PricebookEntry pStd_aux = new PricebookEntry(pricebook2Id=Test.getStandardPricebookId(), Product2Id=p1.id, UnitPrice=0, isActive=true, useStandardPrice=false); insert pStd_aux;
        PricebookEntry pbe = new PricebookEntry(Product2Id=p1.Id,UnitPrice=2,Pricebook2Id=pb2.Id,isActive=true); insert pbe;

        //Opportunity opp1 = new Opportunity(RecordTypeId=rTypes.get(rTypesD.get('AnexoI')),AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='DONMARIO', CloseDate=system.today(),Stagename='Approved'); insert opp1;
        OpportunityLineItem opp1Item = new OpportunityLineItem(Sales_Report_Type__c='Production',Semente_beneficiada__c=10,Area__c=100,Categoria__c=cat.Id,PricebookEntryId=pbe.Id,OpportunityId=opp3.Id,UnitPrice=1,Quantity=1); insert opp1Item;
      
        aSiteUtils.myOppRepItem[] lista = controller.tmpAppItems;

        controller.saveReport();
       
        lista = controller.tmpAppItems;
		
        controller.saveReport();
                
        //pageRef.getParameters().put('e',opp1.Id);
        //Test.setCurrentPageReference(pageRef);        

        controller.validate();                
        System.assertEquals(controller.validate(),null);
        controller.gotoEdit();

        controller.EditCancel();               
        controller.saveReport();
        controller.submitReport();
        
        opp3.StageName = 'Sent'; update opp3;
        
        pageRef.getParameters().put('t','fi');
        Test.setCurrentPageReference(pageRef);        
        controller = new aSiteProductionReportController ();
        controller.validate();
        
        controller.getRepItemsUpdate();
                    
        pageRef.getParameters().put('t','up2');
        Test.setCurrentPageReference(pageRef);        
        controller = new aSiteProductionReportController ();
        controller.validate();
      
        controller.showConditioned();
        
    }

}