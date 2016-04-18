public with sharing class PropertyInsuranceTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Property Insurance Trigger.
 *  Author  : Sri Tadikonda
 *  Date    : 27-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the Properties Record.
 *               
 *  Modification History
 *  Date            Who         Description 
 *   xxx            xxx         xxx
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public PropertyInsuranceTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(Property_Insurance__c[] NewProperties, Map<ID, Property_Insurance__c> PropertiesMap){
        System.debug('****** PropertyTriggerHandler.OnAfterInsert  ******');
        
        
        UpdateLastTransactionDate(NewProperties);
    }   
 

    
    public void OnAfterUpdate(Property_Insurance__c[] oldProperties, Property_Insurance__c[] updatedProperties, Map<ID, Property_Insurance__c> PropertiesMap){
        System.debug('****** PropertyTriggerHandler.OnAfterUpdate  ******');
        
        UpdateLastTransactionDate(updatedProperties);
    }



    public void OnAfterDelete(Property_Insurance__c[] oldProperties, Map<ID, Property_Insurance__c> PropertiesMap){
    
        System.debug('****** PropertyTriggerHandler.OnAfterDelete  ******');
        
        UpdateLastTransactionDate(oldProperties);
    }
        
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

public void UpdateLastTransactionDate(Property_Insurance__c[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Property_Insurance__c df: updatedSUs){
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