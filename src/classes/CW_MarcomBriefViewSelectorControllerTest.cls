/**
* File Name   :    CW_MarcomBriefViewSelectorController.cls
* Description :    B-109868: Add Related objects to the MarCom Brief View 
*				   Displayes VF page for marcom and marketing users and 
*				   standard page layout for other profiles
*
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 05/06/2014 Cristina P.	Intial
*
*/
@isTest
private class CW_MarcomBriefViewSelectorControllerTest 
{

    public static User sysAdminUser;
	public static User marketingOpsUser;

    public static void createTestData()
    {
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
		System.runAs(thisUser)
		{
			UserRole marketingRole = TestDataUtil.createRole('Sports Marketing Ops');
			
	    	sysAdminUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	insert sysAdminUser;
	    	
	    	marketingOpsUser = TestDataUtil.getUserWithProfileName('Marketing Ops');
		    marketingOpsUser.UserRoleId = marketingRole.Id;
		    insert marketingOpsUser;
		}
    	
    }
    
    static testMethod void testMarcomBriefForMarketingOpsUser() 
    {
        createTestData();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        Test.startTest();
        
	    System.runAs(marketingOpsUser)
	    {  
	    	Test.setCurrentPage(Page.CW_MarcomBriefViewSelector);
	    	CW_MarcomBriefViewSelectorController startCtrl = new CW_MarcomBriefViewSelectorController(new ApexPages.StandardController(camp));
			
			system.assertEquals(startCtrl.isMarcomUser,true);
			
	    }
	    
	    Test.stopTest();
        
    }
    
    static testMethod void testMarcomBriefForOtherUser() 
    {
        createTestData();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        Test.startTest();
        
	    System.runAs(sysAdminUser)
	    {  
	    	Test.setCurrentPage(Page.CW_MarcomBriefViewSelector);
	    	CW_MarcomBriefViewSelectorController startCtrl = new CW_MarcomBriefViewSelectorController(new ApexPages.StandardController(camp));
			
			system.assertEquals(startCtrl.isMarcomUser,false);
	    }
	    
	    Test.stopTest();
        
    }
}