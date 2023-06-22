public class CSVCreator  {

    private static List<String> separateCommas(String input){
        List<String> results = input.split(';');

        for(String result : results) {
            result = result.trim();
        }

        return results;
    }

    @AuraEnabled
    public static CSVObject getCSVObject(String csv_str) {
        List<String> lines_raw = csv_str.split('\n');
        List<String> headers_raw = separateCommas(lines_raw[0]);
        List<List<String>> lines = new List<List<String>>();
        List<CSVHeader> headers = new List<CSVHeader>();

        lines_raw.remove(0);

        //Handling fields with commas

        for(String line : lines_raw) {
            List<String> line_sep = separateCommas(line);
            List<String> fields = new List<String>();
            Boolean makeCompositeField = false;
            String compositeField;
            for(String field : line_sep) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    fields.add(field.trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    fields.add(compositeField.trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    fields.add(field.trim());
                }
            }
            lines.add(fields);
        }

        for(String header : headers_raw) {
            headers.add(new CSVHeader(header));
        }

        return new CSVObject(headers, lines);        
    }
    
    @AuraEnabled
    public static String crearSeedTracking(String jsonString) {
    
        Savepoint sp = Database.setSavepoint();
        
        try{
        
            CSVObject csv_obj = (CSVObject)JSON.deserialize(jsonString, CSVObject.class);

            for (List<String> s : csv_obj.lines){
                if (s[25] == null || s[25] == '')
                    return 'Missing AccountId data.';
            }
        
            /*
            List<Opportunity> oppsActuales = New List<Opportunity>();
            oppsActuales = [Select Id From Opportunity Where RecordType.Name = 'Seed Tracking'];
            if (oppsActuales.size() > 0)
                delete oppsActuales;
        
            Map<String,Id> rty = Opp_Utils.cargarRecordTypesOportunidades();    
            String rt_st = rty.get('Seed Tracking');
        
            Map<String,Opportunity> mapOpps = new Map<String,Opportunity>();
            for (List<String> s : csv_obj.lines){
                Opportunity o = mapOpps.get(s[4]);
                if (o == null){
                    o = new Opportunity(Name='Seed Tracking',Stagename='Editable',CloseDate=System.today(),RecordTypeId=rt_st,AccountId=s[4],Safra__c='20/2020',Marca__c='GDM');
                    mapOpps.put(s[4], o);
                }            
            }
            insert mapOpps.values();    

            List<OpportunityLineItem> items = new List<OpportunityLineItem>();
            for (List<String> s : csv_obj.lines){    
                OpportunityLineItem item = new OpportunityLineItem();
                                
                item.OpportunityId = mapOpps.get(s[4]).Id;
                item.Quantity = Double.valueOf(s[3]);
                item.UnitPrice = 1;
                item.PricebookEntryId = s[5];
                item.Categoria__c = tmp.categoria_id;                                             
    
                items.add(item);
            }

            insert items;   
            */      
        
            List<Seed_Tracking__c> registrosActuales = New List<Seed_Tracking__c>();
            registrosActuales = [Select Id From Seed_Tracking__c];
            if (registrosActuales.size() > 0)
                delete registrosActuales;   
            
            List<Seed_Tracking__c> l_st = New List<Seed_Tracking__c>();
            for (List<String> s : csv_obj.lines){
                Seed_Tracking__c st = New Seed_Tracking__c();
                st.Order__c = String.valueOf(s[0]);
                st.Brand__c = String.valueOf(s[1]);
                st.GDM_Variety_Code__c = String.valueOf(s[2]);
                st.GID__c = String.valueOf(s[3]);
                st.Quantity__c = null;
                st.Quantity_by_140k__c = null;
                if (String.valueOf(s[4]) != '')
                    st.Quantity__c = Double.valueOf(String.valueOf(s[4]).replaceAll(',','.'));
                if (String.valueOf(s[5]) != '')
                    st.Quantity_by_140k__c = Double.valueOf(String.valueOf(s[5]).replaceAll(',','.'));
                st.Unit_Type__c = String.valueOf(s[6]);
                st.Warehouse__c = String.valueOf(s[7]);
                st.Ship_To__c = String.valueOf(s[8]);
                st.Ship_To_Street__c = String.valueOf(s[9]);
                st.Ship_To_City__c = String.valueOf(s[10]);
                st.State__c = String.valueOf(s[11]);
                st.Zip__c = String.valueOf(s[12]);
                st.Contact__c = String.valueOf(s[15]);
                st.Phone_Number__c = String.valueOf(s[16]);
                st.Type__c = String.valueOf(s[17]);
                st.Avion_Barco__c = String.valueOf(s[18]);
                st.Responsable__c = String.valueOf(s[19]);
                st.Rotulos__c = String.valueOf(s[20]);
                st.Harvest__c = String.valueOf(s[21]);
                st.ETA_USA__c = String.valueOf(s[22]);
                st.Status__c = String.valueOf(s[23]);
                st.ETA_Customer__c = String.valueOf(s[24]);
                st.Account__c = String.valueOf(s[25]);
                l_st.add(st);                        
            }
        
            if (l_st.size() > 0)
                insert l_st;
                
         }catch(Exception e){  
            Database.rollback(sp);          
            return 'ERROR ' + e.getMessage();
         }
                
         return 'The data has been imported successfully.';
        
    }

}