/**
* File Name   :    CW_ScheduleTriggerHandler.cls
* Description :    Triiger supporter -> calculation of sumaty fields ( Max(date))
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 01/05/2014 Alex Panka	  Intial -
*/
@isTest
public with sharing class CW_ScheduleTriggerHandlerTest {
	
	
	static testMethod void  initUsersAndCustomSettings()	{
		
		Date d0= date.newInstance(1900, 01,01);
		// schedule is created with evaluation start date (Paramdate -2 days) and evaluation end date (Param +2 days)
		Date dt= date.today().addDays(1);
		Date d1= date.today().addDays(2);
		Date d2= date.today().addDays(3);
		Date d4= date.today().addDays(4);
		CW_Campaign__c TestRec;
		
		List<CW_Campaign__c> camps = TestDataUtil.getCampaigns(3);
		for (CW_Campaign__c c :camps) c.Recurrence_Type__c = 'Recurring';
		insert camps;
		
		List<CW_Schedule__c> schedules = new List<CW_Schedule__c>();
		
		// schedule is created with evaluation start date (runBatchDate -2 days) and evaluation end date (runBatchDate +2 days)
		schedules.add( TestDataUtil.getSchedule(camps[0].Id, dt) );
		upsert schedules;
		
		TestRec=[Select Latest_Schedule_Evaluation_End_Date__c, Latest_Schedule_End_Date__c FROM CW_Campaign__c where ID=:camps[0].Id];
		System.assertEquals(d2, TestRec.Latest_Schedule_End_Date__c,'Error in calculating Latest_Schedule_End_Date__c');
		System.assertEquals(d2, TestRec.Latest_Schedule_Evaluation_End_Date__c,'Error in calculating Latest_Schedule_Evaluation_End_Date__c');
		
		// schedule is created  before first records nothing schold chaneg
		schedules.add( TestDataUtil.getSchedule(camps[0].Id, d1 ));
		
		upsert schedules;
		
		TestRec=[Select Latest_Schedule_Evaluation_End_Date__c, Latest_Schedule_End_Date__c FROM CW_Campaign__c where ID=:camps[0].Id];
		System.assertEquals(d4, TestRec.Latest_Schedule_End_Date__c,'Error in calculating Latest_Schedule_End_Date__c');
		System.assertEquals(d4, TestRec.Latest_Schedule_Evaluation_End_Date__c,'Error in calculating Latest_Schedule_Evaluation_End_Date__c');
		
		delete schedules;
		
		TestRec=[Select Latest_Schedule_Evaluation_End_Date__c, Latest_Schedule_End_Date__c FROM CW_Campaign__c where ID=:camps[0].Id];
		System.assertEquals(d0, TestRec.Latest_Schedule_End_Date__c,'Error in calculating Latest_Schedule_End_Date__c');
		System.assertEquals(d0, TestRec.Latest_Schedule_Evaluation_End_Date__c,'Error in calculating Latest_Schedule_Evaluation_End_Date__c');
		
	}
	static testMethod void scheduleForSingleCampaignType()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Recurrence_Type__c = 'Single';
		insert camp;			
		
		CW_Campaign__c updatedCamp = [SELECT Campaign_Start_Date__c,
											 Campaign_End_Date__c,
											 Latest_Schedule_Evaluation_End_Date__c, 
											 Latest_Schedule_End_Date__c 
									  FROM CW_Campaign__c WHERE ID=:camp.Id];
		
		System.assertEquals(camp.Campaign_End_Date__c, updatedCamp.Latest_Schedule_End_Date__c);
		System.assertEquals(camp.Campaign_End_Date__c+60, updatedCamp.Latest_Schedule_Evaluation_End_Date__c);
	}
	
	
	@isTest static void updateScheduleWithCampaignStageTest() {
		
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
		
		// asset schedules have campaign stage populated after insert
		List<CW_Schedule__c> insertedSchedules = [select Id, Campaign_Stage__c from CW_Schedule__c where Id in:scheduleIds];
		for (CW_Schedule__c s :insertedSchedules) system.assertEquals('stage 1', s.Campaign_Stage__c);
		
	}
	
	static testMethod void createAGStest()
	{
		
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Recurrence_Type__c = 'Recurring';
		insert camp;
		
		CW_Audience_Group__c agControl = TestDataUtil.createAudienceGroup(camp.Id);
		agControl.Name = 'ControlGroup';
		agControl.Is_Control_Group__c = true;
		insert agControl;
		
		CW_Audience_Group__c agTarget = TestDataUtil.createAudienceGroup(camp.Id);
		agTarget.Name = 'TargetGroup';
		agTarget.Control_Group__c = agControl.Id;
		insert agTarget;
		
		List<CW_Schedule__c> schedules = TestDataUtil.getSchedules(camp.Id, 2);
		// insert schedules
		insert schedules;	
		
		List<CW_Audience_Group_Schedule__c> insertedAGSControl = [SELECT Id FROM CW_Audience_Group_Schedule__c WHERE Audience_Group__c =:agControl.Id];
		system.assertEquals(2,insertedAGSControl.size());
		
		CW_Audience_Group_Schedule__c AGSControl = [SELECT Id FROM CW_Audience_Group_Schedule__c 
												    WHERE Audience_Group__c =:agControl.Id
												    AND Schedule__c = :schedules[0].Id];
		CW_Audience_Group_Schedule__c AGSTarget = [SELECT Id,Control_Group_Schedule__c 
												   FROM CW_Audience_Group_Schedule__c 
										  		   WHERE Audience_Group__c =:agTarget.Id 
										  		   AND Schedule__c = :schedules[0].Id];
		system.assertEquals(AGSControl.Id,AGSTarget.Control_Group_Schedule__c);
	}

}