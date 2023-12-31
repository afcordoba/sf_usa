public class sapAltaClienteS4 {
    public class Z_SD_ALTA_CLIENTE_element {
        public sapAltaClienteS4.TABLE_OF_BAPIRET2 ET_RETURN;
        public sapAltaClienteS4.TABLE_OF_ZSSD_IN_CLIE_CFIS IT_CATEG_FISCAL;
        public sapAltaClienteS4.TABLE_OF_ZSSD_IN_CLIE_IMPTO IT_DATOS_IMPTO;
        public String I_AMPLIAR_SOCIEDAD;
        public String I_AMPLIAR_VENTAS;
        public sapAltaClienteS4.ZSSD_IN_CLIE_GRAL I_DATOS_CLIENTE;
        private String[] ET_RETURN_type_info = new String[]{'ET_RETURN','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] IT_CATEG_FISCAL_type_info = new String[]{'IT_CATEG_FISCAL','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] IT_DATOS_IMPTO_type_info = new String[]{'IT_DATOS_IMPTO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] I_AMPLIAR_SOCIEDAD_type_info = new String[]{'I_AMPLIAR_SOCIEDAD','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_AMPLIAR_VENTAS_type_info = new String[]{'I_AMPLIAR_VENTAS','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_DATOS_CLIENTE_type_info = new String[]{'I_DATOS_CLIENTE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'ET_RETURN','IT_CATEG_FISCAL','IT_DATOS_IMPTO','I_AMPLIAR_SOCIEDAD','I_AMPLIAR_VENTAS','I_DATOS_CLIENTE'};
    }
    public class ZSSD_IN_CLIE_GRAL {
        public String CLIENTE_SF;
        public String CLIENTE_SAP;
        public String GRUPO_CTAS;
        public String SOCIEDAD;
        public String ORG_VTAS;
        public String CANAL_DIST;
        public String SECTOR;
        public String NOMBRE;
        public String CLIENTE_CYM;
        public String CONC_BUSQUEDA;
        public String CALLE;
        public String NUMERO;
        public String COD_POSTAL;
        public String POBLACION;
        public String PAIS;
        public String REGION;
        public String TELEFONO;
        public String FAX;
        public String EMAIL;
        public String NIF;
        public String TIPO_NIF;
        public String NRO_IIBB;
        public String CONDICION_IVA;
        public String RAMO_INDUSTRIAL;
        public String GRUPOST;
        public String CUENTA_ASOCIADA;
        public String GRUPO_TESORERIA;
        public String COND_PAGO;
        public String MONEDA;
        public String GRUPO_IMPUTACION;
        public String GRUPO_CLIENTES;
        public String ESQUEMA_CLIENTE;
        public String COND_EXPEDICION;
        public String ACREEDOR;
        public String BARRIO;
        public String INSC_EST;
        public String CAT_CFOPC;
        public String PERS_FIS;
        public String GRP_ESTAD;
        public String INCOTERM1;
        public String INCOTERM2;
        public String PRIENTREGA;
        public String CLAS_DISTRIB;
        public String CALC_LIMITE;
        public String LIMITE_COMPRA;
        public String TAX_JUR;
        public String PO_BOX;
        public String PO_BOX_POSTAL_CODE;
        public String OFICINA_VENTA;
        public String GRP_VENDEDORES;
        public String OVER_TOLE;
        public String GRP_COND;
        public String PFORT;
        public String PO_BOX_REG;
        public String TP_CLIENTE;
        public String VZSKZ;
        public String ZWELS;
        public String LEGALNAT;
        public String CRTN;
        public String ICMSTAXPAY;
        private String[] CLIENTE_SF_type_info = new String[]{'CLIENTE_SF','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CLIENTE_SAP_type_info = new String[]{'CLIENTE_SAP','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] GRUPO_CTAS_type_info = new String[]{'GRUPO_CTAS','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] SOCIEDAD_type_info = new String[]{'SOCIEDAD','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] ORG_VTAS_type_info = new String[]{'ORG_VTAS','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CANAL_DIST_type_info = new String[]{'CANAL_DIST','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] SECTOR_type_info = new String[]{'SECTOR','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] NOMBRE_type_info = new String[]{'NOMBRE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CLIENTE_CYM_type_info = new String[]{'CLIENTE_CYM','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CONC_BUSQUEDA_type_info = new String[]{'CONC_BUSQUEDA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CALLE_type_info = new String[]{'CALLE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] NUMERO_type_info = new String[]{'NUMERO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] COD_POSTAL_type_info = new String[]{'COD_POSTAL','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] POBLACION_type_info = new String[]{'POBLACION','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] PAIS_type_info = new String[]{'PAIS','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] REGION_type_info = new String[]{'REGION','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] TELEFONO_type_info = new String[]{'TELEFONO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] FAX_type_info = new String[]{'FAX','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] EMAIL_type_info = new String[]{'EMAIL','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] NIF_type_info = new String[]{'NIF','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] TIPO_NIF_type_info = new String[]{'TIPO_NIF','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] NRO_IIBB_type_info = new String[]{'NRO_IIBB','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CONDICION_IVA_type_info = new String[]{'CONDICION_IVA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] RAMO_INDUSTRIAL_type_info = new String[]{'RAMO_INDUSTRIAL','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] GRUPOST_type_info = new String[]{'GRUPOST','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CUENTA_ASOCIADA_type_info = new String[]{'CUENTA_ASOCIADA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] GRUPO_TESORERIA_type_info = new String[]{'GRUPO_TESORERIA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] COND_PAGO_type_info = new String[]{'COND_PAGO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MONEDA_type_info = new String[]{'MONEDA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] GRUPO_IMPUTACION_type_info = new String[]{'GRUPO_IMPUTACION','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] GRUPO_CLIENTES_type_info = new String[]{'GRUPO_CLIENTES','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] ESQUEMA_CLIENTE_type_info = new String[]{'ESQUEMA_CLIENTE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] COND_EXPEDICION_type_info = new String[]{'COND_EXPEDICION','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] ACREEDOR_type_info = new String[]{'ACREEDOR','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] BARRIO_type_info = new String[]{'BARRIO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] INSC_EST_type_info = new String[]{'INSC_EST','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CAT_CFOPC_type_info = new String[]{'CAT_CFOPC','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] PERS_FIS_type_info = new String[]{'PERS_FIS','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] GRP_ESTAD_type_info = new String[]{'GRP_ESTAD','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] INCOTERM1_type_info = new String[]{'INCOTERM1','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] INCOTERM2_type_info = new String[]{'INCOTERM2','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] PRIENTREGA_type_info = new String[]{'PRIENTREGA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CLAS_DISTRIB_type_info = new String[]{'CLAS_DISTRIB','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CALC_LIMITE_type_info = new String[]{'CALC_LIMITE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] LIMITE_COMPRA_type_info = new String[]{'LIMITE_COMPRA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] TAX_JUR_type_info = new String[]{'TAX_JUR','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] PO_BOX_type_info = new String[]{'PO_BOX','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] PO_BOX_POSTAL_CODE_type_info = new String[]{'PO_BOX_POSTAL_CODE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] OFICINA_VENTA_type_info = new String[]{'OFICINA_VENTA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] GRP_VENDEDORES_type_info = new String[]{'GRP_VENDEDORES','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] OVER_TOLE_type_info = new String[]{'OVER_TOLE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] GRP_COND_type_info = new String[]{'GRP_COND','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] PFORT_type_info = new String[]{'PFORT','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] PO_BOX_REG_type_info = new String[]{'PO_BOX_REG','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] TP_CLIENTE_type_info = new String[]{'TP_CLIENTE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] VZSKZ_type_info = new String[]{'VZSKZ','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] ZWELS_type_info = new String[]{'ZWELS','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] LEGALNAT_type_info = new String[]{'LEGALNAT','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CRTN_type_info = new String[]{'CRTN','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] ICMSTAXPAY_type_info = new String[]{'ICMSTAXPAY','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'CLIENTE_SF','CLIENTE_SAP','GRUPO_CTAS','SOCIEDAD','ORG_VTAS','CANAL_DIST','SECTOR','NOMBRE','CLIENTE_CYM','CONC_BUSQUEDA','CALLE','NUMERO','COD_POSTAL','POBLACION','PAIS','REGION','TELEFONO','FAX','EMAIL','NIF','TIPO_NIF','NRO_IIBB','CONDICION_IVA','RAMO_INDUSTRIAL','GRUPOST','CUENTA_ASOCIADA','GRUPO_TESORERIA','COND_PAGO','MONEDA','GRUPO_IMPUTACION','GRUPO_CLIENTES','ESQUEMA_CLIENTE','COND_EXPEDICION','ACREEDOR','BARRIO','INSC_EST','CAT_CFOPC','PERS_FIS','GRP_ESTAD','INCOTERM1','INCOTERM2','PRIENTREGA','CLAS_DISTRIB','CALC_LIMITE','LIMITE_COMPRA','TAX_JUR','PO_BOX','PO_BOX_POSTAL_CODE','OFICINA_VENTA','GRP_VENDEDORES','OVER_TOLE','GRP_COND','PFORT','PO_BOX_REG','TP_CLIENTE','VZSKZ','ZWELS','LEGALNAT','CRTN','ICMSTAXPAY'};
    }
    public class TABLE_OF_ZSSD_IN_CLIE_IMPTO {
        public sapAltaClienteS4.ZSSD_IN_CLIE_IMPTO[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class Z_SD_ALTA_CLIENTEResponse_element {
        public sapAltaClienteS4.TABLE_OF_BAPIRET2 ET_RETURN;
        public String E_KNA1;
        public String E_NRO_CLIENTE;
        public String E_SUBRC;
        public sapAltaClienteS4.TABLE_OF_ZSSD_IN_CLIE_CFIS IT_CATEG_FISCAL;
        public sapAltaClienteS4.TABLE_OF_ZSSD_IN_CLIE_IMPTO IT_DATOS_IMPTO;
        private String[] ET_RETURN_type_info = new String[]{'ET_RETURN','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] E_KNA1_type_info = new String[]{'E_KNA1','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] E_NRO_CLIENTE_type_info = new String[]{'E_NRO_CLIENTE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] E_SUBRC_type_info = new String[]{'E_SUBRC','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] IT_CATEG_FISCAL_type_info = new String[]{'IT_CATEG_FISCAL','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] IT_DATOS_IMPTO_type_info = new String[]{'IT_DATOS_IMPTO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'ET_RETURN','E_KNA1','E_NRO_CLIENTE','E_SUBRC','IT_CATEG_FISCAL','IT_DATOS_IMPTO'};
    }
    public class BAPIRET2 {
        public String TYPE_x;
        public String ID;
        public String NUMBER_x;
        public String MESSAGE;
        public String LOG_NO;
        public String LOG_MSG_NO;
        public String MESSAGE_V1;
        public String MESSAGE_V2;
        public String MESSAGE_V3;
        public String MESSAGE_V4;
        public String PARAMETER;
        public Integer ROW;
        public String FIELD;
        public String SYSTEM_x;
        private String[] TYPE_x_type_info = new String[]{'TYPE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] ID_type_info = new String[]{'ID','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] NUMBER_x_type_info = new String[]{'NUMBER','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_type_info = new String[]{'MESSAGE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] LOG_NO_type_info = new String[]{'LOG_NO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] LOG_MSG_NO_type_info = new String[]{'LOG_MSG_NO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_V1_type_info = new String[]{'MESSAGE_V1','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_V2_type_info = new String[]{'MESSAGE_V2','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_V3_type_info = new String[]{'MESSAGE_V3','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] MESSAGE_V4_type_info = new String[]{'MESSAGE_V4','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] PARAMETER_type_info = new String[]{'PARAMETER','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] ROW_type_info = new String[]{'ROW','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] FIELD_type_info = new String[]{'FIELD','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] SYSTEM_x_type_info = new String[]{'SYSTEM','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'TYPE_x','ID','NUMBER_x','MESSAGE','LOG_NO','LOG_MSG_NO','MESSAGE_V1','MESSAGE_V2','MESSAGE_V3','MESSAGE_V4','PARAMETER','ROW','FIELD','SYSTEM_x'};
    }
    public class ZSSD_IN_CLIE_IMPTO {
        public String TIPO_IMPUESTO;
        public String CLASIF_FISCAL;
        private String[] TIPO_IMPUESTO_type_info = new String[]{'TIPO_IMPUESTO','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] CLASIF_FISCAL_type_info = new String[]{'CLASIF_FISCAL','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'TIPO_IMPUESTO','CLASIF_FISCAL'};
    }
    public class ZSSD_IN_CLIE_CFIS {
        public String CATEGORIA_FISCAL;
        public String SUJETO_DESDE;
        public String SUJETO_HASTA;
        private String[] CATEGORIA_FISCAL_type_info = new String[]{'CATEGORIA_FISCAL','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] SUJETO_DESDE_type_info = new String[]{'SUJETO_DESDE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] SUJETO_HASTA_type_info = new String[]{'SUJETO_HASTA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'CATEGORIA_FISCAL','SUJETO_DESDE','SUJETO_HASTA'};
    }
    public class TABLE_OF_BAPIRET2 {
        public sapAltaClienteS4.BAPIRET2[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class TABLE_OF_ZSSD_IN_CLIE_CFIS {
        public sapAltaClienteS4.ZSSD_IN_CLIE_CFIS[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class Z_SD_ALTA_CLIENTE {
        SAPEndpoint__c endpoint = SAPEndpoint__c.getOrgDefaults();
        public String endpoint_x = endpoint.Endpoint__c + '/sap/bc/srt/rfc/sap/z_sd_alta_cliente/' + endpoint.Manager__c + '/z_sd_alta_cliente/z_sd_alta_cliente';
        //public String endpoint_x = 'http://s4qas.eastus.cloudapp.azure.com:8000/sap/bc/srt/rfc/sap/z_sd_alta_cliente/300/z_sd_alta_cliente/z_sd_alta_cliente';
        public Map<String,String> inputHttpHeaders_x = new Map<String, String>();
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions', 'sapAltaClienteS4'};
        
        public sapAltaClienteS4.Z_SD_ALTA_CLIENTEResponse_element Z_SD_ALTA_CLIENTE(sapAltaClienteS4.Z_SD_ALTA_CLIENTE_element request){
            sapAltaClienteS4.Z_SD_ALTA_CLIENTE_element request_x = request;       
            
            String encodedusernameandpassword;          
            
            String myData = 'SALESFORCEUS:2o21gdms33dS';
            Blob hash = Blob.valueOf(myData);
            encodedusernameandpassword = EncodingUtil.base64Encode(hash);
            this.timeout_x = 60000;
            this.inputHttpHeaders_x.put('Authorization', 'Basic '+ encodedusernameandpassword); 
            
            sapAltaClienteS4.Z_SD_ALTA_CLIENTEResponse_element response_x;
            Map<String, sapAltaClienteS4.Z_SD_ALTA_CLIENTEResponse_element> response_map_x = new Map<String, sapAltaClienteS4.Z_SD_ALTA_CLIENTEResponse_element>();
            response_map_x.put('response_x', response_x);
            
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:sap-com:document:sap:rfc:functions:Z_SD_ALTA_CLIENTE:Z_SD_ALTA_CLIENTERequest',
              'urn:sap-com:document:sap:rfc:functions',
              'Z_SD_ALTA_CLIENTE',
              'urn:sap-com:document:sap:rfc:functions',
              'Z_SD_ALTA_CLIENTEResponse',
              'sapAltaClienteS4.Z_SD_ALTA_CLIENTEResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}