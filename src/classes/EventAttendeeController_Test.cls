@isTest
public class EventAttendeeController_Test{
/******************************************************************************************
 *  Alzheimer's 
 *  
 *  Purpose : Test Class for EventAttendeeController
 *  Author  : Mike Tinson
 *  Date    : 21-01-2015
 *  Version : 1
 *  Project : 
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  21-01-2015    MT      Moved to separate test class from orignal test routine in EventAttendeeController          
*******************************************************************************************/
static testMethod void testEventAttendeeController(){

    
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
    
    Service_Usage__c servUsg2 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con2.id,Service_Type__c='Dementia cafe');
    insert servUsg2;
        
    Test.StartTest();
    
    
    Event eveRec = new Event(WhatId=serv.Id,Subject='TestController',DurationInMinutes=30,
    ActivityDateTime=System.Today(),
    ActivityDate = System.Today() ,
    RecurrenceEndDateOnly = System.Today().addDays(7) ,
    RecurrenceStartDateTime = System.Today(),
    RecurrenceType = 'RecursEveryWeekday',
    RecurrenceDayofWeekMask = 64,
    IsRecurrence = TRUE,Format__c='Face to Face', In_Out__c='Outgoing',Location_Type_Event__c='Office');
    insert eveRec;
    
    Event_Attendance_Details__c eveAttn = new Event_Attendance_Details__c(EventNumber__c=[Select EventNumber__c from Event where id=:eveRec.id].EventNumber__c,Contact__c=volCon.id,Type__c='Contact');
    insert eveAttn;

    ApexPages.currentPage().getParameters().put('Id', eveRec.id);        
    EventAttendeeController conCls= new EventAttendeeController(new ApexPages.StandardController(eveRec));
    conCls.removeConId=con1.id;
    conCls.AddToList();
    conCls.saveUsersNReturn();

    conCls.RemoveContact();
    conCls.lstAvailableCons[0].isSelected=true;
    conCls.AddToList();
    conCls.saveContactsNReturn();

    eveRec.WhatId=acc.id;
    update eveRec;
    delete eveRec;
    delete con1;
   
}
static testMethod void testEventAttendeeController2(){
    //test single event, contact already added.
    
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
    
    Id conRecTypeId =[Select Id from RecordType where SObjectType='Contact' and DeveloperName = 'Person_with_dementia'].id;
    Id volRecTypeId =[Select Id from RecordType where SObjectType='Contact' and DeveloperName = 'Volunteer'].id;
    
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
    
    Service_Usage__c servUsg2 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con2.id,Service_Type__c='Dementia cafe');
    insert servUsg2;
        
    Test.StartTest();
    
    
    Event eveRec = new Event(WhatId=serv.Id,Subject='TestController',DurationInMinutes=30,
    ActivityDateTime=System.Today().addDays(1),
    ActivityDate = System.Today().addDays(1) ,
    IsRecurrence = FALSE,
    Format__c='Face to Face', 
    In_Out__c='Outgoing',
    Location_Type_Event__c='Office');
    insert eveRec;
    
    Event_Attendance_Details__c eveAttn = new Event_Attendance_Details__c(EventNumber__c=[Select EventNumber__c from Event where id=:eveRec.id].EventNumber__c,Contact__c=Con1.id,Type__c='Contact', Service_usage__c = servUsg1.id, Attendance_Status__c='Attended');
    insert eveAttn;

    //add contact (service user)
    Event_Attendance_Details__c eveAttn2 = new Event_Attendance_Details__c(EventNumber__c=[Select EventNumber__c from Event where id=:eveRec.id].EventNumber__c,Contact__c=volCon.id,Type__c='Contact', Attendance_Status__c='Attended');
    insert eveAttn2;


    ApexPages.currentPage().getParameters().put('Id', eveRec.id);        
    EventAttendeeController conCls= new EventAttendeeController(new ApexPages.StandardController(eveRec));
    
    conCls.strInsertWithStatus='Attended';
    conCls.AddToList();
    conCls.saveContactsNWorkers();
    conCls.saveUsersNServiceUsers();
    conCls.removeConId=con1.id;
    conCls.RemoveContact();
    conCls.lstAvailableCons[0].isSelected=true;
    conCls.AddToList();
    conCls.saveContactsNReturn();
    

    /*
    eveRec.WhatId=acc.id;
    update eveRec;
    delete eveRec;
    delete con1;
    */

}

}