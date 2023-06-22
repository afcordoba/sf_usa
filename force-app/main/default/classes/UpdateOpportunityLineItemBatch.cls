public with sharing class UpdateOpportunityLineItemBatch implements Database.Batchable<sObject> {
	public final String season = '22/2022';
	public final List<String> types = new List<String>{
		'Z2 - PARENT SEED',
		'Z3 - TEST SEED',
		'Z4 - WHOLESALE SEED',
		'Z13 - COMMERCIAL SEED',
		'Z14 - STOCK SEED'
	};
	public final String rtName = 'Sale';
	public final String orderType = 'ZO14 – Local Order';
	public final String query = 'SELECT Id, Price_by_140k__c, Price_by_140K_value__c, Quantity_by_140k__c, Quantity_by_140k_value__c FROM OpportunityLineItem	WHERE Opportunity.Safra__c =: season  AND Opportunity.Type IN: types AND Opportunity.RecordType.Name =: rtName AND Opportunity.Tipo__c =: orderType';

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<OpportunityLineItem> items) {
		List<OpportunityLineItem> itemsToUpdate = new List<OpportunityLineItem>();
		for (OpportunityLineItem item : items) {
			if (
				item.Price_by_140k__c != item.Price_by_140K_value__c ||
				item.Quantity_by_140k__c != item.Quantity_by_140k_value__c
			) {
				itemsToUpdate.add(item);
			}
		}
		if (itemsToUpdate.size() > 0) {
			update items;
		}
	}

	public void finish(Database.BatchableContext BC) {
	}
}