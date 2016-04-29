/**
* File Name   :    CW_WizardControllerTest.cls
* Description :    PEN-131/PEN-082
*                  creating campaign wizard
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 14/03/2014 Klea Kolaric	Merging test code from Cristina Popescu and adding new methods
* 0.2 24/03.2014 Cristina P.	Update the test class to work with the save functionality on save button
*								Test the navigation menu
* 0.3 26/03/2014 Cristina P		Update the test class adding test function for submit for approval process
* 0.4 27/03/2014 Klea Kolaric	Tests for asset page
* 0.5 01/04/2014 Cristina P		Tests for cost changed while campaign is in approval
* 0.6 17/04/2014 Cristina P		Test for adding new campaign to a locked roadmap
* 0.7 18/04/2014 Cristina P		Test for auto save campaign
* 0.8 30/04/2014 Klea Kolaric	B-106849
* 0.9 02/05/2014 Klea Kolaric	B-114113
*0.10 24/07/2014 Suneetha Jasthi	 B-121604
*/
@isTest
public with sharing class CW_WizardControllerTest
{
	public static User approverUser;
	public static User nonApproverUser;
	public static User cimBiUser;

	public static ApproverListSetting__c cas1;
	public static ApproverListSetting__c cas2;
	public static ApproverListSetting__c cas3;

	public static List<CW_Campaign_Navigation_Settings__c> campaignNavigationSettings;

	public static void initUsers()
	{
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		System.runAs(thisUser){

	    	UserRole vipRole = TestDataUtil.createRole('Sports VIP Marketing Ops');

	    	UserRole marketingRole = TestDataUtil.createRole('Sports Marketing Ops');

	    	UserRole cimRole = TestDataUtil.createRole('CIM');

	    	approverUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	approverUser.Username = 'Approver@username.com';
	    	approverUser.UserRoleId = vipRole.Id;
	    	approverUser.Department = 'Sport';
	    	insert approverUser;

	    	nonApproverUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	nonApproverUser.UserRoleId = marketingRole.Id;
	    	approverUser.Department = 'Sport';
	    	insert nonApproverUser;

	    	cimBiUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	cimBiUser.UserRoleId = cimRole.Id;
	    	cimBiUser.Department = 'Sport';
	    	insert cimBiUser;

		}
	}

	public static void initCustomSettings()
	{
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		System.runAs(thisUser)
		{
			List<Pagereference> pageReferences = new List<Pagereference>();
			pageReferences.add(Page.CW_Campaign_Information);
			pageReferences.add(Page.CW_Business_Case);
			pageReferences.add(Page.CW_MarCom_Delivery);
			pageReferences.add(Page.CW_Creative_Information);
			pageReferences.add(Page.CW_Assets);
			pageReferences.add(Page.CW_Audience);
			pageReferences.add(Page.CW_Reward);
			pageReferences.add(Page.CW_Associate_Audience_Reward);
			pageReferences.add(Page.CW_Legal_Information);
			campaignNavigationSettings = TestDataUtil.getCampaignNavigationSettings(pageReferences);
			insert campaignNavigationSettings;

			system.assertEquals(pageReferences.size(), campaignNavigationSettings.size());
			system.debug('campaignNavigationSettings>>>'+campaignNavigationSettings);

	    	cas1 = new ApproverListSetting__c(Name='1',Username__c=approverUser.Username,Role__c='Sports VIP Marketing Ops',Limit__c = 25000);
		    cas2 = new ApproverListSetting__c(Name='2',Username__c=approverUser.Username,Role__c='Sports Marketing Ops',Limit__c = 35000);
		    cas3 = new ApproverListSetting__c(Name='3',Username__c=approverUser.Username,Role__c ='Sports Marketing Ops' ,Type__c='Brief');
		    insert new List<ApproverListSetting__c>{cas1,cas2,cas3};
		}
	}

	public static testMethod void CampaignInformationPageTest()
    {
    	initUsers();
    	initCustomSettings();

        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;

        CW_Brand__c brand = TestDataUtil.createBrand();
        insert brand;

        Test.startTest();

	    System.runAs(approverUser)
	    {
	        Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.camp.Name='Test_UnitTest';
	        wizCtrl.camp.Campaign_Start_Date__c = Date.today().addDays(1);
	        wizCtrl.camp.Campaign_End_Date__c = Date.today().addDays(30);
	        wizCtrl.getHeaderFields();
	        wizCtrl.getFields();
			wizCtrl.saveCampaign();
			wizCtrl.cancel();

	        List<CW_Campaign__c> lCampaigns = [SELECT Id,Campaign_Start_Date__c,
								 					  Campaign_End_Date__c,
								 					  Estimated_Cost__c,
								 					  Name
						 					   FROM CW_Campaign__c
										 	   WHERE Id =: wizCtrl.camp.Id];

			system.assertEquals(lCampaigns.size(), 1);
			system.assertEquals(lCampaigns[0].Campaign_End_Date__c, system.today() + 30);
			system.assertEquals(lCampaigns.size(), 1);
	    }
	    Test.stopTest();
    }

    static testMethod void CampaignDescriptionPageTest()
    {
		initUsers();
    	initCustomSettings();

    	CW_WizardBrandLabelUtilTest.dataSetup();

    	System.runAs(approverUser)
	    {
	    	Integer currentPageIndex = 0;
	    	Pagereference firstPage = new Pagereference('/apex/'+campaignNavigationSettings[currentPageIndex].Page_Name__c);
	    	Test.setCurrentPage(firstPage);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(new CW_Campaign__c()));
			wizCtrl.camp.Name='Test_UnitTest';
	        wizCtrl.camp.Campaign_Start_Date__c = Date.today().addDays(1);
	        wizCtrl.camp.Campaign_End_Date__c = Date.today().addDays(30);

	    	Test.startTest();

	    	TestDataUtil.checkList(wizCtrl.pageBrandHelper.brands, TestDataUtil.BWINTEST);
	    	//system.assertEquals('', String.valueOf(wizCtrl.pageBrandHelper.brands));
	    	wizCtrl.loadLabelProductMatrix();
	    	TestDataUtil.checkMatrix(wizCtrl.pageBrandHelper.labelProductMatrix, TestDataUtil.BWINTEST+TestDataUtil.DOTCOM, TestDataUtil.SPORTS);
	    	wizCtrl.loadLanguages();
	    	wizCtrl.loadLabelCountryMatrix();

	    	//system.assertEquals('', String.valueOf(wizCtrl.pageBrandHelper.labelProductMatrix));

	    	wizCtrl.saveCampaign();

	    	Test.stopTest();

	    	system.assertEquals(16,[select count() from CW_Campaign_Sites__c]);
    	}
    }

    static testMethod void CampaignDescriptionPageTestWithExistingCampaignSites()
    {
    	initUsers();
    	initCustomSettings();

    	CW_WizardBrandLabelUtilTest.dataSetup();
    	CW_Campaign__c camp = TestDataUtil.createCampaign();
    	insert camp;

    	CW_Site_Catalogue__c sc = [select id, Label__c, Country__c, Product__c from CW_Site_Catalogue__c where
	    							Label__r.Name = :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM)
	    							and Country__r.Name = :TestDataUtil.IRELAND
	    							and Product__r.Name = :TestDataUtil.SPORTS
	    							limit 1];

    	CW_Campaign_Sites__c cs = new CW_Campaign_Sites__c();
    	cs.Campaign__c = camp.Id;
    	cs.Site_Catalogue__c = sc.id;
    	cs.Language__c = [select id from CW_Language__c where Name = :TestDataUtil.GA limit 1].id;
    	insert cs;

    	System.runAs(approverUser)
	    {
	    	// go throug first page
	    	Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.camp.Name='Test_UnitTest';
	        wizCtrl.camp.Campaign_Start_Date__c = Date.today().addDays(1);
	        wizCtrl.camp.Campaign_End_Date__c = Date.today().addDays(30);

	    	Test.startTest();

	    	system.assertEquals(wizCtrl.pageBrandHelper.existingCampSites.size(),1);
	    	wizCtrl.resetSection();

	    	wizCtrl.loadLabelProductMatrix();
	    	wizCtrl.loadLanguages();
	    	TestDataUtil.checkList(wizCtrl.pageBrandHelper.languages, TestDataUtil.EN);
	    	system.assert(!TestDataUtil.checkList(wizCtrl.pageBrandHelper.languages, TestDataUtil.GA)); // assert unchecked option

	    	wizCtrl.loadLabelCountryMatrix();
	    	wizCtrl.getCountryIndexList();
	    	TestDataUtil.checkMatrix(wizCtrl.pageBrandHelper.labelCountryMatrix, TestDataUtil.BWINTEST+TestDataUtil.DOTCOM, TestDataUtil.NORWAY);
	    	system.assert(!TestDataUtil.checkMatrix(wizCtrl.pageBrandHelper.labelCountryMatrix, TestDataUtil.BWINTEST+TestDataUtil.DOTCOM, TestDataUtil.IRELAND)); // assert unchecked option

	    	wizCtrl.saveCampaign();
	    }
    	Test.stopTest();

    	system.assertEquals(1,[select count() from CW_Campaign_Sites__c]);	// old record has been deleted
    	system.assertEquals(1,[select count() from CW_Campaign_Sites__c where
    							Campaign__c = :camp.Id
    							and Site_Catalogue__r.Label__r.Name = :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM)
    							and Language__r.Name = :TestDataUtil.EN
    							and Site_Catalogue__r.Country__r.Name = :TestDataUtil.NORWAY
    							and Site_Catalogue__r.Product__r.Name = :TestDataUtil.SPORTS]);
    }

    /*static testMethod void AssetsPageTest()
    {
    	initUsers();
    	initCustomSettings();

    	TestDataUtil.completeAssetCatalogueDataCreation();

    	// associate with campaign
    	CW_Campaign__c camp = TestDataUtil.createCampaign();
    	insert camp;
    	CW_WizardAssetUtilTest.associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);

    	// create asset selection on campaign
    	CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c();
    	ca.Campaign__c = camp.Id;
    	ca.Asset__c = [select id from CW_Asset__c where Name = :(TestDataUtil.BANNER+' '+TestDataUtil.ADVANCED) limit 1].id;
    	insert ca;

    	List<CW_Localised_Asset__c> loc = new List<CW_Localised_Asset__c>();
    	Id enId = [select id from CW_Language__c where Name = :TestDataUtil.EN limit 1].id;

    	for(CW_Asset_Catalogue__c ac : [select id from CW_Asset_Catalogue__c where Asset__c = :ca.Asset__c])
    	{
    		CW_Localised_Asset__c la = new CW_Localised_Asset__c();
    		la.Campaign_Asset__c = ca.Id;
    		la.Asset_Catalogue__c = ac.Id;
    		la.Language__c = enId;
    		loc.add(la);
    	}
    	insert loc;

    	// go throug first page
    	Test.setCurrentPage(Page.CW_Campaign_Information);
		CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
		wizCtrl.camp.Name='Test_UnitTest';
        wizCtrl.camp.Campaign_Start_Date__c = system.today();
        wizCtrl.camp.Campaign_End_Date__c = system.today() + 30;
		wizCtrl.activePage = 'Assets';
		wizCtrl.goToPage();

    	Test.startTest();

    	system.assertEquals(1,wizCtrl.assetHelper.campAssets.size());

    	wizCtrl.selectedCampAssetId = ca.Id;
    	wizCtrl.editAsset();
    	wizCtrl.selectedCampAssetId = ca.Id;
    	wizCtrl.deleteAsset();
    	wizCtrl.newAssetpage();

    	wizCtrl.next();

    	Test.stopTest();

    	system.assertEquals(0,[select count() from CW_Campaign_Asset__c]);
    }*/

    static testMethod void CampaignNavigationMenuTest()
    {
    	initUsers();
    	initCustomSettings();

    	Test.startTest();
    	System.runAs(approverUser)
	    {
	    	Integer currentPageIndex = 0;
	    	Pagereference firstPage = new Pagereference('/apex/'+campaignNavigationSettings[currentPageIndex].Page_Name__c);
	    	Test.setCurrentPage(firstPage);

			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(new CW_Campaign__c()));
			wizCtrl.camp.Name='New_UnitTest';
	        wizCtrl.camp.Campaign_Start_Date__c = Date.today().addDays(1);
	        wizCtrl.camp.Campaign_End_Date__c = Date.today().addDays(30);

			wizCtrl.next();
			system.assertEquals(
				campaignNavigationSettings[++currentPageIndex].Name, wizCtrl.activePage,
				'when navigating forwards, the new active page was incorrect'
			);

			wizCtrl.back();
			system.assertEquals(
				campaignNavigationSettings[--currentPageIndex].Name, wizCtrl.activePage,
				'when navigating backwards, the new active page was incorrect'
			);

			Integer lastPageIndex = campaignNavigationSettings.size() - 1;
			wizCtrl.activePage = campaignNavigationSettings[lastPageIndex].Name; // set active page to last page
			wizCtrl.goToPage();
			system.assertEquals(false, wizCtrl.hasNext, 'last page should not have a next button');
	    }

	    CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;

	    System.runAs(cimBiUser)
	    {
	    	Integer currentPageIndex = 0;
	    	Pagereference firstPage = new Pagereference('/apex/'+campaignNavigationSettings[currentPageIndex].Page_Name__c);
	    	Test.setCurrentPage(firstPage);

			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));

	    	campaignNavigationSettings = [SELECT Id, accessibleByCIMorBI__c FROM CW_Campaign_Navigation_Settings__c WHERE accessibleByCIMorBI__c =: true];
	   		system.assertEquals(campaignNavigationSettings.size(),wizCtrl.campaignNavigationMenu.size(),'CIM and BI users should have access to specific pages on the wizard');
	    }

		Test.stopTest();
    }

    static testMethod void SubmitForApprovalTest() {

        initUsers();
    	initCustomSettings();

	    System.runAs(nonApproverUser)
	    {
	    	//remove user's role
	    	nonApproverUser.UserRoleId=null;
	    	update nonApproverUser;
	    	
	        Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController ctrl1 = new CW_WizardController(new ApexPages.StandardController(new CW_Campaign__c()));
	    	ctrl1.camp.Name = 'SubmitCampForApproval';
	    	ctrl1.camp.Campaign_Start_Date__c = Date.today().addDays(1);
			ctrl1.camp.Campaign_End_Date__c = ctrl1.camp.Campaign_Start_Date__c.addMonths(3);
			ctrl1.camp.Stage__c = 'Production';
			ctrl1.camp.Estimated_Cost__c = 21000;
			ctrl1.next();			
			
	        Test.startTest();
	        //try to submit the campaign as a user without role
	        ctrl1.submitForApproval();
	        for(ApexPages.Message msg :  ApexPages.getMessages())
	    	{
	    		//error message should diplay since user role is important in finding the approver
	    		system.assertEquals(msg.getSummary(),ConstantUtil.SUBMIT_FOR_APPROVAL_NO_ROLE_SPECIFIED);
			}
			
			//check if campiagn is auto-approved
            system.assertEquals(false,ctrl1.isAutoApproved,'User is not an approver so cost must be submitted');
            //check if campaign requires approval
	    	system.assertEquals(true,ctrl1.requiresApproval,'Campaign requires approval');
	    	//check if the campaign approval buton is enabled and display the right message for the user
	    	system.assertEquals(ConstantUtil.APPROVAL_BTN_LABEL_SUBMIT_CAMP_FOR_APPROVAL,ctrl1.approvalBtnLabel,'Campaign submittion button shows Cost In Approval');
			
			//add a role to the user in order to submit the campaign
	    	nonApproverUser.UserRoleId=[SELECT Id, Name FROM UserRole WHERE Name =: 'Sports Marketing Ops' limit 1].Id;
	    	update nonApproverUser;
			
			//submit campiagn for apporval
	    	ctrl1.submitForApproval();

	    	List<CW_Campaign__c> lCampaigns = [SELECT Id,Campaign_Start_Date__c,
	                           						  Campaign_End_Date__c,
	                           						  Estimated_Cost__c,
	                           						  Name,
	                           						  Cost_Approval_Status__c
	                        				   FROM CW_Campaign__c
	                                           WHERE Id =: ctrl1.camp.Id];
	    	Test.stopTest();
	    	//check if campaign status got updated after user submited the campaiagn
	    	system.assertEquals(lCampaigns[0].Cost_Approval_Status__c, 'In Approval');

	    }
    }

    static testMethod void AutoApprovalTest()
    {
    	initUsers();
    	initCustomSettings();
    	Test.startTest();

        // auto approved campaign --> when the submitter is the same person as the approver
    	system.runAs(approverUser)
    	{
	    	Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController ctrl2 = new CW_WizardController(new ApexPages.StandardController(new CW_Campaign__c()));
	    	ctrl2.camp.Name = 'AutoApproved Campaign';
	    	ctrl2.camp.OwnerId=approverUser.id;
	    	ctrl2.camp.Campaign_Start_Date__c = Date.today().addDays(1);
			ctrl2.camp.Campaign_End_Date__c = ctrl2.camp.Campaign_Start_Date__c.addMonths(3);
			ctrl2.camp.Stage__c = 'Production';
			ctrl2.camp.Estimated_Cost__c = 0;
			ctrl2.username = approverUser.Username;
			ctrl2.saveCampaign();

	    	system.assertEquals(ctrl2.requiresApproval,false);

	    	List<CW_Campaign__c> lCamps = [SELECT Id,Campaign_Start_Date__c,
						       						  Campaign_End_Date__c,
						       						  Estimated_Cost__c,
						       						  Name,
						       						  Cost_Approval_Status__c
						    				   FROM CW_Campaign__c
						                       WHERE Id =: ctrl2.camp.Id];

	    	system.assertEquals(lCamps[0].Cost_Approval_Status__c, 'Approved');
	    }
	    Test.stopTest();
    }
	public static testMethod void SubmitForApprovalNullCostTest()
	{
        initUsers();
    	initCustomSettings();


	    System.runAs(nonApproverUser)
	    {
       	 	//submit for approval with a null cost
	    	Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController ctrlNew = new CW_WizardController(new ApexPages.StandardController(new CW_Campaign__c()));
	    	ctrlNew.camp.Name = 'Submit Campaign with null cost';
	    	ctrlNew.camp.Stage__c = 'Production';
	    	ctrlNew.camp.Campaign_Start_Date__c = Date.today().addDays(1);
			ctrlNew.camp.Campaign_End_Date__c = ctrlNew.camp.Campaign_Start_Date__c.addMonths(3);
			ctrlNew.activePage = 'Business Case';
			ctrlNew.goToPage();
			ctrlNew.camp.Estimated_Cost__c = 21;
    		ctrlNew.next();

    		Test.startTest();

	    	system.assertEquals(ctrlNew.requiresApproval,true);
	    	system.assertEquals(ctrlNew.approvalBtnLabel,ConstantUtil.APPROVAL_BTN_LABEL_SUBMIT_CAMP_FOR_APPROVAL);

	    	ctrlNew.back();
	    	ctrlNew.camp.Estimated_Cost__c = null;
	    	ctrlNew.submitForApproval();

	    	for(ApexPages.Message msg :  ApexPages.getMessages())
	    	{
	    		system.assertEquals(msg.getSummary(),ConstantUtil.APPROVAL_BTN_LABEL_CRITERIA_NOT_MET);
			}

        Test.stopTest();
    	}
	}

    static testMethod void saveRecordWithoutCampaignName()
    {
    	initUsers();
    	initCustomSettings();

    	Test.startTest();

    	System.runAs(approverUser)
	    {
	    	// go throug first page
	    	Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(new CW_Campaign__c()));
	        wizCtrl.camp.Campaign_Start_Date__c = Date.today().addDays(1);
	        wizCtrl.camp.Campaign_End_Date__c = Date.today().addDays(30);
			wizCtrl.saveCampaign();

			for(ApexPages.Message msg :  ApexPages.getMessages())
	    	{
	    		system.assertEquals(msg.getSummary(),ConstantUtil.CAMPAIGN_SAVE_ERROR);
			}
	    }
		Test.stopTest();
    }

    static testMethod void changeEstimatedCostInApproval()
    {
    	initUsers();
    	initCustomSettings();

    	Test.startTest();

    	System.runAs(nonApproverUser)
	    {

	    	CW_Campaign__c camp = TestDataUtil.createCampaign();
        	camp.Cost_Approval_Status__c = 'In Approval';
        	insert camp;

	    	Test.setCurrentPage(Page.CW_Campaign_Information);
	    	CW_WizardController currCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			currCtrl.activePage = 'Business Case';
			currCtrl.goToPage();
	    	currCtrl.camp.Estimated_Cost__c=22000;
	    	currCtrl.saveCampaign();


			for(ApexPages.Message msg :  ApexPages.getMessages())
	    	{
	    		system.assertEquals(msg.getSummary(),ConstantUtil.CAMPAIGN_SAVE_COST_ERROR);
			}
	    }
		Test.stopTest();
    }

    static testMethod void autoSavedCampaign()
    {
    	initUsers();
    	initCustomSettings();

    	CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;

    	Test.startTest();

    	System.runAs(nonApproverUser)
	    {
	    	Test.setCurrentPage(Page.CW_Campaign_Information);
	    	CW_WizardController currCtrl = new CW_WizardController(new ApexPages.StandardController(camp));

			currCtrl.camp.Name ='AutoSaved Campaign';
			currCtrl.saveCampaign();

			Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID,currCtrl.camp.Id);

	    	currCtrl.activePage = 'Business Case';
			currCtrl.goToPage();
			currCtrl.camp.Estimated_Cost__c = 23000;

			Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID,currCtrl.camp.Id);

			currCtrl.activePage = 'Campaign Information';
			currCtrl.goToPage();
			currCtrl.camp.Campaign_Start_Date__c = Date.today().addDays(1);
			currCtrl.camp.Campaign_End_Date__c = Date.today().addDays(15);
			currCtrl.next();

			Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID,currCtrl.camp.Id);

			List<CW_Campaign__c> updatedCamp = [SELECT Id, Name,
														Campaign_Start_Date__c,
														Campaign_End_Date__c,
														Estimated_Cost__c
										 		FROM CW_Campaign__c
										 		WHERE Id =: currCtrl.camp.Id];

			system.assertEquals(updatedCamp[0].Name, currCtrl.camp.Name);
			system.assertEquals(updatedCamp[0].Campaign_Start_Date__c, currCtrl.camp.Campaign_Start_Date__c);
			system.assertEquals(updatedCamp[0].Campaign_End_Date__c, currCtrl.camp.Campaign_End_Date__c);
			system.assertEquals(updatedCamp[0].Estimated_Cost__c, currCtrl.camp.Estimated_Cost__c);
	    }
    }

    static testMethod void testCampaignAssetTypePage()
    {
    	initUsers();
    	initCustomSettings();

    	CW_WizardBrandLabelUtilTest.dataSetup();
    	CW_WizardAssetUtilTest.dataSetup();

        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        CW_WizardAssetUtilTest.associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
        // add one asset type to campaign
        Id mailerATId = [select id from CW_Asset_Type__c where Name = :TestDataUtil.MAILER limit 1].Id;
        insert new CW_Campaign_Asset_Type__c(Campaign__c = camp.Id, Asset_Type__c = mailerATId);

        Test.startTest();
        System.runAs(approverUser)
	    {
	        Test.setCurrentPage(Page.CW_Creative_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.activePage = 'Marcom Delivery';
			wizCtrl.goToPage();
			wizCtrl.initAssetTypeSelectionPage();
			
			for(WrapperUtil.SelectListWrapper slw : wizCtrl.campAssetTypeList)
			{
				if(slw.campAssetType.Asset_Type__r.Name == TestDataUtil.MAILER)
				{
					system.assert(slw.selected);	// assert values was correctly preselected
					slw.selected = false;	// deselect
				}
				if(slw.campAssetType.Asset_Type__r.Name == TestDataUtil.BANNER)
				{
					system.assert(!slw.selected);	// not selected
					slw.selected = true;	// select
				}
			}
			wizCtrl.saveCampaign();
	    }
	    Test.stopTest();

	    // check that mailer was deleted and banner added
	    system.assertEquals(1,[select count() from CW_Campaign_Asset_Type__c]);
	    system.assertEquals(1,[select count() from CW_Campaign_Asset_Type__c where Asset_Type__r.Name = :TestDataUtil.BANNER]);
    }

    static testMethod void testCampaignAssetPage()
    {
    	initUsers();
    	initCustomSettings();

    	CW_WizardBrandLabelUtilTest.dataSetup();
    	CW_WizardAssetUtilTest.dataSetup();

        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        CW_WizardAssetUtilTest.associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
        CW_WizardAssetUtilTest.addAllAssetTypesToCampaign(camp.Id);
        Integer catNum;

        Test.startTest();
        System.runAs(approverUser)
	    {
	        Test.setCurrentPage(Page.CW_Creative_Information);
			CW_WizardController wizCtrl = new CW_WizardController(new ApexPages.StandardController(camp));
			wizCtrl.activePage = 'Assets';
			wizCtrl.goToPage();
			catNum = wizCtrl.assetTypeOptions.get(0).size();
			wizCtrl.destroyPages();
	    }
	    Test.stopTest();

	    system.assertEquals(catNum,[select count() from CW_Campaign_Asset_Type__c]);
    }

     static testMethod void testUploadDocument()
     {

     	initUsers();
    	initCustomSettings();

		CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;

	    System.runAs(nonApproverUser)
	    {
	    	Test.setCurrentPage(Page.CW_Upload_Campaign_Attachment);
			CW_WizardController ctrlNew = new CW_WizardController(new ApexPages.StandardController(camp));

	    	ctrlNew.attachment.Name = 'test attachment';
	    	ctrlNew.attachment.Body = Blob.valueOf(file);
	    	ctrlNew.attachment.Description = 'test attach';

	    	ctrlNew.uploadFile();

	    	List<Attachment> attachments = [SELECT id, name FROM Attachment WHERE parent.id =: ctrlNew.camp.Id];
	        System.assertEquals(1, attachments.size());
	    }
     }

	static testMethod void testSubmitMarcomBrief()
	{
		initUsers();
    	initCustomSettings();

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

    	CW_Roadmap__c roadmap  = TestDataUtil.createRoadmap();
    	insert roadmap;

        System.runAs(nonApproverUser)
     	{
     		nonApproverUser.Department = 'Sport';
     		update nonApproverUser;

     		CW_Campaign__c camp = TestDataUtil.createCampaign();
     		camp.Roadmap__c = roadmap.Id;
	        insert camp;

	        CW_Campaign_Sites__c campSites = TestDataUtil.createCampaignSite(camp.Id, siteCatalogue.Id, language.Id);
	       	insert campSites;

	        Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController ctrlNew = new CW_WizardController(new ApexPages.StandardController(camp));

			ctrlNew.camp.Urgent_Campaign__c = true;
			ctrlNew.camp.Suggested_MarCom_Delivery_Date__c = Date.today().addDays(10);
	    	ctrlNew.camp.Main_Campaign_Business_Objective__c = 'test';
	    	ctrlNew.camp.Campaign_Focus__c = 'Retention';
	    	ctrlNew.camp.What_is_being_communicated__c ='test';
	    	ctrlNew.camp.Target_Audience_Insight__c = 'test';
	    	ctrlNew.saveCampaign();
	    	ctrlNew.submitMarcomBrief();
	    	
	    	roadmap.Approval_Status__c = 'Approved';
	    	update roadmap;
			
	    	ctrlNew.camp.Urgent_Campaign__c = false;
	    	ctrlNew.camp.Brief_Approval_Status__c = 'In Approval';
	    	ctrlNew.camp.Roadmap_Approval_Status__c = 'Approved';
	    	ctrlNew.next();
	    	
	    	ctrlNew.calcBriefRequiresApproval(camp);
	        System.assertEquals(false,ctrlNew.briefRequiresApproval);
	        System.assertEquals(ConstantUtil.APPROVAL_BTN_LABEL_CRITERIA_NOT_MET + ConstantUtil.SUBMIT_FOR_APPROVAL_BRIEF_SUBMISSION,ctrlNew.briefApprovalBtnLabel);

	    	camp = [SELECT Brief_Approval_Status__c,Stage__c
	    			FROM CW_Campaign__c
	    			WHERE Id =: camp.Id];

	    	System.assertEquals('Not Submitted',camp.Brief_Approval_Status__c);
	        System.assertEquals('Roadmap Approved',camp.Stage__c);

		}
	}

	static testMethod void testSubmitMarcomBriefUrgentCamp()
	{
		initUsers();
    	initCustomSettings();

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

    	CW_Roadmap__c roadmap  = TestDataUtil.createRoadmap();
    	insert roadmap;

        System.runAs(nonApproverUser)
     	{
     		nonApproverUser.Department = 'Sport';
     		update nonApproverUser;

     		CW_Campaign__c camp = TestDataUtil.createCampaign();
	        insert camp;

	        CW_Campaign_Sites__c campSites = TestDataUtil.createCampaignSite(camp.Id, siteCatalogue.Id, language.Id);
	       	insert campSites;

	        Test.setCurrentPage(Page.CW_Campaign_Information);
			CW_WizardController ctrlNew = new CW_WizardController(new ApexPages.StandardController(camp));

			ctrlNew.camp.Urgent_Campaign__c = true;
			ctrlNew.camp.Suggested_MarCom_Delivery_Date__c = Date.today().addDays(10);
	    	ctrlNew.camp.Main_Campaign_Business_Objective__c = 'test';
	    	ctrlNew.camp.Campaign_Focus__c = 'Retention';
	    	ctrlNew.camp.What_is_being_communicated__c ='test';
	    	ctrlNew.camp.Target_Audience_Insight__c = 'test';
	    	ctrlNew.saveCampaign();
	    	ctrlNew.submitMarcomBrief();

	    	ctrlNew.camp.Urgent_Campaign__c = false;
	    	ctrlNew.camp.Brief_Approval_Status__c = 'In Approval';
	    	ctrlNew.saveCampaign();

	    	camp = [SELECT Brief_Approval_Status__c,Stage__c
	    			FROM CW_Campaign__c
	    			WHERE Id =: camp.Id];

	    	System.assertEquals('Not Submitted',camp.Brief_Approval_Status__c);
	        System.assertEquals('Draft',camp.Stage__c);

		}
	}


    public static testMethod void checkApprovalStatusWithGreaterCostThanApprovedAmount()
    {
        initUsers();
        initCustomSettings();


        System.runAs(nonApproverUser)
        {

            Test.setCurrentPage(Page.CW_Campaign_Information);
            CW_WizardController ctrlNew = new CW_WizardController(new ApexPages.StandardController(new CW_Campaign__c()));
            ctrlNew.camp.Name = 'Entering higher cost should seek for approval';
            ctrlNew.camp.Campaign_Start_Date__c = Date.today().addDays(1);
            ctrlNew.camp.Campaign_End_Date__c = ctrlNew.camp.Campaign_Start_Date__c.addMonths(3);
            ctrlNew.camp.Stage__c = 'Production';
            ctrlNew.activePage = 'Business Case';
            ctrlNew.goToPage();
            ctrlNew.camp.Estimated_Cost__c = 50000;
            ctrlNew.saveCampaign();
             List<CW_Campaign__c> lCampaigns= [SELECT Name, Cost_Approval_Status__c     FROM CW_Campaign__c   WHERE Id =: ctrlNew.camp.Id];
             system.assertEquals(lCampaigns.size(), 1);
             lCampaigns[0].Approved_Amount__c=50000;
             lCampaigns[0].Cost_Approval_Status__c='Approved';
            update lCampaigns[0];
            Test.startTest();
            system.assertEquals(lCampaigns[0].Cost_Approval_Status__c,'Approved');

            ctrlNew = new CW_WizardController(new ApexPages.StandardController(lCampaigns[0]));
            ctrlNew.activePage = 'Business Case';
            ctrlNew.goToPage();
            ctrlNew.camp.Estimated_Cost__c = 75000;
            ctrlNew.next();
			 Test.stopTest();

             lCampaigns= [SELECT Name, Cost_Approval_Status__c     FROM CW_Campaign__c   WHERE Id =: ctrlNew.camp.Id];
             system.assertEquals(lCampaigns[0].Cost_Approval_Status__c,'Not Submitted');

        }

    }

        public static testMethod void checkApprovalStatusWithLessCostThanApprovedAmount()
    {
        initUsers();
        initCustomSettings();


        System.runAs(nonApproverUser)
        {

            Test.setCurrentPage(Page.CW_Campaign_Information);
            CW_WizardController ctrlNew = new CW_WizardController(new ApexPages.StandardController(new CW_Campaign__c()));
            ctrlNew.camp.Name = 'Entering lower cost should auto approve';
            ctrlNew.camp.Campaign_Start_Date__c = Date.today().addDays(1);
            ctrlNew.camp.Campaign_End_Date__c = ctrlNew.camp.Campaign_Start_Date__c.addMonths(3);
            ctrlNew.activePage = 'Business Case';
            ctrlNew.goToPage();
            ctrlNew.camp.Estimated_Cost__c = 50000;
            ctrlNew.saveCampaign();
            List<CW_Campaign__c> lCampaigns= [SELECT Name, Cost_Approval_Status__c     FROM CW_Campaign__c          WHERE Id =: ctrlNew.camp.Id];
            system.assertEquals(lCampaigns.size(), 1);
            lCampaigns[0].Approved_Amount__c=50000;
            lCampaigns[0].Cost_Approval_Status__c='Approved';
            update lCampaigns[0];
            Test.startTest();
             system.assertEquals(lCampaigns[0].Cost_Approval_Status__c,'Approved');

             ctrlNew = new CW_WizardController(new ApexPages.StandardController(lCampaigns[0]));
             ctrlNew.activePage = 'Business Case';
            ctrlNew.goToPage();
            ctrlNew.camp.Estimated_Cost__c = 45000;
            ctrlNew.saveCampaign();

			ctrlNew = new CW_WizardController(new ApexPages.StandardController(ctrlNew.camp));
            ctrlNew.activePage = 'Business Case';
            ctrlNew.goToPage();
            ctrlNew.camp.Estimated_Cost__c = 48000;
            ctrlNew.saveCampaign();
 			Test.stopTest();

             lCampaigns= [SELECT Name, Cost_Approval_Status__c     FROM CW_Campaign__c   WHERE Id =: ctrlNew.camp.Id];
             system.assertEquals(lCampaigns[0].Cost_Approval_Status__c,'Approved');

        }
    }

	static final String file = 'field1,field2,field3\n' +
					   		  + '1value1,1value2,1value3\n' +
					   		  + '2value1,2value2,2value3';
}