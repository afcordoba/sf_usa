/**
 * @description       : Process to retreived all documents made in SAP and update all the opportunity line items related to them.
 * @author            : 
 * @group             : 
 * @last modified on  : 01-17-2023
 * @last modified by  : Santiago Muñoz
 * @last modified by  : pablo.fraquia@cloudgaia.com for #30879
 * 					  : 03-31-2023
 *                      BOL_Number__c field added in OpportnityLineItem query (actItems() method)
 *                    : 04-11-2023
 *                      consultarFlujoDoc method updated to avoid mass creation of scheduled jobs
 * 					  : 04-25-2023
 *						Code optimization to reduce the amount of time the CPU is utilized
 *@last modified by  :  pablo.fraquia@cloudgaia.com for #30996					  
 * 					 :  05-03-2023
 * 					    Updated the setting of item.BOL_Number__c and item.Invoice_Number__c 
 *    					variables to avoid null responses.	
**/
global class sapFlujoDoc_caller {

	/**
	 * @description Looks for all the Bitacoras and then executes on process per each.
	*
	* @return      `string`
	*/	
	webService static string consultarFlujoDoc() {
		/*
		List<Bitacora_NC__c> regBitacora = [SELECT Id, vbtyp__c, fkart__c, Fecha_Desde__c, Fecha_hasta__c, numero_lote__c, sociedad__c
											FROM Bitacora_NC__c
											WHERE numero_lote__c > 0];
		
		for (Bitacora_NC__c b : regBitacora) {
		*/
		for(Bitacora_NC__c b : [SELECT Id, vbtyp__c, fkart__c, Fecha_Desde__c, Fecha_hasta__c, numero_lote__c, sociedad__c
								FROM Bitacora_NC__c
								WHERE numero_lote__c > 0]) {
			procesos(b.Id,
					 b.sociedad__c,
					 b.vbtyp__c,
					 b.fkart__c,
					 b.fecha_desde__c,
					 b.fecha_hasta__c,
					 Integer.valueOf(b.numero_lote__c) + 1);
		}

		String ss = String.valueOf(Datetime.now().second());
		String min = String.valueOf(Datetime.now().minute() + 1);
		String hour = String.valueOf(Datetime.now().hour());
		String day = String.valueOf(Datetime.now().day());
		String month = String.valueOf(Datetime.now().month());
		String year = String.valueOf(Datetime.now().year());
	
		String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
	
		schedulableFlujoDocUpdate s = new schedulableFlujoDocUpdate(); 
		System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);

		return 'Termino';
	}

	@future(callout=true)
	/**
	 * @description        Retrieves the data from SAP of the document type in the Bitacora
	*
	* @param bitId        Bitacora Record Id
	* @param arg_bukrs    
	* @param arg_vbtyp    
	* @param arg_fkart    Document Type in SAP
	* @param arg_desde    First day retrieved from SAP
	* @param arg_hasta    Last day retrieved from SAP
	* @param arg_nro_lote 
	*/	
	webService static void procesos(
		Id bitId,
		String arg_bukrs,
		String arg_vbtyp,
		String arg_fkart,
		Date arg_desde,
		Date arg_hasta,
		Integer arg_nro_lote
	) {
		SavePoint sp;
		Decimal cantidadSAP = 0;
		Decimal cantidadSF = 0;
		String sociedad;
		List<Flujo_Doc_tmp__c> tmps = new List<Flujo_Doc_tmp__c>();

		SAPEndpoint__c endpoint = SAPEndpoint__c.getOrgDefaults();

		try {

			Integer mandanteSAP = 1;
			Configuracion_USA__c c = [SELECT FC_Mandante_SAP__c FROM Configuracion_USA__c LIMIT 1];

			mandanteSAP = Integer.valueOf(c.FC_Mandante_SAP__c);
			sociedad = arg_bukrs;

			Date hasta = arg_hasta;
			if (arg_hasta == null)
				hasta = System.today();
			Date desde = arg_desde;

			String s_ayer_mes = String.valueOf(desde.month());
			String s_hoy_mes = String.valueOf(hasta.month());
			String s_ayer_dia = String.valueOf(desde.day());
			String s_hoy_dia = String.valueOf(hasta.day());
			if (Integer.valueOf(s_ayer_mes) < 10)
				s_ayer_mes = '0' + s_ayer_mes;
			if (Integer.valueOf(s_ayer_dia) < 10)
				s_ayer_dia = '0' + s_ayer_dia;
			if (Integer.valueOf(s_hoy_mes) < 10)
				s_hoy_mes = '0' + s_hoy_mes;
			if (Integer.valueOf(s_hoy_dia) < 10)
				s_hoy_dia = '0' + s_hoy_dia;

			String s_ayer = desde.year() + '-' + s_ayer_mes + '-' + s_ayer_dia;
			String s_hoy = hasta.year() + '-' + s_hoy_mes + '-' + s_hoy_dia;

			sapFlujoDocV6.ZSD_FLUJO_DOC_2 soap = new sapFlujoDocV6.ZSD_FLUJO_DOC_2();
			sapFlujoDocV6.ZSD_FLUJO_DOC_2Response_element result = new sapFlujoDocV6.ZSD_FLUJO_DOC_2Response_element();

			soap.inputHttpHeaders_x = new Map<String, String>();
			String encodedusernameandpassword;

			//String myData = 'donmario:donmario';
			String myData = endpoint.Username__c + ':' + endpoint.Password__c;

			Blob hash = Blob.valueOf(myData);
			encodedusernameandpassword = EncodingUtil.base64Encode(hash);

			soap.timeout_x = 110000;
			soap.inputHttpHeaders_x.put('Authorization', 'Basic ' + encodedusernameandpassword);
			if (!Test.isRunningTest()) {

				result = soap.ZSD_FLUJO_DOC_2(
					null,
					arg_bukrs,
					s_ayer,
					s_hoy,
					arg_fkart,
					'00:00:00',
					'23:59:59',
					arg_vbtyp,
					mandanteSAP
				);
			}
			if (result != null) {
				if (result.E_FLUJO_DOC.item != null) {
					sp = Database.setSavepoint();
					cantidadSAP = result.E_FLUJO_DOC.item.size();
					for (sapFlujoDocV6.ZSSD_FLUJO_DOC t : result.E_FLUJO_DOC.item) {
						Boolean skip = false;

						//for(Flujo_Doc_tmp__c f : oldTempList) {
						for(Flujo_Doc_tmp__c f : [SELECT Id, FKART__c, FKIMG__c, ZZPOSSF__c, Vbeln__c, Posnr__c
												  FROM Flujo_Doc_tmp__c
												  WHERE Fecha_Desde__c >= :desde]) {
							if(f.Posnr__c == t.POSNR && f.Vbeln__c == t.VBELN){
								skip = true;
							}
						}

						if(!skip) {
							Flujo_Doc_tmp__c doc = new Flujo_Doc_tmp__c();
							doc.FKART__c = t.Fkart;
							doc.FKIMG__c = decimal.valueOf(t.Fkimg);
							doc.NETWR__c = decimal.valueOf(t.Netwr);
							doc.POSNV__c = t.Posnv;
							doc.VBELV__c = t.Vbelv;
							doc.VBTYP__c = arg_vbtyp; // No lo trae de SAP
							doc.XBLNR__c = t.Xblnr;
							doc.WAERK__c = t.Waerk;
							doc.ZZPOSSF__c = t.Zzpossf; //'00kf0000005l9iBAAQ'; //
							doc.numero_lote__c = arg_nro_Lote;
							doc.Fecha_Desde__c = desde;
							doc.Fecha_Hasta__c = hasta;
							doc.KeyNfe__c = t.KEY_NFE;
							doc.Vbeln__c = t.VBELN; // Document/devolution in SAP id
							doc.Posnr__c = t.POSNR; // Position in document in SAP
							
							tmps.add(doc);
						}
					}
					insert tmps;
					cantidadSF = tmps.size();
				}
			} else {
				System.debug('NO RESULT');
			}

			Bitacora_nc__c bit = new Bitacora_nc__c(
				Id = bitId,
				Fecha_desde__c = hasta,
				Cantidad_Registros__c = cantidadSAP,
				Cantidad_Registros_SF__c = cantidadSF,
				numero_lote__c = arg_nro_lote,
				Copiado_desde_sap__c = true
			);
			update bit;

		} catch (Exception e) {

			System.debug('ERROR:  ' +e.getStackTraceString());

			if (sp == null)
				sp = Database.setSavepoint();

			Database.rollback(sp);

			Bitacora_nc__c bit = new Bitacora_nc__c(
				Id = bitId,
				Log__c = e.getMessage(),
				numero_lote__c = arg_nro_lote,
				Cantidad_Registros__c = cantidadSAP,
				Cantidad_Registros_SF__c = 0,
				Copiado_desde_sap__c = false
			);

			update bit;
		}
	}
	@future
	/**
	 * @description     Updates the opportunity line items from the Sap documents saved in the Flujo Doc Temps;
	*
	* @param arg_vbtyp  
	* @param arg_fkart 
	* @param sociedad  
	*/	
	webService static void actItems(String arg_vbtyp, String arg_fkart, String sociedad) {
		try {
			List<Id> itemIds = new List<Id>();
			List<String> itemRef = new List<String>();
			List<Flujo_Doc_tmp__c> fdocs_up = new List<Flujo_Doc_tmp__c>();
            List<Seed_Tracking__c> sTrackList = new List<Seed_Tracking__c>();
            List<Seed_Tracking__c> sTrackInsertList = new List<Seed_Tracking__c>();
            Map<Id, Seed_Tracking__c> sTrackUpdateMap = new Map<Id, Seed_Tracking__c>();
            Map<Id, Seed_Tracking__c> sTrackMap = new Map<Id, Seed_Tracking__c>();

			Map<Id, Flujo_Doc_tmp__c> mapFlujo = new Map<Id, Flujo_Doc_tmp__c>();
			Map<Id, OpportunityLineItem> mapOpp = new Map<Id, OpportunityLineItem>();
			Map<String, Flujo_Doc_tmp__c> mapFlujoAnul = new Map<String, Flujo_Doc_tmp__c>();

			List<Flujo_Doc_tmp__c> fdocs = [
				SELECT Id,ZZPOSSF__c, FKART__c, WAERK__c, FKIMG__c, VBTYP__c, NETWR__c, XBLNR__c, POSNV__c, VBELV__c, Vbeln__c, Posnr__c
				FROM Flujo_Doc_tmp__c
				WHERE
					FKART__c = :arg_fkart
					AND VBTYP__c = :arg_vbtyp
					AND ActualizadoEnOpLineItem__c = FALSE
					AND ZZPOSSF__c != ''
			];
			for (Flujo_Doc_tmp__c f : fdocs) {
				System.debug('@@@ f.Vbeln__c  ?  ' +f.Vbeln__c);
				System.debug('@@@ f.Posnr__c  ?  ' +f.Posnr__c);
				itemIds.add(f.ZZPOSSF__c); // traigo los id de los OpportunityLineItem a actualizar
				mapFlujo.put(f.ZZPOSSF__c, f);
			}

			List<OpportunityLineItem> items = new List<OpportunityLineItem>();
			items = [
				SELECT Id, CM_Amount__c, DB_Amount__c, Returned_Quantity__c, BOL_Number__c, Invoice_Number__c
				FROM OpportunityLineItem
				WHERE Id IN :itemIds
			];

			for (OpportunityLineItem item : items) {

				System.debug('@@@ item.BOL_Number__c  ?  ' +item.BOL_Number__c);
				System.debug('@@@ item.Invoice_Number__c  ?  ' +item.Invoice_Number__c);
				mapOpp.put(item.Id, item);
			}
            
            if(arg_fkart == 'ZE14' || arg_fkart == 'ZF13') {
                List<String> fields = new List<String>(Schema.getGlobalDescribe().get('Seed_Tracking__c').getDescribe().fields.getMap().keySet());
                String query  = 'SELECT '+String.join(fields, ',')+' FROM Seed_Tracking__c WHERE Opportunity_Product__c IN :itemIds AND Active__c = true';
                sTrackList = Database.query(query);
            }

			String x = '';
			if (arg_vbtyp == 'S') {
				for (Flujo_Doc_tmp__c d : fdocs) {
					itemRef.add(d.XBLNR__c);
				}

				for (Flujo_Doc_tmp__c f : [SELECT Id, ZZPOSSF__c, FKART__c, WAERK__c, FKIMG__c, VBTYP__c, NETWR__c, XBLNR__c, POSNV__c, VBELV__c
										   FROM Flujo_Doc_tmp__c
										   WHERE VBTYP__c != 'S' AND ZZPOSSF__c != '' AND XBLNR__c IN :itemRef]) {	
					mapFlujoAnul.put(f.XBLNR__c, f);
				}
			}

			for (Flujo_Doc_tmp__c documento : fdocs) {
				OpportunityLineItem item = mapOpp.get(documento.ZZPOSSF__c); //JERE
				if (item == null)
					continue;

				documento.ActualizadoEnOpLineItem__c = true;

				if ('ZC16' == documento.FKART__c || 'ZC15' == documento.FKART__c) {
					//NC DEVOLUCION
					item.Returned_Quantity__c = item.Returned_Quantity__c == null
						? 0 + documento.FKIMG__c
						: item.Returned_Quantity__c + documento.FKIMG__c;
				}

				//NOTAS DE CREDITO POR PRECIO
				if ('ZC14' == documento.FKART__c) {
					item.CM_Amount__c = item.CM_Amount__c == null
						? 0 + documento.NETWR__c
						: item.CM_Amount__c + documento.NETWR__c;
				}

				//NOTAS DE DEBITO X CANT
				if ('ZD02' == documento.FKART__c) {
					item.Returned_Quantity__c = item.Returned_Quantity__c == null
						? 0 - documento.FKIMG__c
						: item.Returned_Quantity__c - documento.FKIMG__c;
				}

				//NOTAS DE DEBITO X PRECIO
				if ('ZD01' == documento.FKART__c) {
					item.DB_Amount__c = item.DB_Amount__c == null
						? 0 + documento.NETWR__c
						: item.DB_Amount__c + documento.NETWR__c;
				}

				if ('ZE14' == documento.FKART__c) {
					for(Seed_Tracking__c s : sTrackList) {
						if((s.Delivery_SAP_ID__c == null || s.Delivery_SAP_ID__c == '') && s.Opportunity_Product__c == documento.ZZPOSSF__c) {
                            Seed_Tracking__c sTrack = sTrackUpdateMap.get(s.Id);
                            if(sTrack == null) {
                                sTrack = s;
                            }
                            
							if(sTrack.Status__c != 'Delivered' && sTrack.Quantity_by_140k__c == documento.FKIMG__c) {
								sTrack.Status__c = 'In Transit';
								sTrack.ETA_Customer__c = Date.today().addDays(3).format() +' - '+ Date.today().addDays(7).format();
								sTrack.Quantity_by_140k_in_Delivery__c =  documento.FKIMG__c;
								sTrack.Delivery_SAP_ID__c = documento.Vbeln__c;
								sTrack.Delivery_SAP_Item__c = documento.Posnr__c;

								sTrackUpdateMap.put(sTrack.Id, sTrack);

								//item.BOL_Number__c = item.BOL_Number__c + ';' + documento.Vbeln__c;
								item.BOL_Number__c = (item.BOL_Number__c == null) ? documento.Vbeln__c : item.BOL_Number__c + ' ; ' + documento.Vbeln__c;
								
							} else if (sTrack.Status__c != 'Delivered' && sTrack.Quantity_by_140k__c > documento.FKIMG__c) {
								Seed_Tracking__c sToInsert = sTrack.clone(false, true, false, false);
								sToInsert.Status__c = 'In Transit';
								sToInsert.ETA_Customer__c = Date.today().addDays(3).format() +' - '+ Date.today().addDays(7).format();
								sToInsert.Quantity_by_140k_in_Delivery__c = documento.FKIMG__c;
                                sToInsert.Quantity_by_140k__c = sTrack.Quantity_by_140k__c - documento.FKIMG__c;
								sToInsert.Delivery_SAP_ID__c = documento.Vbeln__c;
								sToInsert.Delivery_SAP_Item__c = documento.Posnr__c;
                                sToInsert.Id = null;

								sTrackInsertList.add(sToInsert);

								s.Quantity_by_140k__c = sTrack.Quantity_by_140k__c - documento.FKIMG__c;

								sTrackUpdateMap.put(sTrack.Id, sTrack);
								
								//item.BOL_Number__c = item.BOL_Number__c + ';' + documento.Vbeln__c;
								item.BOL_Number__c = (item.BOL_Number__c == null) ? documento.Vbeln__c : item.BOL_Number__c + ' ; ' + documento.Vbeln__c;
							}
						}
					}
                    
                }
                
				if ('ZF13' == documento.FKART__c ) {
					for(Seed_Tracking__c s : sTrackList) {
						if((s.Invoice_SAP_ID__c == null || s.Invoice_SAP_ID__c == '') && s.Status__c == 'In Transit' && s.Opportunity_Product__c == documento.ZZPOSSF__c && s.Quantity_by_140k__c == documento.FKIMG__c) {
							s.Status__c = 'Delivered';
							s.Invoice_SAP_ID__c = documento.Vbeln__c;
							s.Invoice_SAP_Item__c = documento.Posnr__c;
							s.ETA_Customer__c = Date.today().format();
							sTrackUpdateMap.put(s.Id, s);

							//item.Invoice_Number__c = item.Invoice_Number__c + ';' +documento.Vbeln__c;
							item.Invoice_Number__c = (item.Invoice_Number__c == null) ? documento.Vbeln__c : item.Invoice_Number__c + ' ; ' + documento.Vbeln__c;
							
						}
					}
				}

				//PROCESAR ANULACIONES
				if ('S' == documento.VBTYP__c) {
					Flujo_Doc_tmp__c docNC = mapFlujoAnul.get(documento.XBLNR__c);
					if (docNC == null)
						continue;

					if ('ZC16' == docNC.FKART__c || 'ZC15' == docNC.FKART__c)
						item.Returned_Quantity__c = item.Returned_Quantity__c == null
							? 0 - documento.FKIMG__c
							: item.Returned_Quantity__c - documento.FKIMG__c;

					if ('ZC14' == docNC.FKART__c) {
						item.CM_Amount__c = item.CM_Amount__c == null
							? 0 - documento.NETWR__c
							: item.CM_Amount__c - documento.NETWR__c;
					}
				}
			}

            if(arg_fkart == 'ZE14' || arg_fkart == 'ZF13') {

				update sTrackUpdateMap.values();
                insert sTrackInsertList;
            }

			update items;
			update fdocs;

			for(OpportunityLineItem updatedItem : items) {

				System.debug('@@@ updatedItem.BOL_Number__c  ?  ' +updatedItem.BOL_Number__c);
				System.debug('@@@ updatedItem.Invoice_Number__c  ?  ' +updatedItem.Invoice_Number__c);
			}

			for(Flujo_Doc_tmp__c updatedfdoc : fdocs) {

				System.debug('@@@ updatedfdoc.BOL_Number__c  ?  ' +updatedfdoc.Vbeln__c);
				System.debug('@@@ updatedfdoc.Invoice_Number__c  ?  ' +updatedfdoc.Vbeln__c);
			}

		} catch (DmlException ex) {

			System.debug('ERROR en actualizar OpportunityLineItem:  ' + ex.getStackTraceString());
		}
	}
}