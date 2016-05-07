/**
* File Name   :    CW_CampaignRewardCompController.cls
* Description :    B-109691 - Reward Summary Table 
*				   that are linked to the campaign 
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 03/04/2014 Cristina P		Initial
*/
@isTest
public with sharing class CW_CampaignRewardCompControllerTest {

	public static CW_Campaign_Navigation_Settings__c 	cns1;
	public static CW_Campaign_Navigation_Settings__c 	cns2;
	
	
	public static void initCustomSettings()
	{
		cns1 = TestDataUtil.createCampaignNavigationSettings(Page.CW_Campaign_Information,1,false);
    	cns2 = TestDataUtil.createCampaignNavigationSettings(Page.CW_Audience,2,false);
    	insert new List<CW_Campaign_Navigation_Settings__c>{cns1,cns2};
    	
    	CW_CampaignListSettingHelper.getIntegerValue(ConstantUtil.REWARD_PAGE_SIZE,5);//Set page size to 5 recs
    	
	}
	
	static testMethod void standardSetControllerTest() 
	{
		initCustomSettings();
		
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
		CW_Offer_Type__c offerType = TestDataUtil.createOfferType('Operational Tool');
		insert offerType;
		
		CW_Reward_Type__c rewardType = TestDataUtil.createRewardType('FreeBet Amount');
		insert rewardType;
		
		CW_Reward_Catalogue__c rewardCat = TestDataUtil.createRewardCatalogue(offerType.Id,rewardType.Id);
		insert rewardCat;
		
		CW_Reward_Library__c rewardLib= TestDataUtil.createRewardLibrary(rewardType.Id);
		insert rewardLib;
		
		CW_Campaign_Offer__c campOffer = TestDataUtil.createCampaignOffer(camp.Id, offerType.Id);
		insert campOffer; 
		
		List<CW_Campaign_Reward__c> listRewards = new List<CW_Campaign_Reward__c>();
		for (Integer i=0;i<11;i++) 
		{
			listRewards.Add(TestDataUtil.createCampaignReward(campOffer.Id, rewardCat.Id, rewardLib.Id, rewardType.Id));
		}
		insert listRewards;
			
    	CW_CampaignRewardCompController compCtrl= new CW_CampaignRewardCompController();
    	compCtrl.campOfferId = campOffer.Id;
    	compCtrl.campOffer = campOffer;
    	compCtrl.offerTypeId = offerType.Id;
    	compCtrl.init();
    	compCtrl.getHasPrevious();
    	compCtrl.getHasNext();
    	compCtrl.getPageNumber();
    	compCtrl.getTotalPages();
    	compCtrl.getPageNumber();
    	compCtrl.campId=camp.Id;

		system.assertEquals(camp.Id	,compCtrl.campId);
		system.assertEquals(10		,compCtrl.getRewardList().Size());
		system.assertEquals(false  	,compCtrl.editMode);
		system.assertEquals(false 	,compCtrl.disabledButtons);
		system.assertEquals(true  	,compCtrl.getDeleteDisabled());
		system.assertEquals(2     	,compCtrl.getTotalPages());
		system.assertEquals(false 	,compCtrl.NewRecMode);
		system.assertEquals(false 	,compCtrl.editMode);
			
		compCtrl.selectAll = true;
		compCtrl.selectDeselectAllItems();
		system.assertEquals(10     ,compCtrl.getSelectedCount());
		system.assertEquals(false ,compCtrl.getDeleteDisabled());
			
		compCtrl.selectAll = false;
		compCtrl.selectDeselectAllItems();
		system.assertEquals(0     ,compCtrl.getSelectedCount());
		system.assertEquals(true  ,compCtrl.getDeleteDisabled());
			
		compCtrl.contextItem = listRewards[2].Id;
		compCtrl.doSelectItem();
		system.assertEquals(1     ,compCtrl.getSelectedCount());
		compCtrl.doDeselectItem();
		system.assertEquals(0     ,compCtrl.getSelectedCount());
			
		compCtrl.last();
		system.assertEquals(1     ,compCtrl.getRewardList().Size());
			
		compCtrl.doNext();
		system.assertEquals(2     ,compCtrl.getPageNumber());
		system.assertEquals(true  ,compCtrl.getHasPrevious());
		system.assertEquals(false ,compCtrl.getHasNext());
			
		compCtrl.doPrevious();
		system.assertEquals(false  ,compCtrl.getHasPrevious());
		system.assertEquals(true   ,compCtrl.getHasNext());
		
		compCtrl.selectedRewardIds.Add(listRewards[3].Id);
		compCtrl.selectedRewardIds.Add(listRewards[4].Id);
		system.assertEquals(false  ,compCtrl.getDeleteDisabled());
		compCtrl.getDeleteMessage();
		compCtrl.deleteRewards();

		system.assertEquals(9     ,compCtrl.getRewardList().Size());
		system.assertEquals(false  ,compCtrl.editMode);

		compCtrl.savedByParent =true;
		system.assertEquals(false  ,compCtrl.editMode);
		compCtrl.Cancel();
		system.assertEquals(false  ,compCtrl.editMode);
	}
	
	static testMethod void createCampaignReward() 
	{
		initCustomSettings();
		
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
		CW_Offer_Type__c offerType = TestDataUtil.createOfferType('Operational Tool');
		insert offerType;
		
		CW_Reward_Type__c rewardType = TestDataUtil.createRewardType('FreeBet Amount');
		insert rewardType;
		
		CW_Reward_Type__c cashRewardType = TestDataUtil.createRewardType('Cash');
		insert cashRewardType;
		
		CW_Reward_Catalogue__c rewardCat = TestDataUtil.createRewardCatalogue(offerType.Id,rewardType.Id);
		rewardCat.Library__c = true;
		insert rewardCat;
		
		rewardCat = TestDataUtil.createRewardCatalogue(offerType.Id,cashRewardType.Id);
		insert rewardCat;
		
		CW_Reward_Library__c rewardLib= TestDataUtil.createRewardLibrary(rewardType.Id);
		insert rewardLib;
		
		CW_Campaign_Offer__c campOffer = TestDataUtil.createCampaignOffer(camp.Id, offerType.Id);
		insert campOffer; 
		
		CW_CampaignRewardCompController compCtrl= new CW_CampaignRewardCompController();
    	compCtrl.campOfferId = campOffer.Id;
    	compCtrl.campOffer = campOffer;
    	compCtrl.offerTypeId = offerType.Id;
    	
    	compCtrl.addReward();
    	system.assertEquals(true,compCtrl.NewRecMode);
    	compCtrl.getRewardTypeOptions();

    	compCtrl.RewardTypeId = rewardType.Id;
    	compCtrl.getFields();
    	compCtrl.campOfferOrRewardHasLibrary();
    	system.assertEquals('OperationalToolFreeBetAmountFieldSet',compCtrl.fieldsetName,'Wrong fieldset');
    	system.assertEquals(true,compCtrl.hasLibrary,'Library lookup field is not displayed correctly');
    	
    	compCtrl.newRec.Reward_Type__c = cashRewardType.Id;
    	compCtrl.hasLibrary = false;
    	compCtrl.newRec.Currency__c = 'GBP';
    	compCtrl.newRec.Amount__c = 200;
    	compCtrl.SaveNewRecord();
    	List<CW_Campaign_Reward__c> campRewards = [SELECT Id FROM CW_Campaign_Reward__c WHERE Campaign_Offer__c =: compCtrl.campOfferId];
    	system.assertEquals(1,campRewards.size(),'Reward not created successfully');
    	
    	//create reward without amount and currency required fields
    	compCtrl.newRec.Reward_Type__c = cashRewardType.Id;
    	compCtrl.hasLibrary = false;
    	compCtrl.newRec.Currency__c =null;
    	compCtrl.newRec.Amount__c = null;
    	compCtrl.SaveNewRecord();
    	campRewards = [SELECT Id FROM CW_Campaign_Reward__c WHERE Campaign_Offer__c =: compCtrl.campOfferId AND Reward_Type__c=:cashRewardType.Id];
    	system.assertEquals(0,campRewards.size());
    	
    	//create reward without reward library required fields
    	compCtrl.rewardTypeId = rewardType.Id;
    	compCtrl.hasLibrary = compCtrl.campOfferOrRewardHasLibrary();
    	compCtrl.newRec.Reward_Library__c = null;
    	compCtrl.SaveNewRecord();
    	
    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	Boolean isErrorMsgDisplayed = false;
    	for(Apexpages.Message msg:msgs)
    	{
        	if (msg.getDetail().contains(ConstantUtil.REWARD_WITHOUT_LIBRARY))
        		isErrorMsgDisplayed = true;
    	}
    	system.assert(isErrorMsgDisplayed);//Assert the Page Message was Properly Displayed
    
	}
	
	static testMethod void createRewardLibrary() 
	{
		ApexCalloutListSetting__c acl = new ApexCalloutListSetting__c();
    	acl.Name = 'test';
    	acl.HttpRequest_Header_EndPoint__c = 'http://demo9292703.mockable.io/promoapi';
    	acl.HttpRequest_Header_Host__c = 'demo9292703.mockable.io';
    	acl.HttpRequest_Method__c = 'GET';
    	insert acl;
    	
		initCustomSettings();
		
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
		CW_Offer_Type__c offerType = TestDataUtil.createOfferType('Operational Tool');
		insert offerType;
		
		CW_Reward_Type__c rewardType = TestDataUtil.createRewardType('FreeBet Amount');
		insert rewardType;
		
		CW_Reward_Catalogue__c rewardCat = TestDataUtil.createRewardCatalogue(offerType.Id,rewardType.Id);
		rewardCat.Library__c = true;
		insert rewardCat;
		
		CW_Campaign_Offer__c campOffer = TestDataUtil.createCampaignOffer(camp.Id, offerType.Id);
		insert campOffer; 
		
		CW_CampaignRewardCompController compCtrl= new CW_CampaignRewardCompController();
		
    	compCtrl.campOfferId = campOffer.Id;
    	compCtrl.campOffer = campOffer;
    	compCtrl.offerTypeId = offerType.Id;
    	
    	compCtrl.campOfferOrRewardHasLibrary();
    	system.assertEquals(true,compCtrl.showLibrary,'Configure reward button is not displayed');
    	compCtrl.createRewardLibrary();
    	compCtrl.isMockAPI = true;
    	compCtrl.rewardTypeId = rewardType.Id;
    	
    	compCtrl.newLibrary.FreeBet_Name__c = 'Test FreeBet';
    	compCtrl.newLibrary.Customer_Facing_Name__c = 'Test Customer Name';
    	compCtrl.newLibrary.Amount__c = 200;
    	compCtrl.newLibrary.Currency__c = 'EURO';
    	compCtrl.newLibrary.Days_To_Use_By__c = TestDataUtil.getRandomNumber() + 1;
    	compCtrl.newLibrary.Days_To_Claim__c = TestDataUtil.getRandomNumber() + 1;
    	compCtrl.newLibrary.Max_Cap__c = 20;
    	compCtrl.newLibrary.Description__c = 'Test';
    	
    	compCtrl.saveLibrary();
    	
    	/*CW_Reward_Library__c rewardLib = [SELECT ID,FreeBet_Id__c FROM CW_Reward_Library__c WHERE Reward_Type__c =: compCtrl.rewardTypeId]; 
    	system.assert(rewardLib!=null,'Creating new reward library failed.');
    	system.assertEquals('12345',rewardLib.FreeBet_Id__c,'Wrong freebetId returned');
    	
    	CW_Campaign_Reward__c campReward = [SELECT Id,Code__c,Bonus_Id__c,Reward_Library__c FROM CW_Campaign_Reward__c WHERE Campaign_Offer__c =: compCtrl.campOfferId];
    	system.assertEquals('Test FreeBet',campReward.Code__c,'Campaign Reward not created successfully');
    	system.assertEquals('12345',campReward.Bonus_Id__c,'Campaign Reward not created successfully');
    	system.assertEquals(compCtrl.newLibrary.Id,campReward.Reward_Library__c,'Campaign Reward not created successfully');
		*/
	}
}