/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-12-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class schedulableFlujoDocUpdate implements Schedulable {

    global void execute(SchedulableContext ctx) {

		Integer startTime = Limits.getCpuTime();

        try {
	
			for (Bitacora_NC__c b : [SELECT Id, vbtyp__c, fkart__c, Fecha_Desde__c, numero_lote__c, sociedad__c
									 FROM Bitacora_NC__c]) {

				sapFlujoDoc_caller.actItems(b.vbtyp__c, b.fkart__c, b.sociedad__c);
			}
				
		} catch (Exception ee) {

			System.debug('ERROR:  ' +ee.getStackTraceString());
		}

		Integer endTime = Limits.getCpuTime();
        System.debug('Tiempo de CPU utilizado: ' + (endTime - startTime) + ' ms');
    }
}