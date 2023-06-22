global without sharing class aSiteProductionReportController {
	private static String ANEXO_RECORDTYPE = 'Production Report';
	private static String ANEXO_LP = 'Portal PriceList';

	private String token;
	private String type;
	private SiteUser__c logUser;
	private SiteUserSession__c activeSession;
	private Account activeAccount;

	private String rt_A2;
	private Map<String, Id> rty;
	private Map<String, PricebookEntry> rPb;

	public String language { get; set; }
	public String titulo { get; set; }
	public String subtitulo { get; set; }
	public String titulo_tabla { get; set; }
	public String titulo_panel { get; set; }
	private Map<String, String> rTypes;

	public Opportunity[] relatedApp { get; set; }
	public OpportunityLineItem[] relatedAppItems { get; set; }
	public List<String> relatedAppTotals { get; set; }
	//public OpportunityLineItem[] relatedAppItems_1 {get; set;}

	public Opportunity tmpAppII { get; set; }
	public aSiteUtils.myOppRepItem[] tmpAppItems { get; set; }

	public aSiteUtils.myOppRepItem[] tmpAppItemsForecast { get; set; }
	public aSiteUtils.myOppRepItem[] tmpAppItemsProd { get; set; }
	public aSiteUtils.myOppRepItem[] tmpAppItemsUpdate { get; set; }
	public aSiteUtils.myOppRepItem tmpAppItemUpdate { get; set; }

	public Integer cantItemsUpdate { get; set; }
	public Integer itemUpdateAct { get; set; }

	public string recId { get; set; }
	public string editId { get; set; }

	public string marcaVisible { get; set; }
	public string panelVisible { get; set; }
	public string repType { get; set; }

	global aSiteProductionReportController() {
		try {
			repType = System.currentPageReference().getParameters().get('t');
			rty = Opp_Utils.cargarRecordTypesOportunidades();
			System.debug('JERE: ' + 'controller');

			// if (language != null) {
			// 	System.debug('JERE: ' + language);
			language = [SELECT id, LanguageLocaleKey FROM User WHERE id = :UserInfo.getUserId()].LanguageLocaleKey;
			// }

			rTypes = USAUtils.cargarRecordTypesOppbyDevName();
			titulo = rTypes.get('Production_Report');

			if (repType == 'fi') {
				subtitulo = 'Final Production Report';
				type = 'Final Production Report';
				showConditioned();
			}
			if (repType == 'up1') {
				subtitulo = 'Production Update 1';
				type = 'Production Update 1';
				showForecast();
			}
			if (repType == 'up2') {
				subtitulo = 'Production Update 2';
				type = 'Production Update 2';
				showForecast();
			}
			if (repType == 'up3') {
				subtitulo = 'Production Update 3';
				type = 'Production Update 3';
				showForecast();
			}
			if (repType == 'up4') {
				subtitulo = 'Production Update 4';
				type = 'Production Update 4';
				showForecast();
			}
			if (repType == 'up5') {
				subtitulo = 'Production Update 5';
				type = 'Production Update 5';
				showForecast();
			}
		} catch (Exception e) {
		}
	}

	public PageReference validate() {
		token = System.currentPageReference().getParameters().get('token');
		editId = System.currentPageReference().getParameters().get('e');
		System.debug('JERE: ' + 'validate');
		if (token != null) {
			System.debug('JERE: ' + 'token');
			logUser = aSiteAuthManager.VerifyUserSession(token);
			if (logUser != null) {
				System.debug('JERE: ' + 'token+user');
				activeSession = aSiteAuthManager.getUserSession(token);
				activeAccount = aSiteAuthManager.getActiveAccount_byUser(logUser);

				marcaVisible = activeSession.Marca__c;
				getRepItemsUpdate();

				return null;
			}
		}

		PageReference p = new PageReference('/apex/aSiteLogin');
		p.setRedirect(true);
		return p;
	}

	public List<Opportunity> getProductionReport() {
		try {
			if (relatedApp != null && relatedApp.size() > 0)
				return relatedApp;

			if (
				repType == 'up1' ||
				repType == 'up2' ||
				(repType == 'up3' &&
				activeSession.Marca__c == 'DONMARIO') ||
				(repType == 'up4' &&
				activeSession.Marca__c == 'DONMARIO')
			)
				relatedApp = aAppManager.getProductionReportOpp(
					activeAccount.Id,
					activeSession.Production_season__c,
					activeSession.Marca__c,
					type
				);
			else
				relatedApp = aAppManager.getProductionReportOpp(
					activeAccount.Id,
					activeSession.Safra__c,
					activeSession.Marca__c,
					type
				);

			if (relatedApp.size() > 0) {
				recId = relatedApp[0].Id;
				setActiveOpp();
			}

			return relatedApp;
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getLineNumber() + '\n' + e.getMessage()));
			return null;
		}
	}

	public List<aSiteUtils.myOppRepItem> getRepItemsUpdate() {
		//Arma la grilla de productos activados para nuevo anexo 2, resuelvo items custom para edicion en sitio

		if (tmpAppItemsUpdate != null && tmpAppItemsUpdate.size() > 0)
			return tmpAppItemsUpdate;

		List<aSiteUtils.myOppRepItem> tmpItems = new List<aSiteUtils.myOppRepItem>();
		List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
		Map<String, Item_del_Contrato__c> mapSchedule = new Map<String, Item_del_Contrato__c>();
		Map<String, OpportunityLineItem> mapUnitUsed = new Map<String, OpportunityLineItem>();
		Map<String, OpportunityLineItem> mapParentSeed = new Map<String, OpportunityLineItem>();

		System.debug('JERE: ' + 'RepItemsUpdate');
		String season = activeSession.Safra__c;
		if (activeSession.Marca__c == 'DONMARIO')
			season = activeSession.Production_season__c;

		try {
			if (editId != null)
				tmpOppItems = aAppManager.getAnexosItemsByOpp(editId);
			else {
				mapSchedule = aAppManager.getMapSchedules(activeAccount.Id, activeSession.Safra__c, activeSession.Marca__c);
				mapUnitUsed = aAppManager.getMapUsedUnits(
					activeAccount.Id,
					activeSession.Last_season__c,
					activeSession.Marca__c
				);
				mapParentSeed = aAppManager.getMapParentSeeds(activeAccount.Id, activeSession.safra__c, activeSession.Marca__c);

				if (repType == 'up1')
					tmpOppItems = aAppManager.getItemsToProductionRep(
						activeAccount.Id,
						activeSession.production_season__c,
						activeSession.Marca__c
					);
				if (repType == 'up2')
					tmpOppItems = aAppManager.getItemsToProductionUpdate2Rep(
						activeAccount.Id,
						activeSession.production_season__c,
						activeSession.Marca__c
					);
				if (repType == 'up3')
					tmpOppItems = aAppManager.getItemsToProductionUpdate3Rep(activeAccount.Id, season, activeSession.Marca__c);
				if (repType == 'up4')
					tmpOppItems = aAppManager.getItemsToProductionUpdate4Rep(activeAccount.Id, season, activeSession.Marca__c);
				if (repType == 'up5')
					tmpOppItems = aAppManager.getItemsToProductionUpdate5Rep(
						activeAccount.Id,
						activeSession.Safra__c,
						activeSession.Marca__c
					);
				if (repType == 'fi')
					tmpOppItems = aAppManager.getItemsToFinalProductionRep(
						activeAccount.Id,
						activeSession.Safra__c,
						activeSession.Marca__c
					);
			}

			System.debug('JERE: ' + 'After query ' + repType);
			System.debug('JERE: ' + 'After AccountId ' + activeAccount.Id);
			System.debug('JERE: ' + 'After Season ' + activeSession.Safra__c);
			System.debug('JERE: ' + 'After Marca ' + activeSession.Marca__c);
			System.debug('JERE: ' + 'After query size ' + tmpOppItems.size());

			Item_del_Contrato__c itemC = new Item_del_Contrato__c();
			OpportunityLineItem itemopp = new OpportunityLineItem();

			for (OpportunityLineItem s : tmpOppItems) {
				aSiteUtils.myOppRepItem oli = new aSiteUtils.myOppRepItem();

				oli.variedad = s.Variedade_de_Produto__c;
				oli.variedad_registro = s.Variety_Number__c;
				oli.brand = s.Brand_Name__c;
				oli.categoria = s.Categoria__r.Name;
				oli.categoria_id = s.Categoria__c;

				if (editId == null) {
					if (mapSchedule.containsKey(s.Variedade_de_Produto__c)) {
						//vinculo al schedule A variety por variedad
						itemC = mapSchedule.get(s.Variedade_de_Produto__c);
						if (!itemC.active__c)
							continue;
						oli.license = Date.valueOF(itemC.Contrato_de_Multiplicacion__r.License_Date__c);
						oli.variedad_licencia_id = String.valueOF(itemC.Licensee_Variety_ID__c);
						oli.royalty_rate = itemC.Precio__c; //Double.valueOf(items.Precio__c);
					}
					if (mapUnitUsed.containsKey(s.Variedade_de_Produto__c)) {
						//vinculo al Sales Report variety por variedad
						itemopp = mapUnitUsed.get(s.Variedade_de_Produto__c);
						oli.used_dm_prod = Integer.valueOf(itemopp.Semente_Uso_propio__c);
					}

					oli.production_area = Integer.valueOf(s.Area_Plantada__c);
					oli.production_bushels = Integer.valueOf(s.Semente_bruta__c);
					oli.drop = s.Date_Dropped__c;

					if (repType == 'up1') {
						oli.conditioned_140k = Integer.valueOf(s.Semente_beneficiada__c);
						if (mapParentSeed.containsKey(s.Variedade_de_Produto__c)) {
							//vinculo a Parent Sales por variedad
							itemopp = mapParentSeed.get(s.Variedade_de_Produto__c);
							if (itemopp.Prev_Parent__c != null)
								oli.parent_purchased =
									Integer.valueOf(itemopp.Quantity_by_140k__c) + Integer.valueOf(itemopp.Prev_Parent__c);
							else
								oli.parent_purchased = Integer.valueOf(itemopp.Quantity_by_140k__c);
						}
					} else {
						oli.conditioned_140k = Integer.valueOf(s.Units_Estimate_140k__c);
						oli.area_prev = Integer.valueOF(s.Area_Plantada__c); //prev field for validation PRF
						oli.bushel_prev = Integer.valueOF(s.Semente_bruta__c); //prev field for validation PRF
						oli.supply_prev = Integer.valueOF(s.Units_Estimate_140k__c); //prev field for validation PRF
					}
				} else {
					oli.id = s.Id;

					if (s.Prev_supply__c != null)
						oli.supply_prev = Integer.valueOf(s.Prev_supply__c);

					if (s.Prev_Parent__c != null)
						oli.parent_purchased = Integer.valueOf(s.Prev_Parent__c);

					if (s.Licensee_Variety_Name__c != null)
						oli.variedad_licencia_id = s.Licensee_Variety_Name__c;

					if (s.Semente_uso_propio__c != null)
						oli.used_dm_prod = Integer.valueOf(s.Semente_uso_propio__c);

					if (s.Area_Plantada__c != null)
						oli.production_area = Integer.valueOf(s.Area_Plantada__c);

					if (s.Option_acres__c != null)
						oli.optional_area = Integer.valueOf(s.Option_acres__c);

					if (s.Semente_bruta__c != null)
						oli.production_bushels = Integer.valueOf(s.Semente_bruta__c);

					if (s.Units_Estimate_140k__c != null)
						oli.conditioned_140k = Integer.valueOf(s.Units_Estimate_140k__c);

					if (s.Semente_beneficiada__c != null)
						oli.conditioned_140k = Integer.valueOf(s.Semente_beneficiada__c);

					if (s.Total_Replant_Claim__c != null)
						oli.replants = Integer.valueOf(s.Total_Replant_Claim__c);

					if (s.Date_Dropped__c != null)
						oli.drop = s.Date_Dropped__c;
				}

				tmpItems.add(oli);
			}

			tmpAppItemsUpdate = tmpItems;
			cantItemsUpdate = tmpAppItemsUpdate.size();
			itemUpdateAct = 0;

			return tmpItems;
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getLineNumber() + '\n' + e.getMessage()));
			return tmpAppItems;
		}
	}

	public void showForecast() {
		panelVisible = 'Forecast';
		titulo_tabla = 'Production Forecast Update';
	}
	public void showConditioned() {
		panelVisible = 'Conditioned';
		titulo_tabla = 'Final Production & Conditioned Units';
	}

	public PageReference submitReport() {
		PageReference pr = new PageReference('/apex/aSiteProductionReport');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', repType);
		try {
			Opportunity opp = new Opportunity();
			opp.Stagename = 'Sent';
			opp.Id = editId;
			update opp;
			//Commented because email sending is not enabled in sandbox enviroments
			aAppManager.sendNotification(new List<String>{ logUser.Email__c }, 'success');
		} catch (Exception ex) {
			System.debug(ex.getStackTraceString());
			//Commented because email sending is not enabled in sandbox enviroments
			// aAppManager.sendNotification(new List<String>{ logUser.Email__c }, 'error');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getLineNumber() + '\n' + ex.getMessage()));
		}
		return pr;
	}

	public PageReference saveReport() {
		if (save()) {
			PageReference pr = new PageReference('/apex/aSiteProductionReport');
			pr.setRedirect(true);
			pr.getParameters().put('token', token);
			pr.getParameters().put('t', repType);
			return pr;
		} else {
			return null;
		}
	}

	public boolean save() {
		Savepoint sp = Database.setSavepoint();

		try {
			List<OpportunityLineItem> saveOppItems = new List<OpportunityLineItem>();

			String msg = '';
			rt_A2 = rty.get(ANEXO_RECORDTYPE);
			rPb = Opp_Utils.cargarRoyaltyPricebookEntries(ANEXO_LP);

			if (tmpAppItemsUpdate != null) {
				for (aSiteUtils.myOppRepItem tmp : tmpAppItemsUpdate) {
					OpportunityLineItem item = new OpportunityLineItem();

					item.Quantity = 0.1;
					item.UnitPrice = 1;
					if (rPb.get(tmp.variedad) != null)
						item.PricebookEntryId = rPb.get(tmp.variedad).Id;
					item.Categoria__c = tmp.categoria_id;

					item.Semente_uso_propio__c = tmp.used_dm_prod;
					item.Area_Plantada__c = tmp.production_area;
					item.Option_acres__c = tmp.optional_area;
					item.Semente_bruta__c = tmp.production_bushels;

					item.Prev_acres__c = tmp.area_prev;
					item.Prev_bushels__c = tmp.bushel_prev;
					item.Prev_supply__c = tmp.supply_prev;
					item.Prev_parent__c = tmp.parent_purchased;

					item.Total_Replant_Claim__c = tmp.replants;
					item.Date_Dropped__c = tmp.drop;
					item.Licensee_Variety_Name__c = tmp.variedad_licencia_id;
					item.Royalty_Rate__c = tmp.royalty_rate;

					if (repType == 'fi') {
						item.Semente_beneficiada__c = tmp.conditioned_140k;
						item.Units_Estimate_140k__c = tmp.supply_prev;
					} else
						item.Units_Estimate_140k__c = tmp.conditioned_140k;

					if (tmp.id != null && tmp.Id != '')
						item.Id = tmp.Id;

					saveOppItems.add(item);
				}
			}

			Account_Reference__mdt GDMAccount = [SELECT Id, AccountId__c FROM Account_Reference__mdt WHERE Label = 'B&B'];
			if (editId == null) {
				//insert

				if (
					repType == 'up1' ||
					repType == 'up2' ||
					(repType == 'up3' &&
					activeSession.Marca__c == 'DONMARIO') ||
					(repType == 'up4' &&
					activeSession.Marca__c == 'DONMARIO')
				)
					tmpAppII = new Opportunity(
						Name = 'TMP',
						SiteUser__c = logUser.Id,
						Type = type,
						Stagename = 'Editable',
						CloseDate = System.today(),
						RecordTypeId = rt_A2,
						AccountId = activeAccount.Id,
						Safra__c = activeSession.production_season__c,
						Marca__c = activeSession.Marca__c
					);
				else
					tmpAppII = new Opportunity(
						Name = 'TMP',
						SiteUser__c = logUser.Id,
						Type = type,
						Stagename = 'Editable',
						CloseDate = System.today(),
						RecordTypeId = rt_A2,
						AccountId = activeAccount.Id,
						Safra__c = activeSession.Safra__c,
						Marca__c = activeSession.Marca__c
					);

				if (activeSession.Marca__c == 'DONMARIO' && activeAccount.Id != GDMAccount.Id)
					tmpAppII.Company__c = 'B&B';
				insert tmpAppII;

				editId = tmpAppII.Id;
				for (OpportunityLineItem item : saveOppItems)
					item.OpportunityId = tmpAppII.Id;

				insert saveOppItems;
			} else {
				update saveOppItems;
			}

			System.debug(msg);
		} catch (Exception e) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getLineNumber() + '\n' + e.getMessage()));
			return false;
		}
		update activeSession;

		return true;
	}

	public List<Schema.FieldSetMember> getFields() {
		if ((repType == 'up1' || repType == 'up5' || repType == 'up2') && activeSession.Marca__c == 'DONMARIO')
			return SObjectType.OpportunityLineItem.FieldSets.Production_1_DM.getFields();
		if (repType == 'up3' && activeSession.Marca__c == 'DONMARIO')
			return SObjectType.OpportunityLineItem.FieldSets.Production_3_DM.getFields();
		if (repType == 'up4' && activeSession.Marca__c == 'DONMARIO')
			return SObjectType.OpportunityLineItem.FieldSets.Production_4_DM.getFields();

		if (repType == 'up3' && activeSession.Marca__c == 'GDM')
			return SObjectType.OpportunityLineItem.FieldSets.Production_Report_3.getFields();

		if (repType == 'fi')
			if (activeSession.Marca__c == 'DONMARIO')
				return SObjectType.OpportunityLineItem.FieldSets.Final_Production_Report.getFields();
			else
				return SObjectType.OpportunityLineItem.FieldSets.Production_Report_gdm.getFields();
		else
			return SObjectType.OpportunityLineItem.FieldSets.Production_Forecast_Report.getFields();
		return null;
	}

	public void setActiveOpp() {
		//Identifica que opp esta activa y consulta los items relacionados para mostrar en pantalla
		try {
			relatedAppItems = new List<OpportunityLineItem>();
			relatedAppItems = aAppManager.getReportItemsByOpp(recId, 'Production');
			//OpportunityLineItem emptyItem = new OpportunityLineItem();
			//relatedAppItems.add(emptyItem);
			relatedAppItems.add(getRelatedAppTotals(relatedAppItems));
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
		}
	}

	public OpportunityLineItem getRelatedAppTotals(OpportunityLineItem[] items) {
		Decimal productionAcres = 0;
		Decimal productionBushels = 0;
		Decimal cond140Unit = 0;
		Decimal units = 0;
		for (OpportunityLineItem item : items) {
			if (item.Area_Plantada__c != null)
				productionAcres += item.Area_Plantada__c;
			if (item.Semente_bruta__c != null)
				productionBushels += item.Semente_bruta__c;
			if (item.Semente_beneficiada__c != null)
				cond140Unit += item.Semente_beneficiada__c;
			if (item.Units_Estimate_140K__c != null)
				units += item.Units_Estimate_140K__c;
		}
		OpportunityLineItem result = new OpportunityLineItem();
		result.Area_Plantada__c = productionAcres;
		result.Semente_bruta__c = productionBushels;
		result.Semente_beneficiada__c = cond140Unit;
		result.Units_Estimate_140K__c = units;
		result.Licensee_Variety_Name__c = 'Total';
		return result;
	}

	public PageReference gotoEdit() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr = new PageReference('/apex/aSiteProductionReportEdit');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', repType);
		pr.getParameters().put('e', editId);
		return pr;
	}

	public PageReference gotoNew() {
		if (relatedApp.size() > 0) {
			ApexPages.addMessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'Your account has already completed this report.    ')
			);
			return null;
		}

		PageReference pr = new PageReference('/apex/aSiteProductionReportEdit');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', repType);
		return pr;
	}

	public PageReference editCancel() {
		PageReference pr = new PageReference('/apex/aSiteProductionReport');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', repType);
		return pr;
	}

	public SiteUser__c getUser() {
		return logUser;
	}
	public Account getAccount() {
		return activeAccount;
	}
}