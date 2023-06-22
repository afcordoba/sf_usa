/**
 * @description       :
 * @author            : Horacio Calleja
 * @group             :
 * @last modified on  : 01-17-2023
 * @last modified by  : Horacio Calleja
 **/
@isTest
private class aSiteSeedTrackingControllerTest {
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
		Seed_Tracking__c st = new Seed_Tracking__c(
			Account__c = anAccount.Id,
			Active__c = true,
			Brand__c = 'DONMARIO',
			Status__C = 'Pending',
			Type__c = 'Delivery'
		);
		insert st;
	}

	@isTest
	static void testValidateShouldBeOk() {
		Account theAccount = [SELECT Id FROM Account LIMIT 1];
		SiteUser__c theUser = [SELECT Id FROM SiteUser__c LIMIT 1];
		Pagereference pageRef = Page.aSiteSeedTracking;
		SiteUser__c siteUser = [SELECT Id, Email__c, Password__c FROM SiteUser__c LIMIT 1];
		Test.setCurrentPage(pageRef);
		aSiteLoginController loginCtrl = new aSiteLoginController();
		loginCtrl.username = siteUser.Email__c;
		loginCtrl.password = siteUser.Password__c;
		Pagereference pageRedirected = loginCtrl.login();
		String token = pageRedirected.getParameters().get('token');
		Test.startTest();
		aSiteSeedTrackingController stCtrl = new aSiteSeedTrackingController();
		pageRef.getParameters().put('token', token);
		stCtrl.validate();
		stCtrl.getFields();
		Test.stopTest();
		Account ac = stCtrl.getAccount();
		SiteUser__c su = stCtrl.getUser();
		System.assertEquals(theAccount.Id, ac.Id);
		System.assertEquals(theUser.Id, su.Id);
	}

	@isTest
	static void testValidateShouldFail() {
		Test.startTest();
		aSiteSeedTrackingController stCtrl = new aSiteSeedTrackingController();
		stCtrl.validate();
		Test.stopTest();
	}

	@isTest
	static void testGetOptionVarietyShouldBeOk() {
		aSiteSeedTrackingController stCtrl = validate();
		Test.startTest();
		List<SelectOption> varietyOptions = stCtrl.getOptionVariety();
		Test.stopTest();
		System.assertEquals(varietyOptions.size(), 2);
	}

	@isTest
	static void testGetOptionStatusShouldBeOk() {
		aSiteSeedTrackingController stCtrl = validate();
		Test.startTest();
		List<SelectOption> statusOptions = stCtrl.getOptionStatus();
		Test.stopTest();
		System.assertEquals(statusOptions.size(), 2);
	}

	@isTest
	static void testGetOptionSeedTypeShouldBeOk() {
		aSiteSeedTrackingController stCtrl = validate();
		Test.startTest();
		List<SelectOption> seedTypes = stCtrl.getOptionSeedType();
		Test.stopTest();
		System.assertEquals(seedTypes.size(), 2);
	}

	public static aSiteSeedTrackingController validate() {
		Pagereference pageRef = Page.aSiteSeedTracking;
		SiteUser__c siteUser = [SELECT Id, Email__c, Password__c FROM SiteUser__c LIMIT 1];
		Test.setCurrentPage(pageRef);
		aSiteLoginController loginCtrl = new aSiteLoginController();
		loginCtrl.username = siteUser.Email__c;
		loginCtrl.password = siteUser.Password__c;
		Pagereference pageRedirected = loginCtrl.login();
		String token = pageRedirected.getParameters().get('token');
		aSiteSeedTrackingController stCtrl = new aSiteSeedTrackingController();
		pageRef.getParameters().put('token', token);
		stCtrl.validate();
		return stCtrl;
	}
}