public with sharing class ServiceUsageDemographicInfoRLController {

    boolean isNewButtonDisabled = false;

    
    public List<Demographic_Information__c> demoInfo { get;set; }
    public Demographic_Information__c demographicRec {get;set;}
    public String DemographicStatus {get;set;}
    //used to get a hold of the Demographic_Information__c record selected for deletion
    public string SelectedId { get; set; }
 
 
    public ServiceUsageDemographicInfoRLController (ApexPages.StandardController controller) {
        List<Demographic_Information__c> demo = new List<Demographic_Information__c>();
        demo = [SELECT Id, Name, Person__c FROM Demographic_Information__c 
                    WHERE Person__c IN (SELECT Primary_service_user__c 
                                        FROM Service_Usage__c where Id= :System.currentPageReference().getParameters().get('Id'))];
                     
        if(demo.size() == 0)                                            
            isNewButtonDisabled = false;
        else
            isNewButtonDisabled = True;
            LoadData();

    }
  
    private void LoadData() {
         List<Demographic_Information__c> demoList = [SELECT  id,
                NHS_Number__c,
                Ethnic_Group__c,
                Ethnicitiy__c,
                Faith_Culture__c,
                Employment_Status__c,
                Partnership_status__c,
                Number_of_dependent_children__c,
                Sexual_Status__c,
                Registered_with_Social_Services__c,
                People_in_household__c,
                Veteran__c,
                Living_arrangements__c,
                NI_Trust_Area__c,
                Date_of_Change_of_Living_Arrangements__c,
                Other_Demographic_Details__c, 
                Information_Completed__c 
                from Demographic_Information__c where Person__c IN (SELECT Primary_service_user__c 
                                                                    FROM Service_Usage__c 
                                                                    where Id= :System.currentPageReference().getParameters().get('Id'))];
        if  (demoList.size()==0){
                 demographicRec = new Demographic_Information__c();
                 DemographicStatus = 'No information'; 

                              }
        else {demographicRec = demoList[0];
              if  (demographicRec.Information_Completed__c == 'RED')  {DemographicStatus = 'Little demographic information';}
              if  (demographicRec.Information_Completed__c == 'AMBER')  {DemographicStatus = 'Missing demographic information';}
              if  (demographicRec.Information_Completed__c == 'GREEN')  {DemographicStatus = '';}
        }
                 
    }
    
    
    public void create() {
        isNewButtonDisabled = true;
    }
    
    
    public boolean getIsNewButtonDisabled() {
      return isNewButtonDisabled;
    } 
    public pageReference EditDemographic(){
        String sUrl='/apex/DemographicInformationEdit?id=' + System.currentPageReference().getParameters().get('Id');
        return new PageReference(sUrl);
        
    }    
    public PageReference NewImplementation() {
            
            
PageReference page = new  PageReference('/a0Z/e');
    page.setRedirect(true);
    return page; 
            
            
            
             
    }    
            
    
}