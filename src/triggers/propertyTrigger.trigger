trigger propertyTrigger on Location__c(after insert, after update, after delete,before insert,before update) {
/********************************************************************************
* To stop triggers firing more than once, put them in a handler class.
*
* Object: Property
* Sri Tadikonda
* 
*    27 Feb 2014 Add calls to UpdateLastTransaction routine
*    09 Jan 2015 Added SplitLocationAddresses trigger lakshmi rajendram
********************************************************************************/

    // Delegate responsibility to the Property Trigger Handler Class.
    PropertyTriggerHandler handler = new PropertyTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){
        handler.splitLocationAddresses(Trigger.new,Trigger.oldMap);


    }
    else if(Trigger.isInsert && Trigger.isAfter &&!CustomUtils.isDisabledTriggers()){
      //Call the Handler OnAfterInsert Method and execute trigger logic.
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    
    }
    else if(Trigger.isUpdate && Trigger.isBefore &&!CustomUtils.isDisabledTriggers()){
    handler.splitLocationAddresses(Trigger.new, Trigger.oldMap);
    
    }
    else if(Trigger.isUpdate && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
      //Call the Handler OnAfterUpdate Method and execute trigger logic.
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);

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