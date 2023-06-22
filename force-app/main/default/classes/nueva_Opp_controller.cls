public with sharing class nueva_Opp_controller {
    
    public Integer getFull(){
        Integer acceso = 0; // 0 es full access        
        UserRole ur = [SELECT Id, Name FROM UserRole WHERE Id =: Userinfo.getUserRoleId() limit 1];
        if(ur.Name.contains('Sales Representative')) acceso = 1;   //comercial
        if(ur.Name.contains('Administrative')) acceso = 2;   //produccion        
        //if(ur.Name.contains('Director')) acceso = 3;   //gerente cerrado
        return acceso;
    }

    public nueva_Opp_controller(ApexPages.StandardController controller){ 
    }
    public nueva_Opp_controller(){        
    }  
    
    public PageReference nuevaOpp (){
        Map<Id, String> usuarios = New Map<Id, String>();
        String tipo = ApexPages.currentPage().getParameters().get('tipo_opp');
        RecordType rt = [Select Id From RecordType Where DeveloperName = : tipo And SObjectType = 'Opportunity' limit 1];
                
        PageReference pr = new PageReference('/006/e');
        pr.getParameters().put('RecordType', String.valueOf(rt.Id));        
        if(tipo.contains('Anexo')){
            pr.getParameters().put('opp3', 'NEW');
            pr.getParameters().put('opp11', 'Editable');
        }
        if(tipo.contains('Sale')){
            pr.getParameters().put('opp3', 'NEW');
            pr.getParameters().put('opp11', 'Editable');
        }
        pr.getParameters().put('nooverride', '1');
        pr.getParameters().put('retURL', '/006/o');
              
        return pr.setRedirect(true);
                
    }
    
}