@isTest
private class aSiteHomeControllerTest {
	@TestSetup
	static void makeData() {
		Configuracion_USA__c usaConfig = new Configuracion_USA__c(Name = 'Configuracion Usa');
		insert usaConfig;
	}
	@isTest
	static void testReportingMonthsForGDMShouldBeSuccesful() {
		aSiteHomeController homeController = new aSiteHomeController();
		homeController.brand = 'GDM';
		Date aprilReportDate = Date.newInstance(2022, 3, 15);
		Date augustReportDate = Date.newInstance(2022, 7, 29);
		Date decemberReportDate = Date.newInstance(2022, 11, 15);
		String messageApril;
		String messageAugust;
		String messageDecember;
		String reportingApril;
		String reportingAugust;
		String reportingDecember;
		Test.startTest();
		homeController.setReportingActions(aprilReportDate);
		messageApril = homeController.reportingMessage;
		reportingApril = homeController.reportingMonth;
		homeController.setReportingActions(augustReportDate);
		messageAugust = homeController.reportingMessage;
		reportingAugust = homeController.reportingMonth;
		homeController.setReportingActions(decemberReportDate);
		messageDecember = homeController.reportingMessage;
		reportingDecember = homeController.reportingMonth;
		Test.stopTest();
		System.assertEquals(
			'It is time to complete the April Final Production, New Production and Sales Forecast Reports. All reports are due by April 15th.',
			messageApril
		);
		System.assertEquals('APRIL', reportingApril);

		System.assertEquals(
			'It is time to complete the August Production and Final Sales Reports.  All reports are due by August 31st.',
			messageAugust
		);
		System.assertEquals('AUGUST', reportingAugust);

		System.assertEquals(
			'It is time to complete the December Production and Sales Forecast Reports.  All reports are due by December 15th.',
			messageDecember
		);
		System.assertEquals('DECEMBER', reportingDecember);
	}

	@isTest
	static void testReportingMonthsForDONMARIOShouldBeSuccesful() {
		aSiteHomeController homeController = new aSiteHomeController();
		homeController.brand = 'DONMARIO';
		Date aprilReportDate = Date.newInstance(2022, 3, 15);
		Date juneReportDate = Date.newInstance(2022, 5, 1);
		Date julyReportDate = Date.newInstance(2022, 6, 25);
		Date augustReportDate = Date.newInstance(2022, 7, 29);
		Date decemberReportDate = Date.newInstance(2022, 11, 15);
		String messageApril;
		String messageJune;
		String messageJuly;
		String messageAugust;
		String messageDecember;
		String reportingApril;
		String reportingJune;
		String reportingJuly;
		String reportingAugust;
		String reportingDecember;
		Test.startTest();
		homeController.setReportingActions(aprilReportDate);
		messageApril = homeController.reportingMessage;
		reportingApril = homeController.reportingMonth;
		homeController.setReportingActions(juneReportDate);
		messageJune = homeController.reportingMessage;
		reportingJune = homeController.reportingMonth;
		homeController.setReportingActions(julyReportDate);
		messageJuly = homeController.reportingMessage;
		reportingJuly = homeController.reportingMonth;
		homeController.setReportingActions(augustReportDate);
		messageAugust = homeController.reportingMessage;
		reportingAugust = homeController.reportingMonth;
		homeController.setReportingActions(decemberReportDate);
		messageDecember = homeController.reportingMessage;
		reportingDecember = homeController.reportingMonth;

		Test.stopTest();
		System.assertEquals('APRIL', reportingApril);
		System.assertEquals(
			'It is time to complete the April Final Production, New Production and Sales Forecast Reports. All reports are due by April 15th.',
			messageApril
		);

		System.assertEquals('JUNE', reportingJune);
		System.assertEquals(
			'It is time to complete the May Sales and Production Forecast reports due June 1st.',
			messageJune
		);

		System.assertEquals('JULY', reportingJuly);
		System.assertEquals(
			'It is time to complete the July Sales and Production Forecast reports due July 25th.',
			messageJuly
		);

		System.assertEquals('AUGUST', reportingAugust);
		System.assertEquals(
			'It is time to complete the August Final Sales and Production Forecast reports due August 18th.',
			messageAugust
		);

		System.assertEquals('DECEMBER', reportingDecember);
		System.assertEquals(
			'It is time to complete the December Production and Sales Forecast Reports. All reports are due by December 15th.',
			messageDecember
		);
	}

	@isTest
	static void testReportingMonthsForVIRTUEShouldBeSuccesful() {
		aSiteHomeController homeController = new aSiteHomeController();
		homeController.brand = 'VIRTUE';
		Date aprilReportDate = Date.newInstance(2022, 3, 15);
		Date augustReportDate = Date.newInstance(2022, 7, 29);
		Date decemberReportDate = Date.newInstance(2022, 11, 15);
		String messageApril;
		String messageAugust;
		String messageDecember;
		String reportingApril;
		String reportingAugust;
		String reportingDecember;
		Test.startTest();
		homeController.setReportingActions(aprilReportDate);
		messageApril = homeController.reportingMessage;
		reportingApril = homeController.reportingMonth;
		homeController.setReportingActions(augustReportDate);
		messageAugust = homeController.reportingMessage;
		reportingAugust = homeController.reportingMonth;
		homeController.setReportingActions(decemberReportDate);
		messageDecember = homeController.reportingMessage;
		reportingDecember = homeController.reportingMonth;
		Test.stopTest();
		System.assertEquals(
			'It is time to complete the April Final Production, New Production and Sales Forecast Reports. All reports are due by April 15th.',
			messageApril
		);
		System.assertEquals('APRIL', reportingApril);

		System.assertEquals(
			'It is time to complete the August Production and Final Sales Reports.  All reports are due by August 31st.',
			messageAugust
		);
		System.assertEquals('AUGUST', reportingAugust);

		System.assertEquals(
			'It is time to complete the December Production and Sales Forecast Reports.  All reports are due by December 15th.',
			messageDecember
		);
		System.assertEquals('DECEMBER', reportingDecember);
	}

