@isTest
private class OpportunityTriggerTest {
	@TestSetup
	static void makeData() {
		Pricebook2 pricebook = Build.aPricebook2().withBrand('GDM').withName('Pricebook GDM').withIsActive(true).build();
		insert pricebook;
		Pricebook2 pricebookWholesale = Build.aPricebook2()
			.withBrand('GDM')
			.withName('DONMARIO - WHOLESALE PriceList')
			.withIsActive(true)
			.build();
		insert pricebookWholesale;

		Pricebook2 pricebookRoyalty = Build.aPricebook2()
			.withBrand('GDM')
			.withName('TRADEMARK Fee PriceList')
			.withIsActive(true)
			.build();
		insert pricebookRoyalty;

		Variedad__c variety = Build.aVariedad().withName('Variety').build();
		insert variety;
		Product2 aProduct = Build.aProduct2()
			.withName('Product 1')
			.withIsActive(true)
			.withVariedade(variety)
			.withUNIDADE('BAG 140K')
			.build();
		insert aProduct;
		PricebookEntry pbeOneStndr = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(Test.getStandardPricebookId())
			.withProduct2Id(aProduct)
			.withUnitPrice(1)
			.build();
		insert pbeOneStndr;
		PricebookEntry pbeOneGdm = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(pricebook)
			.withProduct2Id(aProduct)
			.withUnitPrice(1)
			.build();
		insert pbeOneGdm;
		Product2 aRoyaltyProduct = Build.aProduct2()
			.withName('Product 1')
			.withIsActive(true)
			.withFamily('Royalty')
			.withVariedade(variety)
			.withUNIDADE('BAG 140K')
			.build();
		insert aRoyaltyProduct;

		PricebookEntry pbeRoyaltyStndr = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(Test.getStandardPricebookId())
			.withProduct2Id(aRoyaltyProduct)
			.withUnitPrice(1)
			.build();
		insert pbeRoyaltyStndr;
		PricebookEntry pbeRoyalty = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(pricebookRoyalty)
			.withProduct2Id(aRoyaltyProduct)
			.withUnitPrice(1)
			.build();
		insert pbeRoyalty;

		Product2 a140SeedProduct = Build.aProduct2()
			.withName('Product 1')
			.withIsActive(true)
			.withFamily('Seed')
			.withVariedade(variety)
			.withUNIDADE('BAG 140K')
			.build();
		insert a140SeedProduct;

		PricebookEntry pbe140kSeedStndr = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(Test.getStandardPricebookId())
			.withProduct2Id(a140SeedProduct)
			.withUnitPrice(1)
			.build();
		insert pbe140kSeedStndr;
		PricebookEntry pbe140k = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(pricebookWholesale)
			.withProduct2Id(a140SeedProduct)
			.withUnitPrice(1)
			.build();
		insert pbe140k;

		Account anAccount = Build.anAccount().withName('Test').build();
		insert anAccount;
		Opportunity saleReport = Build.anOpportunitySalesReport()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Final Sales Report')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		insert saleReport;

		Opportunity saleOpp = Build.anOpportunitySale()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Sales Forecast Update 2')
			.withSeedType('Parent Seed')
			.withMarca('DONMARIO')
			.withPricebook2Id(pricebook)
			.build();
		insert saleOpp;
		Opportunity reportOpp = Build.anOpportunityProductionReport()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Final Production Report')
			.withSeedType('Parent Seed')
			.withMarca('DONMARIO')
			.withPricebook2Id(pricebook)
			.build();
		insert reportOpp;
		Opportunity saleOppTwo = Build.anOpportunitySale()
			.withName('Stock opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Sales Forecast Update 1')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		insert saleOppTwo;
	}

