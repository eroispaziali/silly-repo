/**
* File Name   :    CW_AudienceGroupCompControlerTest.cls
* Description :   
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 03/04/2014 Cristina P		Initial
*/
@isTest
public with sharing class CW_AudienceGroupCompControlerTest {
	
	public static CW_Campaign_Navigation_Settings__c 	cns1;
	public static CW_Campaign_Navigation_Settings__c 	cns2;
	

	
	public static void initCustomSettings()
	{
		cns1 = TestDataUtil.createCampaignNavigationSettings(Page.CW_Campaign_Information,1,false);
    	cns2 = TestDataUtil.createCampaignNavigationSettings(Page.CW_Audience,2,false);
    	insert new List<CW_Campaign_Navigation_Settings__c>{cns1,cns2};
    	
    	CW_CampaignListSettingHelper.getIntegerValue(ConstantUtil.AUDIENCE_GROUP_PAGE_SIZE,5);
	}
	
	static testMethod void standardSetControllerTest() 
	{
        initCustomSettings();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        List<CW_Audience_Group__c> listGroups = TestDataUtil.createAudienceGroups(camp.Id,15);
        insert listGroups;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	Test.startTest();
    	
		system.runAs(thisUser)
	    {  
	    	
			List<sObject> RecList= new List<sObject>();
			
			//Initialization 
	    	CW_AudienceGroupCompControler compCtrl= new CW_AudienceGroupCompControler();
	    	system.assertEquals(0     ,compCtrl.totalSize);
	    	compCtrl.getHasPrevious();
	    	compCtrl.getHasNext();
	    	compCtrl.getPageNumber();
	    	compCtrl.getTotalPages();
	    	compCtrl.getPageNumber();
	    	CompCtrl.campId=camp.Id;
			compCtrl.audienceGroups=RecList;
			compCtrl.isReadOnly=false;
			
			//Lest chech if is All ok set
			system.assertEquals(15    , RecList.Size());
			system.assertEquals(5     ,compCtrl.campGroups.Size());
			system.assertEquals(true  ,compCtrl.getOutputMode());
			system.assertEquals(false ,compCtrl.getEditDisabled() );
			system.assertEquals(true  ,compCtrl.getDeleteDisabled());
			system.assertEquals(3     ,compCtrl.getTotalPages());
			
			//Edit new Reords
			CompCtrl.addGroup();
			system.assertEquals(false ,compCtrl.getOutputMode());
			system.assertEquals(true  ,compCtrl.getNewRecMode());
			system.assertEquals(true  ,compCtrl.getInputMode());
			
			compCtrl.newRec.Name='Test_Name';
			compCtrl.newRec.Description__c = 'Test Descr';
			compCtrl.newRec.Is_Control_Group__c = false;
			compCtrl.newRec.Control_Group__c=listGroups[0].Id;
			compCtrl.SaveNewRecord();
			
			system.assertEquals(false ,ApexPages.hasMessages());
			system.assertEquals(16    ,RecList.Size());
			system.assertEquals(5     ,compCtrl.campGroups.Size());
			system.assertEquals(true  ,compCtrl.getOutputMode());
			system.assertEquals(16    ,compCtrl.totalSize);
			system.assertEquals(4     ,compCtrl.getTotalPages());
			CompCtrl.addGroup();
			compCtrl.newRec.Name='Test_Name';
			compCtrl.newRec.Description__c = 'Test Descr';

			compCtrl.SaveNewRecord();
			//Chech Error Messages
			system.assertEquals(true  ,ApexPages.hasMessages());
			ApexPages.getMessages().clear();
			compCtrl.newRec.Name='Test_Name2';
			compCtrl.newRec.Is_Control_Group__c = false;
			compCtrl.newRec.Control_Group__c=listGroups[1].Id;
			compCtrl.Cancel();
			
			compCtrl.selectAll = true;
			compCtrl.selectDeselectAllItems();
			system.assertEquals(5     ,compCtrl.getSelectedCount());
			system.assertEquals(false ,compCtrl.getDeleteDisabled());
			
			compCtrl.selectAll = false;
			compCtrl.selectDeselectAllItems();
			system.assertEquals(0     ,compCtrl.getSelectedCount());
			system.assertEquals(true  ,compCtrl.getDeleteDisabled());
			
			compCtrl.selectedGroupIds.Add(listGroups[3].Id);
			compCtrl.selectedGroupIds.Add(listGroups[4].Id);
			system.assertEquals(false  ,compCtrl.getDeleteDisabled());
			compCtrl.getDeleteMessage();
			compCtrl.deleteGroups();
			system.assertEquals(14    , RecList.Size());
			system.assertEquals(5     ,compCtrl.campGroups.Size());
			system.assertEquals(true  ,compCtrl.getOutputMode());
			//Tray to delete used control groups
			compCtrl.selectedGroupIds.Add(listGroups[0].Id);
			compCtrl.selectedGroupIds.Add(listGroups[1].Id);
			compCtrl.selectAll = false;
			compCtrl.selectDeselectAllItems();
			
			compCtrl.getDeleteMessage();
			compCtrl.deleteGroups();
			
			//check for errors
			system.assertEquals(true  ,ApexPages.hasMessages());
			system.assertEquals(14    , RecList.Size());
			
			compCtrl.contextItem = listGroups[4].Id;
			compCtrl.doSelectItem();
			system.assertEquals(1     ,compCtrl.getSelectedCount());
			compCtrl.doDeselectItem();
			system.assertEquals(0     ,compCtrl.getSelectedCount());
			
			compCtrl.last();
			system.assertEquals(4     ,compCtrl.campGroups.Size());
			
			compCtrl.first();
			system.assertEquals(5     ,compCtrl.campGroups.Size());
			
			compCtrl.doNext();
			system.assertEquals(2     ,compCtrl.getPageNumber());
			system.assertEquals(true  ,compCtrl.getHasPrevious());
			system.assertEquals(true  ,compCtrl.getHasNext());

			
			compCtrl.doPrevious();
			system.assertEquals(false  ,compCtrl.getHasPrevious());
			system.assertEquals(true   ,compCtrl.getHasNext());

			compCtrl.editGroups();
			system.assertEquals(false ,compCtrl.getOutputMode());
			system.assertEquals(false ,compCtrl.savedByParent);
			compCtrl.savedByParent =true;
			system.assertEquals(true  ,compCtrl.getOutputMode());
			compCtrl.Cancel();
			system.assertEquals(true  ,compCtrl.getOutputMode());
	    }
	}
	static testMethod void WraperClasssControllerTest() 
	{
        initCustomSettings();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        List<CW_Audience_Group__c> listGroups = TestDataUtil.createAudienceGroups(camp.Id,5);
        insert listGroups;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	Test.startTest();
    	
		system.runAs(thisUser)
	    {  

			List<sObject> RecList= new List<sObject>();
			
			//Initialization 
	    	CW_AudienceGroupCompControler compCtrl= new CW_AudienceGroupCompControler();
	    	CompCtrl.campId=camp.Id;
			compCtrl.audienceGroups=RecList;
			compCtrl.isReadOnly=false;
			
			CW_AudienceGroupCompControler.audienceGroupWrapper rec=compCtrl.campGroups[1];
			
			system.assertEquals(0     , rec.members);
			system.assertEquals(false , rec.getIsUsed());
			system.assertEquals(true , rec.isControlGroup);
			rec.isControlGroup=false;
			rec.aGroup.Control_Group__c=listGroups[0].Id;
			system.assertEquals(false , rec.isControlGroup);
			rec.isControlGroup=true;
			system.assertEquals(true , rec.isControlGroup);
			system.assertEquals(null , rec.aGroup.Control_Group__c);
			rec.isControlGroup=false;
	    	system.assertEquals(listGroups[0].Id , rec.aGroup.Control_Group__c);
	    	
	    }
	}

	static testMethod void editSaveGroupsTest() 
    {
        initCustomSettings();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        camp.Recurrence_Type__c = 'Single';
        insert camp;
        
        CW_Schedule__c sche = new CW_Schedule__c();
        sche.Marketing_Campaign__c = camp.Id;
		sche.Start_Date__c = camp.Campaign_Start_Date__c;
		sche.End_Date__c = camp.Campaign_Start_Date__c;
		sche.Evaluation_Start_Date__c = camp.Campaign_Start_Date__c;
		sche.Evaluation_End_Date__c = camp.Campaign_Start_Date__c.addDays(60);
		insert sche;
        
        List<CW_Audience_Group__c> listGroups = TestDataUtil.createAudienceGroups(camp.Id,2);
        listGroups[0].Name = 'My Control Group';
        listGroups[1].Name = 'My Target Group';
        insert listGroups;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	Test.startTest();
    	
		System.runAs(thisUser)
	    {  
	    	List<sObject> RecList= new List<sObject>();
	    	
			CW_AudienceGroupCompControler agCtrl = new CW_AudienceGroupCompControler();
			agCtrl.campId=camp.Id;
			agCtrl.audienceGroups=RecList;
			agCtrl.isReadOnly=false;
			
			CW_AudienceGroupCompControler.audienceGroupWrapper rec=agCtrl.campGroups[0];
			agCtrl.editGroups();
			
			rec.aGroup.Description__c = 'Update Description';
			rec.aGroup.Name = 'Update my group name';
			rec.aGroup.Is_Control_Group__c = true;
			agCtrl.saveAllGroups();
			
			listGroups = [SELECT Id,Name,Description__c
						  FROM CW_Audience_Group__c
						  WHERE Id = : rec.aGroup.Id];
						  
			system.assertEquals(rec.aGroup.Description__c,listGroups[0].Description__c);
			system.assertEquals(rec.aGroup.Name,listGroups[0].Name);
			
			CW_AudienceGroupCompControler.audienceGroupWrapper tgg=agCtrl.campGroups[1];
			agCtrl.editGroups();
			
			tgg.aGroup.Is_Control_Group__c = false;
			tgg.aGroup.Control_Group__c=rec.aGroup.Id;
			agCtrl.saveAllGroups();
			
			agCtrl.editGroups();
			rec.aGroup.Is_Control_Group__c = false;
			agCtrl.saveAllGroups();
			
			listGroups = [SELECT Id,Name,Description__c,Control_Group__c, Campaign__c
						  FROM CW_Audience_Group__c
						  WHERE Campaign__c = : camp.Id];
					  
			system.assertEquals(null,listGroups[1].Control_Group__c,'Control group should be removed since was changed to target group');
	    }
	    Test.stopTest();
    }
}