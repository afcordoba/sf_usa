trigger ProductPriceChange on Product_Price_Change__c(before insert, before update) {
	ProductPriceChangeTriggerUtils.handlePriceChanges(Trigger.new);
}