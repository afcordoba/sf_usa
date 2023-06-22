public class OpportunityDAO {
    private static OpportunityDAO instance = new OpportunityDAO();
    private OpportunityDAO() {
    }

    public static OpportunityDAO getInstance(){
        return instance;
    }

    Map<String, List<OpportunityLineItem>> mapOppLineItemCache = new Map<String, List<OpportunityLineItem>>();

    public List<OpportunityLineItem> getOppLineItemsByOppId(String idOpp){
        if(Test.isRunningTest() && mapOppLineItemCache.containsKey(idOpp)){
            return mapOppLineItemCache.get(idOpp);
        }
        List<OpportunityLineItem> lstOppLineItem = getOppLineItemsByListOppId(new List<String>{idOpp});
        mapOppLineItemCache.put(idOpp, lstOppLineItem);
        return lstOppLineItem;
    }

    public List<Opportunity> getOppInfoByListId(List<String> lstIdOpp){
        String queryPlus = 'RecordType.DeveloperName';
        return aSiteUtils.queryResults1(Opportunity.SObjectType, queryPlus ,'Id = :v1', lstIdOpp);

    }

    public List<OpportunityLineItem> getOppLineItemsByListOppId(List<String> lstIdOpp){
        String queryPlus = 'Opportunity.RecordType.DeveloperName, Opportunity.RecordTypeId, Product2.Name, Product2.Codigo_material_SAP__c, Product2.Unidade__c, Product2.ProductCode';
        return aSiteUtils.queryResults1(OpportunityLineItem.SObjectType, queryPlus ,'OpportunityId = :v1', lstIdOpp);
        
    }

    public List<Opportunity> getOpportunityByListId(List<String> idsOpps){
        String queryPlus = ' Contact_of_Shipping__r.Name, Attendance__r.Email, Attendance__r.Name, Ship_To__r.CodigoSAP__c,' +
            				' Account.Name, Branch_Name__r.CodigoSAP__c, Account.CodigoSAP__c, Owner.Name, Account.Phone,' +
            				' Owner.Sap_Sales_Office__c, Owner.Grupo_de_Vendedores__c, RecordType.DeveloperName, (SELECT Id,' +
            					' Name, Quantity, Product2Id, Product2.Name, Motivo_de_rechazo__c, DocRel__c, Waiting_Sync_To_Delete__c,' +
            					' Material__c, CostOrder__r.Centro_de_CO__c, CostOrder__c, Posicion_Relativa_Consign__c, Comments__c,' +
            					' Product2.ProductCode, Product2.Unidade__c, Product2.Codigo_material_SAP__c, ListPrice, UnitPrice, Product2.Family, Freight_Charge__c, ' +
            					' Shipping_Costs__c, Pallet_Charge__c, OpportunityId, TotalPrice, Warehouse__c, Centro_de_Despacho__c FROM OpportunityLineItems)';
        return aSiteUtils.queryResults1(Opportunity.SObjectType, queryPlus ,'Id = :v1', idsOpps);

    }
    
    public List<OpportunityLineItem> getOpportunityLineItemByListId(List<String> idsPrdOpp){
        String queryPlus = 'Opportunity.RecordType.DeveloperName, Opportunity.RecordTypeId, Product2.Name, Product2.Unidade__c, Product2.Codigo_material_SAP__c';
        return aSiteUtils.queryResults1(OpportunityLineItem.SObjectType, queryPlus ,'OpportunityId = :v1', idsPrdOpp);
        
    }    
}