@isTest
private class IncentiveProgramTest {
	@TestSetup
	static void makeData() {
		User usuario = new User(
			FirstName = 'Charly',
			LastName = 'Garcia',
			Email = 'charlygarcia@arg.com',
			Username = 'Charlygarcia@arg.com',
			TimeZoneSidKey = 'America/Chicago',
			EmailEncodingKey = 'ISO-8859-1',
			ProfileId = '00e41000000P1H3AAK',
			LanguageLocaleKey = 'en_US',
			Alias = 'arg',
			LocaleSidKey = 'en_US'
		);
		insert usuario;
		List<Account> accounts = new List<Account>{
			Build.anAccount().withName('Becks Hybrids').build(),
			Build.anAccount().withName('Stratton Seed Company').build(),
			Build.anAccount().withName('Account X').build(),
			Build.anAccount().withName('Account Y').build()
		};
		insert accounts;
		List<Variedad__c> varieties = new List<Variedad__c>{
			Build.aVariedad().withName('GDM45F118').withActive(true).withTecnologia('XTENDFLEX').build(),
			Build.aVariedad().withName('GDM34E251').withActive(true).withTecnologia('ENLIST').build(),
			Build.aVariedad().withName('V4522S').withActive(true).withTecnologia('CONVENTIONAL').build()
		};
		insert varieties;
		List<Product2> products = new List<Product2>{
			Build.aProduct2().withName('GDM45F118').withVariedade(varieties[0]).withUNIDADE('BAG 140K').withCANTIDADSUBUNIDAD('140').build(),
			Build.aProduct2().withName('GDM34E251').withVariedade(varieties[1]).withUNIDADE('BAG 140K').withCANTIDADSUBUNIDAD('140').build(),
			Build.aProduct2().withName('V4522S').withVariedade(varieties[2]).withUNIDADE('BAG 140K').withCANTIDADSUBUNIDAD('140').build()
		};
		insert products;
		List<PricebookEntry> entries = new List<PricebookEntry>{
			Build.aPricebookEntry()
				.withIsActive(true)
				.withPricebook2Id(Test.getStandardPricebookId())
				.withProduct2Id(products[0])
				.withUnitPrice(3.50)
				.build(),
			Build.aPricebookEntry()
				.withIsActive(true)
				.withPricebook2Id(Test.getStandardPricebookId())
				.withProduct2Id(products[1])
				.withUnitPrice(6.95)
				.build(),
			Build.aPricebookEntry()
				.withIsActive(true)
				.withPricebook2Id(Test.getStandardPricebookId())
				.withProduct2Id(products[2])
				.withUnitPrice(8.95)
				.build()
		};
		insert entries;

		List<Incentive_Code__c> incentiveCodes = new List<Incentive_Code__c>{
			Build.anIncentiveCode().withName('Incentive code 0').withSeason('22/2022').build(),
			Build.anIncentiveCode().withName('Incentive code 1').withSeason('22/2022').build(),
			Build.anIncentiveCode().withName('Incentive code 2').withSeason('22/2022').build(),
			Build.anIncentiveCode().withName('Incentive code 3').withSeason('22/2022').build()
		};
		insert incentiveCodes;

		List<Incentive_Parent_Seed_Code__c> incentiveParentSeedCodes = new List<Incentive_Parent_Seed_Code__c>{
			Build.anIncentiveParentSeedCode().withName('Incentive parent seed code 0').withSeason('22/2022').build()
		};
		insert incentiveParentSeedCodes;
		
		

		List<Incentive_Contract__c> incentives = new List<Incentive_Contract__c>{
			Build.anIncentiveContract()
				.withName('Incentive GDM Becks Hybrids')
				.withBrand('GDM')
				.withCompany('GDM')
				.withSeason('22/2022')
				.withAccount(accounts[0])
				.withIncentiveCode(incentiveCodes[0])
				.withParentSeed(incentiveParentSeedCodes[0])
				.build(),
			Build.anIncentiveContract()
				.withName('Incentive GDM/VIRTUE Stratton Seed Company')
				.withBrand('GDM;VIRTUE')
				.withSeason('22/2022')
				.withAccount(accounts[1])
				.withIncentiveCode(incentiveCodes[1])
				.build(),
			Build.anIncentiveContract()
				.withName('Incentive GDM X')
				.withBrand('GDM')
				.withSeason('22/2022')
				.withAccount(accounts[2])
				.withIncentiveCode(incentiveCodes[2])
				.build(),
			Build.anIncentiveContract()
				.withName('Incentive GDM Y')
				.withBrand('GDM')
				.withSeason('22/2022')
				.withAccount(accounts[3])
				.withIncentiveCode(incentiveCodes[3])
				.build()
		};
		insert incentives;

		List<Incentive_Contract_Parent_Seed_Goal__c> parentSeedDiscounts = new List<Incentive_Contract_Parent_Seed_Goal__c>{
			Build.anIncentiveParentSeedDiscountBuilder()
				.withName('Parent seed discount becky 2022')
				.withIncentiveContract(incentives[0])
				.withSeason('22/2022')
				.withQuantities(1280)
				.withUniqueVarieties(5)
				.build()
		};
		insert parentSeedDiscounts;
		
		List<Incentive_Contract_Volume_Goal__c> volumeGoals = new List<Incentive_Contract_Volume_Goal__c>{
			Build.anIncentiveContractVolumeGoalBuilder()
				.withName('Volume goal Becks GDM')
				.withSeason('22/2022')
				.withIncentiveContract(incentives[0])
				.withVolume(700000)
				.build(),
			Build.anIncentiveContractVolumeGoalBuilder()
				.withName('Volume goal Stratton GDM/VIRTUE')
				.withSeason('22/2022')
				.withIncentiveContract(incentives[1])
				.withVolume(47000)
				.build(),
			Build.anIncentiveContractVolumeGoalBuilder()
				.withName('Volume goal GDM X')
				.withSeason('22/2022')
				.withIncentiveContract(incentives[2])
				.withVolume(700000)
				.build(),
			Build.anIncentiveContractVolumeGoalBuilder()
				.withName('Volume goal GDM y')
				.withSeason('22/2022')
				.withIncentiveContract(incentives[3])
				.withVolume(100000)
				.build()
		};
		insert volumeGoals;

	
		List<Incentive_Parent_Seed_Code_Detail__c> parentSeedDiscountDetails = new List<Incentive_Parent_Seed_Code_Detail__c>{
			Build.anIncentiveParentSeedDiscountDetailBuilder()
			.withName('Parent seed detail beckys 2022')
			.withParentSeed(incentiveParentSeedCodes[0])
			.withTrait('CONVENTIONAL')
			.withMaxQuantities(100)
			.withMinQuantities(100)
			.withMaxVarieties(100)
			.withMinVarieties(100)
			.withDiscount(0)
			.build(),
			Build.anIncentiveParentSeedDiscountDetailBuilder()
			.withName('Parent seed detail beckys 2022')
			.withParentSeed(incentiveParentSeedCodes[0])
			.withTrait('ENLIST')
			.withMaxQuantities(100)
			.withMinQuantities(100)
			.withMaxVarieties(100)
			.withMinVarieties(100)
			.withDiscount(3.50)
			.build(),
			Build.anIncentiveParentSeedDiscountDetailBuilder()
			.withName('Parent seed detail beckys 2022')
			.withParentSeed(incentiveParentSeedCodes[0])
			.withTrait('XTENDFLEX')
			.withMaxQuantities(100)
			.withMinQuantities(100)
			.withMaxVarieties(100)
			.withMinVarieties(100)
			.withDiscount(2.50)
			.build()
		};
		insert parentSeedDiscountDetails;
		// Xtendflex code details

		List<Incentive_Code_Detail__c> codeDetails = new List<Incentive_Code_Detail__c>();
		//Becky's
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 1')
				.withTrait('XTENDFLEX')
				.withMinPercentage(0)
				.withMaxPercentage(42.857)
				// .withMinPrice(3)
				// .withMaxPrice(3)
				.withDiscountPrice(3)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtend flex tier 2')
				.withTrait('XTENDFLEX')
				.withMinPercentage(42.858)
				.withMaxPercentage(71.428)
				.withMinPrice(2.86)
				.withMaxPrice(2.99)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtend flex tier 3')
				.withTrait('XTENDFLEX')
				.withMinPercentage(71.429)
				.withMaxPercentage(99)
				.withMinPrice(2.51)
				.withMaxPrice(2.85)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 4')
				.withTrait('XTENDFLEX')
				.withMinPercentage(99)
				.withDiscountPrice(2.50)
				// .withMaxPrice(2.50)
				// .withMinPrice(2.50)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		// Stratton seeed company
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 1 Stratton')
				.withTrait('XTENDFLEX')
				.withMinPercentage(0)
				.withMaxPercentage(50)
				.withDiscountPrice(3.50)
				// .withMaxPrice(3.50)
				// .withMinPrice(3.50)
				.withIncentiveCode(incentiveCodes[1])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 2 Stratton')
				.withTrait('XTENDFLEX')
				.withMinPercentage(50)
				.withMaxPercentage(99)
				.withDiscountPrice(3.50)
				// .withMaxPrice(3.50)
				// .withMinPrice(3.50)
				.withIncentiveCode(incentiveCodes[1])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 3 Stratton')
				.withTrait('XTENDFLEX')
				.withMinPercentage(99)
				.withDiscountPrice(3.50)
				// .withMaxPrice(3.50)
				// .withMinPrice(3.50)
				.withIncentiveCode(incentiveCodes[1])
				.build()
		);

