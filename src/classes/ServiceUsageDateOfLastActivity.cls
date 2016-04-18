/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Retrive Last Activity Date (Task/Event/Event_Attendance) created against SU.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2012-01-12
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *  Copyright (c) Saaspoint 2012 as per Master Services Agreement
 *
 *  Description: Class with static method to retrive/calculate last Activity schedule for SU records. 
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2013-10-30   Ian Smith  Add Start and Stop tests to stop govenor limits being blown                           
*******************************************************************************************/
public class ServiceUsageDateOfLastActivity
{
    //Static method, returns SU Id and Last Activity date for given list of SU Ids.
    public static Map<id,Date> getDateOfLastActivity(Set<Id> SUIds)
    {
        Map<id,date> mapSUActivityDates = new Map<id,date>();
        
        //Retrive Max date of Event for scheduled date is lesser than today
        for(AggregateResult rec: [Select max(ActivityDateTime) MaxDate,WhatId from Event where ActivityDateTime <= Today 
                and WhatId=:SUIds group by WhatId])
        {
            if(rec.get('WhatId')==null) continue;
            
            if(!mapSUActivityDates.containsKey((id)rec.get('WhatId')))
            {
                DateTime dt = (DateTime)rec.get('MaxDate');
                mapSUActivityDates.put((id)rec.get('WhatId'),date.newinstance(dt.Year(), dt.Month(), dt.day()));
            }
        }
        
        //Retrive Max date of EventAttendanceDetail for status is Attended
        for(AggregateResult rec: [Select max(Event_Date_and_Time__c) MaxDate, Service_Usage__c from Event_Attendance_Details__c 
                where Attendance_Status__c='Attended' and Service_Usage__c =:SUIds group by Service_Usage__c])
        {
            if(rec.get('Service_Usage__c')==null) continue;
            
            DateTime dt = (DateTime)rec.get('MaxDate');
            //If SU and Date not added earlier
            if(!mapSUActivityDates.containsKey((id)rec.get('Service_Usage__c')))
            {
                mapSUActivityDates.put((id)rec.get('Service_Usage__c'),date.newinstance(dt.Year(), dt.Month(), dt.day()));
            }
            else
            {
                //Check previous added SU Activity date is lesser than current Max date, if so replace/update new date.
                if(mapSUActivityDates.get((id)rec.get('Service_Usage__c'))<dt)
                     mapSUActivityDates.put((id)rec.get('Service_Usage__c'),date.newinstance(dt.Year(), dt.Month(), dt.day()));
            }
        }        
        
        
       //Retrive Max date of Task for status is completed.
        for(Task rec: [Select ActivityDate, WhatId from Task where Status='Completed' and WhatId=:SUIds and ActivityDate <> null])
        {
            if(rec.WhatId==null) continue;

            if(!mapSUActivityDates.containsKey(rec.WhatId))
            {
                mapSUActivityDates.put(rec.WhatId,rec.ActivityDate);
            }
            else
            {
                if(mapSUActivityDates.get(rec.WhatId)<rec.ActivityDate)
                    mapSUActivityDates.put(rec.WhatId,rec.ActivityDate);
            }
        }
    return mapSUActivityDates;
    }
public testMethod static void testController()
{

    Contact recCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
    insert recCon;        

    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
  insert accRec;
    Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
    insert serv;
  // Start the test.
  test.startTest();

    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    
    insert recSU;

//    Service_Usage__c recSU2 = new Service_Usage__c(Service_Field__c= serv.id,Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    
//    insert recSU2;    
    
//    Service_Usage__c recSU3 = new Service_Usage__c(Service_Field__c= serv.id,Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    
//    insert recSU3;        
  // Stop the test.
  test.stopTest();
      
    Event eveRec = new Event(WhatId=recSU.id,Subject='Test Subject',DurationInMinutes=30,
            ActivityDateTime=System.now()-1,Format__c='Face to Face', In_Out__c='Outgoing',Location_Type_Event__c='Service User Home');
    insert eveRec;
    
    Event eveRec2 = new Event(WhatId=recSU.id,Subject='Test Subject',DurationInMinutes=30,
            ActivityDateTime=System.now()-1,Format__c='Face to Face', In_Out__c='Outgoing',Location_Type_Event__c='Office');
    insert eveRec2;    

    Task tskRec = new Task(WhatId=recSU.id,Subject='Test Subject',Format__c='Face to Face', 
            In_Out__c='Outgoing',Status='Completed',Completion_Date_Task__c=Date.Today(),Staff_Time_Minutes__c=30,
            Volunteer_Time_Minutes__c=30,ActivityDate=System.Today()-1);
    insert tskRec; 
        
    Event_Attendance_Details__c EADRec = new Event_Attendance_Details__c(Service_Usage__c=recSU.id, 
            Event_Date_and_Time__c=System.now()+1,Attendance_Status__c='Attended');  
    insert EADRec; 
    
//        Event_Attendance_Details__c EADRec2 = new Event_Attendance_Details__c(Service_Usage__c=recSU3.id, 
//            Event_Date_and_Time__c=System.now(),Attendance_Status__c='Attended');  
//    insert EADRec2;     
    
    Task tskRec2 = new Task(WhatId=recSU.id,Subject='Test Subject',Format__c='Face to Face', 
            In_Out__c='Outgoing',Status='Completed',Completion_Date_Task__c=Date.Today(),Staff_Time_Minutes__c=30,
            Volunteer_Time_Minutes__c=30,ActivityDate=System.Today()+2);
    insert tskRec2;
    
//    Task tskRec3 = new Task(WhatId=recSU2.id,Subject='Test Subject',Format__c='Face to Face', 
//            In_Out__c='Outgoing',Status='Completed',Completion_Date_Task__c=Date.Today(),Staff_Time_Minutes__c=30,
//            Volunteer_Time_Minutes__c=30,ActivityDate=System.Today());
//    insert tskRec3;      
    
    update eveRec;
    tskRec.WhatId=recSU.id;
    update tskRec;
    
    ServiceUsageDateOfLastActivity.getDateOfLastActivity(new Set<Id>{recSU.id});//,recSU2.id,recSU3.id removed

    //system.debug('########## SU Last Activity ###########'+[Select Date_of_last_Activity__c from Service_Usage__c where Id=:recSU.id ].Date_of_last_Activity__c);
    
  

  }      
}