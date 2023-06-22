@isTest
private class DatosPedidoVentaControllerTest {
	@TestSetup
	static void makeData() {
		Contact aContact = new Contact(FirstName = 'Fake contact', LastName = 'Fake');
		insert aContact;
		Account anAccount = Build.anAccount()
			.withName('Test account')
			.withShippingCity('New York')
			.withShippingCountry('United states')
			.withShippingState('NY')
			.withShippingStreet('Fake street 123')
			.withShippingPostalCode('1234')
			.withBillingCity('New york')
			.withBillingState('NY')
			.withBillingCountry('United States')
			.withBillingPostalCode('1234')
			.withBillingStreet('Fake street')
			.build();
		insert anAccount;
		Opportunity theOppGDM = Build.anOpportunity()
			.withAccountId(anAccount)
			.withActiva(true)
			.withCompany('GDM')
			.withDescription('Desc')
			.withCloseDate(date.today())
			.withShipTo(anAccount)
			.withBranchName(anAccount)
			.withType('Z2 - PARENT SEED')
			.withAttendance(aContact)
			.build();
		insert theOppGDM;
		Opportunity theOppVirtue = Build.anOpportunity()
			.withAccountId(anAccount)
			.withActiva(true)
			.withCompany('B&B')
			.withDescription('Desc')
			.withCloseDate(date.today())
			.withShipTo(anAccount)
			.withBranchName(anAccount)
			.withType('Z2 - PARENT SEED')
			.withCloseDate(date.today())
			.withAttendance(aContact)
			.build();
		insert theOppVirtue;
		Product2 aProduct = Build.aProduct2().withName('Test prod').withUNIDADE('BAG 40(140K').build();
		insert aProduct;
		Variedad__c variety = Build.aVariedad().withName('Test variety').build();
		insert variety;
		Pricebook2 aPricebook = Build.aPricebook2()
			.withBrand('GDM')
			.withIsActive(true)
			.withDescription('Desc')
			.withName('Test pb')
			.build();
		insert aPricebook;
		PricebookEntry standarPbeOne = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(Test.getStandardPricebookId())
			.withProduct2Id(aProduct)
			.build();
		insert standarPbeOne;
		PricebookEntry pbeOne = Build.aPricebookEntry()
			.withIsActive(true)
			.withPricebook2Id(aPricebook)
			.withProduct2Id(aProduct)
			.build();
		insert pbeOne;
		OpportunityLineItem oliOne = Build.anOpportunityLineItem()
			.withOpportunityId(theOppGDM)
			.withQuantity(10)
			.withCurrentSale140kUnits(10)
			.withUnitsEstimate140K(10)
			.withForecastQuantity(10)
			.withPricebookEntryId(pbeOne)
			.withProduct2Id(aProduct)
			.withUnitPrice(10)
			.build();
		insert oliOne;

		OpportunityLineItem oliTwo = Build.anOpportunityLineItem()
			.withOpportunityId(theOppVirtue)
			.withQuantity(10)
			.withCurrentSale140kUnits(10)
			.withUnitsEstimate140K(10)
			.withForecastQuantity(10)
			.withPricebookEntryId(pbeOne)
			.withProduct2Id(aProduct)
			.withUnitPrice(10)
			.build();
		insert oliTwo;
	}

	@isTest
	static void testDatosPedidoVentaControllerShouldRetrieveOpportunityWithProductsGDM() {
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
				Attendance__r.Name,
				CloseDate,
				Owner.Name,
				Incoterm_1__c,
				Incoterm_2__c,
				(
					SELECT
						Id,
						Quantity,
						Quantity_by_140k__c,
						Price_by_140k__c,
						Variedade_de_Produto__c,
						UnitPrice,
						Product2.UNIDADE__c
					FROM OpportunityLineItems
				)
			FROM Opportunity
			WHERE Company__c = 'GDM'
		][0];
		Pagereference pdfPedidoVentaPage = Page.PDFPedidoVenta;
		Test.setCurrentPage(pdfPedidoVentaPage);
		Apexpages.currentPage().getParameters().put('idOpp', opp.Id);
		Test.startTest();
		DatosPedidoVentaController dpvCtrl = new DatosPedidoVentaController();
		Test.stopTest();
		DatosPedidoVentaVF pedido = dpvCtrl.pedido;
		System.assertEquals(
			'30 days upon receipt of applicable invoice, as issued by GDM. A service charge of 1.5% per month (18% per annum) will be added on all accounts over 30 days.',
			pedido.salePayment
		);
		System.assertEquals(
			'Buyer agrees and understands that he will receive the Seeds as detailed herein, subject to that certain soybean license agreement (the “SLA”) entered into by and between GDM Seeds Inc. and Buyer. Buyer will abide by all terms and conditions set forth therein and use the Seed for said purposes only, and in particular, agrees that if Buyer is receiving Testing Seed, it shall be used exclusively for non-for-profit purposes, as further detailed in the SLA. This Confirmation of Sale shall be construed consistently with the provisions of the SLA, and in the event of any conflicts, the provisions of the SLA shall prevail. Governing Law and Submission to Jurisdiction provisions as set forth in the SLA shall be applicable to this instrument, as well.',
			pedido.saleApplica
		);
		System.assertEquals(
			'Questions concerning this order? Contact Sales Administration at salesadminusa@gdmseeds.com.',
			pedido.saleSupport
		);
		System.assert(pedido.lstDadosProduto.size() > 0);
	}

	@isTest
	static void testDatosPedidoVentaControllerShouldRetrieveOpportunityWithProductsBandB() {
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
				Attendance__r.Name,
				CloseDate,
				Owner.Name,
				Incoterm_1__c,
				Incoterm_2__c,
				(
					SELECT
						Id,
						Quantity,
						Quantity_by_140k__c,
						Price_by_140k__c,
						Variedade_de_Produto__c,
						UnitPrice,
						Product2.UNIDADE__c
					FROM OpportunityLineItems
				)
			FROM Opportunity
			WHERE Company__c = 'B&B'
		][0];
		Pagereference pdfPedidoVentaPage = Page.PDFPedidoVenta;
		Test.setCurrentPage(pdfPedidoVentaPage);
		Apexpages.currentPage().getParameters().put('idOpp', opp.Id);
		Test.startTest();
		DatosPedidoVentaController dpvCtrl = new DatosPedidoVentaController();
		Test.stopTest();
		DatosPedidoVentaVF pedido = dpvCtrl.pedido;
		System.assertEquals(
			'30 days upon receipt of applicable invoice, as issued by B&B Seeds, LLC. A service charge of 1.5% per month (18% per annum) will be added on all accounts over 30 days.',
			pedido.salePayment
		);
		System.assertEquals(
			'Buyer agrees and understands that he will receive the Seeds as detailed herein, subject to that certain soybean license agreement titled DONMARIO® GROWPRO PARTNER AGREEMENT entered into by and  between B&B SEEDS, LLC. and Buyer. Buyer will abide by all terms and conditions set forth therein and use the Seed for said purposes. This Confirmation of Sale shall be construed consistently with the provisions of the above referred agreement, and in the event of any conflicts, the provisions of the such agreement shall prevail. Governing Law and Submission to Jurisdiction provisions as set forth in the agreement shall be applicable to this instrument, as well.',
			pedido.saleApplica
		);
		System.assertEquals(
			'Questions concerning this order? Contact Sales Administration at salesadminusa@gdmseeds.com.',
			pedido.saleSupport
		);
		System.assert(pedido.lstDadosProduto.size() > 0);
	}
}