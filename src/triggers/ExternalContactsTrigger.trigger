trigger ExternalContactsTrigger on External_Contacts__c (after insert,after update) {
/********************************************************************************
* To stop triggers firing more than once, put them in a handler class.
*
* Object: External_Contacts__c
* Lakshmi Rajendram
* 
*    
*    
*    
********************************************************************************/
 System.debug('****** ExternalContactTrigger******');

   
    ExternalContactsTriggerHandler handler = new ExternalContactsTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
    
    handler.OnAfterInsert(Trigger.new,Trigger.oldMap);
    
    }
    if(Trigger.isUpdate && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
    
    handler.OnAfterUpdate( Trigger.new, Trigger.old,Trigger.oldMap);
    
    }
}