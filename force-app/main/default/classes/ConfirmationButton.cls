//Sales Confirmation button from the opp to pdf
global class ConfirmationButton {

    Opportunity theOpportunity = new Opportunity();   
    String theOpportunityID; 
        
    // Constructor - this only really matters if the autoRun function doesn't work right     
    public ConfirmationButton(ApexPages.StandardController stdController) {        
        this.theOpportunity = (Opportunity)stdController.getRecord();     
    } 
    
    // Code invoked on page load.      
    public PageReference autoRun()
    {           
        String thePageOpportunityId = ApexPages.currentPage().getParameters().get('id'); 
        String mensaje = '';
        if (thePageOpportunityId == null) 
        {
            return null;         
        }
        try{
            mensaje = GenerateConfirmation(thePageOpportunityId);
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Call PDF method - ' + e.getMessage() + '' + e.getLineNumber());
            ApexPages.addMessage(myMsg);
            return null;
        }

        PageReference ref = new PageReference('/one/one.app?source=aloha#/sObject/' + thePageOpportunityId + '/view');
        ref.setRedirect(true);    
        return ref;    
    }
    
    WebService static String GenerateConfirmation(Id oppId){

        Blob body;
        Opportunity opp;
        attachment attach = new attachment();
                    
        try{
            opp = [Select Id, Name, Attendance__r.Email, Owner.Email, Owner.Title, Owner.Name From Opportunity Where Id =:oppId limit 1];                
            PageReference pdf = Page.PDFPedidoVenta;
            
            pdf.getParameters().put('idOpp', opp.Id);
            body = pdf.getContentAsPDF();    
            
        }
        catch (VisualforceException e) {
            body = Blob.valueOf('Missing Text');
            return e.getMessage();
        }
        catch(exception e) {
            return 'Call PDF method - ' + e.getMessage() + '' + e.getLineNumber();
        }
        
        try {
            attach.Body = body;         
            attach.Name = 'Confirmation of Sale #' + opp.Name + '.pdf';
            attach.IsPrivate = false;
            attach.ParentId = opp.Id;            
            insert attach;

        }
        catch(exception e) {
            return 'Attach method - ' + e.getMessage();
        }

        // ************************ for email creation************************************                
        Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
        attach2.setContentType('application/pdf');
        attach2.setFileName(attach.Name);
        attach2.setInline(false);
        attach2.Body = body;
        
        try{

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String bodyTxt = '';
            
            String[] toAddresses = new String[]{};
            if(opp.Owner.Email != null){
                toAddresses.add(opp.Owner.Email);
//                toAddresses.add('cmsimmons@gdmseeds.com');                
                mail.setReplyTo(opp.Owner.Email);
                mail.setSenderDisplayName(opp.Owner.Name);                    
                bodyTxt = 'Dear customer,<br/>Attached you will find our Confirmation of Sale document.<br/>Thank you for your business!<br/><br/>' + opp.Owner.Name + '<br/>' + opp.Owner.Title;
                mail.setHtmlBody(bodyTxt); 
            }
            if(opp.Attendance__c!=null)
                toAddresses.add(opp.Attendance__r.Email);        
        
            mail.setToAddresses(toAddresses);
            mail.setSaveAsActivity(true);
            mail.setSubject('GDMSeeds – Confirmation of Sale #' + opp.name);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach2 });
        
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
        catch(exception e) {
            return 'Mailing method - ' + e.getMessage() + '' + e.getLineNumber();
        }

        return attach.Name;
    }
    
}