@isTest
private class CW_CampaignTriggerHandlerTest {

/**
* File Name   :    CW_CampaignTriggerHandlerTest.cls
* Description :    Test Class for CW_CampaignTriggerHandler.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 29/04/2014 Chris Yorkston	Initial version
* 0.2 06/06/2014 Klea Kolaric	D-35748
*
*
*/
	// test that points on Campaign (child) are rolled up to Roadmap (parent) when Campaign records are created, updated, deleted and undeleted
	@isTest static void testCampaignRollupSumOnRoadmap() {
		
		// setup data
		CW_Roadmap__c roadmap = TestDataUtil.getRoadmap();
		insert roadmap;
		
		List<CW_Campaign__c> camps = TestDataUtil.getCampaigns(2);
		for (CW_Campaign__c c :camps) {
			c.Roadmap__c = roadmap.Id;
			c.Points__c = 5.0;
		}
		
		// insert Campaign (with points)
		insert camps;
		
		// assert inserted campaigns (child) points are rolled up to roadmap (parent)
		List<CW_Roadmap__c> roadmaps = [select Id, Points_Used__c from CW_Roadmap__c where Id = :roadmap.Id];
		system.assertEquals(10.0, roadmaps[0].Points_Used__c);
		
		// update Campaigns (with points)
		camps[0].Points__c = 20.0;
		camps[1].Points__c = 40.0;
		update camps;
		
		// assert updated campaigns (child) points are rolled up to roadmap (parent)
		roadmaps = [select Id, Points_Used__c from CW_Roadmap__c where Id = :roadmap.Id];
		system.assertEquals(60.0, roadmaps[0].Points_Used__c);
		
		// delete Campaign
		delete camps[0];
		
		// assert deleted campaign (child) points are not rolled up to roadmap (parent)
		roadmaps = [select Id, Points_Used__c from CW_Roadmap__c where Id = :roadmap.Id];
		system.assertEquals(40.0, roadmaps[0].Points_Used__c);
		
		// undelete Campaign
		undelete camps[0];
		
		// assert undeleted campaign (child) points are included in roll up to roadmap (parent)
		roadmaps = [select Id, Points_Used__c from CW_Roadmap__c where Id = :roadmap.Id];
		system.assertEquals(60.0, roadmaps[0].Points_Used__c);
		
	}
	
	// test that points on Campaign (child) are rolled up to Roadmap (parent) when lookup to Roadmap is removed from a Campaign record
	@isTest static void testCampaignRollupSumOnRoadmapWhenLookupToRoadmapRemoved() {
		
		// setup data
		CW_Roadmap__c roadmap = TestDataUtil.getRoadmap();
		insert roadmap;
		
		List<CW_Campaign__c> camps = TestDataUtil.getCampaigns(2);
		for (CW_Campaign__c c :camps) {
			c.Roadmap__c = roadmap.Id;
			c.Points__c = 5.0;
		}
		
		// insert Campaign (with points)
		insert camps;
		
		// assert inserted campaigns (child) points are rolled up to roadmap (parent)
		List<CW_Roadmap__c> roadmaps = [select Id, Points_Used__c from CW_Roadmap__c where Id = :roadmap.Id];
		system.assertEquals(10.0, roadmaps[0].Points_Used__c);
		
		// update Campaign to remove lookup to Roadmap
		camps[0].Roadmap__c = null;
		update camps[0];
		
		// assert campaign (child which does not have a Roadmap) points are not rolled up to roadmap (parent)
		roadmaps = [select Id, Points_Used__c from CW_Roadmap__c where Id = :roadmap.Id];
		system.assertEquals(5.0, roadmaps[0].Points_Used__c);
		
		// update Campaign to add lookup to Roadmap
		camps[0].Roadmap__c = roadmap.Id;
		update camps[0];
		
		// assert campaign (child) points are rolled up to roadmap (parent)
		roadmaps = [select Id, Points_Used__c from CW_Roadmap__c where Id = :roadmap.Id];
		system.assertEquals(10.0, roadmaps[0].Points_Used__c);
	}
	
	@isTest static void updateChildSchedulesWithCampaignStageTest() {
		
		//setup data
		List<CW_Campaign__c> camps = TestDataUtil.getCampaigns(2);
		for (CW_Campaign__c c :camps) c.Stage__c = 'stage 1';
		
		// insert Campaign (with stage)
		insert camps;
		
		List<CW_Schedule__c> schedules = new List<CW_Schedule__c>();
		List<CW_Schedule__c> schedules1 = TestDataUtil.getSchedules(camps[0].Id, 5);
		List<CW_Schedule__c> schedules2 = TestDataUtil.getSchedules(camps[1].Id, 5);
		schedules.addAll(schedules1);
		schedules.addAll(schedules2);
		
		// insert schedules
		insert schedules;
		
		// get schedule ids
		Set<Id> scheduleIds = new Set<Id>();
		for (CW_Schedule__c s :schedules) scheduleIds.add(s.Id);
		
		// update schedules
		for (CW_Campaign__c c :camps) c.Stage__c = 'stage 2';
		update camps;
		
		// assert schedules have been updated
		List<CW_Schedule__c> updatedSchedules = [select Id, Campaign_Stage__c from CW_Schedule__c where Id in:scheduleIds];
		
		for (CW_Schedule__c s :updatedSchedules) system.assertEquals('stage 2', s.Campaign_Stage__c);
	}
	
