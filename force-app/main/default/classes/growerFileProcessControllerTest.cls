@isTest
public class growerFileProcessControllerTest {

    @isTest
    public static void growerFileProcessControllerTest() {
        ContentVersion doc = new ContentVersion();
        doc.Title = 'Test Doc';
        doc.VersionData = doc.VersionData = Blob.valueOf('Grower ID,License ID,Trait Provider,Agcelerate ID,Email,PhoneNumber,FarmName,FirstName,MiddleName,LastName,SuffixName,AddressLine1,AddressLine2,City,State,Zip,License ID,Trait Provider,License ID,Trait Provider\n'+
        '518146,Syngenta1,Syngenta,asdf,angel.bedetti@gmail.com,1123345613,Angel Farm,Angel,G,Bedetti,,Av Rivadavia,Yatay,BA,TN,1033,Bayer47,Bayer,Corteva1,Corteva');
        doc.PathOnClient  = doc.Title + '.xls';
        insert doc;

        Test.startTest();
        growerFileProcessController.generateGrowers(doc.Id);
        Test.stopTest();

        List<Account> accs = [SELECT Id FROM Account];
        List<Trait_Provider_License_ID__c> licences = [SELECT Id, Account__c FROM Trait_Provider_License_ID__c];

        System.assertEquals(1, accs.size());
        System.assertEquals(2, licences.size());
        for(Trait_Provider_License_ID__c lic : licences) {
            System.assertEquals(accs[0].Id, lic.Account__c);
        }
    }
}