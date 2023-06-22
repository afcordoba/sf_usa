/**
 * @description       :
 * @author            : Horacio Calleja
 * @group             :
 * @last modified on  : 01-18-2023
 * @last modified by  : Horacio Calleja
 **/
public class OpportunityLineItemTriggerUtils {
	public static Map<Id, OpportunityLineItem> productsWithRelations { get; set; }
	public static Boolean isBefore { get; set; }
	public static Boolean isAfter { get; set; }
	public static Boolean isInsert { get; set; }
	public static Boolean isUpdate { get; set; }
	public static Map<Id, OpportunityLineItem> newItems { get; set; }
	public static Map<Id, OpportunityLineItem> oldItems { get; set; }
	public static Boolean isSandbox { get; set; }

	public static void setUtilsProperties(
		Boolean isBefore,
		Boolean isAfter,
		Boolean isUpdate,
		Boolean isInsert,
		Map<Id, OpportunityLineItem> newProducts,
		Map<Id, OpportunityLineItem> oldProducts
	) {
		OpportunityLineItemTriggerUtils.isBefore = isBefore;
		OpportunityLineItemTriggerUtils.isAfter = isAfter;
		OpportunityLineItemTriggerUtils.isUpdate = isUpdate;
		OpportunityLineItemTriggerUtils.isInsert = isInsert;
		OpportunityLineItemTriggerUtils.newItems = newProducts;
		OpportunityLineItemTriggerUtils.oldItems = oldProducts;
		if (
			newItems != null &&
			newItems.size() > 0 &&
			(productsWithRelations == null || !productsWithRelations.keySet().containsAll(newProducts.keySet()))
		) {
			productsWithRelations = new Map<Id, OpportunityLineItem>(
				[
					SELECT
						Id,
						Name,
						Quantity_by_140k__c,
						Variedade_de_Produto__c,
						Quantity,
						Returned_Quantity__c,
						Product2.CANTIDAD_SUB_UNIDAD__c,
						Opportunity.Marca__c,
						OpportunityId,
						Opportunity.Safra__c,
						Opportunity.RecordTypeId,
						Opportunity.RecordType.DeveloperName,
						Opportunity.Name,
						Opportunity.Pricebook2Id,
						Warehouse__c,
						Centro_de_despacho__c,
						Opportunity.Account.Name,
						Product2Id,
						Product2.Unidade__c,
						Amount_Sold__c,
						Opportunity.Type,
						Opportunity.Was_Approved__c,
						Opportunity.Ship_To_City__c,
						Opportunity.Ship_To__r.Name,
						Product2.Name,
						Opportunity.RecordType.Name
					FROM OpportunityLineItem
					WHERE Id IN :newItems.keySet()
					LIMIT 50000
				]
			);
		}
	}

	public static void InventoryItemsApproved(Map<Id, OpportunityLineItem> oppLis) {
		Set<Id> productId = new Set<Id>();
		Set<Id> oppLisIds = new Set<Id>();
		for (OpportunityLineItem oppLi : oppLis.values()) {
			productId.add(oppLi.Product2Id);
			oppLisIds.add(oppLi.Id);
		}
		List<Product2> productList = [SELECT Id, Variedade__c FROM Product2 WHERE Id IN :productId];
		Map<Id, Id> productVarietyMap = new Map<Id, Id>();
		Set<Id> variedadId = new Set<Id>();
		for (product2 prod : productList) {
			productVarietyMap.put(prod.Id, prod.Variedade__c);
			variedadId.add(prod.Variedade__c);
		}
		List<Seed_Tracking__c> tracks = [
			SELECT
				Id,
				Variety__c,
				Product__c,
				Sale_Order__r.Marca__c,
				Sale_Order__r.Safra__c,
				Sale_Order__r.Pricebook2Id,
				Sale_Order__r.Type,
				Warehouse__c
			FROM Seed_Tracking__c
			WHERE Variety__c IN :variedadId
		];
		Map<String, List<Seed_Tracking__c>> tracksByKey = new Map<String, List<Seed_Tracking__c>>();
		List<Seed_Tracking__c> auxItems;
		for (Seed_Tracking__c st : tracks) {
			String seedType;
			if (st.Sale_Order__r.Type == 'Z3 - TEST SEED')
				seedType = 'Test Seed';
			else if (st.Sale_Order__r.Type == 'Z2 - PARENT SEED')
				seedType = 'Parent Seed';
			else if (st.Sale_Order__r.Type == 'Z4 - WHOLESALE SEED')
				seedType = 'Wholesale Seed';
			if (
				tracksByKey.containsKey(
					st.Variety__c +
					st.Warehouse__c +
					st.Sale_Order__r.Marca__c +
					st.Sale_Order__r.Safra__c +
					st.Sale_Order__r.Pricebook2Id +
					seedType
				)
			) {
				auxItems = tracksByKey.get(
					st.Variety__c +
					st.Warehouse__c +
					st.Sale_Order__r.Marca__c +
					st.Sale_Order__r.Safra__c +
					st.Sale_Order__r.Pricebook2Id +
					seedType
				);
				auxItems.add(st);
				tracksByKey.put(
					st.Variety__c +
					st.Warehouse__c +
					st.Sale_Order__r.Marca__c +
					st.Sale_Order__r.Safra__c +
					st.Sale_Order__r.Pricebook2Id +
					seedType,
					auxItems
				);
			} else {
				auxItems = new List<Seed_Tracking__c>();
				auxItems.add(st);
				tracksByKey.put(
					st.Variety__c +
					st.Warehouse__c +
					st.Sale_Order__r.Marca__c +
					st.Sale_Order__r.Safra__c +
					st.Sale_Order__r.Pricebook2Id +
					seedType,
					auxItems
				);
			}
		}

		List<OpportunityLineItem> oppLiList = [
			SELECT
				Id,
				Product2Id,
				Product2.Variedade__c,
				Opportunity.Marca__c,
				Opportunity.Safra__c,
				Opportunity.Pricebook2Id,
				Centro_de_despacho__c,
				Customer_ETA__c,
				Customer_Status__c,
				Opportunity.Seed_Type__c
			FROM OpportunityLineItem
			WHERE Id IN :oppLisIds
		];
		System.debug(tracksByKey.keySet());
		List<Seed_Tracking__c> tracksToUpdate = new List<Seed_Tracking__c>();
		for (OpportunityLineItem oppLi : oppLiList) {
			String key =
				oppLi.Product2.Variedade__c +
				oppLi.Centro_de_despacho__c +
				oppLi.Opportunity.Marca__c +
				oppLi.Opportunity.Safra__c +
				oppLi.Opportunity.Pricebook2Id +
				oppLi.Opportunity.Seed_Type__c;
			System.debug(key);
			if (tracksByKey.containsKey(key)) {
				for (Seed_Tracking__c track : tracksByKey.get(key)) {
					OpportunityLineItem actualOppLi = oppLis.get(oppLi.Id);
					track.Status__c = actualOppLi.Customer_Status__c;
					track.ETA_Customer__c = actualOppLi.Customer_ETA__c;
					tracksToUpdate.add(track);
				}
			}
		}
		update tracksToUpdate;
	}

	public static void TraitLicenseNotification(
		List<OpportunityLineItem> oppLiList,
		Map<Id, OpportunityLineItem> oldMap
	) {
		try {
			List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
			List<Profile> administrativeProfile = [SELECT Id FROM Profile WHERE Name = 'Administrative'];
			Map<Id, OpportunityLineItem> oliById = new Map<Id, OpportunityLineItem>();
			Set<Id> oppLineItemsIds = new Set<Id>();
			Id recordTypeProductionReport = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
				.get('Production_Report')
				.getRecordTypeId();
			Id recordTypeSalesReport = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
				.get('Sales_Report')
				.getRecordTypeId();
			EmailTemplate emTemplate = [
				SELECT Id, Subject, Body, HtmlValue
				FROM EmailTemplate
				WHERE DeveloperName = 'Variety_Changed_Template'
			];
			Configuracion_USA__c admingSettings = [SELECT Id, Sales_Admin_Email__c FROM Configuracion_USA__c LIMIT 1];
			CustomNotificationType notificationType = [
				SELECT Id, DeveloperName
				FROM CustomNotificationType
				WHERE DeveloperName = 'License_Variety_Updated'
				LIMIT 1
			];

			List<User> users = [SELECT Id FROM User WHERE ProfileId = :administrativeProfile[0].Id AND IsActive = TRUE];

			for (OpportunityLineItem oli : oppLiList) {
				oppLineItemsIds.add(oli.Id);
			}

			if (!oppLineItemsIds.isEmpty()) {
				List<OpportunityLineItem> opportunityProducts = [
					SELECT Id, Opportunity.Name, Opportunity.Account.Name, Opportunity.RecordTypeId
					FROM OpportunityLineItem
					WHERE Id IN :oppLineItemsIds
				];
				for (OpportunityLineItem anOli : opportunityProducts) {
					if (
						anOli.Opportunity.RecordTypeId == recordTypeProductionReport ||
						anOli.Opportunity.RecordTypeId == recordTypeSalesReport
					) {
						if (!oliById.containsKey(anOli.Id)) {
							oliById.put(anOli.Id, anOli);
						}
					}
				}
			}

			Set<String> recipentsIds = new Set<String>();
			for (User recipent : users) {
				recipentsIds.add(recipent.Id);
			}

			for (OpportunityLineItem oppLi : oppLiList) {
				if (oliById.containsKey(oppLi.Id)) {
					if (oppLi.Licensee_Variety_Name__c != oldMap.get(oppLi.Id).Licensee_Variety_Name__c) {
						Messaging.CustomNotification notification = new Messaging.CustomNotification();
						String opportunityName = oliById.containsKey(oppLi.Id) ? oliById.get(oppLi.Id).Opportunity.Name : '';
						String accountName = oliById.containsKey(oppLi.Id) ? oliById.get(oppLi.Id).Opportunity.Account.Name : '';
						String orderCompany = oppLi.Company__c;
						String commercialCode = oppLi.Variedade_de_Produto__c;
						String newVarietyId = oppLi.Licensee_Variety_Name__c;
						String oldVarietyId = oldMap.get(oppLi.Id).Licensee_Variety_Name__c;
						String finalMsg = '';
						String oppLineItemId = '' + oppLi.Id;
						finalMsg += 'Account Name: ' + accountName + '\n';
						finalMsg += 'Order Company: ' + orderCompany + '\n';
						finalMsg += 'GDM Commercial Code: ' + commercialCode + '\n';
						finalMsg += '(Old) Licence Variety Id: ' + oldVarietyId + '\n';
						finalMsg += '(New) Licence Variety Id: ' + newVarietyId + '\n';
						notification.setTitle(opportunityName + ' - License Variety ID Changed');
						notification.setBody(finalMsg);
						notification.setNotificationTypeId(notificationType.Id);
						notification.setTargetId(oppLi.OpportunityId);
						emails = prepareEmail(
							accountName,
							commercialCode,
							oldVarietyId,
							newVarietyId,
							orderCompany,
							oppLineItemId,
							emails,
							emTemplate,
							admingSettings.Sales_Admin_Email__c
						);
						try {
							notification.send(recipentsIds);
						} catch (Exception e) {
							System.debug(e.getStackTraceString());
							System.debug('Problem sending notification: ' + e.getMessage());
						}
					}
				}
			}
			if (emails.size() > 0) {
				Messaging.sendEmail(emails);
			}
		} catch (Exception ex) {
			System.debug(ex.getStackTraceString());
		}
	}

