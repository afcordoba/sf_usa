public with sharing class opportunityProductEntryExtension {
	private opportunityLineItem[] forDeletion = new List<opportunityLineItem>{};

	public Opportunity theOpp { get; set; }
	public Pricebook2 theBook { get; set; }
	public String searchString { get; set; }
	public opportunityLineItem[] shoppingCart { get; set; }
	public priceBookEntry[] AvailableProducts { get; set; }
	public Item_del_contrato__c[] AvailableSchedules { get; set; }

	public String toSelect { get; set; }
	public String toUnselect { get; set; }
	public String toReselect { get; set; }
	public Decimal Total { get; set; }

	public Boolean overLimit { get; set; }
	public Boolean exclusiveWarning { get; set; }

	private Boolean forcePricebookSelection = false;
	private String compania = '';
	private Integer contador = 0;

	private Map<String, Schema.SObjectField> objectFields_oppItems = Schema.getGlobalDescribe()
		.get('OpportunityLineItem')
		.getDescribe()
		.fields.getMap();
	private Map<String, Schema.SObjectField> objectFields_opps = Schema.getGlobalDescribe()
		.get('Opportunity')
		.getDescribe()
		.fields.getMap();
	private Map<String, PricebookEntry> mapTradeMarkPrices = new Map<String, PricebookEntry>();
	private Map<String, Item_del_Contrato__c> mapSchedule = new Map<String, Item_del_Contrato__c>();
	private Map<String, Item_del_Contrato__c> mapExclusives = new Map<String, Item_del_Contrato__c>();

	public void setforcePricebookSelection(Boolean a) {
		forcePricebookSelection = a;
	}

	public opportunityProductEntryExtension(ApexPages.StandardController controller) {
		List<PricebookEntry> tmpPriceItems = new List<PricebookEntry>();

		try {
			map<Id, User> propRol = new Map<Id, User>();

			String queryOpp = 'SELECT ';
			for (String s : objectFields_opps.keySet())
				queryOpp += ' ' + s + ',';
			queryOpp +=
				'RecordType.Name, RecordType.DeveloperName, PriceBook2.Name FROM Opportunity Where Id = \'' +
				controller.getRecord().Id +
				'\' limit 1';
			theOpp = Database.query(queryOpp);

			// Obtengo los productos ya cargados a la opp y los cargo como "Seleccionados"
			String queryItems = 'SELECT ';
			for (String s : objectFields_oppItems.keySet())
				queryItems += ' ' + s + ',';
			queryItems += 'PriceBookEntry.UnitPrice, PriceBookEntry.IsActive, PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.PriceBook2Id,';
			queryItems += 'Categoria__r.Name, PricebookEntry.Product2.Categ__c, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Product2.Family, ';
			queryItems += 'PricebookEntry.Product2.Variedade__r.Nombre_de_Registro__c, PricebookEntry.Product2.Categ__r.Name, PricebookEntry.Product2.Semilla_Tratada__c, Opportunity.StageName ';
			queryItems +=
				'FROM OpportunityLineItem Where OpportunityId = \'' +
				theOpp.Id +
				'\' Order by Variedade_de_Produto__c ASC';
			shoppingCart = Database.query(queryItems);
			for (OpportunityLineItem o : shoppingCart) {
				o.ZZPOSSF__c = String.ValueOf(contador);
				contador++;
			}
			for (User u : [SELECT Id, UserRole.Name, Profile.Name FROM User]) {
				propRol.put(u.Id, u);
			}

			if (theOpp.Type == 'Z31 - STOCK SEED') {
				String queryPlus = 'Pricebook2.Type__c, Product2.Variedade__r.Name';
				tmpPriceItems = aSiteUtils.queryResults1(
					PricebookEntry.SObjectType,
					queryPlus,
					'Pricebook2.Type__c = :v1',
					'TRADEMARK'
				);

				for (PricebookEntry pb : tmpPriceItems) {
					if (!mapTradeMarkPrices.containsKey(pb.Product2.Variedade__r.Name)) {
						mapTradeMarkPrices.put(pb.Product2.Variedade__r.Name, pb);
					}
				}
			}

			mapSchedule = aAppManager.getMapSchedules(theOpp.AccountId, theOpp.Safra__c, theOpp.Marca__c);
			mapExclusives = aAppManager.getMapSchedulesExclusives(theOpp.AccountId);

			exclusiveWarning = false;
			// Chequeo si la opp ya tiene una lista de precios
			if (theOpp.Pricebook2Id == null) {
				String nombreLista = 'Portal PriceList';
				Pricebook2[] activepbs = [
					SELECT Id, Name
					FROM Pricebook2
					WHERE Name = :nombreLista AND isActive = TRUE
					LIMIT 1
				];
				if (activepbs.size() == 2) {
					forcePricebookSelection = true;
					theBook = new Pricebook2();
				} else {
					theBook = activepbs[0];
				}
			} else {
				theBook = theOpp.Pricebook2;
			}
			System.debug(theBook);
		} catch (Exception e) {
			ApexPages.addMessages(e);
			return;
		}

		if (!forcePricebookSelection)
			updateAvailableList();
	}

	// metodo 'action' del inicio de la pagina VF
	public PageReference priceBookCheck() {
		if (theOpp == null)
			return null;

		if (forcePricebookSelection) {
			//si es necesario elegir la lista entonces va a la pagina estandar
			return changePricebook();
		} else {
			System.debug(theOpp.pricebook2Id);
			System.debug(theBook);
			if (theOpp.pricebook2Id != theBook.Id) {
				// si solo hay una lista activa, entonces seteamos esa lista y grabamos la opp
				try {
					theOpp.Pricebook2Id = theBook.Id;
					update (theOpp);
				} catch (Exception e) {
					ApexPages.addMessages(e);
				}
			}

			return null;
		}
	}

	public PageReference changePricebook() {
		// Simplemente retornamos la pagina comun de seleccion de lista de precios
		PageReference ref = new PageReference('/oppitm/choosepricebook.jsp');
		ref.getParameters().put('id', theOpp.Id);
		ref.getParameters().put('retURL', '/apex/opportunityProductEntry?id=' + theOpp.Id);
		return ref;
	}

	public void updateAvailableList() {
		Set<Id> prodsARel;
		List<Id> oppsARel;

		if (theBook == null)
			return;

		// Construimos un query dinamico sobre los productos de la lista de precios
		String qString = 'select Id, Pricebook2Id, IsActive, Product2Id, UnitPrice,';
		qString += ' Product2.Name, Product2.Codigo_material_SAP__c, Product2.IsActive, Product2.UNIDADE__c, Product2.Variedade__c, Product2.Categ__c,';
		qString += ' Product2.Variedade__r.Nombre_de_Registro__c, Product2.Variedade__r.Royalty_Rate__c, Product2.Variedade__r.Name, Product2.Categ__r.Name, Product2.Family';
		qString += ' from PricebookEntry where IsActive=true and Pricebook2Id = \'' + theBook.Id + '\'';

		// buscamos productos cuya descripcion o nombre coindidan con el texto ingresado
		if (searchString != null) {
			qString +=
				' and (Product2.Name like \'%' +
				searchString +
				'%\' or Product2.Codigo_material_SAP__c like \'%' +
				searchString +
				'%\' or Product2.Variedade__r.Name like \'%' +
				searchString +
				'%\' or Product2.Variedade__r.Nombre_de_Registro__c like \'%' +
				searchString +
				'%\')';
		}

		qString += ' order by Product2.Name';
		qString += ' limit 31';

		system.debug('qString:' + qString);
		AvailableProducts = database.query(qString);

		// Solo se mostraran hasta 30 registros... si el query tiene mas, entonces el usuario vera un mensaje
		if (AvailableProducts.size() == 31) {
			AvailableProducts.remove(30);
			overLimit = true;
		} else {
			overLimit = false;
		}
	}

	public PageReference addToShoppingCart() {
		Decimal royalty = 3.5;
		Decimal list_roy = 3.5;

		exclusiveWarning = false;

		// Cuando el usuario presiona "Seleccionar" en un producto
		for (PricebookEntry d : AvailableProducts) {
			if ((String) d.Id == toSelect) {
				royalty = d.Product2.Variedade__r.Royalty_Rate__c;
				list_roy = d.Product2.Variedade__r.Royalty_Rate__c;
				Item_del_Contrato__c itemS = new Item_del_Contrato__c();

				if (mapSchedule.containsKey(d.Product2.Variedade__r.Name)) {
					itemS = mapSchedule.get(d.Product2.Variedade__r.Name);
					if (!itemS.active__c)
						continue;

					royalty = items.Precio__c;
				}

				if (theOpp.RecordType.Name != 'Reservation' && mapExclusives.containsKey(d.Product2.Variedade__r.Name)) {
					exclusiveWarning = true;
					continue;
				}

				if (theOpp.Type == 'Z31 - STOCK SEED') {
					if (mapTradeMarkPrices.containsKey(d.Product2.Variedade__r.Name)) {
						royalty = mapTradeMarkPrices.get(d.Product2.Variedade__r.Name).UnitPrice;
						list_roy = mapTradeMarkPrices.get(d.Product2.Variedade__r.Name).UnitPrice;
					}
				}

				OpportunityLineItem item = new opportunityLineItem(
					Company__c = theOpp.Company__c,
					List_Royalty_Rate__c = list_roy,
					Royalty_rate__c = royalty,
					OpportunityId = theOpp.Id,
					PriceBookEntry = d,
					PriceBookEntryId = d.Id,
					UnitPrice = d.UnitPrice,
					ZZPOSSF__c = String.valueOf(contador)
				);
				item.Product2 = d.Product2;

				shoppingCart.add(item);
				contador++;
				break;
			}
		}
		return null;
	}

	public PageReference removeFromShoppingCart() {
		// Cuando el usuario presiona "Eliminar" en un producto seleccionado
		Integer count = 0;
		for (opportunityLineItem d : shoppingCart) {
			if ((String) d.ZZPOSSF__c == toUnselect) {
				if (d.Id != null && (d.Posicion_Relativa_Consign__c == null || d.Posicion_Relativa_Consign__c == '')) {
					forDeletion.add(d);
					shoppingCart.remove(count);
				} else if (d.Posicion_Relativa_Consign__c != null && d.Posicion_Relativa_Consign__c != '') {
					d.Waiting_Sync_To_Delete__c = true;
				}

				break;
			}
			count++;
		}

		updateAvailableList();

		return null;
	}

	public PageReference reAddToShoppingCart() {
		// Cuando el usuario presiona "Eliminar" en un producto seleccionado
		Integer count = 0;
		for (opportunityLineItem d : shoppingCart) {
			if ((String) d.ZZPOSSF__c == toReselect) {
				d.Waiting_Sync_To_Delete__c = false;

				break;
			}
			count++;
		}

		updateAvailableList();

		return null;
	}

	public PageReference onSave() {
		List<OpportunityLineItem> deleteVB = new List<OpportunityLineItem>();
		List<OpportunityLineItem> insertVB = new List<OpportunityLineItem>();
		OpportunityLineItem cloneVB = new OpportunityLineItem();
		Boolean ofPend = false;
		// Si algun producto ya selecciondo es eliminado, entonces debemos quitarlo
		Savepoint sp;
		try {
			// Los datos ya cargados deben ser actualizados
			sp = Database.setSavepoint();
			if (forDeletion.size() > 0)
				delete (forDeletion);

			for (OpportunityLineItem i : shoppingCart) {
				if (i.Quantity == null)
					i.Quantity = 0.01;
			}

			if (shoppingCart.size() > 0)
				upsert (shoppingCart);
		} catch (Exception e) {
			ApexPages.Message myMsg = new ApexPages.Message(
				ApexPages.Severity.ERROR,
				E.getMessage() +
				' - ' +
				e.getStackTraceString()
			);
			ApexPages.addMessage(myMsg);
			Database.rollback(sp);
			return null;
		}

		// Luego de grabar los cambios retornamos al usuario a la opp
		//        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));

		PageReference tempPage = new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
		tempPage.setRedirect(true);
		return tempPage;
	}

	public PageReference onCancel() {
		return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
	}

	public List<Schema.FieldSetMember> getFields() {
		Opportunity o = [SELECT RecordType.Name FROM Opportunity WHERE Id = :theOpp.Id];
		if (o.RecordType.Name == 'Sales Report')
			return SObjectType.OpportunityLineItem.FieldSets.Sales_report.getFields();
		if (o.RecordType.Name == 'Production Report')
			return SObjectType.OpportunityLineItem.FieldSets.Production_forecast_report.getFields();
		return new List<Schema.FieldSetMember>();
	}
}