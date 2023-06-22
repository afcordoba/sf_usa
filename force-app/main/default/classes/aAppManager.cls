public class aAppManager {
	private static String ST_APROBADA = 'Approved';
	private static String ST_ENVIADA = 'Sent';

	public aAppManager() {
	}

	//USA
	public static List<Opportunity> getSalesReportOpp(Id accId, String safra, String marca, String type) {
		try {
			return aSiteUtils.queryResults5(
				Opportunity.SObjectType,
				null,
				'AccountId = :v1',
				accId,
				'RecordType.DeveloperName = :v2',
				'Sales_Report',
				'Safra__c = :v3',
				safra,
				'Marca__c = :v4',
				marca,
				'Type = :v5',
				type
			);
		} catch (Exception e) {
			return null;
		}
	}
	public static List<Opportunity> getProductionReportOpp(Id accId, String safra, String marca, String type) {
		try {
			return aSiteUtils.queryResults5(
				Opportunity.SObjectType,
				null,
				'AccountId = :v1',
				accId,
				'RecordType.DeveloperName = :v2',
				'Production_Report',
				'Safra__c = :v3',
				safra,
				'Marca__c = :v4',
				marca,
				'Type = :v5',
				type
			);
		} catch (Exception e) {
			return null;
		}
	}

	public static Map<String, OpportunityLineItem> getMapUsedUnits(Id accId, String safra, String marca) {
		try {
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();

			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';
			tmpOppItems = aSiteUtils.queryResults5(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sales_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Final Sales Report'
			);

			for (OpportunityLineItem s : tmpOppItems) {
				if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
					mapOppItem.put(s.Variedade_de_Produto__c, s);
				}
			}
			System.debug('JERE MAP UP 2:: Cantidad de items ' + tmpOppItems.size());
			return mapOppItem;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsForUsedUnits(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			tmpOppItems2 = aSiteUtils.queryResults5(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sales_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Final Sales Report'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) {
					//Ojo, ver idioma para este dato
					tmpOppItems.add(s);
				}
			}
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToFinalSalesRep(Id accId, String safra, String marca) {
		try {
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();
			Map<String, OpportunityLineItem> mapOppItemAux = new Map<String, OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems3 = new List<OpportunityLineItem>();

			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName, Opportunity.Type, Opportunity.RecordType.DeveloperName ';

			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sales_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Sales Forecast Update 2',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (
					(s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) &&
					String.isNotBlank(s.Variedade_de_Produto__c)
				) {
					//Ojo, ver idioma para este dato
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						s.Unconditioned_Bushels__c = 0;
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					}
					//tmpOppItems.add(s);
				}
			}
			//parent seed
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z2 - PARENT SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA && String.isNotBlank(s.Variedade_de_Produto__c)) {
					if (s.Quantity_by_140k__c > 0) {
						if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
							s.Unconditioned_Bushels__c = s.Quantity_by_140k__c;
							s.Description = 'from Parent Seed';
							mapOppItem.put(s.Variedade_de_Produto__c, s);
						} else {
							OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
							if (oli != null) {
								oli.Description = 'from Parent Seed';
								if (oli.Unconditioned_Bushels__c != null)
									oli.Unconditioned_Bushels__c = oli.Unconditioned_Bushels__c + Double.valueOf(s.Quantity_by_140k__c);
							}
						}
					}
				}
			}

			//falta eliminar los que sean test de menos de una bolsa.
			//Wholesale

			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z4 - WHOLESALE SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA && String.isNotBlank(s.Variedade_de_Produto__c)) {
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						s.Product_Purchased__c = s.Quantity_by_140k__c;
						s.Description = 'from WS';
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					} else {
						OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
						if (oli != null) {
							oli.Description = 'from WS';
							if (oli.Product_Purchased__c != null)
								oli.Product_Purchased__c = oli.Product_Purchased__c + Double.valueOf(s.Quantity_by_140k__c);
							else
								oli.Product_Purchased__c = Double.valueOf(s.Quantity_by_140k__c);
						}
					}
				}
			}

			//wholesale type purchase
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Purchase' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z4 - WHOLESALE SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA && String.isNotBlank(s.Variedade_de_Produto__c) && s.Quantity >= 1) {
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						s.Wholesale_Sales__c = s.Quantity;
						s.Description = 'from WS';
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					} else {
						OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
						if (oli != null) {
							oli.Description = 'from WS';
							if (oli.Wholesale_Sales__c != null && oli.Wholesale_Sales__c >= 1) {
								oli.Wholesale_Sales__c = oli.Wholesale_Sales__c + s.Quantity;
							} else {
								oli.Wholesale_Sales__c = s.Quantity;
							}
						}
					}
				}
			}

			//Test seed
			tmpOppItems3 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z3 - TEST SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems3) {
				if (s.Opportunity.StageName == ST_APROBADA && String.isNotBlank(s.Variedade_de_Produto__c)) {
					if (s.Quantity_by_140k__c > 0) {
						if (!mapOppItemAux.containsKey(s.Variedade_de_Produto__c)) {
							s.Test_Seed_Purchases__c = s.Quantity_by_140k__c;
							s.Unconditioned_Bushels__c = 0;
							s.Description = 'from Test Seed';
							mapOppItemAux.put(s.Variedade_de_Produto__c, s);
						} else {
							OpportunityLineItem oli = mapOppItemAux.get(s.Variedade_de_Produto__c);
							if (oli != null) {
								if (oli.Test_Seed_Purchases__c != null)
									oli.Test_Seed_Purchases__c = oli.Test_Seed_Purchases__c + Double.valueOf(s.Quantity_by_140k__c);
								else
									oli.Test_Seed_Purchases__c = Double.valueOf(s.Quantity_by_140k__c);
							}
						}
					}
				}
			}

			for (OpportunityLineItem li : mapOppItemAux.values()) {
				if (li.Test_Seed_Purchases__c >= 1 && String.isNotBlank(li.Variedade_de_Produto__c)) {
					if (!mapOppItem.containsKey(li.Variedade_de_Produto__c)) {
						mapOppItem.put(li.Variedade_de_Produto__c, li);
					} else {
						OpportunityLineItem oli = mapOppItem.get(li.Variedade_de_Produto__c);
						oli.Test_Seed_Purchases__c = li.Test_Seed_Purchases__c;
					}
				}
			}

			List<String> keyList = new List<String>();
			keyList.addAll(mapOppItem.keySet());
			keyList.sort();
			Map<String, OpportunityLineItem> sortedItems = new Map<String, OpportunityLineItem>();
			for (String key : keyList) {
				sortedItems.put(key, mapOppItem.get(key));
			}
			return sortedItems.values();
		} catch (Exception e) {
			return null;
		}
	}

	public static Map<String, OpportunityLineItem> getMapFore2Rep(Id accId, String safra, String marca) {
		try {
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();

			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';
			tmpOppItems = aSiteUtils.queryResults5(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sales_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Sales Forecast Update 1'
			);
			for (OpportunityLineItem s : tmpOppItems) {
				//if(s.Opportunity.StageName == ST_APROBADA){
				if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
					mapOppItem.put(s.Variedade_de_Produto__c, s);
				}
				//}
			}
			System.debug('JERE MAP UP 2:: Cantidad de items ' + tmpOppItems.size());
			return mapOppItem;
		} catch (Exception e) {
			return null;
		}
	}

	public static Map<String, OpportunityLineItem> getMapProd1Rep(Id accId, String safra, String marca) {
		try {
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();

			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';
			tmpOppItems = aSiteUtils.queryResults5(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Production_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Production Report 1'
			);
			for (OpportunityLineItem s : tmpOppItems) {
				if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
					mapOppItem.put(s.Variedade_de_Produto__c, s);
				}
			}
			System.debug('JERE MAP UP 2:: Cantidad de items ' + tmpOppItems.size());
			return mapOppItem;
		} catch (Exception e) {
			return null;
		}
	}

	public static Map<String, Item_del_Contrato__c> getMapSchedules(Id accId, String safra, String marca) {
		try {
			Map<String, Item_del_Contrato__c> mapOppItem = new Map<String, Item_del_Contrato__c>();
			List<Item_del_Contrato__c> tmpOppItems = new List<Item_del_Contrato__c>();

			String queryPlus = 'Contrato_de_Multiplicacion__r.Multiplicador__c, Contrato_de_Multiplicacion__r.License_Date__c, Contrato_de_Multiplicacion__r.Safra__c, Contrato_de_Multiplicacion__r.Sociedad__c';
			tmpOppItems = aSiteUtils.queryResults2(
				Item_del_Contrato__c.SObjectType,
				queryPlus,
				'Contrato_de_Multiplicacion__r.Multiplicador__c = :v1',
				accId,
				'Contrato_de_Multiplicacion__r.Brand__c = :v2',
				marca
			);
			// tmpOppItems = aSiteUtils.queryResults3(
			// 	Item_del_Contrato__c.SObjectType,
			// 	queryPlus,
			// 	'Contrato_de_Multiplicacion__r.Multiplicador__c = :v1',
			// 	accId,
			// 	'Contrato_de_Multiplicacion__r.Brand__c = :v2',
			// 	marca,
			// 	'Contrato_de_Multiplicacion__r.RecordType.Name <> :v3',
			// 	'Test Seed Schedule A'
			// );
			for (Item_del_Contrato__c s : tmpOppItems) {
				if (!mapOppItem.containsKey(s.Variedade__c)) {
					mapOppItem.put(s.Variedade__c, s);
				}
			}
			System.debug('JERE MAP UP 2:: Cantidad de items ' + tmpOppItems.size());
			return mapOppItem;
		} catch (Exception e) {
			return null;
		}
	}

	public static Map<String, Item_del_Contrato__c> getMapSchedulesExclusives(Id accId) {
		try {
			Map<String, Item_del_Contrato__c> mapOppItem = new Map<String, Item_del_Contrato__c>();
			List<Item_del_Contrato__c> tmpOppItems = new List<Item_del_Contrato__c>();

			String queryPlus = 'Contrato_de_Multiplicacion__r.Multiplicador__c, Contrato_de_Multiplicacion__r.License_Date__c, Contrato_de_Multiplicacion__r.Safra__c, Contrato_de_Multiplicacion__r.Sociedad__c';
			tmpOppItems = aSiteUtils.queryResults2(
				Item_del_Contrato__c.SObjectType,
				queryPlus,
				'Contrato_de_Multiplicacion__r.Multiplicador__c != :v1',
				accId,
				'Exclusive__c = :v2',
				'YES'
			);
			for (Item_del_Contrato__c s : tmpOppItems) {
				if (!mapOppItem.containsKey(s.Variedade__c)) {
					mapOppItem.put(s.Variedade__c, s);
				}
			}
			System.debug('JERE MAP UP 3:: Cantidad de items ' + tmpOppItems.size());
			return mapOppItem;
		} catch (Exception e) {
			return null;
		}
	}

	public static Map<String, OpportunityLineItem> getMapParentSeeds(Id accId, String safra, String marca) {
		try {
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();

			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';
			tmpOppItems = aSiteUtils.queryResults5(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z17 - PARENT SEED'
			);

			for (OpportunityLineItem s : tmpOppItems) {
				if (s.Opportunity.StageName == ST_APROBADA) {
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					} else {
						OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
						if (oli != null)
							oli.Prev_Parent__c = s.Quantity_by_140k__c;
						//oli.Prev_Parent__c = s.Quantity_by_140k__c + oli.Prev_Parent__c == null ? 0 : oli.Prev_Parent__c;
					}
				}
			}
			System.debug('JERE MAP UP 2:: Cantidad de items ' + tmpOppItems.size());
			return mapOppItem;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsSales1_DM(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Production_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Production Update 4',
				'Variedade_de_Produto__c'
			);

			for (OpportunityLineItem s : tmpOppItems2)
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA)
					tmpOppItems.add(s);

			System.debug('JERE UP 1:: Cantidad de items ' + tmpOppItems.size());
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsSales1(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Production_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Production Update 2',
				'Variedade_de_Produto__c'
			);

			for (OpportunityLineItem s : tmpOppItems2)
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA)
					tmpOppItems.add(s);

			System.debug('JERE UP 1:: Cantidad de items ' + tmpOppItems.size());
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsSales2(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();

			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sales_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Sales Forecast Update 1',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) {
					//tmpOppItems.add(s);
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					}
				}
			}

			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z19 - WHOLESALE SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA) {
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						s.Description = 'from WS';
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					} else {
						OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
						if (oli != null)
							oli.Description = 'from WS';
					}
				}
			}

			//            System.debug('JERE UP 2:: Cantidad de items ' + tmpOppItems.size());
			//            return tmpOppItems;
			return mapOppItem.values();
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsSales2_DM(Id accId, String safra, String marca) {
		try {
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();
			Map<String, OpportunityLineItem> mapOppItemAux = new Map<String, OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems3 = new List<OpportunityLineItem>();

			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sales_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Sales Forecast Update 1',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) {
					//Ojo, ver idioma para este dato
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						s.Unconditioned_Bushels__c = 0;
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					}
				}
			}
			//parent seed
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z17 - PARENT SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA) {
					if (s.Quantity_by_140k__c > 0) {
						if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
							s.Unconditioned_Bushels__c = s.Quantity_by_140k__c;
							s.Description = 'from Parent Seed';
							mapOppItem.put(s.Variedade_de_Produto__c, s);
						} else {
							OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
							if (oli != null) {
								oli.Description = 'from Parent Seed';
								if (oli.Unconditioned_Bushels__c != null)
									oli.Unconditioned_Bushels__c = oli.Unconditioned_Bushels__c + Double.valueOf(s.Quantity_by_140k__c);
							}
						}
					}
				}
			}

			//Wholesale
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z19 - WHOLESALE SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA) {
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						s.Product_Purchased__c = s.Quantity_by_140k__c;
						s.Description = 'from WS';
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					} else {
						OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
						if (oli != null) {
							oli.Description = 'from WS';
							if (oli.Product_Purchased__c != null)
								oli.Product_Purchased__c = oli.Product_Purchased__c + Double.valueOf(s.Quantity_by_140k__c);
							else
								oli.Product_Purchased__c = Double.valueOf(s.Quantity_by_140k__c);
						}
					}
				}
			}

			//Test seed
			tmpOppItems3 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z18 - TEST SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems3) {
				if (s.Opportunity.StageName == ST_APROBADA) {
					if (s.Quantity_by_140k__c > 0) {
						if (!mapOppItemAux.containsKey(s.Variedade_de_Produto__c)) {
							s.Test_Seed_Purchases__c = s.Quantity_by_140k__c;
							s.Unconditioned_Bushels__c = 0;
							s.Description = 'from Test Seed';
							mapOppItemAux.put(s.Variedade_de_Produto__c, s);
						} else {
							OpportunityLineItem oli = mapOppItemAux.get(s.Variedade_de_Produto__c);
							if (oli != null) {
								if (oli.Test_Seed_Purchases__c != null)
									oli.Test_Seed_Purchases__c = oli.Test_Seed_Purchases__c + Double.valueOf(s.Quantity_by_140k__c);
								else
									oli.Test_Seed_Purchases__c = Double.valueOf(s.Quantity_by_140k__c);
							}
						}
					}
				}
			}

			for (OpportunityLineItem li : mapOppItemAux.values()) {
				if (li.Test_Seed_Purchases__c >= 1) {
					if (!mapOppItem.containsKey(li.Variedade_de_Produto__c)) {
						mapOppItem.put(li.Variedade_de_Produto__c, li);
					} else {
						OpportunityLineItem oli = mapOppItem.get(li.Variedade_de_Produto__c);
						oli.Test_Seed_Purchases__c = li.Test_Seed_Purchases__c;
					}
				}
			}

			List<String> keyList = new List<String>();
			keyList.addAll(mapOppItem.keySet());
			keyList.sort();
			Map<String, OpportunityLineItem> sortedItems = new Map<String, OpportunityLineItem>();
			for (String key : keyList) {
				sortedItems.put(key, mapOppItem.get(key));
			}
			return sortedItems.values();
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToUpdateUp1Rep(Id accId, String safra, String marca) {
		//ver para eliminar este metodo
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los ANEXOS I para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Production_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Sales_Report_Type__c = :v5',
				'Production'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) {
					//Ojo, ver idioma para este dato
					tmpOppItems.add(s);
				}
			}
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToUpdateUp2Rep(Id accId, String safra, String marca) {
		//ver para eliminar este metodo
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los reportes prod up 1 para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Production_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Production/Conditioning'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) {
					//Ojo, ver idioma para este dato
					tmpOppItems.add(s);
				}
			}
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsSales3_DM(Id accId, String safra, String marca) {
		//ver para eliminar este metodo
		try {
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sales_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Sales Forecast Update 2',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) {
					//Ojo, ver idioma para este dato
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					}
				}
			}

			return mapOppItem.values();
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsSales4_DM(Id accId, String safra, String marca) {
		//ver para eliminar este metodo
		try {
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sales_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Sales Forecast Update 3',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) {
					//Ojo, ver idioma para este dato
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					}
				}
			}

			return mapOppItem.values();
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToForecastUp5Rep(Id accId, String safra, String marca) {
		try {
			Map<String, OpportunityLineItem> mapOppItem = new Map<String, OpportunityLineItem>();
			Map<String, OpportunityLineItem> mapOppItemAux = new Map<String, OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sales_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Sales Forecast Update 4',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) {
					//Ojo, ver idioma para este dato
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					}
				}
			}

			//stock seed
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z14 - STOCK SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA) {
					if (s.Quantity_by_140k__c > 0) {
						if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
							s.Unconditioned_Bushels__c = s.Quantity_by_140k__c;
							s.Description = 'from Stock Seed';
							mapOppItem.put(s.Variedade_de_Produto__c, s);
						} else {
							OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
							if (oli != null) {
								oli.Description = 'from Stock Seed';
								if (oli.Unconditioned_Bushels__c != null)
									oli.Unconditioned_Bushels__c = oli.Unconditioned_Bushels__c + Double.valueOf(s.Quantity_by_140k__c);
								else
									oli.Unconditioned_Bushels__c = s.Quantity_by_140k__c;
							}
						}
					}
				}
			}

			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z2 - PARENT SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA && String.isNotBlank(s.Variedade_de_Produto__c)) {
					if (s.Quantity_by_140k__c > 0) {
						if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
							s.Unconditioned_Bushels__c = s.Quantity_by_140k__c;
							s.Description = 'from Parent Seed';
							mapOppItem.put(s.Variedade_de_Produto__c, s);
						} else {
							OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
							if (oli != null) {
								oli.Description = 'from Parent Seed';
								if (oli.Unconditioned_Bushels__c != null) {
									oli.Unconditioned_Bushels__c = oli.Unconditioned_Bushels__c + Double.valueOf(s.Quantity_by_140k__c);
								} else {
									oli.Unconditioned_Bushels__c = Double.valueOf(s.Quantity_by_140k__c);
								}
							}
						}
					}
				}
			}

			//falta eliminar los que sean test de menos de una bolsa.
			//Wholesale

			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z4 - WHOLESALE SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA && String.isNotBlank(s.Variedade_de_Produto__c)) {
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						s.Product_Purchased__c = s.Quantity_by_140k__c;
						s.Description = 'from WS';
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					} else {
						OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
						if (oli != null) {
							oli.Description = 'from WS';
							if (oli.Product_Purchased__c != null)
								oli.Product_Purchased__c = oli.Product_Purchased__c + Double.valueOf(s.Quantity_by_140k__c);
							else
								oli.Product_Purchased__c = Double.valueOf(s.Quantity_by_140k__c);
						}
					}
				}
			}

			//wholesale type purchase
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Purchase' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z4 - WHOLESALE SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA && String.isNotBlank(s.Variedade_de_Produto__c) && s.Quantity >= 1) {
					if (!mapOppItem.containsKey(s.Variedade_de_Produto__c)) {
						s.Wholesale_Sales__c = s.Quantity;
						s.Description = 'from WS';
						mapOppItem.put(s.Variedade_de_Produto__c, s);
					} else {
						OpportunityLineItem oli = mapOppItem.get(s.Variedade_de_Produto__c);
						if (oli != null) {
							oli.Description = 'from WS';
							if (oli.Wholesale_Sales__c != null && oli.Wholesale_Sales__c >= 1) {
								oli.Wholesale_Sales__c = oli.Wholesale_Sales__c + s.Quantity;
							} else {
								oli.Wholesale_Sales__c = s.Quantity;
							}
						}
					}
				}
			}

			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Sale' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Z3 - TEST SEED',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_APROBADA) {
					if (s.Quantity_by_140k__c > 0) {
						if (!mapOppItemAux.containsKey(s.Variedade_de_Produto__c)) {
							s.Test_Seed_Purchases__c = s.Quantity_by_140k__c;
							s.Unconditioned_Bushels__c = 0;
							s.Description = 'from Test Seed';
							mapOppItemAux.put(s.Variedade_de_Produto__c, s);
						} else {
							OpportunityLineItem oli = mapOppItemAux.get(s.Variedade_de_Produto__c);
							if (oli != null) {
								if (oli.Test_Seed_Purchases__c != null)
									oli.Test_Seed_Purchases__c = oli.Test_Seed_Purchases__c + Double.valueOf(s.Quantity_by_140k__c);
								else
									oli.Test_Seed_Purchases__c = Double.valueOf(s.Quantity_by_140k__c);
							}
						}
					}
				}
			}

			for (OpportunityLineItem li : mapOppItemAux.values()) {
				if (li.Test_Seed_Purchases__c >= 1) {
					if (!mapOppItem.containsKey(li.Variedade_de_Produto__c)) {
						mapOppItem.put(li.Variedade_de_Produto__c, li);
					} else {
						OpportunityLineItem oli = mapOppItem.get(li.Variedade_de_Produto__c);
						oli.Test_Seed_Purchases__c = li.Test_Seed_Purchases__c;
					}
				}
			}
			List<String> keyList = new List<String>();
			keyList.addAll(mapOppItem.keySet());
			keyList.sort();
			Map<String, OpportunityLineItem> sortedItems = new Map<String, OpportunityLineItem>();
			for (String key : keyList) {
				sortedItems.put(key, mapOppItem.get(key));
			}
			return sortedItems.values();
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToProductionUpdate2Rep(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Production_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Production Update 1',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if ((s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA)) {
					tmpOppItems.add(s);
				}
			}
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToProductionUpdate3Rep(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Production_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Production Update 2',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if ((s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA)) {
					tmpOppItems.add(s);
				}
			}
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToProductionUpdate4Rep(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Production_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Production Update 3',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if ((s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA)) {
					tmpOppItems.add(s);
				}
			}
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToProductionUpdate5Rep(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'Production_Report' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Opportunity.Type = :v5',
				'Production Update 4',
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if ((s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA)) {
					tmpOppItems.add(s);
				}
			}
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToFinalProductionRep(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Variedad__r.Name, PricebookEntry.Product2.Variedade__c, PricebookEntry.Product2.Variedade__r.Name, Categoria__r.Name, Opportunity.StageName';

			//Consulto todos los Final Product Report para armar la grilla disponible de variedades.
			if (marca == 'DONMARIO')
				tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
					OpportunityLineItem.SObjectType,
					queryPlus,
					'Opportunity.AccountId = :v1',
					accId,
					'Opportunity.RecordType.DeveloperName in :v2',
					new List<String>{ 'Production_Report' },
					'Opportunity.Safra__c = :v3',
					safra,
					'Opportunity.Marca__c = :v4',
					marca,
					'Opportunity.Type = :v5',
					'Production Update 5',
					'Variedade_de_Produto__c'
				);
			else
				tmpOppItems2 = aSiteUtils.queryResults5WithOrderBy(
					OpportunityLineItem.SObjectType,
					queryPlus,
					'Opportunity.AccountId = :v1',
					accId,
					'Opportunity.RecordType.DeveloperName in :v2',
					new List<String>{ 'Production_Report' },
					'Opportunity.Safra__c = :v3',
					safra,
					'Opportunity.Marca__c = :v4',
					marca,
					'Opportunity.Type = :v5',
					'Production Update 3',
					'Variedade_de_Produto__c'
				);
			for (OpportunityLineItem s : tmpOppItems2) {
				if ((s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA)) {
					tmpOppItems.add(s);
				}
			}
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getItemsToProductionRep(Id accId, String safra, String marca) {
		try {
			List<OpportunityLineItem> tmpOppItems = new List<OpportunityLineItem>();
			List<OpportunityLineItem> tmpOppItems2 = new List<OpportunityLineItem>();
			String queryPlus = 'Estado_de_Produccion__r.Name, Variedad__r.Name, PricebookEntry.Product2.Variedade__c, Categoria__r.Name, Opportunity.StageName'; //PricebookEntry.Product2.Variedade__r.Name,

			//Consulto todos los ANEXOS I para armar la grilla disponible de variedades.
			tmpOppItems2 = aSiteUtils.queryResults4WithOrderBy(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'Opportunity.AccountId = :v1',
				accId,
				'Opportunity.RecordType.DeveloperName in :v2',
				new List<String>{ 'AnexoI' },
				'Opportunity.Safra__c = :v3',
				safra,
				'Opportunity.Marca__c = :v4',
				marca,
				'Variedade_de_Produto__c'
			);
			for (OpportunityLineItem s : tmpOppItems2) {
				if (s.Opportunity.StageName == ST_ENVIADA || s.Opportunity.StageName == ST_APROBADA) {
					//Ojo, ver idioma para este dato
					tmpOppItems.add(s);
				}
			}
			return tmpOppItems;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getAnexosItemsByOpp(Id oppId) {
		try {
			String queryPlus = 'Estado_de_Produccion__r.Name, Variedad__r.Name, Categoria__r.Name';
			return aSiteUtils.queryResults1WithOrderByField(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'OpportunityId = :v1',
				oppId,
				'Variedade_de_Produto__c'
			);
		} catch (Exception e) {
			return null;
		}
	}

	public static List<OpportunityLineItem> getReportItemsByOpp(Id oppId, String tipo) {
		try {
			String queryPlus = 'Estado_de_Produccion__r.Name, Variedad__r.Name, Categoria__r.Name';
			//            return aSiteUtils.queryResults2(OpportunityLineItem.SObjectType, queryPlus ,'OpportunityId = :v1', oppId,'Sales_Report_Type__c = :v2',tipo);
			return aSiteUtils.queryResults1WithOrderByField(
				OpportunityLineItem.SObjectType,
				queryPlus,
				'OpportunityId = :v1',
				oppId,
				'Variedade_de_Produto__c'
			);
		} catch (Exception e) {
			return null;
		}
	}

	public static List<String> getOpcionesForecast() {
		try {
			return aSiteUtils.getDatosCombo('OpportunityLineItem', 'Forecast__c');
		} catch (Exception e) {
			return null;
		}
	}
	public static List<String> getOpcionesProdUpdate() {
		try {
			return aSiteUtils.getDatosCombo('OpportunityLineItem', 'Update_Values__c');
		} catch (Exception e) {
			return null;
		}
	}

	public static String getLinkDataAnalytics() {
		try {
			List<Configuracion_USA__c> c = aSiteUtils.queryResults1(
				Configuracion_USA__c.SObjectType,
				null,
				'Id != :v1',
				null
			);
			return c[0].Link_Data_Analytics__c;
		} catch (Exception e) {
			return null;
		}
	}

	public static List<Estado__c> getEstados() {
		try {
			return aSiteUtils.queryResults1(Estado__c.SObjectType, null, 'Id != :v1', null);
		} catch (Exception e) {
			return null;
		}
	}

	public static List<Categoria__c> getCategorias() {
		try {
			return aSiteUtils.queryResults1(Categoria__c.SObjectType, null, 'Id != :v1', null);
		} catch (Exception e) {
			return null;
		}
	}

	public static void sendNotification(List<String> emails, String notificationType) {
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.toAddresses = emails;
		message.subject = 'Report submission to GDM Seeds';
		if (notificationType == 'success') {
			message.plainTextBody =
				'Dear Customer, \n \n' +
				'Thank you for completing the GDM reporting. If you have any questions, please reach out to your Regional Manager or contact sales administration at salesadminusa@gdmseeds.com.' +
				'\n \nGDM Seeds';
		} else if (notificationType == 'error') {
			message.plainTextBody =
				'Dear Customer, \n \n' +
				'There was a an error trying to complete the GDM report. Please reach out to your Regional Manager or contact sales administration at salesadminusa@gdmseeds.com.' +
				'\n \nGDM Seeds';
		}
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
		Organization org = [SELECT Id, isSandbox FROM Organization LIMIT 1];
		if(!org.isSandbox || !Test.isRunningTest()) {
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
		}
	}
}