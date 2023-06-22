global class aSiteHeaderController {

    private SiteUser__c logUser;
    public Account activeAccount {get;set;}
    public SiteUserSession__c activeSession {get;set;}
    
    public Boolean isLogged {get;set;}
    public String titulo1 {get;set;}
    public String titulo1Reb {get;set;}
    public String titulo2 {get;set;}
    public String titulo2Reb {get;set;}
    public String titulo3 {get;set;}
    public String titulo4 {get;set;}
    
    public String tituloFinalSalesRep {get;set;}
    public String tituloForeUpdate1 {get;set;}
    public String tituloForeUpdate2 {get;set;}
    public String tituloForeUpdate3 {get;set;}
    public String tituloForeUpdate4 {get;set;}
   
    public String tituloProdUpdate1 {get;set;}
    public String tituloProdUpdate2 {get;set;}
    public String tituloProdUpdate3 {get;set;}
    public String tituloProdUpdate4 {get;set;}
    public String tituloProdUpdate5 {get;set;}
    public String tituloProdFinal {get;set;}

    public String linkDataAnalytics {get;set;}
    
    private Map<String,String> rTypes;
    public String gposTemplateLink {get;set;}
    public String language {get;set;}
     
    global aSiteHeaderController(){
        String pn = getVFPageName();
        //'aSiteLogin', 'aSiteActionConfirmation' , 'aSiteChangePass', 'aSiteForgotPass', 'aSiteForgotPassConfirm'
        language = [select id, LanguageLocaleKey from User where id =: UserInfo.getUserId()].LanguageLocaleKey;
        
        validate();
        if((pn == 'aSiteHome' || pn == 'aSiteProfile' || pn == 'aSiteAppendix1' || pn == 'aSiteAppendix2' 
        || pn == 'aSiteContracts' || pn == 'aSiteSalesReportEdit2' || pn == 'aSiteProfileEdit'
        || pn == 'aSiteSalesReportEdit' || pn == 'aSiteProductionReportEdit' || pn == 'aSiteSalesReport' 
        || pn == 'aSiteProductionReport' || pn == 'aSiteSeedTracking' || pn == 'aSiteUploadFile') && validate()){
            isLogged = true;
        }
        rTypes = USAUtils.cargarRecordTypesOppbyDevName();

        titulo1 = rTypes.get('AnexoI');    
        
        tituloFinalSalesRep = 'Final Sales Report'; //rTypes.get('Sales_Report');
        tituloForeUpdate1 = 'Sales Forecast Update 1';
        tituloForeUpdate2 = 'Sales Forecast Update 2';
        tituloForeUpdate3 = 'Sales Forecast Update 3';
        tituloForeUpdate4 = 'Sales Forecast Update 4';
        
        tituloProdFinal = 'Final Production Report';
        tituloProdUpdate1 = 'Production Update 1';
        tituloProdUpdate2 = 'Production Update 2';
        tituloProdUpdate3 = 'Production Update 3';
        tituloProdUpdate4 = 'Production Update 4';
        tituloProdUpdate5 = 'Production Update 5';

        linkDataAnalytics = aAppManager.getLinkDataAnalytics();

        List<ContentDocument> doc = [SELECT Id FROM ContentDocument WHERE Title = 'Partner GPOS Template'];
        if(doc.size() > 0)
            gposTemplateLink =  '/sfc/servlet.shepherd/document/download/' + doc[0].Id;
    }
    
    public SiteUser__c getUser(){
        return logUser;
    }
    public String getBrand(){
        return activeSession.Marca__c;
    }
    
    public boolean validate() {
        
        String token = System.currentPageReference().getParameters().get('token');
        if(token!=null){
            logUser = aSiteAuthManager.VerifyUserSession(token);
            if(logUser!=null){
                activeSession = aSiteAuthManager.getUserSession(token);
                activeAccount = aSiteAuthManager.getActiveAccount_byUser(logUser);                
                return true;  
            }          
        }
        return false;
    }

    public string getVFPageName() {
        String pageName = ApexPages.CurrentPage().getUrl();
        pageName = pageName.replaceFirst('/apex/', '');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        string[] pageNameExtra = pageName.split('%3F', 0);    
        pageName = pageNameExtra[0];
    
        system.debug('pageName-->' + pageName);        
        return pageName;
    }

    // -*--------------------- Sales Reports ------------------------------------------------------------------
       
    public PageReference gotoSalesForeUpdate1Report(){
        PageReference pr;
        String type = 'Sales Forecast Update 1';
        Opportunity[] relatedApp = aAppManager.getSalesReportOpp(activeAccount.Id, activeSession.Sales_Season__c, activeSession.Marca__c, type);        
        if(relatedApp.size()==0)
            pr = new PageReference('/apex/aSiteSalesReportEdit');
        else
            pr = new PageReference('/apex/aSiteSalesReport');
        return setParamLog(pr,type,'up1');
    }
    public PageReference gotoSalesForeUpdate2Report(){
        PageReference pr;
        String type = 'Sales Forecast Update 2';
        Opportunity[] relatedApp = aAppManager.getSalesReportOpp(activeAccount.Id, activeSession.Sales_Season__c, activeSession.Marca__c, type);        
        if(relatedApp.size()==0)
            pr = new PageReference('/apex/aSiteSalesReportEdit');
        else
            pr = new PageReference('/apex/aSiteSalesReport');
        return setParamLog(pr,type,'up2');
    }    
    public PageReference gotoSalesUpdate3Report(){
        PageReference pr;
        String type = 'Sales Forecast Update 3';
        Opportunity[] relatedApp = aAppManager.getSalesReportOpp(activeAccount.Id, activeSession.Sales_Season__c, activeSession.Marca__c, type);        
        if(relatedApp.size()==0)
            pr = new PageReference('/apex/aSiteSalesReportEdit');
        else
            pr = new PageReference('/apex/aSiteSalesReport');
        return setParamLog(pr,type,'up3');
    }     
    public PageReference gotoSalesUpdate4Report(){
        PageReference pr;
        String type = 'Sales Forecast Update 4';
        Opportunity[] relatedApp = aAppManager.getSalesReportOpp(activeAccount.Id, activeSession.Sales_Season__c, activeSession.Marca__c, type);        
        if(relatedApp.size()==0)
            pr = new PageReference('/apex/aSiteSalesReportEdit');
        else
            pr = new PageReference('/apex/aSiteSalesReport');
        return setParamLog(pr,type,'up4');
    }     
    public PageReference gotoSalesReport(){      
        PageReference pr;
        String type = 'Final Sales Report';
        Opportunity[] relatedApp = aAppManager.getSalesReportOpp(activeAccount.Id, activeSession.Sales_Season__c, activeSession.Marca__c, type);        
        if(relatedApp.size()==0)
            pr = new PageReference('/apex/aSiteSalesReportEdit');
        else
            pr = new PageReference('/apex/aSiteSalesReport');        
        return setParamLog(pr,type,'fi');
    } 
    
    private PageReference setParamLog(PageReference pr, String type, String code){
        String token = System.currentPageReference().getParameters().get('token');      
        pr.setRedirect(true);    
        pr.getParameters().put('token',token);
        pr.getParameters().put('t',code);
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, type + ', ');
        return pr;
    }
    
    // *-----------------------Production Reports -------------------------------------------------------------
    
    public PageReference gotoProd1Report(){       
        String type = 'Production Update 1';
        PageReference pr;
        if(aAppManager.getProductionReportOpp(activeAccount.Id, activeSession.Production_season__c, activeSession.Marca__c, type).size()==0)
            pr = new PageReference('/apex/aSiteProductionReportEdit');        
        else
            pr = new PageReference('/apex/aSiteProductionReport');
        
        return setParamLog(pr,type,'up1');        
    }
    public PageReference gotoProd2Report(){
        String token = System.currentPageReference().getParameters().get('token');
        String type = 'Production Update 2';
        PageReference pr;
        if(aAppManager.getProductionReportOpp(activeAccount.Id, activeSession.Production_season__c, activeSession.Marca__c, type).size()==0){
            pr = new PageReference('/apex/aSiteProductionReportEdit');
        }
        else{
            pr = new PageReference('/apex/aSiteProductionReport');
        }        
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Production 2, ');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        pr.getParameters().put('t','up2');
        return pr;
    }
    public PageReference gotoProd3Report(){
        String token = System.currentPageReference().getParameters().get('token');
        String type = 'Production Update 3';
        String season = activeSession.Sales_Season__c;
        PageReference pr;
        
        if(activeSession.Marca__c == 'DONMARIO')
            season = activeSession.Production_season__c;            
        if(aAppManager.getProductionReportOpp(activeAccount.Id, Season, activeSession.Marca__c, type).size()==0){
            pr = new PageReference('/apex/aSiteProductionReportEdit');
        }
        else{
            pr = new PageReference('/apex/aSiteProductionReport');
        }
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Production 3, ');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        pr.getParameters().put('t','up3');
        return pr;
    }
    public PageReference gotoProd4Report(){
        String token = System.currentPageReference().getParameters().get('token');
        String type = 'Production Update 4';
        String season = activeSession.Sales_Season__c;
        PageReference pr;
        if(activeSession.Marca__c == 'DONMARIO')
            season = activeSession.Production_season__c;
        if(aAppManager.getProductionReportOpp(activeAccount.Id, Season, activeSession.Marca__c, type).size()==0){
            pr = new PageReference('/apex/aSiteProductionReportEdit');
        }
        else{
            pr = new PageReference('/apex/aSiteProductionReport');
        }
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Production 4, ');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        pr.getParameters().put('t','up4');
        return pr;
    }
    public PageReference gotoProd5Report(){
        String token = System.currentPageReference().getParameters().get('token');
        String type = 'Production Update 5';
        PageReference pr;
        if(aAppManager.getProductionReportOpp(activeAccount.Id, activeSession.Safra__c, activeSession.Marca__c, type).size()==0){
            pr = new PageReference('/apex/aSiteProductionReportEdit');
        }
        else{
            pr = new PageReference('/apex/aSiteProductionReport');
        }
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Production 5, ');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        pr.getParameters().put('t','up5');
        return pr;
    }
    
    public PageReference gotoProdFinalReport(){
        String token = System.currentPageReference().getParameters().get('token');
        String type = 'Final Production Report';
        PageReference pr;
        if(aAppManager.getProductionReportOpp(activeAccount.Id, activeSession.Sales_Season__c, activeSession.Marca__c, type).size()==0){
            pr = new PageReference('/apex/aSiteProductionReportEdit');
        }
        else{
            pr = new PageReference('/apex/aSiteProductionReport');
        }
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Production Final, ');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        pr.getParameters().put('t','fi');
        return pr;
    }    
        
    public PageReference gotoDashboard(){
        String token = System.currentPageReference().getParameters().get('token');
        PageReference pr = new PageReference('/apex/aSiteHome');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Dashboard, ');
        return pr;
    }
    
    public PageReference gotoSeedTracking(){
        String token = System.currentPageReference().getParameters().get('token');
        PageReference pr = new PageReference('/apex/aSiteSeedTracking');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);        
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Seed Order Tracking, ');        
        return pr;
    }

    public PageReference gotoAppend1(){
        String token = System.currentPageReference().getParameters().get('token');
        PageReference pr = new PageReference('/apex/aSiteAppendix1');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        return pr;
    }
    
    public PageReference gotoDataAnalytics(){
        String token = System.currentPageReference().getParameters().get('token');
        PageReference page = new PageReference(linkDataAnalytics+getUser().Id + '&autologin_pass=' + getUser().Password__c);
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'DataAnalytics, ');
        return page;
    }
        
    public PageReference gotoProfile(){
        String token = System.currentPageReference().getParameters().get('token');
        PageReference pr = new PageReference('/apex/aSiteProfile');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Profile, ');
        return pr;
    }

    public PageReference gotoContract(){
        String token = System.currentPageReference().getParameters().get('token');
        PageReference pr = new PageReference('/apex/aSiteContracts');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        return pr;
    }
    
    public PageReference closeSession(){
        String comp;
        String token = System.currentPageReference().getParameters().get('token');
        if(activeSession!=null)
            comp = activeSession.Marca__c;
        else
            comp = System.currentPageReference().getParameters().get('comp');
                
        String ret = token;
        ret = aSiteAuthManager.CloseUserSession(token);
        PageReference pr = Page.aSiteActionConfirmation;
        pr.getParameters().put('comp',comp);
        pr.setRedirect(true);
        if (ret == 'Ok') {
            return pr;
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,ret));
        return null;
    }

    /*public PageReference gotoDownloadTemplate(){
        String token = System.currentPageReference().getParameters().get('token');
        
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        return pr;
    }*/

    public PageReference gotoUploadFile(){
        String token = System.currentPageReference().getParameters().get('token');
        PageReference pr = new PageReference('/apex/aSiteUploadFile');
        pr.setRedirect(true);
        pr.getParameters().put('token',token);
        return pr;
    }
}