public class OpportunityVtaIntegrationBO implements IProcessingQueue {
	/**
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

	public static String outboundRequest(Opportunity o) {
		String step = 'Inicio';
		String empresa; //'U001';
		sapAltaPedido.ZSdAltaPedido_element request = new sapAltaPedido.ZSdAltaPedido_element();

		//Cabecera
		request.ICabecera = new sapAltaPedido.ZssdPedidoCab();
		request.ICabecera.ZZnrosf = o.Name;
		request.ICabecera.ZZidsf = o.Id;

		request.ICabecera.WAERK = 'USD'; //moneda
		request.ICabecera.Zzcampana = o.safra__c;
		request.ICabecera.Zlsch = '';
		request.ICabecera.BSTZD = '';

		step = 'Condicion de Pago';
		request.ICabecera.ZTERM = o.Condicion_de_Pago__c.substring(0, 4);
		if (request.ICabecera.ZTERM == 'ZC04' || request.ICabecera.ZTERM == 'ZC05')
			request.ICabecera.VALDT = '';
		else {
			//Condicion de pago, calculo de dias a partir de fecha de documento
			request.ICabecera.VALDT = String.valueOf(o.CloseDate).substring(0, 10);
		}

		step = 'Bloqueos';
		request.ICabecera.FAKSK = '';
		request.ICabecera.LIFSK = '';
		request.ICabecera.ABGRU = '';

		step = 'Clientes'; //Cuentas de Cliente y Distribuidor
		request.ICabecera.KUNRE = o.Account.CodigoSAP__c.trim();
		request.ICabecera.KUNAG = o.Account.CodigoSAP__c.trim();
		if (o.Branch_Name__c != null)
			request.ICabecera.KUNAG = o.Branch_Name__r.CodigoSAP__c.trim(); //solic

		request.ICabecera.KUNRG = o.Account.CodigoSAP__c.trim(); //resp pago
		request.ICabecera.KUNWE = o.Ship_To__r.CodigoSAP__c.trim(); //desti
		request.ICabecera.KUNZD = '';
		request.ICabecera.KUNZF = '';
		request.ICabecera.KUNZG = '';

		step = 'Fechas';
		request.ICabecera.AUDAT = String.valueOf(o.CloseDate).substring(0, 10);
		if (o.Type == 'Z6 - Royalty') {
			request.ICabecera.VDATU = String.valueOf(Date.today()).substring(0, 10); //String.valueOf(o.Fecha_de_Despacho__c).substring(0,10);
		} else {
			request.ICabecera.VDATU = String.valueOf(o.CloseDate).substring(0, 10); //String.valueOf(o.Fecha_de_Despacho__c).substring(0,10);
		}

		step = 'Clase de documento de ventas';
		request.ICabecera.AUART = o.Tipo__c.substring(0, 4);
		request.ICabecera.VGBEL = '';
		request.ICabecera.AUGRU = o.Type.substring(0, 3); //Motivo de pedido, solo para CANJE o ESPECIE

		step = 'Incoterms';
		request.ICabecera.INCO1 = '';
		request.ICabecera.INCO2 = '';
		if (o.Incoterm_1__c != null)
			request.ICabecera.INCO1 = o.Incoterm_1__c.substring(0, 3);
		if (o.Incoterm_2__c != null)
			request.ICabecera.INCO2 = o.Incoterm_2__c.trim();

		step = 'Grupo de condiciones de clientes, Solo CEREAL';
		request.ICabecera.KDKG1 = '';

		step = 'Sector';
		if (o.type.contains('ROYALTY') || o.Type.contains('REPLANT'))
			request.ICabecera.SPART = '02'; //regalias
		else
			request.ICabecera.SPART = '01'; //Semillas

		step = 'Canal';
		request.ICabecera.VTWEG = '01'; //directo
		if (o.Tipo__c.substring(0, 4) == 'ZPEX')
			request.ICabecera.VTWEG = '02';

		step = 'Oficina de vtas';
		request.ICabecera.VKBUR = 'U001';
		if (o.Owner.Sap_Sales_Office__c != null)
			request.ICabecera.VKBUR = o.Owner.Sap_Sales_Office__c; // Oficina de Ventas

		step = 'Grupo Vendedores';
		request.ICabecera.VKGRP = '';
		if (o.Owner.Grupo_de_Vendedores__c != null)
			request.ICabecera.VKGRP = o.Owner.Grupo_de_Vendedores__c.substring(0, 3);

		request.ICabecera.VKORG = 'U001'; //Organizacion de Ventas

		empresa = 'U001';
		if (o.Company__c == 'B&B') {
			step = 'Company B&B';
			empresa = 'E002';
			request.ICabecera.VKBUR = 'E001'; //If company is B&B
			request.ICabecera.VKGRP = '334';
			request.ICabecera.VKORG = 'E002';
		}

		System.debug('opportunity &&' + o);

		step = 'interlocutores';
		request.TInterlocutores = new sapAltaPedido.ZssdPedidoInterlocutoresTab();
		request.TInterlocutores.item = new List<sapAltaPedido.ZssdPedidoInterlocutores>();

		step = 'productos';
		request.TPosiciones = new sapAltaPedido.ZSSD_PEDIDO_POS_TAB();
		request.TPosiciones.item = new List<sapAltaPedido.ZSSD_PEDIDO_POS>();

		request.TCondiciones = new sapAltaPedido.ZssdPedidoCondTab();
		request.TCondiciones.item = new List<sapAltaPedido.ZssdPedidoCond>();

		request.TTextos = new sapAltaPedido.ZssdTextosTab();
		request.TTextos.item = new List<sapAltaPedido.ZssdTextos>();

		if (o.Contact_of_Shipping__c != null) {
			if (o.Contact_of_Shipping__r.Name != null) {
				sapAltaPedido.ZssdTextos oppNotes = new sapAltaPedido.ZssdTextos();
				//oppNotes.Zzpossf = '';
				oppNotes.TextId = '0006';
				oppNotes.Langu = 'E';
				oppNotes.TextLine = o.Contact_of_Shipping__r.Name;
				request.TTextos.item.add(oppNotes);
			}
		}

		System.debug('opportunity.OpportunityLineItems&&' + o.OpportunityLineItems);

		//repite la rutina por cada producto de la oportunidad
		for (OpportunityLineItem ol : o.OpportunityLineItems) {
			sapAltaPedido.ZSSD_PEDIDO_POS i = new sapAltaPedido.ZSSD_PEDIDO_POS();
			i.Zzpossf = ol.Id;
			i.VGPOS = '';

			step = 'Centro de despacho';
			i.WERKS = 'U001';
			if (ol.Centro_de_Despacho__c != null && ol.Centro_de_Despacho__c != '')
				i.WERKS = ol.Centro_de_Despacho__c.substring(0, 4);

			step = 'Cantidad del pedido';
			i.KWMENG = String.valueOf(ol.Quantity);
			step = 'Orden de CO';
			i.AUFNR = 'VTA';
			for (Centro_de_CO_Item__c centro : [
				SELECT c.Centro_de_CO__c, Centro_de_CO__r.Orden__c
				FROM Centro_de_CO_Item__c c
				WHERE
					c.Centro_de_CO__r.Sociedad__c = :empresa
					AND c.Centro_de_CO__r.Campania__c = :o.safra__c
					AND c.producto__c = :ol.Product2Id
			])
				i.AUFNR = centro.Centro_de_CO__r.Orden__c;

			step = 'Calibre, Grupo de materiales';
			i.MVGR1 = '';
			i.MVGR2 = '';
			i.VSTEL = '';
			i.MVGR4 = '';
			i.LGORT = '';
			i.Cfop = '';
			i.BSTKD_E = '';
			i.VRKME = '';

			step = 'material';
			i.MATNR = ol.Product2.Codigo_material_SAP__c;

			request.TPosiciones.item.add(i);

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

			/*
            if(ol.Shipping_Costs__c != null){
                shipping = ol.Shipping_Costs__c;
                ZFLE = Decimal.valueOf(shipping);                
                ZFLE = ZFLE.divide(1, 2, System.RoundingMode.UP);
            }
  */
			venta = ol.UnitPrice;
			PR00 = Decimal.valueOf(venta);
			PR00 = PR00.divide(1, 2, System.RoundingMode.UP);

