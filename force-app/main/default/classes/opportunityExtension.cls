Public class opportunityExtension{

   public opportunityExtension(ApexPages.StandardController controller) {
   }

//   public String searchTextAnexo {get; set;}
//   public List<Opportunity> resultAnexos = new List<Opportunity>();
//   public String anexo {get; set;}
//   public String etapaAnexo;
//   private String rt_anexoI_opps;   
//   private String rt_salesRep_opps;
//   private String rt_prodRep_opps;
   
   public opportunityExtension(){    
   //    searchTextAnexo = '';
      
       /*for (RecordType rt : [Select Id, DeveloperName, Name From RecordType]){
           if (rt.DeveloperName == 'AnexoI')
              rt_anexoI_opps = rt.Id;           
           if (rt.DeveloperName == 'Sales_Report')
              rt_salesRep_opps = rt.Id;
           if (rt.DeveloperName == 'Production_Report')
              rt_prodRep_opps = rt.Id;
       }*/
   }
   
/*   public void setetapaAnexo(String arg){
       etapaAnexo = arg;
   }

   public String getetapaAnexo(){
       Profile pro = [Select Name From Profile Where Id = : UserInfo.getProfileId()];       
       if (pro.Name == 'Administrador del sistema' || pro.Name == 'Gerente Administrativo')
           etapaAnexo = 'PEAP';
       if (pro.Name == 'Comercial')
           etapaAnexo = 'PEAN';    
       if (pro.Name == 'Administrativo')
           etapaAnexo = 'APR';    
   
       return etapaAnexo;
   }
       
   public List<Opportunity> getresultAnexos() {return resultAnexos;}    
   
   public List<SelectOption> getTiposAnexos() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('ALL','--Todos--'));
       options.add(new SelectOption('A1','Anexo I'));
       return options;
   }
   
   public List<SelectOption> getEtapasAnexos() {        
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('ALL','--Todas--'));
       options.add(new SelectOption('PEAN','Pendiente de Analisis'));
       options.add(new SelectOption('PEAP','Pendiente de Aprobacion'));
       options.add(new SelectOption('APR','Aprobada'));      
       
       return options;
   }
   
   public void listarAnexos(){
       resultAnexos = null;
       this.searchAnexos();       
   }
   
   public void searchAnexos(){
       String s = searchTextAnexo;
       
       String qry = 'select Id, Name, StageName, Safra__c, CloseDate, Account.Id, Account.Name, RecordType.Name, RecordType.DeveloperName, LastModifiedDate From Opportunity ';
       
       qry += 'where OwnerId != null ';
       if (anexo == 'A1')
           qry += ' and RecordTypeId = : rt_anexoI_opps ';
       if (etapaAnexo == 'PEAN')
           qry += ' and StageName = \'Pendiente de Análisis\'';    
       if (etapaAnexo == 'PEAP')
           qry += ' and StageName = \'Pendiente de Aprobación\'';    
       if (etapaAnexo == 'APR')
           qry += ' and StageName = \'Aprobada\'';                   
                       
       if(s != ''){ s = '%' + s + '%'; qry += ' and Name like : s';}
       qry += ' Order by Safra__c Desc, LastModifiedDate Desc';
       resultAnexos = Database.query(qry);
   }
  */
      
   public List<OpportunityLineItem> getItems() {
       String query = 'SELECT ';
       for(Schema.FieldSetMember f : this.getFields()) {
           query += f.getFieldPath() + ', ';
       }
       query += 'Id FROM OpportunityLineItem Where OpportunityId = \'' + apexpages.currentpage().getparameters().get('id') + '\' Order by Variedade_Prod__c';
       return Database.query(query);
   }
   
   public List<Schema.FieldSetMember> getFields() {
        Opportunity o = [Select RecordType.DeveloperName From Opportunity Where Id = : apexpages.currentpage().getparameters().get('id')];
        
        if (o.RecordType.DeveloperName == 'Sales_Report')
            return SObjectType.OpportunityLineItem.FieldSets.Sales_Report.getFields();
        if (o.RecordType.DeveloperName == 'Production_Report')
            return SObjectType.OpportunityLineItem.FieldSets.Production_Forecast_Report.getFields();        
        if (o.RecordType.DeveloperName == 'AnexoI')        
            return SObjectType.OpportunityLineItem.FieldSets.Anexo_I.getFields();
        if (o.RecordType.DeveloperName == 'Parental_Sale')        
            return SObjectType.OpportunityLineItem.FieldSets.Parental_Sale.getFields();
           return null;                      
   }   
}