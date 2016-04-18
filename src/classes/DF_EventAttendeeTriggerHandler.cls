public with sharing class DF_EventAttendeeTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the DF_EventAttendee__c Trigger.
 *  Author  : Ian Smith
 *  Date    : 24-01-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *					lastTransactionDate__c field for the DF_EventAttendee__c Record.
 *               
 *  Modification History
 *  Date            Who     	Description 
 *  24-01-2014      MTinson 	Added Call to UpdateLastTransactionDate Class.
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public DF_EventAttendeeTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
        public void OnAfterInsert(DF_EventAttendee__c[] dfEventAttendee, Map<ID, DF_EventAttendee__c> dfEventAttendeeMap){
        System.debug('****** DF_EventAttendeeTriggerHandler.OnAfterInsert  ******');
        
        List<Id> dfEventAttendeeIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(DF_EventAttendee__c df : dfEventAttendee){
            dfEventAttendeeIds.add(df.Id);
        }
        System.debug('****** dfEventAttendeeIds.Size ******' + dfEventAttendeeIds.Size());

		if(dfEventAttendeeIds.isEmpty() == false){
			
			//Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
			LastTransactionDateLookup handler = new LastTransactionDateLookup();
			handler.UpdateLastTransactionDate(dfEventAttendeeIds[0], dtLastTransactionDate); 
			
		}
    }   
    
    

    public void OnAfterUpdate(DF_EventAttendee__c[] olddfEventAttendee, DF_EventAttendee__c[] updateddfEventAttendee, Map<ID, DF_EventAttendee__c> dfEventAttendeeMap){
        System.debug('****** DF_EventAttendeeTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> dfEventAttendeeIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(DF_EventAttendee__c df : updateddfEventAttendee){
            dfEventAttendeeIds.add(df.Id);
        }
        System.debug('****** dfEventAttendeeIds.Size ******' + dfEventAttendeeIds.Size());

		if(dfEventAttendeeIds.isEmpty() == false){
			
			//Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
			LastTransactionDateLookup handler = new LastTransactionDateLookup();
			handler.UpdateLastTransactionDate(dfEventAttendeeIds[0], dtLastTransactionDate); 
			
		}
    }

	
	
	public void OnAfterDelete(DF_EventAttendee__c[] oldDFEventAttendee, Map<ID, DF_EventAttendee__c> DFEventAttendeeMap){
    
        System.debug('****** DF_EventAttendeeTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> dfEventAttendeeIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(DF_EventAttendee__c df : oldDFEventAttendee){
            dfEventAttendeeIds.add(df.Id);
        }
        System.debug('****** dfEventAttendeeIds.Size ******' + dfEventAttendeeIds.Size());

		if(dfEventAttendeeIds.isEmpty() == false){
			
			//Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
			LastTransactionDateLookup handler = new LastTransactionDateLookup();
			handler.UpdateLastTransactionDate(dfEventAttendeeIds[0], dtLastTransactionDate); 
			
		}
    }


        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

}