	@isTest
	static void testBetweenDueDatesAndOnDatesGDM() {
		aSiteHomeController homeController = new aSiteHomeController();
		homeController.brand = 'GDM';
		Date aprilReportDate = Date.newInstance(2022, 4, 16);
		Date augustReportDate = Date.newInstance(2022, 8, 19);
		Date decemberReportDate = Date.newInstance(2022, 1, 15);
		String messageApril;
		String messageAugust;
		String messageDecember;
		String reportingApril;
		String reportingAugust;
		String reportingDecember;
		Test.startTest();
		homeController.setReportingActions(aprilReportDate);
		messageApril = homeController.reportingMessage;
		reportingApril = homeController.reportingMonth;
		homeController.setReportingActions(augustReportDate);
		messageAugust = homeController.reportingMessage;
		reportingAugust = homeController.reportingMonth;
		homeController.setReportingActions(decemberReportDate);
		messageDecember = homeController.reportingMessage;
		reportingDecember = homeController.reportingMonth;
		Test.stopTest();
		System.assertEquals(
			'It is time to complete the April Final Production, New Production and Sales Forecast Reports. All reports are due by April 15th.',
			messageApril
		);
		System.assertEquals('APRIL', reportingApril);

		System.assertEquals(
			'It is time to complete the August Production and Final Sales Reports.  All reports are due by August 31st.',
			messageAugust
		);
		System.assertEquals('AUGUST', reportingAugust);

		System.assertEquals(
			'It is time to complete the December Production and Sales Forecast Reports.  All reports are due by December 15th.',
			messageDecember
		);
		System.assertEquals('DECEMBER', reportingDecember);
	}

	@isTest
	static void testBetweenDueDatesAndOnDatesDONMARIO() {
		aSiteHomeController homeController = new aSiteHomeController();
		homeController.brand = 'DONMARIO';
		Date aprilReportDate = Date.newInstance(2022, 4, 16);
		Date juneReportDate = Date.newInstance(2022, 6, 2);
		Date julyReportDate = Date.newInstance(2022, 7, 26);
		Date augustReportDate = Date.newInstance(2022, 8, 19);
		Date decemberReportDate = Date.newInstance(2022, 1, 1);
		String messageApril;
		String messageJune;
		String messageJuly;
		String messageAugust;
		String messageDecember;
		String reportingApril;
		String reportingJune;
		String reportingJuly;
		String reportingAugust;
		String reportingDecember;
		Test.startTest();
		homeController.setReportingActions(aprilReportDate);
		messageApril = homeController.reportingMessage;
		reportingApril = homeController.reportingMonth;
		homeController.setReportingActions(juneReportDate);
		messageJune = homeController.reportingMessage;
		reportingJune = homeController.reportingMonth;
		homeController.setReportingActions(julyReportDate);
		messageJuly = homeController.reportingMessage;
		reportingJuly = homeController.reportingMonth;
		homeController.setReportingActions(augustReportDate);
		messageAugust = homeController.reportingMessage;
		reportingAugust = homeController.reportingMonth;
		homeController.setReportingActions(decemberReportDate);
		messageDecember = homeController.reportingMessage;
		reportingDecember = homeController.reportingMonth;

		Test.stopTest();
		System.assertEquals('APRIL', reportingApril, 'When we are at month number the month 3 message should be');
		System.assertEquals(
			'It is time to complete the April Final Production, New Production and Sales Forecast Reports. All reports are due by April 15th.',
			messageApril,
			'Message of reporting date between due of april date and ON of June date should be April message'
		);

		System.assertEquals('JUNE', reportingJune, 'When we are at month number the month 5 message should be');
		System.assertEquals(
			'It is time to complete the May Sales and Production Forecast reports due June 1st.',
			messageJune,
			'Message of reporting date between due of June date and ON of July date should be June message'
		);

		System.assertEquals('JULY', reportingJuly, 'When we are at month number 6 the month message should be');
		System.assertEquals(
			'It is time to complete the July Sales and Production Forecast reports due July 25th.',
			messageJuly,
			'Message of reporting date between due of July date and ON of August date should be July message'
		);

		System.assertEquals('AUGUST', reportingAugust, 'When we are at month number 7 the month message should be');
		System.assertEquals(
			'It is time to complete the August Final Sales and Production Forecast reports due August 18th.',
			messageAugust,
			'Message of reporting date between due of August date and ON of December date should be August message'
		);

		System.assertEquals('DECEMBER', reportingDecember, 'When we are at month number 11 the month message should be');
		System.assertEquals(
			'It is time to complete the December Production and Sales Forecast Reports. All reports are due by December 15th.',
			messageDecember,
			'Message of reporting date between due of August date and ON of December date should be August message'
		);
	}
}