/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Delete related Event Attendance Detail records when Event is Deleted (Single/Group/Recurring).
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-11-17
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: Apex trigger on Event before delete, to remove related Event Attendance Detail records upon Event Deletion.
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  2012-02-27 - MT - Stop users deleting CRS events
 *  2013-08-21 - MT - Reactivate, ignore last change as events can be deleted.                           
*******************************************************************************************/
trigger TriggerEventBeforeDeleteRemoveAttendeeDetails on Event (before delete) {

//stop users deleting events for CRS Events
/*
**	List<RecordType> crsRT = new List<RecordType>();
**	crsRT = [select Id from RecordType where (DeveloperName = 'Awareness_Raising_Event' or DeveloperName = 'CRS_Individual_Event'
**	                                              or DeveloperName = 'CRS_Home_Support_Event' or DeveloperName = 'CRS_Group_Event' 
**	                                              or DeveloperName = 'CRS_Advocacy_Event') and sObjectType='Event'];
**	                                              
**	        
**	for(Event eve: Trigger.old)
**	    try {
**	
**	        for(RecordType rt: crsRT){
**	            if ((eve.RecordTypeId == rt.Id)
**	            ||(eve.RecordTypeId ==rt.Id)
**	            ||(eve.RecordTypeId ==rt.Id)
**	            ||(eve.RecordTypeId ==rt.Id)
**	            ||(eve.RecordTypeId ==rt.Id))
**	            {
**	                eve.addError ('You cannot delete CRS related Events');
**	            }
**	        }
**	    } catch(Exception ex){
**	        //trigger.old[0].addError('You cannot delete CRS related Events');
**	        //throw ex;
**	        }
**
*/
Set<String> setEventNumbers = new Set<String>();
Set<String> setRecurEventIds = new Set<String>();

//Retrieve all EventNumbers, even for recurring events.
for(Event eve: Trigger.old)
{
    if(!setEventNumbers.contains(eve.EventNumber__c))
         setEventNumbers.add(eve.EventNumber__c);

    //Prepare list for recurring event ActivityId
    if(eve.RecurrenceActivityId !=null && eve.IsRecurrence && !setRecurEventIds.contains(eve.RecurrenceActivityId))
         setRecurEventIds.add(eve.RecurrenceActivityId);         
}

system.debug('#################setEventNumbers##################'+setEventNumbers);

//Find EventNumber for recurring events
for(Event eve: [Select EventNumber__c from Event where RecurrenceActivityId =:setRecurEventIds])
{
        if(!setEventNumbers.contains(eve.EventNumber__c))
         setEventNumbers.add(eve.EventNumber__c);
}

system.debug('#################setEventNumbers##################'+setEventNumbers);
system.debug('#################setEventNumbers.size()##################'+setEventNumbers.size());

//Map of all EventAttendeeDetails for given EventNumbers.
//List<Event_Attendance_Details__c> lstEventAttendDetails = new List<Event_Attendance_Details__c>([Select Id from 
//        Event_Attendance_Details__c where EventNumber__c =:setEventNumbers ]);
List<Event_Attendance_Details__c> lstEventAttendDetails = [Select Id from 
        Event_Attendance_Details__c where EventNumber__c =:setEventNumbers ];        
system.debug('#################lstEventAttendDetails ##################'+lstEventAttendDetails );
system.debug('#################lstEventAttendDetails.size() ##################'+lstEventAttendDetails.size() );

//Delete records.
if(lstEventAttendDetails.size()>0)
{
    Savepoint sp = Database.setSavepoint();
    try
    {
        delete lstEventAttendDetails;
    }catch(Exception ex){system.debug(ex.getMessage());Database.rollback(sp);}
}
}