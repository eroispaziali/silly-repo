/**
* File Name   :    CW_MarcomBriefViewController.cls
* Description :    B-109868: Add Related objects to the MarCom Brief View 
*
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 07/06/2014 Cristina P.	Intial
*
*/
@isTest
private class CW_MarcomBriefViewControllerTest {

    public static User sysAdminUser;
	public static User marketingOpsUser;
	public static User marcomUser;
	public static CW_Campaign__c camp;
	public static CW_CampaignWizardAccessSettings__c mcbas;

    public static void createTestData()
    {
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
		System.runAs(thisUser)
		{
			UserRole marketingRole = TestDataUtil.createRole('Sports Marketing Ops');
			UserRole accPartner = TestDataUtil.createRole('Sports MarCom Account Partner');			
			
	    	sysAdminUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	insert sysAdminUser;
	    	
	    	marketingOpsUser = TestDataUtil.getUserWithProfileName('Marketing Ops');
		    marketingOpsUser.UserRoleId = marketingRole.Id;
		    insert marketingOpsUser;
		    
		    marcomUser = TestDataUtil.getUserWithProfileName('MarCom');
		    marcomUser.UserRoleId = accPartner.Id;
		    insert marcomUser;
		    
		    mcbas = new CW_CampaignWizardAccessSettings__c(SetupOwnerId = marcomUser.id,Has_MarcomBriefEditAccess__c = true);
		    insert mcbas;
		    
		    CW_Brand__c brand = TestDataUtil.createBrand();
	        insert brand;
	        
	        CW_Label__c label = TestDataUtil.createLabel(brand.Id);
	        insert label;
	        
	        CW_Country__c country = TestDataUtil.createCountry();
	        insert country;
	        
	        CW_Product__c product = TestDataUtil.createProduct();
	        insert product;
	        
	        CW_Language__c language = TestDataUtil.createLanguage();
	        insert language;
	        
	        CW_Site_Catalogue__c siteCatalogue = TestDataUtil.createSiteCatalogue(label.Id, country.Id, product.Id);
	        insert siteCatalogue;
	    	
	     	camp = TestDataUtil.createCampaign();
	     	insert camp;
	     	 	
		    CW_Campaign_Sites__c campSites = TestDataUtil.createCampaignSite(camp.Id, siteCatalogue.Id, language.Id);
	       	insert campSites;
	       	
	       	CW_Asset_Type__c assetType = TestDataUtil.createAssetType();
	       	insert assetType; 
	       	
	       	CW_Campaign_Asset_Type__c cat = TestDataUtil.createCampaignAssetType(assetType.Id, camp.Id);
	       	insert cat;
	       	
	       	CW_Audience_Group__c ag = TestDataUtil.createAudienceGroup(camp.Id);
	       	insert ag;
	       	
	       	CW_Schedule__c schedule = TestDataUtil.createSchedule(camp);
	       	insert schedule;
	       	
	       	// 10/07/2014 CY - no longer need as AGS records are created by trigger
	       	//CW_Audience_Group_Schedule__c ags = TestDataUtil.createAudienceGroupSchedule(ag.Id, schedule.Id);
	       	//insert ags;
	       	
	       	CW_Offer_Type__c offerType = TestDataUtil.createOfferType('Operational Tool');
	       	insert offerType;
	       	
	       	CW_Reward_Type__c rewardType = TestDataUtil.createRewardType('Freebet Amount');
	       	insert rewardType;
	       	
	       	CW_Reward_Catalogue__c catalog = TestDataUtil.createRewardCatalogue(offerType.Id, rewardType.Id);
	       	insert catalog;
	       	
	       	CW_Reward_Library__c library = TestDataUtil.createRewardLibrary(rewardType.Id);
	       	insert library;
	       	
	       	CW_Campaign_Offer__c campOffer = TestDataUtil.createCampaignOffer(camp.Id,offerType.Id);
	       	insert campOffer;
	       	
	       	CW_Campaign_Reward__c cr = TestDataUtil.createCampaignReward(campOffer.Id, Catalog.Id, Library.Id,rewardType.Id);
	       	insert cr;
		}
    	
    }
    
     static testMethod void testMarcomBrief()
     {
     	createTestData();
    	
        Test.startTest();
        
	    System.runAs(marketingOpsUser)
	    {  
	    	camp.OwnerId = marketingOpsUser.Id; 
	    	camp.Stage__c = 'Draft';
	    	update camp;
	    	
	    	Test.setCurrentPage(Page.CW_MarcomBriefView);
	    	ApexPages.currentPage().getParameters().put('Id',camp.Id);
	    	CW_MarcomBriefViewController mbvCtrl = new CW_MarcomBriefViewController(new ApexPages.StandardController(camp));
			
			//check if is marketing user and has permission to edit points
			system.assertEquals(true, mbvCtrl.isMarketingUser);
			system.assertEquals(false, mbvCtrl.hasPermission);
			
			//check if user has access to delete the campaign
			system.assertEquals(true, mbvCtrl.hasDeleteAccess);
			
			mbvCtrl.editRecord();
			PageReference pg = Page.CW_MarcomBriefView;
			pg.getParameters().put(ConstantUtil.SOBJECT_ID,camp.Id);
			
			mbvCtrl.backToListView();
			mbvCtrl.getWagerUplift();
			mbvCtrl.getNGRUplift();
			
	    }
	    Test.stopTest();
     }
     
     static testMethod void testMarcomBriefForMarcomUser()
     {
     	createTestData();
    	
        Test.startTest();
        
	    System.runAs(marcomUser)
	    {  
	    	Test.setCurrentPage(Page.CW_MarcomBriefView);
	    	ApexPages.currentPage().getParameters().put('Id',camp.Id);
	    	CW_MarcomBriefViewController mbvCtrl = new CW_MarcomBriefViewController(new ApexPages.StandardController(camp));
	    	
	    	//check if user has access to update the campaign points
	    	system.assertEquals(true,mbvCtrl.hasPermission);
	    	
	    	//check if user has access to delete the campaign
			system.assertEquals(false, mbvCtrl.hasDeleteAccess);
	    	
	    	mbvCtrl.camp.Points__c = 40;
	    	mbvCtrl.saveCampaign();
	    	
	    	CW_Campaign__c updatedCamp = [SELECT Points__c FROM CW_Campaign__c WHERE Id=: mbvCtrl.camp.Id];
	    	system.assertEquals(mbvCtrl.camp.Points__c, updatedCamp.Points__c);
	    }
     }
}