/**
* File Name   :    CW_ScheduleDetailsControllerTest.cls
* Description :    Page for creating, editing and deleting schedules
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 29/05/2014 Klea Kolaric	Intial
*
*/
@isTest
public class CW_ScheduleDetailsControllerTest {
	
	private static testMethod void quickRun()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_RECURRING;
    	insert camp;
    	
    	CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
    	insert sch;
    	
		Test.setCurrentPage(Page.CW_Assets);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		 
		Test.startTest();
		 
		CW_ScheduleDetailsController sdc = new CW_ScheduleDetailsController();
		system.assertEquals(1,sdc.schedules.size());
		system.assert(sdc.getShowInlineEditButton());
		 
		sdc.addNewSchedule();
		system.assert(sdc.getIsAddMode());
		sdc.schedules.get(1).Start_Date__c = Date.today().addDays(1);
		sdc.schedules.get(1).End_Date__c = Date.today().addDays(2);
		sdc.schFields = new List<Schema.FieldSetMember>();	// to avoid required fields
		sdc.saveEdit();
		system.assertEquals(2,sdc.schedules.size());
		 
		sdc.inlineEdit();
		system.assert(!sdc.getIsAddMode());
		sdc.schedules.get(1).Start_Date__c = Date.today();
		sdc.schFields = new List<Schema.FieldSetMember>();	// to avoid required fields
		sdc.saveEdit();
		system.assertEquals(Date.today()+1,sdc.schedules.get(1).Start_Date__c);
		 
		sdc.deleteSchId = sdc.schedules.get(1).id;
		sdc.deleteSch();
		system.assertEquals(1,sdc.schedules.size());
		 
		sdc.addNewSchedule();
		sdc.cancelEdit();
		system.assertEquals(1,sdc.schedules.size());
		sdc.inlineEdit();
		sdc.cancelEdit();
		 
