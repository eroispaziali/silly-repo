public with sharing class PropertyContractTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Property Contracts Trigger.
 *  Author  : Sri Tadikonda
 *  Date    : 27-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the Property Contracts Record.
 *               
 *  Modification History
 *  Date            Who         Description 
 *   xxx            xxx         xxx
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public PropertyContractTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(Property_Contract__c[] NewPropertyContracts, Map<ID, Property_Contract__c> PropertyContractsMap){        
        
        UpdateLastTransactionDate(NewPropertyContracts);
    }   
 

    
    public void OnAfterUpdate(Property_Contract__c[] oldPropertyContracts, Property_Contract__c[] updatedPropertyContracts, Map<ID, Property_Contract__c> PropertyContractsMap){
        
        UpdateLastTransactionDate(updatedPropertyContracts);
    }



    public void OnAfterDelete(Property_Contract__c[] oldPropertyContracts, Map<ID, Property_Contract__c> PropertyContractsMap){
    
        System.debug('****** PropertyTriggerHandler.OnAfterDelete  ******');
        
        UpdateLastTransactionDate(oldPropertyContracts);
    }
        
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

public void UpdateLastTransactionDate(Property_Contract__c[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Property_Contract__c df: updatedSUs){
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