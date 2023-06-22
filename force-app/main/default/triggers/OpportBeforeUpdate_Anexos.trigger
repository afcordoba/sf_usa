trigger OpportBeforeUpdate_Anexos on Opportunity (before update) {

/*
    if(Trigger.new == null) return;
    for(Opportunity o : Trigger.new){
       Opportunity Antes = System.Trigger.oldMap.get(o.Id);
       if (Antes.Marca__c != o.Marca__c)
           o.Marca__c.adderror('Não é permitido alterar a marca.'); 
       if (Antes.Mes__c != o.Mes__c)
           o.Mes__c.adderror('Não é permitido alterar o mes.');
//       if(((o.StageName == 'Desaprobado x Gerente' && Antes.StageName != 'Desaprobado x Gerente') || (o.StageName == 'Rechazada Supervisor' && Antes.StageName != 'Rechazada Supervisor')) && o.Motivo_de_Rechazo__c == null && o.TipoReg__c.contains('Anexo'))
       if(((o.StageName == 'Desaprobado x Gerente' && Antes.StageName != 'Desaprobado x Gerente') || (o.StageName == 'Rechazada Supervisor' && Antes.StageName != 'Rechazada Supervisor')) && o.Motivo_de_Rechazo__c == null && o.RecordType.Name.contains('Anexo'))
           o.Motivo_de_Rechazo__c.adderror('Para recusar deve completar o campo Motivo de Rejeição.');

    //Modulo de produccion de basica
//       if((o.RecordtypeId == '01240000000MAR3' || o.RecordtypeId == '01233000000MI0j' || o.RecordtypeId == '01240000000MAR8') && Antes.Notificado__c)
//             o.Notificado__c.adderror('Não é permitido alterar.');
       
    }
    */
}