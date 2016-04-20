/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Class to retrieve the audit trail list for Contact.
 *  Author  : Fujitsu - Nupoor Pandey
 *  Date    : 2012-03-14
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *
 *  Description: Class to retrieve the audit trail list for Contact. 
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  19-01-2015   MT    REwrite of Test class ContactHistoryAuditTrail
 *                             
*******************************************************************************************/
@isTest
private class ContactHistoryAuditTrail_Test {
    static testMethod void ContactHistoryAuditTrail_Test1 (){
        Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
        insert con1;
        Contact_History__c ConHistory1 = new Contact_History__c(Contact_History__c=con1.Id);
        con1.LastName='test2';
        update con1;
        //put contact id as parameter
        ApexPages.currentPage().getParameters().put('Id', con1.id);   
        ApexPages.StandardController stdCon = new ApexPages.StandardController(ConHistory1);
        ContactHistoryAuditTrail cnt = new ContactHistoryAuditTrail(stdCon);
    }  
    
}