			if (venta == 0) {
				//Normalmente podria usarse en el caso de TEST SEED que sale con precio 0. En ese caso se envia un valor y su descuento.
				PR00 = Decimal.valueOf(1);
				Z100 = Decimal.valueOf(1);
			}

			if (PR00 != 0) {
				sapAltaPedido.ZssdPedidoCond ICond1 = new sapAltaPedido.ZssdPedidoCond();
				ICond1.ZZPOSSF = ol.Id;
				ICond1.KSCHL = 'PR00';
				ICond1.KMEIN = '';

				// to include three decimal places in pricing in the sales orders, when the product is LB
				if (ol.Product2.Unidade__c == 'LB') {
					ICond1.Kbetr = String.valueOf((PR00 * 10000).divide(1, 2, System.RoundingMode.HALF_EVEN));
					ICond1.Kpein = '10000';
				} else {
					ICond1.Kbetr = String.valueOf(PR00);
					ICond1.Kpein = '1';
				}
				request.TCondiciones.item.add(ICond1);
			}
			if (Z100 != 0) {
				sapAltaPedido.ZssdPedidoCond ICond1 = new sapAltaPedido.ZssdPedidoCond();
				ICond1.ZZPOSSF = ol.Id;
				ICond1.KSCHL = 'Z100';
				ICond1.KMEIN = '';
				ICond1.Kbetr = '100';
				ICond1.Kpein = '';
				request.TCondiciones.item.add(ICond1);
			}
			if (ZPAL != 0) {
				sapAltaPedido.ZssdPedidoCond ICond3 = new sapAltaPedido.ZssdPedidoCond();
				ICond3.ZZPOSSF = ol.Id;
				ICond3.KSCHL = 'ZPAL';
				ICond3.KMEIN = '';
				ICond3.Kbetr = String.valueOf(ZPAL);
				ICond3.Kpein = '1';
				request.TCondiciones.item.add(ICond3);
			}
			/*            if (ZFLE != 0){ 
                sapAltaPedido.ZssdPedidoCond ICond6 = new sapAltaPedido.ZssdPedidoCond();
                ICond6.ZZPOSSF = ol.Id;
                ICond6.Kschl = 'ZFLE';
                ICond6.KMEIN = '';
                ICond6.Kbetr = String.valueOf(ZFLE);
                ICond6.Kpein = '1';
                request.TCondiciones.item.add(ICond6);
            }
 */
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
		sapAltaPedido.Z_SD_ALTA_PEDIDO soap = new sapAltaPedido.Z_SD_ALTA_PEDIDO();
		sapAltaPedido.ZSdAltaPedidoResponse_element resultado;
		sapAltaPedido.Bapiret2Tab mensajes;

