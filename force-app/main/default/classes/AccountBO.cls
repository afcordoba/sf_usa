public with sharing class AccountBO {
    
    private static final AccountBO instance = new AccountBO();
    private AccountBO() {}
     
    public static AccountBO getInstance() {
        return instance;
    }

    public void newIntegration(List<Account> accountList, Map<Id, Account> oldAccMap) {
      List<Queue__c> queueToInsert = new List<Queue__c>();
      List<String> accountIds = new List<String>();

      for(Account account : accountList) {
            if((account.CodigoSAP__c == null || account.CodigoSAP__c == '') && account.Status_integration__c == 'Insert Mode' && account.Status_integration__c != oldAccMap.get(account.Id).Status_integration__c){
                accountIds.add(account.Id);
            }
            else if((account.CodigoSAP__c != null || account.CodigoSAP__c != '') && (oldAccMap.get(account.Id).CodigoSAP__c != null || oldAccMap.get(account.Id).CodigoSAP__c != '') && (oldAccMap.get(account.Id).CodigoSAP__c != account.CodigoSAP__c) && account.Status_integration__c == 'Insert Mode'){
                account.addError('This account has already been created in SAP.');
            }
      }

      
      for(Account account : AccountDAO.getInstance().getAccountsById(accountIds)) {
          	System.debug('SANTIAGO - INTENTO DE SYNCRONIZACION CON SAP ' + account.Name);
            String jsonResult = AccountIntegrationBO.outboundRequest(account);

            queueToInsert.add(QueueBO.getInstance().sObjectQueue(account.Id, QueueEventNames.ACCOUNT_SALESFORCE_TO_SAP.name(), jsonResult, false) 
            );
      }
        
      insert queueToInsert;
    }
}