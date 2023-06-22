/**
 * @description       :
 * @author            : Horacio Calleja
 * @group             :
 * @last modified on  : 01-16-2023
 * @last modified by  : Horacio Calleja
 **/
@isTest
private class aSiteAuthRestServiceTest {
	@TestSetup
	static void makeData() {
		Configuracion_USA__c config = Build.aConfiguracionUSA()
			.withActiveSeason('23/2023')
			.withName('Config test')
			.withProductionSeason('23/2023')
			.withSalesSeason('23/2023')
			.withLastSeason('22/2022')
			.build();
		insert config;
		Account anAccount = Build.anAccount().withName('Test').build();
		insert anAccount;
		SiteUser__c siteUser = Build.aSiteUser()
			.withName('Site user test')
			.withAccount(anAccount)
			.withEmail('test@test.com')
			.withPassword('12345')
			.build();
		siteUser.Cadastro_pela_primeira_vez__c = true;
		insert siteUser;
		SiteUserAccount__c siteAccount = Build.aSiteUserAccount()
			.withAccount(anAccount)
			.withActive(true)
			.withName('SU')
			.withSiteUser(siteUser)
			.build();
		insert siteAccount;
	}
	@isTest
	static void testLogin() {
		SiteUser__c su = [SELECT Id, Email__c, Password__c FROM SiteUser__c LIMIT 1];
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		aSiteAuthRestService.userLogin(su.Email__c, su.Password__c, null, null);
		Test.stopTest();
	}
	@isTest
	static void testLoginFailUsername() {
		SiteUser__c su = [SELECT Id, Email__c, Password__c FROM SiteUser__c LIMIT 1];
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		aSiteAuthRestService.userLogin('Fail', su.Password__c, null, null);
		Test.stopTest();
		System.assertEquals(401, res.statusCode);
	}
	@isTest
	static void testLoginMissingFields() {
		SiteUser__c su = [SELECT Id, Email__c, Password__c FROM SiteUser__c LIMIT 1];
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		aSiteAuthRestService.userLogin(null, null, null, null);
		Test.stopTest();
		System.assertEquals(400, res.statusCode);
	}
}