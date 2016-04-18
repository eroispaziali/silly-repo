@isTest
public with sharing class ServiceTriggerHandler_Test{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for ServiceTriggerHandler.
 *  Author  : Mike Tinson
 *  Date    : 14-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class to test ServiceTriggerHandlertrigger on the User object. 
 *               
 *  Modification History
 *
 *  Date            Who     Description 
 *  dd-mm-yyyy      ??      ??
 *                             

*******************************************************************************************/

static testMethod void testInsert(){
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
     Service_Types__c st=new Service_Types__c(Service_Description__c='Test Description',Service_Type__c='Advocacy');
    insert st;
    Services__c service = new Services__c(Display_on_public_website__c=True,Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false,RecordTypeId=[Select Id from RecordType where SObjectType='Services__c' and DeveloperName ='Internal'].Id);//Name='testControllerService');
       
    Test.startTest();
    
    List<Services__c> lisServ=new List<Services__c>();  
    Map<Id,Services__c> mapServ=new Map<Id,Services__c>();  
    
    insert service;
    lisServ.add(service);
    mapServ.put(service.id,service); 
    service=[Select Change_Needs_Approval__c,Approval_Stage__c From Services__c where id=:service.id];
    
   
    service.name='Midlands Central Advocacy Updated';
    service.Related_Service_Description__c=st.id;
    update service;
    ServicesTriggerHandler std=new ServicesTriggerHandler(Trigger.isExecuting, Trigger.size);
    std.OnBeforeServiceInsertAndUpdate(lisServ,mapServ);
    std.OnAfterUpdate(lisServ,lisServ,mapServ);
    delete service;
    
    Test.stopTest(); 

    } 
     static testMethod void validateAddressCreation() {
   
        
        Account acc1 = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
        insert acc1;
         Account acc2 = new Account(Name='Test External',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id);
        insert acc2;
              
        System.debug('Account: [' + acc1.AccountNumber+ '] has inserted into system.');
        Services__c s = new Services__c(Name='Midlands Central Advocacy',service_street__c= 'test the street name long ass string first more than 80 character for testing the', Locality__c=acc1.id,Service_Type__c='Advocacy', National_Service__c=false);
        insert s;
        System.debug('Account: [' + acc2.AccountNumber+ '] has inserted into system.');
        Services__c s1 = new Services__c(Name='Test External Service',service_postcode__c= 'ig1 3lq', Locality__c=acc1.id,Service_Type__c='Advocacy', National_Service__c=false);
        insert s1;
            
        Test.startTest();
        s = [SELECT service_street__c,Street_Line_1__c, Street_Line_2__c,Street_Line_3__c,Street_Line_4__c  FROM Services__c WHERE Id =:s.Id Limit 1];
       
        System.assertEquals(s.Street_Line_1__c,'test the street name long ass string first more than 80 character for testing th');
        System.assertEquals(s.Street_Line_2__c,'e');
        System.assertEquals(s.Street_Line_3__c,null);
        System.assertEquals(s.Street_Line_4__c,null);
         
        s.service_street__c = 'test with three\nline address this\nis street address\nthis is street address 3';
        update s;                        
        s.service_street__c = 'test with two\nline address this\nis shipping address on when second line is overshot the length by 80 or more characters on the third line of the address\nfourth line';
        update s;
        s.service_street__c = 'test with two\nis shipping address on when second line is overshot the length by 80 or more characters on the third line of the addressline address this\n\nfourth line';
        update s;
        s.service_street__c = 'test the street name less than 80 character\n111111111122222222223333333333444444444455555555556666666666777777777788888888889\nthird line\nfourth line';
        update s;
        s.service_street__c ='test the street name less than 80 character\nsecond line\nthird line 11111111112222222222333333333344444444445555555555666666666677777777778888888888\nfourth line';
        update s;
        s.service_street__c ='test the street name less than 80 character\nsecond line\nthird line\nfourth line 1111111111222222222233333333334444444444555555555566666666667777';
        update s;
        s.service_street__c ='test the street name less than 80 character\nsecond line\nthird line\nfourth line' ;
        update s;
              
        s.service_street__c='';
        update s;
        s1.service_postcode__c='Sm7 1PN';
        update s1;
        Test.stopTest(); 
        delete s;
    }
}