	static testMethod void testRecurrenceType()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();	// insert with no recurrence to avoid triggers
    	insert camp;
    	camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_RECURRING;
    	
    	CW_Campaign__c campNew = camp.clone(true,true);
    	campNew.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_SINGLE;
    	
    	CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
    	insert sch;
    	
    	Test.startTest();
    	
    	CW_CampaignTriggerHandler cth = new CW_CampaignTriggerHandler(true);
    	cth.cascadeDeleteSchedulesOnUpdate(new List<CW_Campaign__c>{campNew}, new Map<Id,CW_Campaign__c>(new List<CW_Campaign__c>{camp}));
    	
    	Test.stopTest();
    	
    	// assert that new schdule was created and old one deleted
    	system.assertEquals(1,[select count() from CW_Schedule__c where id != :sch.id]);
    	system.assertEquals(0,[select count() from CW_Schedule__c where id = :sch.id]);
	}
	
	static testMethod void testUpdateCampaignStageWhenBriefIsRejectedOrRecalled()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();	// insert with no recurrence to avoid triggers
    	camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_RECURRING;
    	camp.Brief_Approval_Status__c = 'In Approval';
    	insert camp;
    	
    	Test.startTest();
    	camp.Brief_Approval_Status__c = 'Rejected';
    	update camp;
    	Test.stopTest();
    	system.assertEquals('Draft',[Select Stage__c from CW_Campaign__c where Id=:camp.Id].Stage__c);
    	
    	camp.Brief_Approval_Status__c = 'In Approval';
    	camp.Cost_Approval_Status__c = 'Approved';
    	camp.Roadmap_Approval_Status__c = 'Approved';
    	update camp;
    	
    	camp.Brief_Approval_Status__c = 'Rejected';
    	update camp;
    	system.assertEquals('Roadmap Approved',[Select Stage__c from CW_Campaign__c where Id=:camp.Id].Stage__c);
    	
    	//recall brief for an urgent campaign -> camp stage should revert to draft
    	camp.Brief_Approval_Status__c = 'In Approval';
    	camp.Roadmap_Approval_Status__c = 'Not Submitted';
    	update camp;
    	
    	camp.Brief_Approval_Status__c = 'Not Submitted';
    	update camp;
    	system.assertEquals('Draft',[Select Stage__c from CW_Campaign__c where Id=:camp.Id].Stage__c);
    	//recall the brief when roadmap is approved -> camp stage should revert to roadmap approved
    	camp.Brief_Approval_Status__c = 'In Approval';
    	camp.Roadmap_Approval_Status__c = 'Approved';
    	update camp;
    	
    	camp.Brief_Approval_Status__c = 'Not Submitted';
    	update camp;
    	system.assertEquals('Roadmap Approved',[Select Stage__c from CW_Campaign__c where Id=:camp.Id].Stage__c);
	}
	
	//test if campaign roadmap can be removed from the campaign if roadmap is in approval or already approved
	static testMethod void testRemoveCampaignRoadmapIfStageApprovedOrInApproval()
	{
		//create new roadmap
		CW_Roadmap__c roadmap = TestDataUtil.getRoadmap();
		insert roadmap;
		
		//create new campaign and link it to the roadmap
		CW_Campaign__c camp = TestDataUtil.createCampaign();
    	camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_RECURRING;
    	camp.Roadmap__c = roadmap.Id;
    	insert camp;
    	
    	//approve roadmap
    	roadmap.Approval_Status__c = 'Approved';
    	update roadmap;
    	
    	//try to remove roadmap from campaign
    	Test.startTest();
    	camp.Roadmap__c = null;
    	try 
    		{
    			update camp;
    		}
			catch (Exception e)
			{
				//return true if error message is displayed when trying to remove the roadmap from a campaign when roadmap approval status is approved or in approval 
				Boolean expectedExceptionThrown =  e.getMessage().contains(ConstantUtil.REMOVE_ROADMAP_ERROR) ? true : false;
				//error message should be dispalyed stoping the suer saving the campaign
				System.AssertEquals(expectedExceptionThrown, true);
			}
    	
    	Test.stopTest();
	}
	
	//stop user update campaign points if roadmap was approved or is in approval
	static testMethod void testChangePointsWhileRoadmapInApprovalOrApproved()
	{	
		//create new roadmap
		CW_Roadmap__c roadmap = TestDataUtil.getRoadmap();
		insert roadmap;
		
		//create new campaign and link it to the roadmap
		CW_Campaign__c camp = TestDataUtil.createCampaign();
    	camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_RECURRING;
    	camp.Roadmap__c = roadmap.Id;
    	camp.Points__c = 30;
    	insert camp;
    	
    	//approve roadmap
    	roadmap.Approval_Status__c = 'Approved';
    	update roadmap;
    	
    	//try to update points
    	Test.startTest();
    	try 
    		{
    			camp.Points__c = 35;
    			update camp;
    		}
			catch (Exception e)
			{
				//return true if error message is displayed when trying to remove the roadmap from a campaign when roadmap approval status is approved or in approval 
				Boolean expectedExceptionThrown =  e.getMessage().contains(ConstantUtil.POINTS_CANNOT_BE_UPDATED) ? true : false;
				//error message should be dispalyed stoping the suer saving the campaign
				System.AssertEquals(expectedExceptionThrown, true);
			}
    	
    	Test.stopTest();
	}
	
}