@isTest
private class ContratoBeforeUpdate_AnexosTest {

    static testmethod void test(){
        Contrato__c cc = new Contrato__c();
        insert cc;
      
        Item_del_Contrato__c it = new Item_del_Contrato__c();
        it.Contrato_de_Multiplicacion__c = cc.id;
        insert it;
        
        try
        {
            cc.Tipo_de_Cota_o__c = 'DOLAR';
            update cc;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('Não pode ser modificado o tipo de cotação') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }   
    }  
}