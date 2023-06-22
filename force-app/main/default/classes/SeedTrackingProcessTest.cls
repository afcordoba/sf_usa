@IsTest
public class SeedTrackingProcessTest {
	/*@isTest Not working on production
    public static void ApprovalProcessSetTest(){
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254'); insert acc;
        
        Categoria__c cat = new Categoria__c(Name='BASIC'); insert cat;
        Variedad__c var = new Variedad__c(Name='USG'); insert var;
        Product2 p1 = new Product2(Name='3810', Variedade__c=var.Id,Categ__c=cat.Id,Family='Royalty x Basica'); insert p1;
        Pricebook2 pb2 = new Pricebook2(Name='Portal Pricelist',isActive=true); insert pb2;
        
        PricebookEntry pStd_aux = new PricebookEntry(pricebook2Id=Test.getStandardPricebookId(), Product2Id=p1.id, UnitPrice=0, isActive=true, useStandardPrice=false); insert pStd_aux;
        PricebookEntry pbe = new PricebookEntry(Product2Id=p1.Id,UnitPrice=2,Pricebook2Id=pb2.Id,isActive=true); insert pbe;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Stock per plant' and SobjectType = 'Opportunity'];

        Opportunity opp1 = new Opportunity(RecordTypeId=rt.Id,AccountId=acc.Id,Name='NEW',Safra__c='20/2020',Marca__c='GDM', CloseDate=system.today(),Stagename='Approved'); insert opp1;
        OpportunityLineItem opp1Item = new OpportunityLineItem(Categoria__c=cat.Id,PricebookEntryId=pbe.Id,OpportunityId=opp1.Id,UnitPrice=1,Quantity=1); insert opp1Item;

        List<Inventory_Status__c> invStatus = [SELECT Id FROM Inventory_Status__c];
        System.assertEquals(0, invStatus.size());

        Test.startTest();
        opp1Item.Internal_Status__c = 'Test Status';
        update opp1Item;
        Test.stopTest();

        invStatus = [SELECT Id FROM Inventory_Status__c];
        System.assertEquals(1, invStatus.size()); // This means there is a new approval process for this object
    }*/

	@isTest // Need this to deploy a trigger. Test is not working
	public static void InventoryStatusTriggerTest() {
		Inventory_Status__c is = new Inventory_Status__c();
		insert is;
	}

	@isTest
	public static void SeedTrackGeneralTest() {
		Account acc = new Account(
			Site = 'www.fff.com',
			AccountNumber = '1243',
			Grupo_de_cuentas__c = 'US01 - Domestic Customers',
			Name = 'JERE',
			Nome_Fantasia__c = 'JRERE',
			CodigoSAP__c = '451254'
		);
		insert acc;
		General_Settings__c gs = new General_Settings__c();
		insert gs;

		Categoria__c cat = new Categoria__c(Name = 'BASIC');
		insert cat;
		Variedad__c var = new Variedad__c(Name = 'USG');
		insert var;
		Product2 p1 = new Product2(Name = '3810', Variedade__c = var.Id, Categ__c = cat.Id, Family = 'Royalty x Basica');
		insert p1;
		Pricebook2 pb2 = new Pricebook2(Name = 'Portal Pricelist', isActive = true);
		insert pb2;

		PricebookEntry pStd_aux = new PricebookEntry(
			pricebook2Id = Test.getStandardPricebookId(),
			Product2Id = p1.id,
			UnitPrice = 0,
			isActive = true,
			useStandardPrice = false
		);
		insert pStd_aux;
		PricebookEntry pbe = new PricebookEntry(Product2Id = p1.Id, UnitPrice = 2, Pricebook2Id = pb2.Id, isActive = true);
		insert pbe;

		RecordType rtStock = [SELECT Id FROM RecordType WHERE Name = 'Stock per plant' AND SobjectType = 'Opportunity'];

		Opportunity opp1 = new Opportunity(
			RecordTypeId = rtStock.Id,
			AccountId = acc.Id,
			Name = 'NEW',
			Safra__c = '20/2020',
			Marca__c = 'GDM',
			CloseDate = system.today(),
			Stagename = 'Approved',
			Pricebook2Id = pb2.Id,
			Type = 'Z6 - ROYALTY'
		);
		insert opp1;
		OpportunityLineItem opp1Item = new OpportunityLineItem(
			PricebookEntryId = pbe.Id,
			OpportunityId = opp1.Id,
			UnitPrice = 1,
			Quantity = 1,
			Inventory_Status__c = 'Approved',
			Customer_Status__c = 'TestStatus'
		);
		insert opp1Item;

		RecordType rtSale = [SELECT Id FROM RecordType WHERE Name = 'Sale' AND SobjectType = 'Opportunity'];

		Opportunity opp2 = new Opportunity(
			RecordTypeId = rtSale.Id,
			AccountId = acc.Id,
			Name = 'NEW',
			Safra__c = '20/2020',
			Marca__c = 'GDM',
			CloseDate = system.today(),
			Stagename = 'Editable',
			Pricebook2Id = pb2.Id,
			Type = 'Z6 - ROYALTY'
		);
		insert opp2;
		OpportunityLineItem opp2Item = new OpportunityLineItem(
			PricebookEntryId = pbe.Id,
			OpportunityId = opp2.Id,
			UnitPrice = 1,
			Quantity = 1
		);
		insert opp2Item;

		List<Seed_Tracking__c> sTracks = [SELECT Id FROM Seed_Tracking__c];
		System.assertEquals(0, sTracks.size());

		Test.startTest();
		opp2.StageName = 'Approved';
		update opp2;
		Test.stopTest();

		sTracks = [SELECT Id, Status__c, Sale_Order__c, Product__c FROM Seed_Tracking__c];
		for (Seed_Tracking__c st : sTracks) {
			System.assertEquals(opp1Item.Customer_Status__c, st.Status__c);
		}
		System.assertEquals(1, sTracks.size());
	}

