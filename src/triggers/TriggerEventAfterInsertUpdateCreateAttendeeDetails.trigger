/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Align Event Attendance Detail Object for added Event Attendees.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-11-16
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: Apex trigger on Event After insert and after Update, to allign EventAttendanceDetails records
 *        as per Event Invitees. Only when Event is related to Services__c (GuideBook).
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2012-02-07  MT  removed secondary service user (Secondary_Service_User__c) 
 *  2013-03-28  MT  error selecting events on EventNumber__c change sql to use in rather than set
 *  2013-08-16  MT  stop duplicate records being created.    (Change 338)     
 *  2013-08022  MT  still getting errors in full sandbox using eventnumber_c on Event object SoQL return nothing.                  
 *                  Change to use collection of event ids.
*******************************************************************************************/
trigger TriggerEventAfterInsertUpdateCreateAttendeeDetails on Event (after insert, after update) {

Set<String> setEventNumbers = new Set<String>();
Set<id> setEventIds = new Set<id>();
Set<id> setServicesId = new Set<id>();
Set<String> setEveNumToDelDetailsForServiceChange = new Set<String>();
Set<String> setEveNumToDelDetailsForNonService = new Set<String>();

for(Event eve: Trigger.new)
{
    try
    {
    //Event should be related to Service only.
    if(!setEventIds.contains(eve.id) && eve.WhatId!=null &&
        string.valueOf(eve.WhatId).startsWith(Schema.SObjectType.Services__c.getKeyPrefix()))
        {
        //ignore event for a reoccuring event-Change 338
        if (!eve.IsRecurrence){
        	if (!setEventNumbers.contains(eve.EventNumber__c)) {
 		     	setEventNumbers.add(eve.EventNumber__c);
        	}
 		     setEventIds.add(eve.Id);
	         setServicesId.add(eve.WhatId);//MT 20130328
	         system.debug('>>>>>>>>>>>Add Event Number to set ' + eve.EventNumber__c + ' serviceID to set ' + eve.WhatId );
        }
    }
    

    //Check if user has either changed the Service or related to other Object than Service. 
    if(Trigger.isUpdate && eve.WhatId != Trigger.oldMap.get(eve.id).WhatId)
    {
        //If Event was previously related to Service
        if(string.valueOf(Trigger.oldMap.get(eve.id).WhatId).startsWith(Schema.SObjectType.Services__c.getKeyPrefix()))
        {
            //ignore event for a reoccuring event-Change 338
            if (!eve.IsRecurrence){
	            //Event was previously related to Service.
	            if(!setEventIds.contains(eve.id))
	            {
		         if (!setEventNumbers.contains(eve.EventNumber__c)) {
		 		  	setEventNumbers.add(eve.EventNumber__c);
		         }
	             setEventIds.add(eve.Id);
	            }   
	            
	            //If current event is related to Service.
	            if(string.valueOf(eve.WhatId).startsWith(Schema.SObjectType.Services__c.getKeyPrefix()))
	            {            
	                setEveNumToDelDetailsForServiceChange.add(eve.EventNumber__c);
	            }
	            else
	            {
	                setEveNumToDelDetailsForNonService.add(eve.EventNumber__c); 
	            }
            }
         }   
    }     
    }catch(Exception ex){eve.addError(ex.getMessage()+'. Contact The CRS Helpdesk.');}
    system.debug('#############event.id###################'+eve.id);     
}

//Map of all EventAttendee for given EventNumber.
Map<Id,EventAttendee> mapEventAttends = new Map<Id,EventAttendee>([Select AttendeeId, EventId, Id,Event.WhatId,
        Event.EventNumber__c, event.ActivityDateTime,Event.Subject from EventAttendee where Event.id =:setEventids]);


set<Id> setServiceIds = new set<Id>();
set<Id> setContactIds = new set<Id>();
set<Id> setEventAttendsId = new set<Id>();

for(EventAttendee rec: mapEventAttends.values())
{
    try{
    setServiceIds.add(rec.Event.WhatId);
	//get a list of existing attendees
	setEventAttendsId.add(rec.AttendeeId);
	system.debug('>>>>>>>>>>>>>>>>>>AttendeeId :' + rec.AttendeeId);
    //Look for only Contact Attendees
    if(string.valueOf(rec.AttendeeId).startsWith(Schema.SObjectType.Contact.getKeyPrefix()))
        setContactIds.add(rec.AttendeeId);

    }catch(Exception ex){rec.addError(ex.getMessage()+'. Contact The CRS Helpdesk.');}    
}

Map<string,Service_Usage__c> mapServUsages = new Map<string,Service_Usage__c>();

//Get the Service Usage records, user is having access to.          
RetrieveServiceUsagesWithSharing clsSURecs = new RetrieveServiceUsagesWithSharing();

//Loop through Service Usage records under user context, for Service and Contact.
for(Service_Usage__c rec:clsSURecs.getSURecordsOfServciesNContacts(setContactIds,setServiceIds))
{
    try
    {
    //If Event is related to Service and invitee Contact is found as Primary Service User in Servic Usage.
    if(rec.Primary_Service_User__c!=null && !mapServUsages.containsKey(rec.Primary_Service_User__c+''+rec.Service_Field__c))
        {
            mapServUsages.put(rec.Primary_Service_User__c+''+rec.Service_Field__c,rec);
        }

    }catch(Exception ex){rec.addError(ex.getMessage()+'. Contact The CRS Helpdesk.');}    
}

Set<Id> setAttendDetailsToDel = new Set<Id>();
Map<Id,Event_Attendance_Details__c> mapEventAttendDetails = new Map<Id,Event_Attendance_Details__c>();

Set<string> setAttendDetailsAddedManually = new Set<String>();

//Create Map of EventAttendeeDetails with EventAttendeeId as key.
//MT 20130328 CHANGE way EventAttendanceDetails are access to avoid error 
//MT 20130816 Part 1 - for service usages
String sqlStr = 'Select Service_Usage__c,EventAttendeeId__c, Contact__c,EventNumber__c,EventId__c ';
sqlStr+= 'from Event_Attendance_Details__c where EventNumber__c IN ';
sqlStr+= ' :setEventNumbers ';
sqlStr+= ' AND Service_Usage__c IN :setServicesId ';
system.debug('#############sqlStr##############'+sqlStr);
List<Event_Attendance_Details__c> mtest = Database.query(sqlStr);
system.debug('#############sqlStr##############'+mtest.size());
//for(Event_Attendance_Details__c rec:[Select Service_Usage__c,EventAttendeeId__c, Contact__c,EventNumber__c,EventId__c
//        from Event_Attendance_Details__c where EventNumber__c =:setEventNumbers  ])
for (Event_Attendance_Details__c rec: mtest)
{
        //Attendees added via standard SFDC, will have Event Id
        if(rec.EventId__c != null)
            mapEventAttendDetails.put(rec.EventAttendeeId__c,rec);
        else
        {
           //For contacts added manually through VF. will not have Event Id populated.
           if(rec.Contact__c!=null)
                setAttendDetailsAddedManually.add(rec.Contact__c+rec.EventNumber__c);
        }    
}

system.debug('#############mapEventAttendDetails 1##############'+mapEventAttendDetails);
system.debug('#############setAttendDetailsAddedManually 1##############'+setAttendDetailsAddedManually);

//Create Map of EventAttendeeDetails with EventAttendeeId as key.
//MT 20130328 CHANGE way EventAttendanceDetails are access to avoid error 
//MT 20130816 Part 2 - for users
sqlStr = 'Select Service_Usage__c,EventAttendeeId__c, Contact__c,EventNumber__c,EventId__c ';
sqlStr+= 'from Event_Attendance_Details__c where EventNumber__c IN ';
sqlStr+= ' :setEventNumbers ';
sqlStr+= ' AND ((User__c IN :setEventAttendsId) ';
sqlStr+= ' OR (Contact__c IN :setEventAttendsId))';
system.debug('#############sqlStr##############'+sqlStr);
List<Event_Attendance_Details__c> mtest3 = Database.query(sqlStr);
system.debug('#############sqlStr##############'+mtest3.size());
//for(Event_Attendance_Details__c rec:[Select Service_Usage__c,EventAttendeeId__c, Contact__c,EventNumber__c,EventId__c
//        from Event_Attendance_Details__c where EventNumber__c =:setEventNumbers  ])
for (Event_Attendance_Details__c rec: mtest3)
{
        //Attendees added via standard SFDC, will have Event Id
        if(rec.EventId__c != null)
            mapEventAttendDetails.put(rec.EventAttendeeId__c,rec);
        else
        {
           //For contacts added manually through VF. will not have Event Id populated.
           if(rec.Contact__c!=null)
                setAttendDetailsAddedManually.add(rec.Contact__c+rec.EventNumber__c);
        }    
}

system.debug('#############mapEventAttendDetails 2##############'+mapEventAttendDetails);
system.debug('#############setAttendDetailsAddedManually 2##############'+setAttendDetailsAddedManually);


//Deleting EventAttendeeDetails if any invitee is removed from event.
for(Event_Attendance_Details__c rec: mapEventAttendDetails.Values())
{
    //If AttendeeId from Details is not found in latest EventAttendee then mark it for deletion.
    if(rec.EventAttendeeId__c!=null && !mapEventAttends.containsKey(rec.EventAttendeeId__c))
        setAttendDetailsToDel.add(rec.id);
}

//Delete old Details records of Contacts which were manually added.
//when user has changed related service or associated to object other than service.
//MT 20130328 CHANGE way EventAttendanceDetails are access to avoid error 
sqlStr = 'Select Id from Event_Attendance_Details__c where ';
sqlStr +=' (EventNumber__c=:setEveNumToDelDetailsForServiceChange and Service_Usage__c IN :setServicesId and EventAttendeeId__c = null and Contact__c != null) ';
sqlStr +=' or (EventNumber__c=:setEveNumToDelDetailsForNonService and Service_Usage__c IN :setServicesId)';
system.debug('#############sqlStr##############'+sqlStr);
List<Event_Attendance_Details__c> mtest2 = Database.query(sqlStr);
system.debug('#############sqlStr##############'+mtest2.size());
//for(Event_Attendance_Details__c rec: [Select Id from Event_Attendance_Details__c where 
//    (EventNumber__c=:setEveNumToDelDetailsForServiceChange and EventAttendeeId__c = null and Contact__c != null)
//    or EventNumber__c=:setEveNumToDelDetailsForNonService])
for (Event_Attendance_Details__c rec: mtest2)
{
    setAttendDetailsToDel.add(rec.id);
}

system.debug('#############setAttendDetailsToDel##############'+setAttendDetailsToDel);

List<Event_Attendance_Details__c> lstEventAttndDetailsToUpsert= new List<Event_Attendance_Details__c>();

//Creating record in Details for new invitees.
for(Id eveAttId: mapEventAttends.keySet())
{
    EventAttendee eveAttRec = mapEventAttends.get(eveAttId);

    boolean isContactAttendee = string.valueOf(eveAttRec.AttendeeId).startsWith(Schema.SObjectType.Contact.getKeyPrefix());
    boolean isUserAttendee = string.valueOf(eveAttRec.AttendeeId).startsWith(Schema.SObjectType.User.getKeyPrefix());

    try{
    //Create Detail record if not found.
    if(!mapEventAttendDetails.containsKey(eveAttId) && !setAttendDetailsAddedManually.contains(eveAttRec.AttendeeId+eveAttRec.Event.EventNumber__c))
    {
    	system.debug('>>>>>>>>>>>>>>>>>>Create Detail record if not found.   ' + eveAttId );
    	system.debug('>>>>>>>>>>>>>>>>>>setAttendDetailsAddedManually search.' + eveAttRec.AttendeeId+eveAttRec.Event.EventNumber__c);
        lstEventAttndDetailsToUpsert.add(new Event_Attendance_Details__c(EventAttendeeId__c=eveAttId,
            EventNumber__c=eveAttRec.Event.EventNumber__c,
            Contact__c=((isContactAttendee)?eveAttRec.AttendeeId:null),
            EventId__c=eveAttRec.EventId,
            Event_Date_And_Time__c=eveAttRec.event.ActivityDateTime,
            Service_Usage__c=(mapServUsages.containsKey(eveAttRec.AttendeeId+''+eveAttRec.Event.WhatId)?
                mapServUsages.get(eveAttRec.AttendeeId+''+eveAttRec.Event.WhatId).Id:null),
            Type__c=((isContactAttendee)?'Contact':(isUserAttendee)?'User':''),
            User__c=((isUserAttendee)?eveAttRec.AttendeeId:null),
            Event_Subject__c=eveAttRec.Event.Subject));

    }
    else //Update Details with Service_Usage (Contact) when user has changed the Event Related Service.
    {
       Event_Attendance_Details__c tmpEAD = (mapEventAttendDetails.containsKey(eveAttId)?mapEventAttendDetails.get(eveAttId):null);

        if(setEveNumToDelDetailsForServiceChange.contains(eveAttRec.Event.EventNumber__c) && isContactAttendee)
        {
            //Event_Attendance_Details__c tmpEAD = (mapEventAttendDetails.containsKey(eveAttId)?mapEventAttendDetails.get(eveAttId):null);

            //Update SU for only contacts added via Salesforce
            if(tmpEAD!=null && tmpEAD.EventAttendeeId__c!=null)
            {
                tmpEAD.Service_Usage__c=(mapServUsages.containsKey(eveAttRec.AttendeeId+''+eveAttRec.Event.WhatId)?
                mapServUsages.get(eveAttRec.AttendeeId+''+eveAttRec.Event.WhatId).Id:null);
                //lstEventAttndDetailsToUpsert.add(tmpEAD);
            }
        }
        
        //update Detail with Event latest Date time and Subject.
        if(tmpEAD!=null)
        {
            tmpEAD.Event_Date_And_Time__c = eveAttRec.Event.ActivityDateTime;
            tmpEAD.Event_Subject__c=eveAttRec.Event.Subject;
            lstEventAttndDetailsToUpsert.add(tmpEAD);
        }   
    }
    }catch(Exception ex){system.debug(ex.getMessage());}
}

system.debug('#############lstEventAttndDetailsToUpsert##############'+lstEventAttndDetailsToUpsert);

//If any Update fail then roll back all changes.
Savepoint sp = Database.setSavepoint();

//Upsert Details for new invitees
if(lstEventAttndDetailsToUpsert.size()>0)
{
    try{
        upsert lstEventAttndDetailsToUpsert;
    }catch(Exception ex){System.debug(ex.getMessage());Database.rollback(sp);throw ex;}


}

//Delete Details for removed invitees.
if(setAttendDetailsToDel.size()>0)
{
    List<Event_Attendance_Details__c> lstDetailsToDel = new List<Event_Attendance_Details__c>();
    for(Id delId:setAttendDetailsToDel)
    {
        lstDetailsToDel.add(new Event_Attendance_Details__c(id=delId));
    }

    try{
        delete lstDetailsToDel;
    }catch(Exception ex){System.debug(ex.getMessage());Database.rollback(sp);throw ex;}    
}
}