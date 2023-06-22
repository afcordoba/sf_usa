/**
 *  Clase test del controller del seed track, fuerza cobertura
 *  Jere 22.12.05 Complete unit tests
 */
@isTest
global with sharing class aSeedTrackingManagerTest {

    @IsTest(SeeAllData=false)
    global static void testSeedManager () {        
        Account acc = new Account(Site='www.fff.com',AccountNumber='1243',Grupo_de_cuentas__c='US01 - Domestic Customers',Name='JERE', Nome_Fantasia__c = 'JRERE', CodigoSAP__c='451254');
        insert acc;
        Seed_Tracking__c seed = new Seed_Tracking__c(Account__c=acc.Id, Brand__c='GDM', Status__c='PENDING', Type__c='PARENT');
        insert seed;
            
        aSeedTrackingManager.getVarietiesSeedTracking(acc.Id);
        
        aSeedTrackingManager.getStatusSeedTracking(acc.Id);
        
        aSeedTrackingManager.getSeedTypeSeedTracking(acc.Id);
            
		aSeedTrackingManager.getItemsSeedTracking(acc.Id, 'GDM', 'PENDING', 'PARENT');    	
	}    
}