public with sharing class UIDemographicInfoRLController {

    public boolean showAddButton {get;set;}
    public boolean showData {get;set;}

    public List<Demographic_Information__c> lisDgData = new List<Demographic_Information__c>();
    public List<Demographic_Information__c> dgData { get;set; }
    
    //used to get a hold of the Demographic_Information__c record selected for deletion
    public string SelectedId { get; set; }
 
 
    public UIDemographicInfoRLController (ApexPages.StandardController controller) {

        UI_Participant__c p = [select id, Status__c from UI_Participant__c where id = :System.currentPageReference().getParameters().get('Id')];                           
        lisDgData = [SELECT Id, Name, Person__c FROM Demographic_Information__c 
                    WHERE Person__c IN (SELECT Contact__c 
                                        FROM UI_Participant__c where Id = :p.id)];                     

		showAddButton = (p.Status__c=='Active' && lisDgData.size() == 0);
		showData=false;        

		/* Hide the data if the user is not Active */
        if (p.Status__c == 'Active') {
            dgData = lisDgData; 
            showData=true;
        }
    }
        
    public void create() {
        showAddButton = false;
    }
    
}