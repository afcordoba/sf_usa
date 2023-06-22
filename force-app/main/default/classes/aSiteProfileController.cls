global class aSiteProfileController {
	private String token;
	global String company { get; set; }
	private SiteUser__c logUser;
	public String accSelect { get; set; }
	public SiteUserAccount__c[] relatedAccounts { get; set; }
	public string language { get; set; }

	global aSiteProfileController() {
		language = [SELECT id, LanguageLocaleKey FROM User WHERE id = :UserInfo.getUserId()].LanguageLocaleKey;
	}

	public PageReference validate() {
		token = System.currentPageReference().getParameters().get('token');
		company = System.currentPageReference().getParameters().get('comp');
		if (token != null) {
			logUser = aSiteAuthManager.VerifyUserSession(token);
			if (logUser != null)
				return null;
		}
		PageReference p = new PageReference('/apex/aSiteLogin');
		p.setRedirect(true);
		return p;
	}

	public List<SiteUserAccount__c> getAccounts() {
		try {
			if (relatedAccounts != null && relatedAccounts.size() > 0)
				return relatedAccounts;

			relatedAccounts = aSiteAuthManager.getUserAccounts_byUser(logUser);

			return relatedAccounts;
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));
			return null;
		}
	}

	public SiteUser__c getUser() {
		return logUser;
	}

	public PageReference editProfile() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr = new PageReference('/apex/aSiteProfileEdit');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		return pr;
	}

	public PageReference editPassword() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference p = new PageReference('/apex/aSiteChangePass');
		p.setRedirect(true);
		p.getParameters().put('token', token);
		p.getParameters().put('comp', company);
		return p;
	}

	public PageReference editCancel() {
		PageReference pr = new PageReference('/apex/aSiteProfile');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		return pr;
	}

	public PageReference saveProfile() {
		update logUser;
		PageReference pr = new PageReference('/apex/aSiteProfile');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		return pr;
	}

	public Pagereference setActiveAccount() {
		try {
			PageReference pr = new PageReference('/apex/aSiteProfile');
			pr.setRedirect(true);
			pr.getParameters().put('token', token);
			for (SiteUserAccount__c d : relatedAccounts) {
				d.Active__c = false;
				if ((String) d.Id == accSelect) {
					d.Active__c = true;
				}
			}
			update relatedAccounts;
			return pr;
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));
			return null;
		}
	}
}