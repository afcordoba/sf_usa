@isTest
public class gposGenerateOpportunitiesControllerTest {
	@isTest
	public static void getSummaryTextTest() {
		Variedad__c variety = new Variedad__c();
		variety.Name = 'DM37M3X';
		insert variety;
		Account acc = new Account();
		acc.Name = 'Test Name';
		insert acc;
		ContentVersion doc = new ContentVersion();
		doc.Title = 'Test Doc';
		doc.VersionData = Blob.valueOf(
			'Seller/Dealer ID;Seller/Dealer Name;Seller/Dealer Address;Address 2;Seller/Dealer City;Seller/Dealer State;Seller/Dealer Zip;Grower ID Number;License Number;Grower/Purchaser First Name;Grower/Purchaser Last Name;Farm Business Name;Grower/Purchaser Address 1;Grower/Purchaser Address 2;Grower/Purchaser City;Grower/Purchaser State;Grower/Purchaser Zip;Grower/Purchaser Phone No.;Email Address;Ship Date;Invoice Date;Invoice Number;Variety;Trait;Unit Total;Invoice Type\n' +
			'100200;Account Test Glb;10 Main Rd.;;New York;NY;31349;1234;123456;Horace;Doe;;321 Main St;;Springfield;TN;37073;;;6/1/2021;1/1/2021;1111;DM37M3X;E3;10;IV\n' +
			'100201;Account Test Glb;10 Main Rd.;;New York;NY;31349;;987654;Jhon;Doe;;321 Main St;;Springfield;TN;37073;;;7/1/2021;2/1/2021;1112;DM37M3X;RR2F;5;CM\n' +
			'100200;Account Test Glb;10 Main Rd.;;New York;NY;31349;1234;123456;Horace;Doe;;321 Main St;;Springfield;TN;37073;;;6/1/2021;1/1/2021;1111;DM37M3X;RR2X;3;RP'
		);
		doc.PathOnClient = doc.Title + '.xls';
		insert doc;
		gposUploadFileComponentController.generateTemps(doc.Id, acc.Id);
		Dealer_Summary__c ds = [SELECT Id FROM Dealer_Summary__c];
		Test.startTest();
		gposGenerateOpportunitiesController.resultWrapper result = gposGenerateOpportunitiesController.getSummaryText(
			ds.Id
		);
		Test.stopTest();

		System.assertEquals(
			'There are 2 temporary records with 3 varieties items.',
			result.message,
			'There were error generating the temps'
		);
	}

	@isTest
	public static void generateOppsTest() {
		Variedad__c variety = new Variedad__c();
		variety.Name = 'DM37M3X';
		insert variety;

		Pricebook2 pb = new Pricebook2(Id = Test.getStandardPricebookId());
		upsert pb;

		Categoria__c categ = new Categoria__c();
		categ.Name = 'PARENTAL';
		insert categ;

		Product2 prod = new Product2();
		prod.Name = 'Test Prod';
		prod.Variedade__c = variety.Id;
		prod.Unidade__c = 'BAG 140K';
		prod.Categ__c = categ.Id;
		insert prod;

		PricebookEntry pbe = new PricebookEntry();
		pbe.Product2Id = prod.Id;
		pbe.Pricebook2Id = pb.Id;
		pbe.UnitPrice = 1;
		pbe.IsActive = true;
		insert pbe;

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
		gposUploadFileComponentController.generateTemps(doc.Id, acc.Id);
		Dealer_Summary__c ds = [SELECT Id FROM Dealer_Summary__c];
		Test.startTest();
		gposGenerateOpportunitiesController.generateOpps(ds.Id);
		Test.stopTest();
		List<Opportunity> gposOpps = [SELECT Id FROM Opportunity];
		List<OpportunityLineItem> gposOppItems = [SELECT Id FROM OpportunityLineItem];
		System.assertEquals(2, gposOpps.size(), 'There were error generating the opportunities');
		System.assertEquals(3, gposOppItems.size(), 'There were error generating the products');
	}
}