trigger ContratoBeforeUpdate_Anexos on Contrato__c (before update) {
    //Modulo facturacion
    if(Trigger.new == null) return;
    for(Contrato__c c : Trigger.new){
        Contrato__c old = System.Trigger.oldMap.get(c.Id);
        if(c.Tipo_de_Cota_o__c != old.Tipo_de_Cota_o__c){
            for(Item_del_Contrato__c it: [SELECT Id FROM Item_del_Contrato__c WHERE Contrato_de_Multiplicacion__c =: c.Id])
                c.Tipo_de_Cota_o__c.adderror('Não pode ser modificado o tipo de cotação.');
        }
    }
}