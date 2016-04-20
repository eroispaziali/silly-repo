@isTest
public class TestBatchGroupEventAttendanceRecal{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Batch APEX Class to re-calculate the Apex Sharing rules for Service Usage records.
 *  Author  : Mike Tinson
 *  Date    : 28-11-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Batch APEX Class to re-calculate the totals for attendees for group events.
 *                  Change-00575
 *
 *                  Test class to test BatchGroupEventAttendanceRecalculation 
 *
 *
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ??
 *                             
*******************************************************************************************/


static testMethod void mainTest(){
    
    User userVol = new User(alias = 'userVol',
        email='vol@testorg.com',
        emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US',
        profileid = [SELECT Id FROM Profile WHERE Name='CRS - One App User'].id,
        username='vol@testorg.com',
        title='Volunteer',
        TimeZoneSidKey='Europe/London',
        Worker_Type__c='Volunteer');
    insert userVol;


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
        RecordTypeId=volRecTypeId, Worker_Type__c ='Volunteer');
    insert volCon;
    
    Service_Usage__c servUsg1 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con1.id,Service_Type__c='Dementia cafe');
    insert servUsg1;
    
    Event eveRec = new Event(WhatId=serv.Id,Subject='TestController',DurationInMinutes=30,
    ActivityDateTime=System.Today().addDays(-7),
    ActivityDate = System.Today() .addDays(-7),
    RecordTypeId=[Select Id from RecordType where 
            SObjectType='Event' and Name = 'CRS Group Event'].id,
    IsRecurrence = false,Format__c='Face to Face', In_Out__c='Outgoing',Location_Type_Event__c='Office');
    insert eveRec;
    Event_Attendance_Details__c eveAttn2 = new Event_Attendance_Details__c(EventNumber__c=[Select EventNumber__c from Event where id=:eveRec.id].EventNumber__c,Contact__c=con1.id,Type__c='Contact', Attendance_Status__c='Attended');
    insert eveAttn2;    
    Event_Attendance_Details__c eveAttn = new Event_Attendance_Details__c(EventNumber__c=[Select EventNumber__c from Event where id=:eveRec.id].EventNumber__c,Contact__c=volCon.id,Type__c='Contact', Attendance_Status__c='Attended');
    insert eveAttn;
    
    Event_Attendance_Details__c eveAttn3 = new Event_Attendance_Details__c(EventNumber__c=[Select EventNumber__c from Event where id=:eveRec.id].EventNumber__c, User__c=userVol.id, Type__c='User', Attendance_Status__c='Attended');
    insert eveAttn3;    

//create query string
    Id GroupRecordid =[Select Id from RecordType where SObjectType='Event' and Name = 'CRS Group Event'].id;
    String qString = 'select id,EventNumber__c, activitydatetime, Number_of_Person_with_Dementia_Attendees__c, Number_of_Carer_Attendees__c, Number_of_Worker_Attendees__c,Number_of_Volunteer_Attendees__c from Event where ';
    qString = qString +' recordtypeid =\'' + GroupRecordid  + '\' and IsRecurrence=false and IsChild=false and ActivityDateTime <= TODAY and ActivityDateTime > LAST_YEAR';
    Test.StartTest();
    BatchGroupEventAttendanceRecalculation  batchRecalc = new BatchGroupEventAttendanceRecalculation ();
    batchRecalc.query =qString ; 
    batchRecalc.email=UserInfo.getUserEmail();
    ID batchprocessid = Database.executeBatch(batchRecalc, 20);
    System.debug('batchprocessid='+batchprocessid) ;
    
    Test.StopTest();


}
}