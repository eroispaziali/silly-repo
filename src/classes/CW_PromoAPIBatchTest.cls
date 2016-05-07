@isTest
public with sharing class CW_PromoAPIBatchTest {
	 
	 @isTest static void testCalloutToPromotionCreationViaPromoAPI() {
        
        // setup data
		ApexCalloutListSetting__c testRecord = new ApexCalloutListSetting__c();
		testRecord.Name = ConstantUtil.APEX_CALLOUT_PROMO_API_PROMOTION_CREATION_QA;
		testRecord.HttpRequest_Header_EndPoint__c 	= 'https://crmgateway170.ivycomptech.co.in/promoservice-v1/campaign';
		testRecord.HttpRequest_Method__c 			= 'POST';
		testRecord.HttpRequest_Header_Key__c 		= '';
		insert testRecord;
		
		Contact contact = new Contact();
		contact.LastName = 'Test Contact';
		contact.Account_Name__c = '';
		insert contact;
		
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		camp.Campaign_Start_Date__c = system.today().addDays(1);
		camp.Cost_Approval_Status__c = 'Approved';
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
		
		CW_Audience_Group_Member__c agm = new CW_Audience_Group_Member__c();
		agm.Contact__c = contact.Id;
		agm.Audience_Group_Schedule__c = ags.Id;
		agm.Audience_Group_LU__c = ag.id;
		insert agm;
		
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
		
		CW_Audience_Group_Member_Reward__c agmr = new CW_Audience_Group_Member_Reward__c();
		agmr.Audience_Group_Schedule_Reward__c = agsr.Id;
		agmr.Audience_Group_Member__c = agm.Id;
		insert agmr;
		
		Map<String,String> headers = new Map<String,String>();
		headers.put('Content-Type','application/json');
		
		SingleRequestMock fakeResponse = new SingleRequestMock(
        	200, 
        	'Complete', 
        	'{"campaignId": "'+camp.Id+'","campaignStatus": true,"responseMessage": "SUCCESS","PromoResponseList": [{"internalId": "'+ags.id +'","promoStatus": true,"promoId": 109825,"errorCode": null,"errorMessage": null}]}', 
        	headers
        );
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, fakeResponse);
		
		Test.startTest();
		CW_PromoAPIBatchClass promoAPI = new CW_PromoAPIBatchClass(ConstantUtil.APEX_CALLOUT_PROMO_API_PROMOTION_CREATION_QA);
		promoAPI.updatePromoID();
        Test.stopTest();
        
        CW_Audience_Group_Schedule_Reward__c agsrUpdated = [SELECT id,PromoId__c
    												 		FROM CW_Audience_Group_Schedule_Reward__c 
    												 		WHERE Campaign_Reward__r.Campaign_Offer__r.Campaign__c =:camp.Id];
    	system.assertEquals('109825', agsrUpdated.PromoId__c);
    }

}