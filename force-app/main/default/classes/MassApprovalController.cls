public class MassApprovalController {
	@AuraEnabled
	public static void handleCsv(Id contentDocumentId) {
		Map<Id, String> actionById = new Map<Id, String>();
		if (contentDocumentId != null) {
			ContentVersion contentVersionObj = [
				SELECT Id, VersionData
				FROM ContentVersion
				WHERE ContentDocumentId = :contentDocumentId
			];

			List<String> csvRecordsList = contentVersionObj.VersionData.toString().split('\n');

			for (Integer i = 1; i < csvRecordsList.size(); i++) {
				List<String> csvRowData = csvRecordsList[i].split(',');
				if (!actionById.containsKey(csvRowData[0])) {
					String recordId = csvRowData[0];
					String action = csvRowData[1];
					actionById.put(recordId.trim(), action.trim());
				}
			}
			try {
				System.debug(actionById);
				massApprove(actionById);
			} catch (Exception ex) {
				System.debug(ex.getStackTraceString());
				System.debug(ex.getMessage());
				throw new AuraHandledException('An error has ocurred when uploading the .csv');
			}
		}
	}

	public static void massApprove(Map<Id, String> actionById) {
		try {
			Set<Id> ids = actionById.keySet();
			List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
			List<Inventory_Status__c> inventoriesToUpdate = new List<Inventory_Status__c>();
			List<ProcessInstanceWorkitem> workItems = [
				SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId
				FROM ProcessInstanceWorkitem
				WHERE ProcessInstance.TargetObjectId IN :ids
			];
			for (ProcessInstanceWorkItem workItem : workItems) {
				if (actionById.containsKey(workItem.ProcessInstance.TargetObjectId)) {
					Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
					req.setWorkitemId(workItem.Id);
					req.setAction(actionById.get(workItem.ProcessInstance.TargetObjectId));
					requests.add(req);
				}
			}

			for (Inventory_Status__c inventoryStatus : [
				SELECT Id, Status__c
				FROM Inventory_Status__c
				WHERE Id IN :ids AND Status__c = 'Pending'
			]) {
				if (actionById.containsKey(inventoryStatus.Id)) {
					String action = actionById.get(inventoryStatus.Id) == 'Approve' ? 'Approved' : ' Rejected';
					inventoryStatus.Status__c = action;
					inventoriesToUpdate.add(inventoryStatus);
				}
			}
			Approval.ProcessResult[] processResults = Approval.process(requests);
			if (inventoriesToUpdate.size() > 0) {
				update inventoriesToUpdate;
			}
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
			System.debug(e.getMessage());
			throw new AuraHandledException('An error has ocurred when updating approval status');
		}
	}
}