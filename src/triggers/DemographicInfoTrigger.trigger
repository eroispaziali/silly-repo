trigger DemographicInfoTrigger on Demographic_Information__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    /* The code is broken down into a Trigger and an Apex “handler” class that implements the actual functionality.
       It’s best practice to only have one trigger for each object and to avoid complex logic in triggers. 
       To simplify testing and resuse, triggers should delegate to Apex classes which contain the actual execution logic.*/

    System.debug('****** DemographicInfoTrigger ******');

    // Delegate responsibility to the DemographicInfoTriggerHandler Class.
    DemographicInfoTriggerHandler handler = new DemographicInfoTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore){
        //Call the Handler OnBeforeInsert Method and execute trigger logic.
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
        
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        //Call the Handler OnAfterInsert Method and execute trigger logic.
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        //Call the Handler OnBeforerUpdate Method and execute trigger logic.
        //handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        //Call the Handler OnAfterUpdate Method and execute trigger logic.
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);

    }
    else if(Trigger.isDelete && Trigger.isBefore){

    }
    else if(Trigger.isDelete && Trigger.isAfter){
        //Call the Handler OnAfterDelete Method and execute trigger logic.
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        
    }/*
    else if(Trigger.isUnDelete){
  
    }*/

}