@isTest
private class CW_AssociateAudienceRewardHelperTest 
{

	static testMethod void myUnitTest() 
	{
    	//create Camp
   		CW_Campaign__c camp = TestDataUtil.createCampaign();
      	camp.Recurrence_Type__c = 'Recurring';
      	insert camp;
      	
    	//create Groups    
      	List<CW_Audience_Group__c> listGroups = TestDataUtil.createAudienceGroups(camp.Id,5);
      	listGroups[0].Is_Control_Group__c=false;
      	listGroups[1].Is_Control_Group__c=false;
      	listGroups[2].Is_Control_Group__c=false;
      	insert listGroups;
      	
      	//create shedule
      	List<CW_Schedule__c> shedLst= new List<CW_Schedule__c> ();
      	shedLst.Add(TestDataUtil.createSchedule(Camp));
      	shedLst.Add(TestDataUtil.createSchedule(Camp));
      	shedLst.Add(TestDataUtil.createSchedule(Camp));
		insert shedLst;
		
      	//Create rewards
		CW_Offer_Type__c offerType = TestDataUtil.createOfferType('Operational Tool');
    	insert offerType;
    	
    	CW_Reward_Type__c rewardType = TestDataUtil.createRewardType('FreeBet Amount');
    	insert rewardType;
    	
    	CW_Reward_Catalogue__c rewardCat = TestDataUtil.createRewardCatalogue(offerType.Id,rewardType.Id);
    	insert rewardCat;
    	CW_Reward_Library__c rewardLib= TestDataUtil.createRewardLibrary(rewardType.Id);
		insert rewardLib;
		
		//create Camp Offer
   		CW_Campaign_Offer__c campOffer = TestDataUtil.createCampaignOffer(camp.Id, offerType.Id);
      	insert campOffer;
		
		List<CW_Campaign_Reward__c> listRewards = new List<CW_Campaign_Reward__c>();
		listRewards.Add(TestDataUtil.createCampaignReward(campOffer.id,rewardCat.Id,rewardLib.Id,rewardType.Id));
		listRewards.Add(TestDataUtil.createCampaignReward(campOffer.id,rewardCat.Id,rewardLib.Id,rewardType.Id));
		listRewards.Add(TestDataUtil.createCampaignReward(campOffer.id,rewardCat.Id,rewardLib.Id,rewardType.Id));
		
		insert listRewards;
		System.AssertEquals(15, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Schedule__c '));
		 
		CW_AssociateAudienceRewardHelper ctrHlpr= new CW_AssociateAudienceRewardHelper(camp.Id);
		
		//Insert new records select only one reward and one group
		ctrHlpr.contextItem=''+shedLst[0].Id+listGroups[0].id+listRewards[1].id;
		ctrHlpr.doSelectGroupReward();
		ctrHlpr.contextItem=''+shedLst[1].Id+listGroups[0].id+listRewards[1].id;
		ctrHlpr.doSelectGroupReward();
		ctrHlpr.contextItem=''+shedLst[2].Id+listGroups[0].id+listRewards[1].id;
		ctrHlpr.doSelectGroupReward();
		
		System.AssertEquals(1, getBoolCount(ctrHlpr.getCheckkAgs().Values()));
		System.AssertEquals(3, getBoolCount(ctrHlpr.getCheckkAgsr().Values()));
		ctrHlpr.PresistChages();
		System.AssertEquals(15, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Schedule__c ')); 	
		System.AssertEquals(3, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Schedule_Reward__c '));
		
		ctrHlpr.contextItem=''+shedLst[0].Id+listGroups[0].id+listRewards[0].id;
		ctrHlpr.doSelectGroupReward();
		ctrHlpr.contextItem=''+shedLst[1].Id+listGroups[1].id+listRewards[1].id;
		ctrHlpr.doSelectGroupReward();
		ctrHlpr.contextItem=''+shedLst[2].Id+listGroups[2].id+listRewards[2].id;
		ctrHlpr.doSelectGroupReward();
		System.AssertEquals(4, getBoolCount(ctrHlpr.getCheckkAgs().Values()));
		System.AssertEquals(6, getBoolCount(ctrHlpr.getCheckkAgsr().Values()));
		ctrHlpr.PresistChages();
		System.AssertEquals(15, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Schedule__c ')); 	//all posible scheduled
		System.AssertEquals(6, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Schedule_Reward__c '));
		
		ctrHlpr= new CW_AssociateAudienceRewardHelper(camp.Id);
		
		//Recheck 
		ctrHlpr.contextItem=''+shedLst[0].Id+listGroups[0].id+listRewards[0].id;
		ctrHlpr.doDeSelectGroupReward();
		ctrHlpr.contextItem=''+shedLst[0].Id+listGroups[0].id+listRewards[0].id;
		ctrHlpr.doSelectGroupReward();
		System.AssertEquals(4, getBoolCount(ctrHlpr.getCheckkAgs().Values()));
		System.AssertEquals(6, getBoolCount(ctrHlpr.getCheckkAgsr().Values()));
		
		ctrHlpr.contextItem=''+shedLst[1].Id+listGroups[2].id+listRewards[0].id;
		ctrHlpr.doSelectGroupReward();
		System.AssertEquals(5, getBoolCount(ctrHlpr.getCheckkAgs().Values()));
		System.AssertEquals(7, getBoolCount(ctrHlpr.getCheckkAgsr().Values()));
		
		ctrHlpr.contextItem=''+listGroups[2].id+listRewards[0].id;
		ctrHlpr.doDeSelectGroupSchedule();
		System.AssertEquals(4, getBoolCount(ctrHlpr.getCheckkAgs().Values()));
		System.AssertEquals(6, getBoolCount(ctrHlpr.getCheckkAgsr().Values()));
		
		ctrHlpr.contextItem=''+listGroups[0].id+listRewards[0].id;
		ctrHlpr.doDeSelectGroupSchedule();
		System.AssertEquals(5, getBoolCount(ctrHlpr.getCheckkAgsr().Values()));
		
		//Delete records
		ctrHlpr.contextItem=''+shedLst[0].Id+listGroups[0].id+listRewards[0].id;
		ctrHlpr.doDeSelectGroupReward();
		ctrHlpr.contextItem=''+listGroups[0].id+listRewards[1].id;
		ctrHlpr.doDeSelectGroupSchedule();
		System.AssertEquals(4, getBoolCount(ctrHlpr.getCheckkAgs().Values()));
		System.AssertEquals(2, getBoolCount(ctrHlpr.getCheckkAgsr().Values()));
		ctrHlpr.PresistChages();
		//No delete		
		System.AssertEquals(15, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Schedule__c ')); 	
		System.AssertEquals(2, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Schedule_Reward__c '));
	}
   
   	private static integer getBoolCount(List<Boolean> bvl)
   	{
		integer i=0;
   		for(Boolean bv:bvl)
   		{
   			if(bv)i+=1;
   		}
   		return i;
	} 
}