	@isTest
	static void testCloningOppFsrShouldCreateACloneFromOppApproved() {
		Account acc = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
		Opportunity oppToApprove = [
			SELECT Id, AccountId
			FROM Opportunity
			WHERE Type = 'Final Sales Report' AND Marca__c = 'GDM'
			LIMIT 1
		];
		List<Incentive_Code__c> incentiveCodes = new List<Incentive_Code__c>{
			Build.anIncentiveCode().withName('Incentive code 0').withSeason('22/2022').build(),
			Build.anIncentiveCode().withName('Incentive code 1').withSeason('22/2022').build(),
			Build.anIncentiveCode().withName('Incentive code 2').withSeason('22/2022').build(),
			Build.anIncentiveCode().withName('Incentive code 3').withSeason('22/2022').build()
		};
		insert incentiveCodes;

        List<Incentive_Contract__c> incentives = new List<Incentive_Contract__c>{
			Build.anIncentiveContract()
				.withName('Incentive GDM Becks Hybrids')
				.withBrand('GDM')
				.withCompany('GDM')
				.withSeason('22/2022')
				.withAccount(acc)
				.withIncentiveCode(incentiveCodes[0])
				.build()
        };
        insert incentives;
		List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Pricebook GDM'];
		List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
		itemsToInsert.addAll(createOppProducts(pbes, oppToApprove, 10));
		insert itemsToInsert;
		oppToApprove.StageName = 'Approved';
		Test.startTest();
		update oppToApprove;
		Test.stopTest();

		Opportunity oppCloned = [
			SELECT
				Id,
				Anexo_Relacionado__c,
				RecordType.DeveloperName,
				Ship_To__c,
				StageName,
				Type,
				Condicion_de_Pago__c,
				Incoterm_1__c,
				Incoterm_2__c,
				Tipo__c,
				Pricebook2Id
			FROM Opportunity
			WHERE Anexo_Relacionado__c = :oppToApprove.Id
			LIMIT 1
		];
		System.assert(oppCloned != null);
		System.assertEquals(oppToApprove.AccountId, oppCloned.Ship_To__c);
		System.assertEquals(oppToApprove.Id, oppCloned.Anexo_Relacionado__c);
		System.assertEquals('Editable', oppCloned.StageName);
		System.assertEquals('Z6 - ROYALTY', oppCloned.Type);
		System.assertEquals('ZC05 Net 30 days from shipping date', oppCloned.Condicion_de_pago__c);
		System.assertEquals('FOB - Free On Board', oppCloned.Incoterm_1__c);
		System.assertEquals('N/A', oppCloned.Incoterm_2__c);
		System.assertEquals('ZO15 - Local Order', oppCloned.Tipo__c);
		System.assertEquals('Sale', oppCloned.RecordType.DeveloperName);
	}

	@isTest
	static void testCloningOppAprilSalesReportShouldCreateACloneFromOppApproved() {
		Opportunity oppToApprove = [
			SELECT Id, AccountId
			FROM Opportunity
			WHERE Type = 'Sales Forecast Update 2' AND Marca__c = 'DONMARIO'
			LIMIT 1
		];
		Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = 'TRADEMARK Fee PriceList' LIMIT 1];
		List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Pricebook GDM'];
		List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
		itemsToInsert.addAll(createOppProducts(pbes, oppToApprove, 10));
		insert itemsToInsert;
		oppToApprove.StageName = 'Approved';
		Test.startTest();
		update oppToApprove;
		Test.stopTest();

