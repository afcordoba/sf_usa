trigger ScheduleAVariety on Item_del_Contrato__c(after insert, after update) {
	if (Trigger.isInsert) {
		if (Trigger.isAfter) {
			ScheduleAVarietyTriggerUtils.updateExclusiveVariety(Trigger.newMap, Trigger.oldMap);
		}
	}
	if (Trigger.isUpdate) {
		if (Trigger.isAfter) {
			ScheduleAVarietyTriggerUtils.updateExclusiveVariety(Trigger.newMap, Trigger.oldMap);
		}
	}
}