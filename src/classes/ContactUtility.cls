public with sharing class ContactUtility {

    public static void updateContact(Set<String> contactIds){
        List<Contact> contactToUpdate = new List<Contact>();
        List<Contact> contactList = [Select c.testFlag__c, c.Id From Contact c where Id in :contactIds];
        for(Contact contact: contactList){
            contact.testFlag__c = true;
            contactToUpdate.add(contact);
        }
        System.debug('contactToUpdate: '+contactToUpdate);
        Database.update(contactToUpdate);
    }
 //
 // TEST CASE
 //
 private static testMethod void testContactUtility() {
  
    Contact c1 = new Contact(FirstName='one', LastName='test1',MailingPostalCode ='ABC123', Birthdate =Date.Today());
    insert c1;

    c1.LastName='test2';
    update c1;
    Set<String> contactIds = new Set<String>();
    contactIds.add(c1.Id);
    ContactUtility.updateContact(contactIds);
    }  
}