public class SiteNotificationBO {

    private static final SiteNotificationBO instance = new SiteNotificationBO();    
    private SiteNotificationBO(){}
    
    public static SiteNotificationBO getInstance() {
        return instance;
    }
    
    public void executePushingNotification(List<SiteNotification__c> objToProcessing) {
            
        List<SiteNotificationRecipient__c> recs = new List<SiteNotificationRecipient__c>();
        List<SiteUser__c> users = new List<SiteUser__c>();
                
        for(SiteNotification__c n : objToProcessing )
        {
            if(n.Category__c == 'Bean Blog Post')
                users = queryUsersBeanBlog(n);
            else if(n.Category__c == 'GDM Explore Visit Reminder')
                users = queryUsersVisitInvitationReminder(n);     
            else if(n.Category__c == 'GDM Explore Invitation Created')
                users = queryUsersInvitation(n);
            else if(n.Category__c == 'GDM Explore Invitation Answer')
                users = queryUsersInvitation(n);
            else if(n.Category__c == 'GDM Explore Visit Canceled Harvest')
                users = queryUsersVisits(n); 
            else if(n.Category__c == 'GDM Explore New User Approval Request')
                users = queryUsersRequestApproval(n);

            for(SiteUser__c u : users){
                SiteNotificationRecipient__c r = new SiteNotificationRecipient__c();
                r.SiteNotification__c = n.Id;
                r.SiteUser__c = u.Id;
                r.Status__c = 'Unseen';
                recs.add(r);
            }
        }    
        insert recs;    
    }
    
    public List<SiteUser__c> queryUsersBeanBlog( SiteNotification__c n) {
        String fn1; String filters=''; String region = '';

        
        // user status 
        //filters = 'and Status__c = \'Approved\'' + filters;
        
        //user brand accesses
        fn1 = 'Brand_GDM__c = true ' + 'and Status__c = \'Approved\''; 
    
        // user blog notifications ON per Region
        if(n.Plot_Location__c!=null && n.Topic__c != 'PRODUCTION'){    
            region = n.Plot_Location__r.Plot_Location_Region__c;        
            if(region!='')
                fn1 = fn1 + ' and Notification_Blog_Post_Regions__c includes (\'' + region + '\')';
        }
        
        System.debug('JERE:::NOTIF ' + fn1);        
        
        List<SiteUser__c> users = Database.query(aSiteUtils.queryFromSObject(SiteUser__c.SObjectType,null) + ' where ' + fn1 + ' Order By Name');
        return users;
    }
    
    public List<SiteUser__c> queryUsersRequestApproval( SiteNotification__c n) {
        String fn1; String filters=''; String region = '';
        
        // approver user id 
        filters = 'Id = \'' + n.SiteUser__r.New_Siteuser_Request_Approver__c + '\'';
        
        fn1 = filters;
        
        System.debug('JERE:::' + fn1);        
        
        List<SiteUser__c> users = Database.query(aSiteUtils.queryFromSObject(SiteUser__c.SObjectType,null) + ' where ' + fn1 + ' Order By Name');
        return users;        
    }
    
    public List<SiteUser__c> queryUsersVisitInvitationReminder( SiteNotification__c n) {
        String fn1; String filters=''; String region = '';
        
        // user status 
        filters = 'Status__c = \'Approved\' and Id = \'' + n.SiteUser__c + '\'';
        
        //user blog notifications ON
        fn1 = filters + ' and Notification_Visit_Reminder__c = true';
        
        System.debug('JERE:::' + fn1);        
        
        List<SiteUser__c> users = Database.query(aSiteUtils.queryFromSObject(SiteUser__c.SObjectType,null) + ' where ' + fn1 + ' Order By Name');
        return users;        
    }
 
    public List<SiteUser__c> queryUsersVisits( SiteNotification__c n) {
        String fn1; String filters=''; String region = '';
        
        // user status 
        filters = 'Status__c = \'Approved\' and Id = \'' + n.SiteUser__c + '\'';
        
        //user blog notifications ON
        if(n.Category__c=='GDM Explore Visit Canceled Harvest')
            fn1 = filters + ' and Notification_Visit_Cancellation__c = true';
            
        //else if(n.Category__c=='GDM Explore Invitation Answer')
        //    fn1 = filters + ' and Notification_Invitation_Response__c = true';
            
        System.debug('JERE:::' + fn1);        
        
        List<SiteUser__c> users = Database.query(aSiteUtils.queryFromSObject(SiteUser__c.SObjectType,null) + ' where ' + fn1 + ' Order By Name');
        return users;        
    }
       
    public List<SiteUser__c> queryUsersInvitation( SiteNotification__c n) {
        String fn1; String filters=''; String region = '';
        
        // user status 
        filters = 'Status__c = \'Approved\' and Id = \'' + n.SiteUser__c + '\'';
        
        //user blog notifications ON
        if(n.Category__c=='GDM Explore Invitation Created')
            fn1 = filters + ' and Notification_Visit_Invitation__c = true';
        else if(n.Category__c=='GDM Explore Invitation Answer')
            fn1 = filters + ' and Notification_Invitation_Response__c = true';
        
        System.debug('JERE:::' + fn1);        
        
        List<SiteUser__c> users = Database.query(aSiteUtils.queryFromSObject(SiteUser__c.SObjectType,null) + ' where ' + fn1 + ' Order By Name');
        return users;        
    }
    
    public List<SiteUser__c> queryUsersHarvest( SiteNotification__c n) {
        String fn1; String filters=''; String region = '';
        
        // user status 
        filters = 'Status__c = \'Approved\'';
        
        //user blog notifications ON
        fn1 = filters + ' and Admin__c = true and Notification_Visit__c = true';
        
        System.debug('JERE:::' + fn1);        
        
        List<SiteUser__c> users = Database.query(aSiteUtils.queryFromSObject(SiteUser__c.SObjectType,null) + ' where ' + fn1 + ' Order By Name');
        return users;        
    }
    
}