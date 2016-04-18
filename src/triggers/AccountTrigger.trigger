trigger AccountTrigger on Account (after insert, after update, after delete,before update) {
/********************************************************************************
* To stop triggers firing more than once, put them in a handler class.
*
* Object: Account
* Mike Tinson
* 
*    13 Feb 2014 Add calls to UpdateLastTransaction routine
*               
 *  Modification History
 *  Date            Who                       Description 
 *   15/10/2014     Lakshmi Rajendram         Included setAccountAddressTrigger
 *   09/01/2015     Lakshmi Rajendram         Included calls to DisabledTriggers                    
******************************************************************************************/
 
 System.debug('****** AccountTrigger ******');

    // Delegate responsibility to the DF_AccountTriggerHandler Class.
    AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){

    }
    else if(Trigger.isInsert && Trigger.isAfter && !CustomUtils.isDisabledTriggers()){
      //Call the Handler OnAfterInsert Method and execute trigger logic.
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);

    }
    else if((Trigger.isBefore || Trigger.isInsert)&&!CustomUtils.isDisabledTriggers()){
       handler.OnBeforeUpdate(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore && !CustomUtils.isDisabledTriggers()){

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