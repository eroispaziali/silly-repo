@isTest
private class TestTriggerExistingRelation{

static testMethod void mytestclass(){
    Contact c1 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
            MailingCity='Abcd', MailingCountry='Abcd', MailingState='Abcd', MailingStreet='Abcd',
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);    
        insert c1;
    Contact relcon = new Contact(FirstName='two', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Carer of Person with Dementia'].id);  
        insert relcon;
    Id personal = [SELECT Id,Name FROM RecordType WHERE SobjectType='SFDC_Contact_Connector__c' AND Name ='Personal'].id;
    Id professional  = [SELECT Id,Name FROM RecordType WHERE SobjectType='SFDC_Contact_Connector__c' AND Name ='Professional'].id;
    
     SFDC_Contact_Connector__c Relation1 = new SFDC_Contact_Connector__c(RecordTypeId=personal, Contact__c=c1.id, Related_Contact__c=relcon.id, Type__c='Spouse of',Same_Address__c=true);
     insert Relation1;
     SFDC_Contact_Connector__c Relation2 = new SFDC_Contact_Connector__c(RecordTypeId=personal, Contact__c=c1.id, Related_Contact__c=c1.id, Type__c='Spouse of',Same_Address__c=true);     
     SFDC_Contact_Connector__c Relation3 = new SFDC_Contact_Connector__c(RecordTypeId=personal, Contact__c=c1.id, Related_Contact__c=relcon.id, Type__c='Spouse of',Same_Address__c=true);
      try
        {
            insert Relation2;
        }
        catch(System.DMLException e)
        {
         System.assert(e.getMessage().contains('Relationship with Self can not be created'));
        }    
        try
        {
            insert Relation3;
        }
        catch(System.DMLException e)
        {
         System.assert(e.getMessage().contains('A Relationship already exists with the same person'));
        }     
        
 }
}