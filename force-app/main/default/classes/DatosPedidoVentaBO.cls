public with sharing class DatosPedidoVentaBO {
	private static DatosPedidoVentaBO instance = new DatosPedidoVentaBO();
	private DatosPedidoVentaBO() {
	}

	public static DatosPedidoVentaBO getInstance() {
		return instance;
	}

	public DatosPedidoVentaVF getPedidoVenda(String idPedidoVenda) {
		DatosPedidoVentaVF dadosPedido = new DatosPedidoVentaVF();
		try {
			Opportunity opp = [
				SELECT
					Id,
					Company__c,
					Name,
					Account.Name,
					Branch_Name__r.Name,
					Branch_Name__r.BillingStreet,
					Branch_Name__r.BillingCity,
					Branch_Name__r.BillingState,
					Branch_Name__r.BillingPostalCode,
					Branch_Name__r.BillingCountry,
					Description,
					Account.BillingStreet,
					Account.BillingCity,
					Account.BillingState,
					Account.BillingPostalCode,
					Account.BillingCountry,
					Ship_To__r.Name,
					Ship_To__r.ShippingStreet,
					Ship_To__r.ShippingCity,
					Ship_To__r.ShippingState,
					Ship_To__r.ShippingPostalCode,
					Ship_To__r.ShippingCountry,
					Ship_To__r.BillingCity,
					Ship_To__r.BillingCountry,
					Ship_To__r.BillingPostalCode,
					Ship_To__r.BillingState,
					Ship_To__r.BillingStreet,
					Attendance__r.Name,
					CloseDate,
					Owner.Name,
					Incoterm_1__c,
					Incoterm_2__c,
					toLabel(Type)
				FROM Opportunity
				WHERE Id = :idPedidoVenda
			];

			if (opp.Company__c == 'GDM') {
				dadosPedido.loadDataCabecalhoGDM();
				dadosPedido.salePayment = '30 days upon receipt of applicable invoice, as issued by GDM. A service charge of 1.5% per month (18% per annum) will be added on all accounts over 30 days.';
				dadosPedido.saleApplica = 'Buyer agrees and understands that he will receive the Seeds as detailed herein, subject to that certain soybean license agreement (the “SLA”) entered into by and between GDM Seeds Inc. and Buyer. Buyer will abide by all terms and conditions set forth therein and use the Seed for said purposes only, and in particular, agrees that if Buyer is receiving Testing Seed, it shall be used exclusively for non-for-profit purposes, as further detailed in the SLA. This Confirmation of Sale shall be construed consistently with the provisions of the SLA, and in the event of any conflicts, the provisions of the SLA shall prevail. Governing Law and Submission to Jurisdiction provisions as set forth in the SLA shall be applicable to this instrument, as well.';
				dadosPedido.saleSupport = 'Questions concerning this order? Contact Sales Administration at salesadminusa@gdmseeds.com.';
			} else {
				dadosPedido.loadDataCabecalhoBB();
				dadosPedido.salePayment = '30 days upon receipt of applicable invoice, as issued by B&B Seeds, LLC. A service charge of 1.5% per month (18% per annum) will be added on all accounts over 30 days.';
				dadosPedido.saleApplica = 'Buyer agrees and understands that he will receive the Seeds as detailed herein, subject to that certain soybean license agreement titled DONMARIO® GROWPRO PARTNER AGREEMENT entered into by and  between B&B SEEDS, LLC. and Buyer. Buyer will abide by all terms and conditions set forth therein and use the Seed for said purposes. This Confirmation of Sale shall be construed consistently with the provisions of the above referred agreement, and in the event of any conflicts, the provisions of the such agreement shall prevail. Governing Law and Submission to Jurisdiction provisions as set forth in the agreement shall be applicable to this instrument, as well.';
				dadosPedido.saleSupport = 'Questions concerning this order? Contact Sales Administration at salesadminusa@gdmseeds.com.';
			}

			dadosPedido.oppName = opp.Name;
			dadosPedido.oppOwnerName = opp.Owner.Name;
			String month = opp.CloseDate.month() < 10 ? '0' + opp.CloseDate.month() : '' + opp.CloseDate.month();
			String day = opp.CloseDate.day() < 10 ? '0' + opp.CloseDate.day() : '' + opp.CloseDate.day();
			String formatedDate = month + '/' + day + '/' + opp.CloseDate.year();
			dadosPedido.oppCloseDate = formatedDate;
			dadosPedido.BillToName = opp.Account.Name; // + ' ("Buyer")';
			dadosPedido.ShipToName = opp.Ship_To__r.Name; // + ' ("D.A.")';
			dadosPedido.BranchName = opp.Branch_Name__r.Name; // + ' ("Branch")';
			dadosPedido.BillToAddress = opp.Account.BillingStreet;
			if (opp.Ship_To__r.BillingStreet != null)
				dadosPedido.ShipToAddress = opp.Ship_To__r.BillingStreet;
			dadosPedido.BillToCityZip =
				opp.Account.BillingCity +
				', ' +
				opp.Account.BillingState +
				' ' +
				opp.Account.BillingPostalCode;
			if (opp.Ship_To__r.BillingCity != null)
				dadosPedido.ShipToCityZip = opp.Ship_To__r.BillingCity;
			if (opp.Ship_To__r.BillingState != null)
				dadosPedido.ShipToCityZip =
					dadosPedido.ShipToCityZip +
					', ' +
					opp.Ship_To__r.BillingState +
					' ' +
					opp.Ship_To__r.BillingPostalCode;

			if (opp.Attendance__c != null)
				dadosPedido.BillToContact = opp.Attendance__r.Name;

			//String inc2 = opp.Incoterm_2__c != null ? ' (' + opp.Incoterm_2__c + ')' : '';

			dadosPedido.saleDescription = opp.Description;
			dadosPedido.saleIncoterm = opp.Incoterm_1__c; // + inc2;
			//dadosPedido.saleShipment = 'Upon Request following the license Agreement\'s "Notices" provisions.';
			//dadosPedido.saleShippedBy = 'Buyer';

			for (OpportunityLineItem item : [SELECT	Id,	
													Quantity,
													Quantity_by_140k__c,
													Price_by_140k__c,
													Variedade_de_Produto__c,
													UnitPrice,
													Product2.UNIDADE__c,
													Product2.Family
											FROM OpportunityLineItem
											WHERE OpportunityId = :idPedidoVenda 
											AND Product2.Family != 'Freight' 
											AND Motivo_de_Rechazo__c = null 
											ORDER BY Variedade_de_Produto__c ASC]) {

				DatosPedidoVentaVF.Produto prdn = new DatosPedidoVentaVF.Produto();
				prdn.units = String.valueOf(item.Quantity_by_140k__c); //'&nbsp;';
				prdn.originator = item.Variedade_de_Produto__c;
				prdn.product = opp.Type;
				prdn.unitType = item.Product2.UNIDADE__c;
				prdn.quantity = item.Quantity;
				if (item.Product2.UNIDADE__c == 'BAG 140k')
					prdn.unitType = 'PAPER BAG';
				if (item.Product2.UNIDADE__c == 'BAG 40(140k)')
					prdn.unitType = 'BB';
				prdn.price = '$ ' + String.valueOf(item.Price_by_140k__c);
				dadosPedido.lstDadosProduto.add(prdn);
			}
		} catch (exception e) {
			System.debug('Exception error:  ' +e.getStackTraceString());
			return null; //e.getMessage() + '' + e.getLineNumber();
		}

		return dadosPedido;
	}
}