/**
* File Name   :    CW_WizardRewardUtil .cls
* Description :    Select rewards and triggers
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.3 28/07/2014 Cristina P.	B-122940 Campaign Reward - Many Rewards per Trigger
*
*/
@isTest
private class CW_CampaignRewardTriggerHandlerTest {

    static testMethod void myUnitTest() 
    {
       	CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
		CW_Offer_Type__c offerType = TestDataUtil.createOfferType('Operational Tool');
		insert offerType;
		
		CW_Reward_Type__c rewardTypeAmount = TestDataUtil.createRewardType('FreeBet Amount');
		insert rewardTypeAmount;
		
		CW_Reward_Type__c rewardTypePercentage = TestDataUtil.createRewardType('FreeBet Percentage');
    	insert rewardTypePercentage;
		
		CW_Reward_Catalogue__c rewardCat = TestDataUtil.createRewardCatalogue(offerType.Id,rewardTypeAmount.Id);
		rewardCat.Library__c = true;
		insert rewardCat;
		
		rewardCat = TestDataUtil.createRewardCatalogue(offerType.Id,rewardTypePercentage.Id);
		rewardCat.Library__c = true;
		insert rewardCat;
		
		CW_Reward_Library__c rewardLibPercentage= TestDataUtil.createRewardLibrary(rewardTypePercentage.Id);
		insert rewardLibPercentage;
		
		CW_Reward_Library__c rewardLibAmount= TestDataUtil.createRewardLibrary(rewardTypeAmount.Id);
		insert rewardLibAmount;
		
		CW_Campaign_Offer__c campOffer = TestDataUtil.createCampaignOffer(camp.Id, offerType.Id);
		insert campOffer; 
		
		CW_Campaign_Reward__c campReward = TestDataUtil.createCampaignReward(campOffer.Id, rewardCat.Id, rewardLibAmount.Id, rewardTypeAmount.Id);
		insert campReward;
		
		campReward.Reward_Type__c = rewardTypePercentage.Id;
		update campReward;
		
		campReward = [SELECT Id,Code__c,Bonus_ID__c,Reward_Library__c FROM CW_Campaign_Reward__c WHERE Id =: campReward.Id];
    	
    	system.assertEquals(null,campReward.Code__c,'Reward not updated successfully');
    	system.assertEquals(null,campReward.Bonus_ID__c,'Reward not updated successfully');
    	system.assertEquals(null,campReward.Reward_Library__c,'Reward not updated successfully');
    	
    	campReward.Reward_Type__c = rewardTypeAmount.Id;
    	campReward.Reward_Library__c = rewardLibAmount.Id;
		update campReward;
		
		campReward = [SELECT Id,Code__c,Bonus_ID__c FROM CW_Campaign_Reward__c WHERE Id =: campReward.Id];
    	
    	system.assertEquals(null,campReward.Bonus_ID__c,'Reward not updated successfully');
    	
		
    }
}