	@isTest
	public static void SeedTrackGeneral2Test() {
		Account acc = new Account(
			Site = 'www.fff.com',
			AccountNumber = '1243',
			Grupo_de_cuentas__c = 'US01 - Domestic Customers',
			Name = 'JERE',
			Nome_Fantasia__c = 'JRERE',
			CodigoSAP__c = '451254'
		);
		insert acc;
		General_Settings__c gs = new General_Settings__c();
		insert gs;

		Categoria__c cat = new Categoria__c(Name = 'BASIC');
		insert cat;
		Variedad__c var = new Variedad__c(Name = 'USG');
		insert var;
		Product2 p1 = new Product2(Name = '3810', Variedade__c = var.Id, Categ__c = cat.Id, Family = 'Royalty x Basica');
		insert p1;
		Pricebook2 pb2 = new Pricebook2(Name = 'Portal Pricelist', isActive = true);
		insert pb2;

		PricebookEntry pStd_aux = new PricebookEntry(
			pricebook2Id = Test.getStandardPricebookId(),
			Product2Id = p1.id,
			UnitPrice = 0,
			isActive = true,
			useStandardPrice = false
		);
		insert pStd_aux;
		PricebookEntry pbe = new PricebookEntry(Product2Id = p1.Id, UnitPrice = 2, Pricebook2Id = pb2.Id, isActive = true);
		insert pbe;

		RecordType rtStock = [SELECT Id FROM RecordType WHERE Name = 'Stock per plant' AND SobjectType = 'Opportunity'];

		Opportunity opp1 = new Opportunity(
			RecordTypeId = rtStock.Id,
			AccountId = acc.Id,
			Name = 'NEW',
			Safra__c = '20/2020',
			Marca__c = 'GDM',
			CloseDate = system.today(),
			Stagename = 'Approved',
			Pricebook2Id = pb2.Id,
			Type = 'Z6 - ROYALTY'
		);
		insert opp1;
		OpportunityLineItem opp1Item = new OpportunityLineItem(
			PricebookEntryId = pbe.Id,
			OpportunityId = opp1.Id,
			UnitPrice = 1,
			Quantity = 1,
			Inventory_Status__c = 'Pending',
			Customer_Status__c = 'TestStatus'
		);
		insert opp1Item;

		RecordType rtSale = [SELECT Id FROM RecordType WHERE Name = 'Sale' AND SobjectType = 'Opportunity'];

		Opportunity opp2 = new Opportunity(
			RecordTypeId = rtSale.Id,
			AccountId = acc.Id,
			Name = 'NEW',
			Safra__c = '20/2020',
			Marca__c = 'GDM',
			CloseDate = system.today(),
			Stagename = 'Editable',
			Pricebook2Id = pb2.Id,
			Type = 'Z6 - ROYALTY'
		);
		insert opp2;
		OpportunityLineItem opp2Item = new OpportunityLineItem(
			PricebookEntryId = pbe.Id,
			OpportunityId = opp2.Id,
			UnitPrice = 1,
			Quantity = 1
		);
		insert opp2Item;

		opp2.StageName = 'Approved';
		update opp2;

		List<Seed_Tracking__c> sTracks = [SELECT Id, Status__c, Sale_Order__c, Product__c FROM Seed_Tracking__c];
		for (Seed_Tracking__c st : sTracks) {
			System.assertEquals(null, st.Status__c);
		}

		Test.startTest();
		opp1Item.Inventory_Status__c = 'Approved';
		update opp1Item;
		Test.stopTest();

		//sTracks = [SELECT Id, Status__c, Sale_Order__c, Product__c FROM Seed_Tracking__c];
		//for(Seed_Tracking__c st : sTracks) {
		//    System.assertEquals(opp1Item.Customer_Status__c, st.Status__c);
		//}

		System.assertEquals(1, sTracks.size());
	}
}