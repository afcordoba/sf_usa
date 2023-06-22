/**
 * @description       :
 * @author            : Horacio Calleja
 * @group             :
 * @last modified on  : 01-17-2023
 * @last modified by  : Horacio Calleja
 **/
@isTest
private class OpportunityLineItemTriggerTest {
	@TestSetup
	static void makeData() {
		List<Opportunity> opps = new List<Opportunity>();
		List<OpportunityLineItem> oppProds = new List<OpportunityLineItem>();
		Variedad__c variety = Build.aVariedad().withName('Variety').build();
		List<Product2> productsToUpdate = new List<Product2>();
		insert variety;
		Product2 aProduct = Build.aProduct2()
			.withName('Product 1')
			.withIsActive(true)
			.withVariedade(variety)
			.withUNIDADE('BAG 140K')
			.withCANTIDADSUBUNIDAD('140')
			.build();
		// insert aProduct;
		productsToUpdate.add(aProduct);
		Product2 aRoyaltyProduct = Build.aProduct2()
			.withName('Product 1')
			.withIsActive(true)
			.withFamily('Royalty')
			.withVariedade(variety)
			.withUNIDADE('BAG 140K')
			.build();
		// insert aRoyaltyProduct;
		productsToUpdate.add(aRoyaltyProduct);
		insert productsToUpdate;
		Pricebook2 pricebook = Build.aPricebook2().withBrand('GDM').withName('Pricebook GDM').withIsActive(true).build();
		insert pricebook;
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

		Account anAccount = Build.anAccount().withName('Test').build();
		insert anAccount;
		Opportunity saleReport = Build.anOpportunitySalesReport()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		opps.add(saleReport);
		Opportunity reservationOpp = Build.anOpportunitySalesReport()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		opps.add(reservationOpp);
		Opportunity saleOpp = Build.anOpportunitySale()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		opps.add(saleOpp);
		Opportunity stockOpp = Build.anOpportunityStockperPlant()
			.withName('Stock opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.withStageName('Inventory')
			.build();
		opps.add(stockOpp);

		Opportunity prodReport = Build.anOpportunityProductionReport()
			.withName('Prod report opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		opps.add(prodReport);
		insert opps;
		OpportunityLineItem itemStock = Build.anOpportunityLineItem()
			.withPricebookEntryId(pbeOneGdm)
			.withInventoryStatus('Pending')
			.withOpportunityId(stockOpp)
			.withTotalPrice(10)
			.withQuantity(1000)
			.withCentrodedespacho('E002 - B&B - GIBSON CITY')
			.withWarehouse('DEVE-DEVELOPMENT')
			.withReturnedQuantity(0)
			.withMotivodeRechazo('asd')
			.build();
		oppProds.add(itemStock);
		OpportunityLineItem itemProdReport = Build.anOpportunityLineItem()
			.withPricebookEntryId(pbeOneGdm)
			.withOpportunityId(prodReport)
			.withTotalPrice(10)
			.withQuantity(1)
			.withCentrodedespacho('E002 - B&B - GIBSON CITY')
			.build();

		oppProds.add(itemProdReport);
		insert oppProds;
		Seed_Tracking__c seedTrack = Build.aSeedTracking()
			.withAccount(anAccount)
			.withActive(true)
			.withBrand('GDM')
			.withProduct(aProduct)
			.withVariety(variety)
			.withWarehouse('E002 - B&B - GIBSON CITY')
			.withSaleOrder(stockOpp)
			.build();
		insert seedTrack;
		Configuracion_USA__c config = Build.aConfiguracionUSA()
			.withName('Adminsettings')
			.withLastSeason('21/2021')
			.withActiveSeason('22/2022')
			.withSalesAdminEmail('hc@glb.com')
			.withRecordTypeforOppNro('AnexoI,Sales_report,Production_report')
			.build();
		insert config;
		Contrato__c contract = Build.aContratoParentSeedScheduleA()
			.withBrand('GDM')
			.withSafra('22/2022')
			.withMultiplicador(anAccount)
			.build();
		insert contract;
		Item_del_contrato__c itemContrato = Build.anItemdelContrato()
			.withActive(true)
			.withCultivar(aRoyaltyProduct)
			.withContratodeMultiplicacion(contract)
			.build();
		insert itemContrato;
	}

	@isTest
	static void testApprovedItemsShouldPass() {
		OpportunityLineItem itemToApprove = [
			SELECT Id, Inventory_Status__c, Variedade_de_Produto__c, Customer_Status__c, Customer_ETA__c, Product2Id
			FROM OpportunityLineItem
			WHERE Inventory_Status__c != 'Approved' AND Opportunity.RecordType.DeveloperName = 'Stock_per_Plant'
			LIMIT 1
		];
		itemToApprove.Customer_Status__c = 'Approved';
		itemToApprove.Customer_ETA__c = '3/24/2022 - 3/31/2022';
		itemToApprove.Inventory_Status__c = 'Approved';
		Test.startTest();
		update itemToApprove;
		Test.stopTest();

		Seed_Tracking__c seedTrackUpdated = [
			SELECT Id, Status__c, ETA_Customer__c
			FROM Seed_Tracking__c
			WHERE Product__c = :itemToApprove.Product2Id
			LIMIT 1
		];
		System.assertEquals(
			itemToApprove.Customer_Status__c,
			seedTrackUpdated.Status__c,
			'Customer status should be equal as the opportunity product once approved'
		);
		System.assertEquals(
			itemToApprove.Customer_ETA__c,
			seedTrackUpdated.ETA_Customer__c,
			'Customer ETA should be equal as the opportunity product once approved'
		);
	}

	@isTest
	static void traitLicenseNotifications() {
		OpportunityLineItem itemProdReport = [
			SELECT Id, Licensee_Variety_Name__c
			FROM OpportunityLineItem
			WHERE Opportunity.RecordType.DeveloperName = 'Production_Report' AND Licensee_Variety_Name__c = NULL
			LIMIT 1
		];
		itemProdReport.Licensee_Variety_Name__c = '1234';
		Test.startTest();
		update itemProdReport;
		Test.stopTest();
	}

	@isTest
	static void testUpdatingLicenseeVarietyNameOfOppProductShouldUpdateScheduleAVarietyWithSameVarietySeasonAndBrand() {
		OpportunityLineItem itemProdReport = [
			SELECT
				Id,
				Licensee_Variety_Name__c,
				Opportunity.Marca__c,
				Opportunity.Safra__c,
				Opportunity.AccountId,
				Variedade_de_Produto__c
			FROM OpportunityLineItem
			WHERE Opportunity.RecordType.DeveloperName = 'Production_Report' AND Licensee_Variety_Name__c = NULL
			LIMIT 1
		];
		itemProdReport.Licensee_Variety_Name__c = '1234';
		Test.startTest();
		update itemProdReport;
		Test.stopTest();
		Item_del_Contrato__c itemUpdated = [
			SELECT Id, Licensee_Variety_ID__c
			FROM Item_del_Contrato__c
			WHERE
				Contrato_de_multiplicacion__r.Safra__c = :itemProdReport.Opportunity.Safra__c
				AND Contrato_de_multiplicacion__r.Brand__c = :itemProdReport.Opportunity.Marca__c
				AND Contrato_de_multiplicacion__r.Multiplicador__c = :itemProdReport.Opportunity.AccountId
				AND Variedade__c = :itemProdReport.Variedade_de_Produto__c
			LIMIT 1
		];

		System.assertEquals(
			itemProdReport.Licensee_Variety_Name__c,
			itemUpdated.Licensee_Variety_ID__c,
			'Updating Licensee variety name on opp prod should update licenses variety brand with same Variety, Brand and Season'
		);
	}

	@isTest
	static void testHandleInventoryShouldUpdateStockAvailable() {
		Account anAccount = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
		Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Pricebook GDM' LIMIT 1];
		Variedad__c variety = [SELECT Id FROM Variedad__c LIMIT 1];
		PricebookEntry pbe = [
			SELECT Id, Product2Id
			FROM PricebookEntry
			WHERE Product2.Variedade__c = :variety.Id AND Pricebook2Id = :pricebook.Id
			LIMIT 1
		];

		OpportunityLineItem itemStockBeforeUpdate = [
			SELECT Id, Quantity, Amount_Sold__c
			FROM OpportunityLineItem
			WHERE Name = 'Stock opp Product 1'
			LIMIT 1
		];

		Opportunity saleOpp = [
			SELECT Id, Safra__c, Marca__c
			FROM Opportunity
			WHERE RecordType.DeveloperName = 'Sale'
			LIMIT 1
		];
		OpportunityLineItem itemSale = Build.anOpportunityLineItem()
			.withPricebookEntryId(pbe)
			.withOpportunityId(saleOpp)
			.withQuantity(90)
			.withTotalPrice(10)
			.withCentrodedespacho('E002 - B&B - GIBSON CITY')
			.withWarehouse('DEVE-DEVELOPMENT')
			.build();
		Test.startTest();
		insert itemSale;
		Test.stopTest();

		System.assertEquals(itemSale.Quantity, itemStockBeforeUpdate.Amount_Sold__c + itemSale.Quantity);
	}

	@isTest
	static void testInsertingOppProductShouldUpdateRelatedScheduleALicenseeField() {
		Account anAccount = [SELECT Id FROM Account LIMIT 1];
		Product2 aRoyaltyProduct = [
			SELECT Id, Variedade__c
			FROM Product2
			WHERE Name = 'Product 1' AND Family = 'Royalty' AND Variedade__r.Name = 'Variety'
		];
		Pricebook2 thePricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Pricebook GDM' LIMIT 1];
		Opportunity anOpp = [
			SELECT Id, Safra__c, Marca__c, AccountId
			FROM Opportunity
			WHERE
				Marca__c = 'GDM'
				AND Safra__c = '22/2022'
				AND AccountId = :anAccount.Id
				AND Opportunity.RecordType.DeveloperName = 'Production_Report'
			LIMIT 1
		];
		PricebookEntry pbeOneStndr = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(Test.getStandardPricebookId())
			.withProduct2Id(aRoyaltyProduct)
			.withUnitPrice(1)
			.build();
		insert pbeOneStndr;
		PricebookEntry pbeOneGdm = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(thePricebook)
			.withProduct2Id(aRoyaltyProduct)
			.withUnitPrice(1)
			.build();
		insert pbeOneGdm;
		OpportunityLineItem item = Build.anOpportunityLineItem()
			.withPricebookEntryId(pbeOneGdm)
			.withOpportunityId(anOpp)
			.withTotalPrice(10)
			.withQuantity(1)
			.withCentrodedespacho('E002 - B&B - GIBSON CITY')
			.build();
		item.Licensee_Variety_Name__c = '12345678910';
		Test.startTest();
		insert item;
		Test.stopTest();

		OpportunityLineItem itemInserted = [SELECT Variedade_de_Produto__c FROM OpportunityLineItem WHERE Id = :item.Id];

		Item_del_Contrato__c itemUpdated = [
			SELECT Id, Licensee_Variety_ID__c
			FROM Item_del_Contrato__c
			WHERE
				Contrato_de_multiplicacion__r.Safra__c = :anOpp.Safra__c
				AND Contrato_de_multiplicacion__r.Brand__c = :anOpp.Marca__c
				AND Contrato_de_multiplicacion__r.Multiplicador__c = :anOpp.AccountId
				AND Variedade__c = :itemInserted.Variedade_de_Produto__c
			LIMIT 1
		];
		System.assertEquals(
			item.Licensee_Variety_Name__c,
			itemUpdated.Licensee_Variety_ID__c,
			'Updating Licensee variety name on opp prod should update licenses variety brand with same Variety, Brand and Season'
		);
	}

	@isTest
	static void testHandleInventoryWhenAProductIsEdited() {
		Opportunity saleOpp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Sale' LIMIT 1];
		Opportunity stockOpp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Stock_per_Plant' LIMIT 1];
		List<PricebookEntry> products = createProducts(2);
		List<OpportunityLineItem> stockProducts = createOppProducts(products, stockOpp, 1000);
		List<OpportunityLineItem> saleProducts = createOppProducts(products, saleOpp, 100);
		List<OpportunityLineItem> items = new List<OpportunityLineItem>();
		items.addAll(stockProducts);
		items.addAll(saleProducts);
		Set<Id> stockProdIds = new Set<Id>();
		saleProducts.addAll(stockProducts);
		// insert stockProducts;
		// insert saleProducts;
		insert items;
		for (OpportunityLineItem stockProd : stockProducts) {
			stockProdIds.add(stockProd.Id);
		}
		for (OpportunityLineItem saleProd : saleProducts) {
			saleProd.Quantity = 50;
		}
		Test.startTest();
		update saleProducts;
		Test.stopTest();

		List<OpportunityLineItem> updatedStocks = [
			SELECT Id, PricebookEntry.Product2.Variedade__c, Quantity, Amount_Sold__c
			FROM OpportunityLineItem
			WHERE Id IN :stockProdIds
		];

		for (OpportunityLineItem updatedStock : updatedStocks) {
			for (OpportunityLineItem saleProd : saleProducts) {
				if (updatedStock.PricebookEntry.Product2.Variedade__c == saleProd.Variedade_de_Produto__c) {
					System.assertEquals(50, updatedStock.Amount_Sold__c);
				}
			}
		}
	}

	@isTest
	static void testSendNotificationWhenNeedToStock() {
		Opportunity saleOpp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Sale' LIMIT 1];
		Opportunity stockOpp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Stock_per_Plant' LIMIT 1];
		List<PricebookEntry> products = createProducts(2);
		List<OpportunityLineItem> stockProducts = createOppProducts(products, stockOpp, 1000);
		List<OpportunityLineItem> saleProducts = createOppProducts(products, saleOpp, 2000);
		Set<Id> stockProdIds = new Set<Id>();
		insert stockProducts;
		Test.startTest();
		insert saleProducts;
		Test.stopTest();

		List<OpportunityLineItem> updatedStocks = [
			SELECT Id, PricebookEntry.Product2.Variedade__c, Quantity, Amount_Sold__C
			FROM OpportunityLineItem
			WHERE Id IN :stockProdIds
		];

		for (OpportunityLineItem updatedStock : updatedStocks) {
			for (OpportunityLineItem saleProd : saleProducts) {
				if (updatedStock.PricebookEntry.Product2.Variedade__c == saleProd.Variedade_de_Produto__c) {
					System.assertEquals(2000, updatedStock.Amount_Sold__c);
				}
			}
		}
	}
	@isTest
	static void testHandleDeletionShouldCreateObjectRegistroEliminacion() {
		OpportunityLineItem item = [SELECT Id FROM OpportunityLineItem LIMIT 1];
		Test.startTest();
		delete item;
		Test.stopTest();
		Registro_de_Eliminacion__c itemDeleted = [
			SELECT Id_reg_objeto__c, Fecha_eliminacion__c, Nombre_objeto__c
			FROM Registro_de_Eliminacion__c
			WHERE Id_reg_objeto__c = :item.Id
			LIMIT 1
		];

		System.assertNotEquals(null, itemDeleted);
		System.assertEquals(item.Id, itemDeleted.Id_reg_objeto__c);
		System.assertEquals(system.today(), itemDeleted.Fecha_eliminacion__c);
		System.assertEquals('OpportunityLineItem', itemDeleted.Nombre_objeto__c);
	}

	@isTest
	static void testChangePLantShouldChangeWarehouse() {
		List<String> codes = new List<String>{
			'E001',
			'E002',
			'E003',
			'E004',
			'U002',
			'U003',
			'U004',
			'U005',
			'U006',
			'U001',
			'Other'
		};
		Opportunity oppToRelate = [SELECT Id FROM Opportunity LIMIT 1];
		List<OpportunityLineItem> items = createOppProductsWithCentroDespacho(
			createProducts(codes.size()),
			oppToRelate,
			10,
			codes
		);
		Set<Id> ids = new Set<Id>();
		for (OpportunityLineItem item : items) {
			ids.add(item.Id);
		}
		Test.startTest();
		insert items;
		Test.stopTest();

		List<OpportunityLineItem> updatedItems = [
			SELECT Id, Centro_de_despacho__c
			FROM OpportunityLineItem
			WHERE Id IN :ids
		];
		for (OpportunityLineItem i : updatedItems) {
			for (OpportunityLineItem oldItem : items) {
				if (oldItem.Id == i.Id) {
					switch on oldItem.Centro_de_despacho__c {
						when 'E001' {
							System.assertEquals('E001 - B&B - CHAMPAIGN', i.Centro_de_despacho__c);
						}
						when 'E002' {
							System.assertEquals('E002 - B&B - GIBSON CITY', i.Centro_de_despacho__c);
						}
						when 'E003' {
							System.assertEquals('E003 - B&B - JONESBORO', i.Centro_de_despacho__c);
						}
						when 'E004' {
							System.assertEquals('E004 - B&B - PRO AG', i.Centro_de_despacho__c);
						}
						when 'U002' {
							System.assertEquals('U002 - GDM - GIBSON CITY', i.Centro_de_despacho__c);
						}
						when 'U003' {
							System.assertEquals('U003 - GDM - JONESBORO', i.Centro_de_despacho__c);
						}
						when 'U004' {
							System.assertEquals('U004 - GDM - PRO AG', i.Centro_de_despacho__c);
						}
						when 'U005' {
							System.assertEquals('U005 - GDM - HUTCHINSON', i.Centro_de_despacho__c);
						}
						when 'U006' {
							System.assertEquals('U006 - GDM - DES MOINES', i.Centro_de_despacho__c);
						}
						when 'U001' {
							System.assertEquals('U001 - GDM - CHAMPAIGN', i.Centro_de_despacho__c);
						}
						when else {
							System.assertEquals('not found', i.Centro_de_despacho__c);
						}
					}
				}
			}
		}
	}

	@isTest
	static void testSetNetPriceAndType() {
		Opportunity productionReport = [
			SELECT Id, RecordType.Name, Type
			FROM Opportunity
			WHERE RecordType.Name = 'Production Report'
			LIMIT 1
		];
		Opportunity salesReport = [SELECT Id, Type FROM Opportunity WHERE RecordType.Name = 'Sales Report' LIMIT 1];
		List<OpportunityLineItem> itemsProductionReport = createOppProducts(createProducts(2), productionReport, 10);
		List<OpportunityLineItem> itemsSales = createOppProducts(createProducts(2), salesReport, 10);
		Set<Id> idsProductionReport = new Set<Id>();
		Set<Id> idsSales = new Set<Id>();

		List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
		itemsToInsert.addAll(itemsProductionReport);
		itemsToInsert.addAll(itemsSales);
		Test.startTest();
		insert itemsToInsert;
		Test.stopTest();

		for (OpportunityLineItem itemProdReport : itemsProductionReport) {
			idsProductionReport.add(itemProdReport.Id);
		}
		for (OpportunityLineItem itemSale : itemsSales) {
			idsSales.add(itemSale.Id);
		}

		List<OpportunityLineItem> itemsProductionReportUpdated = [
			SELECT Id, Qty_x_Price__c, Sales_Report_Type__c, Sub_Amount__c
			FROM OpportunityLineItem
			WHERE Id IN :idsProductionReport
		];
		List<OpportunityLineItem> itemSalesReportUpdated = [
			SELECT Id, Qty_x_Price__c, Sales_Report_Type__c, Sub_Amount__c
			FROM OpportunityLineItem
			WHERE Id IN :idsSales
		];

		for (OpportunityLineItem itemProdReport : itemsProductionReportUpdated) {
			System.assertEquals(itemProdReport.Sub_Amount__c, itemProdReport.Qty_x_Price__c);
			System.assertEquals(itemProdReport.Sales_Report_Type__c, productionReport.Type);
		}

		for (OpportunityLineItem itemSales : itemSalesReportUpdated) {
			System.assertEquals(itemSales.Sub_Amount__c, itemSales.Qty_x_Price__c);
			System.assertEquals(itemSales.Sales_Report_Type__c, 'Sale');
		}
	}

	@isTest
	static void testCreateProductChangeWhenQuantityOfStockChanges() {
		Opportunity stock = [SELECT Id, Type FROM Opportunity WHERE RecordType.DeveloperName = 'Stock_per_Plant' LIMIT 1];
		List<OpportunityLineItem> itemsStock = createOppProducts(createProducts(2), stock, 10);
		Set<Id> idsStock = new Set<Id>();
		insert itemsStock;
		for (OpportunityLineItem iStock : itemsStock) {
			iStock.Centro_de_despacho__c = 'E001 - B&B - CHAMPAIGN';
		}
		Test.startTest();
		update itemsStock;
		Test.stopTest();

		for (OpportunityLineItem itemStock : itemsStock) {
			idsStock.add(itemStock.Id);
		}

		List<Opportunity_Product_Change__c> productsChange = [SELECT Id FROM Opportunity_Product_Change__c];

		System.assert(productsChange != null);
		System.assert(productsChange.size() == 2);
	}

	@isTest
	static void testInsertReservationProductShouldIncreaseReservationQuantityFieldInOppProduct() {
		Account anAccount = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
		Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Pricebook GDM' LIMIT 1];
		Variedad__c variety = [SELECT Id FROM Variedad__c LIMIT 1];
		Opportunity stock = [SELECT Id, Type FROM Opportunity WHERE RecordType.DeveloperName = 'Stock_per_Plant' LIMIT 1];
		Opportunity reservationOpp = Build.anOpportunityReservation()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		insert reservationOpp;
		List<OpportunityLineItem> itemsStock = createOppProducts(createProducts(2), stock, 10);
		Set<Id> idsStock = new Set<Id>();
		for (OpportunityLineItem itemStock : itemsStock) {
			idsStock.add(itemStock.Id);
		}
		insert itemsStock;
		List<OpportunityLineItem> itemsReservation = createOppProducts(createProducts(2), reservationOpp, 10);
		Test.startTest();
		insert itemsReservation;
		Test.stopTest();

		itemsStock = [SELECT Id, Reservation_Quantity__c FROM OpportunityLineItem WHERE Id IN :idsStock];

		for (OpportunityLineItem itemStock : itemsStock) {
			System.assertEquals(10, itemStock.Reservation_Quantity__c);
		}
	}

	@isTest
	static void testUpdateReservationProductShouldIncreaseReservationQuantityFieldInOppProduct() {
		List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
		Account anAccount = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
		Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Pricebook GDM' LIMIT 1];
		Variedad__c variety = [SELECT Id FROM Variedad__c LIMIT 1];
		Opportunity stock = [SELECT Id, Type FROM Opportunity WHERE RecordType.DeveloperName = 'Stock_per_Plant' LIMIT 1];
		Opportunity reservationOpp = Build.anOpportunityReservation()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		insert reservationOpp;
		List<OpportunityLineItem> itemsStock = createOppProducts(createProducts(2), stock, 10);
		Set<Id> idsStock = new Set<Id>();
		for (OpportunityLineItem itemStock : itemsStock) {
			itemsToInsert.add(itemStock);
			// idsStock.add(itemStock.Id);
		}
		
		// insert itemsStock;
		List<OpportunityLineItem> itemsReservation = createOppProducts(createProducts(2), reservationOpp, 10);
		// insert itemsReservation;
		for (OpportunityLineItem itemReservation : itemsReservation) {
			itemsToInsert.add(itemReservation);
		}
		insert itemsToInsert;
		Test.startTest();
		for (OpportunityLineItem itemReservation : itemsReservation) {
			itemsToInsert.add(itemReservation);
			itemReservation.Quantity = 5;
		}
		update itemsReservation;
		Test.stopTest();

		for (OpportunityLineItem itemStock : itemsStock) {
			idsStock.add(itemStock.Id);
		}

		itemsStock = [SELECT Id, Reservation_Quantity__c FROM OpportunityLineItem WHERE Id IN :idsStock];

		for (OpportunityLineItem itemStock : itemsStock) {
			System.assertEquals(15, itemStock.Reservation_Quantity__c);
		}
	}

	@isTest
	static void testUpdateOpportunitySeasonShouldUpdateRelatedItemValues() {
		Account anAccount = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
		Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Pricebook GDM' LIMIT 1];
		Variedad__c variety = [SELECT Id FROM Variedad__c LIMIT 1];
		Opportunity stock = [SELECT Id, Type FROM Opportunity WHERE RecordType.DeveloperName = 'Stock_per_Plant' LIMIT 1];
		List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
		Opportunity reservationOpp = Build.anOpportunityReservation()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('21/2021')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		insert reservationOpp;
		Opportunity saleOpp = Build.anOpportunitySale()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('21/2021')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		insert saleOpp;
		List<OpportunityLineItem> itemsStock = createOppProducts(createProducts(2), stock, 10);
		Set<Id> idsStock = new Set<Id>();
		for (OpportunityLineItem itemStock : itemsStock) {
			idsStock.add(itemStock.Id);
		}
		// insert itemsStock;
		List<OpportunityLineItem> itemsReservation = createOppProducts(createProducts(2), reservationOpp, 10);
		List<OpportunityLineItem> itemsSales = createOppProducts(createProducts(2), saleOpp, 12);
		itemsToInsert.addAll(itemsReservation);
		itemsToInsert.addAll(itemsSales);
		itemsToInsert.addAll(itemsStock);
		// insert itemsReservation;
		// insert itemsSales;
		insert itemsToInsert;
		List<OpportunityLineItem> itemsBeforeUpdate = [
			SELECT Id, Reservation_Quantity__c, Amount_Sold__c
			FROM OpportunityLineItem
			WHERE OpportunityId = :stock.Id
		];
		Test.startTest();
		reservationOpp.Safra__c = '22/2022';
		saleOpp.Safra__c = '22/2022';
		List<Opportunity> oppsToUpdate = new List<Opportunity>{ reservationOpp, saleOpp };
		update oppsToUpdate;
		Test.stopTest();

		itemsStock = [SELECT Id, Reservation_Quantity__c, Amount_Sold__c FROM OpportunityLineItem WHERE Id IN :idsStock];

		for (OpportunityLineItem itemBeforeUpdate : itemsBeforeUpdate) {
			System.assertEquals(0, itemBeforeUpdate.Reservation_Quantity__c);
			System.assertEquals(0, itemBeforeUpdate.Amount_Sold__C);
		}

		for (OpportunityLineItem itemStock : itemsStock) {
			System.assertEquals(10, itemStock.Reservation_Quantity__c);
			System.assertEquals(12, itemStock.Amount_Sold__C);
		}
	}

	@isTest
	static void testAddingNotExistentProductToASaleShouldSendMissingStockNotification() {
		Account anAccount = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
		Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Pricebook GDM' LIMIT 1];
		Variedad__c variety = [SELECT Id FROM Variedad__c LIMIT 1];
		Opportunity stock = [SELECT Id, Type FROM Opportunity WHERE RecordType.DeveloperName = 'Stock_per_Plant' LIMIT 1];
		Opportunity reservationOpp = Build.anOpportunityReservation()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		insert reservationOpp;
		List<OpportunityLineItem> itemsReservation = createOppProducts(createProducts(2), reservationOpp, 10);
		Test.startTest();
		insert itemsReservation;
		Test.stopTest();

		//No asserts because it's a salesforce notificaiton
	}

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
				.withCentrodedespacho('E002 - B&B - GIBSON CITY')
				.withWarehouse('DEVE-DEVELOPMENT')
				.build();
			oppProducts.add(oppProduct);
		}
		return oppProducts;
	}