		//Enlist code details

		// Becky's
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 1')
				.withTrait('ENLIST')
				.withMinPercentage(0)
				.withMaxPercentage(42.857)
				.withDiscountPrice(4.95)
				// .withMaxPrice(4.95)
				// .withMinPrice(4.95)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 2')
				.withTrait('ENLIST')
				.withMinPercentage(42.858)
				.withMaxPercentage(71.428)
				.withMinPrice(3.96)
				.withMaxPrice(4.50)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 3')
				.withTrait('ENLIST')
				.withMinPercentage(71.429)
				.withMaxPercentage(99)
				.withMinPrice(3.51)
				.withMaxPrice(3.95)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 4')
				.withTrait('ENLIST')
				.withMinPercentage(99)
				.withDiscountPrice(3.50)
				// .withMaxPrice(3.50)
				// .withMinPrice(3.50)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		// Stratton seed company
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 1 Stratton')
				.withTrait('ENLIST')
				.withMinPercentage(0)
				.withMaxPercentage(50)
				.withDiscountPrice(5.95)
				// .withMaxPrice(5.95)
				// .withMinPrice(5.95)
				.withIncentiveCode(incentiveCodes[1])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 2 Stratton')
				.withTrait('ENLIST')
				.withMinPercentage(50)
				.withMaxPercentage(99)
				.withMinPrice(4.96)
				.withMaxPrice(5.94)
				.withIncentiveCode(incentiveCodes[1])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 3 Stratton')
				.withTrait('ENLIST')
				.withMinPercentage(99)
				.withDiscountPrice(4.95)
				// .withMaxPrice(4.95)
				// .withMinPrice(4.95)
				.withIncentiveCode(incentiveCodes[1])
				.build()
		);

		//Conventional code details

		// Becky's
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Conventional tier 1')
				.withTrait('CONVENTIONAL')
				.withMinPercentage(0)
				.withMaxPercentage(42.857)
				.withDiscountPrice(4)
				// .withMaxPrice(4)
				// .withMinPrice(4)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Conventional tier 2')
				.withTrait('CONVENTIONAL')
				.withMinPercentage(42.858)
				.withMaxPercentage(71.428)
				.withDiscountPrice(4)
				// .withMaxPrice(4)
				// .withMinPrice(4)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Conventional tier 3')
				.withTrait('CONVENTIONAL')
				.withMinPercentage(71.429)
				.withMaxPercentage(99)
				.withDiscountPrice(4)
				// .withMinPrice(4)
				// .withMaxPrice(4)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Conventional tier 4')
				.withTrait('CONVENTIONAL')
				.withMinPercentage(99)
				.withDiscountPrice(4)
				// .withMaxPrice(4)
				// .withMinPrice(4)
				.withIncentiveCode(incentiveCodes[0])
				.build()
		);

		//Stratton's
		// Stratton seed company
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Conventional 1 Stratton')
				.withTrait('CONVENTIONAL')
				.withMinPercentage(0)
				.withMaxPercentage(50)
				.withDiscountPrice(8.95)
				// .withMaxPrice(8.95)
				// .withMinPrice(8.95)
				.withIncentiveCode(incentiveCodes[1])
				.build()
		);
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Conventional 2 Stratton')
				.withTrait('CONVENTIONAL')
				.withMinPercentage(50)
				.withMaxPercentage(99)
				.withMinPrice(5.96)
				.withMaxPrice(8.94)
				.withIncentiveCode(incentiveCodes[1])
				.build()
		);
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Conventional 3 Stratton')
				.withTrait('CONVENTIONAL')
				.withMinPercentage(99)
				.withDiscountPrice(4.95)
				// .withMinPrice(4.95)
				// .withMaxPrice(4.95)
				.withIncentiveCode(incentiveCodes[1])
				.build()
		);

		// X account
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 1 X')
				.withTrait('XTENDFLEX')
				.withMinPercentage(0)
				.withMaxPercentage(50)
				.withDiscountPrice(3)
				// .withMaxPrice(3)
				// .withMinPrice(3)
				.withIncentiveCode(incentiveCodes[2])
				.build()
		);
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 2 X')
				.withTrait('XTENDFLEX')
				.withMinPercentage(50)
				.withMaxPercentage(99)
				.withMaxPrice(2.99)
				.withMinPrice(2.50)
				.withIncentiveCode(incentiveCodes[2])
				.build()
		);
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 3 X')
				.withTrait('XTENDFLEX')
				.withDiscountPrice(2.50)
				// .withMaxPrice(2.50)
				// .withMaxPrice(2.50)
				// .withMinPrice(2.50)
				.withIncentiveCode(incentiveCodes[2])
				.build()
		);

		// Y account
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 1 Y')
				.withTrait('XTENDFLEX')
				.withMinPercentage(0)
				.withMaxPercentage(50)
				.withDiscountPrice(3)
				// .withMaxPrice(3)
				// .withMinPrice(3)
				.withIncentiveCode(incentiveCodes[3])
				.build()
		);
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 2 Y')
				.withTrait('XTENDFLEX')
				.withMinPercentage(50)
				.withMaxPercentage(99)
				.withMaxPrice(2.99)
				.withMinPrice(2.50)
				.withIncentiveCode(incentiveCodes[3])
				.build()
		);
		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Xtendflex tier 3 Y')
				.withTrait('XTENDFLEX')
				.withMinPercentage(99)
				.withDiscountPrice(2.50)
				// .withMaxPrice(2.50)
				// .withMinPrice(2.50)
				.withIncentiveCode(incentiveCodes[3])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 1 Y')
				.withTrait('ENLIST')
				.withMinPercentage(0)
				.withMaxPercentage(50)
				.withDiscountPrice(5.95)
				// .withMaxPrice(5.95)
				// .withMinPrice(5.95)
				.withIncentiveCode(incentiveCodes[3])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 2 Y')
				.withTrait('ENLIST')
				.withMinPercentage(50)
				.withMaxPercentage(99)
				.withMinPrice(4.50)
				.withMaxPrice(5.40)
				.withIncentiveCode(incentiveCodes[3])
				.build()
		);

		codeDetails.add(
			Build.anIncentiveCodeDetail()
				.withName('Enlist tier 3 Y')
				.withTrait('ENLIST')
				.withMinPercentage(99)
				.withDiscountPrice(5.40)
				// .withMaxPrice(5.40)
				// .withMinPrice(5.40)
				.withIncentiveCode(incentiveCodes[3])
				.build()
		);

		insert codeDetails;

		List<Opportunity> opportunities = new List<Opportunity>{
			Build.anOpportunitySalesReport()
				.withName('Beckys FSR GDM')
				.withAccountId(accounts[0])
				.withSafra('22/2022')
				.withTipo('Z2 - PARENT SEED')
				.withType('Final Sales Report')
				.withSeedType('Parent Seed')
				.withMarca('GDM')
				.withPricebook2Id(Test.getStandardPricebookId())
				.withStageName('Sent')
				.withOwnerId(usuario)
				.build(),
			Build.anOpportunitySalesReport()
				.withName('Stratton FSR GDM')
				.withAccountId(accounts[1])
				.withSafra('22/2022')
				.withTipo('Z2 - PARENT SEED')
				.withType('Final Sales Report')
				.withSeedType('Parent Seed')
				.withMarca('GDM')
				.withPricebook2Id(Test.getStandardPricebookId())
				.withStageName('Sent')
				.withOwnerId(usuario)
				.build(),
			Build.anOpportunitySalesReport()
				.withName('Stratton FSR GDM/VIRTUE')
				.withAccountId(accounts[1])
				.withSafra('22/2022')
				.withTipo('Z2 - PARENT SEED')
				.withType('Final Sales Report')
				.withSeedType('Parent Seed')
				.withStageName('Sent')
				.withMarca('VIRTUE')
				.withPricebook2Id(Test.getStandardPricebookId())
				.withOwnerId(usuario)
				.build(),
			Build.anOpportunitySalesReport()
				.withName('x FSR GDM')
				.withAccountId(accounts[2])
				.withSafra('22/2022')
				.withTipo('Z2 - PARENT SEED')
				.withType('Final Sales Report')
				.withSeedType('Parent Seed')
				.withStageName('Sent')
				.withMarca('GDM')
				.withPricebook2Id(Test.getStandardPricebookId())
				.withOwnerId(usuario)
				.build(),
			Build.anOpportunitySalesReport()
				.withName('Y FSR GDM')
				.withAccountId(accounts[3])
				.withSafra('22/2022')
				.withTipo('Z2 - PARENT SEED')
				.withType('Final Sales Report')
				.withSeedType('Parent Seed')
				.withStageName('Sent')
				.withMarca('GDM')
				.withPricebook2Id(Test.getStandardPricebookId())
				.withOwnerId(usuario)
				.build(),
			Build.anOpportunitySalesReport()
				.withName('Beckys FSR GDM')
				.withAccountId(accounts[0])
				.withSafra('21/2021')
				.withTipo('Z2 - PARENT SEED')
				.withType('Z2 - PARENT SEED')
				.withSeedType('Parent Seed')
				.withMarca('GDM')
				.withPricebook2Id(Test.getStandardPricebookId())
				.withStageName('Approved')
				.withOwnerId(usuario)
				.build()
		};
		insert opportunities;

		List<OpportunityLineItem> items = new List<OpportunityLineItem>{
			Build.anOpportunityLineItem()
				.withPricebookEntryId(entries[0])
				.withOpportunityId(opportunities[0])
				.withQuantity(1)
				.withSementecomercializada(199000)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withUnitPrice(3.50)
				.build(),
			Build.anOpportunityLineItem()
				.withPricebookEntryId(entries[1])
				.withOpportunityId(opportunities[0])
				.withQuantity(1)
				.withSementecomercializada(100000)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withUnitPrice(6.95)
				.build(),
			Build.anOpportunityLineItem()
				.withPricebookEntryId(entries[1])
				.withOpportunityId(opportunities[1])
				.withQuantity(1)
				.withSementecomercializada(40000)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withUnitPrice(6.95)
				.build(),
			Build.anOpportunityLineItem()
				.withPricebookEntryId(entries[2])
				.withOpportunityId(opportunities[2])
				.withQuantity(1)
				.withSementecomercializada(5000)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withUnitPrice(8.95)
				.build(),
			Build.anOpportunityLineItem()
				.withPricebookEntryId(entries[0])
				.withOpportunityId(opportunities[3])
				.withQuantity(1)
				.withSementecomercializada(450000)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withUnitPrice(3.50)
				.build(),
			Build.anOpportunityLineItem()
				.withPricebookEntryId(entries[0])
				.withOpportunityId(opportunities[4])
				.withQuantity(1)
				.withSementecomercializada(25000)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withUnitPrice(3.50)
				.build(),
			Build.anOpportunityLineItem()
				.withPricebookEntryId(entries[1])
				.withOpportunityId(opportunities[4])
				.withQuantity(1)
				.withSementecomercializada(50000)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withUnitPrice(6.95)
				.build(),
			Build.anOpportunityLineItem()
				.withPricebookEntryId(entries[0])
				.withOpportunityId(opportunities[5])
				.withQuantity(1000)
				.withSementecomercializada(50000)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withUnitPrice(3.50)
				.build(),
			Build.anOpportunityLineItem()
				.withPricebookEntryId(entries[1])
				.withOpportunityId(opportunities[5])
				.withQuantity(280)
				.withSementecomercializada(50000)
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withUnitPrice(6.95)
				.build()
		};
		insert items;
		opportunities[0].StageName = 'Approved';
		opportunities[1].StageName = 'Approved';
		// opportunities[2].StageName = 'Approved';
		update opportunities;
	}

	@isTest
	static void testApprovingFinalSalesReportShouldCreateRoyaltiesAndSnapshots() {
		Map<Id, Opportunity> opps = new Map<Id, Opportunity>(
			[SELECT Id, StageName FROM Opportunity WHERE StageName != 'Approved' AND Safra__c = '22/2022']
		);
		for (Opportunity opp : opps.values()) {
			opp.StageName = 'Approved';
		}
		Test.startTest();
		update opps.values();
		Test.stopTest();

		List<Opportunity> royalties = [SELECT Id FROM Opportunity WHERE Type = 'Z6 - Royalty'];
		List<Incentive_Snapshot__c> snaps = [SELECT Id, Brand__c, Season__c, Account__c FROM Incentive_Snapshot__c];

		System.assertEquals(opps.size(), royalties.size(), 'The system should create one royalty for each approved FSR');
		System.assertEquals(4, snaps.size());

		for (Opportunity updatedOpp : [
			SELECT Id, Incentive_Snapshot__c, AccountId, Safra__c, Marca__c
			FROM Opportunity
			WHERE Id IN :opps.keySet()
		]) {
			System.assertNotEquals(updatedOpp.Incentive_Snapshot__c, null);
			for (Incentive_Snapshot__c snap : snaps) {
				if (
					snap.Account__c == updatedOpp.AccountId &&
					snap.Brand__c.contains(updatedOpp.Marca__c) &&
					snap.Season__c == updatedOpp.Safra__c
				) {
					System.assertEquals(snap.Id, updatedOpp.Incentive_Snapshot__c);
				}
			}
		}
	}

	@isTest
	static void testIncentiveSnapshotValuesForBeckyAccount() {
		Id beckyAccount = [SELECT Id FROM Account WHERE Name = 'Becks Hybrids' LIMIT 1].Id;

		Incentive_Snapshot__c createdSnap = [
			SELECT
				Volume_Discount_Achieved__c,
				Unit_Totals__c,
				(SELECT Acomplished__c, Total_Discount__c FROM Incentive_Snapshot_Volume_Details__r),
				(SELECT Quantities_Acomplished__c, Unique_Varieties_Acomplished__c, Total_Discount__c FROM Incentive_Snapshot_Parent_Seed_Details__r)
			FROM Incentive_Snapshot__c
			WHERE Account__c = :beckyAccount
			LIMIT 1
		];
		List<Opportunity> royalties = [
			SELECT Id, 
			(SELECT Id, Product2.Tecnologia__c, UnitPrice, Royalty_discount_achieved__c FROM OpportunityLineItems)
			FROM Opportunity
			WHERE AccountId = :beckyAccount AND Type = 'Z6 - ROYALTY'
		];
		System.assertEquals(royalties.size(), 1);
		for (OpportunityLineItem item : royalties[0].OpportunityLineItems) {
			if (item.Product2.Tecnologia__c == 'ENLIST') {
				//Volume discount (now uses parent seed discount)
				// System.assertEquals(4.95, item.Royalty_discount_achieved__c);
				System.assertEquals(3.50, item.Royalty_discount_achieved__c);
			}
			if (item.Product2.Tecnologia__c == 'XTENDFLEX') {
				//Volume discount (now parent seed)
				// System.assertEquals(3, item.Royalty_discount_achieved__c);
				System.assertEquals(2.5, item.Royalty_discount_achieved__c);
			}
		}
		// Volume discount
		System.assertEquals(2.50, createdSnap.Incentive_Snapshot_Volume_Details__r[0].Total_Discount__c);
		System.assertEquals(2.50, createdSnap.Volume_Discount_Achieved__c);
		System.assertEquals(299000, createdSnap.Unit_Totals__c);
		// 42.71% (299.000) of 100% (700.000)
		System.assertEquals(42.71.round(), createdSnap.Incentive_Snapshot_Volume_Details__r[0].Acomplished__c.round());

		System.assertEquals(100.0.round(), createdSnap.Incentive_Snapshot_Parent_Seed_Details__r[0].Quantities_Acomplished__c.round());
		System.assertEquals(40.0.round(), createdSnap.Incentive_Snapshot_Parent_Seed_Details__r[0].Unique_Varieties_Acomplished__c.round());
		System.assertEquals(4.45, createdSnap.Incentive_Snapshot_Parent_Seed_Details__r[0].Total_Discount__c);
	}

	@isTest
	static void testIncentiveSnapshotValuesForBeckyAccount2() {
		Id beckyAccount = [SELECT Id FROM Account WHERE Name = 'Becks Hybrids' LIMIT 1].Id;
		Opportunity opp = [
			SELECT StageName, AccountId, (SELECT Semente_comercializada__c, Product2.Name FROM OpportunityLineItems)
			FROM Opportunity
			WHERE AccountId = :beckyAccount AND StageName = 'Approved' AND Safra__c = '22/2022'
			ORDER BY CreatedDate
			LIMIT 1
		];
		List<OpportunityLineItem> itemsToUpdate = new List<OpportunityLineItem>();
		// opp.StageName = 'Approved';
		// update opp;
		opp.StageName = 'Editable';
		opp.Incentive_Procesed__c = false;
		update opp;
		for (OpportunityLineItem item : opp.OpportunityLineItems) {
			if (item.Product2.Name == 'GDM34E251') {
				item.Semente_comercializada__c = 111000;
				itemsToUpdate.add(item);
			}
		}
		Test.startTest();
		update itemsToUpdate;
		opp.StageName = 'Approved';
		update opp;
		Test.stopTest();

		List<Incentive_Snapshot__c> createdSnaps = [
			SELECT
				Volume_Discount_Achieved__c,
				Unit_Totals__c,
				Parent_Seed_Totals__c,
				Unique_Varieties_Totals__c,
				(SELECT Acomplished__c, Total_Discount__c FROM Incentive_Snapshot_Volume_Details__r),
				(SELECT Quantities_Acomplished__c, Unique_Varieties_Acomplished__c, Total_Discount__c FROM Incentive_Snapshot_Parent_Seed_Details__r)
			FROM Incentive_Snapshot__c
			WHERE Account__c = :beckyAccount
		];

		List<Opportunity> royalties = [
			SELECT Id, (SELECT Id, Product2.Tecnologia__c, UnitPrice, Royalty_discount_achieved__c FROM OpportunityLineItems)
			FROM Opportunity
			WHERE AccountId = :beckyAccount AND Type = 'Z6 - ROYALTY'
		];

		System.assertEquals(1, createdSnaps.size());
		System.assert(royalties.size() > 0);
		System.assert(royalties[0].OpportunityLineItems.size() > 0);
		for (OpportunityLineItem item : royalties[0].OpportunityLineItems) {
			if (item.Product2.Tecnologia__c == 'ENLIST') {
				//Volume discount (now uses parent seed discount)
				// System.assertEquals(4.95, item.Royalty_discount_achieved__c);
				System.assertEquals(3.50, item.Royalty_discount_achieved__c);
			}
			if (item.Product2.Tecnologia__c == 'XTENDFLEX') {
				//Volume discount (now uses parent seed discount)
				// System.assertEquals(3, item.Royalty_discount_achieved__c.setScale(2));
				System.assertEquals(2.5, item.Royalty_discount_achieved__c.setScale(2));
			}
		}
		for (OpportunityLineItem item : royalties[1].OpportunityLineItems) {
			if (item.Product2.Tecnologia__c == 'ENLIST') {
				// System.assertEquals(4.95, item.Royalty_discount_achieved__c);
				// System.assertEquals(4.47, item.Royalty_discount_achieved__c.setScale(2));
				System.assertEquals(3.50, item.Royalty_discount_achieved__c);
			}
			if (item.Product2.Tecnologia__c == 'XTENDFLEX') {
				//Volume discount (now uses parent seed discount)
				// System.assertEquals(2.98, item.Royalty_discount_achieved__c.setScale(2));
				System.assertEquals(2.50, item.Royalty_discount_achieved__c.setScale(2));
			}
		}

		//Volume discount
		System.assertEquals(
			5.49.setScale(2),
			createdSnaps[0].Incentive_Snapshot_Volume_Details__r[0].Total_Discount__c.setScale(2)
		);
		System.assertEquals(5.49.setScale(2), createdSnaps[0].Volume_Discount_Achieved__c.setScale(2));
		System.assertEquals(310000, createdSnaps[0].Unit_Totals__c);
		// 42.71% (299.000) of 100% (700.000)
		System.assertEquals(
				44.29.setScale(2),
				createdSnaps[0].Incentive_Snapshot_Volume_Details__r[0].Acomplished__c.setScale(2)
			);
			
		//Parent seed discounts
		System.assertEquals(310000, createdSnaps[0].Unit_Totals__c);
		System.assertEquals(1280, createdSnaps[0].Parent_Seed_Totals__c);
		System.assertEquals(2, createdSnaps[0].Unique_Varieties_Totals__c);
		System.assertEquals(100.0.round(), createdSnaps[0].Incentive_Snapshot_Parent_Seed_Details__r[0].Quantities_Acomplished__c.round());
		System.assertEquals(40.0.round(), createdSnaps[0].Incentive_Snapshot_Parent_Seed_Details__r[0].Unique_Varieties_Acomplished__c.round());
		System.assertEquals(8.90, createdSnaps[0].Incentive_Snapshot_Parent_Seed_Details__r[0].Total_Discount__c);

		System.assertEquals(2, royalties.size());
	}

	@isTest
	static void testIncentiveSnapshotForStrattonCompanyShouldCreateOnlyOneIncentiveWhenThereAreTwoBrandsForTheSameContract() {
		Id strattAcc = [SELECT Id FROM Account WHERE Name = 'Stratton Seed Company' LIMIT 1].Id;
		Opportunity oppVirtue = [
			SELECT StageName
			FROM Opportunity
			WHERE AccountId = :strattAcc AND StageName != 'Approved' AND Marca__c = 'VIRTUE'
			LIMIT 1
		];
		Test.startTest();
		oppVirtue.StageName = 'Approved';
		update oppVirtue;
		Test.stopTest();

		List<Incentive_Snapshot__c> createdSnaps = [
			SELECT
				Volume_Discount_Achieved__c,
				Unit_Totals__c,
				Activity_Discount_Achieved__c,
				(SELECT Acomplished__c, Total_Discount__c FROM Incentive_Snapshot_Volume_Details__r)
			FROM Incentive_Snapshot__c
			WHERE Account__c = :strattAcc
		];
		List<Opportunity> royalties = [
			SELECT
				Id,
				Marca__c,
				(SELECT Id, Product2.Tecnologia__c, UnitPrice, Royalty_discount_achieved__c FROM OpportunityLineItems)
			FROM Opportunity
			WHERE AccountId = :strattAcc AND Type = 'Z6 - ROYALTY'
			ORDER BY CreatedDate
		];
		System.assertEquals(1, createdSnaps.size());
		System.assertEquals(2, royalties.size());
		for (Opportunity royalty : royalties) {
			if (royalty.Marca__c == 'VIRTUE') {
				for (OpportunityLineItem item : royalty.OpportunityLineItems) {
					if (item.Product2.Tecnologia__c == 'ENLIST') {
						System.assertEquals(5.04, item.Royalty_discount_achieved__c.setScale(2));
					}
					if (item.Product2.Tecnologia__c == 'CONVENTIONAL') {
						System.assertEquals(6.16, item.Royalty_discount_achieved__c.setScale(2));
					}
				}
			}
		}
		System.assertEquals(
			4.50.setScale(2),
			createdSnaps[0].Incentive_Snapshot_Volume_Details__r[0].Total_Discount__c.setScale(2)
		);
		System.assertEquals(4.50.setScale(2), createdSnaps[0].Volume_Discount_Achieved__c.setScale(2));
		System.assertEquals(0, createdSnaps[0].Activity_Discount_Achieved__c);
		System.assertEquals(45000, createdSnaps[0].Unit_Totals__c);
		// 95.74% (45000) of 100% (470000)
		System.assertEquals(
			95.74.setScale(2),
			createdSnaps[0].Incentive_Snapshot_Volume_Details__r[0].Acomplished__c.setScale(2)
		);
	}

	@isTest
	static void testXaccountScenario() {
		Id xAccount = [SELECT Id FROM Account WHERE Name = 'Account X' LIMIT 1].Id;
		Opportunity opp = [
			SELECT StageName, AccountId
			FROM Opportunity
			WHERE AccountId = :xAccount
			ORDER BY CreatedDate
			LIMIT 1
		];
		Test.startTest();
		opp.StageName = 'Approved';
		update opp;

		Test.stopTest();

		List<Incentive_Snapshot__c> createdSnaps = [
			SELECT
				Volume_Discount_Achieved__c,
				Unit_Totals__c,
				(SELECT Acomplished__c, Total_Discount__c FROM Incentive_Snapshot_Volume_Details__r)
			FROM Incentive_Snapshot__c
			WHERE Account__c = :xAccount
		];

		List<Opportunity> royalties = [
			SELECT Id, (SELECT Id, Product2.Tecnologia__c, UnitPrice, Royalty_discount_achieved__c FROM OpportunityLineItems)
			FROM Opportunity
			WHERE AccountId = :xAccount AND Type = 'Z6 - ROYALTY'
		];

		System.assertEquals(1, createdSnaps.size());
		System.assert(royalties.size() > 0);
		System.assert(royalties[0].OpportunityLineItems.size() > 0);
		for (OpportunityLineItem item : royalties[0].OpportunityLineItems) {
			if (item.Product2.Tecnologia__c == 'XTENDFLEX') {
				System.assertEquals(2.85, item.Royalty_discount_achieved__c.setScale(2));
			}
		}
		System.assertEquals(
			0.65.setScale(2),
			createdSnaps[0].Incentive_Snapshot_Volume_Details__r[0].Total_Discount__c.setScale(2)
		);
		System.assertEquals(0.65.setScale(2), createdSnaps[0].Volume_Discount_Achieved__c.setScale(2));
		System.assertEquals(450000, createdSnaps[0].Unit_Totals__c);
		// 64.29% (450000) of 100% (700.000)
		System.assertEquals(
			64.29.setScale(2),
			createdSnaps[0].Incentive_Snapshot_Volume_Details__r[0].Acomplished__c.setScale(2)
		);

		// System.assertEquals(2, royalties.size());
	}

	@isTest
	static void testYaccountScenario() {
		Id xAccount = [SELECT Id FROM Account WHERE Name = 'Account Y' LIMIT 1].Id;
		Opportunity opp = [
			SELECT StageName, AccountId
			FROM Opportunity
			WHERE AccountId = :xAccount
			ORDER BY CreatedDate
			LIMIT 1
		];
		Test.startTest();
		opp.StageName = 'Approved';
		update opp;

		Test.stopTest();

		List<Incentive_Snapshot__c> createdSnaps = [
			SELECT
				Volume_Discount_Achieved__c,
				Unit_Totals__c,
				(SELECT Acomplished__c, Total_Discount__c FROM Incentive_Snapshot_Volume_Details__r)
			FROM Incentive_Snapshot__c
			WHERE Account__c = :xAccount
		];

		List<Opportunity> royalties = [
			SELECT Id, (SELECT Id, Product2.Tecnologia__c, UnitPrice, Royalty_discount_achieved__c FROM OpportunityLineItems)
			FROM Opportunity
			WHERE AccountId = :xAccount AND Type = 'Z6 - ROYALTY'
		];

		System.assertEquals(1, createdSnaps.size());
		System.assert(royalties.size() > 0);
		System.assert(royalties[0].OpportunityLineItems.size() > 0);
		for (OpportunityLineItem item : royalties[0].OpportunityLineItems) {
			if (item.Product2.Tecnologia__c == 'XTENDFLEX') {
				System.assertEquals(2.74, item.Royalty_discount_achieved__c.setScale(2));
			}
			if (item.Product2.Tecnologia__c == 'ENLIST') {
				System.assertEquals(4.94, item.Royalty_discount_achieved__c.setScale(2));
			}
		}
		// System.assertEquals(
		// 	2.74.setScale(2),
		// 	createdSnaps[0].Incentive_Snapshot_Volume_Details__r[0].Total_Discount__c.setScale(2)
		// );
		// System.assertEquals(2.74.setScale(2), createdSnaps[0].Volume_Discount_Achieved__c.setScale(2));
		System.assertEquals(75000, createdSnaps[0].Unit_Totals__c);
		// 64.29% (450000) of 100% (700.000)
		System.assertEquals(
			75.00.setScale(2),
			createdSnaps[0].Incentive_Snapshot_Volume_Details__r[0].Acomplished__c.setScale(2)
		);

		// System.assertEquals(2, royalties.size());
	}

	@isTest static void testActivityDiscount(){
		Id beckyAccount = [SELECT Id FROM Account WHERE Name = 'Becks Hybrids' LIMIT 1].Id;
		Opportunity opp = [SELECT Id, StageName, Incentive_Snapshot__c FROM Opportunity WHERE Name = 'Beckys FSR GDM' LIMIT 1];
		Incentive_Snapshot__c snapshot = [SELECT Id FROM Incentive_Snapshot__c WHERE Id =: opp.Incentive_Snapshot__c];
		List<Opportunity> royalties = [
			SELECT Id, (SELECT Id, Product2.Tecnologia__c, UnitPrice, Royalty_discount_achieved__c FROM OpportunityLineItems)
			FROM Opportunity
			WHERE AccountId = :beckyAccount AND Type = 'Z6 - ROYALTY'
		];
		Incentive_Contract__c ic = [SELECT Id,Incentive_Activity_Code__c FROM Incentive_Contract__c WHERE Name = 'Incentive GDM Becks Hybrids' LIMIT 1];
		delete royalties;
		delete snapshot;
		opp.StageName = 'Editable';
		update opp;
		Incentive_Activity_Code__c activityCode = new Incentive_Activity_Code__c(Name = 'Activity code 1');
		insert activityCode;
		Incentive_Activity_Code_Detail__c activityDetail = new Incentive_Activity_Code_Detail__c(Name = 'Detail 1', Discount_Amount__c = 0.6, Activities_Needed__c = 2, isLastDiscount__c = true, Incentive_Activity_Code__c = activityCode.Id);
		insert activityDetail;
		Incentive_Contract_Activity_Goal__c activityGoal = new Incentive_Contract_Activity_Goal__c(Name = 'Goal', Activities_Done__c = 2, Incentive_Contract__c = ic.Id);
		insert activityGoal;
		ic.Incentive_Activity_Code__c = activityCode.Id;
		update ic;
		
		Test.startTest();
		opp.StageName = 'Approved';
		update opp;
		Test.stopTest();

		List<Incentive_Snapshot__c> createdSnaps = [
			SELECT Id,
			(SELECT Id, Discount__c
			FROM Incentive_Snapshot_Activity_Details__r
			ORDER BY CreatedDate DESC)
			FROM Incentive_Snapshot__c
			WHERE Account__c = :beckyAccount
		];

		royalties = [
			SELECT Id, (SELECT Id, Product2.Tecnologia__c, UnitPrice, Royalty_discount_achieved__c FROM OpportunityLineItems)
			FROM Opportunity
			WHERE AccountId = :beckyAccount AND Type = 'Z6 - ROYALTY' LIMIT 1
		];

		System.assertEquals(1, createdSnaps.size());
		System.assert(royalties.size() > 0);
		System.assert(royalties[0].OpportunityLineItems.size() > 0);
		for (OpportunityLineItem item : royalties[0].OpportunityLineItems) {
			if (item.Product2.Tecnologia__c == 'ENLIST') {
				//Volume discount (now uses parent seed discount)
				// System.assertEquals(4.95, item.Royalty_discount_achieved__c);
				System.assertEquals(2.9, item.Royalty_discount_achieved__c);
			}
			if (item.Product2.Tecnologia__c == 'XTENDFLEX') {
				//Volume discount (now uses parent seed discount)
				// System.assertEquals(3, item.Royalty_discount_achieved__c.setScale(2));
				System.assertEquals(1.9, item.Royalty_discount_achieved__c.setScale(2));
			}
		}

		System.assertEquals(0.6, createdSnaps[0].Incentive_Snapshot_Activity_Details__r[0].Discount__c);

	}
}