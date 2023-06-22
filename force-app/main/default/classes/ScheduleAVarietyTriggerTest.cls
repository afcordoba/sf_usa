@isTest
private class ScheduleAVarietyTriggerTest {
	@TestSetup
	static void makeData() {
		Variedad__c aVariety = Build.aVariedad().withName('Variety One').build();
		insert aVariety;
		Product2 aProduct = Build.aProduct2().withName('Product 1').withVariedade(aVariety).withFamily('ROYALTY').build();
		insert aProduct;
		Contrato__c schedule = Build.aContratoParentSeedScheduleA().build();
        insert schedule;
		Item_del_contrato__c aScheduleAv = Build.anItemdelContrato().withActive(true).withCultivar(aProduct).withContratodeMultiplicacion(schedule).build();
		insert aScheduleAv;
	}

	@isTest
	static void testChangingScheduleAVarietyExclusiveToYesShouldChangeInVariety() {
		Item_del_Contrato__c scheduleAV = [
			SELECT Id, Cultivar__r.Variedade__r.Exclusive_Variety__c
			FROM Item_del_Contrato__c
			LIMIT 1
		];
		scheduleAV.Exclusive__c = 'YES';
		Test.startTest();
		update scheduleAV;
		Test.stopTest();
		Variedad__c aVariety = [
			SELECT Id, Exclusive_Variety__c
			FROM Variedad__c
			WHERE Id = :scheduleAV.Cultivar__r.Variedade__c
			LIMIT 1
		];
		System.assertEquals(scheduleAV.Exclusive__c == 'YES', aVariety.Exclusive_Variety__c);
	}
}