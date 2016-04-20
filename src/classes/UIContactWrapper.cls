public without sharing class UIContactWrapper{

  /***********************************************************************************************************
    *
    *   @author        :  gary.grant@conseq.co.uk
    *   @date          :  August 2014
    *   @description   :  A wrapper class for a Contact in the context of User Involvement 
    *                     Contains data about the Contact, demographic data and General Consent   
                          which is in the Participant record                  
    *     
    ************************************************************************************************************/

    public UI_Participant__c participant {get;set;}
    public Contact contact {get;set;}
    public Demographic_Information__c dgdata {get;set;}
    
    /* Constructor for a single instance. Do not use this version of the constructor for list - that will exceed the 
       query governor limits very quickly. */ 
    public UIContactWrapper(Contact c) {
    
      contact = c;       

      /* Demographic information is stored on a separate record in the database 
         This record will not be saved but is there to make the data model complete. 
      */  

	  dgdata = (Demographic_Information__c)CustomUtils.ObjectWithAllFields('Person__c', contact.id , Schema.sObjectType.Demographic_Information__c);
      if (dgdata == null) {
          dgdata = new Demographic_Information__c();
          dgdata.Person__c = contact.id;
          dgdata.OwnerId = contact.OwnerId;
          dgdata.Name = contact.Client_reference_number__c;          
      }
      
      
      /* The User Involvement data is stored in a separate record that records general consent to be involved */         
      participant = (UI_Participant__c)CustomUtils.ObjectWithAllFields('Contact__c', contact.id , Schema.sObjectType.UI_Participant__c);      
      if (participant==null) {               
            // Create a new Consent Object. This is used in the view and may not be saved. 
            participant = new UI_Participant__c();
            participant.Contact__c = contact.id;
            participant.Status__c = 'Unconfirmed';              
      }
    
    }

	// Partial Constructor
    public UIContactWrapper(Contact c, UI_Participant__c p) {
    
      contact = c;       
      participant = p;
                  
      /* The User Involvement data is stored in a separate record that records general consent to be involved        
         Create a new Consent Object. This is used in the view and may not be saved.
      */                    
      if (participant==null) {                      
          participant = new UI_Participant__c();
          participant.Contact__c = contact.id;
          participant.Status__c = 'Unconfirmed';              
      }
    
    }

	// Full Constructor
    public UIContactWrapper(Contact c, UI_Participant__c p, Demographic_Information__c dg) {
    
      contact = c;       
      participant = p;
      dgdata = dg;      

      /* Demographic information is stored on a separate record in the database 
         This record will not be saved but is there to make the data model complete. 
      */  

      if (dgdata == null) {
          dgdata = new Demographic_Information__c();
          dgdata.Person__c = contact.id;
          dgdata.OwnerId = contact.OwnerId;
          dgdata.Name = contact.Client_reference_number__c;          
      }
      
      
      /* The User Involvement data is stored in a separate record that records general consent to be involved        
         Create a new Consent Object. This is used in the view and may not be saved.
      */                    
      if (participant==null) {                      
          participant = new UI_Participant__c();
          participant.Contact__c = contact.id;
          participant.Status__c = 'Unconfirmed';              
      }
    
    }


}