public with sharing class zzServiceUsageCopyTriggerHandler {

    /* *************************************************************************
       
       APEX Handler Class contains the execution logic of the zzService_Usage_Copy__c Trigger.
       
       *************************************************************************/
          	
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
   
	public zzServiceUsageCopyTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnAfterUpdate(zzService_Usage_Copy__c[] oldzzServiceUsageCopy, zzService_Usage_Copy__c[] updatedzzServiceUsageCopy, Map<ID, zzService_Usage_Copy__c> zzServiceUsageCopyMap){
		System.debug('****** zzServiceUsageCopyTriggerHandler.OnBeforeUpdate  ******');
		
		/*
		
		ADD TRIGGER LOGIC HERE!
		
		*/
		
		System.debug('****** Call Apex Class zzDateModifiedLookup Start ******');
		
		// Call Apex Class to populate zzDateModifiedLookup__c Object.
		zzDateModifiedLookup handler = new zzDateModifiedLookup();
		handler.zzDateModifiedLookupUpdate();
		
		System.debug('****** zzDateModifiedLookup End ******');
	}
	
	public boolean IsTriggerContext{
		get{ return m_isExecuting;}
	}

}