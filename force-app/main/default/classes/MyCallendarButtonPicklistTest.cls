/**
 * @description       :
 * @author            : Horacio Calleja
 * @group             :
 * @last modified on  : 01-16-2023
 * @last modified by  : Horacio Calleja
 **/
@isTest
private class MyCallendarButtonPicklistTest {
	@isTest
	static void testGetVakyes() {
		MyCalendarButtonsPicklist b = new MyCalendarButtonsPicklist();
		Test.startTest();
		b.getValues();
        b.getDefaultValue();
		Test.stopTest();
	}
}