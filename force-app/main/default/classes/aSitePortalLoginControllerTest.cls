@isTest
private class aSitePortalLoginControllerTest {
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
		Pagereference pageRef = Page.aSiteLogin;
		SiteUser__c siteUser = [SELECT Id, Email__c, Password__c FROM SiteUser__c LIMIT 1];
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('username', siteUser.Email__c);
		ApexPages.currentPage().getParameters().put('password', siteUser.Password__c);
		Test.startTest();
		aSiteLoginController loginCtrl = new aSiteLoginController();
		loginCtrl.username = siteUser.Email__c;
		loginCtrl.password = siteUser.Password__c;
		loginCtrl.login();
		Test.stopTest();
		System.assertEquals(true, loginCtrl.isLogged, 'Should be true if the user has logged in succesfully.');
	}

	@isTest
	static void testLoginFailOne() {
		Pagereference pageRef = Page.aSiteLogin;
		SiteUser__c siteUser = [SELECT Id, Email__c, Password__c, Cadastro_pela_primeira_vez__c FROM SiteUser__c LIMIT 1];
		siteUser.Cadastro_pela_primeira_vez__c = false;
		update siteUser;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('username', siteUser.Email__c);
		ApexPages.currentPage().getParameters().put('password', siteUser.Password__c);
		Test.startTest();
		aSiteLoginController loginCtrl = new aSiteLoginController();
		loginCtrl.forwardToResetPassword();
		loginCtrl.username = siteUser.Email__c;
		loginCtrl.password = siteUser.Password__c;
		loginCtrl.login();
		Test.stopTest();
		System.assertEquals(false, loginCtrl.isLogged, 'User cant log in if it is the first time they try.');
	}
	@isTest
	static void testLoginFailTwo() {
		Pagereference pageRef = Page.aSiteLogin;
		SiteUser__c siteUser = [SELECT Id, Email__c, Password__c, Cadastro_pela_primeira_vez__c FROM SiteUser__c LIMIT 1];
		siteUser.Cadastro_pela_primeira_vez__c = true;
		update siteUser;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		aSiteLoginController loginCtrl = new aSiteLoginController();
		loginCtrl.forwardToResetPassword();
		loginCtrl.username = null;
		loginCtrl.password = siteUser.Password__c;
		loginCtrl.login();
		Test.stopTest();
		System.assertEquals(false, loginCtrl.isLogged, 'User cant log in if it is the first time they try.');
	}
	@isTest
	static void testLoginFailThree() {
		Pagereference pageRef = Page.aSiteLogin;
		SiteUser__c siteUser = [SELECT Id, Email__c, Password__c, Cadastro_pela_primeira_vez__c FROM SiteUser__c LIMIT 1];
		siteUser.Cadastro_pela_primeira_vez__c = true;
		update siteUser;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		aSiteLoginController loginCtrl = new aSiteLoginController();
		loginCtrl.forwardToResetPassword();
		loginCtrl.closeSession();
		loginCtrl.username = siteUser.Email__c;
		loginCtrl.password = null;
		loginCtrl.login();
		Test.stopTest();
		System.assertEquals(false, loginCtrl.isLogged, 'User cant log in if it is the first time they try.');
	}
}