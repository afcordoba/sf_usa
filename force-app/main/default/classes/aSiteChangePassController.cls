public class aSiteChangePassController {

    public String company {get; set;}    

    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    public String token {get; set;}
    public string language {get;set;}

    public PageReference validate() {
        token = System.currentPageReference().getParameters().get('token');
        
        if(token==null){
            PageReference p = new PageReference('/apex/aSiteLogin');
            p.setRedirect(true);
            return p;            
        }
        return null;
    }

    public PageReference ChangePassword() {

        if(oldPassword == '' || oldPassword == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Old password is required!'));
            return null;
        }
        if(newPassword == '' || newPassword == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'New password is required!'));
            return null;
        }
        if(newPassword != verifyNewPassword){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'New password and Verify Password are not the same!'));
            return null;
        }
    
        String success = aSiteAuthManager.ChangePassword(token, newPassword, verifyNewPassword, oldpassword);
        PageReference pr = Page.aSiteActionConfirmation;        
        pr.setRedirect(true);
        
        if (success == 'Ok') {
            aSiteAuthManager.CloseUserSession(token);
            if(company != null && !company.isWhitespace())
                pr.getParameters().put('comp',company);
            return pr;
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'The change password action was not finished! ' + success));
        return null;
    }     
    
    public aSiteChangePassController() {
        language = [select id, LanguageLocaleKey from User where id =: UserInfo.getUserId()].LanguageLocaleKey;
        company = System.currentPageReference().getParameters().get('comp');
    }
}