		Test.stopTest();
	}
	
	private static testMethod void testGenerateSchedules1()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_RECURRING;
		camp.Campaign_Start_Date__c = Date.Today().addMonths(1);
		camp.Campaign_End_Date__c = Date.Today().addMonths(7);
    	insert camp;
    	
    	Test.setCurrentPage(Page.CW_Assets);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		Test.startTest();
		
		CW_ScheduleDetailsController sdc = new CW_ScheduleDetailsController();
		
		sdc.dummySchedule.Start_Date__c = camp.Campaign_Start_Date__c;
		sdc.dummySchedule.End_Date__c = camp.Campaign_End_Date__c.addDays(-7);
		sdc.lengthInDaysStr = '7';
		sdc.numOfPeriodsStr = '20';
		sdc.period = sdc.getPeriodOptions().get(0).getValue();	// Days
		sdc.generateSchedules();
		system.assert(!sdc.schedules.isEmpty());
		Id firstId = sdc.schedules.get(0).id;	// will use this to assert deletion
		
		sdc.dummySchedule.Start_Date__c = camp.Campaign_Start_Date__c.addDays(3);
		sdc.dummySchedule.End_Date__c = camp.Campaign_End_Date__c;
		sdc.lengthInDaysStr = '10';
		sdc.numOfPeriodsStr = '2';
		sdc.period = sdc.getPeriodOptions().get(1).getValue();	// Weeks
		sdc.generateSchedules();
		system.assert(!sdc.schedules.isEmpty());
		system.assertNotEquals(firstId,sdc.schedules.get(0).id);	// old schedules deleted
		firstId = sdc.schedules.get(0).id;
		
		sdc.dummySchedule.Start_Date__c = camp.Campaign_Start_Date__c;
		sdc.dummySchedule.End_Date__c = camp.Campaign_End_Date__c;
		sdc.lengthInDaysStr = '7';
		sdc.numOfPeriodsStr = '2';
		sdc.period = sdc.getPeriodOptions().get(2).getValue();	// Months
		sdc.generateSchedules();
		system.assert(!sdc.schedules.isEmpty());
		system.assertNotEquals(firstId,sdc.schedules.get(0).id);	// old schedules deleted
		
		Test.stopTest();
	}
	
	private static testMethod void testGenerateSchedules2()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_RECURRING;
		Integer nextYear = Date.Today().addYears(1).year();
		camp.Campaign_Start_Date__c = Date.newInstance(nextYear,6,2);	// start June 2nd
		camp.Campaign_End_Date__c = Date.newInstance(nextYear,7,30);	// end July 30th
    	insert camp;
    	
    	CW_Schedule__c sch = TestDataUtil.createSchedule(camp);	// dummy schedule to test deletion
    	sch.Start_Date__c = camp.Campaign_Start_Date__c;
    	sch.End_Date__c = camp.Campaign_End_Date__c;
    	sch.Evaluation_Start_Date__c = sch.Start_Date__c;
    	sch.Evaluation_End_Date__c = sch.End_Date__c.addDays(ConstantUtil.EVALUATION_DATE_OFFSET);
    	insert sch;
    	
    	Test.setCurrentPage(Page.CW_Assets);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		Test.startTest();
		
		CW_ScheduleDetailsController sdc = new CW_ScheduleDetailsController();
		
		sdc.dummySchedule.Start_Date__c = camp.Campaign_Start_Date__c;
		sdc.dummySchedule.End_Date__c = camp.Campaign_End_Date__c;
		sdc.lengthInDaysStr = '7';
		sdc.numOfPeriodsStr = '2';
		sdc.period = sdc.getPeriodOptions().get(1).getValue();	// Weeks
		sdc.generateSchedules();
		
		Test.stopTest();
		
		system.assertEquals(0,[select count() from CW_Schedule__c where id = :sch.id]);
		system.assertEquals(5,sdc.schedules.size());
		system.assertEquals(Date.newInstance(nextYear,6,2),sdc.schedules.get(0).Start_Date__c);	// from June 2nd
		system.assertEquals(Date.newInstance(nextYear,6,8),sdc.schedules.get(0).End_Date__c);	// to June 8th
		system.assertEquals(Date.newInstance(nextYear,6,16),sdc.schedules.get(1).Start_Date__c);	// from June 16th
		system.assertEquals(Date.newInstance(nextYear,6,22),sdc.schedules.get(1).End_Date__c);	// to June 22nd
		system.assertEquals(Date.newInstance(nextYear,6,30),sdc.schedules.get(2).Start_Date__c);	// from June 30th
		system.assertEquals(Date.newInstance(nextYear,7,6),sdc.schedules.get(2).End_Date__c);	// to July 6th
		system.assertEquals(Date.newInstance(nextYear,7,14),sdc.schedules.get(3).Start_Date__c);	// from July 14th
		system.assertEquals(Date.newInstance(nextYear,7,20),sdc.schedules.get(3).End_Date__c);	// to July 20th
		system.assertEquals(Date.newInstance(nextYear,7,28),sdc.schedules.get(4).Start_Date__c);	// from July 28th
		system.assertEquals(Date.newInstance(nextYear,7,30),sdc.schedules.get(4).End_Date__c);	// to July 30th
	}
	
	private static testMethod void testGenerateSchedules3()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_LIFECYCLE;
		Integer nextYear = Date.Today().addYears(1).year();
		camp.Campaign_Start_Date__c = Date.newInstance(nextYear,6,7);	// start June 7th
		camp.Campaign_End_Date__c = Date.newInstance(nextYear,11,5);	// end November 5th
    	insert camp;
    	
    	CW_Schedule__c sch = TestDataUtil.createSchedule(camp);	// dummy schedule to test deletion
    	sch.Start_Date__c = camp.Campaign_Start_Date__c;
    	sch.End_Date__c = camp.Campaign_End_Date__c;
    	sch.Evaluation_Start_Date__c = sch.Start_Date__c;
    	sch.Evaluation_End_Date__c = sch.End_Date__c.addDays(ConstantUtil.EVALUATION_DATE_OFFSET);
    	insert sch;
    	
    	Test.setCurrentPage(Page.CW_Assets);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		Test.startTest();
		
		CW_ScheduleDetailsController sdc = new CW_ScheduleDetailsController();
		
		sdc.dummySchedule.Start_Date__c = camp.Campaign_Start_Date__c;
		sdc.dummySchedule.End_Date__c = camp.Campaign_End_Date__c.addDays(-1);	// November 4th
		system.assert(sdc.getIsLifecycle());
		sdc.generateSchedules();
		
		Test.stopTest();
		
		system.assertEquals(0,[select count() from CW_Schedule__c where id = :sch.id]);
		system.assertEquals(5,sdc.schedules.size());
		system.assertEquals(Date.newInstance(nextYear,6,7),sdc.schedules.get(0).Start_Date__c);	// from June 7th
		system.assertEquals(Date.newInstance(nextYear,7,6),sdc.schedules.get(0).End_Date__c);	// to July 6th
		system.assertEquals(Date.newInstance(nextYear,7,7),sdc.schedules.get(1).Start_Date__c);	// from July 7th
		system.assertEquals(Date.newInstance(nextYear,8,6),sdc.schedules.get(1).End_Date__c);	// to August 6th
		system.assertEquals(Date.newInstance(nextYear,8,7),sdc.schedules.get(2).Start_Date__c);	// from August 7th
		system.assertEquals(Date.newInstance(nextYear,9,6),sdc.schedules.get(2).End_Date__c);	// to September 6th
		system.assertEquals(Date.newInstance(nextYear,9,7),sdc.schedules.get(3).Start_Date__c);	// from Septemebr 7th
		system.assertEquals(Date.newInstance(nextYear,10,6),sdc.schedules.get(3).End_Date__c);	// to October 6th
		system.assertEquals(Date.newInstance(nextYear,10,7),sdc.schedules.get(4).Start_Date__c);	// from October 7th
		system.assertEquals(Date.newInstance(nextYear,11,4),sdc.schedules.get(4).End_Date__c);	// to November 4th
	}
	
	private static testMethod void testGenerateSchedulesFail()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_RECURRING;
		camp.Campaign_Start_Date__c = Date.Today().addMonths(1);
		camp.Campaign_End_Date__c = Date.Today().addMonths(7);
    	insert camp;
    	
    	Test.setCurrentPage(Page.CW_Assets);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		Test.startTest();
		
		CW_ScheduleDetailsController sdc = new CW_ScheduleDetailsController();
		
		sdc.dummySchedule.Start_Date__c = camp.Campaign_Start_Date__c;
		sdc.dummySchedule.End_Date__c = camp.Campaign_End_Date__c.addDays(-7);
		sdc.lengthInDaysStr = '-7';		// negative integer
		sdc.numOfPeriodsStr = '20';
		sdc.period = sdc.getPeriodOptions().get(0).getValue();	// Days
		sdc.generateSchedules();
		system.assertEquals(0, sdc.schedules.size());
		
		sdc.lengthInDaysStr = '7';
		sdc.numOfPeriodsStr = '0';	// 0 not allowed
		sdc.period = sdc.getPeriodOptions().get(0).getValue();	// Days
		sdc.generateSchedules();
		system.assertEquals(0, sdc.schedules.size());
		
		sdc.lengthInDaysStr = 'abcd';	// invalid integer
		sdc.numOfPeriodsStr = '20';
		sdc.period = sdc.getPeriodOptions().get(0).getValue();	// Days
		sdc.generateSchedules();
		system.assertEquals(0, sdc.schedules.size());
		
		sdc.lengthInDaysStr = '7';	// invalid integer
		sdc.numOfPeriodsStr = '20';
		sdc.period = sdc.getPeriodOptions().get(0).getValue();	// Days
		sdc.generateSchedules();
		system.assertNotEquals(0, sdc.schedules.size());
		
		Test.stopTest();
	}

}