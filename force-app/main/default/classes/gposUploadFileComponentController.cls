public class gposUploadFileComponentController {
	@AuraEnabled
	public static ContentVersion contentVersion { get; set; }

	@AuraEnabled
	public static Dealer_Summary__c dealerSummary { get; set; }

	public gposUploadFileComponentController() {
		contentVersion = new ContentVersion();
		dealerSummary = new Dealer_Summary__c();
	}

	@AuraEnabled
	public static Dealer_Summary__c getDealerSummary(String AccountId) {
		try {
			List<Dealer_Summary__c> dealerSummary = new List<Dealer_Summary__c>();
			String season = (System.today().year() - 2000) + '/' + System.today().year();
			dealerSummary = [SELECT Id, Name FROM Dealer_Summary__c WHERE Client__c = :AccountId LIMIT 1];
			if (dealerSummary.size() > 0) {
				return dealerSummary[0];
			} else {
				return null;
			}
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	public static Dealer_Summary__c generateDealerSummary(String AccountId, String AccountName) {
		Dealer_Summary__c dealerSummary = new Dealer_Summary__c();
		dealerSummary.Client__c = AccountId;
		dealerSummary.Season__c = (System.today().year() - 2000) + '/' + System.today().year();
		dealerSummary.Name = AccountName + ' - ' + dealerSummary.Season__c;
		insert dealerSummary;
		return dealerSummary;
	}

	@AuraEnabled
	public static void generateTemps(String contentId, Id accountId) {
		try {
			ContentVersion data = [
				SELECT Id, Title, VersionData, ContentDocumentId
				FROM ContentVersion
				WHERE Id = :contentId
			];
			Account client = [SELECT Id, Name FROM Account WHERE Id = :accountId];
			GPOS_Customer_Report__c report = new GPOS_Customer_Report__c();
			report.Document__c = '/sfc/servlet.shepherd/document/download/' + contentId;
			report.Account__c = accountId;
			report.Name = data.Title;
			report.Type__c = 'Internal';
			insert report;
			String documentBody = data.VersionData.toString();

			Dealer_Summary__c dealerSum = getDealerSummary(accountId);
			if (dealerSum == null) {
				dealerSum = generateDealerSummary(accountId, client.Name);
			}

			//Delete previous data
			List<GPOS_Grower_Temp__c> tempsToDelete = [
				SELECT Id
				FROM GPOS_Grower_Temp__c
				WHERE Dealer_Summary__c = :dealerSum.Id
			];
			List<Dealer_Summary_Variety__c> dealerSumVarietiesToDelete = [
				SELECT Id
				FROM Dealer_Summary_Variety__c
				WHERE Dealer_Summary__c = :dealerSum.Id
			];
			delete tempsToDelete;
			delete dealerSumVarietiesToDelete;

			List<GrowerWrapper> wrappers = processFile(documentBody);

			Set<String> dealersExternalIds = new Set<String>();
			Set<String> dealersNames = new Set<String>();

			Set<String> varietiesNames = new Set<String>();
			// Retrieve existing data
			for (GrowerWrapper wr : wrappers) {
				if (!wr.DealerId.isWhitespace())
					dealersExternalIds.add(wr.DealerId);
				else
					dealersNames.add(wr.DealerName);

				for (GrowerProductWrapper wrProd : wr.products) {
					varietiesNames.add(wrProd.Variety);
				}
			}
			RecordType gposRecordType = [SELECT Id FROM RecordType WHERE sobjecttype = 'Account' AND name = 'GPOS Account'];
			List<Account> dealers = [
				SELECT Id, Name, External_Id__c
				FROM Account
				WHERE External_Id__c IN :dealersExternalIds
			];
			List<Account> dealersbyName = [
				SELECT Id, Name, External_Id__c
				FROM Account
				WHERE Name IN :dealersNames AND RecordTypeId = :gposRecordType.Id
			];

			List<Variedad__c> varieties = [SELECT Id, Name FROM Variedad__c WHERE Name IN :varietiesNames];
			Map<String, Account> AccountsMap = new Map<String, Account>();
			Map<String, Variedad__c> varietiesMap = new Map<String, Variedad__c>();
			for (Account dealer : dealers) {
				AccountsMap.put(dealer.External_Id__c, dealer);
			}
			for (Account dealer : dealersbyName) {
				if (dealer.External_Id__c != null && !dealer.External_Id__c.isWhitespace())
					AccountsMap.put(dealer.External_Id__c, dealer);
				else
					AccountsMap.put(dealer.Name, dealer);
			}

			for (Variedad__c variety : varieties) {
				varietiesMap.put(variety.Name, variety);
			}

			// Generate Missing Dealers
			Map<String, Account> NewAccountsMap = new Map<String, Account>();

			for (GrowerWrapper wr : wrappers) {
				if (
					!wr.dealerId.isWhitespace() &&
					!AccountsMap.containsKey(wr.DealerId) &&
					!NewAccountsMap.containsKey(wr.DealerId)
				) {
					Account newDealer = new Account();
					newDealer.External_Id__c = wr.DealerId;
					newDealer.Name = wr.DealerName;
					newDealer.Address__c = wr.DealerAddress;
					newDealer.Alternate_Address__c = wr.DealerAlternateAddress;
					newDealer.City__c = wr.DealerCity;
					newDealer.State__c = wr.DealerState;
					newDealer.Zip_Code__c = wr.DealerZipCode;
					newDealer.RecordTypeId = gposRecordType.Id;
					newDealer.Type = 'Dealer';
					NewAccountsMap.put(newDealer.External_Id__c, newDealer);
				} else if (
					wr.DealerId.isWhitespace() &&
					!wr.DealerName.isWhitespace() &&
					!AccountsMap.containsKey(wr.DealerName) &&
					!NewAccountsMap.containsKey(wr.DealerName)
				) {
					Account newDealer = new Account();
					newDealer.Name = wr.DealerName;
					newDealer.Address__c = wr.DealerAddress;
					newDealer.Alternate_Address__c = wr.DealerAlternateAddress;
					newDealer.City__c = wr.DealerCity;
					newDealer.State__c = wr.DealerState;
					newDealer.Zip_Code__c = wr.DealerZipCode;
					newDealer.RecordTypeId = gposRecordType.Id;
					newDealer.Type = 'Dealer';
					NewAccountsMap.put(newDealer.Name, newDealer);
				}
			}
			insert NewAccountsMap.values();
			AccountsMap.putAll(NewAccountsMap);

			// Generate Grower Temp
			Map<String, GPOS_Grower_Temp__c> growerTempMap = new Map<String, GPOS_Grower_Temp__c>();

			for (GrowerWrapper wr : wrappers) {
				GPOS_Grower_Temp__c temp = new GPOS_Grower_Temp__c();
				temp.Dealer_Summary__c = dealerSum.Id;
				if (AccountsMap.containsKey(wr.DealerId)) {
					temp.Dealer__c = AccountsMap.get(wr.DealerId).Id;
					wr.Dealer = temp.Dealer__c;
				} else if (AccountsMap.containsKey(wr.DealerName)) {
					temp.Dealer__c = AccountsMap.get(wr.DealerName).Id;
					wr.Dealer = temp.Dealer__c;
				}
				temp.Grower__c = wr.Grower;
				temp.Dealer_Address__c = wr.DealerAddress;
				temp.Dealer_Alternate_Address__c = wr.DealerAlternateAddress;
				temp.Dealer_City__c = wr.DealerCity;
				temp.Dealer_State__c = wr.DealerState;
				temp.Dealer_Zip_Code__c = wr.DealerZipCode;
				temp.Grower_Address__c = wr.GrowerAddress;
				temp.Grower_Alternate_Address__c = wr.GrowerAlternateAddress;
				temp.Grower_City__c = wr.GrowerCity;
				temp.Grower_State__c = wr.GrowerState;
				temp.Grower_Zip_Code__c = wr.GrowerZipCode;
				temp.Grower_Email_Address__c = wr.GrowerEmail;
				temp.Grower_Phone_Number__c = wr.GrowerPhone;
				temp.Name = wr.DealerName + ' - ' + wr.GrowerFirstName + ' ' + wr.GrowerLastName;

				String tempId = wr.DealerName + '' + wr.GrowerFirstName + wr.GrowerLastName;
				growerTempMap.put(tempId, temp);
			}

			insert growerTempMap.values();

			// Generate Variety Consolidation
			Map<String, GPOS_Variety_Consolidation__c> varConsolidationMap = new Map<String, GPOS_Variety_Consolidation__c>();
			for (GrowerWrapper wr : wrappers) {
				String tempId = wr.DealerName + '' + wr.GrowerFirstName + wr.GrowerLastName;
				for (GrowerProductWrapper prodWr : wr.products) {
					GPOS_Variety_Consolidation__c varConsolidation;
					System.debug(prodWr.Variety);
					if (!varConsolidationMap.containsKey(prodWr.Variety + tempId)) {
						varConsolidation = new GPOS_Variety_Consolidation__c();
						varConsolidation.GPOS_Grower_Temp__c = growerTempMap.get(tempId).Id;
						if (!prodWr.Variety.isWhitespace() && varietiesMap.containsKey(prodWr.Variety))
							varConsolidation.Variety__c = varietiesMap.get(prodWr.Variety).Id;
						else
							throw new AuraHandledException(
								'One or more of those varieties doesn`t exists in the system: ' + prodWr.Variety
							);
						varConsolidation.Name = prodWr.Variety;
						varConsolidationMap.put(prodWr.Variety + tempId, varConsolidation);
					}
				}
			}
			insert varConsolidationMap.values();

			// Generate Variety Temp and Dealer Summary Variety
			List<GPOS_Variety_Temp__c> gposVarietiesTemp = new List<GPOS_Variety_Temp__c>();
			Map<String, Dealer_Summary_Variety__c> dealerSumVarietyMap = new Map<String, Dealer_Summary_Variety__c>();
			for (GrowerWrapper wr : wrappers) {
				String tempId = wr.DealerName + '' + wr.GrowerFirstName + wr.GrowerLastName;
				for (GrowerProductWrapper prodWr : wr.products) {
					GPOS_Variety_Temp__c varietyTemp = new GPOS_Variety_Temp__c();
					varietyTemp.GPOS_Variety_Consolidation__c = varConsolidationMap.get(prodWr.Variety + tempId).Id;
					varietyTemp.Amount__c = Decimal.valueOf(prodWr.Amount);
					varietyTemp.Invoice_Date__c = Date.parse(prodWr.InvoiceDate);
					varietyTemp.Invoice_Number__c = prodWr.InvoiceNumber;
					varietyTemp.Invoice_Type__c = prodWr.InvoiceType;
					varietyTemp.Ship_Date__c = Date.parse(prodWr.ShipDate);
					varietyTemp.Trait__c = prodWr.Trait;
					varietyTemp.Name = prodWr.Variety;
					gposVarietiesTemp.add(varietyTemp);

					if (dealerSumVarietyMap.containsKey(prodWr.Variety)) {
						Dealer_Summary_Variety__c dsv = dealerSumVarietyMap.get(prodWr.Variety);
						switch on prodWr.InvoiceType {
							when 'IV' {
								dsv.IV_Amount__c += Decimal.valueOf(prodWr.Amount);
							}
							when 'CM' {
								dsv.CM_Amount__c += Decimal.valueOf(prodWr.Amount);
							}
							when 'RP' {
								dsv.RP_Amount__c += Decimal.valueOf(prodWr.Amount);
							}
						}
						dealerSumVarietyMap.put(prodWr.Variety, dsv);
					} else {
						Dealer_Summary_Variety__c dsv = new Dealer_Summary_Variety__c();
						dsv.Dealer_Summary__c = dealerSum.Id;
						dsv.Variety__c = varietiesMap.get(prodWr.Variety).Id;
						dsv.Name = prodWr.Variety;
						switch on prodWr.InvoiceType {
							when 'IV' {
								dsv.IV_Amount__c = Decimal.valueOf(prodWr.Amount);
								dsv.CM_Amount__c = 0;
								dsv.RP_Amount__c = 0;
							}
							when 'CM' {
								dsv.IV_Amount__c = 0;
								dsv.CM_Amount__c = Decimal.valueOf(prodWr.Amount);
								dsv.RP_Amount__c = 0;
							}
							when 'RP' {
								dsv.IV_Amount__c = 0;
								dsv.CM_Amount__c = 0;
								dsv.RP_Amount__c = Decimal.valueOf(prodWr.Amount);
							}
						}
						dealerSumVarietyMap.put(prodWr.Variety, dsv);
					}
				}
			}
			insert dealerSumVarietyMap.values();
			insert gposVarietiesTemp;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
		}
	}

	public static List<growerWrapper> processFile(String documentBody) {
		try {
			documentBody.replace('\'', '');
			List<String> documentStrings = documentBody.split('\n');
			List<String> documentHeader = documentStrings[0].split(',');
			documentStrings.remove(0);
			System.debug('DOCUMENT STRINGS -> ' + documentStrings);

			Map<String, GrowerWrapper> results = new Map<String, GrowerWrapper>();
			Map<String, Trait_Provider_License_ID__c> licencesMap = new Map<String, Trait_Provider_License_ID__c>();
			Set<String> licenceNumbers = new Set<String>();
			List<List<String>> valoresFilas = new List<List<String>>();
			for (String documentRow : documentStrings) {
				List<String> values = documentRow.split(',');
				for (String value : values) {
					System.debug(value);
					List<String> rowValues = value.split(';');
					valoresFilas.add(rowValues);
					licenceNumbers.add(rowValues[8].remove('\r'));
				}
			}
			System.debug('VALORES FILAS -> ' + valoresFilas);
			List<Trait_Provider_License_ID__c> licences = [
				SELECT Id, Name, Account__c
				FROM Trait_Provider_License_ID__c
				WHERE Name IN :licenceNumbers
			];
			for (Trait_Provider_License_ID__c licence : licences) {
				licencesMap.put(licence.Name, licence);
			}

			for (List<String> values : valoresFilas) {
				GrowerWrapper wr = new GrowerWrapper();
				// for (String values : rowValues) {
				// List<String> values = documentRow.split(',');
				System.debug('VALORES -> ' + values);
				if (values[1].length() == 0) {
					continue;
				}
				if (!values[1].remove('\r').isWhitespace() && values[1].remove('\r') != null) {
					if (results.containsKey(values[1].remove('\r') + values[9].remove('\r') + values[10].remove('\r')))
						wr = results.get(values[1].remove('\r') + values[9].remove('\r') + values[10].remove('\r'));
					else {
						wr.DealerId = values[0].remove('\r');
						wr.DealerName = values[1].remove('\r');
						wr.DealerAddress = values[2].remove('\r');
						wr.DealerAlternateAddress = values[3].remove('\r');
						wr.DealerCity = values[4].remove('\r');
						wr.DealerState = values[5].remove('\r');
						wr.DealerZipCode = values[6].remove('\r');
						wr.GrowerId = values[7].remove('\r');
						wr.LicenceNumber = values[8].remove('\r');
						wr.GrowerFirstName = values[9].remove('\r');
						wr.GrowerLastName = values[10].remove('\r');
						wr.GrowerBusinessName = values[11].remove('\r');
						wr.GrowerAddress = values[12].remove('\r');
						wr.GrowerAlternateAddress = values[13].remove('\r');
						wr.GrowerCity = values[14].remove('\r');
						wr.GrowerState = values[15].remove('\r');
						wr.GrowerZipCode = values[16].remove('\r');
						wr.GrowerPhone = values[17].remove('\r');
						wr.GrowerEmail = values[18].remove('\r');
						if (licencesMap.containsKey(wr.LicenceNumber)) {
							wr.Grower = licencesMap.get(wr.LicenceNumber).Account__c;
						}
						wr.products = new List<GrowerProductWrapper>();
					}

					GrowerProductWrapper prod = new GrowerProductWrapper();

					prod.ShipDate = values[19].remove('\r').replace('-', '/');
					prod.InvoiceDate = values[20].remove('\r').replace('-', '/');
					prod.InvoiceNumber = values[21].remove('\r');
					prod.Variety = values[22].remove('\r');
					prod.Trait = values[23].remove('\r');
					prod.Amount = values[24].remove('\r');
					prod.InvoiceType = values[25].remove('\r');
					System.debug(values[22]);

					wr.products.add(prod);
					results.put(wr.DealerName + wr.GrowerFirstName + wr.GrowerLastName, wr);
				}
				// }
			}

			return results.values();
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class GrowerWrapper {
		@AuraEnabled
		public String Dealer { get; set; }

		@AuraEnabled
		public String DealerId { get; set; }

		@AuraEnabled
		public String DealerName { get; set; }

		@AuraEnabled
		public String DealerAddress { get; set; }

		@AuraEnabled
		public String DealerAlternateAddress { get; set; }

		@AuraEnabled
		public String DealerCity { get; set; }

		@AuraEnabled
		public String DealerState { get; set; }

		@AuraEnabled
		public String DealerZipCode { get; set; }

		@AuraEnabled
		public String LicenceNumber { get; set; } // Preguntar a quien corresponde este Licence Id

		@AuraEnabled
		public String Grower { get; set; }

		@AuraEnabled
		public String GrowerId { get; set; }

		@AuraEnabled
		public String GrowerFirstName { get; set; }

		@AuraEnabled
		public String GrowerLastName { get; set; }

		@AuraEnabled
		public String GrowerBusinessName { get; set; }
		@AuraEnabled
		public String GrowerAddress { get; set; }
		@AuraEnabled
		public String GrowerAlternateAddress { get; set; }
		@AuraEnabled
		public String GrowerCity { get; set; }
		@AuraEnabled
		public String GrowerState { get; set; }
		@AuraEnabled
		public String GrowerZipCode { get; set; }
		@AuraEnabled
		public String GrowerPhone { get; set; }
		@AuraEnabled
		public String GrowerEmail { get; set; }
		@AuraEnabled
		public String type { get; set; }

		@AuraEnabled
		public List<GrowerProductWrapper> products { get; set; }
	}

	public class GrowerProductWrapper {
		@AuraEnabled
		public String ShipDate { get; set; }

		@AuraEnabled
		public String InvoiceDate { get; set; }

		@AuraEnabled
		public String InvoiceNumber { get; set; }

		@AuraEnabled
		public String Variety { get; set; }

		@AuraEnabled
		public String Trait { get; set; }

		@AuraEnabled
		public String Amount { get; set; }

		@AuraEnabled
		public String InvoiceType { get; set; }

		@AuraEnabled
		public Id productId { get; set; }
	}
}