	public static List<Messaging.SingleEmailMessage> prepareEmail(
		String accountName,
		String commercialCode,
		String oldVariety,
		String newVariety,
		String orderCompany,
		String oppLineItemId,
		List<Messaging.SingleEmailMessage> emails,
		EmailTemplate emTemplate,
		String salesAdminEmail
	) {
		Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
		String currentUrl = URL.getSalesforceBaseUrl().toExternalForm();
		String[] sendingTo = new List<String>{ salesAdminEmail };
		semail.setToAddresses(sendingTo);
		semail.setSubject(emTemplate.subject);
		semail.setTemplateId(emTemplate.Id);
		String plainBody = emTemplate.HtmlValue;
		plainBody = accountName != null
			? plainBody.replace('{{{accountName}}}', accountName)
			: plainBody.replace('{{{accountName}}}', '....');
		plainBody = orderCompany != null
			? plainBody.replace('{{{orderCompany}}}', orderCompany)
			: plainBody.replace('{{{orderCompany}}}', '....');
		plainBody = commercialCode != null
			? plainBody.replace('{{{commercialCode}}}', commercialCode)
			: plainBody.replace('{{{commercialCode}}}', '....');
		plainBody = newVariety != null
			? plainBody.replace('{{{newVariety}}}', newVariety)
			: plainBody.replace('{{{newVariety}}}', '....');
		plainBody = oldVariety != null
			? plainBody.replace('{{{oldVariety}}}', oldVariety)
			: plainBody.replace('{{{oldVariety}}}', '....');
		plainBody = oppLineItemId != null
			? plainBody.replace('{{{oppLineItemId}}}', oppLineItemId)
			: plainBody.replace('{{{oppLineItemId}}}', '');

		plainBody = plainBody.replace('{{{currentOrg}}}', currentUrl);

		plainBody = plainBody.replace('{{{Sender.Name}}}', UserInfo.getName());

		semail.setHtmlBody(plainBody);
		semail.setTargetObjectId(UserInfo.getUserId());
		semail.setSaveAsActivity(false);
		emails.add(semail);

		return emails;
	}

	public static void updateLicenseeVarietyIds(
		Map<Id, OpportunityLineItem> oldProducts,
		Map<Id, OpportunityLineItem> newProducts
	) {
		Set<Id> accountIds = new Set<Id>();
		Set<String> varieties = new Set<String>();
		Set<String> seasons = new Set<String>();
		Set<String> brands = new Set<String>();
		Map<String, String> licenseVarietyIdByCommercialCode = new Map<String, String>();
		Map<String, List<OpportunityLineItem>> productsByCommercialCode = new Map<String, List<OpportunityLineItem>>();
		List<Item_del_Contrato__c> scheduleAVarieties = new List<Item_del_Contrato__c>();
		List<Item_del_Contrato__c> scheduleAVarietiesToUpdate = new List<Item_del_Contrato__c>();
		List<OpportunityLineItem> modifiedProducts = new List<OpportunityLineItem>();
		Set<Id> productsIds = new Set<Id>();
		for (Id productKey : newProducts.keySet()) {
			if (
				oldProducts == null ||
				(oldProducts.containsKey(productKey) &&
				oldProducts.get(productKey).Licensee_Variety_Name__c != newProducts.get(productKey).Licensee_Variety_Name__c)
			) {
				OpportunityLineItem theProduct = newProducts.get(productKey);
				productsIds.add(theProduct.Id);
			}
		}
		if (productsIds.size() > 0) {
			modifiedProducts = [
				SELECT
					Id,
					Opportunity.Safra__c,
					Opportunity.AccountId,
					Opportunity.Marca__c,
					Variedade_de_Produto__c,
					Licensee_Variety_Name__c
				FROM OpportunityLineItem
				WHERE Id IN :productsIds
			];

			for (OpportunityLineItem theProduct : modifiedProducts) {
				accountIds.add(theProduct.Opportunity.AccountId);
				varieties.add(theProduct.Variedade_de_Produto__c);
				brands.add(theProduct.Opportunity.Marca__c);
			}

			scheduleAVarieties = [
				SELECT
					Id,
					Name,
					Variedade__c,
					Licensee_Variety_ID__c,
					Contrato_de_Multiplicacion__r.Multiplicador__c,
					Contrato_de_Multiplicacion__r.Brand__c,
					Contrato_de_Multiplicacion__r.Sociedad__c,
					Contrato_de_Multiplicacion__r.Safra__c
				FROM Item_del_Contrato__c
				WHERE
					Variedade__c IN :varieties
					AND Contrato_de_Multiplicacion__r.Multiplicador__c IN :accountIds
					AND (Contrato_de_Multiplicacion__r.Brand__c IN :brands
					OR Contrato_de_Multiplicacion__r.Sociedad__c IN :brands)
			];

			for (Item_del_Contrato__c scheduleVariety : scheduleAVarieties) {
				String scheduleVarietyBrand = scheduleVariety.Contrato_de_Multiplicacion__r.Brand__c != null
					? scheduleVariety.Contrato_de_Multiplicacion__r.Brand__c
					: scheduleVariety.Contrato_de_Multiplicacion__r.Sociedad__c;
				String scheduleVarietySeason = scheduleVariety.Contrato_de_Multiplicacion__r.Safra__c;
				String scheduleVarietyAccount = scheduleVariety.Contrato_de_Multiplicacion__r.Multiplicador__c;
				String scheduleVarietyValue = scheduleVariety.Variedade__c;
				String scheduleLicenseeId = scheduleVariety.Licensee_Variety_ID__c;
				for (OpportunityLineItem modifiedProduct : modifiedProducts) {
					String productBrand = modifiedProduct.Opportunity.Marca__c;
					String productSeason = modifiedProduct.Opportunity.Safra__c;
					String productAccount = modifiedProduct.Opportunity.AccountId;
					String productVariety = modifiedProduct.Variedade_de_Produto__c;
					String productLicenseeId = modifiedProduct.Licensee_Variety_Name__c;
					List<String> splittedSeason = modifiedProduct.Opportunity.Safra__c.split('/');
					Integer firstNumber = Integer.valueOf(splittedSeason[0]) - 1;
					Integer secondNumber = Integer.valueOf(splittedSeason[1]) - 1;
					String productLastSeason = '' + firstNumber + '/' + secondNumber;
					if (
						productBrand == scheduleVarietyBrand &&
						productAccount == scheduleVarietyAccount &&
						productVariety == scheduleVarietyValue &&
						scheduleLicenseeId != productLicenseeId
					) {
						scheduleVariety.Licensee_Variety_ID__c = modifiedProduct.Licensee_Variety_Name__c;
						scheduleAVarietiesToUpdate.add(scheduleVariety);
					}
				}
			}
			if (!scheduleAVarietiesToUpdate.isEmpty()) {
				update scheduleAVarietiesToUpdate;
			}
		}
	}

