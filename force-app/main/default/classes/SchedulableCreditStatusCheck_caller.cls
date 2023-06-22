global class SchedulableCreditStatusCheck_caller implements Schedulable {
  global void execute(SchedulableContext sc) {
    consultarOpps();
  }
  
  public static void consultarOpps(){
      try{
        String result = sapCreditStatus_caller.consultarOpps();
      }catch(Exception e){
        system.debug(e.getMessage());
      }
  }
}