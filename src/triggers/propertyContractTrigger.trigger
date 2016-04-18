trigger propertyContractTrigger on Property_Contract__c(after insert, after update, after delete) {
/********************************************************************************
* To stop triggers firing more than once, put them in a handler class.
*
* Object: Property Contract
* Sri Tadikonda
* 
*    27 Feb 2014 Add calls to UpdateLastTransaction routine
********************************************************************************/

    // Delegate responsibility to the Property Contract Trigger Handler Class.
    PropertyContractTriggerHandler handler = new PropertyContractTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore){

    }
    else if(Trigger.isInsert && Trigger.isAfter){
      //Call the Handler OnAfterInsert Method and execute trigger logic.
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);

    }
    else if(Trigger.isUpdate && Trigger.isBefore){

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

    }
    else if(Trigger.isUnDelete){
  
    }
}