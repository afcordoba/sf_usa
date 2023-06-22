public class PlotNoteExecutionBO {

    private static final PlotNoteExecutionBO instance = new PlotNoteExecutionBO();    
    private PlotNoteExecutionBO(){}
    
    public static PlotNoteExecutionBO getInstance() {
        return instance;
    }
    
    public void executeStartNoteMassUpdate(List<Explore_Plot_Note_Score__c> objToProcessing) {
        
        List<Explore_Plot_Note_Score__c> scores = new List<Explore_Plot_Note_Score__c>();
    
        for(Explore_Plot_Note_Score__c score : objToProcessing )   //Detect a note with FILL not N/A
        {   
            if(score.Explore_Rating__r.Name=='FILL' && score.Score_Value__c!='N/A'){

                Plot_Saved_soy__c note = score.Plot_Note__r; 
                Explore_Plot_Cell__c cell = note.Plot_Cell__r; 
                Plot_location__c loc = cell.Explore_Plot__r;
                SiteUser__c user = note.SiteUser__r;
                scores = [Select Id, Explore_Rating__r.Name, Explore_Rating__c From Explore_Plot_Note_Score__c where Id != :score.Id and Plot_Note__c = :note.Id];
    
                List<Mass_Plot_Note__c> masses = new List<Mass_Plot_Note__c>();
                
                for(Explore_Plot_Note_Score__c s : scores){
                    if(s.Explore_Rating__r.Name=='FILL')
                        continue;
                    Mass_Plot_Note__c mass = new Mass_Plot_Note__c();
                    mass.Date__c = score.Date__c;
                    mass.Explore_Rating__c = s.Explore_Rating__c;
                    mass.Plot_Location__c = loc.Id;
                    mass.SiteUser__c = user.Id;
                    mass.Value__c = score.Score_Value__c;
                    //masses.add(mass);
                    insert mass;    
                }
                //insert masses;
            }            
        }
    }
    
    public void executeNoteMassUpdate(List<Mass_Plot_Note__c> objToProcessing) {
            
        List<Explore_Plot_Cell__c> emptyCells = new List<Explore_Plot_Cell__c>();
        List<Explore_Plot_Cell__c> allCells = new List<Explore_Plot_Cell__c>();
        List<Id> noteCellsId = new List<Id>();        
        List<Plot_Saved_Soy__c> notes = new List<Plot_Saved_Soy__c>();
        List<Explore_Plot_Note_Score__c> scores = new List<Explore_Plot_Note_Score__c>();
                
        for(Mass_Plot_Note__c n : objToProcessing )
        {           
            
            noteCellsId = queryNoteCells(n);
            System.debug('JERE:::' + noteCellsId);
            
            emptyCells = queryEmptyCells(n, noteCellsId);
            System.debug('JERE:::' + emptyCells.size());
            
            for(Explore_Plot_Cell__c c : emptyCells){
                Plot_Saved_Soy__c note = new Plot_Saved_Soy__c();
                note.Plot_location__c = n.Plot_Location__c;
                note.SiteUser__c = n.SiteUser__c;
                note.Created_date__c = n.Date__c;
                note.Plot_Cell__c = c.Id;
                note.Mass_Plot_Note__c = n.Id;                    
                note.Active__c = true;            
                note.Type__c = 'NOTE';                
                note.Variety__c = c.Variety__c;
                notes.add(note);    
            }
            
            insert notes;
            
            for(Plot_Saved_Soy__c note : notes){    
                Explore_Plot_Note_Score__c score = new Explore_Plot_Note_Score__c();
                score.Explore_Rating__c = n.Explore_Rating__c;
                score.Plot_Note__c = note.Id;
                score.Score_Value__c = n.value__c;
                scores.add(score);            
            }
           
            insert scores;
            
        }    
   
    }
 
    public List<Explore_Plot_Cell__c> queryEmptyCells( Mass_Plot_Note__c n, List<Id> ids) {        
        
        List<Explore_Plot_Cell__c> cels;        
        cels = [Select Id, Name, Variety__c from Explore_Plot_Cell__c Where Explore_Plot__c = :n.Plot_location__c and Id NOT in :ids]; 

        return cels;
    }
    
    public List<Id> queryNoteCells( Mass_Plot_Note__c n) {        
        
        List<id> listaToTrue = new List<id>();

        for(Explore_Plot_Note_Score__c e : [Select Id, Name, Plot_Note__r.Plot_Cell__c from Explore_Plot_Note_Score__c where
            Plot_Note__r.SiteUser__c = :n.SiteUser__c and Score_value__c != 'N/A' and Explore_Rating__c = :n.Explore_Rating__c and Plot_Note__r.Plot_Location__c = :n.Plot_location__c and Date__c = :n.Date__c]){
            
            listaToTrue.add(e.Plot_Note__r.Plot_Cell__c);
        } 

        return listaToTrue;
    }
    
}