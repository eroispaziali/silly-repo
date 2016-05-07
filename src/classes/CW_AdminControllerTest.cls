@isTest
private class CW_AdminControllerTest {

/**
* File Name   :    CW_AdminControllerTest.cls
* Description :    Test Class for CW_AdminController.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 24/04/2014 Chris Yorkston	Initial version
*
*
*/

    @isTest static void testAdminControllerUpdateAudienceGroupMembers() {
    	
    	// setup data
		system.assertEquals(null, CustomSettingUtil.getRunBatchDate());
		
		CW_CampaignListSetting__c batchRunDateRecord = new CW_CampaignListSetting__c();
		batchRunDateRecord.Name = ConstantUtil.BATCH_RUN_DATE;
		//schedule start date cannot be today or in the past
		Date runBatchDate = Date.today().addDays(1);
		batchRunDateRecord.Date_Value__c = runBatchDate;
		insert batchRunDateRecord;
		
		// asset that we can retrieve run batch date from custom setting
		system.assertEquals(runBatchDate, CustomSettingUtil.getRunBatchDate());
		
		List<CW_Campaign__c> camps = TestDataUtil.getCampaigns(3);
		insert camps;
		
		List<CW_Schedule__c> schedules = new List<CW_Schedule__c>();
		
		// schedule is created with evaluation start date (runBatchDate -2 days) and evaluation end date (runBatchDate +2 days)
		schedules.add( TestDataUtil.getSchedule(camps[0].Id, runBatchDate) );
		
		// schedule is created with evaluation start date and evaluation end date before runBatchDate
		schedules.add( TestDataUtil.getSchedule(camps[2].Id, runBatchDate.addMonths(2)) );
		
		insert schedules;
		
		//CW_Audience_Group__c audienceGroup = TestDataUtil.createAudienceGroup(camp.Id);
		List<CW_Audience_Group__c> audienceGroups = TestDataUtil.getAudienceGroups(camps);
		insert audienceGroups;
		
		List<Contact> contacts = TestDataUtil.getContacts(3);
		insert contacts;
		
		/*
		// 10/07/2014 CY - no longer required to insert AGS records manually as they are created by trigger
		List<CW_Audience_Group_Schedule__c> audienceGroupSchedules = new List<CW_Audience_Group_Schedule__c>();
		audienceGroupSchedules.add( TestDataUtil.createAudienceGroupSchedule(audienceGroups[0].Id, schedules[0].Id) );
		audienceGroupSchedules.add( TestDataUtil.createAudienceGroupSchedule(audienceGroups[1].Id, schedules[1].Id) );
		audienceGroupSchedules.add( TestDataUtil.createAudienceGroupSchedule(audienceGroups[2].Id, schedules[2].Id) );
		insert audienceGroupSchedules;
		*/
		Set<Id> audienceGroupIds = new Set<Id>();
		for (CW_Audience_Group__c ag :audienceGroups) audienceGroupIds.add(ag.Id);
		List<CW_Audience_Group_Schedule__c> audienceGroupSchedules = 
			[select Id, Name, Audience_Group__c, Schedule__c from CW_Audience_Group_Schedule__c where Audience_Group__c in :audienceGroupIds];
		
		Map<Id,CW_Audience_Group_Schedule__c> agsMap = new Map<Id,CW_Audience_Group_Schedule__c>(); 
		for (CW_Audience_Group_Schedule__c ags :audienceGroupSchedules) 
			agsMap.put(ags.Audience_Group__c, ags);
		
		List<CW_Audience_Group_Member__c> audienceGroupMembers = new List<CW_Audience_Group_Member__c>();
		for (Integer i=0;i<3;i++) {
			CW_Audience_Group_Member__c audienceGroupMember = TestDataUtil.getAudienceGroupMember();
			audienceGroupMember.Audience_Group_LU__c = audienceGroups[i].Id;
			//audienceGroupMember.Audience_Group_Schedule__c = audienceGroupSchedules[i].Id;
			audienceGroupMember.Audience_Group_Schedule__c = agsMap.get(audienceGroups[i].Id).Id;
			audienceGroupMember.Contact__c = contacts[i].Id;
			audienceGroupMembers.add(audienceGroupMember);
		}
		insert audienceGroupMembers;
		
		// assert that audience group member have KPI's at 0
		Set<Id> audienceGroupMemberIds = new Set<Id>();
		for (CW_Audience_Group_Member__c agm :audienceGroupMembers) {
			system.assertEquals(0, agm.Lifetime_NGR__c);
			system.assertEquals(0, agm.Lifetime_Wager__c);
			audienceGroupMemberIds.add(agm.Id);
		}
		
    	Test.startTest();
        Pagereference pageRef = Page.CW_Admin;
        Test.setCurrentPage(pageRef);
        
        CW_AdminController controller = new CW_AdminController();
        controller.updateAudienceGroupMembers();
        Test.stopTest();
        
        // get updated audience group members 
		// (batch job should have stamped KPI's from contact record on group member record where run batch date was inside the eval dates of a schedule)
		List<CW_Audience_Group_Member__c> updatedAudienceGroupMembers = 
			[select Id, Lifetime_NGR__c, Lifetime_Wager__c from CW_Audience_Group_Member__c where Id in :audienceGroupMemberIds];
			
		for (CW_Audience_Group_Member__c agm :updatedAudienceGroupMembers) {
			if (agm.Id == audienceGroupMembers[0].Id) {
				// run batch date was inside period of schedule; KPI's have been updated from Contact to assocated Audience Group Member record
				system.assertEquals(contacts[0].Lifetime_NGR__c, agm.Lifetime_NGR__c);
				system.assertEquals(contacts[0].Lifetime_Wager__c, agm.Lifetime_Wager__c);
			} 
		}
    }
    
