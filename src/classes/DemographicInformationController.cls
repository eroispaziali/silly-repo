public with sharing class DemographicInformationController {

    private Service_Usage__c serviceUsage;

    //used to get a hold of the Demographic_Information__c record selected for deletion
    public string SelectedId { get; set; }
    public Demographic_Information__c demo {get;set;}
    public String PersonName {get; set;}
    public String PersonReference {get; set;}
    
    public DemographicInformationController(ApexPages.StandardController controller) {

        SelectedId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('***** conId *****' + SelectedId );
        
        if(SelectedId != NULL)
            serviceUsage = [SELECT Id, Primary_Service_User__c, Primary_Service_User__r.Client_reference_number__c, Primary_Service_User__r.Name FROM  Service_Usage__c WHERE Id =: SelectedId];
            system.debug('***** serviceusage *****' + serviceUsage.Id + '|' +  serviceUsage.Primary_Service_User__c + '|' + serviceUsage.Primary_Service_User__r.Client_reference_number__c );        
            PersonReference = ServiceUsage.Primary_Service_User__r.Client_reference_number__c;
            PersonName = ServiceUsage.Primary_Service_User__r.Name;
            //now get Demographic Information record
            List <Demographic_Information__c> demoList = [SELECT id,name, Person__c, NHS_Number__c, Ethnic_Group__c, Ethnicitiy__c, Faith_Culture__c, Employment_Status__c, Partnership_status__c, Number_of_dependent_children__c, Sexual_Status__c, Registered_with_Social_Services__c, People_in_household__c, Veteran__c, Living_arrangements__c, NI_Trust_Area__c, Date_of_Change_of_Living_Arrangements__c, Other_Demographic_Details__c 
                                               FROM Demographic_Information__c  WHERE Person__c=:serviceUsage.Primary_Service_User__c];
            if (demoList.size()==0){
                demo = new Demographic_Information__c ();
                demo.Person__c = serviceUsage.Primary_Service_User__c;
                demo.Name = serviceUsage.Primary_Service_User__r.Client_reference_number__c;
            }
            else {
                demo = demoList[0];
                system.debug('*****demoInf***'+ demo.id + ' '+ demo.name);
            }
            
    }



    // The Demographic_Information__c record we are adding values to
//    public Demographic_Information__c demo{
//        get {
//          if (demo== null)
//            demo = new Demographic_Information__c ();
//            demo.Person__c = serviceUsage.Primary_Service_User__c;
//            demo.Name = serviceUsage.Primary_Service_User__r.Client_reference_number__c;
//          return demo;
//        }
//        set;
//    }


    
    // Save button is clicked.
    public PageReference save() {
        system.debug('*****demoInf saving***'+ demo.id + ' '+ demo.name);
    
        try {
        
            // Insert Demogrphic Info record into the database.
            upsert demo; 
            
        } catch (DMLException e) {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new Demographic Information Record.'));
          return null;
        }
    
        // if Demogrphic Info successfully inserted then redirect to calling page.
        PageReference pageRef = new PageReference('/'+this.SelectedId );
        pageRef.setRedirect(true);
        pageRef.getParameters().put('inline','0'); 
        return pageRef;
        
    }
       

}