	@isTest
	static void testDeletionOfOlisShouldReduceQuantityInInventory() {
		List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
		Account anAccount = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
		Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Pricebook GDM' LIMIT 1];
		Variedad__c variety = [SELECT Id FROM Variedad__c LIMIT 1];
		Opportunity stock = [SELECT Id, Type FROM Opportunity WHERE RecordType.DeveloperName = 'Stock_per_Plant' LIMIT 1];
		Opportunity reservationOpp = Build.anOpportunityReservation()
			.withName('Sale opp')
			.withAccountId(anAccount)
			.withSafra('22/2022')
			.withTipo('Z2 - PARENT SEED')
			.withType('Z2 - PARENT SEED')
			.withSeedType('Parent Seed')
			.withMarca('GDM')
			.withPricebook2Id(pricebook)
			.build();
		insert reservationOpp;
		Test.startTest();
		List<OpportunityLineItem> itemsStock = createOppProducts(createProducts(2), stock, 10);
		Set<Id> idsStock = new Set<Id>();
		insert itemsStock;
		List<OpportunityLineItem> itemsReservation = createOppProducts(createProducts(2), reservationOpp, 10);
		insert itemsReservation;
		itemsStock = [SELECT Id, Reservation_Quantity__c FROM OpportunityLineItem WHERE Id IN :idsStock];
		
		
		delete itemsReservation;
		Test.stopTest();
		
		for (OpportunityLineItem itemStock : itemsStock) {
			idsStock.add(itemStock.Id);
		}
		itemsStock = [SELECT Id, Reservation_Quantity__c FROM OpportunityLineItem WHERE Id IN :idsStock];

		for (OpportunityLineItem itemStock : itemsStock) {
			System.assertEquals(0, itemStock.Reservation_Quantity__c);
		}
	}

	public static List<OpportunityLineItem> createOppProductsWithCentroDespacho(
		List<PricebookEntry> products,
		Opportunity opp,
		Double quantity,
		List<String> centros
	) {
		List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
		for (Integer i = 0; i < centros.size(); i++) {
			OpportunityLineItem oppProduct = Build.anOpportunityLineItem()
				.withPricebookEntryId(products.get(i))
				.withOpportunityId(opp)
				.withQuantity(quantity)
				.withTotalPrice(10)
				.withCentrodedespacho(centros.get(i))
				.build();
			oppProducts.add(oppProduct);
		}
		for (PricebookEntry pbe : products) {
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
				.withCANTIDADSUBUNIDAD('140')
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