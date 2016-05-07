/**
* File Name   :    CW_AudienceGroupTriggerHandlerTest.cls
* Description :    D-106803o
*                 
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 24/04/2014 Alex  Panka		Initial
 */
 
@isTest
public with sharing class CW_AudienceGroupTriggerHandlerTest {
	
	static testMethod void ValidationRuleTest() {
		
		CW_Campaign__c camp = TestDataUtil.createCampaign();
      insert camp;
      //We muset use single call for testDataUtil for uniq names
      List<CW_Audience_Group__c> listAllGrps  =TestDataUtil.createAudienceGroups(camp.Id,6);
      
		List<CW_Audience_Group__c> listControlGrps  = new List <CW_Audience_Group__c>();
		List<CW_Audience_Group__c> listControlGrps2 = new List <CW_Audience_Group__c>();
		List<CW_Audience_Group__c> listNormalGrps   = new List <CW_Audience_Group__c>();
		listControlGrps.Add(listAllGrps.get(0));
		listControlGrps.Add(listAllGrps.get(1));
		listControlGrps2.Add(listAllGrps.get(2));
		listControlGrps2.Add(listAllGrps.get(3));
		listNormalGrps.Add(listAllGrps.get(4));
		listNormalGrps.Add(listAllGrps.get(5));
		
		insert listControlGrps;
		insert listControlGrps2;
		


		for(integer i=0;i<2;i++){
			listNormalGrps.get(i).Is_Control_Group__c=false;
			listNormalGrps.get(i).Control_Group__c=listControlGrps.get(i).id;
		}
		insert listNormalGrps;
	   //Test if we can chage witout ref
	   for(CW_Audience_Group__c Rec :listControlGrps2){
	   	Rec.Is_Control_Group__c=false;
	   }
	   update listControlGrps2;
	   for(CW_Audience_Group__c Rec :listControlGrps2){
	   	Rec.Is_Control_Group__c=true;
	   }
		update listControlGrps2;
	   
	   try{
	   	insert listAllGrps;
	   	System.assert(false,'Validation of Unique Name on Audience control group not rise error');
	   }
	   catch(Exception E){}	 
	   
	   
	}
	
	static testMethod void controlGroupTest()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
      	insert camp;
        
		CW_Audience_Group__c controlGroup = TestDataUtil.createAudienceGroup(camp.Id);
		controlGroup.Name = 'Control1';
		controlGroup.Is_Control_Group__c = true;
		insert controlGroup;
		CW_Audience_Group__c targetGroup = TestDataUtil.createAudienceGroup(camp.Id);
		targetGroup.Name = 'Target1';
		targetGroup.Is_Control_Group__c = false;
		targetGroup.Control_Group__c = controlGroup.Id;
		insert targetGroup;
		
		Test.startTest();
		targetGroup.Is_Control_Group__c = true;
		update targetGroup;
		Test.stopTest();
		
		CW_Audience_Group__c reselectTarget = [select Is_Control_Group__c, Control_Group__c 
												from CW_Audience_Group__c where id = :targetGroup.Id];
		System.assert(reselectTarget.Is_Control_Group__c);	// group is now conrol group
		System.assertEquals(reselectTarget.Control_Group__c,null);	// no longer has control group
	}
	
	static testMethod void testCreateAGS()
	{
		List<CW_Schedule__c> schs = setupSchedules();	// insert later
		
		Test.startTest();
		
		// create groups with no schedules in order to avoid trigger creation
		CW_Audience_Group__c agc = TestDataUtil.createAudienceGroup(schs.get(0).Marketing_Campaign__c);
		agc.Name = 'test control';
		agc.Is_Control_Group__c = true;	// control group
		agc.Unica_Id__c = '111222';
		insert agc;
		
		CW_Audience_Group__c agt = TestDataUtil.createAudienceGroup(schs.get(0).Marketing_Campaign__c);
		agt.Name = 'test target';
		agt.Is_Control_Group__c = false;	// control group
		agt.Control_Group__c = agc.id;
		agt.Unica_Id__c = '222333';
		insert agt;
		
		insert schs;	// create schedules
		
		Test.stopTest();
		
		List<CW_Audience_Group_Schedule__c> agsC = 
			[select id, Schedule__c, is_Control_Group__c from CW_Audience_Group_Schedule__c 
				where Audience_Group__c = :agc.id order by Schedule__r.Start_Date__c asc];
		List<CW_Audience_Group_Schedule__c> agsT = 
			[select id, Schedule__c, is_Control_Group__c, Control_Group_Schedule__c from CW_Audience_Group_Schedule__c 
				where Audience_Group__c = :agt.id order by Schedule__r.Start_Date__c asc];
				
		system.assertEquals(5,agsC.size());
		system.assertEquals(5,agsT.size());
		
		for(Integer i=0; i<5; i++)
		{
			system.assert(agsC.get(i).is_Control_Group__c);
			system.assert(!agsT.get(i).is_Control_Group__c);
			system.assertEquals(schs.get(i).id,agsC.get(i).Schedule__c);
			system.assertEquals(schs.get(i).id,agsT.get(i).Schedule__c);
			system.assertEquals(agsC.get(i).id,agsT.get(i).Control_Group_Schedule__c);
		}
		
	}
	
	static testMethod void testUpdateAGS()
	{
		List<CW_Schedule__c> schs = setupSchedules();	// insert later
		
		Test.startTest();
		
		// create groups with no schedules in order to avoid trigger creation
		CW_Audience_Group__c agc = TestDataUtil.createAudienceGroup(schs.get(0).Marketing_Campaign__c);
		agc.Name = 'test control';
		agc.Is_Control_Group__c = true;	// control group
		agc.Unica_Id__c = '111222';
		insert agc;
		
		CW_Audience_Group__c agt = TestDataUtil.createAudienceGroup(schs.get(0).Marketing_Campaign__c);
		agt.Name = 'test target';
		agt.Is_Control_Group__c = false;	// control group
		agt.Control_Group__c = null;
		agt.Unica_Id__c = '222333';
		insert agt;
		
		CW_Audience_Group__c agtNew = agt.clone(true,true);
		agtNew.Control_Group__c = agc.id;
		update agtNew;
		
		insert schs;	// create schedules
		
		Test.stopTest();
		
		List<CW_Audience_Group_Schedule__c> agsC = 
			[select id, Schedule__c, is_Control_Group__c from CW_Audience_Group_Schedule__c 
				where Audience_Group__c = :agc.id order by Schedule__r.Start_Date__c asc];
		List<CW_Audience_Group_Schedule__c> agsT = 
			[select id, Schedule__c, is_Control_Group__c, Control_Group_Schedule__c from CW_Audience_Group_Schedule__c 
				where Audience_Group__c = :agt.id order by Schedule__r.Start_Date__c asc];
				
		system.assertEquals(5,agsC.size());
		system.assertEquals(5,agsT.size());
		
		for(Integer i=0; i<5; i++)
		{
			system.assert(agsC.get(i).is_Control_Group__c);
			system.assert(!agsT.get(i).is_Control_Group__c);
			system.assertEquals(schs.get(i).id,agsC.get(i).Schedule__c);
			system.assertEquals(schs.get(i).id,agsT.get(i).Schedule__c);
			system.assertEquals(agsC.get(i).id,agsT.get(i).Control_Group_Schedule__c);
		}
		
	}
	
	static testMethod void testDeleteAGS()
	{
		List<CW_Schedule__c> schs = setupSchedules();
		insert schs;
		
		Test.startTest();
		
		CW_Audience_Group__c agt = TestDataUtil.createAudienceGroup(schs.get(0).Marketing_Campaign__c);
		agt.Name = 'test target';
		agt.Control_Group__c = null;
		agt.Unica_Id__c = '222333';
		insert agt;
		
		// 10/07/2014 CY - commented lines below, not sure why trigger handler methods are being invoked directly!?
		//CW_AudienceGroupTriggerHandler.createAGS(new Map<Id,CW_Audience_Group__c>(new List<CW_Audience_Group__c>{agt}));
		//CW_AudienceGroupTriggerHandler.cascadeDelete(new List<CW_Audience_Group__c>{agt});
		
		delete agt;
		
		Test.stopTest();
		
		List<CW_Audience_Group_Schedule__c> agsT = 
			[select id, Schedule__c, is_Control_Group__c, Control_Group_Schedule__c from CW_Audience_Group_Schedule__c 
				where Audience_Group__c = :agt.id order by Schedule__r.Start_Date__c asc];
				
		system.assertEquals(0,agsT.size());
	}
	
	/*** DATA SETUP ***/
	
	static testMethod List<CW_Schedule__c> setupSchedules()
	{
		Integer nextYear = Date.today().addYears(1).year();	// campaign will run five times, MAY-OCT, from 3rd to 10th
		
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Recurrence_Type__c = ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_RECURRING;
		camp.Campaign_Start_Date__c = Date.newInstance(nextYear,5,1);
		camp.Campaign_End_Date__c = Date.newInstance(nextYear,10,1);
    	insert camp;
    	
		List<CW_Schedule__c> schList = new List<CW_Schedule__c>();
		for(Integer i=5; i<10; i++)
		{
			CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
			sch.Start_Date__c = Date.newInstance(nextYear,i,3);
			sch.End_Date__c = Date.newInstance(nextYear,i,10);
			sch.Evaluation_Start_Date__c = sch.Start_Date__c;
			sch.Evaluation_End_Date__c = sch.End_Date__c.addDays(ConstantUtil.EVALUATION_DATE_OFFSET);
			schList.add(sch);
		}
		
		return schList;
	}
		
}