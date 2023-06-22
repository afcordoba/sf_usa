trigger Queue on Queue__c ( after insert ) {
    QueueBO.getInstance().executeProcessingQueue( trigger.new );
}