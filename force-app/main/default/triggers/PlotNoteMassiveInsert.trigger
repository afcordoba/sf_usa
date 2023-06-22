trigger PlotNoteMassiveInsert on Mass_Plot_Note__c (after Insert) {

    List<Mass_Plot_Note__c> n = new List<Mass_Plot_Note__c>();    
    n = [Select Id, SiteUser__c, Name, Plot_Location__c,  Explore_Rating__c, Date__c, Value__c from Mass_Plot_Note__c Where Id IN :trigger.new ];   
    
    PlotNoteExecutionBO.getInstance().executeNoteMassUpdate(n);
    
}