    @isTest static void testAdminControllerAddAndRemoveScheduleBatchUpdateAudienceGroupMembers() {
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
 		Pagereference pageRef = Page.CW_Admin;
        Test.setCurrentPage(pageRef);
        
        CW_AdminController controller = new CW_AdminController();
        controller.addScheduledJobToUpdateAudienceGroupMembers();
		Test.stopTest();
		
		// assert that batch job is scheduled
		List<CronTrigger> cronJobs = [
	    	select Id, CronJobDetailId, CronJobDetail.Name 
	    	from CronTrigger where CronJobDetail.Name LIKE :ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_MEMBER+'%'
	    ];
	    system.assertEquals(true, cronJobs.size()==1);
	    
	    // remove schedule
	    controller.removeScheduledJobToUpdateAudienceGroupMembers();
	    
	    // assert that batch job is scheduled
		cronJobs = [
	    	select Id, CronJobDetailId, CronJobDetail.Name 
	    	from CronTrigger where CronJobDetail.Name LIKE :ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_MEMBER+'%'
	    ];
	    system.assertEquals(true, cronJobs.size()==0);
	    
    }

 	@isTest 
 	static void testAdminControllerAddAndRemoveScheduleBatchUpdateAudienceGroupRelation() {
    	// setup data
		//No setup data for now
		
		// Instantiate the batch class
		CW_BatchAudienceGroupRelationAssign myBatch = new CW_BatchAudienceGroupRelationAssign();
 
		// Instantiate the scheduler
		BatchScheduler scheduler = new BatchScheduler();
 
		// Assign the batch class to the variable within the scheduler
		scheduler.batchClass = myBatch;
 
		// Get Schedule string - run every day at 1am (01:00)
		String sch = ConstantUtil.BATCH_APEX_SCHEDULE_UPDATE_AUDIENCE_GROUP_MEMBER;
 
 		Test.startTest();
 		Pagereference pageRef = Page.CW_Admin;
        Test.setCurrentPage(pageRef);
        
        CW_AdminController controller = new CW_AdminController();
        controller.addScheduledJobToUpdateAudienceGroupRelation();
		Test.stopTest();
		
		// assert that batch job is scheduled
		List<CronTrigger> cronJobs = [
	    	select Id, CronJobDetailId, CronJobDetail.Name 
	    	from CronTrigger where CronJobDetail.Name LIKE :ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_RELATION+'%'
	    ];
	    system.assertEquals(true, cronJobs.size()==1);
	    
	    // remove schedule
	    controller.removeScheduledJobToUpdateAudienceGroupRelation();
	    
	    // assert that batch job is scheduled
		cronJobs = [
	    	select Id, CronJobDetailId, CronJobDetail.Name 
	    	from CronTrigger where CronJobDetail.Name LIKE :ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_RELATION+'%'
	    ];
	    system.assertEquals(true, cronJobs.size()==0);
	    
    }    
}