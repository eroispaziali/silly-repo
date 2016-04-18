public with sharing class EventAttendanceDetailsTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the EventAttendanceDetails Trigger.
 *  Author  : Mike Tinson
 *  Date    : 13-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the EventAttendanceDetails Record.
 *               
 *  Modification History
 *  Date            Who         Description 
 *   xxx            xxx         xxx
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public EventAttendanceDetailsTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(Event_Attendance_Details__c[] NewEventAttendanceDetails, Map<ID, Event_Attendance_Details__c> EventAttendanceDetailsMap){
        System.debug('****** EventAttendanceDetailsTriggerHandler.OnAfterInsert  ******');
        
        
        UpdateLastTransactionDate(NewEventAttendanceDetails);
    }   
 

    
    public void OnAfterUpdate(Event_Attendance_Details__c[] oldEventAttendanceDetails, Event_Attendance_Details__c[] updatedEventAttendanceDetails, Map<ID, Event_Attendance_Details__c> EventAttendanceDetailsMap){
        System.debug('****** EventAttendanceDetailsTriggerHandler.OnAfterUpdate  ******');
        
        UpdateLastTransactionDate(updatedEventAttendanceDetails);
    }



    public void OnAfterDelete(Event_Attendance_Details__c[] oldEventAttendanceDetails, Map<ID, Event_Attendance_Details__c> EventAttendanceDetailsMap){
    
        System.debug('****** EventAttendanceDetailsTriggerHandler.OnAfterUpdate  ******');
        
        UpdateLastTransactionDate(oldEventAttendanceDetails);
    }
        
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

public void UpdateLastTransactionDate(Event_Attendance_Details__c[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Event_Attendance_Details__c df: updatedSUs){
        SUIds.add(df.Id);
    }
    System.debug('****** SUIds.Size ******' + SUIds.Size());

    if(SUIds.isEmpty() == false){
      
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
      LastTransactionDateLookup handler = new LastTransactionDateLookup();
      handler.UpdateLastTransactionDate(SUIds[0], dtLastTransactionDate); 
      
        }
    
    }
}