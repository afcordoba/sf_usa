public class AccountIntegrationBO implements IProcessingQueue {
        
    public static void executeQueue(String queueId, String recordId, String eventName, String payload, Integer target) {      
        try {
            if(eventName.equals(QueueEventNames.ACCOUNT_SALESFORCE_TO_SAP.name())) {
                outboundIntegration(queueId, recordId, eventName, payload);
            }
        } catch(Exception ex) {
            QueueBO.getInstance().updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString());
        }
    }
    
    public static String outboundRequest(Account account) {
        sapAltaClienteS4.Z_SD_ALTA_CLIENTE_element requestPayload = new sapAltaClienteS4.Z_SD_ALTA_CLIENTE_element();
        requestPayload.I_DATOS_CLIENTE = new sapAltaClienteS4.ZSSD_IN_CLIE_GRAL();
        
        requestPayload.I_DATOS_CLIENTE.CLIENTE_SF = account.Id;
        requestPayload.I_DATOS_CLIENTE.CLIENTE_SAP = '';
        
        requestPayload.I_DATOS_CLIENTE.ACREEDOR = '';                 
        requestPayload.I_DATOS_CLIENTE.CLIENTE_CYM = '';             
        requestPayload.I_DATOS_CLIENTE.CONDICION_IVA = '';
        requestPayload.I_DATOS_CLIENTE.NIF = '';
        requestPayload.I_DATOS_CLIENTE.TIPO_NIF = '';
        requestPayload.I_DATOS_CLIENTE.VZSKZ = '';
        requestPayload.I_DATOS_CLIENTE.ZWELS = '';
        requestPayload.I_DATOS_CLIENTE.NRO_IIBB = '';
        requestPayload.I_DATOS_CLIENTE.CLAS_DISTRIB = '';
        requestPayload.I_DATOS_CLIENTE.GRP_COND = '';           
        requestPayload.I_DATOS_CLIENTE.CALC_LIMITE = '';
        
        requestPayload.I_DATOS_CLIENTE.CANAL_DIST = '01';
        requestPayload.I_DATOS_CLIENTE.COND_EXPEDICION = '01';
        requestPayload.I_DATOS_CLIENTE.COND_PAGO = 'ZC00';            
        requestPayload.I_DATOS_CLIENTE.CUENTA_ASOCIADA = '0012100001';
        requestPayload.I_DATOS_CLIENTE.GRUPO_TESORERIA = 'E2';
        requestPayload.I_DATOS_CLIENTE.ICMSTAXPAY = '1';
        requestPayload.I_DATOS_CLIENTE.PERS_FIS = '2';             
        requestPayload.I_DATOS_CLIENTE.MONEDA = 'USD';            
        requestPayload.I_DATOS_CLIENTE.ESQUEMA_CLIENTE = '01';
        requestPayload.I_DATOS_CLIENTE.SECTOR = '01';
        requestPayload.I_DATOS_CLIENTE.INCOTERM1 = 'CIF';
        requestPayload.I_DATOS_CLIENTE.INCOTERM2 = 'CIF';
        requestPayload.I_DATOS_CLIENTE.CAT_CFOPC = '04';
        requestPayload.I_DATOS_CLIENTE.Prientrega = '00';
        requestPayload.I_DATOS_CLIENTE.GRUPO_IMPUTACION = '01';
        
        if(account.BillingCountry.ToUppercase() == 'UNITED STATES' || account.BillingCountry.ToUppercase() == 'US'){
            requestPayload.I_DATOS_CLIENTE.GRUPO_CLIENTES = '01';
             
        }
        else{
            requestPayload.I_DATOS_CLIENTE.GRUPO_CLIENTES = '02'; 
        }
        
        requestPayload.I_DATOS_CLIENTE.LIMITE_COMPRA = account.Credit_Limit__c;
        
        String nombre = account.Name;
        if(nombre.length() > 20)
            requestPayload.I_DATOS_CLIENTE.CONC_BUSQUEDA = nombre.substring(0,20);
        else
            requestPayload.I_DATOS_CLIENTE.CONC_BUSQUEDA = nombre;
                
        
        if(account.Grupo_de_Cuentas__c.substring(0,4) == 'US03'){            
            requestPayload.I_DATOS_CLIENTE.GRUPO_CTAS = 'DEST';
            requestPayload.I_DATOS_CLIENTE.TP_CLIENTE = 'DESTINO US';
            //requestPayload.I_DATOS_CLIENTE.CLIENTE_SAP = 'BP_DEST'; 
        } 
        else{
            requestPayload.I_DATOS_CLIENTE.GRUPO_CTAS = 'CUST';               
            requestPayload.I_DATOS_CLIENTE.TP_CLIENTE = 'CLIENTE US';
            //requestPayload.I_DATOS_CLIENTE.CLIENTE_SAP = 'BP_CUST';                
        }
        
        //Data de Domicilio
        if(account.BillingCountry.ToUppercase() == 'CANADA' || account.BillingCountry.ToUppercase() == 'CA'){
            requestPayload.I_DATOS_CLIENTE.PAIS = 'CA';
        }
        else{
            requestPayload.I_DATOS_CLIENTE.PAIS = 'US';
        }
        requestPayload.I_DATOS_CLIENTE.COD_POSTAL = account.BillingPostalCode;
        requestPayload.I_DATOS_CLIENTE.POBLACION = account.BillingCity;
        requestPayload.I_DATOS_CLIENTE.NUMERO = '';
        requestPayload.I_DATOS_CLIENTE.BARRIO = '';
        
        if(account.BillingState!=null)
            requestPayload.I_DATOS_CLIENTE.REGION = account.BillingState.substring(0,2);
            
        requestPayload.I_DATOS_CLIENTE.TAX_JUR = account.BillingState.substring(0,2) + '00000000';

             
        if(account.BillingStreet.length() > 60)
            requestPayload.I_DATOS_CLIENTE.CALLE = account.BillingStreet.substring(0,60);
        else
            requestPayload.I_DATOS_CLIENTE.CALLE = account.BillingStreet;
        
        //Correo electronico que sale del contacto 1
        requestPayload.I_DATOS_CLIENTE.EMAIL = account.Email__c;            
        
        requestPayload.I_DATOS_CLIENTE.FAX = '';
        if(account.Fax != null) requestPayload.I_DATOS_CLIENTE.FAX = account.Fax;             
                    
        if(nombre.length() > 40)
            requestPayload.I_DATOS_CLIENTE.NOMBRE = nombre.substring(0,40);
        else
            requestPayload.I_DATOS_CLIENTE.NOMBRE = nombre;            
        
        String sociedad = '01US';
        requestPayload.I_DATOS_CLIENTE.ORG_VTAS = sociedad;            
        requestPayload.I_DATOS_CLIENTE.SOCIEDAD = sociedad;
        
        //Telefono de la cuenta
        requestPayload.I_DATOS_CLIENTE.TELEFONO = '';
        if(account.Phone != null) requestPayload.I_DATOS_CLIENTE.TELEFONO = String.valueOf(account.Phone);            
            
        //Facturacion
        requestPayload.IT_DATOS_IMPTO = new sapAltaClienteS4.TABLE_OF_ZSSD_IN_CLIE_IMPTO();
        requestPayload.IT_DATOS_IMPTO.item = new List<sapAltaClienteS4.ZSSD_IN_CLIE_IMPTO>();
        
        if(account.BillingCountry.ToUppercase() == 'UNITED STATES' || account.BillingCountry.ToUppercase() == 'US'){
            sapAltaClienteS4.ZSSD_IN_CLIE_IMPTO impt = new sapAltaClienteS4.ZSSD_IN_CLIE_IMPTO();
            impt.TIPO_IMPUESTO = 'UTXJ';
            impt.CLASIF_FISCAL = '0';
            requestPayload.IT_DATOS_IMPTO.item.add(impt);
        }
    
        requestPayload.IT_CATEG_FISCAL = new sapAltaClienteS4.TABLE_OF_ZSSD_IN_CLIE_CFIS();
        requestPayload.IT_CATEG_FISCAL.item = new List<sapAltaClienteS4.ZSSD_IN_CLIE_CFIS>();
        
        requestPayload.I_AMPLIAR_SOCIEDAD ='';
        requestPayload.I_AMPLIAR_VENTAS ='X';
        
        return JSON.serialize(requestPayload);
    }    
    
    @future(callout=true)
    private static void outboundIntegration( String queueId, String recordId, String eventName, String payload) {
        String mens = ''; 
        try {            
            sapAltaClienteS4.Z_SD_ALTA_CLIENTE_element request_x = (sapAltaClienteS4.Z_SD_ALTA_CLIENTE_element) JSON.deserialize(payload, sapAltaClienteS4.Z_SD_ALTA_CLIENTE_element.class);
            sapAltaClienteS4.Z_SD_ALTA_CLIENTE request = new sapAltaClienteS4.Z_SD_ALTA_CLIENTE();            
            sapAltaClienteS4.Z_SD_ALTA_CLIENTEResponse_element response = request.Z_SD_ALTA_CLIENTE(request_x);            
            
            if(response.E_SUBRC != null && response.E_SUBRC != '04') {
                ProcessControl.ignoredByTrigger = true;
                Account acc = new Account( Id = recordId, CodigoSAP__c = response.E_NRO_CLIENTE, Status_integration__c = 'Success');
                update acc;
            }
            
            sapAltaClienteS4.TABLE_OF_BAPIRET2 mensajes;
            mensajes = response.ET_Return;
            if(mensajes.item!=null)
                for (Integer i=0; i<mensajes.item.size();i++)
                    mens += mensajes.item[i].Message + '\n';
                   
            QueueBO.getInstance().updateQueueConfirm(queueId, eventName + ' ' + JSON.serialize(response), mens); 
        } catch(CalloutException ex) {
            QueueBO.getInstance().updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString());   
        } catch(DmlException ex) {
            QueueBO.getInstance().updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString());
        } catch(Exception ex) {
            QueueBO.getInstance().updateQueue(queueId, eventName + ' / ' + ex.getMessage() + ' / ' + ex.getStackTraceString());
        }
    }


}