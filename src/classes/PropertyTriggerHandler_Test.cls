@isTest
public with sharing class PropertyTriggerHandler_Test{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for PropertyTriggerHandler.
 *  Author  : Lakshmi Rajendram
 *  Date    : 09-01-2015
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class to test PropertyTriggerHandlertrigger on the User object. 
 *               
 *  Modification History
 *
 *  Date            Who     Description 
 *  dd-mm-yyyy      ??      ??
 *                             
*******************************************************************************************/

static testMethod void propertyInsert()
    {
      
        Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
        Test.startTest();
        insert accRec;

        System.debug('Account: [' + accRec.AccountNumber+ '] has inserted into system.');
        Location__c p = new Location__c(Name='Alzheimers Soceity',Where__c = accRec.Id,RecordTypeId=[Select Id from RecordType where SObjectType='Location__c' and Name like 'Lease%'].id, Street__c='test the street name long ass string first more than 80 character for testing the');

        insert p ;
        p = [SELECT Street__c,Street_Line_1__c, Street_Line_2__c,Street_Line_3__c,Street_Line_4__c  FROM Location__c WHERE Id =:p.Id Limit 1];

        System.assertEquals(p.Street_Line_1__c,'test the street name long ass string first more than 80 character for testing th');
        System.assertEquals(p.Street_Line_2__c,'e');
        System.assertEquals(p.Street_Line_3__c,null);
        System.assertEquals(p.Street_Line_4__c,null);

        p.Street__c  = 'test with three\nline address this\nis street address\nthis is street address 3';
        update p;                        
        p.Street__c  = 'test with two\nline address this\nis shipping address on when second line is overshot the length by 80 or more characters on the third line of the address\nfourth line';
        update p;
        p.Street__c  = 'test with two\nis shipping address on when second line is overshot the length by 80 or more characters on the third line of the addressline address this\n\nfourth line';
        update p;
        p.Street__c  = 'test the street name less than 80 character\n111111111122222222223333333333444444444455555555556666666666777777777788888888889\nthird line\nfourth line';
        update p;
        p.Street__c  ='test the street name less than 80 character\nsecond line\nthird line 11111111112222222222333333333344444444445555555555666666666677777777778888888888\nfourth line';
        update p;
        p.Street__c  ='test the street name less than 80 character\nsecond line\nthird line\nfourth line 111111111122222222223333333333444444444455555555556666666666777777';
        update p;
        p.Street__c  ='test the street name less than 80 character\nsecond line\nthird line\nfourth line' ;
        update p;
        p.Street__c='';
        update p;
        delete p;
         Test.stopTest();
    
    }
}