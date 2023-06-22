public with sharing class DatosPedidoVentaController {
  public transient DatosPedidoVentaVF pedido {get; set;}
  public transient String assComprador {get; set;}
  public transient String dadosVencimento {get; set;}

  public DatosPedidoVentaController() {
  
      try{
          String idOpp = ApexPages.currentPage().getParameters().get('idOpp');
          pedido = DatosPedidoVentaBO.getInstance().getPedidoVenda(idOpp);
    
          pedido.oppName = fillBlanks(pedido.oppName, 15);
          pedido.oppCloseDate = fillBlanks(pedido.oppCloseDate, 15);
          pedido.BillToName = fillBlanks(pedido.BillToName , 45);          
          pedido.ShipToName = fillBlanks(pedido.ShipToName , 45);
          pedido.BranchName = fillBlanks(pedido.BranchName , 45);
          pedido.BillToAddress = fillBlanks(pedido.BillToAddress , 40);
          pedido.ShipToAddress = fillBlanks(pedido.ShipToAddress , 40);
          pedido.BillToCityZip = fillBlanks(pedido.BillToCityZip , 30);
          pedido.ShipToCityZip = fillBlanks(pedido.ShipToCityZip , 30);
          pedido.BillToContact = fillBlanks(pedido.BillToContact , 60);
      }
      catch(exception e) {
          //return 'Fill PDF method - ' + e.getMessage() + '' + e.getLineNumber();
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Fill PDF method:'));
      }
  }
    
  private String fillBlanks(String stringFormat, Integer nrCaracteresTotal){
    String novoTextoFormatado = stringFormat.replace('null','');
    String strToRepeat = '&nbsp;';
    novoTextoFormatado += strToRepeat.repeat(nrCaracteresTotal - stringFormat.length());
    return novoTextoFormatado;
  }
}