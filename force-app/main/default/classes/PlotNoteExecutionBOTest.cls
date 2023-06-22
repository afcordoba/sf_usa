/**
 * An apex page controller that exposes the mssive creation of notes
 */
@IsTest public with sharing class PlotNoteExecutionBOTest {
     
     @IsTest(SeeAllData=true) public static void testNoteCreationTrigger() {
        
        Macroregion__c m = new Macroregion__c(Name='SCB');
        insert m;
        County__c co = new County__c(Name='TEST', Macroregion__c=m.Id);
        insert co;
        Location__c l = new Location__c(Name='TES',County__c=co.Id);
        insert l;
        Plot_location__c pl = new Plot_location__c(Location__c=l.Id, Name='TEST');
        insert pl;
        Explore_Plot_Cell__c cell = new Explore_Plot_Cell__c(Explore_Plot__c=pl.Id, QR_Code__c='123');
        insert cell;
        
        Account a = new Account(Name='TEST A', Location__c=l.Id);
        insert a;        
        SiteUser__c user = new SiteUser__c(Email__c='j@mil.com',Notification_Bean_Blog__c=true, Notification_Visit__c=true, Password__c='df',Name='JERE',Brand_GDM__c=true,Status__c='Approved', Account__c=a.Id);
        insert user;
        
        Explore_Rating__c rating = new Explore_Rating__c(Name='Eye', Visible_Name__c='Eye Appeal'); insert rating;    
        Explore_Rating__c ratingFill = new Explore_Rating__c(Name='FILL', Visible_Name__c='Fill'); insert ratingFill;    
        
        Plot_Saved_Soy__c note = new Plot_Saved_Soy__c(note__c='TEST',SiteUser__c=user.Id,Plot_location__c=pl.Id, Plot_Cell__c=cell.Id); insert note;
        Explore_Plot_Note_Score__c ex = new Explore_Plot_Note_Score__c(Explore_Rating__c=rating.Id, Plot_Note__c=note.Id, Score_Value__c='2'); insert ex;
                
        // Instantiate a new controller with all parameters in the page
        Mass_Plot_Note__c mm = new Mass_Plot_Note__c();
        mm.Plot_Location__c = pl.Id;
        mm.SiteUser__c = user.Id; 
        mm.Explore_Rating__c = rating.Id;                
        mm.Value__c = '1';
        
        insert mm;
                                  
        Plot_Saved_Soy__c note2 = new Plot_Saved_Soy__c(note__c='TEST',SiteUser__c=user.Id,Plot_location__c=pl.Id, Plot_Cell__c=cell.Id); insert note2;
        Explore_Plot_Note_Score__c ex2 = new Explore_Plot_Note_Score__c(Explore_Rating__c=rating.Id, Plot_Note__c=note2.Id, Score_Value__c='2'); insert ex2;
        Explore_Plot_Note_Score__c exFill = new Explore_Plot_Note_Score__c(Explore_Rating__c=ratingFill.Id, Plot_Note__c=note2.Id, Score_Value__c='1'); insert exFill;
        
    }    
}