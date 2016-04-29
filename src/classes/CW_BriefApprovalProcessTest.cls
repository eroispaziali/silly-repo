/**
* File Name   :    CW_BriefApprovalProcessTest.cls
* Description :    B-106804 As a Marketing Ops I want the ability to submit a MarCom Brief
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 24/04/2014 Cristina P.	Intial
*
*/
@isTest
private class CW_BriefApprovalProcessTest 
{
	public static User approverUser;
	public static User nonApproverUser;
	public static CW_Campaign__c camp;
	
	public static ApproverListSetting__c approverSetting;
	
	public static void initUsersAndCustomSettings()
	{
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
		System.runAs(thisUser){
	    		
	    	UserRole marketingRole = TestDataUtil.createRole('Marketing Ops');
	    	
	    	Group newGroup = TestDataUtil.createGroup('Roadmappers');
	    	insert newGroup;
	    	
	    	approverUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	approverUser.UserRoleId = marketingRole.Id;
	    	approverUser.Department = 'Sport';
	    	insert approverUser;
	    	
	    	nonApproverUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	nonApproverUser.UserRoleId = marketingRole.Id;
	    	nonApproverUser.Department = 'Sport';
	    	insert nonApproverUser;
	    	
	    	approverSetting = new ApproverListSetting__c(Name='1',Username__c=approverUser.Username,Role__c ='Marketing Ops' ,Type__c='Brief');
	    	insert new List<ApproverListSetting__c>{approverSetting};
		}
	}
	
	public static void initData()
	{
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
	    	
        
	}
	
	public static void updateCampRequiredFields(CW_Campaign__c campaign)
	{
        campaign.Suggested_MarCom_Delivery_Date__c = Date.today().addDays(10);
    	campaign.Main_Campaign_Business_Objective__c = 'test';
    	campaign.Campaign_Focus__c = 'Retention'; 
    	campaign.What_is_being_communicated__c ='test';
    	campaign.Target_Audience_Insight__c = 'test';
    	campaign.Urgent_Campaign__c = false;
    	update campaign;
	    
	}

    static testMethod void submitBriefForApprovalNoCampaignSite() 
    {
    	initUsersAndCustomSettings();
    	
    	CW_Campaign__c newCamp = TestDataUtil.createCampaign();
    	newCamp.OwnerId = nonApproverUser.Id;
	    insert newCamp;
	    
	    updateCampRequiredFields(newCamp);
    		
     	System.runAs(nonApproverUser)
     	{
     		updateCampRequiredFields(newCamp);	
	    	
	        newCamp = [SELECT Name, Campaign_Start_Date__c,
	        			   Campaign_End_Date__c, 
	    				   Suggested_MarCom_Delivery_Date__c,
	    				   OwnerId, 
	    				   Main_Campaign_Business_Objective__c,
	    				   Campaign_Focus__c,Roadmap__c,
	    				   What_is_being_communicated__c,
	    				   Target_Audience_Insight__c,
	    				   Requestor_Department__c,
	    				   Cost_Approval_Status__c,
	    				   Urgent_Campaign__c
	    			FROM CW_Campaign__c
	    			WHERE Id =: newCamp.Id];
	        
	        CW_BriefApprovalProcess briefAP = new CW_BriefApprovalProcess();
	        briefAP.checkBriefForApproval(newCamp);

	        system.assertEquals(briefAP.submitBriefForApproval , false);
        	
     	 }
    }
    
    static testMethod void submitBriefForApprovalNoRoadmapApproved() 
    {
    	initUsersAndCustomSettings();
    	initData();
    	
    	CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
    	roadmap.Approval_Status__c = 'Not Submitted';
        insert roadmap;
        
    	updateCampRequiredFields(camp);	
    	
     	System.runAs(nonApproverUser)
     	{
     		camp.Stage__c = 'Draft';
     		camp.OwnerId = nonApproverUser.Id;
     	 	camp.Cost_Approval_Status__c = 'Approved';
	    	camp.Roadmap__c = roadmap.Id;
	    	update camp;
	    	
	        camp = [SELECT Name, Campaign_Start_Date__c,
	        			   Campaign_End_Date__c, 
	    				   Suggested_MarCom_Delivery_Date__c,
	    				   OwnerId, 
	    				   Main_Campaign_Business_Objective__c,
	    				   Campaign_Focus__c,Roadmap__c,
	    				   What_is_being_communicated__c,
	    				   Target_Audience_Insight__c,
	    				   Requestor_Department__c,
	    				   Cost_Approval_Status__c,
	    				   Urgent_Campaign__c
	    			FROM CW_Campaign__c
	    			WHERE Id =: camp.Id];
	        
	        CW_BriefApprovalProcess briefAP = new CW_BriefApprovalProcess();
	        briefAP.submitBriefForApproval(camp);

	        system.assertEquals(briefAP.errorMessage , ConstantUtil.SUBMIT_FOR_APPROVAL_BRIEF_NO_ROADMAP_APPROVED + roadmap.Approval_Status__c);
        	
     	 }
    }
    
