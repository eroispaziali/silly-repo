/**
* File Name   :    CW_WizardAssetUtilTest.cls
* Description :    B-106848/50/52
*                  asset selection functionality
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 26/03/2014 Klea Kolaric	Initial version
* 0.2 30/04/2014 Klea Kolaric	Fixes due to B-106849
* 0.3 14/05/2014 Klea Kolaric	B-108923 show Messaging related list
*
*
*/
@isTest
public with sharing class CW_WizardAssetUtilTest {
	
	private static testMethod void assertDataCreationTest()
    {
    	CW_WizardBrandLabelUtilTest.dataSetup();
    	Test.startTest();
    	dataSetup();
    	Test.stopTest();
    	
    	testDataSetup();
    }
    
    private static testMethod void testNewAssetHappyPathEditCountrySpecific()
    {
    	CW_WizardBrandLabelUtilTest.dataSetup();
    	dataSetup();
    	
    	CW_Campaign__c camp = TestDataUtil.createCampaign();
    	insert camp;
    	associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
    	addAllAssetTypesToCampaign(camp.Id);
    	
    	Id assetTypeId = [select id from CW_Asset_Type__c where Country_Specific__c = true limit 1].id;
    	CW_Campaign_Asset__c ca = createCampAsset(assetTypeId,camp);
    	
    	Test.setCurrentPage(Page.CW_Campaign_Asset_Details);
    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPASSETID,ca.Id);
    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE,'false');
    	
    	Test.startTest();
    	
    	CW_WizardAssetUtil wau = new CW_WizardAssetUtil();
    	
    	system.assertNotEquals(wau.campAsset.Id,null);
    	system.assert(wau.getCountrySpecific());
    	
    	system.assertEquals(TestDataUtil.getBrandList().size()*TestDataUtil.getProductList().size()*(TestDataUtil.getCountryList().size()-2)
    		+ TestDataUtil.getBrandList().size()*(TestDataUtil.getProductList().size()-1)*(TestDataUtil.getLabelDomainsList().size()-1),
    		wau.languageMatrix.size());
    	system.assertEquals(TestDataUtil.getLanguageList().size(),wau.languageColumns.size());
    	
    	// deselect all options (will be selected by default) and do some asserts
    	String siteCatName;
    	for(WrapperUtil.SelectListWrapper slw : wau.languageMatrix)
    	{
    		slw.deselectAll();
    		// single country domains
    		if(slw.siteCat.Label__r.Name.endsWith(TestDataUtil.DOTDE) || slw.siteCat.Label__r.Name.endsWith(TestDataUtil.DOTFR))
    		{
    			system.assert(slw.showRow);
    		}
    		// find sitecat used to show selection row for BWIN.com UK
    		if(slw.showRow && slw.siteCat.Label__r.Name == (TestDataUtil.BWINTEST+TestDataUtil.DOTCOM) 
    			&& slw.siteCat.Country__r.Name == TestDataUtil.UNITEDKINGDOM && slw.siteCat.Product__r.Name == TestDataUtil.SPORTS)
    		{
    			siteCatName = slw.siteCat.Name;
    		}
    	}
    	system.assert(TestDataUtil.checkMatrix(wau.languageMatrix,siteCatName,TestDataUtil.EN));
    	system.assert(TestDataUtil.checkMatrix(wau.languageMatrix,siteCatName,TestDataUtil.GA));
    	wau.saveNewAssets();
    	
    	Test.stopTest();
    	
    	// all site cats in the system are covered by asset cats
    	List<CW_Site_Catalogue__c> siteCats = [select id from CW_Site_Catalogue__c 
    			where Label__r.Name = :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM) and Country__r.Name = :TestDataUtil.UNITEDKINGDOM
    			and Product__r.Name = :TestDataUtil.SPORTS];
    			
    	system.assertEquals(1,[select count() from CW_Campaign_Asset__c where Campaign__c = :camp.Id and Asset__c = :ca.Asset__c]);
    	
    	system.assertEquals([select count() from CW_Site_Language__c 
    			where (Language__r.Name = :TestDataUtil.EN or Language__r.Name = :TestDataUtil.GA) and Site_Catalogue__c in :siteCats]
    		,[select count() from CW_Localised_Asset__c 
    			where Campaign_Asset__r.Campaign__c = :camp.Id and Asset_Catalogue__r.Site_Catalogue__c in :siteCats]);
    }
    
    private static testMethod void testNewAssetHappyPathEditNonCountrySpecific()
    {
    	CW_WizardBrandLabelUtilTest.dataSetup();
    	dataSetup();
    	
    	// keep only bwin.com domain
    	delete [select id from CW_Asset_Catalogue__c where Site_Catalogue__r.Label__r.Name != :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM)];
    	delete [select id from CW_Site_Catalogue__c where Label__r.Name != :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM)];
    	system.assertEquals((TestDataUtil.getCountryList().size()-2)*TestDataUtil.getProductList().size(),
    							[select count() from CW_Site_Catalogue__c]);
    	
    	CW_Campaign__c camp = TestDataUtil.createCampaign();
    	insert camp;
    	associateSiteCataloguesToCampaign(new List<String>{TestDataUtil.BANNER}, camp.Id);
    	addAllAssetTypesToCampaign(camp.Id);
    	
    	Id assetTypeId = [select id from CW_Asset_Type__c where Country_Specific__c = false and Name = :TestDataUtil.BANNER limit 1].id;
    	CW_Campaign_Asset__c ca = createCampAsset(assetTypeId,camp);
    	
    	Test.setCurrentPage(Page.CW_Campaign_Asset_Details);
    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPASSETID,ca.Id);
    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE,'false');
    	
    	Test.startTest();
    	
    	CW_WizardAssetUtil wau = new CW_WizardAssetUtil();
    	
    	system.assert(!wau.getCountrySpecific());
    	
    	system.assertEquals(1*TestDataUtil.getProductList().size(),wau.languageMatrix.size());
    	system.assertEquals(TestDataUtil.getLanguageList().size()-2,wau.languageColumns.size());
    	
    	// deselect all options (will be selected by default) and do some asserts
    	String siteCatName;
    	for(WrapperUtil.SelectListWrapper slw : wau.languageMatrix)
    	{
    		slw.deselectAll();
    		system.assert(slw.showRow);
			if(slw.siteCat.Product__r.Name == TestDataUtil.SPORTS)
			{
				siteCatName = slw.siteCat.Name;
			}
    	}
    	
    	system.assert(TestDataUtil.checkMatrix(wau.languageMatrix,siteCatName,TestDataUtil.EN));
    	system.assert(TestDataUtil.checkMatrix(wau.languageMatrix,siteCatName,TestDataUtil.GA));
    	wau.saveNewAssets();
    	
    	Test.stopTest();
    	
    	// all site cats in the system are covered by asset cats
    	List<CW_Site_Catalogue__c> siteCats = [select id from CW_Site_Catalogue__c 
    			where Label__r.Name = :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM) and Country__r.Name = :TestDataUtil.UNITEDKINGDOM
    			and Product__r.Name = :TestDataUtil.SPORTS];
    			
    	system.assertEquals(1,[select count() from CW_Campaign_Asset__c where Campaign__c = :camp.Id and Asset__c = :ca.Asset__c]);
    	
    	system.assertEquals([select count() from CW_Site_Language__c 
    			where (Language__r.Name = :TestDataUtil.EN or Language__r.Name = :TestDataUtil.GA) and Site_Catalogue__c in :siteCats]
    		,[select count() from CW_Localised_Asset__c 
    			where Campaign_Asset__r.Campaign__c = :camp.Id and Asset_Catalogue__r.Site_Catalogue__c in :siteCats]);
    }
    
    private static testMethod void testEditAsset()
    {
    	CW_WizardBrandLabelUtilTest.dataSetup();
    	dataSetup();
    	
    	// keep only bwin.com domain
    	delete [select id from CW_Asset_Catalogue__c where Site_Catalogue__r.Label__r.Name != :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM)];
    	delete [select id from CW_Site_Catalogue__c where Label__r.Name != :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM)];
    	
    	CW_Campaign__c camp = TestDataUtil.createCampaign();
    	insert camp;
    	associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
    	
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
    	
    	Test.setCurrentPage(Page.CW_Campaign_Asset_Details);
    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPASSETID,ca.Id);
    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE,'false');
    	
    	Test.startTest();
    	
    	CW_WizardAssetUtil wau = new CW_WizardAssetUtil();
    	
    	system.assert(!wau.getCountrySpecific());
    	
    	// confirm needs option is selected
    	for(WrapperUtil.SelectListWrapper slw : wau.languageMatrix)
    	{
    		if(slw.showRow)
    		{
    			system.assert(!TestDataUtil.checkMatrix(wau.languageMatrix,slw.siteCat.Name,TestDataUtil.EN));
    			system.assert(TestDataUtil.checkMatrix(wau.languageMatrix,slw.siteCat.Name,TestDataUtil.GA));
    		}
    	}
    	wau.saveNewAssets();
    	
    	Test.stopTest();
    	
    	system.assertEquals(0,[select count() from CW_Localised_Asset__c 
    							where Campaign_Asset__c = :ca.Id and Language__r.Name = :TestDataUtil.EN]);
    	system.assertEquals((TestDataUtil.getCountryList().size()-2)*TestDataUtil.getProductList().size(),
    		[select count() from CW_Localised_Asset__c where Campaign_Asset__c = :ca.Id and Language__r.Name = :TestDataUtil.GA]);
    		
    	// coverage
    	wau.getRetUrl();
    }
    
    private static testMethod void testMessagingForMailer()
    {
    	// if this field set doesn't exist, there is no point in executing test
    	if(Schema.sObjectType.CW_Messaging__c.FieldSets.getMap().containsKey(TestDataUtil.MAILER))
    	{
    		CW_WizardBrandLabelUtilTest.dataSetup();
	    	dataSetup();
	    	
	    	CW_Campaign__c camp = TestDataUtil.createCampaign();
	    	insert camp;
	    	associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
	    	addAllAssetTypesToCampaign(camp.Id);
	    	
	    	// create asset selection on campaign
	    	CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c();
	    	ca.Campaign__c = camp.Id;
	    	ca.Asset__c = [select id from CW_Asset__c where Name = :(TestDataUtil.MAILER+' '+TestDataUtil.BASIC) limit 1].id;
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
	    	
	    	// pre add messaging object
	    	CW_Messaging__c msg1 = new CW_Messaging__c(Campaign_Asset__c = ca.Id, Dispatch_Date__c = Date.Today().addDays(2));
	    	insert msg1;
	    	
	    	Test.setCurrentPage(Page.CW_Campaign_Asset_Details);
	    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPASSETID,ca.Id);
	    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE,'false');
    	
    		Test.startTest();
    	
    		CW_WizardAssetUtil wau = new CW_WizardAssetUtil();
    		wau.campAsset.Purpose__c = 'test';
    		system.assertEquals(1,wau.msgList.size());
    		List<Schema.FieldSetMember> msgFields = wau.msgFields;
    		
    		wau.addNewMessaging();
    		CW_Messaging__c msg2 = wau.msgList.get(wau.msgList.size()-1);
    		msg2.Dispatch_Date__c = Date.Today().addDays(3);
    		wau.msgFields.clear();	// avoid required fields
    		wau.saveEdit();
    		
    		msg2.Approval_Status__c = 'Rejected';
    		update msg2;
    		
    		wau.msgFields = msgFields;
    		wau.initMessaging();
    		system.assertEquals(2,wau.msgList.size());
    		
    		Date changeDate = Date.Today().addDays(1);
    		wau.inlineEdit();
    		for(CW_Messaging__c msg : wau.msgList)
    		{
    			if(msg.Id == msg2.Id)
    			{
    				msg.Dispatch_Date__c = changeDate;
    			}
    		}
    		wau.msgFields.clear();	// avoid required fields
    		wau.saveEdit();
    		wau.msgFields = msgFields;
    		wau.initMessaging();
    		system.assertEquals(2,wau.msgList.size());
    		
    		for(CW_Messaging__c msg : wau.msgList)
    		{
    			if(msg.Id == msg2.Id)
    			{
    				system.assertEquals(msg.Dispatch_Date__c,changeDate);
    			}
    		}
	    	system.assertEquals(1,[select count() from CW_Messaging__c where  Id = :msg2.Id]);
	    	wau.deleteMsgId = msg1.Id;
	    	wau.deleteMsg();
	    	//system.assertEquals(1,wau.msgList.size());
	    	
	    	wau.cancelEdit();
	    	wau.getMessagingAvailable();
	    	wau.getShowInlineEditButton();
	    	
	    	Test.stopTest();
	    	
	    	system.assertEquals(1,[select count() from CW_Messaging__c]);
	    	system.assertEquals(1,[select count() from CW_Messaging__c 
	    		where Campaign_Asset__c = :ca.Id and Id = :msg2.Id]);
    	}
    	
    	
    }
    
    private static testMethod void testMessagingForTeaser()
    {
    	// if this field set doesn't exist, there is no point in executing test
    	if(Schema.sObjectType.CW_Messaging__c.FieldSets.getMap().containsKey(TestDataUtil.TEASER))
    	{
    		CW_WizardBrandLabelUtilTest.dataSetup();
	    	dataSetup();
	    	
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
	    	
	    	CW_Campaign__c camp = TestDataUtil.createCampaign();
	    	insert camp;
	    	
	    	CW_Campaign_Sites__c campSite = TestDataUtil.createCampaignSite(camp.Id, siteCatalogue.Id, language.Id);
	    	insert campSite;
	    	
        	CW_Asset_Type__c assetType = new CW_Asset_Type__c();
        	assetType.Name = 'Teaser';
			insert assetType;

	        CW_Asset__c asst = new CW_Asset__c();
    	    asst.Name = 'C1(Casino)';
        	asst.Asset_Type__c = assetType.Id;
        	insert asst;
	    	
	    	associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
	    	addAllAssetTypesToCampaign(camp.Id);
	    	
	    	// create asset selection on campaign
	    	CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c();
	    	ca.Campaign__c = camp.Id;
	    	ca.Asset__c = asst.Id;
	    	insert ca;
	    	
	    	CW_Asset_Catalogue__c assetCat = TestDataUtil.createAssetCatalogue(siteCatalogue.Id, asst.Id);
	    	insert assetCat;
	    	
	    	List<CW_Localised_Asset__c> loc = new List<CW_Localised_Asset__c>();
	    	Id enId = [select id from CW_Language__c where Name = :TestDataUtil.EN limit 1].id;
	    	
	    	for(CW_Asset_Catalogue__c ac : [select id,Site_Catalogue__r.Label__r.Name from CW_Asset_Catalogue__c where Asset__c = :asst.Id])
	    	{
	    		CW_Localised_Asset__c la = new CW_Localised_Asset__c();
	    		la.Campaign_Asset__c = ca.Id;
	    		la.Asset_Catalogue__c = ac.Id;
	    		la.Language__c = enId;
	    		loc.add(la);
	    	}
	    	insert loc;

	    	// pre add messaging object
	    	CW_Messaging__c msg1 = new CW_Messaging__c(Campaign_Asset__c = ca.Id, Label__c = label.Id, Live_Date__c = Date.Today().addDays(2),End_Date__c = Date.Today().addDays(10));
	    	insert msg1;
	    	
	    	Test.setCurrentPage(Page.CW_Campaign_Asset_Details);
	    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPASSETID,ca.Id);
	    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE,'false');
    	
    		Test.startTest();
    	
    		CW_WizardAssetUtil wau = new CW_WizardAssetUtil();
    		system.assertEquals(1,wau.msgList.size());
    		List<Schema.FieldSetMember> msgFields = wau.msgFields;
    		
    		for (WrapperUtil.SelectListWrapper slw:  wau.languageMatrix)
			{
				for (WrapperUtil.SelectWrapper sw: slw.subObjects)
				{
					sw.selected = true;
				}
			}
    		
    		wau.addNewMessaging();
    		CW_Messaging__c msg2 = wau.msgList.get(wau.msgList.size()-1);
    		
    		msg2.Label__c = siteCatalogue.Label__c;
    		msg2.Live_Date__c = Date.Today().addDays(3);
    		msg2.End_Date__c =  Date.Today().addDays(13);
    		//wau.msgFields.clear();	// avoid required fields
    		wau.getIsAddMode();
    		wau.saveEdit();
    		
    		msg2.Approval_Status__c = 'Rejected';
    		//Cristina P: 01/09/14: Sunnetha please fix. Sorry but I don't know what is the messaging new functionality
    		/*update msg2; 
			
    		wau.msgFields = msgFields;
    		wau.initMessaging();
    		//system.assertEquals(2,wau.msgList.size());
    		
    		Date changeDate = Date.Today().addDays(1);
    		wau.inlineEdit();
    		for(CW_Messaging__c msg : wau.msgList)
    		{
    			if(msg.Id == msg2.Id)
    			{
    				msg.Live_Date__c = changeDate;
    			}
    		}
    		wau.msgFields.clear();	// avoid required fields
    		wau.saveEdit();
    		wau.msgFields = msgFields;
    		wau.initMessaging();
    		system.assertEquals(2,wau.msgList.size());
    		
    		for(CW_Messaging__c msg : wau.msgList)
    		{
    			if(msg.Id == msg2.Id)
    			{
    				system.assertEquals(msg.Live_Date__c,changeDate);
    			}
    		}
    		
	    	wau.deleteMsgId = msg1.Id;
	    	wau.deleteMsg();
	    	//system.assertEquals(1,wau.msgList.size());
	    	
	    	wau.cancelEdit();
	    	wau.getMessagingAvailable();
	    	wau.getShowInlineEditButton();
	    	
	    	Test.stopTest();
	    	
	    	system.assertEquals(1,[select count() from CW_Messaging__c]);
	    	system.assertEquals(1,[select count() from CW_Messaging__c 
	    		where Campaign_Asset__c = :ca.Id and Id = :msg2.Id]);
    		*/
    		CW_Label__c newlabel = TestDataUtil.createLabel(brand.Id);
	        newlabel.Name = 'Cristina Label';
	        insert newlabel;
    		
    		wau.addNewMessaging();
    		CW_Messaging__c msg3 = wau.msgList.get(wau.msgList.size()-1);
    		
    		msg3.Label__c = newlabel.Id;
    		msg2.Live_Date__c = Date.Today().addDays(3);
    		msg2.End_Date__c =  Date.Today().addDays(13);
    		//wau.msgFields.clear();	// avoid required fields
    		wau.saveEdit();
    		
    		system.assertEquals(0,[select count() from CW_Messaging__c 
	    		where Campaign_Asset__c = :ca.Id and Id = :msg3.Id]);
	    		
    	}
    }
    
    /*** HELPER METHODS ***/
	
	// best to execute CW_WizardBrandLabelUtilTest.dataSetup() beforehand to get site catalogues
	public static void dataSetup()
	{
		List<CW_Asset_Type__c> assetTypes = new List<CW_Asset_Type__c>();
		for(String atName : TestDataUtil.getAssetTypeList())
		{
			CW_Asset_Type__c assetType = TestDataUtil.createAssetType();
			assetType.Name = atName;
			if(atName == TestDataUtil.MAILER)
			{
				assetType.Country_Specific__c = true;
			}
			else
			{
				assetType.Country_Specific__c = false;
			}
			assetTypes.add(assetType);
		}
		insert assetTypes;
		
		List<CW_Asset__c> assets = new List<CW_Asset__c>();
		for(CW_Asset_Type__c assetType : assetTypes)
		{
			for(String assetName : TestDataUtil.getAssetExtensionList())
			{
				CW_Asset__c asst = TestDataUtil.createAsset(assetType.Id);
				asst.Name = assetType.Name + ' ' + assetName;
				assets.add(asst);
			}
		}
		insert assets;
		
		List<CW_Asset_Catalogue__c> assetCats = new List<CW_Asset_Catalogue__c>();
		// I expect way less than a 1000 but following best practice
		for(CW_Site_Catalogue__c sc : [select id from CW_Site_Catalogue__c limit 1000])
		{
			for(CW_Asset__c asst : assets)
			{
				assetCats.add(TestDataUtil.createAssetCatalogue(sc.Id,asst.Id));
			}
		}
		insert assetCats;
	}
	
	public static void testDataSetup()
	{
		System.assertEquals(1,[select count() from CW_Asset_Type__c where Country_Specific__c = true and Name = :TestDataUtil.MAILER]);
		System.assertEquals([select count() from CW_Asset_Type__c],TestDataUtil.getAssetTypeList().size());
		System.assertEquals([select count() from CW_Asset__c],
			TestDataUtil.getAssetTypeList().size()*TestDataUtil.getAssetExtensionList().size());
		System.assertEquals([select count() from CW_Asset_Catalogue__c],
			TestDataUtil.getAssetTypeList().size()*TestDataUtil.getAssetExtensionList().size()*[select count() from CW_Site_Catalogue__c]);
	}
	
	// only use site catalogues which have asset catalogues for needed asset types
	public static void associateSiteCataloguesToCampaign(List<String> assetTypeNames, Id campaignId)
	{
		List<CW_Campaign_Sites__c> campSites = new List<CW_Campaign_Sites__c>();
		for(CW_Site_Catalogue__c sc : [select id, 
										(select id from Asset_Catalogues__r where Asset__r.Asset_Type__r.Name in :assetTypeNames),
										(select Language__c from Site_Languages__r)
										from CW_Site_Catalogue__c
										limit 1000])
		{
			if(!sc.Asset_Catalogues__r.isEmpty())
			{
				for(CW_Site_Language__c sl : sc.Site_Languages__r)
				{
					campSites.add(TestDataUtil.createCampaignSites(campaignId,sc.id,sl.Language__c));
				}
			}
		}
		insert campSites;
	}
	
	public static void addAllAssetTypesToCampaign(Id campId)
	{
		List<CW_Campaign_Asset_Type__c> campAT = new List<CW_Campaign_Asset_Type__c>();
		for(CW_Asset_Type__c assetType : [select id from CW_Asset_Type__c])
		{
			campAT.add(new CW_Campaign_Asset_Type__c(Campaign__c = campId, Asset_Type__c = assetType.id));
		}
		insert campAT;
	}
	
	public static CW_Campaign_Asset__c createCampAsset(Id assetTypeId, CW_Campaign__c camp)
	{
		CW_WizardCampaignAssetUtil cwau = new CW_WizardCampaignAssetUtil();
		cwau.camp = camp;
		cwau.assetTypeId = assetTypeId;
		cwau.readOnly = false;
		cwau.getInit();
		
		// create asset
		cwau.fieldSetQC = new List<Schema.FieldSetMember>();	// destroy fieldset to avoid leaving any required fields blank
		cwau.addAsset();	// this call fails because we didn't set asset
		Id assetId = (Id) cwau.assetOptions.get(1).getValue();	// first option is the empty one
		cwau.campAssetQC.Asset__c = assetId;
		cwau.addAsset();	// this time it should succeed
		
		return [select id, Asset__c, Asset__r.Asset_Type__c  from CW_Campaign_Asset__c where Campaign__c = :camp.Id limit 1];
	}

}