	public static void handleInventoryStock(
		Map<Id, OpportunityLineItem> oldProducts,
		Map<Id, OpportunityLineItem> newProducts
	) {
		Set<String> brands = new Set<String>();
		Set<String> seasons = new Set<String>();
		Set<String> varieties = new Set<String>();
		Set<String> warehouses = new Set<String>();
		Set<String> plants = new Set<String>();
		Set<Id> productsIds = new Set<Id>();
		Set<Id> pricebooksIds = new Set<Id>();
		Id stockRt = XappiaHelper.getRecordType('Opportunity', 'Stock_per_Plant').Id;
		Id saleRt = XappiaHelper.getRecordType('Opportunity', 'Sale').Id;
		Id reservationRt = XappiaHelper.getRecordType('Opportunity', 'Reservation').Id;
		Map<Id, OpportunityLineItem> stockToUpdate = new Map<Id, OpportunityLineItem>();
		Map<String, List<OpportunityLineItem>> inventoryByBrandAndSeason = new Map<String, List<OpportunityLineItem>>();
		List<Opportunity> salesOpportunities = new List<Opportunity>();
		Map<Id, InventoryProduct> productsToRestock = new Map<Id, InventoryProduct>();
		ProductWrapper saleWrapper = new ProductWrapper();
		ProductWrapper reservationWrapper = new ProductWrapper();
		List<OpportunityLineItem> stockItems = new List<OpportunityLineItem>();
		List<InventoryProduct> missingStock = new List<InventoryProduct>();
		Map<String, Opportunity> inventories = new Map<String, Opportunity>();
		for (OpportunityLineItem newProduct : newProducts.values()) {
			if (isNewQuantityOrOldProductChanged(oldProducts, newProduct)) {
				System.debug(newProduct.Opportunity.Name);
				System.debug(newProduct.Product2.Unidade__c);
				System.debug(newProduct.Variedade_de_Produto__c);
				productsIds.add(newProduct.Id);
				warehouses.add(newProduct.Warehouse__c);
				plants.add(newProduct.Centro_de_despacho__c);
				if (wasWarehouseOrPlantChanged(newProduct)) {
					plants.add(oldProducts.get(newProduct.Id).Centro_de_despacho__c);
					warehouses.add(oldProducts.get(newProduct.Id).Warehouse__c);
				}
			}
		}

		if (OpportunityLineItemTriggerUtils.productsWithRelations == null) {
			OpportunityLineItemTriggerUtils.productsWithRelations = new Map<Id, OpportunityLineItem>(
				[
					SELECT
						Id,
						Name,
						Quantity_by_140k__c,
						Variedade_de_Produto__c,
						Quantity,
						Returned_Quantity__c,
						Product2.CANTIDAD_SUB_UNIDAD__c,
						Opportunity.Marca__c,
						OpportunityId,
						Opportunity.Safra__c,
						Opportunity.RecordTypeId,
						Opportunity.RecordType.DeveloperName,
						Opportunity.Name,
						Opportunity.Pricebook2Id,
						Warehouse__c,
						Centro_de_despacho__c,
						Opportunity.Account.Name,
						Product2Id,
						Product2.Unidade__c,
						Amount_Sold__c,
						Opportunity.Type
					FROM OpportunityLineItem
					WHERE Id IN :productsIds
				]
			);
		}

		if (productsIds != null && productsIds.size() > 0) {
			for (OpportunityLineItem prod : OpportunityLineItemTriggerUtils.productsWithRelations.values()) {
				if (
					prod.Opportunity.Type != 'Z16 - TRADEMARK ROYALTY' &&
					prod.Opportunity.Type != 'Z6 - ROYALTY' &&
					newProducts.containsKey(prod.Id)
				) {
					prod.Quantity = newProducts.get(prod.Id).Quantity == null ? 0 : newProducts.get(prod.Id).Quantity;
					prod.Amount_Sold__c = newProducts.get(prod.Id).Amount_Sold__c == null
						? 0
						: newProducts.get(prod.Id).Amount_Sold__c;
					prod.Warehouse__c = newProducts.get(prod.Id).Warehouse__c == null
						? ''
						: newProducts.get(prod.Id).Warehouse__c;
					prod.Centro_de_despacho__c = newProducts.get(prod.Id).Centro_de_despacho__c == null
						? ''
						: newProducts.get(prod.Id).Centro_de_despacho__c;
					prod.Reservation_Quantity__c = newProducts.get(prod.Id).Reservation_Quantity__c == null
						? 0
						: newProducts.get(prod.Id).Reservation_Quantity__c;
					if (
						prod.Opportunity.RecordTypeId == saleRt ||
						prod.Opportunity.RecordTypeId == reservationRt ||
						prod.Opportunity.RecordTypeId == stockRt
					) {
						if (prod.Opportunity.RecordTypeId == saleRt) {
							saleWrapper.newProducts.add(prod);
						}
						if (prod.Opportunity.RecordTypeId == reservationRt) {
							reservationWrapper.newProducts.add(prod);
						}

						if (prod.Opportunity.RecordTypeId == stockRt) {
							stockItems.add(prod);
						}

						brands.add(prod.Opportunity.Marca__c);
						seasons.add(prod.Opportunity.Safra__c);
						varieties.add(prod.Variedade_de_Produto__c);
					}
				}
			}

			if (stockItems.size() > 0) {
				handleInventoryProductsStock(stockItems);
			}

			if (
				(saleWrapper != null && saleWrapper.newProducts.size() > 0) ||
				(reservationWrapper != null &&
				reservationWrapper.newProducts.size() > 0 &&
				isAfter)
			) {
				for (Opportunity inventory : [
					SELECT
						Id,
						Marca__c,
						Safra__c,
						RecordTypeId,
						HasOpportunityLineItem,
						Pricebook2Id,
						(
							SELECT
								Id,
								Name,
								Quantity_by_140k__c,
								Variedade_de_Produto__c,
								Quantity,
								Returned_Quantity__c,
								Warehouse__c,
								Centro_de_despacho__c,
								OpportunityId,
								Amount_Sold__c,
								Opportunity.Marca__c,
								Opportunity.Safra__c,
								Opportunity.RecordTypeId,
								Opportunity.Pricebook2Id,
								Product2.Unidade__c,
								Product2Id,
								Product2.CANTIDAD_SUB_UNIDAD__c,
								Reservation_Quantity__c,
								Opportunity.Type
							FROM OpportunityLineItems
							WHERE
								Variedade_de_Produto__c IN :varieties
								AND Warehouse__c IN :warehouses
								AND Centro_de_despacho__c IN :plants
						)
					FROM Opportunity
					WHERE RecordTypeId = :stockRt AND StageName = 'Inventory' AND Safra__c IN :seasons AND Marca__c IN :brands
					ORDER BY CreatedDate DESC
				]) {
					String key = inventory.Marca__c + inventory.Safra__c;
					inventories.put(key, inventory);
					if (
						String.isNotBlank(inventory.Marca__c) &&
						String.isNotBlank(inventory.Safra__c) &&
						inventory.HasOpportunityLineItem
					) {
						if (!inventoryByBrandAndSeason.containsKey(key)) {
							inventoryByBrandAndSeason.put(key, new List<OpportunityLineItem>());
							inventoryByBrandAndSeason.get(key).addAll(inventory.OpportunityLineItems);
						} else {
							inventoryByBrandAndSeason.get(key).addAll(inventory.OpportunityLineItems);
						}
					}
				}

				saleWrapper.inventoryProducts = inventoryByBrandAndSeason;
				saleWrapper.oldProducts = oldProducts;
				reservationWrapper.inventoryProducts = inventoryByBrandAndSeason;
				reservationWrapper.oldProducts = oldProducts;

				// saleWrapper = handleSalesProductsStock(saleWrapper);
				saleWrapper = handleProductStock(saleWrapper);
				reservationWrapper = handleProductStock(reservationWrapper);

				for (OpportunityLineItem saleItem : saleWrapper.stockToUpdate.values()) {
					if (!stockToUpdate.containsKey(saleItem.Id)) {
						stockToUpdate.put(saleItem.Id, saleItem);
					} else {
						stockToUpdate.get(saleItem.Id).Amount_Sold__c += saleItem.Amount_Sold__c;
					}
				}

				for (OpportunityLineItem reservationItem : reservationWrapper.stockToUpdate.values()) {
					if (!stockToUpdate.containsKey(reservationItem.Id)) {
						stockToUpdate.put(reservationItem.Id, reservationItem);
					} else {
						stockToUpdate.get(reservationItem.Id).Reservation_Quantity__c += reservationItem.Reservation_Quantity__c;
					}
				}

				List<OpportunityLineItem> productsAdded = new List<OpportunityLineItem>();
				productsAdded.addAll(saleWrapper.newProducts);
				productsAdded.addAll(reservationWrapper.newProducts);

				missingStock = getMissingProducts(inventoryByBrandAndSeason, productsAdded, inventories);
				productsToRestock = getProductsToRestock(saleWrapper.stockMissing, reservationWrapper.stockMissing);

				if (stockToUpdate.size() > 0) {
					update stockToUpdate.values();
				}

				if (productsToRestock.size() > 0 || missingStock.size() > 0) {
					Set<String> usersIds = new Set<String>();
					List<Group> userGroup = [SELECT Id FROM Group WHERE DeveloperName = 'Inventory_Notification' LIMIT 1];
					for (GroupMember grMember : [
						SELECT Id, GroupId, UserOrGroupId
						FROM GroupMember
						WHERE GroupId = :userGroup[0].Id
					]) {
						if (String.valueOf(grMember.UserOrGroupId).startsWith('005')) {
							usersIds.add(grMember.UserOrGroupId);
						}
					}

					if (productsToRestock.size() > 0 || missingStock.size() > 0) {
						isSandbox = [SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()].IsSandbox;
						if (productsToRestock.size() > 0) {
							notificateStock(productsToRestock.values(), usersIds);
						}
						if (missingStock.size() > 0) {
							notificateMissingProducts(missingStock, usersIds);
						}
					}
				}
			}
		}
	}

	public static Boolean isTheSameProduct(OpportunityLineItem theProduct, OpportunityLineItem theProductToCompare) {
		return theProduct.Warehouse__c == theProductToCompare.Warehouse__c &&
			theProduct.Centro_de_despacho__c == theProductToCompare.Centro_de_despacho__c &&
			theProduct.Variedade_de_Produto__c == theProductToCompare.Variedade_de_Produto__c &&
			theProduct.Opportunity.Marca__c == theProductToCompare.Opportunity.Marca__c &&
			theProduct.Opportunity.Safra__c == theProductToCompare.Opportunity.Safra__c;
	}

	public static void handleInventoryProductsStock(List<OpportunityLineItem> inventoryItems) {
		// if (isBefore) {
		Set<String> varieties = new Set<String>();
		Set<String> brands = new Set<String>();
		Set<String> seasons = new Set<String>();

		List<OpportunityLineItem> saleAndReservationItems;
		Map<Id, OpportunityLineItem> inventoryToUpdate = new Map<Id, OpportunityLineItem>();
		for (OpportunityLineItem inventoryItem : inventoryItems) {
			brands.add(OpportunityLineItemTriggerUtils.productsWithRelations.get(inventoryItem.Id).Opportunity.Marca__c);
			seasons.add(OpportunityLineItemTriggerUtils.productsWithRelations.get(inventoryItem.Id).Opportunity.Safra__c);
			varieties.add(productsWithRelations.get(inventoryItem.Id).Variedade_de_Produto__c);
		}
		if (varieties.size() > 0) {
			saleAndReservationItems = [
				SELECT
					Id,
					Warehouse__c,
					Centro_de_despacho__c,
					Variedade_de_produto__c,
					Product2Id,
					Opportunity.RecordType.DeveloperName,
					Opportunity.Marca__c,
					Opportunity.Safra__c,
					Quantity_by_140k__c,
					Opportunity.Type
				FROM OpportunityLineItem
				WHERE
					(Opportunity.RecordType.DeveloperName = 'Sale'
					OR Opportunity.RecordType.DeveloperName = 'Reservation')
					AND Variedade_de_produto__c IN :varieties
					AND Opportunity.Marca__c = :brands
					AND Opportunity.Safra__c = :seasons
					AND Opportunity.StageName != 'Rejected'
			];
			for (OpportunityLineItem inventoryItem : inventoryItems) {
				String inventoryBrand = productsWithRelations.get(inventoryItem.Id).Opportunity.Marca__c;
				String inventorySeason = productsWithRelations.get(inventoryItem.Id).Opportunity.Safra__c;
				if (inventoryToUpdate.containsKey(inventoryItem.Id)) {
					inventoryItem = inventoryToUpdate.get(inventoryItem.Id);
				}
				if (wasWarehouseOrPlantChanged(inventoryItem)) {
					inventoryItem.Amount_Sold__c = 0;
					inventoryItem.Reservation_Quantity__c = 0;
				}
				for (OpportunityLineItem saleOrReservationItem : saleAndReservationItems) {
					if (
						isTheSameProduct(saleOrReservationItem, inventoryItem) &&
						(isInsert || wasWarehouseOrPlantChanged(inventoryItem))
					) {
						if (saleOrReservationItem.Opportunity.RecordType.DeveloperName == 'Sale') {
							inventoryItem.Amount_Sold__c += saleOrReservationItem.Quantity_by_140k__c;
						} else if (saleOrReservationItem.Opportunity.RecordType.DeveloperName == 'Reservation') {
							inventoryItem.Reservation_Quantity__c += saleOrReservationItem.Quantity_by_140k__c;
						}
						inventoryToUpdate.put(inventoryItem.Id, inventoryItem);
					}
				}
			}
		}
		if (oldItems != null) {
			for (OpportunityLineItem oldProduct : oldItems.values()) {
				if (inventoryToUpdate.containsKey(oldProduct.Id)) {
					OpportunityLineItem inventoryProduct = inventoryToUpdate.get(oldProduct.Id);
					if (
						inventoryProduct.Amount_Sold__c == oldProduct.Amount_Sold__c &&
						inventoryProduct.Reservation_Quantity__c == oldProduct.Reservation_Quantity__c
					) {
						inventoryToUpdate.remove(oldProduct.Id);
					}
				}
			}
		}
		if (inventoryToUpdate.size() > 0) {
			update inventoryToUpdate.values();
		}
	}

