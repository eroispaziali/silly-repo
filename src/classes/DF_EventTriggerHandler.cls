public with sharing class DF_EventTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the DF_Event__c Trigger.
 *  Author  : Ian Smith
 *  Date    : 24-01-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *					lastTransactionDate__c field for the DF_Event__c Record.
 *               
 *  Modification History
 *  Date            Who     	Description 
 *  24-01-2014      MTinson 	Added Call to UpdateLastTransactionDate Class.
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public DF_EventTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnAfterInsert(DF_Event__c[] dfEvent, Map<ID, DF_Event__c> dfEventMap){
        System.debug('****** DF_EventTriggerHandler.OnAfterInsert  ******');
        
        List<Id> dfEventIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(DF_Event__c df : dfEvent){
            dfEventIds.add(df.Id);
        }
        System.debug('****** dfEventIds.Size ******' + dfEventIds.Size());

		if(dfEventIds.isEmpty() == false){
			
			//Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
			LastTransactionDateLookup handler = new LastTransactionDateLookup();
			handler.UpdateLastTransactionDate(dfEventIds[0], dtLastTransactionDate); 
			
		}
    }   


    
    public void OnAfterUpdate(DF_Event__c[] olddfEvent, DF_Event__c[] updateddfEvent, Map<ID, DF_Event__c> dfEventMap){
    
        System.debug('****** DF_EventTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> dfEventIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(DF_Event__c df : updateddfEvent){
            dfEventIds.add(df.Id);
        }
        System.debug('****** dfEventIds.Size ******' + dfEventIds.Size());

		if(dfEventIds.isEmpty() == false){
			
			//Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
			LastTransactionDateLookup handler = new LastTransactionDateLookup();
			handler.UpdateLastTransactionDate(dfEventIds[0], dtLastTransactionDate); 
			
		}
    }
    
    

	public void OnAfterDelete(DF_Event__c[] oldDFEvent, Map<ID, DF_Event__c> DFEventMap){
    
        System.debug('****** DF_EventTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> dfEventIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(DF_Event__c df : oldDFEvent){
            dfEventIds.add(df.Id);
        }
        System.debug('****** dfEventIds.Size ******' + dfEventIds.Size());

		if(dfEventIds.isEmpty() == false){
			
			//Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
			LastTransactionDateLookup handler = new LastTransactionDateLookup();
			handler.UpdateLastTransactionDate(dfEventIds[0], dtLastTransactionDate); 
			
		}
    }
        
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

}