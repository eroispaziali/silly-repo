public with sharing class TaskTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Task Trigger.
 *  Author  : Mike Tinson
 *  Date    : 13-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the Task Record.
 *               
 *  Modification History
 *  Date            Who         Description 
 *   xxx            xxx         xxx
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public TaskTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(Task[] NewTasks, Map<ID, Task> TaskMap){
        System.debug('****** TaskTriggerHandler.OnAfterInsert  ******');
        
        
        UpdateLastTransactionDate(NewTasks);
    }   
 

    
    public void OnAfterUpdate(Task[] oldTask, Task[] updatedTask, Map<ID, Task> TaskMap){
        System.debug('****** TaskTriggerHandler.OnAfterUpdate  ******');
        
        UpdateLastTransactionDate(updatedTask);
    }



    public void OnAfterDelete(Task[] oldTask, Map<ID, Task> TaskMap){
    
        System.debug('****** TaskTriggerHandler.OnAfterUpdate  ******');
        
        UpdateLastTransactionDate(oldTask);
    }
        
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

public void UpdateLastTransactionDate(Task[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Task df: updatedSUs){
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