	public static void notificateMissingProducts(List<InventoryProduct> missingProducts, Set<String> usersIds) {
		if (!isSandbox) {
			sendStockEmailNotification(missingProducts);
		}
		sendStockSalesforceNotificationMissingStock(missingProducts, usersIds);
	}

	public static void notificateStock(List<InventoryProduct> stockProducts, Set<String> usersIds) {
		if (!isSandbox) {
			sendStockEmailNotification(stockProducts);
		}
		sendStockSalesforceNotification(stockProducts, usersIds);
	}

	public static Map<Id, InventoryProduct> getProductsToRestock(
		Map<Id, InventoryProduct> salesProducts,
		Map<Id, InventoryProduct> reservationProducts
	) {
		Map<Id, InventoryProduct> productsToRestock = new Map<Id, InventoryProduct>();
		for (InventoryProduct saleProduct : salesProducts.values()) {
			if (!productsToRestock.containsKey(saleProduct.productAdded.Id)) {
				productsToRestock.put(saleProduct.productAdded.Id, saleProduct);
			}
		}
		for (InventoryProduct reservationProd : reservationProducts.values()) {
			if (!productsToRestock.containsKey(reservationProd.productAdded.Id)) {
				productsToRestock.put(reservationProd.productAdded.Id, reservationProd);
			} else {
				productsToRestock.get(reservationProd.productAdded.Id).quantityToStock += reservationProd.quantityToStock;
				productsToRestock.get(reservationProd.productAdded.Id)
					.quantityToStockBy140k += reservationProd.quantityToStockBy140k;
			}
		}
		return productsToRestock;
	}

	public static List<InventoryProduct> getMissingProducts(
		Map<String, List<OpportunityLineItem>> inventoryProducts,
		List<OpportunityLineItem> productsAdded,
		Map<String, Opportunity> inventories
	) {
		// List<OpportunityLineItem> missingProducts = new List<OpportunityLineItem>();
		List<InventoryProduct> missingProducts = new List<InventoryProduct>();
		Map<Id, OpportunityLineItem> existingProducts = new Map<Id, OpportunityLineItem>();
		for (OpportunityLineItem itemAdded : productsAdded) {
			String key = itemAdded.Opportunity.Marca__c + itemAdded.Opportunity.Safra__c;
			if (inventoryProducts.containsKey(key)) {
				for (OpportunityLineItem inventoryItem : inventoryProducts.get(key)) {
					if (
						itemAdded.Variedade_de_Produto__c == inventoryItem.Variedade_de_Produto__c &&
						itemAdded.Warehouse__c == inventoryItem.Warehouse__c &&
						itemAdded.Centro_de_despacho__c == inventoryItem.Centro_de_despacho__c &&
						itemAdded.Opportunity.Pricebook2Id == inventoryItem.Opportunity.Pricebook2Id
					) {
						existingProducts.put(itemAdded.Id, itemAdded);
					}
				}
			}
		}
		for (OpportunityLineItem itemAdded : productsAdded) {
			if (!existingProducts.containsKey(itemAdded.Id)) {
				Opportunity relatedInventory;
				String key = itemAdded.Opportunity.Marca__c + itemAdded.Opportunity.Safra__c;
				if (inventories.containsKey(key) && inventories.get(key).Pricebook2Id == itemAdded.Opportunity.Pricebook2Id) {
					relatedInventory = inventories.get(key);
				} else {
					relatedInventory = itemAdded.Opportunity;
				}
				InventoryProduct missingProduct = new InventoryProduct();
				missingProduct.relatedInventory = relatedInventory;
				missingProduct.productAdded = itemAdded;
				missingProducts.add(missingProduct);
			}
		}
		return missingProducts;
	}

	public static Boolean wasWarehouseOrPlantChanged(OpportunityLineItem newProduct) {
		return (oldItems != null &&
		oldItems.containsKey(newProduct.Id) &&
		(newProduct.Warehouse__c != oldItems.get(newProduct.Id).Warehouse__c ||
		newProduct.Centro_de_despacho__c != oldItems.get(newProduct.Id).Centro_de_despacho__c));
	}

	public static ProductWrapper handleProductStock(ProductWrapper theProductWrapper) {
		for (OpportunityLineItem theProduct : theProductWrapper.newProducts) {
			String key = theProduct.Opportunity.Marca__c + theProduct.Opportunity.Safra__c;
			OpportunityLineItem oldProduct;
			if (theProductWrapper.oldProducts != null && theProductWrapper.oldProducts.containsKey(theProduct.Id)) {
				oldProduct = theProductWrapper.oldProducts.get(theProduct.Id);
			}
			if (theProductWrapper.inventoryProducts.containsKey(key)) {
				for (OpportunityLineItem inventoryProduct : theProductWrapper.inventoryProducts.get(key)) {
					inventoryProduct.Quantity = inventoryProduct.Quantity == 0.01 ? 0 : inventoryProduct.Quantity;
					inventoryProduct.Amount_Sold__c = inventoryProduct.Amount_Sold__c == null
						? 0
						: inventoryProduct.Amount_Sold__c;
					inventoryProduct.Reservation_Quantity__c = inventoryProduct.Reservation_Quantity__c == null
						? 0
						: inventoryProduct.Reservation_Quantity__c;
					if (theProductWrapper.stockToUpdate.containsKey(inventoryProduct.Id)) {
						inventoryProduct = theProductWrapper.stockToUpdate.get(inventoryProduct.Id);
					}
					theProductWrapper.newProduct = theProduct;
					theProductWrapper.oldProduct = oldProduct;
					theProductWrapper.inventoryProduct = inventoryProduct;
					theProductWrapper = handleUpdateOldInventory(theProductWrapper);
					if (
						theProduct.Variedade_de_Produto__c == inventoryProduct.Variedade_de_Produto__c &&
						theProduct.Warehouse__c == inventoryProduct.Warehouse__c &&
						theProduct.Centro_de_despacho__c == inventoryProduct.Centro_de_despacho__c &&
						theProduct.Opportunity.Pricebook2Id == inventoryProduct.Opportunity.Pricebook2Id
					) {
						if (theProduct.Opportunity.RecordType.DeveloperName == 'Reservation') {
							if (oldProduct != null) {
								theProductWrapper = handleUpdateReservationProducts(theProductWrapper);
							} else {
								theProductWrapper = handleInsertReservationProducts(theProductWrapper);
							}
						} else if (theProduct.Opportunity.RecordType.DeveloperName == 'Sale') {
							if (oldProduct != null) {
								theProductWrapper = handleUpdateSaleProducts(theProductWrapper);
							} else {
								theProductWrapper = handleInsertSaleProducts(theProductWrapper);
							}
						}
					}
				}
			}
		}
		return theProductWrapper;
	}

	// public static ProductWrapper handleSalesProductsStock(ProductWrapper salesWrapper) {
	// 	for (OpportunityLineItem salesProd : salesWrapper.newProducts) {
	// 		String key = salesProd.Opportunity.Marca__c + salesProd.Opportunity.Safra__c;
	// 		OpportunityLineItem oldProduct;
	// 		if (salesWrapper.oldProducts != null && salesWrapper.oldProducts.containsKey(salesProd.Id)) {
	// 			oldProduct = salesWrapper.oldProducts.get(salesProd.Id);
	// 		}
	// 		if (salesWrapper.inventoryProducts.containsKey(key)) {
	// 			for (OpportunityLineItem inventoryProduct : salesWrapper.inventoryProducts.get(key)) {
	// 				inventoryProduct.Quantity = inventoryProduct.Quantity == 0.01 ? 0 : inventoryProduct.Quantity;
	// 				inventoryProduct.Amount_Sold__c = inventoryProduct.Amount_Sold__c == null
	// 					? 0
	// 					: inventoryProduct.Amount_Sold__c;
	// 				if (salesWrapper.stockToUpdate.containsKey(inventoryProduct.Id)) {
	// 					inventoryProduct = salesWrapper.stockToUpdate.get(inventoryProduct.Id);
	// 				}
	// 				salesWrapper.newProduct = salesProd;
	// 				salesWrapper.oldProduct = oldProduct;
	// 				salesWrapper.inventoryProduct = inventoryProduct;
	// 				salesWrapper = handleUpdateOldInventory(salesWrapper);
	// 				if (
	// 					salesProd.Variedade_de_Produto__c == inventoryProduct.Variedade_de_Produto__c &&
	// 					salesProd.Warehouse__c == inventoryProduct.Warehouse__c &&
	// 					salesProd.Centro_de_despacho__c == inventoryProduct.Centro_de_despacho__c &&
	// 					salesProd.Opportunity.Pricebook2Id == inventoryProduct.Opportunity.Pricebook2Id
	// 				) {
	// 					if (oldProduct != null) {
	// 						salesWrapper = handleUpdateSaleProducts(salesWrapper);
	// 					} else {
	// 						salesWrapper = handleInsertSaleProducts(salesWrapper);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// 	return salesWrapper;
	// }

