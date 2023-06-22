public class requestSAPOpportunityEditController {

	public Id oportunidadId {get;set;}
	public String currentUrlOrg {get;set;}

	public requestSAPOpportunityEditController(ApexPages.StandardController stdController) {
		oportunidadId = stdController.getRecord().id;
		currentUrlOrg = System.URL.getOrgDomainUrl().toExternalForm();
	}
	
	public void checkFields() {
		FlujoDocBO.opportunityEnableValidation(oportunidadId);
	}
}