		Opportunity oppCloned = [
			SELECT
				Id,
				Anexo_Relacionado__c,
				RecordType.DeveloperName,
				Ship_To__c,
				StageName,
				Type,
				Condicion_de_Pago__c,
				Incoterm_1__c,
				Incoterm_2__c,
				Tipo__c,
				Pricebook2Id
			FROM Opportunity
			WHERE Anexo_Relacionado__c = :oppToApprove.Id
			LIMIT 1
		];
		System.assert(oppCloned != null);
		System.assertEquals(oppToApprove.AccountId, oppCloned.Ship_To__c);
		System.assertEquals(oppToApprove.Id, oppCloned.Anexo_Relacionado__c);
		System.assertEquals('Editable', oppCloned.StageName);
		System.assertEquals('Z33 - TRADEMARK ROYALTY', oppCloned.Type);
		System.assertEquals('ZC05 Net 30 days from shipping date', oppCloned.Condicion_de_pago__c);
		System.assertEquals('DED - Deliver to ship-to address', oppCloned.Incoterm_1__c);
		System.assertEquals('N/A', oppCloned.Incoterm_2__c);
		System.assertEquals('ZO15 - Local Order', oppCloned.Tipo__c);
		System.assertEquals('Sale', oppCloned.RecordType.DeveloperName);
		System.assertEquals(pb.Id, oppCloned.Pricebook2Id);
	}

	@isTest
	static void testCloningOppAprilProductionReportShouldCreateACloneFromOppApproved() {
		Opportunity oppToApprove = [
			SELECT Id, AccountId
			FROM Opportunity
			WHERE Type = 'Final Production Report' AND Marca__c = 'DONMARIO'
			LIMIT 1
		];
		Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = 'DONMARIO - WHOLESALE PriceList' LIMIT 1];
		oppToApprove.StageName = 'Approved';
		List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Pricebook GDM'];
		List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
		itemsToInsert.addAll(createOppProducts(pbes, oppToApprove, 10));
		insert itemsToInsert;
		Test.startTest();
		update oppToApprove;
		Test.stopTest();

		Opportunity oppCloned = [
			SELECT
				Id,
				Anexo_Relacionado__c,
				RecordType.DeveloperName,
				Ship_To__c,
				StageName,
				Type,
				Condicion_de_Pago__c,
				Incoterm_1__c,
				Incoterm_2__c,
				Tipo__c,
				Pricebook2Id
			FROM Opportunity
			WHERE Anexo_Relacionado__c = :oppToApprove.Id
			LIMIT 1
		];
		System.assert(oppCloned != null);
		System.assertEquals(oppToApprove.AccountId, oppCloned.Ship_To__c);
		System.assertEquals(oppToApprove.Id, oppCloned.Anexo_Relacionado__c);
		System.assertEquals('Editable', oppCloned.StageName);
		System.assertEquals('Z16 - TRADEMARK ROYALTY', oppCloned.Type);
		System.assertEquals('ZC05 Net 30 days from shipping date', oppCloned.Condicion_de_pago__c);
		System.assertEquals('DED - Deliver to ship-to address', oppCloned.Incoterm_1__c);
		System.assertEquals('N/A', oppCloned.Incoterm_2__c);
		System.assertEquals('ZO15 - Local Order', oppCloned.Tipo__c);
		System.assertEquals('Sale', oppCloned.RecordType.DeveloperName);
		System.assertEquals(pb.Id, oppCloned.Pricebook2Id);
	}

	@isTest
	static void testCalculateEstimate() {
		Opportunity oppToApprove = [
			SELECT Id, Safra__c, AccountId, Royalty_Estimation_Amount__c
			FROM Opportunity
			WHERE Type = 'Sales Forecast Update 1'
			LIMIT 1
		];
		Credit_Document__c cd = new Credit_Document__c(
			Season__c = oppToApprove.Safra__c,
			Document_Type__c = 'Credit Limit',
			Account__c = oppToApprove.AccountId,
			Royalty_Estimation__c = 10
		);
		insert cd;
		Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = 'DONMARIO - WHOLESALE PriceList' LIMIT 1];
		oppToApprove.StageName = 'Approved';
		List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Pricebook GDM'];
		List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
		itemsToInsert.addAll(createOppProducts(pbes, oppToApprove, 10));
		insert itemsToInsert;
		Test.startTest();
		update oppToApprove;
		Test.stopTest();

		oppToApprove = [
			SELECT Id, Safra__c, AccountId, Royalty_Estimation_Amount__c
			FROM Opportunity
			WHERE Id = :oppToApprove.Id
		];

		List<Credit_Document__c> cdUpdated = [
			SELECT Id, Account__c, Season__c, Royalty_Estimation__c
			FROM Credit_Document__c
			WHERE Id = :cd.Id
		];
		System.assertEquals(30, cdUpdated[0].Royalty_Estimation__c);
	}

	@isTest
	static void testCargarRecordTypes() {
		List<String> rtDevNames = new List<String>{
			'Appendix I',
			'Appendix II',
			'Master',
			'Budget',
			'GPOS Opportunity',
			'Production Report',
			'Purchase',
			'Reservation',
			'Sale',
			'Sale Request',
			'Sales Report',
			'Stock per plant'
		};
		Test.startTest();
		Map<String, Id> rtypes = Opp_Utils.cargarRecordTypesOportunidades();
		Test.stopTest();
		for (String devName : rtypes.keySet()) {
			System.assert(rtDevNames.contains(devName), 'The record type name should exist');
		}
	}

	@isTest
	static void testDonmarioPricebookAssignment() {
		Account anAccount = [SELECT Id FROM Account LIMIT 1];
		List<Pricebook2> pricebooksToInsert = new List<Pricebook2>();
		List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
		Set<Id> oppsIds = new Set<Id>();
		Id rtSale = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sale').getRecordTypeId();
		Id rtPurchase = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('Purchase')
			.getRecordTypeId();
		Id rtReservation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('Reservation')
			.getRecordTypeId();
		Pricebook2 parentPricebook = Build.aPricebook2()
			.withBrand('DONMARIO')
			.withName('Pricebook Donmario')
			.withType('PARENT SEED')
			.withIsActive(true)
			.build();
		Pricebook2 wholesalePricebook = Build.aPricebook2()
			.withBrand('DONMARIO')
			.withName('Pricebook Donmario')
			.withType('WHOLESALE SEED')
			.withIsActive(true)
			.build();
		Pricebook2 trademarkPricebook = Build.aPricebook2()
			.withBrand('DONMARIO')
			.withName('Pricebook Donmario')
			.withType('TRADEMARK')
			.withIsActive(true)
			.build();
		Pricebook2 royaltyPricebook = Build.aPricebook2()
			.withBrand(null)
			.withName('Pricebook Donmario')
			.withType('PORTAL')
			.withIsActive(true)
			.build();
		pricebooksToInsert.add(parentPricebook);
		pricebooksToInsert.add(wholesalePricebook);
		pricebooksToInsert.add(trademarkPricebook);
		pricebooksToInsert.add(royaltyPricebook);
		insert pricebooksToInsert;
		Opportunity saleOpp = Build.anOpportunitySale()
			.withType('Z2 - PARENT SEED')
			.withMarca('DONMARIO')
			.withAccountId(anAccount)
			.build();
		Opportunity reservationOpp = Build.anOpportunityReservation()
			.withType('Z7 - PRODUCTION SEED')
			.withMarca('DONMARIO')
			.withAccountId(anAccount)
			.build();
		Opportunity royaltyOpp = Build.anOpportunitySale()
			.withType('Z6 - ROYALTY')
			.withMarca('DONMARIO')
			.withAccountId(anAccount)
			.build();
		Opportunity royaltyTrademarkOpp = Build.anOpportunitySale()
			.withType('Z16 - TRADEMARK ROYALTY')
			.withMarca('DONMARIO')
			.withAccountId(anAccount)
			.build();
		Opportunity wholesaleOpp = Build.anOpportunitySale()
			.withType('Z4 - WHOLESALE SEED')
			.withMarca('DONMARIO')
			.withAccountId(anAccount)
			.build();
		Opportunity replantOpp = Build.anOpportunitySale()
			.withType('Z15 - REPLANT')
			.withMarca('DONMARIO')
			.withAccountId(anAccount)
			.build();
		replantOpp.Company__c = 'B&B';
		opportunitiesToInsert.add(saleOpp);
		opportunitiesToInsert.add(reservationOpp);
		opportunitiesToInsert.add(royaltyOpp);
		opportunitiesToInsert.add(wholesaleOpp);
		opportunitiesToInsert.add(royaltyTrademarkOpp);
		opportunitiesToInsert.add(replantOpp);
		Test.startTest();
		insert opportunitiesToInsert;
		for (Opportunity oppInserted : opportunitiesToInsert) {
			oppsIds.add(oppInserted.Id);
		}
		Test.stopTest();
		for (Opportunity insertedOpp : [SELECT RecordTypeId, Pricebook2Id, Type FROM Opportunity WHERE Id IN :oppsIds]) {
			if (
				insertedOpp.Type == 'Z2 - PARENT SEED' &&
				(insertedOpp.RecordTypeId == rtSale ||
				insertedOpp.RecordTypeId == rtReservation)
			) {
				System.assertEquals(parentPricebook.Id, insertedOpp.Pricebook2Id);
			}
			if (insertedOpp.RecordTypeId == rtSale && insertedOpp.Type == 'Z6 - ROYALTY') {
				System.assertEquals(royaltyPricebook.Id, insertedOpp.Pricebook2Id);
			}
			if (insertedOpp.RecordTypeId == rtSale && insertedOpp.Type == 'Z16 - TRADEMARK ROYALTY') {
				System.assertEquals(trademarkPricebook.Id, insertedOpp.Pricebook2Id);
			}
			if (insertedOpp.RecordTypeId == rtSale && insertedOpp.Type == 'Z4 - WHOLESALE SEED') {
				System.assertEquals(wholesalePricebook.Id, insertedOpp.Pricebook2Id);
			}
			if (insertedOpp.RecordTypeId == rtSale && insertedOpp.Type == 'Z15 - REPLANT') {
				System.assertEquals(trademarkPricebook.Id, insertedOpp.Pricebook2Id);
			}
		}
	}

	@isTest
	static void testVirtuePricebookAssignment() {
		Account anAccount = [SELECT Id FROM Account LIMIT 1];
		List<Pricebook2> pricebooksToInsert = new List<Pricebook2>();
		List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
		Set<Id> oppsIds = new Set<Id>();
		Id rtSale = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sale').getRecordTypeId();
		Id rtPurchase = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('Purchase')
			.getRecordTypeId();
		Id rtReservation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('Reservation')
			.getRecordTypeId();
		Pricebook2 parentPricebook = Build.aPricebook2()
			.withBrand('VIRTUE')
			.withName('Pricebook Donmario')
			.withType('PARENT SEED')
			.withIsActive(true)
			.build();
		Pricebook2 wholesalePricebook = Build.aPricebook2()
			.withBrand('VIRTUE')
			.withName('Pricebook Donmario')
			.withType('WHOLESALE SEED')
			.withIsActive(true)
			.build();
		Pricebook2 royaltyPricebook = Build.aPricebook2()
			.withBrand(null)
			.withName('Pricebook Donmario')
			.withType('PORTAL')
			.withIsActive(true)
			.build();

		pricebooksToInsert.add(parentPricebook);
		pricebooksToInsert.add(wholesalePricebook);
		pricebooksToInsert.add(royaltyPricebook);
		insert pricebooksToInsert;
		Opportunity saleOpp = Build.anOpportunitySale()
			.withType('Z2 - PARENT SEED')
			.withMarca('VIRTUE')
			.withAccountId(anAccount)
			.build();

		Opportunity wholesaleOpp = Build.anOpportunitySale()
			.withType('Z4 - WHOLESALE SEED')
			.withMarca('VIRTUE')
			.withAccountId(anAccount)
			.build();
		Opportunity royaltyOpp = Build.anOpportunitySale()
			.withType('Z6 - ROYALTY')
			.withMarca('VIRTUE')
			.withAccountId(anAccount)
			.build();
		opportunitiesToInsert.add(saleOpp);
		opportunitiesToInsert.add(wholesaleOpp);
		opportunitiesToInsert.add(royaltyOpp);
		Test.startTest();
		insert opportunitiesToInsert;
		for (Opportunity oppInserted : opportunitiesToInsert) {
			oppsIds.add(oppInserted.Id);
		}
		Test.stopTest();
		for (Opportunity insertedOpp : [SELECT RecordTypeId, Pricebook2Id, Type FROM Opportunity WHERE Id IN :oppsIds]) {
			if (
				insertedOpp.Type == 'Z2 - PARENT SEED' &&
				(insertedOpp.RecordTypeId == rtSale ||
				insertedOpp.RecordTypeId == rtReservation)
			) {
				System.assertEquals(parentPricebook.Id, insertedOpp.Pricebook2Id);
			}
			if (insertedOpp.RecordTypeId == rtSale && insertedOpp.Type == 'Z6 - ROYALTY') {
				System.assertEquals(royaltyPricebook.Id, insertedOpp.Pricebook2Id);
			}
			if (
				insertedOpp.RecordTypeId == rtSale && insertedOpp.Type == 'Z4 - WHOLESALE SEED' ||
				insertedOpp.Type == 'COMMERCIAL SEED'
			) {
				System.assertEquals(wholesalePricebook.Id, insertedOpp.Pricebook2Id);
			}
		}
	}
	@isTest
	static void testGdmPricebookAssignment() {
		Account anAccount = [SELECT Id FROM Account LIMIT 1];
		List<Pricebook2> pricebooksToInsert = new List<Pricebook2>();
		List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
		Set<Id> oppsIds = new Set<Id>();
		Id rtSale = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sale').getRecordTypeId();
		Id rtPurchase = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('Purchase')
			.getRecordTypeId();
		Id rtReservation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('Reservation')
			.getRecordTypeId();
		Pricebook2 parentPricebook = Build.aPricebook2()
			.withBrand('GDM')
			.withName('Pricebook Donmario')
			.withType('PARENT SEED')
			.withIsActive(true)
			.build();
		Pricebook2 wholesalePricebook = Build.aPricebook2()
			.withBrand('GDM')
			.withName('Pricebook Donmario')
			.withType('WHOLESALE SEED')
			.withIsActive(true)
			.build();
		Pricebook2 royaltyPricebook = Build.aPricebook2()
			.withBrand(null)
			.withName('Pricebook Donmario')
			.withType('PORTAL')
			.withIsActive(true)
			.build();
		Pricebook2 trademarkPricebook = Build.aPricebook2()
			.withBrand('DONMARIO')
			.withName('trademarkPricebook')
			.withType('TRADEMARK')
			.withIsActive(true)
			.build();

		pricebooksToInsert.add(parentPricebook);
		pricebooksToInsert.add(wholesalePricebook);
		pricebooksToInsert.add(royaltyPricebook);
		pricebooksToInsert.add(trademarkPricebook);
		insert pricebooksToInsert;
		Opportunity saleOpp = Build.anOpportunitySale()
			.withType('Z2 - PARENT SEED')
			.withMarca('GDM')
			.withAccountId(anAccount)
			.build();

		Opportunity wholesaleOpp = Build.anOpportunitySale()
			.withType('Z4 - WHOLESALE SEED')
			.withMarca('GDM')
			.withAccountId(anAccount)
			.build();

		Opportunity replantOpp = Build.anOpportunitySale()
			.withType('Z15 - REPLANT')
			.withMarca('GDM')
			.withAccountId(anAccount)
			.build();
		replantOpp.Company__c = 'GDM';

		opportunitiesToInsert.add(saleOpp);
		opportunitiesToInsert.add(wholesaleOpp);
		opportunitiesToInsert.add(replantOpp);
		Test.startTest();
		insert opportunitiesToInsert;
		for (Opportunity oppInserted : opportunitiesToInsert) {
			oppsIds.add(oppInserted.Id);
		}
		Test.stopTest();
		for (Opportunity insertedOpp : [SELECT RecordTypeId, Pricebook2Id, Type FROM Opportunity WHERE Id IN :oppsIds]) {
			if (
				insertedOpp.Type == 'Z2 - PARENT SEED' &&
				(insertedOpp.RecordTypeId == rtSale ||
				insertedOpp.RecordTypeId == rtReservation)
			) {
				System.assertEquals(parentPricebook.Id, insertedOpp.Pricebook2Id);
			}
			if (insertedOpp.RecordTypeId == rtSale && insertedOpp.Type == 'Z4 - WHOLESALE SEED') {
				System.assertEquals(wholesalePricebook.Id, insertedOpp.Pricebook2Id);
			}
			if (insertedOpp.Type == 'Z15 - REPLANT') {
				System.assertEquals(royaltyPricebook.Id, insertedOpp.Pricebook2Id);
			}
		}
	}

	// @isTest
	// static void testInsertingOppProductShouldUpdateRelatedScheduleALicenseeField() {
	// 	Account anAccount = [SELECT Id FROM Account LIMIT 1];
	// 	Product2 aRoyaltyProduct = [
	// 		SELECT Id, Variedade__c
	// 		FROM Product2
	// 		WHERE Name = 'Product 1' AND Family = 'Royalty' AND Variedade__r.Name = 'Variety'
	// 	];
	// 	Pricebook2 thePricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Pricebook GDM' LIMIT 1];
	// 	Opportunity anOpp = [
	// 		SELECT Id, Safra__c, Marca__c, AccountId
	// 		FROM Opportunity
	// 		WHERE
	// 			Marca__c = 'GDM'
	// 			AND Safra__c = '22/2022'
	// 			AND AccountId = :anAccount.Id
	// 			AND Opportunity.RecordType.DeveloperName = 'Production_Report'
	// 		LIMIT 1
	// 	];
	// 	PricebookEntry pbeOneStndr = Build.aPricebookEntry()
	// 		.withIsActive(true)
	// 		.withPricebook2Id(Test.getStandardPricebookId())
	// 		.withProduct2Id(aRoyaltyProduct)
	// 		.withUnitPrice(1)
	// 		.build();
	// 	insert pbeOneStndr;
	// 	PricebookEntry pbeOneGdm = Build.aPricebookEntry()
	// 		.withIsActive(true)
	// 		.withPricebook2Id(thePricebook)
	// 		.withProduct2Id(aRoyaltyProduct)
	// 		.withUnitPrice(1)
	// 		.build();
	// 	insert pbeOneGdm;
	// 	OpportunityLineItem item = Build.anOpportunityLineItem()
	// 		.withPricebookEntryId(pbeOneGdm)
	// 		.withOpportunityId(anOpp)
	// 		.withTotalPrice(10)
	// 		.withQuantity(1)
	// 		.withCentrodedespacho('E002 - B&B - GIBSON CITY')
	// 		.build();
	// 	item.Licensee_Variety_Name__c = '12345678910';
	// 	Test.startTest();
	// 	insert item;
	// 	Test.stopTest();

	// 	OpportunityLineItem itemInserted = [SELECT Variedade_de_Produto__c FROM OpportunityLineItem WHERE Id = :item.Id];

	// 	Item_del_Contrato__c itemUpdated = [
	// 		SELECT Id, Licensee_Variety_ID__c
	// 		FROM Item_del_Contrato__c
	// 		WHERE
	// 			Contrato_de_multiplicacion__r.Safra__c = :anOpp.Safra__c
	// 			AND Contrato_de_multiplicacion__r.Brand__c = :anOpp.Marca__c
	// 			AND Contrato_de_multiplicacion__r.Multiplicador__c = :anOpp.AccountId
	// 			AND Variedade__c = :itemInserted.Variedade_de_Produto__c
	// 		LIMIT 1
	// 	];
	// 	System.assertEquals(
	// 		item.Licensee_Variety_Name__c,
	// 		itemUpdated.Licensee_Variety_ID__c,
	// 		'Updating Licensee variety name on opp prod should update licenses variety brand with same Variety, Brand and Season'
	// 	);
	// }

	public static List<OpportunityLineItem> createOppProducts(
		List<PricebookEntry> products,
		Opportunity opp,
		Double quantity
	) {
		List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
		for (PricebookEntry pbe : products) {
			OpportunityLineItem oppProduct = Build.anOpportunityLineItem()
				.withPricebookEntryId(pbe)
				.withOpportunityId(opp)
				.withQuantity(quantity)
				.withTotalPrice(10)
				.withForecastQuantity(quantity)
				.withTestPlotsUnits(quantity)
				.withSementebeneficiada(quantity)
				.withRoyaltyEstimation(quantity)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.build();
			oppProducts.add(oppProduct);
		}
		return oppProducts;
	}
	public static List<PricebookEntry> createProducts(Integer numberOfProducts) {
		List<PricebookEntry> products = new List<PricebookEntry>();
		Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Pricebook GDM' LIMIT 1];
		for (Integer i = 0; i < numberOfProducts; i++) {
			Variedad__c variety = Build.aVariedad().withName('Variety' + i).build();
			insert variety;
			Product2 aProduct = Build.aProduct2()
				.withName('Product ' + i)
				.withIsActive(true)
				.withVariedade(variety)
				.withUNIDADE('BAG 140K')
				.build();
			insert aProduct;
			PricebookEntry pbeOneStndr = Build.aPricebookEntry()
				.withIsActive(true)
				.withPricebook2Id(Test.getStandardPricebookId())
				.withProduct2Id(aProduct)
				.withUnitPrice(1)
				.build();
			insert pbeOneStndr;
			PricebookEntry pbeOneGdm = Build.aPricebookEntry()
				.withIsActive(true)
				.withPricebook2Id(pricebook)
				.withProduct2Id(aProduct)
				.withUnitPrice(1)
				.build();
			insert pbeOneGdm;
			products.add(pbeOneGdm);
		}
		return products;
	}
}