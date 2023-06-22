/**
 * @description       : 
 * @author            : Horacio Calleja
 * @group             : 
 * @last modified on  : 01-10-2023
 * @last modified by  : Horacio Calleja
**/
trigger OpportunityLineItemTrigger on OpportunityLineItem(
	after insert,
	before insert,
	after update,
	before update,
	after delete
) {
	OpportunityLineItemTriggerUtils.setUtilsProperties(
		Trigger.isBefore,
		Trigger.isAfter,
		Trigger.isUpdate,
		Trigger.isInsert,
		Trigger.newMap,
		Trigger.oldMap
	);

	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			OpportunityLineItemTriggerUtils.handleInsertValues(Trigger.new, Trigger.isBefore, Trigger.isAfter);
		}
		if (Trigger.isAfter) {
			OpportunityLineItemTriggerUtils.handleInventoryStock(null, Trigger.newMap);
			OpportunityLineItemTriggerUtils.handleInsertValues(Trigger.new, Trigger.isBefore, Trigger.isAfter);
			OpportunityLineItemTriggerUtils.updateLicenseeVarietyIds(null, Trigger.newMap);
		}
	}

	if (Trigger.isUpdate) {
		OpportunityLineItemTriggerUtils.handleUpdateValues(
			Trigger.oldMap,
			Trigger.newMap,
			Trigger.isBefore,
			Trigger.isAfter
		);
		if (Trigger.isAfter) {
			Set<Id> oppIds = new Set<Id>();
			// Set<Id> rejectedOppIds = new Set<Id>();

			for (OpportunityLineItem oppLi : Trigger.new) {
				oppIds.add(oppLi.opportunityId);
			}
			OpportunityLineItemTriggerUtils.TraitLicenseNotification(Trigger.new, Trigger.oldMap);

			OpportunityLineItemTriggerUtils.updateLicenseeVarietyIds(Trigger.oldMap, Trigger.newMap);

			OpportunityLineItemTriggerUtils.handleInventoryStock(Trigger.oldMap, Trigger.newMap);

			Map<Id, Opportunity> inventoryOpps = new Map<Id, Opportunity>(
				[SELECT Id FROM Opportunity WHERE Id IN :oppIds AND RecordType.Name = 'Stock per plant']
			);
			Map<Id, OpportunityLineItem> inventoryItemsUpdated = new Map<Id, OpportunityLineItem>();
			for (OpportunityLineItem oppLi : Trigger.new) {
				if (
					inventoryOpps.containsKey(oppLi.OpportunityId) &&
					oppLi.Inventory_Status__c == 'Approved' &&
					oppLi.Inventory_Status__c != Trigger.oldMap.get(oppLi.Id).Inventory_Status__c
				) {
					inventoryItemsUpdated.put(oppLi.Id, oppLi);
				}
			}
			if (inventoryItemsUpdated.size() > 0) {
				OpportunityLineItemTriggerUtils.InventoryItemsApproved(inventoryItemsUpdated);
			}

			// // Rejection of Product
			// List<Id> rejectedOppIdsList = new List<Id>();
			// rejectedOppIdsList.addAll(rejectedOppIds);
			// Opp_Utils.setSeedTracks(rejectedOppIdsList);
		}
	}

	if (Trigger.isDelete) {
		if (Trigger.isAfter) {
			OpportunityLineItemTriggerUtils.handleDeletion(Trigger.old);
			OpportunityLineItemTriggerUtils.removeInventoryStock(Trigger.oldMap);
		}
	}

}