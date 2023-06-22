@isTest
private class AccountTriggerTest {
	private static final Integer ACCOUNTS_SIZE = 10;
	@TestSetup
	static void makeData() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < ACCOUNTS_SIZE; i++) {
			Account anAccount = Build.anAccount()
				.withName('Account test ' + i)
				.withBillingCountry('US')
				.withGrupodeCuentas('US03 - Ship To')
				.withBillingState('NY')
				.withBillingStreet('Fake street ' + i)
				.build();
			accounts.add(anAccount);
		}
		insert accounts;
	}
	@isTest
	static void testUpdatingAccountNotCreatedInSapSystemWithStatusIntegrationInsertModeShouldInsertQueueToCreateIt() {
		Account anAccount = [SELECT Id FROM Account WHERE Status_Integration__c = NULL LIMIT 1];
		anAccount.Status_Integration__c = 'Insert Mode';
		Test.startTest();
		update anAccount;
		Test.stopTest();

		List<Queue__c> queues = [SELECT Id, Account__c, EventName__c FROM Queue__c];
		String queueAccount = queues[0].Account__c;
		String queueEvent = queues[0].EventName__c;
		System.assertEquals(anAccount.Id, queueAccount, 'The account was not queued');
		System.assertEquals(
			QueueEventNames.ACCOUNT_SALESFORCE_TO_SAP.name(),
			queueEvent,
			'The queue was created with wrong event name'
		);
	}
	@isTest
	static void testBulkUpdatingAccountNotCreatedInSapSystemWithStatusIntegrationInsertModeShouldInsertQueueToCreateIt() {
		List<Account> accounts = [SELECT Id, Status_Integration__c FROM Account];
		Set<String> accountIds = new Set<String>();
		for (Account theAccount : accounts) {
			theAccount.Status_Integration__c = 'Insert Mode';
			accountIds.add(theAccount.Id);
		}
		Test.startTest();
		update accounts;
		Test.stopTest();

		List<Queue__c> queues = [SELECT Id, Account__c, EventName__c FROM Queue__c];
		System.assertEquals(accounts.size(), queues.size(), 'Not all accounts were queued');
		for (Queue__c theQueue : queues) {
			String queueAccount = theQueue.Account__c;
			String queueEvent = theQueue.EventName__c;
			System.assert(accountIds.contains(queueAccount), 'There is an account that was not queued');
			System.assertEquals(
				QueueEventNames.ACCOUNT_SALESFORCE_TO_SAP.name(),
				queueEvent,
				'The queue was created with wrong event name'
			);
		}
	}

	@isTest
	static void testUpdatingAccountWithSatusIntegrationInsertModeAlreadyCreatedInSapShouldShowError() {
		Account anAccount = Build.anAccount()
			.withName('Account test')
			.withBillingCountry('US')
			.withGrupodeCuentas('US03 - Ship To')
			.withBillingState('NY')
			.withBillingStreet('Fake street')
			.withCodigoSAP('12345')
			.build();
		insert anAccount;
		Test.startTest();
		anAccount.Status_Integration__c = 'Insert Mode';
		anAccount.CodigoSap__c = '1111';
		Database.SaveResult result = Database.update(anAccount, false);
		Test.stopTest();

		System.assertEquals(
			'This account has already been created in SAP.',
			result.getErrors()[0].getMessage(),
			'The update was not expected to succeed'
		);
	}
}