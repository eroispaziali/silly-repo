/**
* File Name   :    CW_AudienceGroupControllerTest.cls
* Description :    B-110228/B-110230/B-109518
*                  CIM, BI, Marketer must be able to View,Edit,Delete audience groups 
*				   that are linked to the campaign
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 03/04/2014 Cristina P		Initial
 */
@isTest
private class CW_AudienceGroupControllerTest 
{

	public static CW_Campaign_Navigation_Settings__c 	cns1;
	public static CW_Campaign_Navigation_Settings__c 	cns2;
	
	public static CW_CampaignListSetting__c		audienceGroupPageSizeRecord;
	
	public static void initCustomSettings()
	{
		cns1 = TestDataUtil.createCampaignNavigationSettings(Page.CW_Campaign_Information,1,false);
    	cns2 = TestDataUtil.createCampaignNavigationSettings(Page.CW_Audience,2,false);
    	insert new List<CW_Campaign_Navigation_Settings__c>{cns1,cns2};
    	
    	audienceGroupPageSizeRecord = new CW_CampaignListSetting__c(Name=ConstantUtil.AUDIENCE_GROUP_PAGE_SIZE,
    											 Integer_Value__c=10);
    	insert audienceGroupPageSizeRecord;
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
    	
		System.runAs(thisUser)
	    {  
	    	audienceGroupPageSizeRecord.Integer_Value__c = 5;
			update audienceGroupPageSizeRecord;
			
	    	Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.next();
			
			Test.setCurrentPage(Page.CW_Audience);
			Apexpages.currentPage().getParameters().put('id',camp.Id);
			CW_AudienceGroupController agCtrl = new CW_AudienceGroupController();
			
			agCtrl.selectAll = true;
			agCtrl.selectDeselectAllItems();
			system.assertEquals(true,agCtrl.getHasNext());
			
			agCtrl.doNext();
			
			system.assertEquals(agCtrl.selectAll, false);
			
			system.assertEquals(true,agCtrl.getHasPrevious());
			agCtrl.doPrevious();
			
			agCtrl.contextItem = agCtrl.campGroups[0].aGroup.Id;
			agCtrl.doSelectItem();
			agCtrl.doDeselectItem();
			
			agCtrl.last();
			system.AssertEquals(agCtrl.setGroups.getRecords().size(),5);
			
			agCtrl.first();
			system.AssertEquals(agCtrl.setGroups.getRecords().size(),5);
			
			agCtrl.doNext();
			system.AssertEquals(agCtrl.hasFirstPage,true);
			system.AssertEquals(agCtrl.hasLastPage,true);
			
			agCtrl.doPrevious();
			system.AssertEquals(agCtrl.hasFirstPage,false);
			system.AssertEquals(agCtrl.hasLastPage,true);
			
	    }
	}
	
	static testMethod void editSaveGroupsTest() 
    {
        initCustomSettings();
        
        audienceGroupPageSizeRecord.Integer_Value__c = null;
		update audienceGroupPageSizeRecord;
			
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        List<CW_Audience_Group__c> listGroups = TestDataUtil.createAudienceGroups(camp.Id,5);
        insert listGroups;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	Test.startTest();
    	
		System.runAs(thisUser)
	    {  
	        Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.next();
			
			Test.setCurrentPage(Page.CW_Audience);
			Apexpages.currentPage().getParameters().put('id',camp.Id);
			CW_AudienceGroupController agCtrl = new CW_AudienceGroupController();
			
			system.AssertEquals(agCtrl.setGroups.getPageSize(),100);
        	agCtrl.getFields();
			agCtrl.editGroups();
			
			system.assertEquals(agCtrl.inputMode,true);
			
			agCtrl.cancel();
			
			system.assertEquals(agCtrl.inputMode,false);
			
			agCtrl.editGroups();
			
			agCtrl.getAudienceGroup();
			
			agCtrl.campGroups[0].aGroup.Description__c = 'Update Description';
			agCtrl.campGroups[1].aGroup.Name = 'Update Name';
			agCtrl.saveGroups();
			
			listGroups = [SELECT Id,Name,Description__c
						  FROM CW_Audience_Group__c
						  WHERE Campaign__c = : camp.Id];
						  
			system.assertEquals(listGroups[0].Description__c,'Update Description');
			system.assertEquals(listGroups[1].Name,'Update Name');
			
			system.assertEquals(0,agCtrl.campGroups[0].getNumberOfMembers());
			system.assertEquals(false,agCtrl.campGroups[0].getIsUsed());
			
			agCtrl.editGroups();
			
			agCtrl.getAudienceGroup();
			
			agCtrl.campGroups[1].aGroup.Name = 'Update Name';
			agCtrl.saveGroups();
			
			for(ApexPages.Message msg :  ApexPages.getMessages()) 
	    	{
	    		system.assertEquals(msg.getSummary(),agCtrl.campGroups[1].aGroup.Name + ConstantUtil.DUPLICATE_AUDIENCE_GROUP_NAME);
			}
			
			
	    }
	    Test.stopTest();
    }
    
