@isTest
public class gposDownloadFileComponentControllerTest {
    @isTest
    public static void gposDownloadFileComponentControllerTest() {
        Account activeAccount = new Account();
        activeAccount.Name = 'Angel Bedetti Test';
        insert activeAccount;
        GPOS_Customer_Report__c report = new GPOS_Customer_Report__c();
        report.Account__c = activeAccount.Id;
        report.Name = 'Test';
        report.Document__c = 'urlToDownload';
        report.Type__c = 'Customer';
        insert report; 

        Test.startTest();
        List<gposDownloadFileComponentController.FileWrapper> files = gposDownloadFileComponentController.getFiles(activeAccount.Id);
        Test.stopTest();
        System.assertEquals(1, files.Size());
    }
}