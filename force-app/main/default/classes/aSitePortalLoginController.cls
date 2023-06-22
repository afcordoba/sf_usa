global without sharing class aSitePortalLoginController {
	// global String company { get; set; }
	// global String ip { get; set; }
	// public Boolean isLogged { get; set; }
	// public string language { get; set; }

	// global aSitePortalLoginController() {
	// 	company = System.currentPageReference().getParameters().get('comp');
	// 	//language = 'en_US';
	// 	language = [SELECT id, LanguageLocaleKey FROM User WHERE id = :UserInfo.getUserId()].LanguageLocaleKey;
	// }

	// public PageReference validate() {
	// 	String username = System.currentPageReference().getParameters().get('username');
	// 	String password = System.currentPageReference().getParameters().get('password');
	// 	System.debug(username);
	// 	System.debug(password);
	// 	if (username == null || password == null) {
	// 		//return forwardToLogin();
	// 		return null;
	// 	} else {
	// 		return login();
	// 	}
	// }

	// global PageReference login() {
	// 	String username = System.currentPageReference().getParameters().get('username');
	// 	String password = System.currentPageReference().getParameters().get('password');
	// 	String token;
	// 	SiteUser__c user;

	// 	if (username == '' || username == null) {
	// 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Username_is_required));
	// 		return null;
	// 	}

	// 	if (password == '' || password == null) {
	// 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Password_is_required));
	// 		return null;
	// 	}

	// 	user = aSiteAuthManager.UserLogin(username, password);
	// 	if (user == null) {
	// 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Username_incorrent));
	// 		return null;
	// 	}

	// 	ip = ApexPages.currentPage().getHeaders().get('True-Client-IP');
	// 	if (ip == '' || ip == null) {
	// 		ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
	// 	}
	// 	if (ip == '' || ip == null) {
	// 		ip = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
	// 	}

	// 	token = aSiteAuthManager.OpenUserSession(user.Id, ip, company);

	// 	if (token == null || token == '') {
	// 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Username_incorrent));
	// 		//return forwardToLogin();
	// 		return null;
	// 	}

	// 	isLogged = true;

	// 	if (!user.Cadastro_pela_primeira_vez__c) {
	// 		return forwardToChangePassPage(token);
	// 	} else {
	// 		return forwardToHomePage(token);
	// 	}
	// }

	// // global PageReference forwardToLogin() {
	// // 	PageReference p = new PageReference('/apex/aSiteLogin');
	// // 	p.setRedirect(true);
	// // 	if (company != null && !company.isWhitespace())
	// // 		p.getParameters().put('comp', company);
	// // 	return p;
	// // }

	// global PageReference forwardToChangePassPage(String strSessionToken) {
	// 	PageReference p = new PageReference('/apex/aSiteChangePass');
	// 	p.setRedirect(true);
	// 	p.getParameters().put('token', strSessionToken);
	// 	p.getParameters().put('comp', company);
	// 	return p;
	// }

	// global PageReference forwardToHomePage(String strSessionToken) {
	// 	PageReference p = new PageReference('/apex/aSiteHome');
	// 	p.setRedirect(true);
	// 	p.getParameters().put('token', strSessionToken);
	// 	return p;
	// }
}