@isTest
public class TestAccountTriggerHandler{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for AccountTriggerHandler.
 *  Author  : Mike Tinson
 *  Date    : 14-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class to test AccountTriggerHandlertrigger on the User object. 
 *               
 *  Modification History
 *
 *  Date            Who                   Description 
 *  15-10-2014      Lakshmi Rajendram      Added Further test related to set account address from property
 *                             
*******************************************************************************************/

static testMethod void testInsertUpdate(){
   
  Account accRec1 = new Account(Name='Midlands Central Locality Account',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
   insert accRec1;
   Location__c propertyRec = new Location__c(Name='Alzheimers Soceity',Where__c=accRec1.id,City__c='Test City',Postcode__c='TE1 1TN',Street__c='Test Street',County__c='Test County',Country__c='Test Country',Postcode_Constituency__c='Test Con',Postcode_Local_Authority__c='Test LA',Postcode_Primary_Care_Trust__c= 'Test PCT',Postcode_Ward__c='Test Ward',Clinical_Commissioning_Group__c='Test CCG',RecordTypeId=[Select Id from RecordType where SObjectType='Location__c' and Name like 'Lease%'].id);
   insert propertyRec;
   Location__c propertyRec2 = new Location__c(Name='Alzheimers Soceity 2',Where__c=accRec1.id,City__c='Test City2',Postcode__c='TE1 2TN',Street__c='Test Street2',County__c='Test County2',Country__c='Test Country2',RecordTypeId=[Select Id from RecordType where SObjectType='Location__c' and Name like 'Lease%'].id);   
   insert propertyRec2;
   Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
   insert accRec;
   accRec.Property__c= propertyRec.id;
   update accRec;
   
   
    
    
    accRec=[Select BillingPostalCode,BillingStreet,BillingCity,BillingState,BillingCountry from Account where Id=:accRec.Id Limit 1];
    System.assertEquals(accRec.BillingPostalCode,'TE1 1TN');
    System.assertEquals(accRec.BillingStreet,'Test Street');
    System.assertEquals(accRec.BillingCity,'Test City');
    System.assertEquals(accRec.BillingState,'Test County'); 
    System.assertEquals(accRec.BillingCountry,'Test Country');   
    
    accRec.Property__c= propertyRec2.id;
    update accRec;
    
    delete accRec;
    
   

    } 
}