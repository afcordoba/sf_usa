trigger Account on Account (after insert, after update, before update) {

   if(trigger.isUpdate){
        if(trigger.isAfter) {
            AccountBO.getInstance().newIntegration(Trigger.new, Trigger.oldMap);
        }        
    }
}