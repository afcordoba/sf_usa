@isTest
public class gposUploadFileComponentControllerTest {
	@isTest
	public static void gposUploadFileComponentControllerTest() {
		Variedad__c variety = new Variedad__c();
		variety.Name = 'DM37M3X';
		insert variety;
		Account acc = new Account();
		acc.Name = 'Test Name';
		insert acc;
		ContentVersion doc = new ContentVersion();
		doc.Title = 'Test Doc';
		doc.VersionData = doc.VersionData = Blob.valueOf(
			'Seller/Dealer ID;Seller/Dealer Name;Seller/Dealer Address;Address 2;Seller/Dealer City;Seller/Dealer State;Seller/Dealer Zip;Grower ID Number;License Number;Grower/Purchaser First Name;Grower/Purchaser Last Name;Farm Business Name;Grower/Purchaser Address 1;Grower/Purchaser Address 2;Grower/Purchaser City;Grower/Purchaser State;Grower/Purchaser Zip;Grower/Purchaser Phone No.;Email Address;Ship Date;Invoice Date;Invoice Number;Variety;Trait;Unit Total;Invoice Type\n' +
			'100200;Account Test Glb;10 Main Rd.;;New York;NY;31349;1234;123456;Horace;Doe;;321 Main St;;Springfield;TN;37073;;;6/1/2021;1/1/2021;1111;DM37M3X;E3;10;IV\n' +
			'100201;Account Test Glb;10 Main Rd.;;New York;NY;31349;;987654;Jhon;Doe;;321 Main St;;Springfield;TN;37073;;;7/1/2021;2/1/2021;1112;DM37M3X;RR2F;5;CM\n' +
			'100200;Account Test Glb;10 Main Rd.;;New York;NY;31349;1234;123456;Horace;Doe;;321 Main St;;Springfield;TN;37073;;;6/1/2021;1/1/2021;1111;DM37M3X;RR2X;3;RP'
		);
		doc.PathOnClient = doc.Title + '.xls';
		insert doc;

		Test.startTest();
		gposUploadFileComponentController.generateTemps(doc.Id, acc.Id);
		Test.stopTest();

		Dealer_Summary__c ds = [SELECT Id FROM Dealer_Summary__c];
		List<GPOS_Grower_Temp__c> grTemp = [SELECT Id FROM GPOS_Grower_Temp__c WHERE Dealer_Summary__c = :ds.Id];
		System.assertEquals(2, grTemp.size(), 'This file should create 2 temps');
	}
}