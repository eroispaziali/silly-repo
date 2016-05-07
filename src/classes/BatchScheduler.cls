global class BatchScheduler implements Schedulable {
/**
* File Name   :    BatchScheduler.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 17/04/2014 Chris Yorkston Initial version
*
*
*/
	
	global Database.Batchable<SObject> batchClass{get;set;}
	global Integer batchSize{get;set;} {batchSize = 200;}
	 
	global void execute(SchedulableContext sc) {
		database.executebatch(batchClass, batchSize);
	}
	
}