trigger ServiceUsageTrigger on Service_Usage__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    ServiceUsageTriggerHandler handler = new ServiceUsageTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
        //handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        //ServiceUsageTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        //change 380 needs before update trigger
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        //ServiceUsageTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
    }
    
    else if(Trigger.isDelete && Trigger.isBefore){
        //handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        //ServiceUsageTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }
    
    else if(Trigger.isUnDelete){
        //handler.OnUndelete(Trigger.new);    
    }
}