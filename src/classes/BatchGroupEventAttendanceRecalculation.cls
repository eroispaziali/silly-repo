global class BatchGroupEventAttendanceRecalculation implements Database.Batchable<sObject>{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Batch APEX Class to re-calculate the Apex Sharing rules for Service Usage records.
 *  Author  : Mike Tinson
 *  Date    : 26-11-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Batch APEX Class to re-calculate the totals for attendees for group events.
 *                  Change-00575
 *
 *                  Called via the Execute Anonymous window. 
 *                  Id GroupEventId = [select id from Recordtype where SobjectType='CRS Group Event'].id;
 *                  BatchGroupEventAttendanceRecalculation  batchRecalc = new BatchGroupEventAttendanceRecalculation ();
 *                  batchRecalc.query = 'select id,EventNumber__c, activitydatetime, Number_of_Person_with_Dementia_Attendees__c, Number_of_Carer_Attendees__c, Number_of_Worker_Attendees__c,Number_of_Volunteer_Attendees__c from Event where recordtypeid =\'add record type id here\' and IsRecurrence=false and IsChild=false and ActivityDateTime <= TODAY and ActivityDateTime > LAST_YEAR';
 *                  batchRecalc.email=UserInfo.getUserEmail();
 *                  ID batchprocessid = Database.executeBatch(batchRecalc, 20);
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ??
 *                             
*******************************************************************************************/


Public String query {get;set;}
Public String email{get;set;}


global Database.querylocator start(Database.BatchableContext BC){
    System.debug('################query##############' + query);
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){
   List<Event_Attendance_Details__c> ead = new List<Event_Attendance_Details__c>();

   List<Event> groupEvents = new List<Event>();
   List<AttendeeClass> attendeeClsList = new List<AttendeeClass>();
   List<String> lstEventNumber = new List<String>();
   Map<String, AttendeeClass > evMap = new Map<String, AttendeeClass >();

   if (scope.size()>0) {
       for(sObject s : scope){
            //get related objects 
            Event eveTmp = (Event)s;
            AttendeeClass cls = new AttendeeClass();
            //store old counters of attendees
            cls.OldNumber_of_PWD_Attendees = eveTmp.Number_of_Person_with_Dementia_Attendees__c;
            cls.OldNumber_of_Carer_Attendees=eveTmp.Number_of_Carer_Attendees__c;
            cls.OldNumber_of_Volunteer_Attendees=eveTmp.Number_of_Volunteer_Attendees__c;
            cls.OldNumber_of_Worker_Attendees=eveTmp.Number_of_Worker_Attendees__c;
            //zero the counters
            eveTmp.Number_of_Person_with_Dementia_Attendees__c=0;
            eveTmp.Number_of_Carer_Attendees__c=0;
            eveTmp.Number_of_Worker_Attendees__c=0;
            eveTmp.Number_of_Volunteer_Attendees__c=0;
            cls.IsUpdated = false;
            cls.recEvent = eveTmp;
            evMap.put(eveTmp.EventNumber__c, cls );
            lstEventNumber.Add(eveTmp.EventNumber__c);
        }
        // get event attendee records for workers and service users that attended these events.
        ead = [select id,name, EventNumber__c, User__r.Worker_Type__c, 
                        Contact__r.Worker_Type__c, contact__r.Record_Type_Name__c 
                        ,Attendance_Status__c
                from Event_Attendance_Details__c
              where EventNumber__c =:lstEventNumber 
              and Attendance_Status__c='Attended']; 

        system.debug ('ead.size = '+ ead.size());
        //loop around attendees and update counters on event
        if (ead.size()>0) {
            for (Event_Attendance_Details__c eadrec: ead){
                if (eadrec.Attendance_Status__c=='Attended') 
                    {
                      //get the relevant event record
                      AttendeeClass  aceve = evMap.get(eadrec.EventNumber__c);
                      //now work out what event attendance is for.  Start with Volunteers and staff
                      // these can be either users or contacts   
                      if ((eadrec.User__r.Worker_Type__c!=null)&&(eadrec.User__r.Worker_Type__c=='Staff'))
                         {aceve.recEvent.Number_of_Worker_Attendees__c++;
                         }
                      if ((eadrec.User__r.Worker_Type__c!=null)&&(eadrec.User__r.Worker_Type__c=='Volunteer'))
                         {aceve.recEvent.Number_of_Volunteer_Attendees__c++;
                         }
                      if (eadrec.Contact__r.Record_Type_Name__c!=null){
                        //volunteers recorded as contacts
                        if (eadrec.Contact__r.Record_Type_Name__c=='Volunteer'){
                            if (eadrec.Contact__r.Worker_Type__c=='Staff')
                            {aceve.recEvent.Number_of_Worker_Attendees__c++;
                            }
                            if (eadrec.Contact__r.Worker_Type__c=='Volunteer')
                            {aceve.recEvent.Number_of_Volunteer_Attendees__c++;
                            }
                        }
                        //service users, always recorded as contacts.
                        if (eadrec.Contact__r.Record_Type_Name__c=='Person_with_dementia')
                           {aceve.recEvent.Number_of_Person_with_Dementia_Attendees__c++;
                           }
                        if (eadrec.Contact__r.Record_Type_Name__c=='Carer')
                           {aceve.recEvent.Number_of_Carer_Attendees__c++;
                           }
                      }
                       
                       //now mark the record as dirty and return updated record to map
                       aceve.IsUpdated=true;
                       evMap.put(eadrec.EventNumber__c,aceve );
                    }
            }
        // populate list with updated events.  Extract events from map and create a list of events to update.
            attendeeClsList = evMap.values();
            for (AttendeeClass  gp: attendeeClsList ) {
               System.debug('###event '+ gp.recEvent.ID + ' EvNo=' + gp.recEvent.EventNumber__c+ ' IsUpdated='+gp.IsUpdated+' staff='+gp.recEvent.Number_of_Worker_Attendees__c +' vols='+gp.recEvent.Number_of_Volunteer_Attendees__c +' pwd='+gp.recEvent.Number_of_Person_with_Dementia_Attendees__c + ' carer='+gp.recEvent.Number_of_Carer_Attendees__c);
               //only add if numbers have changed.
               if ((gp.IsUpdated)&&(
                                    (gp.OldNumber_of_PWD_Attendees != gp.recEvent.Number_of_Person_with_Dementia_Attendees__c)||
                                    (gp.OldNumber_of_Carer_Attendees!=gp.recEvent.Number_of_Carer_Attendees__c) ||
                                    (gp.OldNumber_of_Volunteer_Attendees!=gp.recEvent.Number_of_Volunteer_Attendees__c) ||
                                    (gp.OldNumber_of_Worker_Attendees!=gp.recEvent.Number_of_Worker_Attendees__c)))
               {
                groupEvents.add(gp.recEvent);
               }
            }
            if (groupEvents.size()>0){
                update groupEvents ;    
            }
        }
    }
}
private class AttendeeClass
{
  private boolean IsUpdated                             {get;set;}
  private Decimal OldNumber_of_PWD_Attendees            {get;set;}
  private Decimal OldNumber_of_Carer_Attendees          {get;set;}
  private Decimal OldNumber_of_Worker_Attendees         {get;set;}
  private Decimal OldNumber_of_Volunteer_Attendees      {get;set;}
  private Event recEvent                                {get;set;}
}
global void finish(Database.BatchableContext BC){
    // First, reserve email capacity for the current Apex transaction to ensure
    // that we won't exceed our daily email limits when sending email after
    // the current transaction is committed.
    Messaging.reserveSingleEmailCapacity(1);
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    mail.setToAddresses(new String[] {email});
    mail.setSenderDisplayName('Batch Processing');
    mail.setSubject('Batch Process Completed');
    String strMessage = 'Batch Process has completed';
    strMessage = strMessage  + '\n query: ' + query;
    mail.setPlainTextBody( strMessage );
    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}