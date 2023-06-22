@isTest
public class aSiteUploadFileControllerTest {
    @isTest
    public static void aSiteUploadFileControllerTest() {
        aSiteUploadFileController controller = new aSiteUploadFileController();
        controller.csvFile.Title = 'Partner GPOS Template';
        controller.csvFile.VersionData = Blob.valueOf('1234');
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        SiteUser__c su = new SiteUser__c(Email__c='jere@dm.com', Password__c='123456'); insert su;
        SiteUserAccount__c suacc = new SiteUserAccount__c(SiteUser__c=su.Id,Account__c=acc.Id, Active__c=true); insert suacc;
        SiteUserSession__c susess = new SiteUserSession__c(Marca__c='GDM', Safra__c='18/2018',SiteUser__c=su.Id); insert susess;
        PageReference pageRef = Page.aSiteUploadFile;
        pageRef.getParameters().put('token',susess.Id);      
        Test.setCurrentPageReference(pageRef);

        Test.startTest();
        controller.validate();
        controller.doUpload();
        Test.stopTest();

        List<GPOS_Customer_Report__c> reports = [SELECT Id, Name FROM GPOS_Customer_Report__c];
        System.assertEquals(1, reports.size(), 'There should be only 1 GPOS Report/File but there are ' + reports.size());
        System.assertNotEquals(controller.csvFile.Title, reports[0].Name, 'Name should have change');
        
    }
}