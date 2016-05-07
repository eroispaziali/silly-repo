@isTest
private class RESTfulCalloutPromoAPITest {

/**
* File Name   :    RESTfulCalloutPromoAPITest.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 08/05/2014 Chris Yorkston Initial version
* 0.1 29/05/2014 Chris Yorkston unit tests for promotion creation via Promo API
*
*
*/
     
     @isTest static void testCalloutToFreeBetCreationViaPromoAPI() {
        
        // setup data
		ApexCalloutListSetting__c testRecord = new ApexCalloutListSetting__c();
		testRecord.Name = ConstantUtil.APEX_CALLOUT_PROMO_API_FREEBET_CREATION_QA;
		testRecord.HttpRequest_Header_EndPoint__c 	= 'https://crmgateway170.ivycomptech.co.in/promoservice-v1/freebet';
		testRecord.HttpRequest_Header_Host__c 		= 'demo9292703.mockable.io';
		testRecord.HttpRequest_Method__c 			= 'POST';
		testRecord.HttpRequest_Header_Key__c 		= '';
		insert testRecord;
		
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Campaign_Start_Date__c = system.today().addDays(1);
		insert camp;
		
		CW_Brand__c brand = TestDataUtil.createBrand();
		insert brand;
		
		CW_Label__c label = TestDataUtil.createLabel(brand.Id);
		insert label;
		
		CW_Country__c country = TestDataUtil.createCountry();
		insert country;
		
		CW_Language__c lang = TestDataUtil.createLanguage();
		insert lang;
		
		CW_Product__c product = TestDataUtil.createProduct();
		insert product;
		
		CW_Site_Catalogue__c siteCat = TestDataUtil.createSiteCatalogue(label.Id, country.Id, product.Id);
		insert siteCat;
		
		CW_Site_Language__c siteLang = TestDataUtil.createSiteLanguage(siteCat.Id, lang.Id);
		insert siteLang;
		
		CW_Campaign_Sites__c campSite = TestDataUtil.createCampaignSites(camp.Id, siteCat.Id, lang.Id);
		insert campSite;
		
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		CW_Audience_Group__c ag = testDataUtil.createAudienceGroup(camp.Id);
		insert ag;
		
		CW_Audience_Group_Schedule__c ags = [SELECT Id,Name FROM CW_Audience_Group_Schedule__c 
											 WHERE Schedule__c =: sch.Id
											 AND Audience_Group__c =: ag.Id];//testDataUtil.createAudienceGroupSchedule(ag.Id, sch.Id);
		//insert ags;
		
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
		
		CW_Campaign_Reward__c campReward = TestDataUtil.createCampaignReward(campOffer.Id, rewardCat.Id, rewardLib.Id, rewardType.Id);
		insert campReward;
		
		CW_Audience_Group_Schedule_Reward__c agsr = new CW_Audience_Group_Schedule_Reward__c();
		agsr.Campaign_Reward__c = campReward.Id;
		agsr.Audience_Group_Schedule__c = ags.Id;
		agsr.Account_Currency_Code__c = 'EUR';
		insert agsr;
		
		rewardCat = [SELECT Id, Name, Reward_Type__r.Name FROM CW_Reward_Catalogue__c where Id =: rewardCat.Id];
		Map<String,String> headers = new Map<String,String>();
		headers.put('Content-Type','application/json');
		
		SingleRequestMock fakeResponse = new SingleRequestMock(
        	200, 
        	'Complete', 
        	'{"errorCode":"","errorMessage":"","freebetId":"12345","status":true}', 
        	headers
        );
        
        Test.startTest();
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        // Call method to test.
        // This causes a fake response to be sent from the class that implements HttpCalloutMock. 
        RESTfulCalloutPromoAPI restfulCalloutPromoAPI = new RESTfulCalloutPromoAPI(ConstantUtil.APEX_CALLOUT_PROMO_API_FREEBET_CREATION_QA);
        String freeBetId = restfulCalloutPromoAPI.getFreebetId(camp.Id, rewardLib, rewardCat);
        Test.stopTest();
        
        System.assertEquals('12345', freeBetId);
    }
}