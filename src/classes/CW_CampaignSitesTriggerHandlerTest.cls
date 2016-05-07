@isTest
private class CW_CampaignSitesTriggerHandlerTest {

/**
* File Name   :    CW_CampaignSitesTriggerHandlerTest.cls
* Description :    Test Class for CW_CampaignSitesTriggerHandler.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 21/05/2014 Klea Kolaric 	Initial version
* 0.2 16/06/2014 Chris Yorkston	Added test for
*
*
*/

	@isTest static void testLabelsLanguagesProductsBrandsAggregatedOnCampaign() {
		
		// setup data
		Integer numberOfSiteCatalogueItems = 3;
		
		CW_Campaign__c camp = TestDataUtil.getCampaign();
		insert camp;
		
		List<CW_Brand__c> brands = TestDataUtil.getBrands(numberOfSiteCatalogueItems);
		insert brands;
		
		List<CW_Label__c> labels = TestDataUtil.getLabels(brands);
		insert labels;
		
		List<CW_Country__c> countries = TestDataUtil.getCountries(numberOfSiteCatalogueItems);
		insert countries;
		
		List<CW_Product__c> products = TestDataUtil.getProducts(numberOfSiteCatalogueItems);
		insert products;
		
		List<CW_Site_Catalogue__c> siteCats = TestDataUtil.getSiteCatalogues(labels, countries, products);
		insert siteCats;
		
		List<CW_Language__c> languages = TestDataUtil.getLanguages(numberOfSiteCatalogueItems);
		insert languages;
		
		Test.startTest();
		List<CW_Campaign_Sites__c> campSites = TestDataUtil.getCampaignSites(camp.Id, siteCats, languages);
		insert campSites;
		Test.stopTest();
				
		// assert campaign fields have been populated: label, product and language
		CW_Campaign__c updatedCampaign = [select Id, Labels__c, Languages__c, Products__c, Brands__c from CW_Campaign__c where Id = :camp.Id limit 1];
		
		Set<String> labelSet = new Set<String>();
		Set<String> languageSet = new Set<String>();
		Set<String> productSet = new Set<String>();
		Set<String> brandSet = new Set<String>();
		
		for (CW_Label__c label :labels) labelSet.add(label.Code__c);
		for (CW_Language__c language :languages) languageSet.add(language.Code__c);
		for (CW_Product__c product :products) productSet.add(product.Code__c);
		for (CW_Brand__c brand :brands) brandSet.add(brand.Name);
		
		system.assertEquals(StringUtil.delimitStrings(labelSet), updatedCampaign.Labels__c);
		system.assertEquals(StringUtil.delimitStrings(languageSet), updatedCampaign.Languages__c);
		system.assertEquals(StringUtil.delimitStrings(productSet), updatedCampaign.Products__c);
		system.assertEquals(StringUtil.delimitStrings(brandSet), updatedCampaign.Brands__c);
		
	}
}