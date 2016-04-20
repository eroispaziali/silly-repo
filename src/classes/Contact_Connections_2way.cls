public class Contact_Connections_2way {
  private Contact contact;

  public Contact_Connections_2way() {
        contact = [select id, Salutation, Record_Type_Name__c, RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity  from Contact where id = :ApexPages.currentPage().getParameters().get('id')];
  }
  
  public Contact_Connections_2way(ApexPages.StandardController controller) {
        this.contact= (Contact)controller.getRecord();
  }
    
  public String getName() {
        return 'Inbound and Outbound Connections';
  }

  //method to get a list of all first personal connections for the contact
  public list<SFDC_Contact_Connector__c> getFirstPersonalConnections() {
        //get record type name for every relationship
        RecordType rt1 = [Select Name, Id, DeveloperName From RecordType where Name = 'Personal' limit 1];
        
        //get the list of relationships with recordType = 'Personal'
        //and where the contact is first Contact. 
        List<SFDC_Contact_Connector__c> fPersonalConnections = [select id, name, Type__c, Contact__r.RecordTypeId, Contact__r.Record_Type_Name__c, 
        Related_Contact__r.Record_Type_Name__c, Related_Contact__r.name, Reverse_Relationship_Type__c, Related_Contact__r.Diagnosis__c, Related_Contact__r.Salutation,
        Current__c, Description__c, PoA_Holder__c, Related_Organization__r.name, Primary_Carer__c, Next_of_Kin__c, Keyholder__c, Contact__r.Salutation,
        Contact__r.name, Contact__r.Diagnosis__c, RecordTypeId, Contact_Record_Type__c, Related_Record_Type__c, Emergency_Contact__c from SFDC_Contact_Connector__c 
        where Contact__c = :contact.id and RecordTypeId=:rt1.Id order by Current__c, Contact__r.name];
        //where Contact__c = :contact.id and RecordTypeId=:rt.Id OR Related_Contact__c = :contact.id order by Related_Contact__r.name, Contact__r.name];
        
        //get the list of relationships with recordType = 'Personal'
        //and where the contact is second Contact. 
        List<SFDC_Contact_Connector__c> sPersonalConnections = [select id, name, Type__c, Contact__r.RecordTypeId, Contact__r.Record_Type_Name__c, 
        Related_Contact__r.Record_Type_Name__c, Related_Contact__r.name, Reverse_Relationship_Type__c, Related_Contact__r.Diagnosis__c, Related_Contact__r.Salutation,
        Current__c, Description__c, PoA_Holder__c, Related_Organization__r.name, Primary_Carer__c, Next_of_Kin__c, Keyholder__c, Contact__r.Salutation,
        Contact__r.name, Contact__r.Diagnosis__c, RecordTypeId, Contact_Record_Type__c, Related_Record_Type__c, Emergency_Contact__c  from SFDC_Contact_Connector__c 
        //where Contact__c = :contact.id and RecordTypeId=:rt.Id order by Related_Contact__r.name, Contact__r.name];
        where Related_Contact__c = :contact.id and RecordTypeId=:rt1.Id order by Current__c, Contact__r.name];
        
        for(SFDC_Contact_Connector__c sPCon: sPersonalConnections){
            fPersonalConnections.add(sPCon);
        }
        
        return fPersonalConnections.size()>0?fPersonalConnections:null;
  }
  
  //method to get a list of all personal connections for the contact
  public list<SFDC_Contact_Connector__c> getFirstProfessionalConnections() {
        //get record type name for every relationship
        RecordType rt2 = [Select Name, Id, DeveloperName From RecordType where Name = 'Professional' limit 1];
        
        //get the list of relationships with recordType = 'Professional'
        //and where the contact is first Contact. 
        List<SFDC_Contact_Connector__c> fProfessionalConnections = [select id, name, Type__c, Contact__r.RecordTypeId, Contact__r.Record_Type_Name__c, 
        Related_Contact__r.Record_Type_Name__c, Related_Contact__r.name, Reverse_Relationship_Type__c, Related_Contact__r.Diagnosis__c, Related_Contact__r.Salutation,
        Current__c, Description__c, PoA_Holder__c, Related_Organization__r.name, Primary_Carer__c, Next_of_Kin__c, Keyholder__c, Contact__r.Salutation, 
        Contact__r.name, Contact__r.Diagnosis__c, RecordTypeId, Contact_Record_Type__c, Related_Record_Type__c from SFDC_Contact_Connector__c 
        where Contact__c = :contact.id and RecordTypeId=:rt2.Id order by Current__c, Contact__r.name];
        
        //get the list of relationships with recordType = 'Professional'
        //and where the contact is second Contact. 
        List<SFDC_Contact_Connector__c> sProfessionalConnections = [select id, name, Type__c, Contact__r.RecordTypeId, Contact__r.Record_Type_Name__c, 
        Related_Contact__r.Record_Type_Name__c, Related_Contact__r.name, Reverse_Relationship_Type__c, Related_Contact__r.Diagnosis__c, Related_Contact__r.Salutation,
        Current__c, Description__c, PoA_Holder__c, Related_Organization__r.name, Primary_Carer__c, Next_of_Kin__c, Keyholder__c, Contact__r.Salutation, 
        Contact__r.name, Contact__r.Diagnosis__c, RecordTypeId, Contact_Record_Type__c, Related_Record_Type__c from SFDC_Contact_Connector__c 
        where Related_Contact__c = :contact.id and RecordTypeId=:rt2.Id order by Current__c, Contact__r.name];
        
        for(SFDC_Contact_Connector__c sProfCon: sProfessionalConnections){
            fProfessionalConnections.add(sProfCon);
        }
        
        return fProfessionalConnections.size()>0?fProfessionalConnections:null;
  }
  
  //
  // TEST CASE
  //
  private static testMethod void testRelationships() {
        Contact c1 = new Contact(Salutation='Mr',FirstName='one', LastName='related',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
                RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
        insert c1;
        
        // Set up the VF page
        PageReference pageRef = Page.Contact_Connections_2way;
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', c1.Id);
        
        Contact_Connections_2way cnt = new Contact_Connections_2way();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c1);
        cnt = new Contact_Connections_2way(stdCon);
        
        cnt.getName();
        cnt.getFirstPersonalConnections();
        cnt.getFirstProfessionalConnections();
    }
}