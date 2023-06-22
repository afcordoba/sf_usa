global class aSiteUploadFileController {
	private String token;
	private SiteUser__c logUser { get; set; }
	public Account activeAccount { get; set; }
	public SiteUserSession__c activeSession { get; set; }
	public String language { get; set; }
	public String titulo { get; set; }
	public ContentVersion csvFile { get; set; }
	public Boolean renderFinishedUpload { get; set; }
	public String userName { get; set; }
	public String fileName { get; set; }
	public SiteUser__c getUser() {
		return logUser;
	}
	public Account getAccount() {
		return activeAccount;
	}

	global aSiteUploadFileController() {
		try {
			language = [SELECT id, LanguageLocaleKey FROM User WHERE id = :UserInfo.getUserId()].LanguageLocaleKey;
			titulo = 'Upload GPOS File';
			renderFinishedUpload = false;
			csvFile = new ContentVersion();
		} catch (Exception e) {
		}
	}

	public void doUpload() {
		try {
			csvFile.PathOnClient = csvFile.Title + '.xls';
			if (csvFile.Title == 'Partner GPOS Template')
				csvFile.Title = 'Partner GPOS Template - Report';
			insert csvFile;
			fileName = csvFile.Title;
			csvFile = [SELECT VersionData, Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :csvFile.Id LIMIT 1];

			List<GPOS_User__mdt> gposUsers = [SELECT Id, User_Id__c FROM GPOS_User__mdt];
			List<ContentDocumentLink> links = new List<ContentDocumentLink>();
			for (GPOS_User__mdt user : gposUsers) {
				ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
					LinkedEntityId = user.User_Id__c,
					ContentDocumentId = csvFile.ContentDocumentId,
					shareType = 'V',
					Visibility = 'AllUsers'
				);
				links.add(contentDocumentLink);
			}

			insert links;

			GPOS_Customer_Report__c report = new GPOS_Customer_Report__c();
			report.Document__c = '/sfc/servlet.shepherd/document/download/' + csvFile.ContentDocumentId;
			report.Account__c = activeAccount.Id;
			report.Name = csvFile.Title;
			report.Type__c = 'Customer';
			insert report;
			csvFile = new ContentVersion();
			renderFinishedUpload = true;
			aAppManager.sendNotification(new List<String>{ logUser.Email__c }, 'success');
		} catch (Exception ex) {
            System.debug(ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getLineNumber() + '\n' + ex.getMessage()));
			//Commented because email sending is not enabled in sandbox enviroments
			aAppManager.sendNotification(new List<String>{ logUser.Email__c }, 'error');
		}
	}

	public PageReference validate() {
		token = System.currentPageReference().getParameters().get('token');
		if (token != null) {
			logUser = aSiteAuthManager.VerifyUserSession(token);
			userName = logUser.Contact__r.Name;
			if (logUser != null) {
				activeSession = aSiteAuthManager.getUserSession(token);
				activeAccount = aSiteAuthManager.getActiveAccount_byUser(logUser);
				return null;
			}
		}

		PageReference p = new PageReference('/apex/aSiteLogin');
		p.setRedirect(true);
		return p;
	}
}