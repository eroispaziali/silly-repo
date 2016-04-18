public with sharing class PropertyAuditTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Property Audit Trigger.
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
    
    public PropertyAuditTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(Property_Audit__c[] NewPropertyAudits, Map<ID, Property_Audit__c> PropertyAuditsMap){
        System.debug('****** PropertyAuditTriggerHandler.OnAfterInsert  ******');
        
        
        UpdateLastTransactionDate(NewPropertyAudits);
    }   
 

    
    public void OnAfterUpdate(Property_Audit__c[] oldPropertyAudits, Property_Audit__c[] updatedPropertyAudits, Map<ID, Property_Audit__c> PropertyAuditsMap){
        System.debug('****** PropertyAuditTriggerHandler.OnAfterUpdate  ******');
        
        UpdateLastTransactionDate(updatedPropertyAudits);
    }



    public void OnAfterDelete(Property_Audit__c[] oldPropertyAudits, Map<ID, Property_Audit__c> PropertyAuditsMap){
    
        System.debug('****** PropertyAuditTriggerHandler.OnAfterDelete  ******');
        
        UpdateLastTransactionDate(oldPropertyAudits);
    }
        
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

public void UpdateLastTransactionDate(Property_Audit__c[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Property_Audit__c df: updatedSUs){
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