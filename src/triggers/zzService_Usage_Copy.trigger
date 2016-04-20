trigger zzService_Usage_Copy on zzService_Usage_Copy__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

	/* The code is broken down into a Trigger and an Apex “handler” class that implements the actual functionality.
	   It’s best practice to only have one trigger for each object and to avoid complex logic in triggers. 
	   To simplify testing and resuse, triggers should delegate to Apex classes which contain the actual execution logic.*/

	// Delegate responsibility to the DF_EventAttendeeTriggerHandler Class.
	zzServiceUsageCopyTriggerHandler handler = new zzServiceUsageCopyTriggerHandler(Trigger.isExecuting, Trigger.size);
	
	if(Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}
}