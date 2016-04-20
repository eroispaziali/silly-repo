/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : VF Page controller methods for ContactRelationshipRelatedList, shown as RelatedList on Contact for Relationships.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2012-01-24
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *  Copyright (c) Saaspoint 2012 as per Master Services Agreement
 *
 *  Description: VF Page controller, returns Relationships where current Contact is set as main or related. 
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/

public class ContactRelationshipRelatedListController {
  private Contact contact;

  //Constructor
  public ContactRelationshipRelatedListController() {
        contact = [select id, Record_Type_Name__c, RecordTypeId, Diagnosis__c from Contact where id = :ApexPages.currentPage().getParameters().get('id')];
  }
  
  //StandardController Constructor
  public ContactRelationshipRelatedListController(ApexPages.StandardController controller) {
        this.contact= (Contact)controller.getRecord();
  }
    
  //Method returns list of Relationship records where Contact is either Main or Related, order by Name.
  public list<SFDC_Contact_Connector__c> getConnections() {
        List<SFDC_Contact_Connector__c> connections; 
        connections = [select id, name, Type__c, Contact__r.RecordTypeId, Contact__r.Record_Type_Name__c, Related_Contact__r.Record_Type_Name__c, Contact__r.name, 
        Related_Contact__r.name, Reverse_Relationship_Type__c, Related_Contact__r.Diagnosis__c, Current__c, Description__c, PoA_Holder__c,
        Related_Organization__r.name, Primary_Carer__c, Next_of_Kin__c, Keyholder__c from SFDC_Contact_Connector__c where 
        Contact__c = :contact.id OR Related_Contact__c = :contact.id order by Related_Contact__r.name, Contact__r.name];
        return connections;
  }
  
  //
  // TEST CASE
  //
  private static testMethod void testRelationships() {
        Contact c1 = new Contact(FirstName='one', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today());
        insert c1;
        
        // Set up the VF page
        PageReference pageRef = Page.ContactRelationshipRelatedList;
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', c1.Id);
        
        ContactRelationshipRelatedListController cnt = new ContactRelationshipRelatedListController();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c1);
        cnt = new ContactRelationshipRelatedListController(stdCon);
        
        //cnt.getName();
        cnt.getConnections();
    }
}