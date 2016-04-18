@isTest
private class Test_DA_Triggers {
    //
    // CONTACT EVENT TRIGGERS
    //
    static testMethod void testContactEventTriggers() {
        // find sys admin account
        User u = [select id from User where isActive = true limit 1];
        
        // create test user
        Contact c = new Contact(lastName='test',FirstName='Abc',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
                RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
        //c.status__c = 'New referral';
        insert c;
    }
    
    //
    // RELATIONSHIP TRIGGERS
    //
    static testMethod void testRelationshipTriggers() {
        // create test record type
        //RecordType r = [select Id, Name from RecordType where Name like '%Person%'];
        
        // create test users
        Contact c = new Contact(Salutation='Mr',FirstName='Abc',LastName='pwd',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
                RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
        //c.status__c = 'New referral';
        //c.RecordTypeId = r.Id;
        insert c;
        
        Contact c2 = new Contact(Salutation='Mr',FirstName='Abc',LastName='carer2',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
                RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with Dementia'].id);
        //c2.status__c = 'New referral';
        //c2.RecordTypeId = r.Id;
        insert c2;
        
        // Create relationship record
        SFDC_Contact_Connector__c relationship = new SFDC_Contact_Connector__c();
        
        relationship.Contact__c = c.Id;
        relationship.Related_Contact__c = c2.Id;
        
        insert relationship;
        
        relationship.Status__c = 'New';
        
        update relationship;
    }
    
    /*
     * TEST CRS TRIGGERS
     */
     static testmethod void testContactAccountTrigger() {
        Contact c = new Contact(LastName='test lname',Salutation='Mr',FirstName='Abc',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
                RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);

        insert c;
    }
}