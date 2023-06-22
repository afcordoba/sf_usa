public class CSVObject  {

    @AuraEnabled
    public List<CSVHeader> headers {get; set;}

    @AuraEnabled
    public List<List<String>> lines {get; set;}

    @AuraEnabled
    public Integer line_count {get; set;}

    public CSVObject() {}

    public CSVObject(List<CSVHeader> headers, List<List<String>> lines) {
        this.headers = headers;
        this.lines = lines;
        this.line_count = lines.size();
        
        this.headers.add(new CSVHeader('AccountId'));
        //this.headers.add(new CSVHeader('PricebookEntryId'));
        
        Map<String,Account> accs = New Map<String,Account>();
        for(Account a : [Select Id, CodigoSAP__c From Account])
            accs.put(a.CodigoSAP__c, a);
        
        //Map<String,PricebookEntry> rPb = Opp_Utils.cargarRoyaltyPricebookEntries('Portal PriceList');
        for(List<String> s1 : this.lines){
            if (accs.containsKey(s1[14])){
                s1.add(accs.get(s1[14]).Id);
                }else{
                    s1.add('');
            }
            /*if (rPb.containsKey(s1[1])){
                s1.add(rPb.get(s1[1]).Id);
                }else{
                    s1.add('');
            }*/
        }
        
    }

}