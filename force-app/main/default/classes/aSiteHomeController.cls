global class aSiteHomeController {
	private String token;
	private SiteUser__c logUser;
	private SiteUserSession__c activeSession;
	private Account activeAccount;
	private Configuracion_USA__c settings;
	public string language { get; set; }
	private Integer prod = 0;
	public String reportingMonth { get; set; }
	public String reportingMessage { get; set; }
	public String brand { get; set; }
	public String gposTemplateLink { get; set; }

	global aSiteHomeController() {
		language = [SELECT id, LanguageLocaleKey FROM User WHERE id = :UserInfo.getUserId()].LanguageLocaleKey;
		Configuracion_USA__c[] confs = aSiteUtils.queryResults1(Configuracion_USA__c.SObjectType, null, 'Id <> :v1', '');
		if (confs.size() > 0) {
			settings = confs[0];
		}
	}

	public PageReference validate() {
		token = System.currentPageReference().getParameters().get('token');
		if (token != null) {
			logUser = aSiteAuthManager.VerifyUserSession(token);
			if (logUser != null) {
				activeSession = aSiteAuthManager.getUserSession(token);
				activeAccount = aSiteAuthManager.getActiveAccount_byUser(logUser);
				brand = activeSession.Marca__c;
				// Date decemberCycle = Date.newInstance(2022, 11, 15);
				// Date aprilCycle = Date.newInstance(2022, 3, 15);
				// Date mayCycle = Date.newInstance(2022, 5, 1);
				// Date julyCycle = Date.newInstance(2022, 6, 25);
				// Date augustCycle = Date.newInstance(2022, 7, 27);
				setReportingActions(Date.today());
				return null;
			}
		}

		PageReference p = new PageReference('/apex/aSiteLogin');
		p.setRedirect(true);
		return p;
	}

	public String getTotalProduction() {
		String value = '';
		String recId = '';
		Integer data = 0;

		Opportunity[] relatedApp = aAppManager.getProductionReportOpp(
			activeAccount.Id,
			activeSession.safra__c,
			activeSession.Marca__c,
			'Final Production Report'
		);
		if (relatedApp.size() > 0) {
			recId = relatedApp[0].Id;
		}

		if (recId == '') {
			relatedApp = aAppManager.getProductionReportOpp(
				activeAccount.Id,
				activeSession.safra__c,
				activeSession.Marca__c,
				'Production Update 5'
			);
			if (relatedApp.size() > 0) {
				recId = relatedApp[0].Id;
			}
		}
		if (recId == '') {
			relatedApp = aAppManager.getProductionReportOpp(
				activeAccount.Id,
				activeSession.safra__c,
				activeSession.Marca__c,
				'Production Update 4'
			);
			if (relatedApp.size() > 0) {
				recId = relatedApp[0].Id;
			}
		}
		if (recId == '') {
			relatedApp = aAppManager.getProductionReportOpp(
				activeAccount.Id,
				activeSession.safra__c,
				activeSession.Marca__c,
				'Production Update 3'
			);
			if (relatedApp.size() > 0) {
				recId = relatedApp[0].Id;
			}
		}
		if (recId == '') {
			relatedApp = aAppManager.getProductionReportOpp(
				activeAccount.Id,
				activeSession.safra__c,
				activeSession.Marca__c,
				'Production Update 2'
			);
			if (relatedApp.size() > 0) {
				recId = relatedApp[0].Id;
			}
		}

		List<OpportunityLineItem> relatedAppItems = new List<OpportunityLineItem>();

		if (recId != '')
			relatedAppItems = aAppManager.getAnexosItemsByOpp(recId);

		for (OpportunityLineItem s : relatedAppItems) {
			if (s.Semente_bruta__c != null)
				data = data + Integer.valueOf(s.Semente_bruta__c);
		}

		if (data != null)
			prod = data;

		value = String.valueOf(data);
		value = formatNumberString(value);

		return value;
	}

	public String formatNumberString(String value) {
		if (value != '') {
			String[] valueDecimal;
			if (value.contains('.'))
				valueDecimal = value.split('.');
			else {
				valueDecimal = new List<String>{ value };
			}
			System.debug(valueDecimal + ' ' + value);
			value = '';

			if (valueDecimal[0].length() > 3) {
				List<String> charList = valueDecimal[0].split('');
				Integer modValue = Math.mod(charList.size(), 3);
				for (Integer i = 0; i < charList.size(); i++) {
					if (modValue > 0) {
						modValue--;
						value += charList[i];
					} else {
						if (i != 0) {
							value += ',';
						}
						value += charList[i];
						modValue += 2;
					}
				}
			}
			if (valueDecimal.size() > 1) {
				value += '.' + valueDecimal[1];
			}
		}
		if (value == '')
			value = '0';
		return value;
	}

	public String getDiffProduction() {
		String value = '';
		String recId;
		String recId2;
		Decimal dataAct = 0;
		List<OpportunityLineItem> relatedAppItems = new List<OpportunityLineItem>();

		if (prod == 0) {
			Opportunity[] relatedApp = aAppManager.getProductionReportOpp(
				activeAccount.Id,
				activeSession.safra__c,
				activeSession.Marca__c,
				'Final Production Report'
			);
			if (relatedApp.size() > 0) {
				recId = relatedApp[0].Id;
			}

			relatedAppItems = aAppManager.getAnexosItemsByOpp(recId);
			for (OpportunityLineItem s : relatedAppItems) {
				if (s.Semente_bruta__c != null)
					dataAct = dataAct + Integer.valueOf(s.Semente_bruta__c);
			}
		} else
			dataAct = prod;

		Opportunity[] relatedApp2 = aAppManager.getProductionReportOpp(
			activeAccount.Id,
			activeSession.Last_season__c,
			activeSession.Marca__c,
			'Final Production Report'
		);
		Decimal dataOld = 0;

		if (relatedApp2.size() > 0) {
			recId2 = relatedApp2[0].Id;
		}

		relatedAppItems = new List<OpportunityLineItem>();
		relatedAppItems = aAppManager.getAnexosItemsByOpp(recId2);

		for (OpportunityLineItem s : relatedAppItems) {
			if (s.Semente_bruta__c != null)
				dataOld = dataOld + Integer.valueOf(s.Semente_bruta__c);
		}

		Integer valor = 0;

		if (dataOld == 0)
			valor = 0;
		else
			valor = Integer.valueOf((dataAct - dataOld) / dataOld * 100);

		return String.valueOf(valor) + ' %';
	}

	public String getTotalSold() {
		String value = '';
		String recId;
		Opportunity[] relatedApp = aAppManager.getSalesReportOpp(
			activeAccount.Id,
			activeSession.last_season__c,
			activeSession.Marca__c,
			'Final Sales Report'
		);
		Integer data = 0;

		if (relatedApp.size() > 0) {
			recId = relatedApp[0].Id;
		}

		List<OpportunityLineItem> relatedAppItems = new List<OpportunityLineItem>();
		relatedAppItems = aAppManager.getAnexosItemsByOpp(recId);

		for (OpportunityLineItem s : relatedAppItems) {
			if (s.Unit_Totals__c != null)
				data = data + Integer.valueOf(s.Unit_Totals__c);
		}

		value = String.valueOf(data);
		value = formatNumberString(value);
		return value;
	}
	public String getDiffSold() {
		String value = '';
		value = String.valueOf(0) + '%';
		return value;
	}

	public String getTotalForecast() {
		String value = '';
		String recId = '';
		Integer data = 0;

		Opportunity[] relatedApp = aAppManager.getSalesReportOpp(
			activeAccount.Id,
			activeSession.Safra__c,
			activeSession.Marca__c,
			'Sales Forecast Update 2'
		);
		if (relatedApp.size() > 0) {
			recId = relatedApp[0].Id;
		}

		if (recId == '') {
			relatedApp = aAppManager.getSalesReportOpp(
				activeAccount.Id,
				activeSession.safra__c,
				activeSession.Marca__c,
				'Sales Forecast Update 1'
			);
			if (relatedApp.size() > 0) {
				recId = relatedApp[0].Id;
			}
		}

		List<OpportunityLineItem> relatedAppItems = new List<OpportunityLineItem>();
		if (recId != '')
			relatedAppItems = aAppManager.getAnexosItemsByOpp(recId);

		for (OpportunityLineItem s : relatedAppItems) {
			if (s.forecast_quantity__c != null)
				data = data + Integer.valueOf(s.forecast_quantity__c);
		}

		value = String.valueOf(data);
		value = formatNumberString(value);
		return value;
	}
	public String getDiffFore() {
		String value = '';
		String recId;
		String recId2 = '';
		Opportunity[] relatedApp = aAppManager.getSalesReportOpp(
			activeAccount.Id,
			activeSession.last_season__c,
			activeSession.Marca__c,
			'Final Sales Report'
		);
		Decimal dataAct = 0;

		if (relatedApp.size() > 0) {
			recId = relatedApp[0].Id;
		}

		List<OpportunityLineItem> relatedAppItems = new List<OpportunityLineItem>();
		relatedAppItems = aAppManager.getAnexosItemsByOpp(recId);

		for (OpportunityLineItem s : relatedAppItems) {
			if (s.Unit_Totals__c != null)
				dataAct = dataAct + Integer.valueOf(s.Unit_Totals__c);
		}

		Integer dataFore = 0;

		Opportunity[] relatedApp2 = aAppManager.getSalesReportOpp(
			activeAccount.Id,
			activeSession.Safra__c,
			activeSession.Marca__c,
			'Sales Forecast Update 2'
		);
		if (relatedApp2.size() > 0) {
			recId2 = relatedApp2[0].Id;
		}

		if (recId2 == '') {
			relatedApp2 = aAppManager.getSalesReportOpp(
				activeAccount.Id,
				activeSession.safra__c,
				activeSession.Marca__c,
				'Sales Forecast Update 1'
			);
			if (relatedApp2.size() > 0) {
				recId2 = relatedApp2[0].Id;
			}
		}

		relatedAppItems = new List<OpportunityLineItem>();
		if (recId2 != '')
			relatedAppItems = aAppManager.getAnexosItemsByOpp(recId2);

		for (OpportunityLineItem s : relatedAppItems) {
			if (s.forecast_quantity__c != null)
				dataFore = dataFore + Integer.valueOf(s.forecast_quantity__c);
		}
		if (dataAct == 0)
			value = '0';
		else
			value = String.valueOf(Integer.valueOf((dataFore - dataAct) * 100 / dataAct));

		value = value + '%';
		return value;
	}

	// -*--------------------- Sales Reports ------------------------------------------------------------------

	public PageReference gotoSalesForeUpdate1Report() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr;
		String type = 'Sales Forecast Update 1';
		Opportunity[] relatedApp = aAppManager.getSalesReportOpp(
			activeAccount.Id,
			activeSession.Sales_Season__c,
			activeSession.Marca__c,
			type
		);
		if (relatedApp.size() == 0)
			pr = new PageReference('/apex/aSiteSalesReportEdit');
		else
			pr = new PageReference('/apex/aSiteSalesReport');
		String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Sales 1, ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'up1');
		return pr;
	}
	public PageReference gotoSales2() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr;
		String type = 'Sales Forecast Update 2';
		Opportunity[] relatedApp = aAppManager.getSalesReportOpp(
			activeAccount.Id,
			activeSession.Sales_Season__c,
			activeSession.Marca__c,
			type
		);
		if (relatedApp.size() == 0)
			pr = new PageReference('/apex/aSiteSalesReportEdit');
		else
			pr = new PageReference('/apex/aSiteSalesReport');
		String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Sales 2, ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'up2');
		return pr;
	}
	public PageReference gotoSales3() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr;
		String type = 'Sales Forecast Update 3';
		Opportunity[] relatedApp = aAppManager.getSalesReportOpp(
			activeAccount.Id,
			activeSession.Sales_Season__c,
			activeSession.Marca__c,
			type
		);
		if (relatedApp.size() == 0)
			pr = new PageReference('/apex/aSiteSalesReportEdit');
		else
			pr = new PageReference('/apex/aSiteSalesReport');
		String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Sales 3, ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'up3');
		return pr;
	}
	public PageReference gotoSales4() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr;
		String type = 'Sales Forecast Update 4';
		Opportunity[] relatedApp = aAppManager.getSalesReportOpp(
			activeAccount.Id,
			activeSession.Sales_Season__c,
			activeSession.Marca__c,
			type
		);
		if (relatedApp.size() == 0)
			pr = new PageReference('/apex/aSiteSalesReportEdit');
		else
			pr = new PageReference('/apex/aSiteSalesReport');
		String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Sales 4, ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'up4');
		return pr;
	}
	public PageReference gotoSalesReport() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr;
		String type = 'Final Sales Report';
		Opportunity[] relatedApp = aAppManager.getSalesReportOpp(
			activeAccount.Id,
			activeSession.Sales_Season__c,
			activeSession.Marca__c,
			type
		);
		if (relatedApp.size() == 0)
			pr = new PageReference('/apex/aSiteSalesReportEdit');
		else
			pr = new PageReference('/apex/aSiteSalesReport');
		String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Sales Final, ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'fi');
		return pr;
	}

	public PageReference gotoSalesUpdate3Report() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr = new PageReference('/apex/aSiteSalesReport');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'up3');
		return pr;
	}

	// *-----------------------Production Reports -------------------------------------------------------------

	public PageReference gotoProd1() {
		String token = System.currentPageReference().getParameters().get('token');
		String type = 'Production Update 1';
		PageReference pr;
		if (
			aAppManager.getProductionReportOpp(
					activeAccount.Id,
					activeSession.Production_season__c,
					activeSession.Marca__c,
					type
				)
				.size() == 0
		) {
			pr = new PageReference('/apex/aSiteProductionReportEdit');
		} else {
			pr = new PageReference('/apex/aSiteProductionReport');
		}
		String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Production 1, ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'up1');
		return pr;
	}
	public PageReference gotoProd2() {
		String token = System.currentPageReference().getParameters().get('token');
		String type = 'Production Update 2';
		PageReference pr;
		if (
			aAppManager.getProductionReportOpp(
					activeAccount.Id,
					activeSession.Production_season__c,
					activeSession.Marca__c,
					type
				)
				.size() == 0
		) {
			pr = new PageReference('/apex/aSiteProductionReportEdit');
		} else {
			pr = new PageReference('/apex/aSiteProductionReport');
		}
		String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Production 2, ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'up2');
		return pr;
	}
	//gotoProdUpdateDecReport

	public PageReference gotoProdUpdateDecReport() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr;

		String type;
		if (activeSession.Marca__c == 'DONMARIO')
			type = 'Production Update 5';
		else
			type = 'Production Update 3';

		if (
			aAppManager.getProductionReportOpp(activeAccount.Id, activeSession.Sales_Season__c, activeSession.Marca__c, type)
				.size() == 0
		) {
			pr = new PageReference('/apex/aSiteProductionReportEdit');
		} else {
			pr = new PageReference('/apex/aSiteProductionReport');
		}

		String ret = aSiteAuthManager.RefreshUserSessionLog(token, type + ', ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		if (activeSession.Marca__c == 'DONMARIO')
			pr.getParameters().put('t', 'up5');
		else
			pr.getParameters().put('t', 'up3');
		return pr;
	}

	public PageReference gotoProdUpdateAugReport() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr;

		String type;
		String season = activeSession.Production_season__c;

		if (activeSession.Marca__c == 'DONMARIO')
			type = 'Production Update 4';
		else
			type = 'Production Update 2';

		if (aAppManager.getProductionReportOpp(activeAccount.Id, season, activeSession.Marca__c, type).size() == 0) {
			pr = new PageReference('/apex/aSiteProductionReportEdit');
		} else {
			pr = new PageReference('/apex/aSiteProductionReport');
		}

		String ret = aSiteAuthManager.RefreshUserSessionLog(token, type + ', ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		if (activeSession.Marca__c == 'DONMARIO')
			pr.getParameters().put('t', 'up4');
		else
			pr.getParameters().put('t', 'up2');
		return pr;
	}

	public PageReference gotoProdUpdate3Report() {
		String token = System.currentPageReference().getParameters().get('token');
		String type = 'Production Update 3';
		PageReference pr;
		if (
			aAppManager.getProductionReportOpp(activeAccount.Id, activeSession.Sales_Season__c, activeSession.Marca__c, type)
				.size() == 0
		) {
			pr = new PageReference('/apex/aSiteProductionReportEdit');
		} else {
			pr = new PageReference('/apex/aSiteProductionReport');
		}
		String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Production 3, ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'up3');
		return pr;
	}
	public PageReference gotoProdReport() {
		String token = System.currentPageReference().getParameters().get('token');
		String type = 'Final Production Report';
		PageReference pr;
		if (
			aAppManager.getProductionReportOpp(activeAccount.Id, activeSession.Sales_Season__c, activeSession.Marca__c, type)
				.size() == 0
		) {
			pr = new PageReference('/apex/aSiteProductionReportEdit');
		} else {
			pr = new PageReference('/apex/aSiteProductionReport');
		}
		String ret = aSiteAuthManager.RefreshUserSessionLog(token, 'Production Final, ');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		pr.getParameters().put('t', 'fi');
		return pr;
	}

	public PageReference gotoUploadFile() {
		String token = System.currentPageReference().getParameters().get('token');
		PageReference pr = new PageReference('/apex/aSiteUploadFile');
		pr.setRedirect(true);
		pr.getParameters().put('token', token);
		return pr;
	}

	public SiteUser__c getUser() {
		return logUser;
	}

	public String getHomeMessage() {
		if (activeSession.Marca__c == 'DONMARIO')
			return settings.DM_Home_Message__c; //'It is time to complete the August Production Report and Final Sales Reports. All reports are due by August 18th.';
		else
			return settings.GDM_Home_Message__c; //'It is time to complete the August Production Report and Final Sales Reports. All reports are due by August 31st.';
	}

	public void setReportingActions(Date today) {
		Integer month = today.month();
		Integer day = today.day();
		reportingMessage = 'No rep message';

		if (brand == 'GDM' || brand == 'VIRTUE') {
			setReportingDatesForGdmAndVirtue(day, month);
		} else if (brand == 'DONMARIO') {
			setReportingDatesForDonmario(day, month);
		}
	}
	private void setReportingDatesForGdmAndVirtue(Integer day, Integer month) {
		if ((month == 3 && day >= 15) || (month > 3 && month < 7) || (month == 7 && day < 27)) {
			reportingMonth = 'APRIL';
			reportingMessage = 'It is time to complete the April Final Production, New Production and Sales Forecast Reports. All reports are due by April 15th.';
		} else if ((month == 7 && day >= 27) || (month > 7 && month < 11) || (month == 11 && day < 15)) {
			reportingMonth = 'AUGUST';
			reportingMessage = 'It is time to complete the August Production and Final Sales Reports.  All reports are due by August 31st.';
		} else if ((month == 11 && day >= 15) || (month > 11 || month < 3) || (month == 3 && day < 15)) {
			reportingMonth = 'DECEMBER';
			reportingMessage = 'It is time to complete the December Production and Sales Forecast Reports.  All reports are due by December 15th.';
		}
	}
	private void setReportingDatesForDonmario(Integer day, Integer month) {
		if ((month == 3 && day >= 15) || month == 4) {
			reportingMonth = 'APRIL';
			reportingMessage = 'It is time to complete the April Final Production, New Production and Sales Forecast Reports. All reports are due by April 15th.';
		} else if ((month == 5 && day >= 1) || (month == 6 && day < 25)) {
			reportingMonth = 'JUNE';
			reportingMessage = 'It is time to complete the May Sales and Production Forecast reports due June 1st.';
		} else if ((month == 6 && day >= 25) || (month == 7 && day < 27)) {
			reportingMonth = 'JULY';
			reportingMessage = 'It is time to complete the July Sales and Production Forecast reports due July 25th.';
		} else if ((month == 7 && day >= 27) || (month > 7 && month < 11) || (month == 11 && day < 15)) {
			List<ContentDocument> doc = [SELECT Id FROM ContentDocument WHERE Title = 'Partner GPOS Template'];
			if (doc.size() > 0) {
				gposTemplateLink = '/sfc/servlet.shepherd/document/download/' + doc[0].Id + '?operationContext=S1';
			}
			reportingMonth = 'AUGUST';
			reportingMessage = 'It is time to complete the August Final Sales and Production Forecast reports due August 18th.';
		} else if ((month == 11 && day >= 15) || (month > 11 || month < 3) || (month == 3 && day < 15)) {
			reportingMonth = 'DECEMBER';
			reportingMessage = 'It is time to complete the December Production and Sales Forecast Reports. All reports are due by December 15th.';
		}
	}

	public List<PieWedgeData> getPieData() {
		List<PieWedgeData> data = new List<PieWedgeData>();
		data.add(new PieWedgeData('GDM15x009', 30));
		data.add(new PieWedgeData('GDM15x010', 15));
		data.add(new PieWedgeData('GDM16x022', 10));
		data.add(new PieWedgeData('GDM40x056', 20));
		data.add(new PieWedgeData('GDM40x070', 25));
		return data;
	}

	// Wrapper class
	public class PieWedgeData {
		public String name { get; set; }
		public Integer data { get; set; }

		public PieWedgeData(String name, Integer data) {
			this.name = name;
			this.data = data;
		}
	}
}