/**
 * An apex page controller that exposes the portal site forgot password functionality
 * jgarmendia 17.04.07
 */
public class aSiteForgotPassController {
    public String username {get; set;}   
    public string language {get;set;}
    public String company {get; set;}  
    
    public aSiteForgotPassController() {
        language = [select id, LanguageLocaleKey from User where id =: UserInfo.getUserId()].LanguageLocaleKey;
    }
    
    public PageReference forgotPassword() {
        
        if(username == '' || username == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Username is required!'));
            return null;
        }
        company = System.currentPageReference().getParameters().get('comp');
        if(company != null && !company.isWhitespace())
            company = '?comp=' + company;
        boolean success = aSiteAuthManager.ForgotPassword(username, company);
        
        PageReference pr = new PageReference('/apex/aSiteForgotPassConfirm');
        pr.getParameters().put('comp',company);
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        return null;
    }
}