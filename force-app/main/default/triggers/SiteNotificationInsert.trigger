trigger SiteNotificationInsert on SiteNotification__c (after insert) {    
    List<SiteNotification__c> n = new List<SiteNotification__c>();    
    n = [Select Id, Category__c, Topic__c, Account__c, Siteuser__c, Siteuser__r.New_Siteuser_Request_Approver__c, Name, Plot_Location__r.Plot_Location_Region__c, RecipientProfile__r.Access_Reporting_Section__c, RecipientProfile__r.Access_Business_Section__c, RecipientProfile__r.Access_Products_Section__c from SiteNotification__c Where Id IN :trigger.new ];   
    SiteNotificationBO.getInstance().executePushingNotification(n);       
}