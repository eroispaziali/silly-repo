@isTest
public with sharing class TestPropertyAuditTriggerHandler{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for PropertyAuditTriggerHandler.
 *  Author  : Sri Tadikonda
 *  Date    : 27-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class to test PropertyAuditTriggerHandlertrigger on the User object. 
 *               
 *  Modification History
 *
 *  Date            Who     Description 
 *  dd-mm-yyyy      ??      ??
 *                             
*******************************************************************************************/

static testMethod void testInsert()
    {
        Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
        Test.startTest();
        insert accRec;
        
        Location__c propertyRec = new Location__c(Name='Alzheimers Soceity',Where__c = accRec.Id,RecordTypeId=[Select Id from RecordType where SObjectType='Location__c' and Name like 'Lease%'].id);
                
        insert propertyRec ;
        
        Property_Audit__c paRec = new Property_Audit__c(Location__c = propertyRec.Id,Audit_Date__c = system.today());
        
        insert paRec;
        
        paRec.NumberofFloors__c ='4';
        update paRec;
        
        delete paRec;
        
        Test.stopTest(); 

    } 
}