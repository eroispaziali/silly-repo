trigger ContactTrigger on Contact (before insert, after insert, before update, before delete) {
/********************************************************
* Call a handler class for all trigger events on Contact.
* This is to ensure that trigger actions is only done once

*09 Jan 2015 Added calls to SetDefaultAccount lakshmi rajendram
*09 Jan 2015 Added SplitLocationAddresses  lakshmi rajendram
********************************************************/
    ContactTriggerHandler handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);
    if(Trigger.isInsert && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){
       //handler.OnBeforeInsert(Trigger.new);
       handler.SetDefaultAccount(Trigger.new);
       handler.splitPeopleAddresses(Trigger.new,Trigger.oldMap);
        }
    else if(Trigger.isInsert && Trigger.isAfter&&!CustomUtils.isDisabledTriggers()){
       handler.OnAfterInsert(Trigger.new, Trigger.newMap);
      
        }
    else if(Trigger.isUpdate && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        handler.splitPeopleAddresses(Trigger.new,Trigger.oldMap);
    }
     
    else if(Trigger.isUpdate && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
     
    }
    else if(Trigger.isDelete && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){
         handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
        //Call the Handler OnAfterDelete Method and execute trigger logic.
        //handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
}