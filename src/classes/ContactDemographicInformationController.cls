public with sharing class ContactDemographicInformationController {

    private Contact contact;

    //used to get a hold of the Demographic_Information__c record selected for deletion
    public string rtnId { get; set; }
    public Demographic_Information__c demo {get;set;}

    public String PersonName {get; set;}
    public String PersonReference {get; set;}
    
    public ContactDemographicInformationController(ApexPages.StandardController controller) {

        String id = ApexPages.currentPage().getParameters().get('id');
        rtnId = ApexPages.currentPage().getParameters().get('rtnId');
        
        if(id != NULL)
            contact = [SELECT Id, Client_reference_number__c, Name FROM  Contact WHERE Id =: id];
            PersonReference = contact.Client_reference_number__c;
            PersonName = contact.Name;

            //now get Demographic Information record
            List <Demographic_Information__c> demoList = [SELECT id,name, Person__c, NHS_Number__c, Ethnic_Group__c, Ethnicitiy__c, Faith_Culture__c, Employment_Status__c, Partnership_status__c, Number_of_dependent_children__c, Sexual_Status__c, Registered_with_Social_Services__c, People_in_household__c, Veteran__c, Living_arrangements__c, NI_Trust_Area__c, Date_of_Change_of_Living_Arrangements__c, Other_Demographic_Details__c 
                                               FROM Demographic_Information__c  WHERE Person__c=:id];
            if (demoList.size()==0){
                demo = new Demographic_Information__c ();
                demo.Person__c = id;
                demo.Name = contact.Client_reference_number__c;
            }
            else {
                demo = demoList[0];
                system.debug('*****demoInf***'+ demo.id + ' '+ demo.name);
            }
            
    }

    
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
        PageReference pageRef = new PageReference('/'+this.rtnId );
        pageRef.setRedirect(true);
        pageRef.getParameters().put('inline','0'); 
        return pageRef;
        
    }
       

}