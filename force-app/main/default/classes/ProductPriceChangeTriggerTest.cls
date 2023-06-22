@isTest
private class ProductPriceChangeTriggerTest {
	@TestSetup
	static void makeData() {
		Variedad__c variety = Build.aVariedad().withName('Variety').build();
		insert variety;
		List<Product2> products = new List<Product2>();

		Pricebook2 pricebook = Build.aPricebook2().withBrand('GDM').withName('Pricebook GDM').withIsActive(true).build();
		pricebook.Type__c = 'PARENT SEED';
		insert pricebook;
		Pricebook2 pricebookWholesale = Build.aPricebook2()
			.withBrand('GDM')
			.withName('DONMARIO - WHOLESALE PriceList')
			.withIsActive(true)
			.build();
		pricebookWholesale.Type__c = 'WHOLESALE SEED';
		insert pricebookWholesale;
		List<PricebookEntry> entries = new List<PricebookEntry>();
		for (Integer i = 0; i < 10; i++) {
			Product2 aProduct = Build.aProduct2()
				.withName('Product ' + i)
				.withIsActive(true)
				.withVariedade(variety)
				.withUNIDADE('BAG 140K')
				.build();
			products.add(aProduct);
		}
		insert products;
		for (Product2 theProd : products) {
			PricebookEntry pbeOneStndr = Build.aPricebookEntry()
				.withIsActive(true)
				.withPricebook2Id(Test.getStandardPricebookId())
				.withProduct2Id(theProd)
				.withUnitPrice(1)
				.build();
			entries.add(pbeOneStndr);
			PricebookEntry pbeOneGdm = Build.aPricebookEntry()
				.withIsActive(true)
				.withPricebook2Id(pricebook)
				.withProduct2Id(theProd)
				.withUnitPrice(1)
				.build();
			entries.add(pbeOneGdm);
			PricebookEntry pbWholesale = Build.aPricebookEntry()
				.withIsActive(true)
				.withPricebook2Id(pricebookWholesale)
				.withProduct2Id(theProd)
				.withUnitPrice(1)
				.build();
			entries.add(pbWholesale);
		}
		insert entries;
	}

	@isTest
	public static void testChangePriceShouldModifyPriceobookEntry() {
		Id wholesaleId = [SELECT Id FROM Pricebook2 WHERE Type__c = 'WHOLESALE SEED' LIMIT 1].Id;
		Id parentId = [SELECT Id FROM Pricebook2 WHERE Type__c = 'PARENT SEED' LIMIT 1].Id;
		List<Product_Price_Change__c> pricesChanges = new List<Product_Price_Change__c>();
		for (Product2 aProduct : [SELECT Id FROM Product2]) {
			pricesChanges.add(
				new Product_Price_Change__c(Product__c = aProduct.Id, Pricebook__c = wholesaleId, New_Price__c = 3)
			);
		}
          Test.startTest();
          insert pricesChanges;
          Test.stopTest();

          for(PricebookEntry entry : [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id =: parentId]){
               System.assertEquals(1, entry.UnitPrice);
          }

          for(PricebookEntry entryModified : [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id =: wholesaleId]){
               System.assertEquals(3, entryModified.UnitPrice);
          }

	}
}