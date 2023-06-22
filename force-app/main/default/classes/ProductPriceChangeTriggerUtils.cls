public class ProductPriceChangeTriggerUtils {
	public static void handlePriceChanges(List<Product_Price_Change__c> priceChanges) {
		Set<Id> productsIds = new Set<Id>();
		List<PricebookEntry> entriesToUpdate = new List<PricebookEntry>();
		Map<String, Product_Price_Change__c> priceChangeByKey = new Map<String, Product_Price_Change__c>();
		Map<Id, Map<Id, Decimal>> pricesByPricebookAndProduct = new Map<Id, Map<Id, Decimal>>();
		for (Product_Price_Change__c priceChange : priceChanges) {
			priceChange.Modified_Date__c = Date.today();
			if (!pricesByPricebookAndProduct.containsKey(priceChange.Pricebook__c)) {
				pricesByPricebookAndProduct.put(
					priceChange.Pricebook__c,
					new Map<Id, Decimal>{ priceChange.Product__c => priceChange.New_price__c }
				);
			}
			String key = '' + priceChange.Product__c + priceChange.Pricebook__c;
			priceChangeByKey.put(key, priceChange);
			pricesByPricebookAndProduct.get(priceChange.Pricebook__c).put(priceChange.Product__c, priceChange.New_price__c);
			productsIds.add(priceChange.Product__c);
		}
		for (PricebookEntry entry : [
			SELECT Id, Pricebook2Id, UnitPrice, Product2Id, UseStandardPrice
			FROM PricebookEntry
			WHERE Pricebook2Id IN :pricesByPricebookAndProduct.keySet() AND Product2Id IN :productsIds
		]) {
			if (
				pricesByPricebookAndProduct.containsKey(entry.Pricebook2Id) &&
				pricesByPricebookAndProduct.get(entry.Pricebook2Id).containsKey(entry.Product2Id)
			) {
				entry.UseStandardPrice = false;
				String key = '' + entry.Product2Id + entry.Pricebook2Id;
				Decimal newPrice = pricesByPricebookAndProduct.get(entry.Pricebook2Id).get(entry.Product2Id);
				Decimal oldPrice = entry.UnitPrice;
				if (newPrice != oldPrice) {
					entry.UnitPrice = newPrice;
					entriesToUpdate.add(entry);
				}
				priceChangeByKey.get(key).Old_Price__c = oldPrice;
			}
		}
		if (entriesToUpdate.size() > 0) {
			update entriesToUpdate;
		}
	}
}