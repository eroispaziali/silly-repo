public with sharing class UserTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Users Trigger.
 *  Author  : Mike Tinson
 *  Date    : 13-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the Users Record.
 *               
 *  Modification History
 *  Date            Who         Description 
 *   xxx            xxx         xxx
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public  UserTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(User[] NewUsers, Map<ID, User> UsersMap){
        System.debug('****** UserTriggerHandler.OnAfterInsert  ******');
        
        
        UpdateLastTransactionDate(NewUsers);
    }   
 

    
    public void OnAfterUpdate(User[] oldUsers, User[] updatedUsers, Map<ID, User> UsersMap){
        System.debug('****** UsersTriggerHandler.OnAfterUpdate  ******');
        
        UpdateLastTransactionDate(updatedUsers);
    }


/** cannot delete users
    public void OnAfterDelete(User[] oldUsers, Map<ID, User> UsersMap){
    
        System.debug('****** UsersTriggerHandler.OnAfterDelete  ******');
        
        UpdateLastTransactionDate(oldUsers);
    }
**/        
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
@future
private static void PopulateTxtDate(List<Id> updUsrId, Datetime dtLastTransactionDate){
    // has to be run in a separate routine to avoid a DML Mixed Exception
          //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
      LastTransactionDateLookup handler = new LastTransactionDateLookup();
      handler.UpdateLastTransactionDate(updUsrId[0], dtLastTransactionDate); 

}
public void UpdateLastTransactionDate(User[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(User df: updatedSUs){
        SUIds.add(df.Id);
    }
    System.debug('****** SUIds.Size ******' + SUIds.Size());

    if(SUIds.isEmpty() == false){
      
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
      //LastTransactionDateLookup handler = new LastTransactionDateLookup();
      //handler.UpdateLastTransactionDate(SUIds[0], dtLastTransactionDate); 
      PopulateTxtDate(SUIds, dtLastTransactionDate); 
      
        }
    
    }
}