    static testMethod void downloadCSVFiles() 
    {
        initCustomSettings();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        List<CW_Audience_Group__c> listGroups = TestDataUtil.createAudienceGroups(camp.Id,5);
        insert listGroups;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	Test.startTest();
    	
		System.runAs(thisUser)
	    {  
	        Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.next();
			
			Test.setCurrentPage(Page.CW_Audience);
			Apexpages.currentPage().getParameters().put('id',camp.Id);
			CW_AudienceGroupController agCtrl = new CW_AudienceGroupController();
			
			PageReference ref = new PageReference('/apex/CW_Audience_Group_Template');
			ref.getParameters().put('id',camp.Id);
			agCtrl.downloadAudienceGroupTemplate();
			
			ref = new PageReference('/apex/CW_Audience_Group_Members_Template');
			ref.getParameters().put('id',camp.Id);
			agCtrl.downloadGroupMembersTemplate();
	    }
	    Test.stopTest();
    }
    
    static testMethod void changeTargetGroupToControlGroup() 
    {
        initCustomSettings();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        List<CW_Audience_Group__c> listGroups = TestDataUtil.createAudienceGroups(camp.Id,5);
        listGroups[0].Is_Control_Group__c = false;
        listGroups[0].Control_Group__c = listGroups[1].Id;
        listGroups[2].Is_Control_Group__c = false;
        listGroups[2].Control_Group__c = listGroups[1].Id;
        insert listGroups;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	Test.startTest();
    	
		System.runAs(thisUser)
	    {  
	        Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.next();
			
			Test.setCurrentPage(Page.CW_Audience);
			Apexpages.currentPage().getParameters().put('id',camp.Id);
			CW_AudienceGroupController agCtrl = new CW_AudienceGroupController();
			
			agCtrl.editGroups();
			
			agCtrl.getAudienceGroup();
			
			agCtrl.campGroups[0].aGroup.Is_Control_Group__c = true;
			agCtrl.saveGroups();
			
			listGroups = [SELECT Id,Name,Description__c,
								 Is_Control_Group__c,
								 Control_Group__c
						  FROM CW_Audience_Group__c
						  WHERE Campaign__c = : camp.Id];
						  
			system.assertEquals(listGroups[0].Control_Group__c,null);
			system.assertEquals(listGroups[0].Is_Control_Group__c,true);
			
	    }
	    Test.stopTest();
    }
	
	
    static testMethod void deleteGroupsTest() 
    {
        initCustomSettings();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        List<CW_Audience_Group__c> listGroups = TestDataUtil.createAudienceGroups(camp.Id,5);
        insert listGroups;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	Test.startTest();
    	
		System.runAs(thisUser)
	    {  
	        Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.next();
			
			Test.setCurrentPage(Page.CW_Audience);
			Apexpages.currentPage().getParameters().put('id',camp.Id);
			CW_AudienceGroupController agCtrl = new CW_AudienceGroupController();
			
			system.assertEquals(agCtrl.getPageNumber(),1);
			system.assertEquals(agCtrl.setGroups.getResultSize(),listGroups.size());
			
			agCtrl.getAudienceGroup();
			agCtrl.contextItem = agCtrl.campGroups[0].aGroup.Id;
			agCtrl.doSelectItem();
			agCtrl.contextItem = agCtrl.campGroups[1].aGroup.Id;
			agCtrl.doSelectItem();
			agCtrl.deleteGroups();
			
			listGroups = [SELECT Id,Name,Description__c
						  FROM CW_Audience_Group__c
						  WHERE Campaign__c = : camp.Id];
						  
			system.assertEquals(agCtrl.setGroups.getResultSize(),listGroups.size());
			
	    }
	    Test.stopTest();
    }
    
    static testMethod void createNewGroup()
    {
    	initCustomSettings();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        List<CW_Audience_Group__c> listGroups = TestDataUtil.createAudienceGroups(camp.Id,5);
        insert listGroups;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	Test.startTest();
    	
		System.runAs(thisUser)
	    {  
	        Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.next();
			
			Apexpages.currentPage().getParameters().put('id', camp.Id);
			Id campId = Apexpages.currentPage().getParameters().get('id');
			
			CW_AudienceGroupController agCtrl = new CW_AudienceGroupController();
			
			agCtrl.addGroup();
			
			agCtrl.campGroups[0].aGroup.Description__c = 'Added new group';
			agCtrl.campGroups[0].aGroup.Unica_Id__c = '12345';
			
			agCtrl.saveGroups();
			
			listGroups = [SELECT Id,Name,Description__c,Campaign__c
						  FROM CW_Audience_Group__c
						  WHERE Campaign__c = : campId
						  AND Name =: agCtrl.campGroups[0].aGroup.Name];
			
			system.assertEquals(listGroups.size(),1);
	    }
    }
    
}