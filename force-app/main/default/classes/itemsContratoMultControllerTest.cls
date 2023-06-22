@isTest
private class itemsContratoMultControllerTest {

    static testMethod void myUnitTest() {
    
    Map<String,Id> rt = New Map<String, Id>();
    for(RecordType reTy : [Select Id, Name From RecordType])
        rt.put(reTy.Name, reTy.Id);

    Account cuenta = new Account(Name='ACME', CodigoSAP__c='6000000000'); insert cuenta;
    Categoria__c cat = new Categoria__c(Name='Basic'); insert cat;
    Variedad__c var = new Variedad__c(Name='TRUMP 1'); insert var;
    Product2 prd = new Product2(Name='SOJAETA',Categ__c=cat.Id,Variedade__c=var.Id,isActive=true,Family='Royalty'); insert prd;
      
    Contrato__c c = new Contrato__c(Multiplicador__c=cuenta.Id,Sociedad__c='GDM', RecordTypeId = rt.get('Parent Seed Schedule A'), Safra__c = '18/2018');
    insert c;
    c.Tipo_de_Cota_o__c = 'DOLAR';
    update c;
    
    Item_del_Contrato__c ic = new Item_del_Contrato__c(Cultivar__c=prd.Id, Contrato_de_Multiplicacion__c = c.Id); insert ic;
            
    PageReference pageRef = Page.Items_Contrato_Multiplicacion;
    pageRef.getParameters().put('Id',c.Id);
    pageRef.getParameters().put('nombre',c.Name);
    pageRef.getParameters().put('sociedad',c.Sociedad__c);

    Test.setCurrentPageReference(pageRef);

    itemsContratoMultController i = New itemsContratoMultController();
    i.init();      
        
        /*
    Item_del_Contrato__c ic = new Item_del_Contrato__c(Cultivar__c=pbe.Product2Id, Contrato_de_Multiplicacion__c = c.Id);
        insert ic;
        Contrato__c adi = new Contrato__c(Multiplicador__c=cuenta.Id,Sociedad__c='BRMX', RecordTypeId = rt.get('Aditivo BRMX'), Tipo_de_Cota_o__c = 'DOLAR', Tipo_de_cambio__c = 1.45, Safra__c = '18/19');
        insert adi;
        Item_del_Contrato__c iadi = new Item_del_Contrato__c(Cultivar__c=pbe.Product2Id, Contrato_de_Multiplicacion__c = adi.Id, Quantidade__c = 10, Categoria__c = cat.Id);
        insert iadi;
        Item_del_Contrato__c iadi2 = new Item_del_Contrato__c(Cultivar__c=pbe.Product2Id, Contrato_de_Multiplicacion__c = adi.Id, Quantidade__c = 10, Categoria__c = cat.Id);
    
        PageReference pageRef = Page.Items_Contrato_Multiplicacion;
        pageRef.getParameters().put('Id',c.Id);
        pageRef.getParameters().put('nombre',c.Name);
        pageRef.getParameters().put('sociedad',c.Sociedad__c);
        
        Test.setCurrentPageReference(pageRef);

        //itemsContratoMultController i = New itemsContratoMultController(new ApexPages.StandardController(c.Id));
        itemsContratoMultController i = New itemsContratoMultController();
        i.init();      
        */
        Id a;
        String b;
        
        i.seteditItem(a);
        i.seteliminarItem(a);
        i.setidContrato(a);
        i.setsaveEditItem(a);
        i.setrecTypeContrato('Parent_Seed_Schedule_A');
        i.getrecTypeContrato();
        i.setMensaje('Probando');
        i.getMensaje();
        i.getProductosBasica();
        
        i.getprodsBasica();        
       
        a = i.geteditItem();  
        a = i.geteliminarItem();
        a = i.getidContrato();
        a = i.getsaveEditItem();
        i.setnombreContrato(b);
        
        b = prd.Id;
        i.setidContrato (c.Id);
        pageRef.getParameters().put('save_edit_item',c.Id);
        
        i.setnuevoBasica(b);
        i.addItem();
        
        i.seteditBasica(b);
        i.setsociedadContrato(b);
        b = i.getnombreContrato();
        b = i.getnuevoBasica();
        b = i.geteditBasica();
        b = i.getsociedadContrato();
        
        pageRef.getParameters().put('edit_item', ic.Id);       
        i.editarItem();
        i.cancelEditarItem();
        i.eliminarItem();                
                
        i.saveEditItem();
        i.volver();
            
    }
}