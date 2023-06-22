@isTest
private class SiteNotification_TriggerTest {

    static testmethod void test(){
        SiteUserProfile__c p = new SiteUserProfile__c(Name='Full',Access_Business_Section__c=true,Access_Reporting_Section__c=true,Access_Products_Section__c=true);        
        insert p;
        
        SiteNotification__c c = new SiteNotification__c(Name='TEST',RecipientProfile__c=p.Id);
        insert c;
        
        Macroregion__c m = new Macroregion__c(Name='SCB');
        insert m;
        County__c co = new County__c(Name='TEST', Macroregion__c=m.Id);
        insert co;
        Location__c l = new Location__c(Name='TES',County__c=co.Id);
        insert l;
        Plot_location__c pl = new Plot_location__c(Location__c=l.Id, Name='TEST');
        insert pl;
        Account a = new Account(Name='TEST A', Location__c=l.Id);
        insert a;
        
        SiteUser__c user = new SiteUser__c(Email__c='j@mil.com',Notification_Bean_Blog__c=true, Notification_Visit__c=true, Password__c='df',Name='JERE',Brand_GDM__c=true,Status__c='Approved',SiteUserProfile__c=p.Id, Account__c=a.Id);
        insert user;
        
        SiteNotification__c c2 = new SiteNotification__c(Name='TEST2',Plot_location__c=pl.Id,RecipientProfile__c=p.Id,Category__c='Bean Blog Post');
        insert c2;
        
        SiteNotification__c c3 = new SiteNotification__c(Name='TEST2',Plot_location__c=pl.Id,RecipientProfile__c=p.Id,Category__c='GDM Explore Visit Reminder',SiteUser__c=user.Id, Account__c=a.Id);
        insert c3;
    }  
}