	public static ProductWrapper handleUpdateReservationProducts(ProductWrapper reservationWrapper) {
		OpportunityLineItem oldProduct = reservationWrapper.oldProduct;
		OpportunityLineItem newProduct = reservationWrapper.newProduct;
		OpportunityLineItem inventoryProduct = reservationWrapper.inventoryProduct;
		Decimal inventoryQuantity =
			inventoryProduct.Quantity_by_140k__c -
			inventoryProduct.Amount_Sold__c -
			inventoryProduct.Reservation_Quantity__c;
		Decimal newProdQuantity = convertTo140K(
			newProduct.Product2.Unidade__c,
			newProduct.Quantity,
			newItems.get(newProduct.Id).Quantity_by_140k__c == null
				? newProduct.Quantity
				: newItems.get(newProduct.Id).Quantity_by_140k__c
		);
		Decimal oldProdQuantity = convertTo140K(
			OpportunityLineItemTriggerUtils.productsWithRelations.get(oldProduct.Id).Product2.Unidade__c,
			oldProduct.Quantity,
			oldProduct.Quantity_by_140k__c == null ? oldProduct.Quantity : oldProduct.Quantity_by_140k__c
		);
		if (oldProdQuantity > newProduct.Quantity) {
			inventoryProduct.Reservation_Quantity__c -= oldProdQuantity - newProdQuantity;
		} else if (
			oldProduct.Quantity < newProduct.Quantity &&
			newProduct.Quantity - oldProdQuantity <= inventoryQuantity
		) {
			inventoryProduct.Reservation_Quantity__c += newProdQuantity - oldProdQuantity;
		} else if (
			oldProduct.Quantity == newProduct.Quantity &&
			(oldProduct.Warehouse__c != newProduct.Warehouse__c ||
			oldProduct.Centro_de_despacho__c != newProduct.Centro_de_despacho__c)
		) {
			inventoryProduct.Reservation_Quantity__c += newProdQuantity;
		} else {
			Double quantityToStock;
			Double balance = inventoryQuantity - (newProdQuantity - oldProdQuantity);
			if (inventoryQuantity < 0) {
				quantityToStock = newProdQuantity;
			} else {
				quantityToStock = newProdQuantity - inventoryQuantity;
			}
			inventoryProduct.Reservation_Quantity__c += newProdQuantity - oldProdQuantity;
			if (reservationWrapper.stockMissing.containsKey(inventoryProduct.Id)) {
				reservationWrapper.stockMissing.get(inventoryProduct.Id).quantityToStock += quantityToStock;
				reservationWrapper.stockMissing.get(inventoryProduct.Id).quantityToStockBy140k += quantityToStock;
				reservationWrapper.stockMissing.get(inventoryProduct.Id).balance += balance;
			} else {
				InventoryProduct inventoryToStock = new InventoryProduct(inventoryProduct, newProduct);
				inventoryToStock.quantityToStock = quantityToStock;
				inventoryToStock.quantityToStockBy140k = quantityToStock;
				inventoryToStock.balance = balance;
				inventoryToStock.relatedInventory = inventoryProduct.Opportunity;
				inventoryToStock.saleId = newProduct.OpportunityId;
				reservationWrapper.stockMissing.put(inventoryProduct.Id, inventoryToStock);
			}
		}

		reservationWrapper.newProduct = newProduct;
		reservationWrapper.oldProduct = oldProduct;
		reservationWrapper.inventoryProduct = inventoryProduct;

		reservationWrapper.stockToUpdate.put(inventoryProduct.Id, inventoryProduct);

		return reservationWrapper;
	}

	public static ProductWrapper handleInsertReservationProducts(ProductWrapper reservationWrapper) {
		OpportunityLineItem newProduct = reservationWrapper.newProduct;
		OpportunityLineItem inventoryProduct = reservationWrapper.inventoryProduct;
		Decimal inventoryQuantity =
			inventoryProduct.Quantity_by_140k__c -
			inventoryProduct.Amount_Sold__c -
			inventoryProduct.Reservation_Quantity__c;
		Decimal newProdQuantity = convertTo140K(
			newProduct.Product2.Unidade__c,
			newProduct.Quantity,
			newProduct.Quantity_by_140k__c == null ? newProduct.Quantity : newProduct.Quantity_by_140k__c
		);
		if (newProdQuantity <= inventoryQuantity) {
			inventoryProduct.Reservation_Quantity__c += newProdQuantity;
		} else if (newProdQuantity > inventoryQuantity) {
			Double quantityToStock;
			Double balance = inventoryQuantity - newProdQuantity;
			if (inventoryQuantity < 0) {
				quantityToStock = newProdQuantity;
			} else {
				quantityToStock = newProdQuantity - inventoryQuantity;
			}
			inventoryProduct.Reservation_Quantity__c += newProdQuantity;
			if (reservationWrapper.stockMissing.containsKey(inventoryProduct.Id)) {
				reservationWrapper.stockMissing.get(inventoryProduct.Id).quantityToStock += quantityToStock;
				reservationWrapper.stockMissing.get(inventoryProduct.Id).quantityToStockBy140k += quantityToStock;
				reservationWrapper.stockMissing.get(inventoryProduct.Id).balance += balance;
			} else {
				InventoryProduct inventoryToStock = new InventoryProduct(inventoryProduct, newProduct);
				inventoryToStock.quantityToStock = quantityToStock;
				inventoryToStock.quantityToStockBy140k = quantityToStock;
				inventoryToStock.balance = balance;
				inventoryToStock.relatedInventory = inventoryProduct.Opportunity;
				inventoryToStock.saleId = newProduct.OpportunityId;
				reservationWrapper.stockMissing.put(inventoryProduct.Id, inventoryToStock);
			}
		}
		reservationWrapper.newProduct = newProduct;
		reservationWrapper.inventoryProduct = inventoryProduct;
		reservationWrapper.stockToUpdate.put(inventoryProduct.Id, inventoryProduct);
		return reservationWrapper;
	}

	public static ProductWrapper handleUpdateSaleProducts(ProductWrapper saleWrapper) {
		OpportunityLineItem oldProduct = saleWrapper.oldProduct;
		OpportunityLineItem newProduct = saleWrapper.newProduct;
		OpportunityLineItem inventoryProduct = saleWrapper.inventoryProduct;
		Decimal realQuantity =
			inventoryProduct.Quantity_by_140k__c -
			inventoryProduct.Amount_Sold__c -
			inventoryProduct.Reservation_Quantity__c;
		Decimal newProdQuantity = convertTo140K(
			newProduct.Product2.Unidade__c,
			newProduct.Quantity,
			newItems.get(newProduct.Id).Quantity_by_140k__c == null
				? newProduct.Quantity
				: newItems.get(newProduct.Id).Quantity_by_140k__c
		);
		Decimal oldProdQuantity = convertTo140K(
			OpportunityLineItemTriggerUtils.productsWithRelations.get(oldProduct.Id).Product2.Unidade__c,
			oldProduct.Quantity,
			oldProduct.Quantity_by_140k__c == null ? oldProduct.Quantity : oldProduct.Quantity_by_140k__c
		);
		if (oldProdQuantity > newProdQuantity) {
			inventoryProduct.Amount_Sold__c -= oldProdQuantity - newProdQuantity;
		} else if (oldProdQuantity < newProdQuantity && newProdQuantity - oldProdQuantity <= realQuantity) {
			inventoryProduct.Amount_Sold__c += newProdQuantity - oldProdQuantity;
		} else if (
			oldProdQuantity == newProdQuantity &&
			(oldProduct.Warehouse__c != newProduct.Warehouse__c ||
			oldProduct.Centro_de_despacho__c != newProduct.Centro_de_despacho__c)
		) {
			inventoryProduct.Amount_Sold__c += newProdQuantity;
		} else {
			Double quantityToStock;
			Double balance = realQuantity - (newProdQuantity - oldProdQuantity);
			if (realQuantity < 0) {
				quantityToStock = newProdQuantity;
			} else {
				quantityToStock = newProdQuantity - realQuantity;
			}
			inventoryProduct.Amount_Sold__c += newProdQuantity - oldProdQuantity;
			if (saleWrapper.stockMissing.containsKey(inventoryProduct.Id)) {
				saleWrapper.stockMissing.get(inventoryProduct.Id).quantityToStock += quantityToStock;
				saleWrapper.stockMissing.get(inventoryProduct.Id).quantityToStockBy140k += quantityToStock;
				saleWrapper.stockMissing.get(inventoryProduct.Id).balance += balance;
			} else {
				InventoryProduct inventoryToStock = new InventoryProduct(inventoryProduct, newProduct);
				inventoryToStock.quantityToStock = quantityToStock;
				inventoryToStock.quantityToStockBy140k = quantityToStock;
				inventoryToStock.balance = balance;
				inventoryToStock.relatedInventory = inventoryProduct.Opportunity;
				inventoryToStock.saleId = newProduct.OpportunityId;
				saleWrapper.stockMissing.put(inventoryProduct.Id, inventoryToStock);
			}
		}

		saleWrapper.newProduct = newProduct;
		saleWrapper.oldProduct = oldProduct;
		saleWrapper.inventoryProduct = inventoryProduct;
		saleWrapper.stockToUpdate.put(inventoryProduct.Id, inventoryProduct);

		return saleWrapper;
	}

	public static ProductWrapper handleUpdateOldInventory(ProductWrapper productWrapper) {
		OpportunityLineItem oldProduct = productWrapper.oldProduct;
		OpportunityLineItem newProduct = productWrapper.newProduct;
		OpportunityLineItem inventoryProduct = productWrapper.inventoryProduct;
		// if (wasVarietyChanged(oldProduct, salesProd, inventoryProduct)) {
		// 	if (salesProd.Opportunity.RecordType.DeveloperName == 'Sale') {
		// 		inventoryProduct.Amount_Sold__c += convertTo140K(
		// 			oldProduct.Product2.Unidade__c,
		// 			oldProduct.Quantity,
		// 			oldProduct.Quantity_by_140k__c == null ? 0 : salesProd.Quantity_by_140k__c
		// 		);
		// 	} else if (salesProd.Opportunity.RecordType.DeveloperName == 'Reservation') {
		// 		inventoryProduct.Reservation_Quantity__c += convertTo140K(
		// 			oldProduct.Product2.Unidade__c,
		// 			oldProduct.Quantity,
		// 			oldProduct.Quantity_by_140k__c == null ? 0 : salesProd.Quantity_by_140k__c
		// 		);
		// 	}
		// }

		if (wasWarehouseOrPlantChanged(oldProduct, newProduct, inventoryProduct)) {
			if (newProduct.Opportunity.RecordType.DeveloperName == 'Sale') {
				inventoryProduct.Amount_Sold__c -= convertTo140K(
					oldProduct.Product2.Unidade__c,
					oldProduct.Quantity,
					oldProduct.Quantity_by_140k__c == null ? 0 : oldProduct.Quantity_by_140k__c
				);
			} else if (newProduct.Opportunity.RecordType.DeveloperName == 'Reservation') {
				inventoryProduct.Reservation_Quantity__c -= convertTo140K(
					oldProduct.Product2.Unidade__c,
					oldProduct.Quantity,
					oldProduct.Quantity_by_140k__c == null ? 0 : oldProduct.Quantity_by_140k__c
				);
			}
		}
		productWrapper.newProduct = newProduct;
		productWrapper.oldProduct = oldProduct;
		productWrapper.inventoryProduct = inventoryProduct;
		productWrapper.stockToUpdate.put(inventoryProduct.Id, inventoryProduct);
		return productWrapper;
	}