		String mens = '';

		sapAltaPedido.ZSdAltaPedido_element request_x = (sapAltaPedido.ZSdAltaPedido_element) JSON.deserialize(
			payload,
			sapAltaPedido.ZSdAltaPedido_element.class
		);
		sapAltaPedido.ZssdPedidoCab ICab = request_x.ICabecera;
		sapAltaPedido.ZssdPedidoCondTab TCond = request_x.TCondiciones;
		sapAltaPedido.ZssdPedidoInterlocutoresTab TInter = request_x.TInterlocutores;
		sapAltaPedido.ZSSD_PEDIDO_POS_TAB TPos = request_x.TPosiciones;
		sapAltaPedido.ZssdTextosTab textosTab = request_x.TTextos;
		sapAltaPedido.ZssdTipoCambioTab tipoCambioTab = request_x.TTipocambio;

		SAPEndpoint__c endpoint = SAPEndpoint__c.getOrgDefaults();

		try {
			soap.inputHttpHeaders_x = new Map<String, String>();
			String encodedusernameandpassword;

			String myData = endpoint.Username__c + ':' + endpoint.Password__c;

			Blob hash = Blob.valueOf(myData);
			encodedusernameandpassword = EncodingUtil.base64Encode(hash);
			soap.timeout_x = 90000;
			soap.inputHttpHeaders_x.put('Authorization', 'Basic ' + encodedusernameandpassword);

			resultado = soap.ZSdAltaPedido(ICab, TCond, TInter, TPos, textosTab, tipoCambioTab, String.valueOf(target));

			ProcessControl.ignoredByTrigger = true;

			mensajes = resultado.TReturn;

			if (resultado.ESubrc == 0) {
				system.debug(resultado.ESubrc);
				system.debug(resultado.ENroPedido);
				Opportunity opp = new Opportunity(
					Id = recordId,
					Fecha_de_Alta_SAP__c = System.now(),
					Nro_Pedido_SAP__c = resultado.ENroPedido,
					Status_Integracion__c = 'Integraded'
				);
				update opp;

				if (resultado.TRelPos.item != null) {
					List<OpportunityLineItem> items = new List<OpportunityLineItem>();
					for (sapAltaPedido.ZssdPosSfSap i : resultado.TRelPos.item) {
						items.add(new OpportunityLineItem(Id = i.Zzpossf, Posicion_Relativa_Consign__c = i.Posnr));
					}
					update items;
				}
			} else {
				update new Opportunity(Id = recordId, Status_Integracion__c = 'Integration Error');
			}

			for (Integer i = 0; i < mensajes.item.size(); i++)
				mens += mensajes.item[i].Message + '\n';

			for (Integer i = 0; i < mensajes.item.size(); i++) {
				if (mensajes.item[i].Number_x == '990')
					update new Opportunity(Id = recordId, Status_Integracion__c = 'Integraded - Locked by Credit');
			}

			QueueBO.getInstance().updateQueueConfirm(queueId, eventName + ' - ' + JSON.serialize(resultado), mens);
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