global without sharing class aSiteSalesReportController {
	private static String ANEXO_RECORDTYPE = 'Sales Report';
	private static String ANEXO_LP = 'Portal PriceList';

	private String token;
	private String type;
	private SiteUser__c logUser;
	private SiteUserSession__c activeSession;
	private Account activeAccount;

	private String rt_A3;
	private String rt_A2;
	private Map<String, Id> rty;
	private Map<String, PricebookEntry> rPb;

	public String language { get; set; }
	public String titulo { get; set; }
	public String subtitulo { get; set; }
	public String titulo_panel { get; set; }
	private Map<String, String> rTypes;

	public Opportunity[] relatedApp { get; set; }
	public Opportunity lastRelatedApp { get; set; }
	public OpportunityLineItem[] relatedAppItems { get; set; }

	public Opportunity tmpAppII { get; set; }
	public aSiteUtils.myOppRepItem[] tmpAppItems { get; set; }
	public aSiteUtils.myOppRepItem[] tmpAppItemsSale { get; set; }
	public aSiteUtils.myOppRepItem[] tmpAppItemsForecast { get; set; }
	public aSiteUtils.myOppRepItem tmpAppItemForecast { get; set; }
	public Integer cantItemsForecast { get; set; }
	public Integer itemForecastAct { get; set; }
	public string recId { get; set; }
	public string editId { get; set; }
	public Boolean filledOpportunity { get; set; }
	public string marcaVisible { get; set; }
	public string panelVisible { get; set; }
	public string repType { get; set; }
	public List<Map<String, String>> mapItems { get; set; }

	global aSiteSalesReportController() {
		try {
			repType = System.currentPageReference().getParameters().get('t');
			rty = Opp_Utils.cargarRecordTypesOportunidades();
			language = [SELECT id, LanguageLocaleKey FROM User WHERE id = :UserInfo.getUserId()].LanguageLocaleKey;
			rTypes = USAUtils.cargarRecordTypesOppbyDevName();
			titulo = rTypes.get('Sales_Report');
			filledOpportunity = false;
			if (repType == 'up1') {
				subtitulo = 'Sales Forecast Update 1';
				type = 'Sales Forecast Update 1';
				panelVisible = 'Forecast';
				titulo_panel = 'Sales Volume Forecast';
			}
			if (repType == 'up2') {
				subtitulo = 'Sales Forecast Update 2';
				type = 'Sales Forecast Update 2';
				panelVisible = 'Forecast';
				titulo_panel = 'Sales Volume Forecast';
			}
			if (repType == 'up3') {
				subtitulo = 'Sales Forecast Update 3';
				type = 'Sales Forecast Update 3';
				panelVisible = 'Forecast';
				titulo_panel = 'Sales Volume Forecast';
			}
			if (repType == 'up4') {
				subtitulo = 'Sales Forecast Update 4';
				type = 'Sales Forecast Update 4';
				panelVisible = 'Forecast';
				titulo_panel = 'Sales Volume Forecast';
			}
			if (repType == 'fi') {
				subtitulo = 'Final Sales Report';
				type = 'Final Sales Report';
				panelVisible = 'Sales';
				titulo_panel = 'Sales';
			}
		} catch (Exception e) {
		}
	}

	public PageReference validate() {
		token = System.currentPageReference().getParameters().get('token');
		editId = System.currentPageReference().getParameters().get('e');

		if (token != null) {
			logUser = aSiteAuthManager.VerifyUserSession(token);
			if (logUser != null) {
				activeSession = aSiteAuthManager.getUserSession(token);
				activeAccount = aSiteAuthManager.getActiveAccount_byUser(logUser);
				marcaVisible = activeSession.Marca__c;
				return null;
			}
		}

		PageReference p = new PageReference('/apex/aSiteLogin');
		p.setRedirect(true);
		return p;
	}

	public List<Opportunity> getSalesReport() {
		try {
			if (relatedApp != null && relatedApp.size() > 0)
				return relatedApp;

			relatedAppItems = new List<OpportunityLineItem>();
			relatedApp = aAppManager.getSalesReportOpp(
				activeAccount.Id,
				activeSession.Sales_Season__c,
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

	public void setActiveOpp() {
		//Identifica que opp esta activa y consulta los items relacionados para mostrar en pantalla
		try {
			Map<String, OpportunityLineItem> productsFromPreviousStages = lookForProductionFinalReportProducts();
			relatedAppItems = aAppManager.getAnexosItemsByOpp(recId);
			for (OpportunityLineItem product : relatedAppItems) {
				OpportunityLineItem productFromPreviousStage;
				if (
					productsFromPreviousStages != null && productsFromPreviousStages.containsKey(product.Variedade_de_Produto__c)
				) {
					productFromPreviousStage = productsFromPreviousStages.get(product.Variedade_de_Produto__c);
					if (productFromPreviousStage != null) {
						product.Area_Plantada__c = Integer.valueOf(productFromPreviousStage.Area_Plantada__c);
					}
					if (productFromPreviousStage != null) {
						product.Semente_Bruta__c = Integer.valueOf(productFromPreviousStage.Semente_bruta__c);
					}
				}
			}
			if (productsFromPreviousStages != null && !productsFromPreviousStages.isEmpty()) {
				filledOpportunity = true;
			}
			if (repType == 'fi') {
				setMapItems(relatedAppItems);
			} else {
				relatedAppItems.add(getRelatedAppTotals(relatedAppItems));
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
		}
	}

	public OpportunityLineItem getRelatedAppTotals(OpportunityLineItem[] items) {
		Decimal productionAcres = 0;
		Decimal productionBushels = 0;
		Decimal salesForecast140 = 0;
		for (OpportunityLineItem item : items) {
			if (item.Area_Plantada__c != null)
				productionAcres += item.Area_Plantada__c;
			if (item.Semente_Bruta__c != null)
				productionBushels += item.Semente_bruta__c;
			if (item.Forecast_Quantity__c != null)
				salesForecast140 += item.Forecast_Quantity__c;
		}
		OpportunityLineItem result = new OpportunityLineItem();
		result.Area_Plantada__c = productionAcres;
		result.Semente_bruta__c = productionBushels;
		result.Forecast_Quantity__c = salesForecast140;
		result.Licensee_Variety_Name__c = 'Total';
		return result;
	}

	public void setMapItems(List<OpportunityLineItem> items) {
		mapItems = new List<Map<String, String>>();
		Decimal commercialSales = 0;
		Decimal testPlotUnits = 0;
		Decimal unitsUsedForProduction = 0;
		Decimal unitTotals = 0;
		Decimal descarte = 0;
		Decimal wholeSaleIn = 0;
		Decimal wholeSaleOut = 0;
		Decimal testSeedPurchases = 0;
		Decimal parentSeedPurchases = 0;
		for (OpportunityLineItem item : items) {
			String parsedDate;
			if (item.Date_Dropped__c != null) {
				parsedDate =
					item.Date_Dropped__c.month() +
					'/' +
					item.Date_Dropped__c.day() +
					'/' +
					item.Date_Dropped__c.year();
			} else {
				parsedDate = '';
			}
			if (item.Semente_comercializada__c != null)
				commercialSales += item.Semente_comercializada__c;
			if (item.Test_Plots_Units__c != null)
				testPlotUnits += item.Test_Plots_Units__c;
			if (item.Semente_uso_propio__c != null)
				unitsUsedForProduction += item.Semente_uso_propio__c;
			if (item.Unit_Totals__c != null)
				unitTotals += item.Unit_Totals__c;
			if (item.Descarte__c != null)
				descarte += item.Descarte__c;
			if (item.Wholesale_Sales__c != null)
				wholeSaleOut += item.Wholesale_Sales__c;
			if (item.Product_Purchased__c != null)
				wholeSaleIn += item.Product_Purchased__c;
			if (item.Test_Seed_Purchases__c != null)
				testSeedPurchases += item.Test_Seed_Purchases__c;
			if (item.Parent_Seed_Purchases__c != null)
				parentSeedPurchases += item.Parent_Seed_Purchases__c;

			// Wholesale_Sales__c wholse sale out
			//Product_Purchased__c whole sale in
			mapItems.add(
				new Map<String, String>{
					'Semente_comercializada__c' => parseNullToString(String.valueOf(item.Semente_Comercializada__c)),
					'Test_Plots_Units__c' => parseNullToString(String.valueOf(item.Test_Plots_Units__c)),
					'Semente_uso_propio__c' => parseNullToString(String.valueOf(item.Semente_uso_propio__c)),
					'Unit_Totals__c' => parseNullToString(String.valueOf(item.Unit_Totals__c)),
					'Descarte__c' => parseNullToString(String.valueOf(item.Descarte__c)),
					'Licensee_Variety_Name__c' => parseNullToString(String.valueOf(item.Licensee_Variety_Name__c)),
					'Wholesale_Sales__c' => parseNullToString(String.valueOf(item.Wholesale_Sales__c)),
					'Product_Purchased__c' => parseNullToString(String.valueOf(item.Product_Purchased__c)),
					'Date_Dropped__c' => parsedDate,
					'Variedade_de_Produto__c' => parseNullToString(String.valueOf(item.Variedade_de_Produto__c)),
					'Parent_Seed_Purchases__c' => parseNullToString(String.valueOf(item.Parent_Seed_Purchases__c)),
					'Test_Seed_Purchases__c' => parseNullToString(String.valueOf(item.Test_Seed_Purchases__c))
				}
			);
		}

		mapItems.add(
			new Map<String, String>{
				'Semente_comercializada__c' => parseNullToString(String.valueOf(commercialSales)),
				'Test_Plots_Units__c' => parseNullToString(String.valueOf(testPlotUnits)),
				'Semente_uso_propio__c' => parseNullToString(String.valueOf(unitsUsedForProduction)),
				'Unit_Totals__c' => parseNullToString(String.valueOf(unitTotals)),
				'Descarte__c' => parseNullToString(String.valueOf(descarte)),
				'Licensee_Variety_Name__c' => '---',
				'Wholesale_Sales__c' => parseNullToString(String.valueOf(wholeSaleOut)),
				'Product_Purchased__c' => parseNullToString(String.valueOf(wholeSaleIn)),
				'Test_Seed_Purchases__c' => parseNullToString(String.valueOf(testSeedPurchases)),
				'Parent_Seed_Purchases__c' => parseNullToString(String.valueOf(parentSeedPurchases)),
				'Date_Dropped__c' => '---',
				'Variedade_de_Produto__c' => 'Total'
			}
		);
	}

	public static String parseNullToString(String parsedString) {
		return parsedString == null ? '' : parsedString;
	}

	public List<aSiteUtils.myOppRepItem> getRepItemsSale() {
		if (tmpAppItemsSale == null || tmpAppItemsSale.size() == 0)
			queryOrigItemsFinalReport();

		return tmpAppItemsSale;
	}

	public boolean queryOrigItemsFinalReport() {
		//Arma la grilla de productos activados para nuevo anexo 2, resuelvo items custom para edicion en sitio
		try {
			List<aSiteUtils.myOppRepItem> tmpItems = new List<aSiteUtils.myOppRepItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			Map<String, Item_del_Contrato__c> mapSchedule = new Map<String, Item_del_Contrato__c>();
			Item_del_Contrato__c itemS = new Item_del_Contrato__c();

			if (editId != null) {
				tmpOppItems = aAppManager.getAnexosItemsByOpp(editId);
			} else {
				mapSchedule = aAppManager.getMapSchedules(
					activeAccount.Id,
					activeSession.Sales_season__c,
					activeSession.Marca__c
				);
				if (activeSession.Marca__c == 'DONMARIO') {
					tmpOppItems = aAppManager.getItemsToForecastUp5Rep(
						activeAccount.Id,
						activeSession.Sales_season__c,
						activeSession.Marca__c
					);
				} else {
					tmpOppItems = aAppManager.getItemsToFinalSalesRep(
						activeAccount.Id,
						activeSession.Sales_season__c,
						activeSession.Marca__c
					);
				}
			}

			for (OpportunityLineItem s : tmpOppItems) {
				aSiteUtils.myOppRepItem oli = new aSiteUtils.myOppRepItem();

				if (mapSchedule.containsKey(s.Variedade_de_Produto__c)) {
					itemS = mapSchedule.get(s.Variedade_de_Produto__c);
					if (!itemS.active__c)
						continue;
					oli.license = Date.valueOF(itemS.Contrato_de_Multiplicacion__r.License_Date__c);
					oli.variedad_licencia_id = String.valueOF(itemS.Licensee_Variety_ID__c);
					oli.precio = Double.valueOf(items.Precio__c);
					oli.royalty_rate = items.Precio__c; //Double.valueOf(items.Precio__c);
				}

				oli.variedad = s.Variedade_de_Produto__c;
				oli.variedad_registro = s.Variety_Number__c;
				oli.categoria = s.Categoria__r.Name;
				oli.brand = s.Brand_Name__c;
				oli.categoria_id = s.Categoria__c;
				if (s.Wholesale_Sales__c != null && s.Wholesale_Sales__c >= 1)
					oli.ws_out = Integer.valueOf(s.Wholesale_Sales__c);

				if (s.Unconditioned_Bushels__c != null)
					oli.parent_purchased = Integer.valueOf(s.Unconditioned_Bushels__c);

				oli.test_purchased = 0;
				if (s.Test_Seed_Purchases__c != null)
					oli.test_purchased = Double.valueOf(s.Test_Seed_Purchases__c);

				if (s.Product_Purchased__c != null && s.Product_Purchased__c >= 1)
					oli.ws_in = Integer.valueOf(s.Product_Purchased__c);

				if (s.Total_Replant_Claim__c != null && s.Total_Replant_Claim__c >= 1)
					oli.replants = Integer.valueOf(s.Total_Replant_Claim__c);

				if (editId != null) {
					//if (s.Sales_Report_Type__c == 'Sale'){
					oli.id = s.Id;
					if (s.Licensee_Variety_Name__c != null)
						oli.variedad_licencia_id = s.Licensee_Variety_Name__c;
					if (s.Comments__c != null)
						oli.comentarios = s.Comments__c;

					if (s.Date_dropped__c != null)
						oli.drop = s.Date_dropped__c;
					if (s.Date_Licensed__c != null)
						oli.license = s.Date_Licensed__c;

					if (s.Test_Plots_Units__c != null)
						oli.test = Integer.valueOf(s.Test_Plots_Units__c);
					if (s.Parent_Seed_Purchases__c != null)
						oli.parent_purchased = Integer.valueOf(s.Parent_Seed_Purchases__c);
					if (s.Product_Purchased__c != null && s.Product_Purchased__c >= 1)
						oli.ws_in = Integer.valueOf(s.Product_Purchased__c);
					if (s.Wholesale_Sales__c != null && s.Wholesale_Sales__c >= 1)
						oli.ws_out = Integer.valueOf(s.Wholesale_Sales__c);
					if (s.Semente_Uso_propio__c != null)
						oli.used = Integer.valueOf(s.Semente_Uso_propio__c);
					if (s.Semente_comercializada__c != null)
						oli.comm_sales = Integer.valueOf(s.Semente_comercializada__c);
					if (s.Unit_Totals__c != null)
						oli.total = Integer.valueOf(s.Unit_Totals__c);
					if (s.Total_Replant_Claim__c != null && s.Total_Replant_Claim__c >= 1)
						oli.replants = Integer.valueOf(s.Total_Replant_Claim__c);
					if (s.Descarte__c != null)
						oli.discarded_bushels = Integer.valueOf(s.Descarte__c);
					if (s.Royalty_rate__c != null)
						oli.royalty_rate = Double.valueOf(s.Royalty_Rate__c);
				}

				//mapAuxList.put(oli.variedad,oli);
				tmpItems.add(oli);
			}

			//mapAuxList.sort();
			tmpAppItemsSale = tmpItems;

			return true;
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getLineNumber() + '\n' + e.getMessage()));
			return false;
		}
	}

	public List<aSiteUtils.myOppRepItem> getRepItemsForecast() {
		//Arma la grilla de productos para reportes 1,2,3,4. Resuelvo items segun el reporte previo en cada caso
		try {
			List<aSiteUtils.myOppRepItem> tmpItems = new List<aSiteUtils.myOppRepItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			Map<String, OpportunityLineItem> mapOppApp = new Map<String, OpportunityLineItem>();
			Map<String, OpportunityLineItem> mapOppProd = new Map<String, OpportunityLineItem>();
			Map<String, Item_del_Contrato__c> mapSchedule = new Map<String, Item_del_Contrato__c>();
			Map<String, OpportunityLineItem> productsFromPreviousStages = lookForProductionFinalReportProducts();
			if (editId != null) {
				//Si el reporte tiene id es porque ya existe y esta siendo editado
				tmpOppItems = aAppManager.getAnexosItemsByOpp(editId);
			} else {
				//Si no tiene Id, es porque es un nuevo reporte, y hay que completar la data desde reportes previos.
				mapSchedule = aAppManager.getMapSchedules(
					activeAccount.Id,
					activeSession.Sales_season__c,
					activeSession.Marca__c
				);
				mapOppApp = aAppManager.getMapFore2Rep(activeAccount.Id, activeSession.Sales_season__c, activeSession.Marca__c);

				if (activeSession.Marca__c == 'DONMARIO') {
					if (repType == 'up1')
						tmpOppItems = aAppManager.getItemsSales1_DM(
							activeAccount.Id,
							activeSession.Sales_season__c,
							activeSession.Marca__c
						); //pulls from prod rep aug
					if (
						repType == 'up2' // April
					)
						tmpOppItems = aAppManager.getItemsSales2_DM(
							activeAccount.Id,
							activeSession.Sales_season__c,
							activeSession.Marca__c
						); //pulls from sales rep 1 + sales ***revisar
					if (
						repType == 'up3' //June
					)
						tmpOppItems = aAppManager.getItemsSales3_DM(
							activeAccount.Id,
							activeSession.Sales_season__c,
							activeSession.Marca__c
						); //pulls from sales rep 2
					if (
						repType == 'up4' //July
					)
						tmpOppItems = aAppManager.getItemsSales4_DM(
							activeAccount.Id,
							activeSession.Sales_season__c,
							activeSession.Marca__c
						); //pulls from sales rep 3
				} else {
					mapOppProd = aAppManager.getMapProd1Rep(
						activeAccount.Id,
						activeSession.Sales_season__c,
						activeSession.Marca__c
					);
					if (repType == 'up1')
						tmpOppItems = aAppManager.getItemsSales1(
							activeAccount.Id,
							activeSession.Sales_season__c,
							activeSession.Marca__c
						); //pulls from prod rep 2
					if (
						repType == 'up2' // April
					)
						tmpOppItems = aAppManager.getItemsSales2(
							activeAccount.Id,
							activeSession.Sales_season__c,
							activeSession.Marca__c
						); //pulls from Prod Rep 3 Dec + sales
				}
			}

			OpportunityLineItem itemS = new OpportunityLineItem();
			Item_del_Contrato__c itemC = new Item_del_Contrato__c();

			for (OpportunityLineItem s : tmpOppItems) {
				aSiteUtils.myOppRepItem oli = new aSiteUtils.myOppRepItem();
				itemS = new OpportunityLineItem();
				OpportunityLineItem productFromPreviousStage;
				if (productsFromPreviousStages.containsKey(s.Variedade_de_Produto__c)) {
					productFromPreviousStage = productsFromPreviousStages.get(s.Variedade_de_Produto__c);
				}

				oli.variedad = s.Variedade_de_Produto__c;
				oli.variedad_registro = s.Variety_Number__c;

				if (editId != null) {
					//Es una edicion, levanto datos del mismo reporte
					oli.id = s.Id;

					if (s.Licensee_Variety_Name__c != null)
						oli.variedad_licencia_id = s.Licensee_Variety_Name__c;
					if (s.Semente_Uso_propio__c != null)
						oli.used = Integer.valueOf(s.Semente_Uso_propio__c);
					if (s.forecast_quantity__c != null)
						oli.forecast_quantity = Integer.valueOF(s.forecast_quantity__c);
					if (s.Prev_Forecast__c != null)
						oli.forecast_prev = Integer.valueOf(s.Prev_Forecast__c);
					if (s.Current_Sale_140k_Units__c != null)
						oli.comm_sales = Integer.valueOf(s.Current_Sale_140k_Units__c);
					if (s.Semente_beneficiada__c != null)
						oli.conditioned_140k = Integer.valueOf(s.Semente_beneficiada__c);
					if (s.Product_Purchased__c != null && s.Product_Purchased__c >= 1)
						oli.ws_in = Integer.valueOf(s.Product_Purchased__c);
					if (s.Wholesale_Sales__c != null && s.Wholesale_Sales__c >= 1)
						oli.ws_out = Integer.valueOf(s.Wholesale_Sales__c);
					if (s.Total_Replant_Claim__c != null && s.Total_Replant_Claim__c >= 1)
						oli.replants = integer.valueOf(s.Total_Replant_Claim__c);
					if (productFromPreviousStage != null) {
						oli.production_area = Integer.valueOf(productFromPreviousStage.Area_Plantada__c);
					} else {
						oli.production_area = Integer.valueOf(s.Area_Plantada__c);
					}
					if (productFromPreviousStage != null) {
						oli.production_bushels = Integer.valueOf(productFromPreviousStage.Semente_bruta__c);
					} else {
						oli.production_bushels = Integer.valueOf(s.Semente_bruta__c);
					}
				} else {
					//Es un nuevo reporte, y tengo que popular los campos

					if (mapSchedule.containsKey(s.Variedade_de_Produto__c)) {
						//busco datos complementarios en los schedules A
						itemC = mapSchedule.get(s.Variedade_de_Produto__c);
						if (!itemC.active__c)
							continue;
						oli.license = Date.valueOF(itemC.Contrato_de_Multiplicacion__r.License_Date__c);
						oli.variedad_licencia_id = String.valueOF(itemC.Licensee_Variety_ID__c);
						oli.precio = Double.valueOf(itemC.Precio__c);
						oli.royalty_rate = itemC.Precio__c;
					}

					// Datos del reporte anterior
					if (mapOppApp.containsKey(s.Variedade_de_Produto__c)) {
						itemS = mapOppApp.get(s.Variedade_de_Produto__c);
						oli.forecast_quantity = Integer.valueOF(itemS.forecast_quantity__c);
						oli.forecast_prev = Integer.valueOF(itemS.forecast_quantity__c); //prev field for validation SR2
					}
					// Datos del reporte de produccion anterior
					if (mapOppProd.containsKey(s.Variedade_de_Produto__c)) {
						itemS = mapOppProd.get(s.Variedade_de_Produto__c);
						oli.production_area = Integer.valueOf(itemS.Area_Plantada__c);
						oli.production_bushels = Integer.valueOf(itemS.Semente_bruta__c);
					}
					//tengo que ver como obtengo la data del reporte de venta anterior, pero si es un rep de produccion, tambien ver acres y bushels

					oli.categoria = s.Categoria__r.Name;
					oli.brand = s.Brand_Name__c;
					oli.categoria_id = s.Categoria__c;
					if (productFromPreviousStage != null) {
						oli.production_area = Integer.valueOf(productFromPreviousStage.Area_Plantada__c);
					} else {
						oli.production_area = Integer.valueOf(s.Area_Plantada__c);
					}
					if (productFromPreviousStage != null) {
						oli.production_bushels = Integer.valueOf(productFromPreviousStage.Semente_bruta__c);
					} else {
						oli.production_bushels = Integer.valueOf(s.Semente_bruta__c);
					}
					oli.forecast_quantity = Integer.valueOf(s.forecast_quantity__c);
					oli.forecast_prev = Integer.valueOf(s.forecast_quantity__c);
					oli.comm_sales = Integer.valueOf(s.Current_Sale_140k_Units__c);
					oli.ws_in = s.Product_Purchased__c >= 1 ? Integer.valueOf(s.Product_Purchased__c) : null;
					oli.ws_out = s.Wholesale_Sales__c >= 1 ? Integer.valueOf(s.Wholesale_Sales__c) : null;
					oli.replants = s.Total_Replant_Claim__c >= 1 ? Integer.valueOf(s.Total_Replant_Claim__c) : null;
				}

				tmpItems.add(oli);
			}

			tmpAppItemsForecast = tmpItems;

			return tmpItems;
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getLineNumber() + '\n' + e.getMessage()));
			return tmpAppItems;
		}
	}

	public PageReference submitSalesReport() {
		PageReference pr = new PageReference('/apex/aSiteSalesReport');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', repType);
		try {
			Opportunity opp = new Opportunity();
			opp.Stagename = 'Sent';
			opp.Id = editId;
			update opp;
			System.debug('JERE::Save10');
			//Commented because email sending is not enabled in sandbox enviroments
			// aAppManager.sendNotification(new List<String>{ logUser.Email__c }, 'success');
		} catch (Exception ex) {
			System.debug(ex.getStackTraceString());
			System.debug(ex.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getLineNumber() + '\n' + ex.getMessage()));
			//Commented because email sending is not enabled in sandbox enviroments
			// aAppManager.sendNotification(new List<String>{ logUser.Email__c }, 'error');
		}

		return pr;
	}

	public PageReference saveSalesReport() {
		if (save()) {
			PageReference pr = new PageReference('/apex/aSiteSalesReport');
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
		System.debug('JERE::Save');
		//return true;

		try {
			List<OpportunityLineItem> saveOppItems = new List<OpportunityLineItem>();

			String msg = '';
			rt_A3 = rty.get(ANEXO_RECORDTYPE);
			rPb = Opp_Utils.cargarRoyaltyPricebookEntries(ANEXO_LP);
			System.debug('JERE::Save1');
			if (tmpAppItemsSale != null) {
				for (aSiteUtils.myOppRepItem tmp : tmpAppItemsSale) {
					OpportunityLineItem item = new OpportunityLineItem();

					//Read only
					item.Quantity = 0.1;
					if (tmp.royalty_rate != null)
						item.UnitPrice = tmp.royalty_rate;
					else
						item.UnitPrice = 1;
					if (rPb.get(tmp.variedad) != null)
						item.PricebookEntryId = rPb.get(tmp.variedad).Id;
					item.Categoria__c = tmp.categoria_id;
					item.Description = tmp.comentarios;
					Date y = Date.valueOf(tmp.license);
					item.Date_licensed__c = y;
					item.Parent_Seed_Purchases__c = tmp.parent_purchased;
					item.Test_Seed_Purchases__c = tmp.test_purchased;

					//Input by user
					item.Licensee_Variety_Name__c = tmp.variedad_licencia_id;
					Date x = Date.valueOf(tmp.drop);
					item.Date_dropped__c = x;
					item.Product_Purchased__c = tmp.ws_in;
					item.Wholesale_Sales__c = tmp.ws_out;
					item.Semente_comercializada__c = tmp.comm_sales;
					item.Semente_Uso_propio__c = tmp.used;
					item.Test_Plots_Units__c = tmp.test;
					item.Total_Replant_Claim__c = tmp.replants;
					item.Descarte__c = tmp.discarded_bushels;
					item.Comments__c = tmp.comentarios;
					item.Royalty_Rate__c = tmp.royalty_rate;

					if (tmp.id != null && tmp.Id != '')
						item.Id = tmp.Id;

					saveOppItems.add(item);
				}
			}
			System.debug('JERE::Save2');
			if (tmpAppItemsForecast != null) {
				for (aSiteUtils.myOppRepItem tmp : tmpAppItemsForecast) {
					OpportunityLineItem item = new OpportunityLineItem();

					item.Quantity = 0.1;
					item.UnitPrice = 1;
					if (rPb.get(tmp.variedad) != null)
						item.PricebookEntryId = rPb.get(tmp.variedad).Id;
					item.Categoria__c = tmp.categoria_id;

					if (repType == 'up2' || repType == 'up1' || repType == 'up3' || repType == 'up4') {
						item.Licensee_Variety_Name__c = tmp.variedad_licencia_id;
						item.Forecast_quantity__c = tmp.forecast_quantity;
						item.Prev_Forecast__c = tmp.forecast_prev;
						//item.Semente_comercializada__c = tmp.comm_sales;
						item.Current_Sale_140k_Units__c = tmp.comm_sales;
						if (activeSession.Marca__c != 'DONMARIO') {
							item.Area_Plantada__c = tmp.production_area;
							item.Semente_bruta__c = tmp.production_bushels;
						}
						item.Semente_Uso_propio__c = tmp.used;
						item.Semente_beneficiada__c = tmp.conditioned_140k;
						item.Product_Purchased__c = tmp.ws_in;
						item.Wholesale_Sales__c = tmp.ws_out;
						item.Total_Replant_Claim__c = tmp.replants;

						item.Royalty_Rate__c = tmp.royalty_rate;
					}

					if (tmp.id != null && tmp.Id != '')
						item.Id = tmp.Id;

					saveOppItems.add(item);
				}
			}
			System.debug('JERE::Save3');
			Account_Reference__mdt GDMAccount = [SELECT Id, AccountId__c FROM Account_Reference__mdt WHERE Label = 'B&B'];
			if (editId == null) {
				//insert
				tmpAppII = new Opportunity(
					Name = 'TMP',
					SiteUser__c = logUser.Id,
					Type = type,
					Stagename = 'Editable',
					CloseDate = System.today(),
					RecordTypeId = rt_A3,
					AccountId = activeAccount.Id,
					Safra__c = activeSession.Sales_season__c,
					Marca__c = activeSession.Marca__c,
					Filled__c = filledOpportunity
				);
				if (activeSession.Marca__c == 'DONMARIO' && activeAccount.Id != GDMAccount.AccountId__c)
					tmpAppII.Company__c = 'B&B';
				insert tmpAppII;
				editId = tmpAppII.Id;
				for (OpportunityLineItem item : saveOppItems)
					item.OpportunityId = tmpAppII.Id;
				System.debug('JERE::Save4');
				insert saveOppItems;
			} else {
				update saveOppItems;
				System.debug('JERE::Save5');
			}
			if (filledOpportunity && editId != null) {
				Opportunity filledOpp = new Opportunity();
				filledOpp.Id = editId;
				filledOpp.Filled__c = true;
				update filledOpp;
			}
			System.debug(msg);
		} catch (Exception e) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getLineNumber() + '\n' + e.getMessage()));
			return false;
		}
		update activeSession;
		System.debug('JERE::Save6');
		return true;
	}

	public Map<String, OpportunityLineItem> lookForProductionFinalReportProducts() {
		List<OpportunityLineItem> productsFromFinalProdReport = new List<OpportunityLineItem>();
		List<OpportunityLineItem> productsFromProductionForecastUpdate = new List<OpportunityLineItem>();
		Map<String, OpportunityLineItem> finalProdReportProductsByVariety = new Map<String, OpportunityLineItem>();
		Map<String, OpportunityLineItem> productionForecastUpdateProductsByVariety = new Map<String, OpportunityLineItem>();
		List<Opportunity> finalProductionReports;
		Opportunity finalProductionReport;
		List<Opportunity> productionForecastUpdates;
		Opportunity productionForecastUpdate;

		if (relatedApp == null) {
			relatedApp = aAppManager.getSalesReportOpp(
				activeAccount.Id,
				activeSession.Sales_Season__c,
				activeSession.Marca__c,
				type
			);
		}
		// If final sales report (FSR) was sent before sales forecast update 2 (SFU2), it should fill values of SFU2 with values from FSR.
		if (
			repType == 'up2' &&
			relatedApp != null &&
			relatedApp.size() > 0 &&
			relatedApp[0].Filled__c == false &&
			(relatedApp[0].StageName != 'Approved' ||
			relatedApp[0].StageName != 'Sent')
		) {
			finalProductionReports = aAppManager.getProductionReportOpp(
				activeAccount.Id,
				activeSession.Safra__c,
				activeSession.Marca__c,
				'Final Production Report'
			);
			if (
				!finalProductionReports.isEmpty() &&
				(finalProductionReports[0].StageName == 'Sent' ||
				finalProductionReports[0].StageName == 'Approved')
			) {
				finalProductionReport = finalProductionReports[0];
				productsFromFinalProdReport = aAppManager.getAnexosItemsByOpp(finalProductionReport.Id);
				for (OpportunityLineItem product : productsFromFinalProdReport) {
					if (!finalProdReportProductsByVariety.containsKey(product.Variedade_de_Produto__c)) {
						finalProdReportProductsByVariety.put(product.Variedade_de_Produto__c, product);
					}
				}
			} else {
				productionForecastUpdates = aAppManager.getProductionReportOpp(
					activeAccount.Id,
					activeSession.Safra__c,
					activeSession.Marca__c,
					'Production Update 3'
				);
				if (
					!productionForecastUpdates.isEmpty() &&
					(productionForecastUpdates[0].StageName == 'Sent' ||
					productionForecastUpdates[0].StageName == 'Approved')
				) {
					productionForecastUpdate = productionForecastUpdates[0];
					productsFromProductionForecastUpdate = aAppManager.getAnexosItemsByOpp(productionForecastUpdate.Id);
					for (OpportunityLineItem product : productsFromProductionForecastUpdate) {
						if (!productionForecastUpdateProductsByVariety.containsKey(product.Variedade_de_Produto__c)) {
							productionForecastUpdateProductsByVariety.put(product.Variedade_de_Produto__c, product);
						}
					}
				}
			}
		}

		if (!finalProdReportProductsByVariety.isEmpty() || !productionForecastUpdateProductsByVariety.isEmpty()) {
			filledOpportunity = true;
		}
		return finalProdReportProductsByVariety.isEmpty()
			? productionForecastUpdateProductsByVariety
			: finalProdReportProductsByVariety;
	}

	public List<Schema.FieldSetMember> getFields() {
		if (activeSession.Marca__c == 'DONMARIO') {
			if (repType == 'up1')
				return SObjectType.OpportunityLineItem.FieldSets.Sales_1_DM.getFields();
			if (repType == 'up2')
				return SObjectType.OpportunityLineItem.FieldSets.Sales_2_DM.getFields();
			if (repType == 'up3')
				return SObjectType.OpportunityLineItem.FieldSets.Sales_3_DM.getFields();
			if (repType == 'up4')
				return SObjectType.OpportunityLineItem.FieldSets.Sales_4_DM.getFields();
			if (repType == 'fi')
				return SObjectType.OpportunityLineItem.FieldSets.Sales_Report_DM.getFields();
		} else {
			if (repType == 'up1')
				return SObjectType.OpportunityLineItem.FieldSets.Sales_1.getFields();
			if (repType == 'up2')
				return SObjectType.OpportunityLineItem.FieldSets.Sales_2.getFields();
			if (repType == 'fi')
				return SObjectType.OpportunityLineItem.FieldSets.Sales_Report.getFields();
		}
		return null;
	}

	public PageReference gotoEdit() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr = new PageReference('/apex/aSiteSalesReportEdit');
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

		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr = new PageReference('/apex/aSiteSalesReportEdit');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', repType);
		return pr;
	}

	public PageReference editCancel() {
		PageReference pr = new PageReference('/apex/aSiteSalesReport');
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