	public static ProductWrapper handleInsertSaleProducts(ProductWrapper saleWrapper) {
		OpportunityLineItem newProduct = saleWrapper.newProduct;
		OpportunityLineItem inventoryProduct = saleWrapper.inventoryProduct;
		Decimal inventoryQuantity =
			inventoryProduct.Quantity_by_140k__c -
			inventoryProduct.Amount_Sold__c -
			inventoryProduct.Reservation_Quantity__c;
		Decimal newProdQuantity = convertTo140K(
			newProduct.Product2.Unidade__c,
			newProduct.Quantity,
			newProduct.Quantity_by_140k__c == null ? newProduct.Quantity : newProduct.Quantity_by_140k__c
		);
		if (newProdQuantity <= inventoryQuantity) {
			inventoryProduct.Amount_Sold__c += newProdQuantity;
		} else if (newProdQuantity > inventoryQuantity) {
			Double quantityToStock;
			Double balance = inventoryQuantity - newProdQuantity;
			if (inventoryQuantity < 0) {
				quantityToStock = newProdQuantity;
			} else {
				quantityToStock = newProdQuantity - inventoryQuantity;
			}
			inventoryProduct.Amount_Sold__c += newProdQuantity;

			if (saleWrapper.stockMissing.containsKey(inventoryProduct.Id)) {
				saleWrapper.stockMissing.get(inventoryProduct.Id).quantityToStock += quantityToStock;
				saleWrapper.stockMissing.get(inventoryProduct.Id).quantityToStockBy140k += newProdQuantity;
				saleWrapper.stockMissing.get(inventoryProduct.Id).balance += balance;
			} else {
				InventoryProduct inventoryToStock = new InventoryProduct(inventoryProduct, newProduct);
				inventoryToStock.quantityToStock = quantityToStock;
				inventoryToStock.quantityToStockBy140k = quantityToStock;
				inventoryToStock.balance = balance;
				inventoryToStock.relatedInventory = inventoryProduct.Opportunity;
				inventoryToStock.saleId = newProduct.OpportunityId;
				saleWrapper.stockMissing.put(inventoryProduct.Id, inventoryToStock);
			}
		}
		saleWrapper.newProduct = newProduct;
		saleWrapper.inventoryProduct = inventoryProduct;
		saleWrapper.stockToUpdate.put(inventoryProduct.Id, inventoryProduct);
		return saleWrapper;
	}

	// public static ProductWrapper handleReservationProductsStock(ProductWrapper reservationWrapper) {
	// 	for (OpportunityLineItem reservationProd : reservationWrapper.newProducts) {
	// 		String key = reservationProd.Opportunity.Marca__c + reservationProd.Opportunity.Safra__c;
	// 		OpportunityLineItem oldProduct;
	// 		if (reservationWrapper.oldProducts != null && reservationWrapper.oldProducts.containsKey(reservationProd.Id)) {
	// 			oldProduct = reservationWrapper.oldProducts.get(reservationProd.Id);
	// 		}
	// 		if (reservationWrapper.inventoryProducts.containsKey(key)) {
	// 			for (OpportunityLineItem inventoryProduct : reservationWrapper.inventoryProducts.get(key)) {
	// 				inventoryProduct.Quantity = inventoryProduct.Quantity == 0.01 ? 0 : inventoryProduct.Quantity;
	// 				inventoryProduct.Reservation_Quantity__c = inventoryProduct.Reservation_Quantity__c == null
	// 					? 0
	// 					: inventoryProduct.Reservation_Quantity__c;
	// 				if (reservationWrapper.stockToUpdate.containsKey(inventoryProduct.Id)) {
	// 					inventoryProduct = reservationWrapper.stockToUpdate.get(inventoryProduct.Id);
	// 				}
	// 				reservationWrapper.newProduct = reservationProd;
	// 				reservationWrapper.oldProduct = oldProduct;
	// 				reservationWrapper.inventoryProduct = inventoryProduct;
	// 				reservationWrapper = handleUpdateOldInventory(reservationWrapper);
	// 				if (
	// 					reservationProd.Variedade_de_Produto__c == inventoryProduct.Variedade_de_Produto__c &&
	// 					reservationProd.Warehouse__c == inventoryProduct.Warehouse__c &&
	// 					reservationProd.Centro_de_despacho__c == inventoryProduct.Centro_de_despacho__c &&
	// 					reservationProd.Opportunity.Pricebook2Id == inventoryProduct.Opportunity.Pricebook2Id
	// 				) {
	// 					if (oldProduct != null) {
	// 						reservationWrapper = handleUpdateReservationProducts(reservationWrapper);
	// 					} else {
	// 						reservationWrapper = handleInsertReservationProducts(reservationWrapper);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// 	return reservationWrapper;
	// }

	public static Boolean isNewQuantityOrOldProductChanged(
		Map<Id, OpportunityLineItem> oldProducts,
		OpportunityLineItem newProduct
	) {
		Boolean criteriaFound = false;
		OpportunityLineItem oldProduct;
		if (oldProducts != null && oldProducts.containsKey(newProduct.Id)) {
			oldProduct = oldProducts.get(newProduct.Id);
		}
		if (
			oldProduct != null &&
			((oldProduct.Quantity != newProduct.Quantity) ||
			(oldProduct.Warehouse__c != null &&
			oldProduct.Warehouse__c != newProduct.Warehouse__c) ||
			(oldProduct.Centro_de_despacho__c != null &&
			oldProduct.Centro_de_despacho__c != newProduct.Centro_de_despacho__c) ||
			(oldProduct.Product2Id != newProduct.Product2Id)) || (oldProduct == null && newProduct.Quantity > 0)
		) {
			criteriaFound = true;
		}
		return criteriaFound;
	}

	public static Boolean wasWarehouseOrPlantChanged(
		OpportunityLineItem oldProduct,
		OpportunityLineItem newProd,
		OpportunityLineItem inventoryProduct
	) {
		Boolean wasChanged = false;
		if (
			oldProduct != null &&
			newProd.Variedade_de_Produto__c == inventoryProduct.Variedade_de_Produto__c &&
			newProd.Product2Id == inventoryProduct.Product2Id &&
			(oldProduct.Warehouse__c != null ||
			oldProduct.Centro_de_despacho__c != null) &&
			((oldProduct.Warehouse__c != newProd.Warehouse__c &&
			inventoryProduct.Warehouse__c == oldProduct.Warehouse__c &&
			inventoryProduct.Centro_de_despacho__c == newProd.Centro_de_despacho__c) ||
			(oldProduct.Centro_de_despacho__c != newProd.Centro_de_despacho__c &&
			inventoryProduct.Centro_de_despacho__c == oldProduct.Centro_de_despacho__c &&
			inventoryProduct.Warehouse__c == newProd.Warehouse__c) ||
			(oldProduct.Centro_de_despacho__c != newProd.Centro_de_despacho__c &&
			oldProduct.Warehouse__c != newProd.Warehouse__c &&
			inventoryProduct.Centro_de_despacho__c == oldProduct.Centro_de_despacho__c &&
			inventoryProduct.Warehouse__c == oldProduct.Warehouse__c))
		) {
			wasChanged = true;
		}
		return wasChanged;
	}

	public static Decimal convertTo140K(String unitType, Decimal quantity, Decimal quantityBy140k) {
		Decimal convertedQuantity = quantityBy140k;
		if (unitType == 'BAGS BY LBS' || unitType == 'LB') {
			convertedQuantity = quantity / 50;
		} else if (unitType == 'BAG 40(140K)') {
			convertedQuantity = quantity * 40;
		}
		return convertedQuantity;
	}

	public static void sendStockSalesforceNotification(List<InventoryProduct> stockProducts, Set<String> usersIds) {
		String urlSalesforce = URL.getSalesforceBaseUrl().toExternalForm();

		CustomNotificationType notificationType = [
			SELECT Id, DeveloperName
			FROM CustomNotificationType
			WHERE DeveloperName = 'Inventory_Stock_Request'
			LIMIT 1
		];
		for (InventoryProduct inventoryProd : stockProducts) {
			String productsString = '';
			String variety = inventoryProd.productAdded.Variedade_de_Produto__c == null
				? '-'
				: inventoryProd.productAdded.Variedade_de_Produto__c;
			productsString += 'Name: ' + inventoryProd.productAdded.Name + '\n';
			productsString += 'Variety: ' + variety + '\n';
			productsString += 'Plant: ' + inventoryProd.productAdded.Centro_de_despacho__c + '\n';
			productsString += 'Warehouse: ' + inventoryProd.productAdded.Warehouse__c + '\n';
			productsString += 'Brand: ' + inventoryProd.productAdded.Opportunity.Marca__c + '\n';
			productsString += 'Season: ' + inventoryProd.productAdded.Opportunity.Safra__c + '\n';
			productsString += 'Type: ' + inventoryProd.productAdded.Opportunity.Type + '\n';
			productsString += 'Balance (by 140k): ' + inventoryProd.balance + '\n';
			productsString += 'Account: ' + inventoryProd.saleAccountName + '\n';
			productsString += 'Opportunity Sales Id: ' + inventoryProd.saleId + '\n';
			Messaging.CustomNotification notification = new Messaging.CustomNotification();
			notification.setTitle('Inventory Stock Request');
			notification.setBody(productsString);
			notification.setNotificationTypeId(notificationType.Id);
			notification.setTargetId(inventoryProd.relatedInventory.Id);
			notification.send(usersIds);
		}
	}
	public static void sendStockSalesforceNotificationMissingStock(
		List<InventoryProduct> inventoryProducts,
		Set<String> usersIds
	) {
		String urlSalesforce = URL.getSalesforceBaseUrl().toExternalForm();

		CustomNotificationType notificationType = [
			SELECT Id, DeveloperName
			FROM CustomNotificationType
			WHERE DeveloperName = 'Inventory_Product_Missing_Request'
			LIMIT 1
		];
		for (InventoryProduct inventoryProd : inventoryProducts) {
			String productsString = '';
			String variety = inventoryProd.productAdded.Variedade_de_Produto__c == null
				? '-'
				: inventoryProd.productAdded.Variedade_de_Produto__c;
			productsString += 'Name: ' + inventoryProd.productAdded.Name + '\n';
			productsString += 'Variety: ' + variety + '\n';
			productsString += 'Plant: ' + inventoryProd.productAdded.Centro_de_despacho__c + '\n';
			productsString += 'Warehouse: ' + inventoryProd.productAdded.Warehouse__c + '\n';
			productsString += 'Brand: ' + inventoryProd.productAdded.Opportunity.Marca__c + '\n';
			productsString += 'Season: ' + inventoryProd.productAdded.Opportunity.Safra__c + '\n';
			productsString += 'Type: ' + inventoryProd.productAdded.Opportunity.Type + '\n';
			productsString += 'Quantity (by 140k): ' + inventoryProd.productAdded.Quantity_by_140k__c + '\n';
			Messaging.CustomNotification notification = new Messaging.CustomNotification();
			notification.setTitle('Inventory Product Missing');
			notification.setBody(productsString);
			notification.setNotificationTypeId(notificationType.Id);
			notification.setTargetId(inventoryProd.relatedInventory.Id);
			notification.send(usersIds);
		}
	}

