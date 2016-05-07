/**
* File Name   :    CW_RoadmapApprovalProcessTest.cls
* Description :    B-108780 As a Marketing Ops Roadmapper I want the ability to send 
*				   a roadmap for MarCom approval.
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 15/04/2014 Cristina P.	Intial
*
*/
@isTest
private class CW_RoadmapApprovalProcessTest 
{
	public static User approverUser;
	public static User roadmapperUser;
	
	public static ApproverListSetting__c cas1;
	
	//create approver and non approver users 
	public static void initUsers()
	{
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
		System.runAs(thisUser){
	    		
	    	UserRole vipRole = TestDataUtil.createRole('Sports VIP Marketing Ops');
	    	 
	    	UserRole marketingRole = TestDataUtil.createRole('Sports Marketing Ops');
	    	
	    	Group newGroup = TestDataUtil.createGroup('Roadmappers');
	    	insert newGroup;
	    	
	    	approverUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	approverUser.UserRoleId = vipRole.Id;
	    	approverUser.Department = 'Sport';
	    	insert approverUser;
	    	
	    	roadmapperUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	roadmapperUser.UserRoleId = marketingRole.Id;
	    	roadmapperUser.Department = 'Sport';
	    	insert roadmapperUser;
	    	
	    	GroupMember newGroupMember = TestDataUtil.createGroupMember(newGroup.Id, roadmapperUser.Id);
	    	insert newGroupMember;
		}
	}
	
	//create custom settings
	public static void initCustomSettings()
	{
		initUsers();
		
    	cas1 = new ApproverListSetting__c(Name='1',Username__c=approverUser.Username,Type__c='Roadmappers');
	    insert new List<ApproverListSetting__c>{cas1};
	}
	
	//test roadmap submit for approval succesfully
    static testMethod void SubmitForApprovalSuccesfully() 
    {
    	initCustomSettings();
    	
        CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
        roadmap.Approval_Status__c = 'Not Submitted';
        insert roadmap;
        
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
        
        CW_Asset_Type__c assetType = TestDataUtil.createAssetType();
        insert assetType;
        
        CW_Asset__c asset = TestDataUtil.createAsset(assetType.Id);
        insert asset;
        
        System.runAs(roadmapperUser){
	        CW_Campaign__c camp = TestDataUtil.createCampaign();
	        camp.Campaign_End_Date__c = Date.today().addDays(30);
	        camp.Roadmap__c = roadmap.Id;
	    	camp.Main_Campaign_Business_Objective__c = 'Retention';
	    	camp.Suggested_MarCom_Delivery_Date__c = Date.today().addDays(10);
	    	camp.Campaign_Focus__c = 'Retention';
	    	camp.Points__c = 4;
	    	insert camp;
	    	
	    	CW_Campaign_Asset_Type__c cat = TestDataUtil.createCampaignAssetType(assetType.Id, camp.Id);
	        insert cat;
	        
	        CW_Campaign_Sites__c campSite = TestDataUtil.createCampaignSite(camp.Id, siteCatalogue.Id, language.Id);
        	insert campSite;
	        
	        camp = [SELECT Name, Campaign_Number__c, 
	    				   Suggested_MarCom_Delivery_Date__c,
	    				   Campaign_Start_Date__c,
	    				   Campaign_End_Date__c,
	    				   OwnerId, 
	    				   Main_Campaign_Business_Objective__c,
	    				   Campaign_Focus__c,Roadmap__c,
	    				   Points__c, 
	    				   Requestor_Department__c
	    			FROM CW_Campaign__c
	    			WHERE Id =: camp.Id];
	        
	        CW_RoadmapApprovalProcess.SendForApproval(roadmap.Id);
	        
	        system.assertEquals(CW_RoadmapApprovalProcess.submitForApprovalMessage,ConstantUtil.SUBMIT_FOR_APPROVAL_SUCCESFULLY);
        	
        	List<CW_Campaign__c> listCamps = [SELECT Id, Roadmap__c, Locked_Roadmap__c
        									  FROM CW_Campaign__c
        									  WHERE Roadmap__c =: roadmap.Id];
        	
        	for (CW_Campaign__c curr : listCamps)
        		system.assertEquals(curr.Locked_Roadmap__c,true);
        		
        	Test.setCurrentPage(Page.CW_Campaign_Information);
    		CW_WizardController currCtrl = new CW_WizardController(new ApexPages.StandardController(new CW_Campaign__c()));
			currCtrl.camp.Name ='New Campaign for Roadmap';
			currCtrl.camp.Roadmap__c = roadmap.Id;
    		try 
    		{
    			currCtrl.saveCampaign();
    		}
			catch (Exception e)
			{
				Boolean expectedExceptionThrown =  e.getMessage().contains(ConstantUtil.BLOCKED_NEW_CAMPAIGN) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}
        }
    }
    
