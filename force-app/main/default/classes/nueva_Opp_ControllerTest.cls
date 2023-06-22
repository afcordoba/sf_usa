@isTest
private class nueva_Opp_ControllerTest {

    @IsTest(SeeAllData=false)
    static void gralUnitTest() {
        nueva_Opp_Controller b_obj = new nueva_Opp_Controller();
                        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Or Name = 'Administrador del sistema'];
        UserRole r_c = [SELECT Id FROM UserRole WHERE Name='GDM Sales Representative'];
        UserRole r_p = [SELECT Id FROM UserRole WHERE Name='Director'];
        
        //Funcion Comercial
        User u = new User(Alias = 'ejem', Email='prueba@gdm.com', EmailEncodingKey='UTF-8', 
        LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Comercial@testgdm.com', UserRoleId = r_c.Id);
        
        System.runAs(u) {
            Integer acceso = b_obj.getFull();
            System.AssertEquals(acceso,1);            
        }
        
        u.UserRoleId = r_p.Id;  //Funcion Produccion
        update u;        
        System.runAs(u) {
            Integer acceso = b_obj.getFull();
            System.AssertEquals(acceso,0);
        }
        
        PageReference pageRef = new PageReference('/006/e');
        pageRef.getParameters().put('tipo_opp','AnexoI');      
        Test.setCurrentPageReference(pageRef);
    
        b_obj.nuevaOpp();
        
    }   
}