@isTest
public with sharing class TestPropertyContractTriggerHandler{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for PropertyContractTriggerHandler.
 *  Author  : Sri Tadikonda
 *  Date    : 27-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class to test PropertyContractTriggerHandler on the User object. 
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
        
        Property_Contract__c pcRec = new Property_Contract__c(Location__c = propertyRec.Id);
        insert pcRec;
        
        pcRec.Contract_Start_Date__c= system.today();
        update pcRec;
        
        delete pcRec;
        
        Test.stopTest(); 

    } 
}