@isTest
private class USAUtilsTest {
    static Opportunity opp;
    static {
        opp = new Opportunity();
        opp.Name = 'Test Account';
        opp.Stagename = 'Pendiente';
        opp.CloseDate = System.Today();
        insert opp;
    }
    static testMethod void TestConfirmation() {
        PageReference pref = Page.PDFPedidoVenta;
        pref.getParameters().put('idOpp',opp.id);
        Test.setCurrentPage(pref);

        Test.startTest();

        ConfirmationButton.GenerateConfirmation(opp.Id);    

        Test.stopTest(); 

    }   
}