	// public static void sendStockEmailNotification(List<InventoryProduct> stockProducts) {
	// 	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	// 	List<String> emails = new List<String>{
	// 		GDM_Emails__mdt.getInstance('Production').Email__c,
	// 		GDM_Emails__mdt.getInstance('Sales').Email__c
	// 	};

	// 	// List<String> emails = new List<String>{ 'horacio.calleja@globant.com' };
	// 	String urlSalesforce = URL.getSalesforceBaseUrl().toExternalForm();
	// 	message.toAddresses = emails;
	// 	message.subject = 'Restock request for Sales';
	// 	String productsString = '';
	// 	for (InventoryProduct inventoryProd : stockProducts) {
	// 		String variety = inventoryProd.productAdded.Variedade_de_Produto__c == null
	// 			? '-'
	// 			: inventoryProd.productAdded.Variedade_de_Produto__c;
	// 		productsString += 'Name: ' + inventoryProd.productAdded.Name + '\n';
	// 		productsString += 'Variety: ' + variety + '\n';
	// 		productsString += 'Plant: ' + inventoryProd.productAdded.Centro_de_despacho__c + '\n';
	// 		productsString += 'Warehouse: ' + inventoryProd.productAdded.Warehouse__c + '\n';
	// 		productsString += 'Brand: ' + inventoryProd.productAdded.Opportunity.Marca__c + '\n';
	// 		productsString += 'Season: ' + inventoryProd.productAdded.Opportunity.Safra__c + '\n';
	// 		productsString += 'Type: ' + inventoryProd.productAdded.Opportunity.Type + '\n';
	// 		productsString += 'Quantity (by 140k): ' + inventoryProd.productAdded.Quantity_by_140k__c + '\n';
	// 		productsString +=
	// 			'Link to Inventory Product in salesforce : ' +
	// 			urlSalesforce +
	// 			'/' +
	// 			inventoryProd.relatedInventory.Id +
	// 			'\n';
	// 		productsString +=
	// 			'Link to the Sale in salesforce : ' +
	// 			urlSalesforce +
	// 			'/' +
	// 			inventoryProd.productAdded.OpportunityId +
	// 			'\n \n';
	// 	}

	// 	message.plainTextBody =
	// 		'Dear Admin, \n \n' +
	// 		'There are products that were added to Sales opportunities which we don' +
	// 		'\'t have in stock. This products are: \n \n' +
	// 		productsString +
	// 		'\n \nGDM Seeds';
	// 	Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
	// 	Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
	// }

	public static void sendStockEmailNotification(List<InventoryProduct> stockProducts) {
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		List<String> emails = new List<String>{
			GDM_Emails__mdt.getInstance('Production').Email__c,
			GDM_Emails__mdt.getInstance('Sales').Email__c
		};
		String urlSalesforce = URL.getSalesforceBaseUrl().toExternalForm();
		message.toAddresses = emails;
		message.subject = 'Stock missing for Sales';
		String productsString = '';
		for (InventoryProduct inventoryProd : stockProducts) {
			String variety = inventoryProd.productAdded.Variedade_de_Produto__c == null
				? '-'
				: inventoryProd.productAdded.Variedade_de_Produto__c;
			productsString += 'Name: ' + inventoryProd.productAdded.Name + '\n';
			productsString += 'Variety: ' + variety + '\n';
			productsString += 'Plant: ' + inventoryProd.productAdded.Centro_de_despacho__c + '\n';
			productsString += 'Warehouse: ' + inventoryProd.productAdded.Warehouse__c + '\n';
			productsString += 'Brand: ' + inventoryProd.productAdded.Opportunity.Marca__c + '\n';
			productsString += 'Season: ' + inventoryProd.productAdded.Opportunity.Safra__c + '\n';
			productsString += 'Type: ' + inventoryProd.productAdded.Opportunity.Type + '\n';
			productsString += 'Quantity (by 140k): ' + inventoryProd.productAdded.Quantity_by_140k__c + '\n';
			productsString +=
				'Link to Inventory Product in salesforce : ' +
				urlSalesforce +
				'/' +
				inventoryProd.relatedInventory.Id +
				'\n';
			productsString +=
				'Link to the Sale in salesforce : ' +
				urlSalesforce +
				'/' +
				inventoryProd.productAdded.OpportunityId +
				'\n \n';
		}

		message.plainTextBody =
			'Dear Admin, \n \n' +
			'There are products that were added to Sales opportunities which we don' +
			'\'t have in stock. This products are: \n \n' +
			productsString +
			'\n \nGDM Seeds';
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
	}

	public static void handleDeletion(List<OpportunityLineItem> oldItems) {
		List<Registro_de_Eliminacion__c> regs = new List<Registro_de_Eliminacion__c>();
		for (OpportunityLineItem i : oldItems) {
			Registro_de_Eliminacion__c reg = new Registro_de_Eliminacion__c();
			reg.Fecha_eliminacion__c = system.today();
			reg.Id_reg_objeto__c = i.Id;
			reg.Nombre_objeto__c = 'OpportunityLineItem';
			regs.add(reg);
		}
		insert regs;
	}

	public static void handleUpdateValues(
		Map<Id, OpportunityLineItem> oldItems,
		Map<Id, OpportunityLineItem> newItems,
		Boolean isBefore,
		Boolean isAfter
	) {
		//changePlant method added by pablo.fraquia@cloudgaia.com for ticket 30836 #3649
		changePlant(new List<OpportunityLineItem>(newItems.values()));
		Map<Id, OpportunityLineItem> itemsWithRelations;
		if (isAfter) {
			itemsWithRelations = new Map<Id, OpportunityLineItem>(
				[
					SELECT
						Opportunity.RecordType.Name,
						Opportunity.Type,
						Opportunity.Was_Approved__c,
						Opportunity.Ship_To_City__c,
						Opportunity.Ship_To__r.Name,
						Product2.Name
					FROM OpportunityLineItem
					WHERE Id IN :newItems.keySet()
				]
			);
		}

		if (isBefore) {
			setRejectionReason(oldItems, newItems);
		}
		if (isAfter) {
			setProductChanges(oldItems, newItems, itemsWithRelations);
		}
	}

	public static void handleInsertValues(List<OpportunityLineItem> newItems, Boolean isBefore, Boolean isAfter) {
		Set<Id> ids = new Set<Id>();
		Set<Id> oppsIds = new Set<Id>();
		for (OpportunityLineItem item : newItems) {
			ids.add(item.Id);
			oppsIds.add(item.OpportunityId);
			System.debug(item.Id);
		}

		if (isBefore) {
			changePlant(newItems);

			List<Opportunity> oppsRelated = [SELECT Id, RecordType.Name, Type FROM Opportunity WHERE Id IN :oppsIds];
			for (OpportunityLineItem newItem : newItems) {
				for (Opportunity relatedOpp : oppsRelated) {
					if (newItem.OpportunityId == relatedOpp.Id) {
						newItem.Opportunity = relatedOpp;
					}
				}
			}
			setType(newItems);
			setRateEstimation(newItems);
		}
	}

	public static void setRejectionReason(
		Map<Id, OpportunityLineItem> oldProducts,
		Map<Id, OpportunityLineItem> newProducts
	) {
		for (Id newKeyProd : newProducts.keySet()) {
			if (
				oldProducts.get(newKeyProd).Motivo_de_Rechazo__c != newProducts.get(newKeyProd).Motivo_de_Rechazo__c &&
				newProducts.get(newKeyProd).Motivo_de_Rechazo__c == 'null'
			) {
				newProducts.get(newKeyProd).Motivo_de_Rechazo__c = '';
			}
		}
	}

	public static void setType(List<OpportunityLineItem> newProducts) {
		for (OpportunityLineItem newProduct : newProducts) {
			String recordTypeName = newProduct.Opportunity.RecordType.Name;
			String oppType = newProduct.Opportunity.Type;
			if (recordTypeName == 'Production Report') {
				newProduct.Sales_Report_Type__c = oppType;
			} else if (recordTypeName == 'Sales Report') {
				newProduct.Sales_Report_Type__c = 'Sale';
			}
			// }
		}
	}

