@isTest
private class CW_WizardStartPageSelectorControllerTest 
{
	public static User cimBiUser;
	public static User marketingOpsUser;
	public static Group cimGroup;

    public static void createTestData()
    {
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
		System.runAs(thisUser)
		{
			List<Pagereference> pageReferences = new List<Pagereference>();
			pageReferences.add(Page.CW_Campaign_Information);
			pageReferences.add(Page.CW_Audience);
			pageReferences.add(Page.CW_Reward);
			pageReferences.add(Page.CW_Creative_Information);
			pageReferences.add(Page.CW_Assets);
			List<CW_Campaign_Navigation_Settings__c> campaignNavigationSettings = TestDataUtil.getCampaignNavigationSettings(pageReferences);
			insert campaignNavigationSettings;
		
			UserRole cimRole = TestDataUtil.createRole('CIM');
			UserRole marketingRole = TestDataUtil.createRole('Sports Marketing Ops');
			
	    	cimBiUser = TestDataUtil.getUserWithProfileName('Marketing Ops');
	    	cimBiUser.UserRoleId = cimRole.Id;
	    	insert cimBiUser;
	    	
	    	marketingOpsUser = TestDataUtil.getUserWithProfileName('System Administrator');
		    marketingOpsUser.UserRoleId = marketingRole.Id;
		    insert marketingOpsUser;
		}
    	
    }
    
    static testMethod void testWizardForCim() 
    {
        createTestData();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        Test.startTest();
        
	    System.runAs(cimBiUser)
	    {  
	    	Test.setCurrentPage(Page.CW_WizardStartPageSelector);
	    	CW_WizardStartPageSelectorController startCtrl = new CW_WizardStartPageSelectorController(new ApexPages.StandardController(camp));
			
			system.assertEquals(startCtrl.isCIMorBIUser,true);
	    	
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			
			List<CW_Campaign_Navigation_Settings__c> cns = [SELECT Id FROM CW_Campaign_Navigation_Settings__c WHERE accessibleByCIMorBI__c =: true];
			
			system.assertEquals(cns.size(),wizCtrl.navigationMenu.size());
	    }
	    
	    Test.stopTest();
        
    }
    
    static testMethod void testWizardForMarketingOpsUser() 
    {
        createTestData();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        Test.startTest();
        
	    System.runAs(marketingOpsUser)
	    {  
	    	Test.setCurrentPage(Page.CW_WizardStartPageSelector);
	    	CW_WizardStartPageSelectorController startCtrl = new CW_WizardStartPageSelectorController(new ApexPages.StandardController(camp));
			
			system.assertEquals(startCtrl.isCIMorBIUser,false);
			
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			List<CW_Campaign_Navigation_Settings__c> cns = [SELECT Id FROM CW_Campaign_Navigation_Settings__c];
			
			system.assertEquals(cns.size(), wizCtrl.navigationMenu.size());
	    }
	    
	    Test.stopTest();
        
    }
}