    static testMethod void SubmitForApprovalWithBlackFields() 
    {
    	initCustomSettings();
    	
        CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
        insert roadmap;
        
        CW_Campaign__c campaign = TestDataUtil.createCampaign();
    	campaign.Roadmap__c = roadmap.Id;
    	insert campaign;
    	
        System.runAs(roadmapperUser){
	        CW_RoadmapApprovalProcess.SendForApproval(roadmap.Id);
	        
	        system.assertEquals(CW_RoadmapApprovalProcess.submitForApprovalMessage,campaign.Name + ConstantUtil.SUBMIT_FOR_APPROVAL_ROADMAP_NULL_FIELDS);
	    	system.assertEquals(CW_RoadmapApprovalProcess.submitForApproval,false);
        }
    }
    
    static testMethod void SubmitForApprovalWithNoApproverDefined() 
    {
    	initUsers();
    	
    	cas1 = new ApproverListSetting__c(Name='1',Username__c=approverUser.Username,Type__c=null);
	    insert new List<ApproverListSetting__c>{cas1};
    	    	
        CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
        insert roadmap;
        
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
        
        CW_Asset_Type__c assetType = TestDataUtil.createAssetType();
        insert assetType;
        
        CW_Asset__c asset = TestDataUtil.createAsset(assetType.Id);
        insert asset;
        
        System.runAs(roadmapperUser){
	        CW_Campaign__c camp = TestDataUtil.createCampaign();
	        camp.Campaign_End_Date__c = Date.today().addDays(30);
	        camp.Roadmap__c = roadmap.Id;
	    	camp.Main_Campaign_Business_Objective__c = 'Retention';
	    	camp.Suggested_MarCom_Delivery_Date__c = Date.today().addDays(10);
	    	camp.Campaign_Focus__c = 'Retention';
	    	camp.Points__c = 4;
	    	insert camp;
	    	
	    	CW_Campaign_Asset_Type__c cat = TestDataUtil.createCampaignAssetType(assetType.Id, camp.Id);
	        insert cat;
	        
	        CW_Campaign_Sites__c campSite = TestDataUtil.createCampaignSite(camp.Id, siteCatalogue.Id, language.Id);
        	insert campSite;
	        
	        camp = [SELECT Name, Campaign_Number__c, 
	    				   Suggested_MarCom_Delivery_Date__c,
	    				   Campaign_Start_Date__c,
	    				   Campaign_End_Date__c,
	    				   OwnerId, 
	    				   Main_Campaign_Business_Objective__c,
	    				   Campaign_Focus__c,Roadmap__c,
	    				   Points__c, 
	    				   Requestor_Department__c
	    			FROM CW_Campaign__c
	    			WHERE Id =: camp.Id];
        
        	CW_RoadmapApprovalProcess.SendForApproval(roadmap.Id);
        
        	system.assertEquals(CW_RoadmapApprovalProcess.submitForApprovalMessage,ConstantUtil.SUBMIT_FOR_APPROVAL_NO_ROADMAP_APPROVER);
        }    
    }
    
