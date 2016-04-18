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
 *  04/08/2012 17:19  Gunish Chawla    Live version
 *  19/1/2015  Mike Tinson    update slow running test - remove to separate test class and update version of this class
 *                             
*******************************************************************************************/
public with sharing class ContactHistoryAuditTrail {

    public Contact person {get; private set;}
    public List<Contact_History__c> contactHistory{get; private set;}

    /**
    Constructor to get the Contact Id from the page and retrieve the following:
        :ContactHistory__c
    */
    public ContactHistoryAuditTrail(ApexPages.StandardController controller) {
        Id id = ApexPages.currentPage().getParameters().get('id');
        person = (id == null) ? new Contact() : 
            [Select c.rrpu__Alert_Message__c, c.Date_of_diagnosis__c, c.Diagnosis__c, c.Diagnosis_made_by__c, c.Id, c.Firstname, c.LastName, 
            c.MailingStreet, c.MailingCity, c.MailingState, c.MailingCountry, c.MailingPostalCode, c.Service_user_aware_of_diagnosis__c, 
            c.Specialist_Communication_Needs__c From Contact c WHERE id = :id];
            
            contactHistory = [Select c.User__c, c.SystemModstamp, c.Specialist_Communication_Needs__c, c.Service_User_aware_of_diagnosis__c, 
            c.OwnerId, c.Name, c.Mailing_Address__c, c.MailingStreet__c, c.MailingState__c, c.MailingPostalCode__c, c.MailingCountry__c, 
            c.MailingCity__c, c.Lastname__c, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Firstname__c, c.Diagnosis_made_by__c, 
            c.Diagnosis__c, c.Date_of_Diagnosis__c, c.Date__c, c.CreatedDate, c.CreatedById, c.Contact_History__c, c.Alert_Message__c, c.Action__c 
            From Contact_History__c c where Contact_History__c = :person.Id Order by Date__c DESC];
    }   
 
}