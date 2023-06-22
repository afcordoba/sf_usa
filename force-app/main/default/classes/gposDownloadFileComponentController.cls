public class gposDownloadFileComponentController {
    
    @AuraEnabled
    public static List<FileWrapper> getFiles(String AccountId) {
        if(AccountId == null) {
            return null;
        }
        List<GPOS_Customer_Report__c> reports = [SELECT Id, Document__c, Name, CreatedDate, Type__c 
                                                    FROM GPOS_Customer_Report__c 
                                                    WHERE Account__c =:AccountId AND Type__c = 'Customer'
                                                    ORDER BY CreatedDate];
        List<FileWrapper> results = new List<FileWrapper>();
        for(GPOS_Customer_Report__c report : reports) {
            FileWrapper wr = new FileWrapper();
            wr.Link = report.Document__c;
            wr.FileName = report.Name;
            wr.Type = report.Type__c;
            wr.CreatedDate = report.CreatedDate.date();
            results.add(wr);
        }
        return results;

        

    }
    public class FileWrapper {
        @AuraEnabled 
        public String Link;
        @AuraEnabled
        public String FileName;
        @AuraEnabled
        public String Type;
        @AuraEnabled
        public Date CreatedDate;
    }

}