/**
* File Name   :    CW_WizardCampaignAssetUtilTest.cls
* Description :    B-114113
					Tabs per Asset type (based on Asset Types selected)
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 02/05/2014 Klea Kolaric	Intial
*
*/
@isTest
public with sharing class CW_WizardCampaignAssetUtilTest {
	
	static CW_Campaign__c dataSetup()
	{
		CW_WizardBrandLabelUtilTest.dataSetup();
    	CW_WizardAssetUtilTest.dataSetup();
        
        CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;
        CW_WizardAssetUtilTest.associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
        CW_WizardAssetUtilTest.addAllAssetTypesToCampaign(camp.Id);
        return camp;
	}
	
	static testMethod void testPageInit()
    {
        CW_Campaign__c camp = dataSetup();
        
        Test.startTest();
        
        Test.setCurrentPage(Page.CW_Assets);
		CW_WizardCampaignAssetUtil cwau = new CW_WizardCampaignAssetUtil();
		cwau.getInit();	// should not cause any kind of exception
		cwau.camp = camp;
		cwau.assetTypeId = [select Asset_Type__c from CW_Campaign_Asset_Type__c order by Name asc limit 1].Asset_Type__c;	// populate
		cwau.readOnly = false;
		cwau.getInit();
		cwau.getTextAreaType();
		cwau.isUserAllowedToAdd = cwau.IsUserAllowedToAddAsset();
		cwau.getDetailIdParam();
		
		Test.stopTest();
    }
    
    static testMethod void testAddAsset()
    {
    	CW_Campaign__c camp = dataSetup();
    	
    	// we will remove one language
    	String removedLang = TestDataUtil.SV;
    	delete [select id from CW_Campaign_Sites__c where Language__r.Name = :removedLang];
        
        Test.startTest();
        
        Test.setCurrentPage(Page.CW_Assets);
		CW_WizardCampaignAssetUtil cwau = new CW_WizardCampaignAssetUtil();
		cwau.camp = camp;
		cwau.assetTypeId = [select Asset_Type__c from CW_Campaign_Asset_Type__c order by Name asc limit 1].Asset_Type__c;	// populate
		cwau.readOnly = false;
		cwau.getInit();
		
		// create asset
		cwau.fieldSetQC = new List<Schema.FieldSetMember>();	// destroy fieldset to avoid leaving any required fields blank
		cwau.addAsset();	// this call fails because we didn't set asset
		Id assetId = (Id) cwau.assetOptions.get(1).getValue();	// first option is the empty one
		cwau.campAssetQC.Asset__c = assetId;
		cwau.addAsset();	// this time it should succeed
		
		Test.stopTest();
		
		system.assertEquals(1,[select count() from CW_Campaign_Asset__c where Campaign__c = :camp.Id and Asset__c = :assetId]);
		Integer assetCatCount = [select count() from CW_Asset_Catalogue__c where Asset__c = :assetId];
		Integer langCount = [select count() from CW_Language__c where Name != :removedLang];
		// due to data config all asset catalogues for asset will be added
		system.assertEquals(assetCatCount,[select count(Id) from CW_Localised_Asset__c group by Asset_Catalogue__c].size());
		// due to data config all languages (except removed one) will also be added
		system.assertEquals(langCount,[select count(Id) from CW_Localised_Asset__c group by Language__c].size());
    }
    
    static testMethod void testInlineEdit()
    {
        CW_Campaign__c camp = dataSetup();
        
        CW_Asset__c ast = [select id, Asset_Type__c from CW_Asset__c limit 1];
        // create asset selection on campaign
    	CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c();
    	ca.Campaign__c = camp.Id;
    	ca.Asset__c = ast.id;	// all assets are available
    	insert ca;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.CW_Assets);
		CW_WizardCampaignAssetUtil cwau = new CW_WizardCampaignAssetUtil();
		cwau.camp = camp;
		cwau.assetTypeId = ast.Asset_Type__c;	// populate
		cwau.readOnly = false;
		cwau.getInit();
		cwau.enterEditMode();
		cwau.saveInlineEdit();
		
		Test.stopTest();
    }
    
    static testMethod void testCopy()
    {
        CW_Campaign__c camp = dataSetup();
        
        CW_Asset__c ast = [select id, Asset_Type__c from CW_Asset__c limit 1];
        // create asset selection on campaign
    	CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c();
    	ca.Campaign__c = camp.Id;
    	ca.Asset__c = ast.id;	// all assets are available
    	insert ca;
    	CW_Localised_Asset__c la = new CW_Localised_Asset__c();
    	la.Campaign_Asset__c = ca.Id;
    	la.Language__c = [select id from CW_Language__c where Name = :TestDataUtil.EN limit 1].id;
    	String lab = TestDataUtil.BWINTEST + TestDataUtil.DOTCOM;
    	la.Asset_Catalogue__c = [select id from CW_Asset_Catalogue__c 
    								where Site_Catalogue__r.Label__r.Name = :lab limit 1].id;
    	insert la;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.CW_Assets);
		CW_WizardCampaignAssetUtil cwau = new CW_WizardCampaignAssetUtil();
		cwau.camp = camp;
		cwau.assetTypeId = ast.Asset_Type__c;	// populate
		cwau.readOnly = false;
		cwau.getInit();
		cwau.selectedCampAssetId = ca.Id;
		cwau.cloneCampAsset();
		
		Test.stopTest();
		
		system.assertEquals(1,[select count() from CW_Campaign_Asset__c where Id != :ca.Id]);
		system.assertEquals(1,[select count() from CW_Localised_Asset__c where Campaign_Asset__c != :ca.Id]);
    }
    
    static testMethod void testDelete()
    {
        CW_Campaign__c camp = dataSetup();
        
        CW_Asset__c ast = [select id, Asset_Type__c from CW_Asset__c limit 1];
        // create asset selection on campaign
    	CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c();
    	ca.Campaign__c = camp.Id;
    	ca.Asset__c = ast.id;	// all assets are available
    	insert ca;
    	CW_Localised_Asset__c la = new CW_Localised_Asset__c();
    	la.Campaign_Asset__c = ca.Id;
    	la.Language__c = [select id from CW_Language__c where Name = :TestDataUtil.EN limit 1].id;
    	String lab = TestDataUtil.BWINTEST + TestDataUtil.DOTCOM;
    	la.Asset_Catalogue__c = [select id from CW_Asset_Catalogue__c 
    								where Site_Catalogue__r.Label__r.Name = :lab limit 1].id;
    	insert la;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.CW_Assets);
		CW_WizardCampaignAssetUtil cwau = new CW_WizardCampaignAssetUtil();
		cwau.camp = camp;
		cwau.assetTypeId = ast.Asset_Type__c;	// populate
		cwau.readOnly = false;
		cwau.getInit();
		cwau.selectedCampAssetId = ca.Id;
		cwau.deleteCampAsset();
		
		Test.stopTest();
		
		system.assertEquals(0,[select count() from CW_Campaign_Asset__c where Id != :ca.Id]);
		system.assertEquals(0,[select count() from CW_Localised_Asset__c where Campaign_Asset__c != :ca.Id]);
    }
    
    //test is banner overall details field get saved for banner asset type
    static testMethod void testAssetBannerDetails()
    {
     	CW_Campaign__c camp = dataSetup();
     	
     	CW_Asset_Type__c assType = TestDatautil.createAssetType();
     	assType.Name = 'Banner';
     	insert assType;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.CW_Assets);
		CW_WizardCampaignAssetUtil cwau = new CW_WizardCampaignAssetUtil();
		cwau.camp = camp;
		cwau.assetTypeId = assType.Id;	// populate
		cwau.readOnly = false;
		cwau.getInit();
		
		cwau.camp.Banner_Overall_Details__c = 'test banner overall details saved successfully';
		cwau.saveBannerOverallToCampaign();
		
		camp = [SELECT Id, Banner_Overall_Details__c FROM CW_Campaign__c WHERE Id=: camp.Id];
		system.assertEquals('test banner overall details saved successfully',camp.Banner_Overall_Details__c);
    }

}