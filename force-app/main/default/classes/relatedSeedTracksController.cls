public without sharing class relatedSeedTracksController {

    @AuraEnabled
    public static List<TrackWrapper> getRelatedSeedTracks (Id inventoryStatusId) {
        Inventory_Status__c targetStatus = [SELECT Id, Opportunity_Product__c,
                                                Opportunity_Product__r.Product2.Variedade__c, Opportunity_Product__r.Centro_de_despacho__c,
                                                Opportunity_Product__r.Opportunity.Marca__c, Opportunity_Product__r.Opportunity.Safra__c,
                                                Opportunity_Product__r.Opportunity.Pricebook2Id, Opportunity_Product__r.Opportunity.Seed_Type__c
                                                FROM Inventory_Status__c WHERE Id = :inventoryStatusId];
        
        String type;
        if(targetstatus.Opportunity_Product__r.Opportunity.Seed_Type__c == 'Parent Seed') {
            type = '%PARENT SEED%';
        }
        else if(targetstatus.Opportunity_Product__r.Opportunity.Seed_Type__c == 'Parent Seed') {
            type = '%TEST SEED%';
        }
        else if(targetstatus.Opportunity_Product__r.Opportunity.Seed_Type__c == 'Wholesale Seed') {
            type = '%WHOLESALE SEED%';
        }

        List<Seed_Tracking__c> tracks = [SELECT Id, Product__c, Sale_Order__r.Marca__c, Variety__r.Name,
                                                Sale_Order__r.Safra__c, Sale_Order__r.Pricebook2Id,
                                                Warehouse__c, Name, Sale_Order__r.Name, Sale_Order__c, Status__c,
                                                ETA_Customer__c
                                        FROM Seed_Tracking__c 
                                        WHERE Variety__c = :targetStatus.Opportunity_Product__r.Product2.Variedade__c 
                                        AND Warehouse__c = :targetStatus.Opportunity_Product__r.Centro_de_despacho__c
                                        AND Sale_Order__r.Marca__c = :targetStatus.Opportunity_Product__r.Opportunity.Marca__c
                                        AND Sale_Order__r.Safra__c = :targetStatus.Opportunity_Product__r.Opportunity.Safra__c
                                        AND Sale_Order__r.Pricebook2Id = :targetStatus.Opportunity_Product__r.Opportunity.Pricebook2Id
                                        AND Sale_Order__r.Type LIKE :type
                                        ];

        List<TrackWrapper> wrappers = new List<TrackWrapper>();
        for(Seed_Tracking__c st : tracks) {
            TrackWrapper wr = new TrackWrapper();
            wr.name = st.Name;
            wr.id = st.Id;
            wr.productName = st.Variety__r.Name;
            wr.brand = st.Sale_Order__r.Marca__c;
            wr.season = st.Sale_Order__r.Safra__c;
            wr.warehouse = st.Warehouse__c;
            wr.saleOrderId = st.Sale_Order__c;
            wr.saleOrderName = st.Sale_Order__r.Name;
            wr.status = st.Status__c;
            wr.customerETA = st.ETA_Customer__c;
            wrappers.add(wr);
        }
        return wrappers;
    }


    public class TrackWrapper {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String brand;
        @AuraEnabled
        public String season;
        @AuraEnabled
        public String warehouse;
        @AuraEnabled
        public String saleOrderId;
        @AuraEnabled
        public String saleOrderName;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String customerETA;
    }
}