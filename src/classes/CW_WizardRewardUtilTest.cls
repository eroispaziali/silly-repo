@isTest
private class CW_WizardRewardUtilTest 
{
    static testMethod void createCampaignOfferSuccesfully() 
    {
    	CW_Offer_Type__c offerType = TestDataUtil.createOfferType('Operational Tool');
    	insert offerType;
    	
    	CW_Reward_Type__c rewardType = TestDataUtil.createRewardType('FreeBet Amount');
    	insert rewardType;
    	
    	CW_Reward_Catalogue__c rewardCat = TestDataUtil.createRewardCatalogue(offerType.Id,rewardType.Id);
    	insert rewardCat;
    	
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        
        Test.setCurrentPage(Page.CW_New_Reward);
        Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID,camp.Id);
		
		CW_WizardRewardUtil wizRU = new CW_WizardRewardUtil();
		wizRU.getCampaignInfo();
		wizRU.emptyAction();
		
		List<Selectoption> offerOps = wizRU.getOfferTypeOptions();
    	
    	system.assertEquals(2,offerOps.size());
    	for(Selectoption ops : offerOps)
    	{
    		if(ops.getLabel() == 'Operational Tool')
    		{
    			wizRU.offerTypeId = (Id) ops.getValue();
    		}
    	}
    	
    	wizRU.addOffer();
    	List<CW_Campaign_Offer__c> campOffer = [SELECT Id,Name,Offer_Code__c,Offer_Id__c FROM CW_Campaign_Offer__c WHERE Campaign__c =:  camp.Id];
    	system.assertEquals(1,campOffer.size(),'New Campaign Offer was not successfully created.');
    	wizRu.offerTypeId = offerOps[1].getValue();
    	wizRu.getCampOfferFields();
    	system.assertEquals('OperationalTool_FieldSet',wizRU.fieldSetName,'Incorect fieldset');
    	
    	wizRu.enableCampOfferFields();
    	system.assertEquals(true,wizRu.editMode,'Campaign Offer fields are not editable');
    	
    	wizRu.campOffers[0].Offer_Code__c = 'TestCode';
    	wizRu.campOffers[0].Offer_Id__c = 'TestID';
    	
    	wizRu.saveChangesCampOffer();
    	
    	system.assertEquals(false,wizRu.editMode,'Campaign Offer fields are editable');
    	
    	campOffer = [SELECT Id,Offer_Code__c,Offer_Id__c FROM CW_Campaign_Offer__c WHERE Id =: wizRu.campOffer.Id];

    	system.assertEquals('TestCode',campOffer[0].Offer_Code__c,'Offer code not updated successfully.');
    	system.assertEquals('TestID',campOffer[0].Offer_Id__c,'Offer Id not updated successfully.');

    	wizRu.offerId = wizRu.campOffer.Id;
    	wizRu.deleteCampOffer();
    	campOffer = [SELECT Id,Offer_Code__c,Offer_Id__c FROM CW_Campaign_Offer__c WHERE Id =: wizRu.campOffer.Id];
    	system.assertEquals(0,campOffer.size(),'Campaign not deleted successfully');
    	
    	wizRU.offerTypeId = null;
    	wizRU.addOffer();
    	
    	campOffer = [SELECT Id,Name,Offer_Code__c,Offer_Id__c FROM CW_Campaign_Offer__c WHERE Campaign__c =:  camp.Id];
    	system.assertEquals(0,campOffer.size(),'New Campaign Offer cannot be created without asset type.');
    	
    	offerType = TestDataUtil.createOfferType('Static Promotion');
    	insert offerType;
    	
    	wizRu.offerTypeId = offerType.Id;
    	wizRu.addOffer();
    	system.assertEquals(false,wizRu.campOfferHasReward(wizRu.offerTypeId));
    }
}