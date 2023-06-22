/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 09-06-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
global class Opp_Utils {
	public static Boolean isUpdate { get; set; }
	public static Boolean isInsert { get; set; }
	public static Boolean isFirstTime = true;
	public static Set<Id> royaltiesCreated = new Set<Id>();
	//@InvocableMethod(label='Complete Royalty Estimation' description='Sum the royalty estimation amount from the SF1 into Credit Limit.')
	public static void CalculateSaleReportEstimation(List<Id> oppIds) {
		for (Id oppId : oppIds)
			calloutEstimate(oppId);
	}

	@future(callout=true)
	public static void calloutEstimate(Id id) {
		//List<Opportunity> opps = aSiteUtils.queryResults1(Opportunity.SObjectType, '','Id = :v1', id);
		//if(opps[0].Royalty_Estimation_Amount__c==0)
		//    return;

		Opportunity opp = [
			SELECT Id, Name, AccountId, Safra__c, Royalty_Estimation_Amount__c
			FROM Opportunity
			WHERE Id = :id
		];
		if (opp.Royalty_Estimation_Amount__c == 0)
			return;

		//List<Credit_Document__c> credits = aSiteUtils.queryResults3(Credit_Document__c.SObjectType, '', 'Account__c = :v1', opps[0].AccountId, 'Season__c = :v2', opps[0].Safra__c, 'Document_type__c = :v3', 'Credit Limit');
		//for(Credit_Document__c c : credits){
		//    c.Royalty_Estimation__c = c.Royalty_Estimation__c == null ? opps[0].Royalty_Estimation_Amount__c : c.Royalty_Estimation__c + opps[0].Royalty_Estimation_Amount__c;
		//}
		//update credits;

		Credit_Document__c cd = [
			SELECT Id, Account__c, Season__c, Royalty_Estimation__c
			FROM Credit_Document__c
			WHERE Document_Type__c = 'Credit Limit' AND Account__c = :opp.AccountId AND Season__c = :opp.Safra__c
		];
		if (cd != null) {
			cd.Royalty_Estimation__c = cd.Royalty_Estimation__c == null
				? opp.Royalty_Estimation_Amount__c
				: cd.Royalty_Estimation__c + opp.Royalty_Estimation_Amount__c;
			update cd;
		}
	}

	public static void cloneReportToSale(List<Id> oppIds, Set<Id> sIds, Map<Id, Opportunity> newOpps) {
		Set<Id> idOpps = new Set<Id>();
		Map<Id, Double> totalBySnap = new Map<Id, Double>();
		Set<String> accountIds = new Set<String>();
		Set<String> brands = new Set<String>();
		Set<String> seasons = new Set<String>();
		Set<String> previousSeasons = new Set<String>();
		Map<Id,List<OpportunityLineItem>> parentSeedItemsByIncentiveContract = new Map<Id,List<OpportunityLineItem>>();
		Set<Id> incentiveContractIds = new Set<Id>();
		for (Id idOpp : newOpps.keySet()) {
			accountIds.add(newOpps.get(idOpp).AccountId);
			seasons.add(newOpps.get(idOpp).Safra__c);
			brands.add(newOpps.get(idOpp).Marca__c);
			if (newOpps.get(idOpp).Incentive_Snapshot__c != null) {
				sIds.add(newOpps.get(idOpp).Incentive_Snapshot__c);
			}
			if (!royaltiesCreated.contains(idOpp)) {
				idOpps.add(idOpp);
				
			}
		}

		for(String season : seasons){
			List<String> splittedSeason = season.split('/');
			Integer firstNumber = Integer.valueOf(splittedSeason[0]) - 1;
			Integer secondNumber = Integer.valueOf(splittedSeason[1]) - 1;
			String prevSeason = '' + firstNumber + '/' + secondNumber;
			previousSeasons.add(prevSeason);
	   }
		//PRICEBOOK AND PBE SETUP
		if (idOpps.size() > 0) {
			for (OpportunityLineItem item : [
				SELECT Id, OpportunityId, Unit_Totals_Value__c, Opportunity.Incentive_Snapshot__c
				FROM OpportunityLineItem
				WHERE OpportunityId IN :oppIds OR Opportunity.Incentive_Snapshot__c IN :sIds
			]) {
				if (
					(newOpps.containsKey(item.OpportunityId) && newOpps.get(item.OpportunityId).Incentive_Snapshot__c != null) ||
					item.Opportunity.Incentive_Snapshot__c != null
				) {
					Id snapId = newOpps.containsKey(item.OpportunityId)
						? newOpps.get(item.OpportunityId).Incentive_Snapshot__c
						: item.Opportunity.Incentive_Snapshot__c;
					// Id snapId = item.Opportunity.Incentive_Snapshot__c == null
					// 	? newOpps.get(item.OpportunityId).Incentive_Snapshot__c
					// 	: item.Opportunity.Incentive_Snapshot__c;
					if (snapId != null) {
						if (!totalBySnap.containsKey(snapId)) {
							totalBySnap.put(snapId, item.Unit_Totals_Value__c);
						} else {
							Double total = totalBySnap.get(snapId) + item.Unit_Totals_Value__c;
							totalBySnap.put(snapId, total);
						}
					}
				}
			}
			Map<String, PricebookEntry> TradePrices = cargarRoyaltyPricebookEntries('TRADEMARK Fee PriceList');
			Pricebook2 tradePb = cargarPricebook('TRADEMARK Fee PriceList');
			Map<String, PricebookEntry> donmarioWholesalePrices = cargarRoyaltyPricebookEntries(
				'DONMARIO - WHOLESALE PriceList'
			);
			Pricebook2 donmarioPb = cargarPricebook('DONMARIO - WHOLESALE PriceList');
			Set<Id> incCodeIds = new Set<Id>();
			Set<Id> snapshotIds = new Set<Id>();
			Set<Id> parentSeedCodeIds = new Set<Id>();
			Map<Id, Incentive_Snapshot_Volume_Detail__c> volumeDetailsToUpdate = new Map<Id, Incentive_Snapshot_Volume_Detail__c>();
			Map<Id, Incentive_Snapshot_Parent_Seed_Detail__c> parentSeedDetailToUpdate = new Map<Id, Incentive_Snapshot_Parent_Seed_Detail__c>();
			//DINAMIC QUERY
			String query = 'SELECT';
			Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe()
				.get('Opportunity')
				.getDescribe()
				.fields.getMap();
			for (String s : objectFields.keySet()) {
				query += ' ' + s + ', ';
			}
			query += 'Account.Name, '; // modify as needed    'Account.Name';

			if (query.subString(query.Length() - 1, query.Length()) == ',') {
				query = query.subString(0, query.Length() - 1);
			}

			query += ' (SELECT Id, Name, UnitPrice, Quantity, Forecast_Quantity__c, Semente_beneficiada__c, Unit_Totals__c,';
			query += ' TotalPrice, PricebookEntry.Product2.Variedade__r.Name,	PricebookEntryId, PricebookEntry.UnitPrice, Product2.Tecnologia__c, Quantity_by_140k__c FROM OpportunityLineItems)';
			query += ' FROM Opportunity';
			query += ' WHERE Id IN :oppIds';

			system.debug(query);

			Map<Id, Opportunity> oMap = new Map<Id, Opportunity>((List<Opportunity>) database.query(query));
			for (Opportunity opp : oMap.values()) {
				if (newOpps.containsKey(opp.Id) && newOpps.get(opp.Id).Incentive_Snapshot__c != null) {
					opp.Incentive_Snapshot__c = newOpps.get(opp.Id).Incentive_Snapshot__c;
					snapshotIds.add(newOpps.get(opp.Id).Incentive_Snapshot__c);
				}
			}

			Map<Id, Incentive_Snapshot__c> snapshotById = new Map<Id, Incentive_Snapshot__c>(
				[
					SELECT
						Id,
						Incentive_Contract__c,
						Incentive_Contract__r.Incentive_Code__c,
						Incentive_Contract__r.Incentive_Parent_Seed_Code__c,
						Unit_Totals__c,
						(
							SELECT Id, CreatedDate, Acomplished__c, Incentive_Contract_Volume_Goal__r.Volume__c, Total_Discount__c
							FROM Incentive_Snapshot_Volume_Details__r
							ORDER BY CreatedDate DESC
						),
						(
							SELECT Id, CreatedDate, Quantities_Acomplished__c,Unique_Varieties_Acomplished__c, Total_Discount__c, Acomplished__c,
							Incentive_Contract_Parent_Seed_Goal__r.Quantities__c, Incentive_Contract_Parent_Seed_Goal__r.Unique_Varieties__c
							FROM Incentive_Snapshot_Parent_Seed_Details__r
							ORDER BY CreatedDate DESC
						),
						(SELECT Id, Discount__c
						FROM Incentive_Snapshot_Activity_Details__r
						ORDER BY CreatedDate DESC
						)
					FROM Incentive_Snapshot__c
					WHERE Id IN :sIds
				]
			);

			for (Incentive_Snapshot__c incSnap : snapshotById.values()) {
				incCodeIds.add(incSnap.Incentive_Contract__r.Incentive_Code__c);
				parentSeedCodeIds.add(incSnap.Incentive_Contract__r.Incentive_Parent_Seed_Code__c);
				if(!parentSeedItemsByIncentiveContract.containsKey(incSnap.Incentive_Contract__c)){
					parentSeedItemsByIncentiveContract.put(incSnap.Incentive_Contract__c, new List<OpportunityLineItem>());
				}
				incentiveContractIds.add(incSnap.Incentive_Contract__c);
			}

			Map<Id, Incentive_Contract__c> icontractMap = new Map<Id,Incentive_Contract__c>(
				[SELECT Id, Account__c, Brand__c, Season__c 
				FROM Incentive_Contract__c 
				WHERE Id IN: incentiveContractIds]
			);

			Map<Id, Incentive_Code__c> icodeMap = new Map<Id, Incentive_Code__c>(
				[
					SELECT
						Id,
						Name,
						(
							SELECT Id, Max_perc__c, Min_perc__c, Trait__c, Discount_Price__c, Min_Price__c, Max_Price__c
							FROM Incentive_Code_Details__r
						)
					FROM Incentive_Code__c
					WHERE Id IN :incCodeIds
				]
			);
			Map<Id,Incentive_Parent_Seed_Code__c> parentSeedMap = new Map<Id,Incentive_Parent_Seed_Code__c>(
				[
					SELECT
						Id,
						Name,
						(
							SELECT Id, Discount__c, Trait__c, Max_Quantities__c, Max_Varieties__c, Min_Quantities__c, Min_Varieties__c
							FROM Incentive_Parent_Seed_Code_Details__r 
						)
					FROM Incentive_Parent_Seed_Code__c
					WHERE Id IN :parentSeedCodeIds
				]
			);

			for(OpportunityLineItem parentSeedItem :  [
				SELECT Variedade_de_Produto__c, Opportunity.AccountId, Opportunity.Safra__c, Opportunity.Marca__c, 
				PricebookEntry.Product2.Variedade__c, Quantity_by_140k__c,Product2.Tecnologia__c, UnitPrice
				FROM OpportunityLineItem
				WHERE Opportunity.Safra__c IN: previousSeasons 
				AND Opportunity.Marca__c =: brands 
				AND Opportunity.AccountId =: accountIds 
				AND Opportunity.StageName = 'Approved'
				AND Opportunity.Type = 'Z2 - PARENT SEED'
			]){
				List<String> splittedSeason = parentSeedItem.Opportunity.Safra__c.split('/');
				Integer firstNumber = Integer.valueOf(splittedSeason[0]) + 1;
				Integer secondNumber = Integer.valueOf(splittedSeason[1]) + 1;
				String actualSeason = '' + firstNumber + '/' + secondNumber;
				String idAccount = parentSeedItem.Opportunity.AccountId;
				String brand = parentSeedItem.Opportunity.Marca__c;
				for(Incentive_Contract__c ic : icontractMap.values()){
					if(ic.Brand__c.contains(brand) && ic.Season__c.contains(actualSeason) && ic.Account__c == idAccount ){
						parentSeedItemsByIncentiveContract.get(ic.Id).add(parentSeedItem);
					}
				}
		}

			List<Opportunity> oppList = new List<Opportunity>();

			List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

			//OPP CREATION ITEARTION
			for (Opportunity opp : oMap.values()) {
				DiscountWrapper volumeDiscount;
				DiscountWrapper parentSeedDiscount;
				Double activityDiscount = 0;
				if (royaltiesCreated.contains(opp.Id)) {
					continue;
				}
				Incentive_Snapshot__c snapshot;
				if (opp.Incentive_Snapshot__c != null) {
					snapshot = snapshotById.get(opp.Incentive_Snapshot__c);
				}

				Double r = Math.random();
				Double x = Math.random();
				system.debug(opp);
				Opportunity newOpp = opp.clone(false, false, false, false);
				newOpp.Anexo_Relacionado__c = opp.id;
				newOpp.Name = 'new clone';

				Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sale').getRecordTypeId();

				newOpp.recordTypeId = devRecordTypeId; //'0122C000000Cote';			
				newOpp.Ship_To__c = newOpp.AccountId;
				newOpp.StageName = 'Editable';

				if (opp.Type == 'Sales Forecast Update 2' && opp.Marca__c == 'DONMARIO') {
					newOpp.Type = 'Z33 - TRADEMARK ROYALTY';
					newOpp.Pricebook2Id = tradePb.Id;
					newOpp.Incoterm_1__c = 'DED - Deliver to ship-to address';
					newOpp.Incoterm_2__c = 'N/A';
				} else if (opp.Type == 'Final Production Report' && opp.Marca__c == 'DONMARIO') {
					newOpp.Type = 'Z16 - TRADEMARK ROYALTY';
					newOpp.Pricebook2Id = donmarioPb.Id;
					newOpp.Incoterm_1__c = 'DED - Deliver to ship-to address';
					newOpp.Incoterm_2__c = 'N/A';
				} else if (opp.Type == 'Final Sales Report') {
					newOpp.Type = 'Z6 - Royalty';
					newOpp.Incoterm_1__c = 'FOB - Free On Board';
					newOpp.Incoterm_2__c = 'N/A';
				}

				newOpp.Condicion_de_Pago__c = 'ZC05 Net 30 days from shipping date';
				newOpp.Tipo__c = 'ZO15 - Local Order';
				newOpp.InsertRef__c = String.valueOf(r).substring(0, 14) + String.valueOf(x).substring(0, 14);

				oppList.add(newOpp);

				//CREATE OPP PRODUCTS
				if(snapshot != null){
					volumeDiscount = calculateVolumeDiscount(opp.OpportunityLineItems, snapshot, icodeMap);
					parentSeedDiscount = calculateParentSeedDiscounts(opp.OpportunityLineItems, parentSeedItemsByIncentiveContract.get(snapshot.Incentive_Contract__c), snapshot, parentSeedMap);
					if(snapshot.Incentive_Snapshot_Activity_Details__r.size() > 0 && snapshot.Incentive_Snapshot_Activity_Details__r[0].Discount__c != null){
						activityDiscount = snapshot.Incentive_Snapshot_Activity_Details__r[0].Discount__c;
					}
				}

				for (OpportunityLineItem prod : opp.OpportunityLineItems) {
					Boolean ableToInsert = false;
					PricebookEntry pbe = new PricebookEntry();
					OpportunityLineItem newProd = new OpportunityLineItem();

					if (opp.Type == 'Sales Forecast Update 2' && opp.Marca__c == 'DONMARIO') {
						pbe = TradePrices.get(prod.PricebookEntry.Product2.Variedade__r.Name);
						newProd.PricebookEntryId = pbe.Id;
						if (prod.Forecast_Quantity__c > 0) {
							newProd.Quantity = prod.Forecast_Quantity__c;
							ableToInsert = true;
							newProd.TotalPrice = null;
							newProd.UnitPrice = pbe.UnitPrice;
						}
					} else if (
						opp.Type == 'Final Production Report' &&
						opp.Marca__c == 'DONMARIO' &&
						donmarioWholesalePrices.containsKey(prod.PricebookEntry.Product2.Variedade__r.Name)
					) {
						pbe = donmarioWholesalePrices.get(prod.PricebookEntry.Product2.Variedade__r.Name);
						newProd.PricebookEntryId = pbe.Id;
						if (prod.Semente_beneficiada__c > 0) {
							ableToInsert = true;
							newProd.Quantity = prod.Semente_Beneficiada__c;
							newProd.TotalPrice = null;
							newProd.UnitPrice = pbe.UnitPrice;
						}
					} else if (opp.Type == 'Final Sales Report') {
						newProd = prod.clone(false, false, false, false);
						if (prod.Unit_Totals__c > 0) {
							Double totalDiscount = 0;
							ableToInsert = true;
							if (snapshot != null && (volumeDiscount.discountAchieved > 0 || parentSeedDiscount.discountAchieved > 0) ){
								DiscountWrapper discountSelected = new DiscountWrapper();
								discountSelected = volumeDiscount.totalPrice >= parentSeedDiscount.totalPrice ? volumeDiscount : parentSeedDiscount;
								if(volumeDiscount.volumeDetails.size() > 0 && volumeDiscount.volumeDetails.containsKey(snapshot.Incentive_Snapshot_Volume_Details__r[0].Id)){
									Incentive_Snapshot_Volume_Detail__c snapVolumeDetailUpdate = volumeDiscount.volumeDetails.get(snapshot.Incentive_Snapshot_Volume_Details__r[0].Id);
									volumeDetailsToUpdate.put(
										snapVolumeDetailUpdate.Id,
										snapVolumeDetailUpdate
									);
								}
								if(parentSeedDiscount.parentSeedDetails.size() > 0 && parentSeedDiscount.parentSeedDetails.containsKey(snapshot.Incentive_Snapshot_Parent_Seed_Details__r[0].Id)){
									Incentive_Snapshot_Parent_Seed_Detail__c snapParentSeedDetail = parentSeedDiscount.parentSeedDetails.get(snapshot.Incentive_Snapshot_Parent_Seed_Details__r[0].Id);
									parentSeedDetailToUpdate.put(
										snapParentSeedDetail.Id,
										snapParentSeedDetail
									);
								}
								Decimal finalDiscount = discountSelected.discountByItem.containsKey(prod.Id) ? 
								discountSelected.discountByItem.get(prod.Id) :
								0;
								newProd.Royalty_discount_achieved__c = prod.UnitPrice - finalDiscount - activityDiscount;
							} else {
								newProd.UnitPrice = prod.UnitPrice;
								newProd.Royalty_discount_achieved__c = prod.UnitPrice - activityDiscount;
							}
							newProd.Quantity = prod.Unit_Totals__c;
							newProd.TotalPrice = null;
						}
					}

					newProd.Centro_de_Despacho__c = 'U001 - GDM-CHAMPAIGN'; //'UD05 - GDM-MARION';
					newProd.InsertRef__c = newOpp.InsertRef__c;
					royaltiesCreated.add(opp.Id);

					if (ableToInsert == true) {
						oliList.add(newProd);
					}
				}
			}
			if (oppList.size() > 0) {
				Database.insert(oppList);
				// royaltiesCreated.add() = true;

				for (OpportunityLineItem oli : oliList) {
					for (Opportunity o : oppList) {
						if (o.InsertRef__c == oli.InsertRef__c) {
							oli.OpportunityId = o.Id;
							oli.TotalPrice = null;
						}
					}
				}

				if (oliList.size() > 0) {
					Database.insert(oliList);
				}
			}
			if (volumeDetailsToUpdate.size() > 0) {
				update volumeDetailsToUpdate.values();
			}
			if(parentSeedDetailToUpdate.size() > 0){
				update parentSeedDetailToUpdate.values();
			}
		}
	}

	//PB UTILS - In the future query the PBE in cargaPricebookQuery
	public static Pricebook2 cargarPricebook(String lp_name) {
		Pricebook2 rPb = new Pricebook2();

		for (Pricebook2 p : [SELECT Id, Name FROM Pricebook2 WHERE Name = :lp_name]) {
			rPb = p;
		}

		return rPb;
	}

	public static Map<String, PricebookEntry> cargarRoyaltyPricebookEntries(String lp_name) {
		Map<String, PricebookEntry> rPb = new Map<String, PricebookEntry>();

		for (PricebookEntry p : [
			SELECT Id, Product2.Licensee_Variety_Id__c, UnitPrice, Pricebook2Id, Product2.Variedade__r.Name, Name
			FROM PricebookEntry
			WHERE Product2.Family = 'Royalty' AND Pricebook2.Name = :lp_name AND isActive = TRUE
		]) {
			rPb.put(p.Product2.Variedade__r.Name, p);
		}

		return rPb;
	}

	public static Map<String, PricebookEntry> cargar140kSeedPricebookEntries(String lp_name) {
		Map<String, PricebookEntry> rPb = new Map<String, PricebookEntry>();

		for (PricebookEntry p : [
			SELECT Id, Product2.Licensee_Variety_Id__c, UnitPrice, Pricebook2Id, Product2.Variedade__r.Name, Name
			FROM PricebookEntry
			WHERE
				Product2.Family = 'Seed'
				AND Product2.UNIDADE__c = 'BAG 140K'
				AND Pricebook2.Name = :lp_name
				AND isActive = TRUE
		]) {
			rPb.put(p.Product2.Variedade__r.Name, p);
		}

		return rPb;
	}

	//USED IN OTHER CLASES
	public static Map<String, Id> cargarRecordTypesOportunidades() {
		Map<String, Id> rTypes = new Map<String, Id>();
		Schema.Describesobjectresult d = Opportunity.sObjectType.getDescribe();
		Map<String, Schema.Recordtypeinfo> rt = d.getRecordTypeInfosByName();

		for (String s : rt.keySet()) {
			rTypes.put(s, rt.get(s).getRecordTypeId());
		}

		return rTypes;
	}

	public static void setSeedTracks(List<Id> oppIds) {
		List<Opportunity> opps = [
			SELECT
				Id,
				StageName,
				AccountId,
				Ship_To__c,
				Ship_To__r.Name,
				Type,
				Ship_To__r.BillingCity,
				Ship_To__r.BillingStreet,
				Ship_To__r.BillingState,
				Contact_of_Shipping__r.Name,
				Ship_To__r.BillingPostalCode,
				OwnerId,
				Contact_of_Shipping__r.Phone,
				Marca__c,
				Safra__c,
				Pricebook2Id,
				(
					SELECT
						Id,
						Quantity,
						Product2.Variedade__c,
						Product2.Variedade__r.Name,
						Product2.Variedade__r.GID__c,
						Quantity_by_140k__c,
						Product2.UNIDADE__c,
						Centro_de_despacho__c,
						Product2Id
					FROM OpportunityLineItems
				)
			FROM Opportunity
			WHERE Id IN :oppIds
		];

		List<String> brands = new List<String>();
		List<String> seasons = new List<String>();

		for (Opportunity opp : opps) {
			brands.add(opp.Marca__c);
			seasons.add(opp.Safra__c);
		}

		List<Seed_Tracking__c> seedTracks = [
			SELECT
				Id,
				Sale_Order__c,
				Variety__c,
				Product__c,
				Sale_Order__r.Marca__c,
				Sale_Order__r.Safra__c,
				Sale_Order__r.Pricebook2Id,
				Sale_Order__r.Type,
				Warehouse__c
			FROM Seed_Tracking__c
			WHERE Sale_Order__c IN :oppIds
		];

		List<OpportunityLineItem> stockItems = [
			SELECT
				Id,
				Product2.Variedade__c,
				Product2.Variedade__r.Name,
				Customer_ETA__c,
				Customer_Status__c,
				Inventory_Status__c,
				Opportunity.Marca__c,
				Opportunity.Safra__c,
				Centro_de_despacho__c,
				Product2Id,
				Opportunity.Pricebook2Id,
				Opportunity.Seed_Type__c
			FROM OpportunityLineItem
			WHERE
				Opportunity.RecordType.Name = 'Stock per plant'
				AND Opportunity.Marca__c IN :brands
				AND Opportunity.Safra__c IN :seasons
		];

		Map<String, OpportunityLineItem> stockByVariety = new Map<String, OpportunityLineItem>();
		for (OpportunityLineItem stockItem : stockItems) {
			stockByVariety.put(
				stockItem.Product2.Variedade__c +
				stockItem.Centro_de_despacho__c +
				stockItem.Product2Id +
				stockItem.Opportunity.Marca__c +
				stockItem.Opportunity.Safra__c +
				stockItem.Opportunity.Pricebook2Id +
				stockItem.Opportunity.Seed_Type__c,
				stockItem
			);
		}

		System.debug(stockByVariety);

		Map<Id, List<Seed_Tracking__c>> tracksByOpportunityId = new Map<Id, List<Seed_Tracking__c>>();
		List<Seed_Tracking__c> auxTrack;

		for (Seed_Tracking__c track : seedTracks) {
			if (tracksByOpportunityId.containskey(track.Sale_Order__c)) {
				auxTrack = tracksByOpportunityId.get(track.Sale_Order__c);
				auxTrack.add(track);
				tracksByOpportunityId.put(track.Sale_Order__c, auxTrack);
			} else {
				auxTrack = new List<Seed_Tracking__c>();
				auxTrack.add(track);
				tracksByOpportunityId.put(track.Sale_Order__c, auxTrack);
			}
		}

		List<Seed_Tracking__c> seedTracksToUpsert = new List<Seed_Tracking__c>();
		Map<String, List<OpportunityLineItem>> itemsByProd;

		for (Opportunity opp : opps) {
			System.debug(opp.StageName);
			if (opp.StageName == 'Approved') {
				List<Seed_Tracking__c> existingTrackList = tracksByOpportunityId.get(opp.Id);

				if (existingTrackList == null) {
					existingTrackList = new List<Seed_Tracking__c>();
				}

				Map<String, Seed_Tracking__c> existingTrackMap = new Map<String, Seed_Tracking__c>();

				for (Seed_Tracking__c est : existingTrackList) {
					String seedType;
					if (est.Sale_Order__r.Type == 'Z3 - TEST SEED') {
						seedType = 'Test Seed';
					} else if (est.Sale_Order__r.Type == 'Z2 - PARENT SEED') {
						seedType = 'Parent Seed';
					} else if (est.Sale_Order__r.Type == 'Z4 - WHOLESALE SEED') {
						seedType = 'Wholesale Seed';
					}

					if (
						!existingTrackMap.containsKey(
							est.Variety__c +
							est.Warehouse__c +
							est.Product__c +
							est.Sale_Order__r.Marca__c +
							est.Sale_Order__r.Safra__c +
							est.Sale_Order__r.Pricebook2Id +
							seedType
						)
					) {
						existingTrackMap.put(
							est.Variety__c +
							est.Warehouse__c +
							est.Product__c +
							est.Sale_Order__r.Marca__c +
							est.Sale_Order__r.Safra__c +
							est.Sale_Order__r.Pricebook2Id +
							seedType,
							est
						);
					}
				}

				isFirstTime = false;
				itemsByProd = new Map<String, List<OpportunityLineItem>>();
				List<OpportunityLineItem> auxItems;

				for (OpportunityLineItem item : opp.OpportunityLineItems) {
					if (itemsByProd.containsKey(item.Product2.Variedade__c + item.Centro_de_despacho__c + item.Product2Id)) {
						auxItems = itemsByProd.get(item.Product2.Variedade__c + item.Centro_de_despacho__c + item.Product2Id);
						auxItems.add(item);
						itemsByProd.put(item.Product2.Variedade__c + item.Centro_de_despacho__c + item.Product2Id, auxItems);
					} else {
						auxItems = new List<OpportunityLineItem>();
						auxItems.add(item);
						itemsByProd.put(item.Product2.Variedade__c + item.Centro_de_despacho__c + item.Product2Id, auxItems);
					}
				}

				String seedType;

				if (opp.Type != null && opp.Type != '') {
					if (opp.Type.contains('PARENT SEED')) {
						seedType = 'Parent Seed';
					} else if (opp.Type.contains('TEST SEED')) {
						seedType = 'Test Seed';
					} else if (opp.Type.contains('WHOLESALE SEED')) {
						seedType = 'Wholesale Seed';
					}
				}
				for (String key : itemsByProd.keySet()) {
					Seed_Tracking__c newTrack = new Seed_Tracking__c();
					if (existingTrackMap.containsKey(key + opp.Marca__c + opp.Safra__c + opp.Pricebook2Id + seedType)) {
						newTrack = existingTrackMap.get(key + opp.Marca__c + opp.Safra__c + opp.Pricebook2Id + seedType);
					}

					newTrack.Active__c = true;
					newTrack.Account__c = opp.AccountId;

					if (opp.Type != null && opp.Type != '') {
						if (seedType == 'Parent Seed') {
							newTrack.Type__c = 'PARENT SEED';
						} else if (seedType == 'Test Seed') {
							newTrack.Type__c = 'TEST SEED';
						} else if (seedType == 'Wholesale Seed') {
							newTrack.Type__c = 'WHOLESALE SEED';
						}
					}

					newTrack.Ship_To__c = opp.Ship_To__r.Name;
					newTrack.Ship_To_City__c = opp.Ship_To__r.BillingCity;
					newTrack.Ship_To_Street__c = opp.Ship_To__r.BillingStreet;
					newTrack.State__c = opp.Ship_To__r.BillingState;
					newTrack.Zip__c = opp.Ship_To__r.BillingPostalCode;
					newTrack.Sale_Order__c = opp.Id;
					newTrack.OwnerId = opp.OwnerId;
					newTrack.Avion_Barco__c = 'Boat';
					newTrack.Contact__c = opp.Contact_of_Shipping__r.Name;
					newTrack.Phone_Number__c = opp.Contact_of_Shipping__r.Phone;

					List<OpportunityLineItem> varItems = itemsByProd.get(key);

					newTrack.GID__c = varItems[0].Product2.Variedade__r.GID__c;
					newTrack.Brand__c = varItems[0].Product2.Variedade__r.Name;
					newTrack.Variety__c = varItems[0].Product2.Variedade__c;
					newTrack.Unit_Type__c = varItems[0].Product2.UNIDADE__c;
					newTrack.product__c = varItems[0].Product2Id;
					newTrack.Opportunity_Product__c = varItems[0].Id;
					newTrack.Quantity__c = 0;
					newTrack.Quantity_by_140k__c = 0;

					for (OpportunityLineItem item : varItems) {
						if (item.Quantity != null) {
							newTrack.Quantity__c += item.Quantity;
						}
						if (item.Quantity_by_140k__c != null) {
							newTrack.Quantity_by_140k__c += item.Quantity_by_140k__c;
						}
						if (item.Centro_de_despacho__c != null) {
							newTrack.Warehouse__c = item.Centro_de_despacho__c;
						}
					}

					if (newTrack.Quantity_by_140k__c == 0) {
						newTrack.Active__c = false;
					}

					if (stockByVariety.containsKey(key + opp.Marca__c + opp.Safra__c + opp.Pricebook2Id + seedType)) {
						OpportunityLineItem stockItem = stockByVariety.get(
							key +
							opp.Marca__c +
							opp.Safra__c +
							opp.Pricebook2Id +
							seedType
						);
						if (stockItem.Inventory_Status__c == 'Approved') {
							newTrack.ETA_Customer__c = stockItem.Customer_ETA__c;
							newTrack.Status__c = stockItem.Customer_Status__c;
						}
					}
					seedTracksToUpsert.add(newTrack);
				}
			} else {
				if (tracksByOpportunityId.containsKey(opp.Id)) {
					for (Seed_Tracking__c existingTrack : tracksByOpportunityId.get(opp.Id)) {
						existingTrack.Active__c = false;
						seedTracksToUpsert.add(existingTrack);
					}
				}
			}
		}
		upsert seedTracksToUpsert;
	}

	public static Set<Id> generateIncentiveContractSnapshot(Set<Id> oIds, Map<Id, Opportunity> newOpps) {
		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		Map<Id, Incentive_Snapshot__c> snapshotsToUpdate = new Map<Id, Incentive_Snapshot__c>();
		List<Incentive_Snapshot__c> sList = new List<Incentive_Snapshot__c>();
		List<Incentive_Snapshot__c> existingIncentiveSnap = new List<Incentive_Snapshot__c>();
		Map<String, Incentive_Snapshot__c> incentiveSnapByAccountAndSeason = new Map<String, Incentive_Snapshot__c>();
		List<Incentive_Snapshot_Activity_Detail__c> saList = new List<Incentive_Snapshot_Activity_Detail__c>();
		List<Incentive_Snapshot_Volume_Detail__c> svList = new List<Incentive_Snapshot_Volume_Detail__c>();
		List<Incentive_Snapshot_Parent_Seed_Detail__c> spList = new List<Incentive_Snapshot_Parent_Seed_Detail__c>(); 
		Map<Id, Incentive_Contract__c> icontractMap = new Map<Id, Incentive_Contract__c>();
		Map<Id, Incentive_Snapshot_Volume_Detail__c> volumeDetailSnapsToUpdate = new Map<Id, Incentive_Snapshot_Volume_Detail__c>();
		Map<Opportunity, Incentive_Snapshot__c> snapshotByOpportunity = new Map<Opportunity, Incentive_Snapshot__c>();
		// Map<Id,Incentive_Contract_Parent_Seed_Goal__c> parentSeedDiscByIncentiveContractId = new Map<Id,Incentive_Contract_Parent_Seed_Goal__c>();
		Map<Id, List<OpportunityLineItem>> parentSeedItemsByIncentiveContract = new Map<Id, List<OpportunityLineItem>>();
		Map<Id,Incentive_Snapshot_Parent_Seed_Detail__c> parentSeedDetailSnapsToUpdate = new Map<Id,Incentive_Snapshot_Parent_Seed_Detail__c>();
		//Incentive Contract Map with opp data and opportunity data
		Set<String> seasons = new Set<String>();
		List<String> brands = new List<String>();
		Set<Id> accountIds = new Set<Id>();
		Set<Id> icodeIds = new Set<Id>();
		Set<Id> iACodeIds = new Set<Id>();
		List<SObject> insertList = new List<SObject>();
		Set<String> previousSeasons = new Set<String>();
		Map<Id, Opportunity> oMap = new Map<Id, Opportunity>(
			[
				SELECT
					Id,
					AccountId,
					Safra__c,
					Company__c,
					Marca__c,
					LastModifiedDate,
					HasOpportunityLineItem,
					Incentive_Snapshot__c,
					(
						SELECT Id, Unit_Totals__c, PricebookEntry.Product2.Tecnologia__c, PricebookEntry.Product2.Variety_Brand__c
						FROM OpportunityLineItems
					)
				FROM Opportunity
				WHERE Id IN :oIds
			]
		);

		for (Opportunity o : oMap.values()) {
			System.debug(o.Safra__c);
			seasons.add(o.Safra__c);
			if (!brands.contains(o.Marca__c)) {
				brands.add(o.Marca__c);
			}
			accountIds.add(o.AccountId);
		}
		for(String season : seasons){
  			List<String> splittedSeason = season.split('/');
  			Integer firstNumber = Integer.valueOf(splittedSeason[0]) - 1;
			Integer secondNumber = Integer.valueOf(splittedSeason[1]) - 1;
			String prevSeason = '' + firstNumber + '/' + secondNumber;
			previousSeasons.add(prevSeason);
 		}
		String brandsParameter = '(\'' + String.join(brands, '\',\'') + '\')';
		String query = 'SELECT Id, Account__c, Brand__c, Season__c, Incentive_Code__c, Name, Incentive_Activity_Code__c, Incentive_Parent_Seed_Code__c, ';
		query += '(SELECT Id, Name, Volume__c, Season__c FROM Incentive_Contract_Volume_Goals__r), ';
		query += '(SELECT Id, Name, Activities_Done__c FROM Incentive_Contract_Activity_Goals__r), ';
		query += '(SELECT Id, Name, Season__c, Quantities__c, Unique_Varieties__c FROM Incentive_Contract_Parent_Seed_Goals__r) ';
		query += 'FROM Incentive_Contract__c ';
		query += 'WHERE Brand__c INCLUDES ' + brandsParameter + ' AND Season__c IN :seasons AND Account__c IN :accountIds';

		List<Incentive_Contract__c> iContractList = Database.query(query);
		for (Incentive_Contract__c ic : iContractList) {
			icontractMap.put(ic.Id, ic);
		}

		query = 'SELECT Id, Account__c, Brand__c, Season__c, Unit_Totals__c, Incentive_Contract__c, Parent_Seed_Totals__c, Unique_Varieties_Totals__c, ';
		query += '(SELECT Id, CreatedDate, Acomplished__c, Incentive_Contract_Volume_Goal__c  FROM Incentive_Snapshot_Volume_Details__r), ';
		query += '(SELECT Id FROM Incentive_Snapshot_Activity_Details__r), ';
		query += '(SELECT Id, CreatedDate, Total_Discount__c, Quantities_Acomplished__c, Unique_Varieties_Acomplished__c, Incentive_Contract_Parent_Seed_Goal__c FROM Incentive_Snapshot_Parent_Seed_Details__r) ';
		query += 'FROM Incentive_Snapshot__c ';
		query += 'WHERE Account__c in :accountIds AND Season__c IN :seasons AND Brand__c INCLUDES ' + brandsParameter;
		existingIncentiveSnap = Database.query(query);
		for (Incentive_Snapshot__c incentiveSnap : existingIncentiveSnap) {
			String key = incentiveSnap.Account__c + incentiveSnap.Season__c;
			if (!incentiveSnapByAccountAndSeason.containsKey(key)) {
				incentiveSnapByAccountAndSeason.put(key, incentiveSnap);
			}
		}

		for (Incentive_Contract__c ic : icontractMap.values()) {
			icodeIds.add(ic.Incentive_Code__c);
			iACodeIds.add(ic.Incentive_Activity_Code__c);
			if(!parentSeedItemsByIncentiveContract.containsKey(ic.Id)){
				parentSeedItemsByIncentiveContract.put(ic.Id, new List<OpportunityLineItem>());
			}
		}

		Map<Id, Incentive_Code__c> icodeMap = new Map<Id, Incentive_Code__c>(
			[
				SELECT
					Id,
					Name,
					(SELECT Id, Max_perc__c, Min_perc__c, Trait__c, Discount_Price__c FROM Incentive_Code_Details__r)
				FROM Incentive_Code__c
				WHERE Id IN :icodeIds
			]
		);

		Map<Id, Incentive_Activity_Code__c> iACodeMap = new Map<Id, Incentive_Activity_Code__c>(
			[
				SELECT
					Id,
					Name,
					(
						SELECT Id, Discount_Amount__c, isLastDiscount__c, Activities_Needed__c
						FROM Incentive_Activity_Code_Details__r
					)
				FROM Incentive_Activity_Code__c
				WHERE Id IN :iACodeIds
			]
		);


		for(OpportunityLineItem parentSeedItem :  [
			SELECT Variedade_de_Produto__c, Opportunity.AccountId, Opportunity.Safra__c, Opportunity.Marca__c, PricebookEntry.Product2.Variedade__c, Quantity_by_140k__c
			FROM OpportunityLineItem
			WHERE Opportunity.Safra__c IN: previousSeasons 
			AND Opportunity.Marca__c =: brands 
			AND Opportunity.AccountId =: accountIds 
			AND Opportunity.StageName = 'Approved'
			AND Opportunity.Type = 'Z2 - PARENT SEED'
      	]){
			List<String> splittedSeason = parentSeedItem.Opportunity.Safra__c.split('/');
  			Integer firstNumber = Integer.valueOf(splittedSeason[0]) + 1;
			Integer secondNumber = Integer.valueOf(splittedSeason[1]) + 1;
			String actualSeason = '' + firstNumber + '/' + secondNumber;
			String idAccount = parentSeedItem.Opportunity.AccountId;
			String brand = parentSeedItem.Opportunity.Marca__c;
			for(Incentive_Contract__c ic : icontractMap.values()){
				if(ic.Brand__c.contains(brand) && ic.Season__c.contains(actualSeason) && ic.Account__c == idAccount ){
					parentSeedItemsByIncentiveContract.get(ic.Id).add(parentSeedItem);
				}
			}
		} 



		for (Opportunity o : oMap.values()) {
			String incentiveSnapKey = o.AccountId + o.Safra__c;
			Double r = Math.random();
			Boolean noContract = false;
			Incentive_Snapshot__c snap;
			Incentive_Contract__c incentiveContract = new Incentive_Contract__c();
			Incentive_Code__c iCode = new Incentive_Code__c();
			// Incentive_Contract_Parent_Seed_Goal__c incentiveParentSeed = new Incentive_Contract_Parent_Seed_Goal__c(); 

			for (Incentive_Contract__c iContract : icontractMap.values()) {
				noContract = false;
				if (
					iContract.Season__c.contains(o.Safra__c) &&
					iContract.Brand__c.contains(o.Marca__c) &&
					iContract.Account__c == o.AccountId
				) {
					incentiveContract = iContract;
					iCode = icodeMap.get(iContract.Incentive_Code__c);
					break;
				} else {
					noContract = true;
				}
			}

			if (noContract == true) {
				continue;
			}
			if (
				incentiveSnapByAccountAndSeason.containsKey(incentiveSnapKey) &&
				incentiveSnapByAccountAndSeason.get(incentiveSnapKey).Brand__c.contains(o.Marca__c) &&
				incentiveSnapByAccountAndSeason.get(incentiveSnapKey).Incentive_Contract__c == incentiveContract.Id
			) {
				snap = incentiveSnapByAccountAndSeason.get(incentiveSnapKey);

				// Incentive_Snapshot_Activity_Detail__c activityDetail = snap.Incentive_Snapshot_Activity_Details__r[0];
				if(newOpps.get(o.Id).Incentive_Procesed__c  == false){
					Decimal totalQuantity;
					for (Incentive_Snapshot_Volume_Detail__c volumeDetailSnap : snap.Incentive_Snapshot_Volume_Details__r) {
						totalQuantity = 0;
						for (Incentive_Contract_Volume_Goal__c volumeGoal : incentiveContract.Incentive_Contract_Volume_Goals__r) {
							if (volumeGoal.Id == volumeDetailSnap.Incentive_Contract_Volume_Goal__c) {
								if (snap.Brand__c.split(';').size() > 1) {
									totalQuantity = snap.Unit_Totals__c;
								}
								for (OpportunityLineItem oli : o.OpportunityLineItems) {
									if (o.Safra__c == volumeGoal.Season__c) {
										totalQuantity += oli.Unit_Totals__c;
									}
									volumeDetailSnap.Acomplished__c = (totalQuantity / volumeGoal.Volume__c) * 100;
								}
								volumeDetailSnapsToUpdate.put(volumeDetailSnap.Id, volumeDetailSnap);
							}
							if (!snapshotByOpportunity.containsKey(o)) {
								snapshotByOpportunity.put(o, snap);
							}
						}
						newOpps.get(o.Id).Incentive_Procesed__c = true;
					}
					if (snap.Unit_Totals__c != totalQuantity) {
						snap.Unit_Totals__c = totalQuantity;
						snapshotsToUpdate.put(snap.Id, snap);
					}
					Integer uniqueVarieties = 0;
					Decimal quantities = 0;
					for(Incentive_Snapshot_Parent_Seed_Detail__c parentSeedDetail : snap.Incentive_Snapshot_Parent_Seed_Details__r){
						for(Incentive_Contract_Parent_Seed_Goal__c parentSeedGoal : incentiveContract.Incentive_Contract_Parent_Seed_Goals__r){
							if(parentSeedGoal.Id == parentSeedDetail.Incentive_Contract_Parent_Seed_Goal__c){
								Set<String> varieties = new Set<String>();
								for(OpportunityLineItem psItem : parentSeedItemsByIncentiveContract.get(incentiveContract.Id)){
									if(!varieties.contains(psItem.Variedade_de_Produto__c)){
										varieties.add(psItem.Variedade_de_Produto__c);
										uniqueVarieties++;
									}
									quantities += psItem.Quantity_by_140k__c;
								}
								parentSeedDetail.Unique_Varieties_Acomplished__c = (uniqueVarieties / parentSeedGoal.Unique_Varieties__c) * 100;
								parentSeedDetail.Quantities_Acomplished__c = (quantities / parentSeedGoal.Quantities__c) * 100;
								parentSeedDetailSnapsToUpdate.put(parentSeedDetail.Id, parentSeedDetail);
							}
						}
					}
					if(snap.Unique_Varieties_Totals__c != uniqueVarieties || snap.Parent_Seed_Totals__c != quantities){
						if(snap.Unique_Varieties_Totals__c != uniqueVarieties){
							snap.Unique_Varieties_Totals__c = uniqueVarieties;
						}
						if(snap.Parent_Seed_Totals__c != quantities){
							snap.Parent_Seed_Totals__c = quantities;
						}
						snapshotsToUpdate.put(snap.Id,snap);
					}
					
				}
				
			} else {
				snap = new Incentive_Snapshot__c();
				snap.Name = incentiveContract.Name + ' ' + o.LastModifiedDate + ' Snapshot';
				snap.Incentive_Contract__c = incentiveContract.Id;
				snap.Unit_Totals__c = 0;
				// snap.Opportunity__c = o.Id;
				snap.InsertRef__c = String.valueOf(r).substring(0, 12);
				snap.Account__c = o.AccountId;
                snap.Season__c = o.Safra__c;
                snap.Brand__c = incentiveContract.Brand__c;
				String brandsStr = '';
				if(incentiveContract.Brand__c.contains(';')){
					List<String> splitedBrands = incentiveContract.Brand__c.split(';');
					for (Integer i = 0; i < splitedBrands.size(); i++) {
						if (splitedBrands.size() > 0 && i < splitedBrands.size() - 1) {
							brandsStr += splitedBrands[i] + '|';
						}
					}					
				} else {
					brandsStr = incentiveContract.Brand__c;
				}
				Incentive_Snapshot_Activity_Detail__c snapA = new Incentive_Snapshot_Activity_Detail__c();

				if (incentiveContract.Incentive_Contract_Activity_Goals__r.size() > 0) {
					snapA.Name = incentiveContract.Name + ' Activity Snapshot';
					snapA.Incentive_Snapshot__r = new Incentive_Snapshot__c(InsertRef__c = String.valueOf(r).substring(0, 12));
					snapA.Incentive_Contract_Activity_Goal__c = incentiveContract.Incentive_Contract_Activity_Goals__r[0].Id;
					snapA.Activities_Done__c = incentiveContract.Incentive_Contract_Activity_Goals__r[0].Activities_Done__c;
					snapA.Discount__c = 0;
					if (
						iACodeMap.containsKey(incentiveContract.Incentive_Activity_Code__c) &&
						iACodeMap.get(incentiveContract.Incentive_Activity_Code__c).Incentive_Activity_Code_Details__r.size() > 0
					) {
						for (
							Incentive_Activity_Code_Detail__c iac : iACodeMap.get(incentiveContract.Incentive_Activity_Code__c)
								.Incentive_Activity_Code_Details__r
						) {
							if (iac.Activities_needed__c == snapA.Activities_Done__c) {
								snapA.Discount__c = iac.Discount_Amount__c;
							} else if (snapA.Activities_Done__c > iac.Activities_needed__c && iac.isLastDiscount__c) {
								snapA.Discount__c = iac.Discount_Amount__c;
							}
						}
					}
					saList.add(snapA);
				}

				for (Incentive_Contract_Volume_Goal__c vg : incentiveContract.Incentive_Contract_Volume_Goals__r) {
					System.debug(vg);

					Incentive_Snapshot_Volume_Detail__c vd = new Incentive_Snapshot_Volume_Detail__c();
					
					vd.Name = incentiveContract.Name + ' ' + brandsStr + ' ' + vg.Season__c + ' Volume Snapshot';
					vd.Incentive_Snapshot__r = new Incentive_Snapshot__c(InsertRef__c = String.valueOf(r).substring(0, 12));
					vd.Incentive_Contract_Volume_Goal__c = vg.Id;
					Decimal totalQuantity = 0;

					System.debug(o.HasOpportunityLineItem);
					System.debug(o.OpportunityLineItems.size());

					for (OpportunityLineItem oli : o.OpportunityLineItems) {
						System.debug(oli);

						if (o.Safra__c == vg.Season__c) {
							totalQuantity += oli.Unit_Totals__c;
						}
					}

					vd.Acomplished__c = (totalQuantity / vg.Volume__c) * 100;
					vd.Total_Discount__c = 0;
					snap.Unit_Totals__c += totalQuantity;

					svList.add(vd);
					
				}

				for(Incentive_Contract_Parent_Seed_Goal__c parentSeedGoal : incentiveContract.Incentive_Contract_Parent_Seed_Goals__r){
					Incentive_Snapshot_Parent_Seed_Detail__c parentSeedDetail = new Incentive_Snapshot_Parent_Seed_Detail__c();
					parentSeedDetail.Name = incentiveContract.Name + ' ' + brandsStr + ' ' + parentSeedGoal.Season__c + ' Parent Seed Snapshot';
					parentSeedDetail.Incentive_Snapshot__r = new Incentive_Snapshot__c(InsertRef__c = String.valueOf(r).substring(0, 12));
					parentSeedDetail.Incentive_Contract_Parent_Seed_Goal__c = parentSeedGoal.Id;
						
					Integer uniqueVarieties = 0;
					Decimal quantities = 0;
					Set<String> varieties = new Set<String>();
					for(OpportunityLineItem psItem : parentSeedItemsByIncentiveContract.get(incentiveContract.Id)){
						if(!varieties.contains(psItem.Variedade_de_Produto__c)){
							varieties.add(psItem.Variedade_de_Produto__c);
							uniqueVarieties++;
						}
						quantities += psItem.Quantity_by_140k__c;
					}
					parentSeedDetail.Unique_Varieties_Acomplished__c = (uniqueVarieties / parentSeedGoal.Unique_Varieties__c) * 100;
					parentSeedDetail.Quantities_Acomplished__c = (quantities / parentSeedGoal.Quantities__c) * 100;
					parentSeedDetail.Total_Discount__c = 0;
					spList.add(parentSeedDetail);		
					snap.Unique_Varieties_Totals__c = uniqueVarieties;				
					snap.Parent_Seed_Totals__c = quantities;				
				}


				sList.add(snap);
				if (snap != null) {
					snapshotByOpportunity.put(o, snap);
				}
				if (!incentiveSnapByAccountAndSeason.containsKey(incentiveSnapKey)) {
					incentiveSnapByAccountAndSeason.put(incentiveSnapKey, snap);
				}
			}
			newOpps.get(o.Id).Incentive_Procesed__c = true;
		}

		insertList.addAll(sList);
		insertList.addAll(saList);
		insertList.addAll(svList);
		insertList.addAll(spList);
		if (insertList.size() > 0) {
			Database.insert(insertList);
		}
		if (snapshotsToUpdate.size() > 0) {
			update snapshotsToUpdate.values();
		}
		if (volumeDetailSnapsToUpdate.size() > 0) {
			update volumeDetailSnapsToUpdate.values();
		}
		if(parentSeedDetailSnapsToUpdate.size() > 0){
			upsert parentSeedDetailSnapsToUpdate.values();
		}
		for (Opportunity opp : snapshotByOpportunity.keySet()) {
			if (newOpps.containsKey(opp.Id)) {
				newOpps.get(opp.Id).Incentive_Snapshot__c = snapshotByOpportunity.get(opp).Id;
			}
		}

		Set<Id> sIds = new Set<Id>();

		for (Incentive_Snapshot__c s : sList) {
			sIds.add(s.Id);
		}
		for (Incentive_Snapshot__c is : snapshotsToUpdate.values()) {
			sIds.add(is.Id);
		}

		return sIds;
	}

	public static void setSnapshot(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
		Set<Id> accountIds = new Set<Id>();
		Set<String> seasons = new Set<String>();
		List<String> brands = new List<String>();
		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		List<Opportunity> modifiedOpps = new List<Opportunity>();
		List<Incentive_Snapshot__c> incentiveSnaps = new List<Incentive_Snapshot__c>();
		Map<String, Incentive_Snapshot__c> snapBySeasonAndAccount = new Map<String, Incentive_Snapshot__c>();
		String RECORDTYPE_SR = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
			.get('Sales Report')
			.getRecordTypeId();
		for (Opportunity newOpp : newOpps.values()) {
			if (
				oldOpps != null &&
				oldOpps.containsKey(newOpp.Id) &&
				newOpp.Stagename == 'Approved' &&
				newOpp.StageName != oldOpps.get(newOpp.Id).StageName &&
				newOpp.RecordTypeId == RECORDTYPE_SR
			) {
				accountIds.add(newOpp.AccountId);
				seasons.add(newOpp.Safra__c);
				brands.add(newOpp.Marca__c);
				oppsToUpdate.add(newOpp);
			}
		}
		String brandsParameter = '(\'' + String.join(brands, '\',\'') + '\')';
		String query = 'SELECT Id, Account__c, Brand__c, Season__c, Unit_Totals__c, Incentive_Contract__c ';
		query += 'FROM Incentive_Snapshot__c ';
		query += 'WHERE Account__c in :accountIds AND Season__c IN :seasons AND Brand__c INCLUDES ' + brandsParameter;
		incentiveSnaps = Database.query(query);
		for (Incentive_Snapshot__c snapshot : incentiveSnaps) {
			String snapKey = snapshot.Account__c + snapshot.Season__c;
			if (!snapBySeasonAndAccount.containsKey(snapKey)) {
				snapBySeasonAndAccount.put(snapKey, snapshot);
			}
		}
		for (Opportunity oppToUpdate : oppsToUpdate) {
			String snapKey = oppToUpdate.AccountId + oppToUpdate.Safra__c;
			if (
				snapBySeasonAndAccount.containsKey(snapKey) &&
				snapBySeasonAndAccount.get(snapKey).Brand__c.contains(oppToUpdate.Marca__c)
			) {
				oppToUpdate.Incentive_Snapshot__c = snapBySeasonAndAccount.get(snapKey).Id;
				// modifiedOpps.add(oppToUpdate);
			}
		}
		// if (modifiedOpps.size() > 0) {
		// 	update modifiedOpps;
		// }
	}

	public static void handleSeasonInventoryChange(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
		Set<Id> changedOpps = new Set<Id>();
		List<OpportunityLineItem> relatedItems = new List<OpportunityLineItem>();
		List<OpportunityLineItem> itemsToUpdate = new List<OpportunityLineItem>();
		Id rtSale = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sale').getRecordTypeId();
		Id rtReservation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('Reservation')
			.getRecordTypeId();
		for (Id idOpp : newOpps.keySet()) {
			if (
				(newOpps.get(idOpp).HasOpportunityLineItem && newOpps.get(idOpp).RecordTypeId == rtSale ||
				newOpps.get(idOpp).RecordTypeId == rtReservation) &&
				(newOpps.get(idOpp).Safra__c != null &&
				oldOpps.containsKey(idOpp) &&
				oldOpps.get(idOpp).Safra__c != newOpps.get(idOpp).Safra__c)
			) {
				changedOpps.add(idOpp);
			}
		}
		relatedItems = [
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
				Reservation_Quantity__c,
				Opportunity.Type
			FROM OpportunityLineItem
			WHERE OpportunityId IN :changedOpps
		];
		Map<Id, OpportunityLineItem> itemById = new Map<Id, OpportunityLineItem>();
		for (OpportunityLineItem item : relatedItems) {
			itemById.put(item.Id, item);
		}
		if (itemById.size() > 0) {
			OpportunityLineItemTriggerUtils.setUtilsProperties(false, true, false, true, itemById, null);
			OpportunityLineItemTriggerUtils.handleInventoryStock(null, itemById);
		}
	}

	public static void setPricebook(List<Opportunity> newOpps) {
		//Add null to brands list to query pricebooks that are for every brand and not only for one
		Set<String> brands = new Set<String>{ null };
		brands.add('DONMARIO');
		Map<String, Map<String, Id>> pricebookByBrandAndType = new Map<String, Map<String, Id>>();
		List<Opportunity> oppsToAssingPricebook = new List<Opportunity>();
		Id rtSale = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sale').getRecordTypeId();
		Id rtPurchase = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('Purchase')
			.getRecordTypeId();
		Id rtReservation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('Reservation')
			.getRecordTypeId();
		String errorMsg;
		Set<Id> rTypes = new Set<Id>{ rtSale, rtPurchase, rtReservation };
		Map<String, Id> pricebookByType;
		for (Opportunity newOpp : newOpps) {
			if (rTypes.contains(newOpp.RecordTypeId) && newOpp.Marca__c != null && newOpp.Type != null) {
				brands.add(newOpp.Marca__c);
				oppsToAssingPricebook.add(newOpp);
			}
		}
		for (Pricebook2 thePricebook : [SELECT Id, Brand__c, Type__c FROM Pricebook2 WHERE Brand__c IN :brands]) {
			if (!pricebookByBrandAndType.containsKey(thePricebook.Brand__c)) {
				pricebookByBrandAndType.put(
					thePricebook.Brand__c,
					new Map<String, Id>{ thePricebook.Type__c => thePricebook.Id }
				);
			} else {
				pricebookByType = pricebookByBrandAndType.get(thePricebook.Brand__c);
				if (!pricebookByType.containsKey(thePricebook.Type__c)) {
					pricebookByType.put(thePricebook.Type__c, thePricebook.Id);
				}
			}
		}
		for (Opportunity opp : oppsToAssingPricebook) {
			// if (pricebookByBrandAndType.containsKey(opp.Marca__c)) {
			Id oppRecordType = opp.RecordTypeId;
			List<String> reservationTypes = new List<String>{
				'Z10 - DEVELOPMENT SEED',
				'Z7 - PRODUCTION SEED',
				'Z11 - RESEARCH SEED'
			};
			if (opp.Type == 'Z15 - REPLANT' && opp.Company__c == 'B&B' && opp.Marca__c == 'DONMARIO') {
				opp.Pricebook2Id = pricebookByBrandAndType.containsKey('DONMARIO') &&
					pricebookByBrandAndType.get('DONMARIO').containsKey('TRADEMARK')
					? pricebookByBrandAndType.get('DONMARIO').get('TRADEMARK')
					: opp.Pricebook2Id;
			}
			if (
				(opp.Type == 'Z15 - REPLANT' &&
				opp.Company__c == 'GDM' &&
				(opp.Marca__c == 'GDM' ||
				opp.Marca__c == 'VIRTUE')) ||
				(oppRecordType == rtPurchase &&
				opp.Type == 'Z4 - WHOLESALE SEED') ||
				(oppRecordType == rtSale &&
				opp.Type == 'Z6 - ROYALTY' &&
				(opp.Marca__c == 'DONMARIO' ||
				opp.Marca__c == 'VIRTUE'))
			) {
				if (pricebookByBrandAndType.containsKey(null) && pricebookByBrandAndType.get(null).containsKey('PORTAL')) {
					opp.Pricebook2Id = pricebookByBrandAndType.get(null).get('PORTAL');
				}
			} else if (
				oppRecordType == rtReservation &&
				reservationTypes.contains(opp.Type) &&
				pricebookByBrandAndType.containsKey(opp.Marca__c) &&
				pricebookByBrandAndType.get(opp.Marca__c).containsKey('PARENT SEED')
			) {
				opp.Pricebook2Id = pricebookByBrandAndType.get(opp.Marca__c).get('PARENT SEED');
			} else if (opp.Marca__c == 'GDM' && pricebookByBrandAndType.containsKey('GDM')) {
				if (oppRecordType == rtSale) {
					pricebookByType = pricebookByBrandAndType.get('GDM');
					switch on opp.Type {
						when 'Z2 - PARENT SEED', 'Z3 - TEST SEED', 'Z7 - PRODUCTION SEED' {
							opp.Pricebook2Id = pricebookByType.containsKey('PARENT SEED')
								? pricebookByType.get('PARENT SEED')
								: opp.Pricebook2Id;
						}
						when 'Z4 - WHOLESALE SEED' {
							opp.Pricebook2Id = pricebookByType.containsKey('WHOLESALE SEED')
								? pricebookByType.get('WHOLESALE SEED')
								: opp.Pricebook2Id;
						}
					}
				}
			} else if (opp.Marca__c == 'DONMARIO' && pricebookByBrandAndType.containsKey('DONMARIO')) {
				if (oppRecordType == rtSale) {
					pricebookByType = pricebookByBrandAndType.get('DONMARIO');
					switch on opp.Type {
						when 'Z2 - PARENT SEED',
							'Z14 - STOCK SEED',
							'Z3 - TEST SEED',
							'Z7 - PRODUCTION SEED',
							'PRODUCTION TRANSFER' {
							opp.Pricebook2Id = pricebookByType.containsKey('PARENT SEED')
								? pricebookByType.get('PARENT SEED')
								: opp.Pricebook2Id;
						}
						when 'COMMERCIAL SEED', 'Z4 - WHOLESALE SEED' {
							opp.Pricebook2Id = pricebookByType.containsKey('WHOLESALE SEED')
								? pricebookByType.get('WHOLESALE SEED')
								: opp.Pricebook2Id;
						}
						when 'Z16 - TRADEMARK ROYALTY' {
							opp.Pricebook2Id = pricebookByType.containsKey('TRADEMARK')
								? pricebookByType.get('TRADEMARK')
								: opp.Pricebook2Id;
						}
					}
				}
			} else if (opp.Marca__c == 'VIRTUE' && pricebookByBrandAndType.containsKey('VIRTUE')) {
				if (oppRecordType == rtSale) {
					pricebookByType = pricebookByBrandAndType.get('VIRTUE');
					switch on opp.Type {
						when 'Z2 - PARENT SEED', 'Z3 - TEST SEED' {
							opp.Pricebook2Id = pricebookByType.containsKey('PARENT SEED')
								? pricebookByType.get('PARENT SEED')
								: opp.Pricebook2Id;
						}
						when 'COMMERCIAL SEED', 'Z4 - WHOLESALE SEED' {
							opp.Pricebook2Id = pricebookByType.containsKey('WHOLESALE SEED')
								? pricebookByType.get('WHOLESALE SEED')
								: opp.Pricebook2Id;
						}
					}
				}
			}
			// }
		}
	}

	public static void validations(List<Opportunity> opps) {
		Id rtSale = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sale').getRecordTypeId();
		for (Opportunity opp : opps) {
			if (opp.Type == null && opp.RecordTypeId == rtSale) {
				opp.addError('Type', 'You must fill the "Type" field.');
			}
		}
	}

	// public static void setPortalReportsOwners(List<Opportunity> newOpps) {
	// 	Set<Id> oppsToChange = new Set<Id>();
	// 	List<Opportunity> oppsToUpdate = new List<Opportunity>();
	// 	Set<Id> accountIds = new Set<Id>();
	// 	Id rtSaleReport = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
	// 		.get('Sales_Report')
	// 		.getRecordTypeId();
	// 	Id rtProductionReport = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
	// 		.get('Production_Report')
	// 		.getRecordTypeId();

	// 	for (Opportunity newOpp : newOpps) {
	// 		if (newOpp.RecordTypeId == rtSaleReport || newOpp.RecordTypeId == rtProductionReport) {
	// 			accountIds.add(newOpp.AccountId);
	// 			oppsToChange.add(newOpp.Id);
	// 		}
	// 	}
	// 	if (oppsToChange.size() > 0) {
	// 		Map<Id, Account> accounts = new Map<Id, Account>(
	// 			[SELECT Id, Owner.FirstName, OwnerId FROM Account WHERE Id IN :accountIds]
	// 		);
	// 		List<String> names = new List<String>{ 'Charlie Simmons', 'Lance Burditt' };
	// 		List<User> owners = [SELECT Id, Name FROM User WHERE Name IN :names];
	// 		Map<String, Id> ownerByName = new Map<String, Id>();
	// 		for (User owner : owners) {
	// 			ownerByName.put(owner.Name, owner.Id);
	// 		}
	// 		if (owners.size() > 0) {
	// 			for (Opportunity opp : newOpps) {
	// 				Account theAccount = accounts.containsKey(opp.AccountId) ? accounts.get(opp.AccountId) : null;
	// 				if (
	// 					opp.Marca__c == 'GDM' &&
	// 					theAccount != null &&
	// 					theAccount.Owner.FirstName != 'Lance' &&
	// 					theAccount.OwnerId != null
	// 				) {
	// 					opp.OwnerId = theAccount.OwnerId;
	// 					// oppsToUpdate.add(opp);
	// 				} else if (
	// 					(opp.Marca__c == 'VIRTUE' || opp.Marca__c == 'DONMARIO') && ownerByName.containsKey('Lance Burditt')
	// 				) {
	// 					opp.OwnerId = ownerByName.get('Lance Burditt');
	// 					// oppsToUpdate.add(opp);
	// 				} else if (
	// 					opp.Marca__c == 'GDM' &&
	// 					theAccount != null &&
	// 					theAccount.Owner.FirstName == 'Lance' &&
	// 					ownerByName.containsKey('Charlie Simmons')
	// 				) {
	// 					opp.OwnerId = ownerByName.get('Charlie Simmons');
	// 					// oppsToUpdate.add(opp);
	// 				}
	// 			}
	// 		}
	// 	}
	// 	// if (oppsToUpdate.size() > 0) {
	// 	// 	update oppsToUpdate;
	// 	// }
	// }

	public static DiscountWrapper calculateVolumeDiscount(List<OpportunityLineItem> items, Incentive_Snapshot__c snapshot, Map<Id, Incentive_Code__c> icodeMap){
		DiscountWrapper discountWrapper = new DiscountWrapper();
		if(!snapshot.Incentive_Snapshot_Volume_Details__r.isEmpty() && !icodeMap.isEmpty()) {
			Double totalAcomplished = snapshot.Incentive_Snapshot_Volume_Details__r[0].Acomplished__c;
			for(OpportunityLineItem newProd : items){
				System.debug(newProd.Product2.Tecnologia__c);
				for (
					Incentive_Code_Detail__c incCodDet : icodeMap.get(snapshot.Incentive_Contract__r.Incentive_Code__c)
						.Incentive_Code_Details__r
				) 	{
						if (
							(incCodDet.Trait__c == newProd.Product2.Tecnologia__c &&
							totalAcomplished >= incCodDet.Min_perc__c &&
							totalAcomplished <= incCodDet.Max_perc__c) ||
							(totalAcomplished >= 99 &&
							incCodDet.Min_perc__c >= 99)
						) {
							Double discountValue = 0;
							Double finalPrice = 0;
							Double volumeGoal = snapshot.Incentive_Snapshot_Volume_Details__r[0]
								.Incentive_Contract_Volume_Goal__r.Volume__c;
							if (incCodDet.Min_Price__c != null && incCodDet.Max_Price__c != null) {
								Double minPerc = incCodDet.Min_perc__c;
								Double maxPerc = incCodDet.Max_perc__c == null ? 100 : incCodDet.Max_perc__c;
								Double maxPrice = incCodDet.Max_Price__c;
								Double minPrice = incCodDet.Min_Price__c;
								Double partialPerc = ((totalAcomplished - minPerc) / (maxPerc - minPerc));
								Double discount = (maxPrice - minPrice) * partialPerc;
								finalPrice = maxPrice - discount;
								discountValue = newProd.UnitPrice - finalPrice;
							} else {
								discountValue = newProd.UnitPrice - incCodDet.Discount_Price__c;
								finalPrice = incCodDet.Discount_Price__c;
							}
							discountWrapper.discountByItem.put(newProd.Id, discountValue);
							discountWrapper.finalPriceByItem.put(newProd.Id, finalPrice);
							discountWrapper.discountAchieved += discountValue;
							discountWrapper.totalPrice += discountValue;
						}
					}
			}
			snapshot.Incentive_Snapshot_Volume_Details__r[0].Total_Discount__c += discountWrapper.discountAchieved;
			discountWrapper.volumeDetails.put(snapshot.Incentive_Snapshot_Volume_Details__r[0].Id, snapshot.Incentive_Snapshot_Volume_Details__r[0]);
		}
		return discountWrapper;
	}

	public static DiscountWrapper calculateParentSeedDiscounts(List<OpportunityLineItem> salesItems, List<OpportunityLineItem> parentSeedItems,  Incentive_Snapshot__c snapshot, Map<Id,Incentive_Parent_Seed_Code__c> parentSeedMap){
		DiscountWrapper discountWrapper = new DiscountWrapper();
		if(
			!snapshot.Incentive_Snapshot_Parent_Seed_Details__r.isEmpty() &&
			!parentSeedMap.isEmpty() 
		){
			Set<String> varieties = new Set<String>();
			Decimal quantities = 0;
			Decimal xtendflexDiscount = 0;
			Decimal conventionalDiscount = 0;
			Decimal enlistDiscount = 0;
			Incentive_Snapshot_Parent_Seed_Detail__c snapParentDetail = snapshot.Incentive_Snapshot_Parent_Seed_Details__r[0]; 
			Decimal quantitiesGoal = snapParentDetail.Incentive_Contract_Parent_Seed_Goal__r.Quantities__c;
			Decimal varietiesGoal = snapParentDetail.Incentive_Contract_Parent_Seed_Goal__r.Unique_Varieties__c;
			Decimal varietiesAcomplished = snapParentDetail.Unique_Varieties_Acomplished__c;
			Decimal quantitiesAcomplished =  snapParentDetail.Quantities_Acomplished__c;
			for(OpportunityLineItem item : parentSeedItems){
				varieties.add(item.Variedade_de_Produto__c);
				quantities += item.Quantity_by_140k__c;
			}
			for (
				Incentive_Parent_Seed_Code_Detail__c parentSeedDetail : parentSeedMap.get(snapshot.Incentive_Contract__r.Incentive_Parent_Seed_Code__c).
				Incentive_Parent_Seed_Code_Details__r
			) {
				Decimal maxVarieties = parentSeedDetail.Max_Varieties__c;
				Decimal minVarieties = parentSeedDetail.Min_Varieties__c;
				Decimal maxQuantities = parentSeedDetail.Max_Quantities__c;
				Decimal minQuantities = parentSeedDetail.Min_Quantities__c;
				for(OpportunityLineItem item : salesItems){
					if(
						(parentSeedDetail.Trait__c == item.Product2.Tecnologia__c) && 
						((quantitiesAcomplished >= minQuantities && quantitiesAcomplished <= maxQuantities || 
						(varietiesAcomplished >= minVarieties && varietiesAcomplished <= maxVarieties)) ||
						(quantitiesAcomplished >= 99 && minQuantities >= 99 || varietiesAcomplished >= 99 && minVarieties >= 99)) 
						
					){
						Decimal discount = 0;
						discount = item.UnitPrice - parentSeedDetail.Discount__c;
						discountWrapper.discountByItem.put(item.Id, discount);
						discountWrapper.finalPriceByItem.put(item.Id, parentSeedDetail.Discount__c);
						discountWrapper.discountAchieved += discount;
						discountWrapper.totalPrice += discount;
					}
				}
			}
			snapshot.Incentive_Snapshot_Parent_Seed_Details__r[0].Total_Discount__c += discountWrapper.discountAchieved;
			discountWrapper.parentSeedDetails.put(snapshot.Incentive_Snapshot_Parent_Seed_Details__r[0].Id,  snapshot.Incentive_Snapshot_Parent_Seed_Details__r[0]);
		}
		return discountWrapper;
	}
	
	public class DiscountWrapper {
		Map<Id,Incentive_Snapshot_Volume_Detail__c> volumeDetails = new Map<Id,Incentive_Snapshot_Volume_Detail__c>();
		Map<Id,Incentive_Snapshot_Parent_Seed_Detail__c> parentSeedDetails = new Map<Id,Incentive_Snapshot_Parent_Seed_Detail__c>();
		Map<Id,Decimal> discountByItem = new Map<Id,Decimal>();
		Map<Id,Decimal> finalPriceByItem = new Map<Id,Decimal>();
		Decimal discountAchieved = 0;
		Decimal totalPrice = 0;
	}	
}