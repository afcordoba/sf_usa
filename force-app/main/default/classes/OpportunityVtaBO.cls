public class OpportunityVtaBO {
	private static OpportunityVtaBO instance = new OpportunityVtaBO();
	private OpportunityVtaBO() {
	}

	public static OpportunityVtaBO getInstance() {
		return instance;
	}

	public static Map<String, Integer> vezesUpdtOppPorTipo = new Map<String, Integer>();

	public OpportunityLineItem getOpportunityLineItemById(String idOppLineItem) {
		return OpportunityDAO.getInstance().getOpportunityLineItemByListId(new List<String>{ idOppLineItem })[0];
	}

	public void newIntegration2(List<Id> opportunityIds, Map<Id, Opportunity> newOpps) {
		List<Queue__c> queueToInsert = new List<Queue__c>();
		List<Opportunity> opportunityToUpdate = new List<Opportunity>();
		Set<String> sapOwners = new Set<String>();
		List<Group> userGroup = [SELECT Id FROM Group WHERE DeveloperName = 'SAP_Opportunity_Owners' LIMIT 1];
		for (GroupMember grMember : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :userGroup[0].Id]) {
			if (String.valueOf(grMember.UserOrGroupId).startsWith('005')) {
				sapOwners.add(grMember.UserOrGroupId);
			}
		}
		system.debug('listOpp: ' + opportunityIds);
		if (!opportunityIds.isEmpty()) {
			for (Opportunity opportunity : OpportunityDAO.getInstance().getOpportunityByListId(opportunityIds)) {
				if (sapOwners.contains(opportunity.OwnerId)) {
					String jsonResult;
					if (opportunity.Status_Integracion__c == 'Insert Mode') {
						if (opportunity.Nro_pedido_SAP__c == null || opportunity.Nro_pedido_SAP__c == '') {
							jsonResult = OpportunityVtaIntegrationS4BO.outboundRequest(opportunity);
							//Change to S4 VtaIntegration for testing
							queueToInsert.add(
								QueueBO.getInstance().sObjectQueue(opportunity.Id, 'OPPORTUNITY_SALESFORCE_TO_SAP', jsonResult, false)
							);
						} else {
							jsonResult = ModificaPedidoIntegrationS4BO.outboundRequestUpdate(opportunity);
							queueToInsert.add(
								QueueBO.getInstance()
									.sObjectQueue(opportunity.Id, 'OPPORTUNITY_UPDATE_SALESFORCE_TO_SAP', jsonResult, false)
							);
						}
					} else {
						jsonResult = OpportunityVtaIntegrationBO.outboundRequestRej(opportunity);
						queueToInsert.add(
							QueueBO.getInstance().sObjectQueue(opportunity.Id, 'OPPORTUNITY_REJ_SALESFORCE_TO_SAP', jsonResult, false)
						);
					}
					opportunityToUpdate.add(new Opportunity(Id = opportunity.Id, Status_Integracion__c = 'Waiting Integration'));
				} else {
					newOpps.get(opportunity.Id).addError('OwnerId', 'Select a valid owner.');
					// Opportunity.addError();
				}
			}

			ProcessControl.ignoredByTrigger = true;

			update opportunityToUpdate;
			insert queueToInsert;
		}
	}
}