	public static void changePlant(List<OpportunityLineItem> products) {
		for (OpportunityLineItem prod : products) {
			if (String.isNotBlank(prod.Centro_de_despacho__c) && prod.Centro_de_despacho__c.length() == 4) {
				switch on prod.Centro_de_despacho__c {
					when 'E001' {
						prod.Centro_de_despacho__c = 'E001 - B&B - CHAMPAIGN';
					}
					when 'E002' {
						prod.Centro_de_despacho__c = 'E002 - B&B - GIBSON CITY';
					}
					when 'E003' {
						prod.Centro_de_despacho__c = 'E003 - B&B - JONESBORO';
					}
					when 'E004' {
						prod.Centro_de_despacho__c = 'E004 - B&B - PRO AG';
					}
					when 'U002' {
						prod.Centro_de_despacho__c = 'U002 - GDM - GIBSON CITY';
					}
					when 'U003' {
						prod.Centro_de_despacho__c = 'U003 - GDM - JONESBORO';
					}
					when 'U004' {
						prod.Centro_de_despacho__c = 'U004 - GDM - PRO AG';
					}
					when 'U005' {
						prod.Centro_de_despacho__c = 'U005 - GDM - HUTCHINSON';
					}
					when 'U006' {
						prod.Centro_de_despacho__c = 'U006 - GDM - DES MOINES';
					}
					when 'U001' {
						prod.Centro_de_despacho__c = 'U001 - GDM - CHAMPAIGN';
					}
					when else {
						prod.Centro_de_despacho__c = 'not found';
					}
				}
			}
		}
	}

	public static Opportunity_Product_Change__c createOpportunityProductChange(
		OpportunityLineItem newItem,
		OpportunityLineItem oldItem,
		OpportunityLineItem itemWithRelations
	) {
		Opportunity_Product_Change__c oppProductChange = new Opportunity_Product_Change__c();
		oppProductChange.Name = itemWithRelations.Product2.Name;
		oppProductChange.New_Quantity__c = newItem.Quantity;
		oppProductChange.New_ShipTo_City__c = itemWithRelations.Opportunity.Ship_To_City__c;
		oppProductChange.New_ShipTo__c = itemWithRelations.Opportunity.Ship_To__r.Name;
		oppProductChange.New_warehouse__c = newItem.Centro_de_despacho__c;
		oppProductChange.Opportunity__c = newItem.OpportunityId;
		oppProductChange.Opportunuty_Product_Id__c = newItem.Id;
		oppProductChange.Prior_Quantity__c = oldItem.Quantity;
		oppProductChange.Prior_Warehouse__c = oldItem.Centro_de_despacho__c;
		oppProductChange.Product__c = newItem.Product2Id;
		if (String.isNotBlank(newItem.Motivo_de_Rechazo__c)) {
			oppProductChange.Reason__c = 'Rejection';
		} else if (oldItem.Centro_de_despacho__c != newItem.Centro_de_despacho__c) {
			oppProductChange.Reason__c = 'Warehouse Change';
		} else {
			oppProductChange.Reason__c = 'Quantity Change';
		}
		oppProductChange.Type__c = itemWithRelations.Opportunity.RecordType.Name;
		return oppProductChange;
	}

	public static void setRateEstimation(List<OpportunityLineItem> newItems) {
		for (OpportunityLineItem item : newItems) {
			if (item.Royalty_Rate__c != null && item.Forecast_Quantity__c != null) {
				item.Royalty_Estimation__c = item.Forecast_Quantity__c * item.Royalty_Rate__c;
			}
		}
	}

	public static void setProductChanges(
		Map<Id, OpportunityLineItem> oldProducts,
		Map<Id, OpportunityLineItem> newProducts,
		Map<Id, OpportunityLineItem> itemsWithRelations
	) {
		List<Opportunity_Product_Change__c> productsChange = new List<Opportunity_Product_Change__c>();
		for (OpportunityLineItem newProduct : newProducts.values()) {
			String recordTypeName = itemsWithRelations.get(newProduct.Id).Opportunity.RecordType.Name;
			Boolean oppWasApproved = itemsWithRelations.get(newProduct.Id).Opportunity.Was_Approved__c;
			if (oldProducts != null && oldProducts.containsKey(newProduct.Id)) {
				OpportunityLineItem oldProd = oldProducts.get(newProduct.Id);
				if (
					oldProd.Quantity_by_140k__c != newProduct.Quantity_by_140k__c ||
					oldProd.Centro_de_despacho__c != newProduct.Centro_de_despacho__c &&
					(recordTypeName == 'Stock per plant' ||
					recordTypeName == 'Reservation' ||
					(recordTypeName == 'Sale' && oppWasApproved))
				) {
					productsChange.add(
						createOpportunityProductChange(newProduct, oldProd, itemsWithRelations.get(newProduct.Id))
					);
				}
			}
		}
		if (productsChange.size() > 0) {
			insert productsChange;
		}
	}

	/**
	 * @description  	When items are deleted, the quantities of those products should be reduced from their inventory
	 *
	 * @param oldItems
	 */
	public static void removeInventoryStock(Map<Id, OpportunityLineItem> oldItems) {
		Set<Id> opportunityIds = new Set<Id>();
		Set<String> varieties = new Set<String>();
		Set<String> warehouses = new Set<String>();
		Set<String> plants = new Set<String>();
		Set<String> seasons = new Set<String>();
		Set<String> brands = new Set<String>();
		List<OpportunityLineItem> itemsToRemove = new List<OpportunityLineItem>();
		List<Opportunity> opps;
		List<Opportunity> oppsToReduce = new List<Opportunity>();
		Map<Id, List<OpportunityLineItem>> itemsToReduce = new Map<Id, List<OpportunityLineItem>>();
		Map<Id, OpportunityLineItem> itemById = new Map<Id, OpportunityLineItem>();
		List<OpportunityLineItem> inventoryProducts;
		for (OpportunityLineItem oldItem : oldItems.values()) {
			opportunityIds.add(oldItem.OpportunityId);
			varieties.add(oldItem.Variedade_de_Produto__c);
			warehouses.add(oldItem.Warehouse__c);
			plants.add(oldItem.Centro_de_despacho__c);
		}
		opps = [
			SELECT Id, Marca__c, Safra__c, Opportunity.RecordType.DeveloperName
			FROM Opportunity
			WHERE
				(Opportunity.RecordType.DeveloperName = 'Sale'
				OR Opportunity.RecordType.DeveloperName = 'Reservation')
				AND StageName != 'Rejected'
				AND Id IN :opportunityIds
		];
		for (Opportunity opp : opps) {
			for (OpportunityLineItem item : oldItems.values()) {
				if (item.OpportunityId == opp.Id) {
					brands.add(opp.Marca__c);
					seasons.add(opp.Safra__c);
					if (!itemsToReduce.containsKey(item.OpportunityId)) {
						itemsToReduce.put(item.OpportunityId, new List<OpportunityLineItem>());
					}
					itemsToReduce.get(item.OpportunityId).add(item);
				}
			}
		}
		inventoryProducts = [
			SELECT
				Id,
				Quantity_by_140k__c,
				Opportunity.Marca__c,
				Opportunity.Safra__c,
				Variedade_de_Produto__c,
				Amount_Sold__c,
				Reservation_Quantity__c,
				Warehouse__c,
				Centro_de_despacho__c
			FROM OpportunityLineItem
			WHERE
				Opportunity.RecordType.DeveloperName = 'Stock_per_Plant'
				AND Opportunity.Safra__c IN :seasons
				AND Opportunity.Marca__c IN :brands
				AND Warehouse__c IN :warehouses
				AND Variedade_de_Produto__c IN :varieties
				AND Centro_de_Despacho__c IN :plants
		];

		for (OpportunityLineItem inventoryProd : inventoryProducts) {
			String invWarehouse = inventoryProd.Warehouse__c;
			String invPlant = inventoryProd.Centro_de_Despacho__c;
			String invVariety = inventoryProd.Variedade_de_Produto__c;
			for (Opportunity opp : opps) {
				String recordTypeOpp = opp.RecordType.DeveloperName;
				if (
					opp.Marca__c == inventoryProd.Opportunity.Marca__c &&
					opp.Safra__c == inventoryProd.Opportunity.Safra__c &&
					itemsToReduce.containsKey(opp.Id) &&
					itemsToReduce.get(opp.Id).size() > 0
				) {
					System.debug(itemsToReduce);
					System.debug(itemsToReduce.get(opp.Id));
					for (OpportunityLineItem itemToReduce : itemsToReduce.get(opp.Id)) {
						System.debug(itemToReduce);
						if (
							itemToReduce.Warehouse__c == invWarehouse &&
							itemToReduce.Centro_de_Despacho__c == invPlant &&
							itemToReduce.Variedade_de_Produto__c == invVariety
						) {
							OpportunityLineItem itemToBeReduced;
							if (itemById.containsKey(inventoryProd.Id)) {
								itemToBeReduced = itemById.get(inventoryProd.Id);
							} else {
								itemToBeReduced = inventoryProd;
								itemById.put(inventoryProd.Id, itemToBeReduced);
							}
							if (itemToBeReduced != null) {
								if (recordTypeOpp == 'Sale') {
									itemToBeReduced.Amount_Sold__c -= itemToReduce.Quantity_by_140k__c;
								} else {
									itemToBeReduced.Reservation_Quantity__c -= itemToReduce.Quantity_by_140k__c;
								}
							}
						}
					}
				}
			}
		}
		if (itemById.size() > 0) {
			update itemById.values();
		}
	}

	private class InventoryProduct {
		private OpportunityLineItem inventoryProduct { get; set; }
		private OpportunityLineItem productAdded { get; set; }
		private Opportunity relatedInventory { get; set; }
		private String saleAccountName { get; set; }
		private String saleId { get; set; }
		private Double quantityToStock = 0;
		private Double quantityToStockBy140k = 0;
		private Double balance { get; set; }

		public InventoryProduct() {
		}

		public InventoryProduct(OpportunityLineItem inventoryProduct, OpportunityLineItem productAdded) {
			this.inventoryProduct = inventoryProduct;
			this.productAdded = productAdded;
		}
	}

	private class ProductWrapper {
		private Map<Id, OpportunityLineItem> stockToUpdate { get; set; }
		private Map<Id, InventoryProduct> stockMissing { get; set; }
		private Map<Id, OpportunityLineItem> oldProducts { get; set; }
		private List<OpportunityLineItem> newProducts { get; set; }
		private Map<String, List<OpportunityLineItem>> inventoryProducts { get; set; }
		private OpportunityLineItem oldProduct { get; set; }
		private OpportunityLineItem newProduct { get; set; }
		private OpportunityLineItem inventoryProduct { get; set; }
		public ProductWrapper() {
			this.stockToUpdate = new Map<Id, OpportunityLineItem>();
			this.stockMissing = new Map<Id, InventoryProduct>();
			this.oldProducts = new Map<Id, OpportunityLineItem>();
			this.newProducts = new List<OpportunityLineItem>();
		}
	}
}