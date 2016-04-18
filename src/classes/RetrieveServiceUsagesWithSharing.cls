/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Retrive Service Usage Records accessible to User.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-11-18
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: Retrive Service Usage records avaialble/accessible to User, based on passed parameters. 
 *        Instantiated from:
 *            1) TriggerEventAfterInsertUpdateCreateAttendeeDetails
 *            2) EventAttendeeController
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2012-02-07  MT  removed secondary service user (Secondary_Service_User__c) 
 *                             
*******************************************************************************************/
public with sharing class RetrieveServiceUsagesWithSharing
{
//Get the Service Usage records, user is having access to. Executes query under user context.
    public List<Service_Usage__c> getSURecordsOfServciesNContacts(set<Id> setContactIds, set<Id> setServiceIds)
    {
     return ([Select Primary_Service_User__c,Primary_Service_User__r.RecordType.Name, 
                 Service_Field__c
                 from Service_Usage__c where Primary_Service_User__c =:setContactIds  or Service_Field__c =:setServiceIds]);
    }   
    

    public List<Service_Usage__c> getSURecordsOfService(string strWhatId)
    {
        return [Select Primary_Service_User__c,Primary_Service_User__r.Name,
                    Primary_Service_User__r.HomePhone,
                    Primary_Service_User__r.LastName,Primary_Service_User__r.MailingPostalCode,
                    Primary_Service_User__r.RecordType.Name,
                    Primary_Service_User__r.Contact_Full_Name__c,
                    Primary_Service_User__r.Birthdate,
                    Closure_Date__c, Referral_Outcome__c
                    from Service_Usage__c 
                    where Service_Field__c =: strWhatId 
                    and Closure_Date__c=null
                    and (Referral_Outcome__c='Service Required'
                    or Referral_Outcome__c=null
                    or Referral_Outcome__c='Case Opened')];                
    }                
}