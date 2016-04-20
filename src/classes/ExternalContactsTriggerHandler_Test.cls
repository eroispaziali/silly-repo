@isTest
/***********************************************************************************************
* @author          Lakshmi Rajendram 
* @date            02-03-2015
* @description     Test class for ExternalContactsTriggerHandler
***********************************************************************************************/


public class ExternalContactsTriggerHandler_Test {
    static testMethod void TestOnAfterInsertUpdateExContact()
    {
        
        Map<String, Object> mapTestData= TestDataFactory_Services.getTestData();
        External_Contacts__c exContact = (External_Contacts__c)mapTestData.get('exContact');
        exContact.Contact_Type__c='Public Contact;Primary Contact';
        update exContact;
        
    }
    
    
    
}