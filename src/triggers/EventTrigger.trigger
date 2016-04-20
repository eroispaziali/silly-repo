trigger EventTrigger on Event (before insert, after insert, before update, after update, before delete, after delete) {
/********************************************************************************
* To stop triggers firing more than once, put them in a handler class.
*
* Object: Event
* Mike Tinson
* 
*    13 Feb 2014 Add calls to UpdateLastTransaction routine
*    3 Feb 2015  Check for Global Disable Triggers
********************************************************************************/
 System.debug('****** EventTrigger ******');
 System.debug('****** Insert' +Trigger.isInsert +'* Update' + Trigger.isUpdate + '* Before ' + Trigger.isBefore  + '* After ' + Trigger.isAfter );
    // Delegate responsibility to the DF_EventTriggerHandler Class.
    EventTriggerHandler handler = new EventTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){
    	handler.OnBeforeInsert(Trigger.new);

    }
    else if(Trigger.isInsert && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
      //Call the Handler OnAfterInsert Method and execute trigger logic.
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);

    }
    else if(Trigger.isUpdate && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){
		handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
      //Call the Handler OnAfterUpdate Method and execute trigger logic.
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);

    }
    else if(Trigger.isDelete && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){
		handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter&& !CustomUtils.isDisabledTriggers()){
      //Call the Handler OnAfterDelete Method and execute trigger logic.
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);

    }
    else if(Trigger.isUnDelete && !CustomUtils.isDisabledTriggers()){
  
    }
}