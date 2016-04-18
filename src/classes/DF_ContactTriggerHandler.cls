public with sharing class DF_ContactTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the DF_Contact__c Trigger.
 *  Author  : Ian Smith
 *  Date    : 23-01-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *					lastTransactionDate__c field for the DF_Contact__c Record.
 *               
 *  Modification History
 *  Date            Who     	Description 
 *  24-01-2014      MTinson 	Added Call to UpdateLastTransactionDate Class.
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public DF_ContactTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(DF_Contact__c[] dfContacts, Map<ID, DF_Contact__c> DFContactMap){
        System.debug('****** DF_ContactTriggerHandler.OnAfterInsert  ******');
        
        List<Id> dfContactIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(DF_Contact__c df : dfContacts){
            dfContactIds.add(df.id);
        }
        System.debug('****** dfContactIds.Size ******' + dfContactIds.Size());

		if(dfContactIds.isEmpty() == false){
			
			//Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
			LastTransactionDateLookup handler = new LastTransactionDateLookup();
			handler.UpdateLastTransactionDate(dfContactIds[0], dtLastTransactionDate); 
			
		}
    }   
 

    
    public void OnAfterUpdate(DF_Contact__c[] oldDFContact, DF_Contact__c[] updatedDFContact, Map<ID, DF_Contact__c> DFContactMap){
        System.debug('****** DF_ContactTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> dfContactIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(DF_Contact__c df : updatedDFContact){
            dfContactIds.add(df.Id);
        }
        System.debug('****** dfContactIds.Size ******' + dfContactIds.Size());

		if(dfContactIds.isEmpty() == false){
			
			//Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
			LastTransactionDateLookup handler = new LastTransactionDateLookup();
			handler.UpdateLastTransactionDate(dfContactIds[0], dtLastTransactionDate); 
			
		}
    }



	public void OnAfterDelete(DF_Contact__c[] oldDFContact, Map<ID, DF_Contact__c> DFContactMap){
    
		System.debug('****** DF_ContactTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> dfContactIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(DF_Contact__c df : oldDFContact){
            dfContactIds.add(df.Id);
        }
        System.debug('****** dfContactIds.Size ******' + dfContactIds.Size());

		if(dfContactIds.isEmpty() == false){
			
			//Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
			LastTransactionDateLookup handler = new LastTransactionDateLookup();
			handler.UpdateLastTransactionDate(dfContactIds[0], dtLastTransactionDate); 
			
		}
    }
        
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }


}