   	static testMethod void submitBriefForApprovalSuccesfully() 
    {
    	initUsersAndCustomSettings();
    	
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
    	
     	CW_Campaign__c newCamp = TestDataUtil.createCampaign();
     	insert newCamp;
     	 	
	    CW_Campaign_Sites__c campSites = TestDataUtil.createCampaignSite(newCamp.Id, siteCatalogue.Id, language.Id);
       	insert campSites;
    	
    	CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
    	roadmap.Approval_Status__c = 'Not Submitted';
        insert roadmap;
        
    	updateCampRequiredFields(newCamp);	
    	
     	System.runAs(nonApproverUser)
     	{
     		newCamp.Name = 'New Campaign';
     		newCamp.OwnerId = nonApproverUser.Id;
     		newCamp.Stage__c = 'Roadmap Approved';
     	 	newCamp.Cost_Approval_Status__c = 'Approved';
	    	newCamp.Roadmap__c = roadmap.Id;
	    	update newCamp;
	    	
	    	roadmap.Approval_Status__c = 'Approved';
	    	update roadmap;
	    	
	        newCamp = [SELECT Name, Campaign_Start_Date__c,
	        			   Campaign_End_Date__c, 
	    				   Suggested_MarCom_Delivery_Date__c,
	    				   OwnerId, 
	    				   Main_Campaign_Business_Objective__c,
	    				   Campaign_Focus__c,Roadmap__c,
	    				   What_is_being_communicated__c,
	    				   Target_Audience_Insight__c,
	    				   Requestor_Department__c,
	    				   Cost_Approval_Status__c,
	    				   Urgent_Campaign__c
	    			FROM CW_Campaign__c
	    			WHERE Id =: newCamp.Id];
	        
	        CW_BriefApprovalProcess briefAP = new CW_BriefApprovalProcess();
	        Boolean isSubmitted = briefAP.submitBriefForApproval(newCamp);

	        system.assertEquals(isSubmitted , true);
        	
     	 }
    }
    
    static testMethod void submitUrgentBriefForApprovalSuccesfully() 
    {
    	initUsersAndCustomSettings();
    	
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
    	
     	CW_Campaign__c urgentCamp = TestDataUtil.createCampaign();
     	insert urgentCamp;
     	 	
	    CW_Campaign_Sites__c campSites = TestDataUtil.createCampaignSite(urgentCamp.Id, siteCatalogue.Id, language.Id);
       	insert campSites;
       	
       	CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
    	roadmap.Approval_Status__c = 'Not Submitted';
        insert roadmap;
    	
    	updateCampRequiredFields(urgentCamp);	
    	
     	System.runAs(nonApproverUser)
     	{
     		urgentCamp.Name = 'Urgent Campaign';
     		urgentCamp.OwnerId = nonApproverUser.Id;
     		urgentCamp.Stage__c = 'Roadmap Approved';
     	 	urgentCamp.Cost_Approval_Status__c = 'Approved';
	    	urgentCamp.Urgent_Campaign__c = true;
	    	update urgentCamp;
	    	
	        urgentCamp = [SELECT Name, Campaign_Start_Date__c,
	        			   Campaign_End_Date__c, 
	    				   Suggested_MarCom_Delivery_Date__c,
	    				   OwnerId, 
	    				   Main_Campaign_Business_Objective__c,
	    				   Campaign_Focus__c,Roadmap__c,
	    				   What_is_being_communicated__c,
	    				   Target_Audience_Insight__c,
	    				   Requestor_Department__c,
	    				   Cost_Approval_Status__c,
	    				   Urgent_Campaign__c
	    			FROM CW_Campaign__c
	    			WHERE Id =: urgentCamp.Id];
	        
	        CW_BriefApprovalProcess briefAP = new CW_BriefApprovalProcess();
	        Boolean isSubmitted = briefAP.submitBriefForApproval(urgentCamp);

	        system.assertEquals(isSubmitted , true);
        	
     	 }
    }
}