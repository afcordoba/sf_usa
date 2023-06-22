public class growerFileProcessController {
	@AuraEnabled
	public static void generateGrowers(String contentId) {
		ContentVersion data = [SELECT Id, Title, VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :contentId];

		String documentBody = data.VersionData.toString();
		processFile(documentBody);
	}

	public static void processFile(String documentBody) {
		try {
			documentBody.replace('\'', '');
			List<String> documentStrings = documentBody.split('\n');
			List<String> documentHeader = documentStrings[0].split(',');
			documentStrings.remove(0);

			List<accountTraitsWrapper> results = new List<accountTraitsWrapper>();
			List<String> agcelerateIds = new List<String>();

			RecordType gposRecordType = [SELECT Id FROM RecordType WHERE sobjecttype = 'Account' AND name = 'GPOS Account'];
			Trait_Provider_License_Id__c trait;
			for (String documentRow : documentStrings) {
				List<String> values = documentRow.split(',');
				if (values[0].length() == 0) {
					continue;
				}
				if (agcelerateIds.contains(values[3]))
					continue;
				Account acc = new Account();
				acc.External_Id__c = values[0];
				acc.Agcelerate_Id__c = values[3];
				agcelerateIds.add(acc.Agcelerate_Id__c);

				acc.Email__c = values[4].remove('\r');
				acc.Phone = values[5].remove('\r');
				acc.Farm_Bussiness_Name__c = values[6].remove('\r');
				acc.Name =
					values[7].remove('\r') +
					' ' +
					values[8].remove('\r') +
					' ' +
					values[9].remove('\r') +
					' ' +
					values[10].remove('\r');
				acc.Address__c = values[11].remove('\r');
				acc.Alternate_Address__c = values[12].remove('\r');
				acc.City__c = values[13].remove('\r');
				acc.State__c = values[14].remove('\r');
				acc.Zip_Code__c = values[15].remove('\r');
				acc.RecordTypeId = gposRecordType.Id;
				acc.Type = 'Grower';
				accountTraitsWrapper wr = new accountTraitsWrapper();
				wr.account = acc;

				for (Integer i = 16; i < values.size(); i += 2) {
					if (!values[i].isWhitespace()) {
						trait = new Trait_Provider_License_ID__c();
						trait.name = values[i];
						trait.Trait_Provider__c = values[i + 1];
						wr.licences.add(trait);
					}
				}
				results.add(wr);
			}

			List<Account> existingAccounts = [
				SELECT Id, Agcelerate_Id__c, (SELECT Id, Name FROM Trait_Provider_License_IDS__r)
				FROM Account
				WHERE Agcelerate_Id__c IN :agcelerateIds
			];
			Map<String, Account> existingAccountsByAgcelerateId = new Map<String, Account>();

			for (Account acc : existingAccounts) {
				existingAccountsByAgcelerateId.put(acc.Agcelerate_Id__c, acc);
			}

			Map<String, Account> accountsToUpsert = new Map<String, Account>();
			List<Trait_Provider_License_ID__c> licencesToDelete = new List<Trait_Provider_License_ID__c>();
			for (accountTraitsWrapper wr : results) {
				if (existingAccountsByAgcelerateId.containsKey(wr.account.Agcelerate_Id__c)) {
					wr.account.Id = existingAccountsByAgcelerateId.get(wr.account.Agcelerate_Id__c).Id;
				}
				accountsToUpsert.put(wr.account.Agcelerate_Id__c, wr.account);
			}

			for (Account acc : existingAccounts) {
				licencesToDelete.addAll(acc.Trait_Provider_License_IDS__r);
			}

			upsert accountsToUpsert.values();
			delete licencesToDelete;

			List<Trait_Provider_License_ID__c> newTraits = new List<Trait_Provider_License_ID__c>();
			for (accountTraitsWrapper wr : results) {
				for (Trait_Provider_License_ID__c licence : wr.licences) {
					licence.Account__c = accountsToUpsert.get(wr.account.Agcelerate_Id__c).Id;
					newTraits.add(licence);
				}
			}
			insert newTraits;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class accountTraitsWrapper {
		Account account;

		List<Trait_Provider_License_ID__c> licences = new List<Trait_Provider_License_ID__c>();
	}
}