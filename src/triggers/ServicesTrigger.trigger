trigger ServicesTrigger on Services__c (after insert, after update, after delete,before update,before insert) {
/********************************************************************************
* To stop triggers firing more than once, put them in a handler class.
*
* Object: Services__c
* Mike Tinson
* 
*    12 Feb 2014 Add calls to UpdateLastTransaction routine
*    08 Sep 2014 Added line 28-41 to update Is_Update__c when service details change  by Lakshmi Rajendram
*    13 Jan 2015 Combined all triggers on to a handler class
********************************************************************************/
 System.debug('****** DF_EventTrigger ******');

    // Delegate responsibility to the DF_EventTriggerHandler Class.
    ServicesTriggerHandler handler = new ServicesTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){
    
     handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
      //Call the Handler OnAfterInsert Method and execute trigger logic.
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);

    }
   
    else if(Trigger.isUpdate && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){//update Is Updated =true when either of service name,service type,service status or service record type has been changed
     handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);
     
    
     }
     
     
    else if(Trigger.isUpdate && Trigger.isAfter  && !CustomUtils.isDisabledTriggers()){
  
    handler.OnAfterInsert(Trigger.new,Trigger.newMap);
  
  }
  
  
  else if(Trigger.isInsert && Trigger.isAfter  && !CustomUtils.isDisabledTriggers()){//update Is Updated =true when either of service name,service type,service status or service record type has been changed
    
     handler.OnAfterUpdate(Trigger.old,Trigger.new,Trigger.oldMap); 
     }
 
    else if(Trigger.isDelete && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){

    }
    else if(Trigger.isDelete && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
      //Call the Handler OnAfterDelete Method and execute trigger logic.
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);

    }
    else if(Trigger.isUnDelete && !CustomUtils.isDisabledTriggers()){
  
    }
    
   

}