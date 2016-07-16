global class BatchSlotDeleter implements Database.Batchable<sObject> {
	
	public String   query;
	public String   deleteStatus = 'Expired';
	
	global BatchSlotDeleter() {

			 query =  ' SELECT  Id ' +
					  ' FROM	Booking_Slot__c' + 
					  ' WHERE	Status__c = ' + deleteStatus;

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}


   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Database.delete(scope, false);
	
	}

	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}