/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 09-06-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
trigger Opportunity on Opportunity(before insert, before update, after insert, after update) {
	Opp_Utils.isInsert = Trigger.isInsert;
	Opp_Utils.isUpdate = Trigger.isUpdate;
	if (!ProcessControl.ignoredByTrigger && !ProcessControl.inFutureContext) {
		if (Test.isRunningTest() && ProcessControl.ignoredByTrigger) {
			return;
		}

		if (Trigger.isAfter) {
			if (Trigger.isUpdate) {
				Opp_Utils.handleSeasonInventoryChange(Trigger.newMap, Trigger.oldMap);

				List<Id> oppForSeedTracks = new List<Id>();
				List<Id> oppIntegrationIds = new List<Id>();

				String RECORDTYPE_SALE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
					.get('Sale')
					.getRecordTypeId();

				for (Opportunity opp : Trigger.new) {
					Opportunity old = Trigger.oldMap.get(opp.Id);
					if (opp.StageName != old.StageName) {
						if (opp.RecordTypeId == RECORDTYPE_SALE) {
							oppForSeedTracks.add(opp.Id);
						}
					}

					if (opp.RecordTypeId == RECORDTYPE_SALE && opp.Stagename == 'Approved') {
						if (opp.Status_Integracion__c == 'Insert Mode')
							oppIntegrationIds.add(opp.Id);
						if (
							opp.Nro_pedido_SAP__c != '' &&
							opp.Nro_pedido_SAP__c != null &&
							opp.Status_Integracion__c == 'Reject Mode'
						)
							oppIntegrationIds.add(opp.Id);
					}
				}

				//ask for size != 0
				if (!oppIntegrationIds.isEmpty())
					OpportunityVtaBO.getInstance().newIntegration2(oppIntegrationIds, Trigger.newMap);

				if (!oppForSeedTracks.isEmpty() && Opp_Utils.isFirstTime) {
					Opp_Utils.setSeedTracks(oppForSeedTracks);
				}
			}
		} else if (Trigger.isBefore) {
			if (Trigger.isUpdate) {
				// Opp_Utils.setPortalReportsOwners(Trigger.new);
				Opp_Utils.setSnapshot(Trigger.newMap, Trigger.oldMap);
				Opp_Utils.validations(Trigger.new);
				Map<Id, Opportunity> oppToSnapshot = new Map<Id, Opportunity>();

				List<Id> oppIds = new List<Id>();
				List<Id> oppReportsIds = new List<Id>();

				String RECORDTYPE_SALE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
					.get('Sale')
					.getRecordTypeId();
				String RECORDTYPE_SR = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
					.get('Sales Report')
					.getRecordTypeId();
				for (Opportunity opp : Trigger.new) {
					Opportunity old = Trigger.oldMap.get(opp.Id);
                    System.debug(opp);
					if(old.StageName == 'Approved'){
						opp.Incentive_Procesed__c = false;
					}
					if (opp.Stagename == 'Approved' && opp.StageName != old.StageName) {
						if (opp.RecordTypeId == RECORDTYPE_SR) {
							oppToSnapshot.put(opp.Id, opp);
                            System.Debug(opp.id+'If new Approved and old not Approved');
                             
                            
						}

						if (opp.Type == 'Final Sales Report') {
							//Call the process to create the royalty order, only for GDM Approved FSR.
							oppIds.add(opp.Id);
						}
						if (opp.Type == 'Sales Forecast Update 2' && opp.Marca__c == 'DONMARIO') {
							//Call the process to create the royalty order, only for DM April #2.
							oppIds.add(opp.Id);
						}
						if (opp.Type == 'Final Production Report' && opp.Marca__c == 'DONMARIO') {
							//Call the process to create the royalty order, only for DM April Production Final.
							oppIds.add(opp.Id);
						}

						if (opp.Type == 'Sales Forecast Update 1') {
							oppReportsIds.add(opp.Id);
						}
					}
				}
				
				Set<Id> sIds = new Set<Id>();
				if (!oppToSnapshot.isEmpty()) {
					sIds = Opp_Utils.generateIncentiveContractSnapshot(oppToSnapshot.keySet(), Trigger.newMap);
				}

				if (!oppIds.isEmpty()) {
					Opp_Utils.cloneReportToSale(oppIds, sIds, Trigger.newMap);
				}

				if (!oppReportsIds.isEmpty()) {
					Opp_Utils.CalculateSaleReportEstimation(oppReportsIds);
				}
			} else if (Trigger.isInsert) {
				//Opp_Utils.setPortalReportsOwners(Trigger.new);

				Opp_Utils.validations(Trigger.new);

				USAUtils.actualizarNroAutorizacionAnexos(Trigger.new);

				Opp_Utils.setPricebook(Trigger.new);
			}
		}
	}
}