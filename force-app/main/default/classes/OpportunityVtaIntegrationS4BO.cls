public class OpportunityVtaIntegrationS4BO implements IProcessingQueue {
	/**
	 *   Copia identica OpportunityVtaIntegrationBO solo que adaptada a nueva integracion S4 - Jere 29.10.21
	 *   Procesa un registro log
	 *   @param queueId Id del registro de procesamiento
	 *   @param recordId Id del registro origen del procesamiento
	 *   @param eventName nombre del evento que lanza de procesamiento
	 *   @param payload JSON con el texto completo del item para procesamiento
	 */
	public static void executeQueue(String queueId, String recordId, String eventName, String payload, Integer target) {
		try {
			if (eventName.equals('OPPORTUNITY_SALESFORCE_TO_SAP')) {
				outboundIntegration(queueId, recordId, eventName, payload, target);
			}
			if (eventName.equals('OPPORTUNITY_REJ_SALESFORCE_TO_SAP')) {
				outboundIntegrationRej(queueId, recordId, eventName, payload, target);
			}
		} catch (Exception ex) {
			QueueBO.getInstance()
				.updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString(), ex.getMessage());
		}
	}

	public static String outboundRequestRej(Opportunity o) {
		SapStatusPedidoIS.ZSdStatusPedido_element request = new SapStatusPedidoIS.ZSdStatusPedido_element();
		SapStatusPedidoIS.ZssdPedidoStatus status = new SapStatusPedidoIS.ZssdPedidoStatus();
		status.Faksk = '';
		status.Lifsk = '';
		status.Abgru = 'Z3';

		request.INroPedido = o.Nro_Pedido_SAP__c;
		request.IStatus = status;
		return JSON.serialize(request);
	}

	@future(callout=true)
	private static void outboundIntegrationRej(
		String queueId,
		String recordId,
		String eventName,
		String payload,
		Integer target
	) {
		SapStatusPedidoIS.Bapiret2Tab mensajes;
		String mens = '';
		SapStatusPedidoIS.ZSdStatusPedidoResponse_element resultado;
		SapStatusPedidoIS.Z_SD_STATUS_PEDIDO soap = new SapStatusPedidoIS.Z_SD_STATUS_PEDIDO();

		SapStatusPedidoIS.ZSdStatusPedido_element request_x = (SapStatusPedidoIS.ZSdStatusPedido_element) JSON.deserialize(
			payload,
			SapStatusPedidoIS.ZSdStatusPedido_element.class
		);
		SapStatusPedidoIS.ZssdPedidoStatus status = request_x.IStatus;

		SAPEndpoint__c endpoint = SAPEndpoint__c.getOrgDefaults();

		try {
			soap.inputHttpHeaders_x = new Map<String, String>();
			String encodedusernameandpassword;

			String myData = endpoint.Username__c + ':' + endpoint.Password__c;
			Blob hash = Blob.valueOf(myData);
			encodedusernameandpassword = EncodingUtil.base64Encode(hash);
			soap.timeout_x = 90000;
			soap.inputHttpHeaders_x.put('Authorization', 'Basic ' + encodedusernameandpassword);

			resultado = soap.ZSdStatusPedido(request_x.INroPedido, status, String.valueOf(target));

			ProcessControl.ignoredByTrigger = true;

			Opportunity opp = new Opportunity(Id = recordId, Status_Integracion__c = 'Integraded', Stagename = 'Rejected');
			update opp;

			mensajes = resultado.TReturn;

			for (Integer i = 0; i < mensajes.item.size(); i++)
				mens += mensajes.item[i].Message + '\n';

			QueueBO.getInstance().updateQueueConfirm(queueId, eventName + '\n' + JSON.serialize(resultado), mens);
		} catch (CalloutException ex) {
			ProcessControl.ignoredByTrigger = true;
			update new Opportunity(Id = recordId, Status_Integracion__c = 'Integration Error');
			QueueBO.getInstance()
				.updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString(), ex.getMessage());
		} catch (DmlException ex) {
			ProcessControl.ignoredByTrigger = true;
			update new Opportunity(Id = recordId, Status_Integracion__c = 'Integration Error');
			QueueBO.getInstance()
				.updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString(), ex.getMessage());
		} catch (Exception ex) {
			ProcessControl.ignoredByTrigger = true;
			update new Opportunity(Id = recordId, Status_Integracion__c = 'Integration Error');
			QueueBO.getInstance()
				.updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString(), ex.getMessage());
		}
	}

	public static Map<Id, String> setCentroCO(Opportunity o) {
		Map<Id, String> materialCostOrder = new Map<Id, String>();
		Set<Id> productIds = new Set<Id>();
		for (OpportunityLineItem item : o.OpportunityLineItems) {
			productIds.add(item.Product2Id);
		}

		String company = '01US';
		if (o.Company__c == 'B&B') {
			company = '02US';
		}

		Map<Id, String> productFamilyById = new Map<Id, String>();
		for (Product2 theProduct : [SELECT Family FROM Product2 WHERE Id IN :productIds]) {
			productFamilyById.put(theProduct.Id, theProduct.Family);
		}

		for (Centro_de_CO__c costOrder : [
			SELECT Orden__c, Product_Family__c
			FROM Centro_de_CO__c
			WHERE
				Sociedad__c = :company
				AND Brand__c = :o.Marca__c
				AND Campania__c = :o.Safra__c
				AND Product_Family__c IN :productFamilyById.values()
		]) {
			for (String productId : productFamilyById.keySet()) {
				if (productFamilyById.get(productId) == costOrder.Product_Family__c) {
					materialCostOrder.put(productId, costOrder.Orden__c);
				}
			}
		}

		return materialCostOrder;
	}

	public static String outboundRequest(Opportunity o) {
		String step = 'Inicio';
		String empresa; //'U001';
		sapAltaPedidoS4.Z_SD_ALTA_PEDIDO_element request = new sapAltaPedidoS4.Z_SD_ALTA_PEDIDO_element();

		// Get CentroCO
		Map<Id, String> materialCostOrder = new Map<Id, String>();
		materialCostOrder = setCentroCO(o);

		//Cabecera
		request.I_Cabecera = new sapAltaPedidoS4.ZSSD_PEDIDO_CAB();
		request.I_Cabecera.ZZnrosf = o.Name;
		request.I_Cabecera.ZZidsf = o.Id;

		request.I_Cabecera.WAERK = 'USD'; //moneda
		request.I_Cabecera.Zzcampana = o.safra__c;
		request.I_Cabecera.Zlsch = '';
		request.I_Cabecera.BSTZD = '';

		step = 'Condicion de Pago';
		request.I_Cabecera.ZTERM = o.Condicion_de_Pago__c.substring(0, 4);
		if (request.I_Cabecera.ZTERM == 'ZC04' || request.I_Cabecera.ZTERM == 'ZC05')
			request.I_Cabecera.VALDT = '';
		else {
			//Condicion de pago, calculo de dias a partir de fecha de documento
			request.I_Cabecera.VALDT = String.valueOf(o.CloseDate).substring(0, 10);
		}

		step = 'Bloqueos';
		request.I_Cabecera.FAKSK = '';
		request.I_Cabecera.LIFSK = '';
		request.I_Cabecera.ABGRU = '';

		step = 'Clientes'; //Cuentas de Cliente y Distribuidor
		request.I_Cabecera.KUNRE = o.Account.CodigoSAP__c.trim();
		request.I_Cabecera.KUNAG = o.Account.CodigoSAP__c.trim();
		if (o.Branch_Name__c != null)
			request.I_Cabecera.KUNAG = o.Branch_Name__r.CodigoSAP__c.trim(); //solic

		request.I_Cabecera.KUNRG = o.Account.CodigoSAP__c.trim(); //resp pago
		if (o.Ship_To__c != null)
			request.I_Cabecera.KUNWE = o.Ship_To__r.CodigoSAP__c.trim(); //desti

		request.I_Cabecera.KUNZD = '';
		request.I_Cabecera.KUNZF = '';
		request.I_Cabecera.KUNZG = '';

		step = 'Fechas';
		request.I_Cabecera.AUDAT = String.valueOf(o.CloseDate).substring(0, 10);

		if (o.Type == 'Z6 - Royalty') {
			request.I_Cabecera.VDATU = String.valueOf(Date.today()).substring(0, 10); //String.valueOf(o.Fecha_de_Despacho__c).substring(0,10);
		} else {
			request.I_Cabecera.VDATU = String.valueOf(o.CloseDate).substring(0, 10); //String.valueOf(o.Fecha_de_Despacho__c).substring(0,10);
		}

		step = 'Clase de documento de ventas';
		request.I_Cabecera.AUART = o.Tipo__c.substring(0, 4);
		request.I_Cabecera.VGBEL = '';
		request.I_Cabecera.AUGRU = o.Type.substring(0, 3).trim(); //Motivo de pedido

		step = 'Incoterms';
		request.I_Cabecera.INCO1 = '';
		request.I_Cabecera.INCO2 = '';
		if (o.Incoterm_1__c != null)
			request.I_Cabecera.INCO1 = o.Incoterm_1__c.substring(0, 3);
		if (o.Incoterm_2__c != null)
			request.I_Cabecera.INCO2 = o.Incoterm_2__c.trim();

		step = 'Grupo de condiciones de clientes, Solo CEREAL';
		request.I_Cabecera.KDKG1 = '';

		step = 'Sector';
		if (o.type.contains('ROYALTY') || o.Type.contains('REPLANT'))
			request.I_Cabecera.SPART = '02'; //regalias
		else
			request.I_Cabecera.SPART = '01'; //Semillas

		step = 'Canal';
		request.I_Cabecera.VTWEG = '01'; //directo
		if (o.Tipo__c.substring(0, 4) == 'ZPEX')
			request.I_Cabecera.VTWEG = '02';

		step = 'Oficina de vtas';
		request.I_Cabecera.VKBUR = 'US01';
		if (o.Sales_Office__c != null)
			request.I_Cabecera.VKBUR = o.Sales_Office__c.substring(0, 4); // Oficina de Ventas

		step = 'Grupo Vendedores';
		request.I_Cabecera.VKGRP = '002';
		if (o.Owner.Grupo_de_Vendedores__c != null)
			request.I_Cabecera.VKGRP = o.Owner.Grupo_de_Vendedores__c.substring(0, 3);

		request.I_Cabecera.VKORG = '01US'; //Organizacion de Ventas

		empresa = '01US';
		if (o.Company__c == 'B&B') {
			step = 'Company B&B';
			empresa = '02US';
			//request.I_Cabecera.VKBUR = 'US00';    //If company is B&B
			request.I_Cabecera.VKGRP = '001';
			request.I_Cabecera.VKORG = '02US';
		}

		System.debug('opportunity &&' + o);

		step = 'interlocutores';
		request.T_Interlocutores = new sapAltaPedidoS4.ZSSD_PEDIDO_INTERLOCUTORES_TAB();
		request.T_Interlocutores.item = new List<sapAltaPedidoS4.ZSSD_PEDIDO_INTERLOCUTORES>();

		step = 'productos';
		request.T_Posiciones = new sapAltaPedidoS4.ZSSD_PEDIDO_POS_TAB();
		request.T_Posiciones.item = new List<sapAltaPedidoS4.ZSSD_PEDIDO_POS>();

		request.T_Condiciones = new sapAltaPedidoS4.ZSSD_PEDIDO_COND_TAB();
		request.T_Condiciones.item = new List<sapAltaPedidoS4.ZSSD_PEDIDO_COND>();

		request.T_Textos = new sapAltaPedidoS4.ZSSD_TEXTOS_TAB();
		request.T_Textos.item = new List<sapAltaPedidoS4.ZSSD_TEXTOS>();

		if (o.Contact_of_Shipping__c != null) {
			if (o.Contact_of_Shipping__r.Name != null) {
				sapAltaPedidoS4.ZSSD_TEXTOS oppNotes = new sapAltaPedidoS4.ZSSD_TEXTOS();
				oppNotes.Text_Id = '0006';
				oppNotes.Langu = 'E';
				oppNotes.Text_Line = o.Contact_of_Shipping__r.Name;
				request.T_Textos.item.add(oppNotes);
			}
		}

		System.debug('opportunity.OpportunityLineItems&&' + o.OpportunityLineItems);

		//repite la rutina por cada producto de la oportunidad
		for (OpportunityLineItem ol : o.OpportunityLineItems) {
			sapAltaPedidoS4.ZSSD_PEDIDO_POS i = new sapAltaPedidoS4.ZSSD_PEDIDO_POS();
			i.Zzpossf = ol.Id;
			i.VGPOS = '000000';

			step = 'Plant';
			i.WERKS = 'U001';
			if (o.Company__c == 'B&B') {
				i.WERKS = 'E001';
			}
			if (ol.Centro_de_Despacho__c != null && ol.Centro_de_Despacho__c != '') {
				i.WERKS = ol.Centro_de_Despacho__c.substring(0, 4);
				i.VSTEL = ol.Centro_de_Despacho__c.substring(0, 4);
			}

			step = 'Warehouse';
			// Valor default
			if (request.I_Cabecera.SPART == '02') {
				// En caso de ser Royalty mandar este valor vacio
				i.LGORT = '';
			} else {
				if (ol.warehouse__c != null && ol.warehouse__c != '')
					i.LGORT = ol.warehouse__c.substring(0, 4);
			}

			step = 'Cantidad del pedido';
			i.KWMENG = String.valueOf(ol.Quantity);

			step = 'Orden de CO';
			//i.AUFNR = '000000300003';  //S4
			//for(Centro_de_CO_Item__c centro : [Select c.Centro_de_CO__c, Centro_de_CO__r.Orden__c from Centro_de_CO_Item__c c Where c.Centro_de_CO__r.Sociedad__c = :empresa and c.Centro_de_CO__r.Campania__c = :o.safra__c And c.producto__c = :ol.Product2Id])
			//    i.AUFNR = centro.Centro_de_CO__r.Orden__c;

			if (materialCostOrder.containsKey(ol.product2Id))
				i.Aufnr = materialCostOrder.get(ol.product2Id);
			else
				i.Aufnr = '';

			step = 'Calibre, Grupo de materiales';
			i.MVGR1 = '';
			i.MVGR2 = '';

			i.MVGR4 = '';

			i.Cfop = '';
			i.BSTKD_E = 'FINAL TEST US';
			i.VRKME = '';

			step = 'material';
			i.MATNR = ol.Product2.Codigo_material_SAP__c;

			request.T_Posiciones.item.add(i);

			Decimal ZPRL = 0.0;
			Decimal ZFLE = 0.0;
			Decimal PR00 = 0.0;
			Decimal ZPAL = 0.0;
			Decimal Z100 = 0.0;

			Double venta;
			Double shipping;
			Double precioPallet;

			if (ol.Pallet_Charge__c != null) {
				//El usuario ingresa el valor x unidad para que lo multiplique despues SAP.
				precioPallet = ol.Pallet_Charge__c;
				ZPAL = Decimal.valueOf(precioPallet);
				ZPAL = ZPAL.divide(1, 2, System.RoundingMode.UP);
			}

			venta = ol.UnitPrice;
			PR00 = Decimal.valueOf(venta);
			PR00 = PR00.divide(1, 2, System.RoundingMode.UP);

			if (venta == 0) {
				//Normalmente podria usarse en el caso de TEST SEED que sale con precio 0. En ese caso se envia un valor y su descuento.
				PR00 = ol.ListPrice;
				Z100 = Decimal.valueOf(1);
			}

			if (PR00 != 0) {
				sapAltaPedidoS4.ZSSD_PEDIDO_COND ICond1 = new sapAltaPedidoS4.ZSSD_PEDIDO_COND();
				ICond1.ZZPOSSF = ol.Id;
				ICond1.KSCHL = 'PR00';
				ICond1.KMEIN = '';
				ICond1.WAERS = 'USD';
				// to include three decimal places in pricing in the sales orders, when the product is LB
				if (ol.Product2.Unidade__c == 'LB') {
					ICond1.Kbetr = String.valueOf((PR00 * 10000).divide(1, 2, System.RoundingMode.HALF_EVEN));
					ICond1.Kpein = '10000';
				} else {
					ICond1.Kbetr = String.valueOf(PR00);
					ICond1.Kpein = '1';
				}
				request.T_Condiciones.item.add(ICond1);
			}
			if (Z100 != 0) {
				sapAltaPedidoS4.ZSSD_PEDIDO_COND ICond1 = new sapAltaPedidoS4.ZSSD_PEDIDO_COND();
				ICond1.ZZPOSSF = ol.Id;
				ICond1.KSCHL = 'Z100';
				ICond1.Kbetr = '100';
				ICond1.Kpein = '';
				ICond1.Kmein = '';
				ICond1.Waers = 'USD';
				request.T_Condiciones.item.add(ICond1);
			}
			if (ZPAL != 0) {
				sapAltaPedidoS4.ZSSD_PEDIDO_COND ICond3 = new sapAltaPedidoS4.ZSSD_PEDIDO_COND();
				ICond3.ZZPOSSF = ol.Id;
				ICond3.KSCHL = 'ZPAL';
				ICond3.KMEIN = '';
				ICond3.Kbetr = String.valueOf(ZPAL);
				ICond3.Kpein = '1';
				request.T_Condiciones.item.add(ICond3);
			}
		}

		return JSON.serialize(request);
	}

	@future(callout=true)
	private static void outboundIntegration(
		String queueId,
		String recordId,
		String eventName,
		String payload,
		Integer target
	) {
		sapAltaPedidoS4.Z_SD_ALTA_PEDIDO soap = new sapAltaPedidoS4.Z_SD_ALTA_PEDIDO();
		sapAltaPedidoS4.Z_SD_ALTA_PEDIDOResponse_element resultado;
		sapAltaPedidoS4.BAPIRET2_TAB mensajes;

		String mens = '';

		sapAltaPedidoS4.Z_SD_ALTA_PEDIDO_element request_x = (sapAltaPedidoS4.Z_SD_ALTA_PEDIDO_element) JSON.deserialize(
			payload,
			sapAltaPedidoS4.Z_SD_ALTA_PEDIDO_element.class
		);
		sapAltaPedidoS4.ZSSD_PEDIDO_CAB ICab = request_x.I_Cabecera;
		sapAltaPedidoS4.ZSSD_PEDIDO_COND_TAB TCond = request_x.T_Condiciones;
		sapAltaPedidoS4.ZSSD_PEDIDO_INTERLOCUTORES_TAB TInter = request_x.T_Interlocutores;
		sapAltaPedidoS4.ZSSD_PEDIDO_POS_TAB TPos = request_x.T_Posiciones;
		sapAltaPedidoS4.ZSSD_TEXTOS_TAB textosTab = request_x.T_Textos;
		sapAltaPedidoS4.ZSSD_TIPO_CAMBIO_TAB tipoCambioTab = request_x.T_Tipocambio;

		SAPEndpoint__c endpoint = SAPEndpoint__c.getOrgDefaults();
		System.debug('Insert S4');
		try {
			soap.inputHttpHeaders_x = new Map<String, String>();
			String encodedusernameandpassword;

			String myData = endpoint.Username__c + ':' + endpoint.Password__c;
			//String myData = 'SALESFORCEUS:2o21gdms33dS';

			Blob hash = Blob.valueOf(myData);
			encodedusernameandpassword = EncodingUtil.base64Encode(hash);
			soap.timeout_x = 90000;
			soap.inputHttpHeaders_x.put('Authorization', 'Basic ' + encodedusernameandpassword);

			resultado = soap.Z_SD_ALTA_PEDIDO(ICab, TCond, TInter, TPos, textosTab, tipoCambioTab);

			ProcessControl.ignoredByTrigger = true;

			mensajes = resultado.T_Return;

			if (resultado.E_Subrc == 0) {
				system.debug(resultado.E_Subrc);
				system.debug(resultado.E_Nro_Pedido);
				Opportunity opp = new Opportunity(
					Id = recordId,
					Fecha_de_Alta_SAP__c = System.now(),
					Nro_Pedido_SAP__c = resultado.E_Nro_Pedido,
					Status_Integracion__c = 'Integraded'
				);
				update opp;

				if (resultado.T_Rel_Pos.item != null) {
					List<OpportunityLineItem> items = new List<OpportunityLineItem>();
					for (sapAltaPedidoS4.ZSSD_POS_SF_SAP i : resultado.T_Rel_Pos.item) {
						items.add(new OpportunityLineItem(Id = i.Zzpossf, Posicion_Relativa_Consign__c = i.Posnr));
					}
					update items;
				}
			} else {
				update new Opportunity(Id = recordId, Status_Integracion__c = 'Integration Error');
			}

			if (mensajes.item != null) {
				for (Integer i = 0; i < mensajes.item.size(); i++)
					mens += mensajes.item[i].Message + '\n';

				for (Integer i = 0; i < mensajes.item.size(); i++) {
					if (mensajes.item[i].Number_x == '990')
						update new Opportunity(Id = recordId, Status_Integracion__c = 'Integraded - Locked by Credit');
				}
			}

			if (resultado.E_Subrc == 0)
				QueueBO.getInstance().updateQueueConfirm(queueId, eventName + ' - ' + JSON.serialize(resultado), mens);
			else
				QueueBO.getInstance().updateQueue(queueId, eventName, mens);
		} catch (CalloutException ex) {
			ProcessControl.ignoredByTrigger = true;
			update new Opportunity(Id = recordId, Status_Integracion__c = 'Integration Error');
			QueueBO.getInstance()
				.updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString(), ex.getMessage());
		} catch (DmlException ex) {
			ProcessControl.ignoredByTrigger = true;
			update new Opportunity(Id = recordId, Status_Integracion__c = 'Integration Error');
			QueueBO.getInstance()
				.updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString(), ex.getMessage());
		} catch (Exception ex) {
			ProcessControl.ignoredByTrigger = true;
			update new Opportunity(Id = recordId, Status_Integracion__c = 'Integration Error');
			QueueBO.getInstance()
				.updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString(), ex.getMessage());
		}
	}
}