trigger PlotNoteScoreInsert on Explore_Plot_Note_Score__c (after insert) {

    List<Explore_Plot_Note_Score__c> n = new List<Explore_Plot_Note_Score__c>();    
    n = [Select Id, Name, Explore_Rating__c, Explore_Rating__r.Name, Date__c, Score_Value__c, Plot_Note__c, Plot_Note__r.Plot_Cell__c, 
        Plot_Note__r.Plot_Cell__r.Explore_Plot__c, Plot_Note__r.Plot_Cell__r.Explore_Plot__r.Id, Plot_Note__r.SiteUser__c, Plot_Note__r.SiteUser__r.Id
        from Explore_Plot_Note_Score__c Where Id IN :trigger.new ];   
    
    PlotNoteExecutionBO.getInstance().executeStartNoteMassUpdate(n);
    
}