    static testMethod void NoAccessToSubmitForApproval() 
    {
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
		System.runAs(thisUser){
	    		
	    	UserRole vipRole = TestDataUtil.createRole('Sports VIP Marketing Ops');
	    	 
	    	UserRole marketingRole = TestDataUtil.createRole('Sports Marketing Ops');
	    	
	    	Group newGroup = TestDataUtil.createGroup('Roadmappers');
	    	insert newGroup;
	    	
	    	approverUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	approverUser.UserRoleId = vipRole.Id;
	    	insert approverUser;
	    	
	    	roadmapperUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	roadmapperUser.UserRoleId = marketingRole.Id;
	    	insert roadmapperUser;
	    	
	    	GroupMember newGroupMember = TestDataUtil.createGroupMember(newGroup.Id, roadmapperUser.Id);
	    	insert newGroupMember;
		}
    	
    	cas1 = new ApproverListSetting__c(Name='1',Username__c=approverUser.Username,Type__c='Roadmappers');
	    insert new List<ApproverListSetting__c>{cas1};
    	
        CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
        insert roadmap;
        
        CW_Campaign__c campaign = TestDataUtil.createCampaign();
    	campaign.Roadmap__c = roadmap.Id;
    	insert campaign;
    	
        System.runAs(approverUser){
        	CW_RoadmapApprovalProcess.SendForApproval(roadmap.Id);
			system.assertEquals(CW_RoadmapApprovalProcess.submitForApprovalMessage,ConstantUtil.SUBMIT_FOR_APPROVAL_NON_ROADMAPPER);
        }
    }
    
    static testMethod void resetCampaignsFlagWhenRoadmapRejected()
    {
    	initCustomSettings();
    	
        CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
        insert roadmap;
        
        CW_Campaign__c campaign = TestDataUtil.createCampaign();
    	campaign.Roadmap__c = roadmap.Id;
    	insert campaign;
    	
    	CW_Asset_Type__c assetType = TestDataUtil.createAssetType();
    	insert assetType;
    	
    	roadmap.Approval_Status__c = ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
    	update roadmap;
    	
    	CW_Campaign_Asset_Type__c cat = TestDataUtil.createCampaignAssetType(assetType.Id, campaign.Id);
    	
    	try 
    	{
    		insert cat;
    	} 
    	catch (DmlException e)
    	{
    		System.assertEquals(e.getMessage(),ConstantUtil.ASSET_INSERT_ERROR
    		 + ConstantUtil.BLOCKED_CAMPAIGN_ASSET_TYPE + ': []');
    		
    	}
    	
    	roadmap.Approval_Status__c = ConstantUtil.APPROVAL_PROCESS_REJECTED;
    	update roadmap;
    	
    	List<CW_Campaign__c> camps = [SELECT Id, Roadmap__c, Locked_Roadmap__c
    								  FROM CW_Campaign__c
    								  WHERE Roadmap__c =: roadmap.Id];
    								  
    	for (CW_Campaign__c curr : camps)
    		system.assertEquals(curr.Locked_Roadmap__c,false);
        
    }
    
    static testMethod void SubmitForApprovalRoadmapWithNoCampaign() 
    {
    	initCustomSettings();
    	
        CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
        insert roadmap;
    	
        System.runAs(roadmapperUser){
	        CW_RoadmapApprovalProcess.SendForApproval(roadmap.Id);
	        
	        system.assertEquals(CW_RoadmapApprovalProcess.submitForApprovalMessage,ConstantUtil.SUBMIT_FOR_APPROVAL_ROADMAP_NO_CAMPS);
	    	system.assertEquals(CW_RoadmapApprovalProcess.submitForApproval,false);
        }
    }
    
    static testMethod void SubmitForApprovalRoadmapAlreadyInApproval() 
    {
    	initCustomSettings();
    	
        CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
        roadmap.Approval_Status__c = 'In Approval';
        insert roadmap;
    	
        System.runAs(roadmapperUser){
	        CW_RoadmapApprovalProcess.SendForApproval(roadmap.Id);
	        
	        system.assertEquals(CW_RoadmapApprovalProcess.submitForApprovalMessage,ConstantUtil.SUBMIT_FOR_APPROVAL_ROADMAP_IN_APPROVAL);
	    	system.assertEquals(CW_RoadmapApprovalProcess.submitForApproval,false);
        }
    }
}