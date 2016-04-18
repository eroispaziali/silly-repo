public with sharing class EventTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Event Trigger.
 *  Author  : Mike Tinson
 *  Date    : 13-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the Event Record.
 *               
 *  Modification History
 *  Date            Who         Description 
 *  3/2/2015        MT          Incorporate TriggerEventBeforeUpsertLocationFiller, 
 *                                  TriggerEventAfterInsertUpdateCreateAttendeeDetails,
 *                                  TriggerEventBeforeDeleteRemoveAttendeeDetails 
 *                                  and TriggerEventAfterUpsertSUDateOfLastActivity
 *                                  into this trigger handler.
 * 
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public EventTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(Event[] NewEvent){
        LocationFiller(NewEvent);
    
    }
    public void OnAfterInsert(Event[] NewEvents, Map<ID, Event> EventMap){
        System.debug('****** EventTriggerHandler.OnAfterInsert  ******');
        AfterInsertUpdateCreateAttendeeDetails(false, NewEvents, NewEvents, EventMap, EventMap);
        UpsertSUDateOfLastActivity(false, NewEvents, NewEvents);
        UpdateLastTransactionDate(NewEvents);
    }   
    public void OnBeforeUpdate(Event[] oldEvent, Event[] updatedEvent, Map<ID, Event> oldEventMap, Map<ID, Event> EventMap){
        System.debug('****** EventTriggerHandler.OnBeforeUpdate  ******');
        LocationFiller(updatedEvent);
    }     
    public void OnAfterUpdate(Event[] oldEvent, Event[] updatedEvent,Map<ID, Event> oldEventMap, Map<ID, Event> newEventMap){
        System.debug('****** EventTriggerHandler.OnAfterUpdate  ******');
        AfterInsertUpdateCreateAttendeeDetails(true, oldEvent, updatedEvent, oldEventMap, newEventMap);
        UpsertSUDateOfLastActivity(true, oldEvent, updatedEvent);
        UpdateLastTransactionDate(updatedEvent);
    }
    public void OnBeforeDelete(Event[] oldEvent, Map<ID, Event> EventMap){
        System.debug('****** EventTriggerHandler.OnBeforeDelete  ******');
        BeforeDeleteRemoveAttendeeDetails(oldEvent);
        
    }


    public void OnAfterDelete(Event[] oldEvent, Map<ID, Event> EventMap){
    
        System.debug('****** EventTriggerHandler.OnAfterUpdate  ******');
        
        UpdateLastTransactionDate(oldEvent);
    }
        
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

public void UpdateLastTransactionDate(Event[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Event df: updatedSUs){
        SUIds.add(df.Id);
    }
    System.debug('****** SUIds.Size ******' + SUIds.Size());

    if(SUIds.isEmpty() == false){
      
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
      LastTransactionDateLookup handler = new LastTransactionDateLookup();
      handler.UpdateLastTransactionDate(SUIds[0], dtLastTransactionDate); 
      
        }
    
    }
