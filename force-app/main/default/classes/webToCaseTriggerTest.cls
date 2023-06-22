/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class webToCaseTriggerTest {
    @IsTest(SeeAllData=true) global static void test1() {
        SiteUser__c user = new SiteUser__c(Name='Jeremias',Password__c='123', Email__c='j@gom.com'); insert user;
        
        Case c = new Case();
        c.SiteUser__c = user.Id;
        c.Subject = '123456';
        
        insert c;
    }    
}