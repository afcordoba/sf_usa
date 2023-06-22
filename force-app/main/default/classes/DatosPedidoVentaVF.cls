public with sharing class DatosPedidoVentaVF {
	public String nomeCompania { get; set; }
	public String dadosCNPJCompania { get; set; }
	public String dadosIECompania { get; set; }
	public String dadosTelefoneCompania { get; set; }
	public String dadosFaxCompania { get; set; }
	public String dadosWebsiteCompania { get; set; }
	public String endCompaniaLinha1 { get; set; }
	public String endCompaniaLinha2 { get; set; }
	public String endCompaniaLinha3 { get; set; }

	public String oppName { get; set; }
	public String oppOwnerName { get; set; }
	public String oppCloseDate { get; set; }
	public String BillToName { get; set; }
	public String ShipToName { get; set; }
	public String BillToAddress { get; set; }
	public String ShipToAddress { get; set; }
	public String BillToCityZip { get; set; }
	public String ShipToCityZip { get; set; }
	public String BillToContact { get; set; }
	public String BranchName { get; set; }

	public String saleDescription { get; set; }
	public String saleIncoterm { get; set; }
	public String saleShipment { get; set; }
	public String saleShippedBy { get; set; }
	public String salePayment { get; set; }
	public String saleApplica { get; set; }
	public String saleSupport { get; set; }

	public List<Produto> lstDadosProduto { get; set; }

	//DADOS DE PRODUTO
	public class Produto {
		public String originator { get; set; }
		public String product { get; set; }
		public String units { get; set; }
		public String unitType { get; set; }
		public String price { get; set; }
		public Decimal quantity { get; set; }
	}

	public DatosPedidoVentaVF() {
		//loadDataCabecalho();
		lstDadosProduto = new List<Produto>();
	}

	public void loadDataCabecalhoGDM() {
		this.nomeCompania = 'GDM SEEDS INC.';
		this.endCompaniaLinha1 = '3414 Big Pine Trail';
		this.endCompaniaLinha2 = 'Champaign, IL 61822';

		this.dadosTelefoneCompania = 'Ph: 217-680-6044';
		this.dadosFaxCompania = 'salesadminusa@gdmseeds.com';

		this.dadosWebsiteCompania = '';
		this.endCompaniaLinha3 = '';
		this.dadosCNPJCompania = '';
	}

	public void loadDataCabecalhoBB() {
		this.nomeCompania = 'B&B Seeds, LLC';
		this.endCompaniaLinha1 = '3414 Big Pine Trail';
		this.endCompaniaLinha2 = 'Champaign, IL 61822';

		this.dadosTelefoneCompania = 'Ph: 217-680-6044';
		this.dadosFaxCompania = 'salesadminusa@gdmseeds.com';

		this.dadosWebsiteCompania = '';
		this.endCompaniaLinha3 = '';
		this.dadosCNPJCompania = '';
	}
}