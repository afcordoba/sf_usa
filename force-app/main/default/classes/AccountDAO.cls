public with sharing class AccountDAO {

    private static final AccountDAO instance = new AccountDAO();    
    private AccountDAO() {}
    
    public static AccountDAO getInstance() {
        return instance;
    }

    public List<Account> getAccountsById( List<String> accountIds ) {
        return [SELECT Id, Name, Phone, Fax, CodigoSAP__c, Email__c, Credit_limit__c, Grupo_de_Cuentas__c, ParentId, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, RecordTypeId
                FROM Account
                WHERE Id in :accountIds];
    }

}