/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EventTriggerHandler_Test {

    static testMethod void myUnitTest() {
	Account acc = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where 
            SObjectType='Account' and Name like 'Internal%'].id);
    insert acc;
    
    Services__c serv = new Services__c(Locality__c=acc.id,Name='testControllerService',Service_Type__c='Dementia cafe');
    insert serv;    
    
    //create look up used by trigger on Service Usage
    RegionAreaLocalityMap__c RALMap = new RegionAreaLocalityMap__c();
    RALMap.RegionAreaLocalityName__c='Locality Management - Midlands Central';
    RALMap.RegionAreaLocalityNameNew__c = 'Locality Management - Birmingham, Solihull, Coventry & Warks';
    insert RALMap;
    
    Id conRecTypeId =[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id;
    Id volRecTypeId =[Select Id from RecordType where SObjectType='Contact' and name like 'Volunteer%'].id;
    
    Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=conRecTypeId);
    insert con1;
    
    Contact con2 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test2',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=conRecTypeId);
    insert con2;
    Contact volCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='Volunteer1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=volRecTypeId, Worker_Type__c='Volunteer');
    insert volCon;
    
    Service_Usage__c servUsg1 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con1.id,Service_Type__c='Dementia cafe');
    insert servUsg1;
    
    //Service_Usage__c servUsg2 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con2.id,Service_Type__c='Dementia cafe');
    //insert servUsg2;
        
    Test.StartTest();    	
    Event eveRec1 = new Event(WhatId=serv.Id,Subject='TestInsert',DurationInMinutes=30,
    ActivityDateTime=System.Today(),
    ActivityDate = System.Today() ,
    RecurrenceEndDateOnly = System.Today().addDays(7) ,
    RecurrenceStartDateTime = System.Today(),
    RecurrenceType = 'RecursEveryWeekday',
    RecurrenceDayofWeekMask = 64,
    IsRecurrence = TRUE,Format__c='Face to Face', In_Out__c='Outgoing',Location_Type_Event__c='Office');
    insert eveRec1;
    
    eveRec1.Subject='TestUpdated.';	
    
    update eveRec1;
    
    delete eveRec1;
    
    //repeat with a non-recurring event.
    Event eveRec2 = new Event(WhatId=serv.Id,Subject='TestInsert2',DurationInMinutes=30,
    ActivityDateTime=System.Today(),
    ActivityDate = System.Today() ,
    IsRecurrence = False,Format__c='Face to Face', In_Out__c='Outgoing',Location_Type_Event__c='Service User Home');
    insert eveRec2;
    eveRec2.Subject='TestUpdated.';	
    eveRec2.ActivityDateTime=System.Today().AddDays(-1);
    eveRec2.ActivityDate = System.Today().AddDays(-1);
    update eveRec2;
    }
	static testMethod void myUnitTest2() {   
	//test event trigger handler directly
	EventTriggerHandler etHandler = new EventTriggerHandler(false,0);
	if (!etHandler.IsTriggerContext) { system.debug('not running in trigger context');
									  }	
		
	}
	
}