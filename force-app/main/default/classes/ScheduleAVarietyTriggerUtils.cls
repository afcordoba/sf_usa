public class ScheduleAVarietyTriggerUtils {
	public static void updateExclusiveVariety(
		Map<Id, Item_del_Contrato__c> newSchedules,
		Map<Id, Item_del_Contrato__c> oldSchedules
	) {
		List<Variedad__c> varieties = new List<Variedad__c>();
		Set<Id> varietiesIds = new Set<Id>();
		Set<Id> productsIds = new Set<Id>();
		Map<String, Item_del_Contrato__c> scheduleByVariety = new Map<String, Item_del_Contrato__c>();
		for (Item_del_Contrato__c newSchedule : newSchedules.values()) {
			if (
				(oldSchedules != null &&
				oldSchedules.containsKey(newSchedule.Id) &&
				oldSchedules.get(newSchedule.Id).Exclusive__c != newSchedule.Exclusive__c) || oldSchedules == null
			) {
				varietiesIds.add(newSchedule.Variety_Id__c);
				scheduleByVariety.put(newSchedule.Variety_Id__c, newSchedule);
			}
		}
		for (Variedad__c var : [SELECT Id, Exclusive_Variety__c FROM Variedad__c WHERE Id IN :varietiesIds]) {
			Boolean isExclusive = scheduleByVariety.get(var.Id).Exclusive__c == 'YES' ? true : false;
			if (isExclusive != var.Exclusive_Variety__c) {
				var.Exclusive_Variety__c = isExclusive;
				varieties.add(var);
			}
		}
		if (varieties.size() > 0) {
			update varieties;
		}
	}
}