@isTest
private class BatchSchedulerTest {

/**
* File Name   :    BatchSchedulerTest.cls
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

	@isTest static void testBatchScheduler() {
		
		// setup data
		CW_CampaignListSetting__c batchRunDateRecord = new CW_CampaignListSetting__c();
		batchRunDateRecord.Name = ConstantUtil.BATCH_RUN_DATE;
		batchRunDateRecord.Date_Value__c = Date.today();
		insert batchRunDateRecord;
		
		// Instantiate the batch class
		CW_BatchUpdateAudienceGroupMember myBatch = new CW_BatchUpdateAudienceGroupMember();
 
		// Instantiate the scheduler
		BatchScheduler scheduler = new BatchScheduler();
 
		// Assign the batch class to the variable within the scheduler
		scheduler.batchClass = myBatch;
 
		// Get Schedule string - run every day at 1am (01:00)
		String sch = ConstantUtil.BATCH_APEX_SCHEDULE_UPDATE_AUDIENCE_GROUP_MEMBER;
 
 		Test.startTest();
 		// schedule batch apex job
		System.schedule(ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_MEMBER+' - Everyday at 1pm', sch, scheduler);
		Test.stopTest();
		
		// assert that batch job is scheduled
		List<CronTrigger> cronJobs = [
	    	select Id, CronJobDetailId, CronJobDetail.Name 
	    	from CronTrigger where CronJobDetail.Name LIKE :ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_MEMBER+'%'
	    ];
	    system.assertEquals(true, cronJobs.size()==1);
		
	}

}