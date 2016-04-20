public with sharing class DemographicInfoTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Demographic_Information__c Trigger.
 *  Author  : Ian Smith
 *  Date    : 23-06-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class prevents duplicate Demographic Info records being added to the 
 *                  Contact Record. Also calls the LastTransactionDateLookup Apex Class to update 
 *                  the lastTransactionDate__c field for the Demographic_Information__c Record.
 *               
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ????                           
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public DemographicInfoTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    

    public void OnBeforeInsert(Demographic_Information__c[] demoInfo, Map<ID, Demographic_Information__c> demoInfoMap){
        System.debug('****** DemographicInfoTriggerHandler.OnBeforeInsert  ******');

        List<Id> demoInfoIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        Map<String, Demographic_Information__c> mapDemoInfo = new Map<String, Demographic_Information__c>();

        for(Demographic_Information__c d : demoInfo){
            if(d != null){
                demoInfoIds.add(d.Id);
                
                if(d.Person__c != null){
                    mapDemoInfo.put(d.Person__c,d);
                }
            }
        }
        System.debug('****** demoInfoIds.Size ******' + demoInfoIds.Size());
        
        if(mapDemoInfo != null && !mapDemoInfo.isEmpty()){
            for(Demographic_Information__c di : [SELECT Id, Person__c FROM Demographic_Information__c WHERE Person__c IN : mapDemoInfo.KeySet()]){
                if(di != null){
                    Demographic_Information__c newDemoInfo = mapDemoInfo.get(di.Person__c);
                    newDemoInfo.Person__c.addError('A Demographic Information record for this Person already exists!');                                      
                }               
            }           
        }
    }


/**
    public void OnBeforeUpdate(Demographic_Information__c[] oldDemoInfo, Demographic_Information__c[] updatedDemoInfo, Map<ID, Demographic_Information__c> demoInfoMap){
        System.debug('****** DemographicInfoTriggerHandler.OnBeforeUpdate  ******');
        
        List<Id> demoInfoIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        Map<String, Demographic_Information__c> mapDemoInfo = new Map<String, Demographic_Information__c>();

        for(Demographic_Information__c d : updatedDemoInfo){
            if(d != null){
                demoInfoIds.add(d.Id);
                
                if(d.Person__c != null){
                    mapDemoInfo.put(d.Person__c,d);
                }
            }
        }
        System.debug('****** demoInfoIds.Size ******' + demoInfoIds.Size());
        
        if(mapDemoInfo != null && !mapDemoInfo.isEmpty()){
            for(Demographic_Information__c di : [SELECT Id, Person__c FROM Demographic_Information__c WHERE Person__c IN : mapDemoInfo.KeySet()]){
                if(di != null){
                    Demographic_Information__c newDemoInfo = mapDemoInfo.get(di.Person__c);
                    newDemoInfo.Person__c.addError('A Demographic Information record for this Person already exists!');                                      
                }               
            }           
        }
    }
    
**/    
    
    public void OnAfterInsert(Demographic_Information__c[] demoInfo, Map<ID, Demographic_Information__c> demoInfoMap){
        System.debug('****** DemographicInfoTriggerHandler.OnAfterInsert  ******');
        
        List<Id> demoInfoIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(Demographic_Information__c di : demoInfo){
            demoInfoIds.add(di.id);
        }
        System.debug('****** demoInfoIds.Size ******' + demoInfoIds.Size());

        if(demoInfoIds.isEmpty() == false){
            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
            LastTransactionDateLookup handler = new LastTransactionDateLookup();
            handler.UpdateLastTransactionDate(demoInfoIds[0], dtLastTransactionDate); 
        }
    }  
    
    
    
    public void OnAfterUpdate(Demographic_Information__c[] oldDemoInfo, Demographic_Information__c[] updatedDemoInfo, Map<ID, Demographic_Information__c> demoInfoMap){
        System.debug('****** DemographicInfoTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> demoInfoIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(Demographic_Information__c di : updatedDemoInfo){
            demoInfoIds.add(di.Id);
        }
        System.debug('****** demoInfoIds.Size ******' + demoInfoIds.Size());

        if(demoInfoIds.isEmpty() == false){
            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
            LastTransactionDateLookup handler = new LastTransactionDateLookup();
            handler.UpdateLastTransactionDate(demoInfoIds[0], dtLastTransactionDate); 
        }
    }      



    public void OnAfterDelete(Demographic_Information__c[] oldDemoInfo, Map<ID, Demographic_Information__c> demoInfoMap){
    
        System.debug('****** DemographicInfoTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> demoInfoIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(Demographic_Information__c di : oldDemoInfo){
            demoInfoIds.add(di.Id);
        }
        System.debug('****** demoInfoIds.Size ******' + demoInfoIds.Size());

        if(demoInfoIds.isEmpty() == false){
            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
            LastTransactionDateLookup handler = new LastTransactionDateLookup();
            handler.UpdateLastTransactionDate(demoInfoIds[0], dtLastTransactionDate); 
        }
    }
        
  
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }


}