public class QueueBO {

    private static final QueueBO instance = new QueueBO();    
    private QueueBO(){}
    
    public static QueueBO getInstance() {
        return instance;
    }
    
    public enum QueueStatus {
        CREATED,
        SUCCESS,
        ERROR
    }
    
    private static map<String, IProcessingQueue> mapToExecute;     
    
    static {
        mapToExecute = new map<String, IProcessingQueue>();
        mapToExecute.put(QueueEventNames.ACCOUNT_SALESFORCE_TO_SAP.name(), new AccountIntegrationBO());
        mapToExecute.put(QueueEventNames.OPPORTUNITY_SALESFORCE_TO_SAP.name(), new OpportunityVtaIntegrationS4BO());
        mapToExecute.put(QueueEventNames.OPPORTUNITY_REJ_SALESFORCE_TO_SAP.name() , new OpportunityVtaIntegrationBO());
        mapToExecute.put(QueueEventNames.OPPORTUNITY_UPDATE_SALESFORCE_TO_SAP.name() , new ModificaPedidoIntegrationS4BO());
   }
  
    public String createQueue( String eventName, String payLoad, Boolean ignoredByTrigger ) {
        Queue__c queue              = new Queue__c();
        queue.EventName__c          = eventName;
        queue.Payload__c            = payLoad;
        queue.Status__c             = QueueStatus.CREATED.name();
        queue.IgnoredByTrigger__c   = ignoredByTrigger;        
        
        insert queue;
        return queue.Id;
    }

    public Queue__c sObjectQueue( String recordId, String eventName, String payLoad, Boolean ignoredByTrigger ) {
        Queue__c queue              = new Queue__c();
        queue.RecordId__c           = recordId;
        queue.EventName__c          = eventName;
        queue.Payload__c            = payLoad;
        queue.Status__c             = QueueStatus.CREATED.name();
        queue.IgnoredByTrigger__c   = ignoredByTrigger;
        if(eventName.contains('OPP'))
            queue.Opportunity__c   = recordId;
        if(eventName.contains('ACC'))
            queue.Account__c = recordId;
         
        return queue;
    }

    public void updateQueue( String queueId, String dmlExceptionStackTrace, String msg) {
        Queue__c queue                  = new Queue__c();
        queue.Id                        = queueId;
        queue.Status__c                 = dmlExceptionStackTrace.equals('') ? QueueStatus.SUCCESS.name() : QueueStatus.ERROR.name();
        queue.ExceptionStackTrace__c    = dmlExceptionStackTrace;       
        if(msg.length() > 250)
            queue.Messages__c           = msg.substring(0,250);
        else
            queue.Messages__c           = msg;
        
        update queue;
    }

    public void updateQueue( String queueId, String dmlExceptionStackTrace) {
        Queue__c queue                  = new Queue__c();
        queue.Id                        = queueId;
        queue.Status__c                 = dmlExceptionStackTrace.equals('') ? QueueStatus.SUCCESS.name() : QueueStatus.ERROR.name();
        queue.ExceptionStackTrace__c    = dmlExceptionStackTrace;       
        
        update queue;
    }
    
    public void updateQueueConfirm( String queueId, String xmlResult) {
        Queue__c queue                  = new Queue__c();
        queue.Id                        = queueId;
        queue.Status__c                 = xmlResult.contains( '"Type_x":"E"' ) ? QueueStatus.ERROR.name() : QueueStatus.SUCCESS.name();
        queue.Response__c               = xmlResult;       
        
        update queue;
    }

    public void updateQueueConfirm( String queueId, String xmlResult, String msg) {
        Queue__c queue                  = new Queue__c();
        queue.Id                        = queueId;
        queue.Status__c                 = xmlResult.contains( '"Type_x":"E"' ) ? QueueStatus.ERROR.name() : QueueStatus.SUCCESS.name();
        queue.Response__c               = xmlResult;       
        if(msg.length() > 250)
            queue.Messages__c           = msg.substring(0,250);
        else
            queue.Messages__c           = msg;
        
        update queue;
    }
    
    public void insertQueueConfirmForTest(String xmlResult) {
        Queue__c queue = new Queue__c();
        queue.Status__c = xmlResult.contains( '"Type_x":"E"' ) ? QueueStatus.ERROR.name() : QueueStatus.SUCCESS.name();
        queue.Response__c = xmlResult.abbreviate(131000); 
        queue.IgnoredByTrigger__c = true;
        
        insert queue;
    }
    
    public void executeProcessingQueue( List<Queue__c> queueToProcessing ) {
        for( Queue__c queue : queueToProcessing ) {
            if(Test.isRunningTest() ) return;
            if(queue.IgnoredByTrigger__c ) return;
                 
            //OpportunityVtaIntegrationS4BO.executeQueue( queue.Id, queue.RecordId__c, queue.EventName__c, queue.Payload__c, 200);
            mapToExecute.get(queue.EventName__c).executeQueue(queue.Id, queue.RecordId__c, queue.EventName__c, queue.Payload__c, 200); 
            
            //Change to S4 VtaIntegration for testing
        }
    }      
}