/*********************************************************
*   Was TriggerEventBeforeUpsertLocationFiller
*   Copy Address details from Service/Activity or Contact to Event for created against Service Usage.
*    If user has not filled address details for Event created against Service Usage, Trigger will populate depending value from
*    Location Type, if 'Office' picks from Service, if 'Service User Home' then from Primary Contact.
*    Also contatenate all Address fields and populate Event Location file, to show on Calender. 
*********************************************************/
public void LocationFiller( List<Event> UpdatedEvents){
    system.debug('###########LocationFiller##############');
    //get the SU prefixKey to check Event is scheduled against SU.
    string SUKeyPrefix = Schema.getGlobalDescribe().get('Service_Usage__c').getDescribe().getKeyPrefix();
    Set<Id> setSUIds = new Set<Id>();
    
    //Extract all SU Ids from Events
    for (Event e : UpdatedEvents) {
    
        //Incase Event What Id is null then skip and continue with next Event record.
        if(e.whatId==null) continue;
        
        string strSUId = String.valueOf(e.whatId);
        
        if(!setSUIds.contains(strSUId) && strSUId.startsWith(SUKeyPrefix))
        {
            system.debug('########### Is related to SU and Meeting Type#######');
            setSUIds.add(strSUId);
        }
    }
    
    system.debug('###########setSUIds##############'+setSUIds);
    //If any of the Event(s) is scheduled against SU then SOQL Service and Primary User address.
    if(setSUIds.size()>0)
    {
        //Retrive Service/Activity and Primary User Address.
        Map<Id,Service_Usage__c> mapSURecs = new Map<Id,Service_Usage__c>([select Id, 
            Service_Field__r.Operated_By__r.BillingStreet, Service_Field__r.Operated_By__r.BillingCity,
            Service_Field__r.Operated_By__r.BillingPostalCode,Service_Field__r.Operated_By__r.BillingState,
            Primary_Service_User__r.MailingStreet,Primary_Service_User__r.MailingCity,
            Primary_Service_User__r.MailingState,Primary_Service_User__r.MailingPostalcode
            from Service_Usage__c where Id=:setSUIds]);
            
            //Iterate through all Event(s) records to set/populate address from Service/Contact on Event record.
            for (Event e : UpdatedEvents) {
                
                try
                {
                    //If Event meeting is at Office or User Home and No field is pre-filled.
                    if(mapSURecs.containsKey(e.WhatId) && e.Location_Type_Event__c!=null && 
                        (e.Location_Type_Event__c.equalsIgnoreCase('Office')
                         || e.Location_Type_Event__c.equalsIgnoreCase('Service User Home')) &&
                         (e.Street__c == null && e.City__c == null && e.County__c == null && e.Postcode__c ==null)
                         )
                    {
                        system.debug('########### SU found and in Address Population ##########');
                        Service_Usage__c recSU = mapSURecs.get(e.WhatId);
                        if(e.Location_Type_Event__c.equalsIgnoreCase('Office'))
                        {
                            e.Street__c = recSU.Service_Field__r.Operated_By__r.BillingStreet;
                            e.City__c = recSU.Service_Field__r.Operated_By__r.BillingCity;
                            e.County__c = recSU.Service_Field__r.Operated_By__r.BillingState;
                            e.Postcode__c = recSU.Service_Field__r.Operated_By__r.BillingPostalCode;
                        }
                        
                        if(e.Location_Type_Event__c.equalsIgnoreCase('Service User Home'))
                        {
                            e.Street__c = recSU.Primary_Service_User__r.MailingStreet;
                            e.City__c = recSU.Primary_Service_User__r.MailingCity;
                            e.County__c = recSU.Primary_Service_User__r.MailingState;
                            e.Postcode__c = recSU.Primary_Service_User__r.MailingPostalCode;
                        
                        }
    
                        //Finally contatenate all address field to populate Location field.
                        e.Location=(e.Street__c!=null?e.Street__c :'')+ (e.City__c!=null?', '+e.City__c :'')+ 
                            (e.County__c!=null?', '+e.County__c :'')+(e.Postcode__c!=null?', '+e.Postcode__c:'');
                    }
                }catch(Exception ex){e.addError('Error Updating addresss fields: '+ex.getMessage()+'. Contact The CRS Helpdesk.');}
    
            }
    }
    system.debug('########### LocationFiller Finished #############');  
    
}
/*********************************************************
*   Was TriggerEventBeforeDeleteRemoveAttendeeDetails
*   Delete related Event Attendance Detail records when Event is Deleted (Single/Group/Recurring).
*   Remove related Event Attendance Detail records upon Event Deletion.
*********************************************************/  
public void BeforeDeleteRemoveAttendeeDetails(list<Event>  oldEvent ){
    system.debug('***********BeforeDeleteRemoveAttendeeDetails ***********');
    Set<String> setEventNumbers = new Set<String>();
    Set<String> setRecurEventIds = new Set<String>();
    
    //Retrieve all EventNumbers, even for recurring events.
    for(Event eve: oldEvent)
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
/*********************************************************
*   Was TriggerEventAfterUpsertSUDateOfLastActivity
*   Update/Align Service Usage 'Date of Last Activity' field.
*   For Events scheduled for Service Usage, will update 'Date of Last Activity' field on SU.
*********************************************************/
public void UpsertSUDateOfLastActivity(boolean bIsUpdate, List<Event> oldEvent, List<Event> newEvent ){
    //get the SU prefixKey to check Event is scheduled against SU.
    string SUKeyPrefix = Schema.getGlobalDescribe().get('Service_Usage__c').getDescribe().getKeyPrefix();
    Set<Id> setSUIds = new Set<Id>();
    
    //Extract all SU Ids from Events
    //For Update Trigger
    if(bIsUpdate)
    {
        for (Event e : oldEvent) {
            
            //If Event's WhatId is null then continue with another Event record.
            if(e.whatId==null) continue;
            
            string strSUId = String.valueOf(e.whatId);
            
            //If Event is scheduled against SU then add SU Id to List.
            if(!setSUIds.contains(strSUId) && strSUId.startsWith(SUKeyPrefix))
            {
                system.debug('########### Is related to SU and Meeting Type#######');
                setSUIds.add(strSUId);
            }
        }
    }
    
    //For Both Insert/Update to Align update Old and new SU record with appropriate Last Activity date.
    for (Event e : newEvent) {
        
        //If Event's WhatId is null then continue with another Event record.
        if(e.whatId==null) continue;
        
        string strSUId = String.valueOf(e.whatId);
        
        //If Event is scheduled against SU then add SU Id to List.
        if(!setSUIds.contains(strSUId) && strSUId.startsWith(SUKeyPrefix))// && e.Format__c!=null) && e.Format__c.equalsIgnoreCase('Meeting'))
        {
            system.debug('########### Is related to SU and Meeting Type#######');
            setSUIds.add(strSUId);
        }
    }
    
    system.debug('###########setSUIds##############'+setSUIds);
    
    //If any SU Ids are added to List; means they need to be updated with appropriate Last Activity dates
    if(setSUIds.size()>0)
    {
        //Invoke Static method which returns Last Activity date for given list of SU Ids.
        Map<Id,Date> mapSUActivityDates = ServiceUsageDateOfLastActivity.getDateOfLastActivity(setSUIds);
        
        List<Service_Usage__c> lstSUToUpdate = new List<Service_Usage__c>();
        
        //If static method returned with SU dates to update.
        if(mapSUActivityDates!=null)
        {
            //Create List of SU records to update with Last Activity Dates.
            for(Id SUId:mapSUActivityDates.keySet())
            {
                lstSUToUpdate.add(new Service_Usage__c(Id=SUId,Date_of_last_Activity__c=mapSUActivityDates.get(SUId)));
            }
            
          try
          {
            //Make DML.
            Database.SaveResult[] lsr = Database.Update(lstSUToUpdate);
            
            //Iterate through each Updated DML record and find for any failurs, if so then add Error message.
            for(Database.SaveResult sr:lsr)
            {
                //If Update was unsuccessful.
                if(!sr.isSuccess())
                {
                    for (Event e : newEvent) 
                    {
                        //Retrieve the Event Id to add Error message.
                        if(e.WhatId==sr.getId())
                        {
                            e.addError('Error updating Service Usage Date of Last Activity: '+sr.getErrors()+'. Contact The CRS Helpdesk.');
                        }
                    }
                }    
            }          
          }catch(Exception ex){system.debug('TriggerEventAfterUpsertSUDateOfLastActivity: Runtime Exception');}
        }
    }   
        
    }
/*********************************************************
*   Was TriggerEventAfterInsertUpdateCreateAttendeeDetails
*   Align Event Attendance Detail Object for added Event Attendees.
*       To allign EventAttendanceDetails records
*       as per Event Invitees. Only when Event is related to Services__c (GuideBook).
*********************************************************/
public void AfterInsertUpdateCreateAttendeeDetails(boolean bIsUpdate, List<Event> oldEvent, List<Event> newEvent, Map<ID, Event> oldEventMap, Map<ID, Event> newEventMap){
//call in separate class as the user does not have access to delete records 
EventAttendanceAlignWithEvent EaAlignWithEvent= new EventAttendanceAlignWithEvent();
try{
    EaAlignWithEvent.AfterInsertUpdateCreateAttendeeDetails(bIsUpdate, oldEvent, newEvent, oldEventMap, newEventMap);
}
catch(Exception ex){System.debug(ex.getMessage());throw ex;}
   
}
}