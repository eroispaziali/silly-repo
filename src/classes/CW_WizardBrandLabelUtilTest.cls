/**
* File Name   :    CW_WizardBrandLabelUtilTest.cls
* Description :    PEN-131
*                  must have be able to select Brand, Label, Language, Product, Country for Site Catalogue
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 11/03/2014 Klea Kolaric	Initial version
*
*
*/
@isTest
public class CW_WizardBrandLabelUtilTest {

    private static testMethod void assertDataCreationTest()
    {
    	Test.startTest();
    	dataSetup();
    	Test.stopTest();
    	
    	testDataSetup();
    }
    
    private static testMethod void happyPathNoPreviousCSTest()
    {
    	dataSetup();
    	CW_Campaign__c camp = TestDataUtil.createCampaign();
    	insert camp;
    	
    	List<Integer> indexList = CW_WizardBrandLabelUtil.createIndexList(12, 5);
    	system.assertEquals(indexList.size(),3);
    	system.assertEquals(indexList.get(0),0);
    	system.assertEquals(indexList.get(1),5);
    	system.assertEquals(indexList.get(2),10);
    	
    	Test.startTest();
    	
    	CW_WizardBrandLabelUtil ut = new CW_WizardBrandLabelUtil();
    	
    	ut.existingCampSites = CW_WizardBrandLabelUtil.selectCampaignSites(camp.Id);
    	system.assertEquals(ut.existingCampSites.size(),0);
    	
    	ut.brands = WrapperUtil.createWrapperList([select id, Name from CW_Brand__c], null, 'Name', 'id', 'id');
    	system.assertEquals(ut.brands.size(),brands.size());
    	TestDataUtil.checkList(ut.brands, TestDataUtil.BWINTEST);
    	
    	ut.loadLabelProductMatrix();
    	system.assertEquals(ut.labelProductMatrix.size(),labelDomains.size());
    	TestDataUtil.checkMatrix(ut.labelProductMatrix, TestDataUtil.BWINTEST+TestDataUtil.DOTCOM, TestDataUtil.SPORTS);
    	ut.labelProductMatrix.get(0).getNotNullSubObjectSize();
    	
    	ut.loadLanguages();
    	system.assertEquals(ut.languages.size(),languages.size()-2);	// FR and DE not available
    	TestDataUtil.checkList(ut.languages, TestDataUtil.EN);
    	
    	ut.loadLabelCountryMatrix();
    	system.assertEquals(ut.labelCountryMatrix.size(),1);
    	system.assertEquals(ut.labelCountryMatrix.get(0).subObjects.size(),countries.size()-2);	// FRANCE and GERMANY not available
    	TestDataUtil.checkMatrix(ut.labelCountryMatrix, TestDataUtil.BWINTEST+TestDataUtil.DOTCOM, TestDataUtil.NORWAY);
    	
    	ut.createCampaignSites(camp.Id);
    	
    	Test.stopTest();
    	
    	system.assertEquals(1,[select count() from CW_Campaign_Sites__c where 
    							Campaign__c = :camp.Id 
    							and Site_Catalogue__r.Label__r.Name = :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM) 
    							and Site_Catalogue__r.Country__r.Name = :TestDataUtil.NORWAY
    							and Site_Catalogue__r.Product__r.Name = :TestDataUtil.SPORTS
    							and Language__r.Name = :TestDataUtil.EN]);
    	
    }
    
    private static testMethod void happyPathDeletePreviousCSTest()
    {
    	dataSetup();
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
    	
    	Test.startTest();
    	
    	CW_WizardBrandLabelUtil ut = new CW_WizardBrandLabelUtil();
    	
    	ut.existingCampSites = CW_WizardBrandLabelUtil.selectCampaignSites(camp.Id);
    	system.assertEquals(ut.existingCampSites.size(),1);
    	
    	ut.brands = WrapperUtil.createWrapperList([select id, Name from CW_Brand__c], null, 'Name', 'id', 'id');
    	ut.markExistingList(true,false);
    	
    	ut.loadLabelProductMatrix();
    	ut.markExistingMatrix(true,false);
    	
    	ut.loadLanguages();
    	ut.markExistingList(false,true);
    	TestDataUtil.checkList(ut.languages, TestDataUtil.EN);
    	system.assert(!TestDataUtil.checkList(ut.languages, TestDataUtil.GA)); // assert unchecked option
    	
    	ut.loadLabelCountryMatrix();
    	ut.markExistingMatrix(false,true);
    	TestDataUtil.checkMatrix(ut.labelCountryMatrix, TestDataUtil.BWINTEST+TestDataUtil.DOTCOM, TestDataUtil.NORWAY);
    	 // assert unchecked option
    	system.assert(!TestDataUtil.checkMatrix(ut.labelCountryMatrix, TestDataUtil.BWINTEST+TestDataUtil.DOTCOM, TestDataUtil.IRELAND));
    	
    	ut.createCampaignSites(camp.Id);
    	ut.removeCampaignSites();
    	
    	Test.stopTest();
    	
    	system.assertEquals(1,[select count() from CW_Campaign_Sites__c]);	// old record has been deleted
    	system.assertEquals(1,[select count() from CW_Campaign_Sites__c where 
    							Campaign__c = :camp.Id 
    							and Site_Catalogue__r.Label__r.Name = :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM) 
    							and Site_Catalogue__r.Country__r.Name = :TestDataUtil.NORWAY
    							and Site_Catalogue__r.Product__r.Name = :TestDataUtil.SPORTS
    							and Language__r.Name = :TestDataUtil.EN]);
    	
    }
    
    private static testMethod void preselectHasPreviousCSTest()
    {
    	dataSetup();
    	CW_Campaign__c camp = TestDataUtil.createCampaign();
    	insert camp;
    	
    	CW_Site_Catalogue__c sc = [select id, Label__c, Country__c, Product__c from CW_Site_Catalogue__c where
	    							Label__r.Name = :(TestDataUtil.BWINTEST+TestDataUtil.DOTCOM) 
	    							and Country__r.Name = :TestDataUtil.NORWAY
	    							and Product__r.Name = :TestDataUtil.SPORTS 
	    							limit 1];
    							
    	CW_Campaign_Sites__c cs = new CW_Campaign_Sites__c();
    	cs.Campaign__c = camp.Id;
    	cs.Site_Catalogue__c = sc.id;
    	cs.Language__c = [select id from CW_Language__c where Name = :TestDataUtil.EN limit 1].id;
    	insert cs;
    	
    	Test.startTest();
    	
    	CW_WizardBrandLabelUtil ut = new CW_WizardBrandLabelUtil();
    	ut.existingCampSites = CW_WizardBrandLabelUtil.selectCampaignSites(camp.Id);
    	system.assertEquals(ut.existingCampSites.size(),1);
    	
    	ut.brands = WrapperUtil.createWrapperList([select id, Name from CW_Brand__c], null, 'Name', 'id', 'id');
    	ut.markExistingList(true,false);
    	ut.loadLabelProductMatrix();
    	ut.markExistingMatrix(true,false);
    	ut.loadLanguages();
    	ut.markExistingList(false,true);
    	ut.loadLabelCountryMatrix();
    	ut.markExistingMatrix(false,true);
    	
    	Test.stopTest();
    	
    	// assert that the same combination that exists was preselected
    	Set<String> selectedCombos = CW_WizardBrandLabelUtil.createSelectedPermutations(ut.labelProductMatrix,ut.labelCountryMatrix);
    	system.assertEquals(selectedCombos.size(),1);
    	system.assert(selectedCombos.contains(CW_WizardBrandLabelUtil.createComboKey(sc.Label__c,sc.Product__c,sc.Country__c)));
    	// check language
    	for(WrapperUtil.SelectWrapper lang : ut.languages)
    	{
    		if(lang.optionName == TestDataUtil.EN)
    		{
    			system.assert(lang.selected);
    			break;
    		}
    	}
    	
    	// when i do save it shouldn't ovewrite or duplicate existing CS record
    	ut.createCampaignSites(camp.Id);
    	system.assertEquals(1,[select count() from CW_Campaign_Sites__c]);
    	system.assertEquals(cs.id,[select id from CW_Campaign_Sites__c limit 1].id);
    }
    
    /*** this is a method to create the complete dataset for testing, including a data check ***/
    
    static List<String> countries = TestDataUtil.getCountryList();
	static List<String> languages = TestDataUtil.getLanguageList();
	static List<String> products = TestDataUtil.getProductList();
	static List<String> brands = TestDataUtil.getBrandList();
	static List<String> labelDomains = TestDataUtil.getLabelDomainsList();
    
    public static void dataSetup()
	{
		List<sObject> objectList = new List<sObject>();
		
		for(String nameStr : countries)
		{
			Sobject so = (sObject) TestDataUtil.createCountry();
			so.put('Name',(object) nameStr);
			objectList.add(so);
		}
		for(String nameStr : languages)
		{
			Sobject so = (sObject) TestDataUtil.createLanguage();
			so.put('Name',(object) nameStr);
			objectList.add(so);
		}
		for(String nameStr : products)
		{
			Sobject so = (sObject) TestDataUtil.createProduct();
			so.put('Name',(object) nameStr);
			objectList.add(so);
		}
		for(String nameStr : brands)
		{
			Sobject so = (sObject) TestDataUtil.createBrand();
			so.put('Name',(object) nameStr);
			objectList.add(so);
		}
		
		insert objectList;	// will be broken up into several DMLs, but objects are grouped by type so not a problem
		
		// create labels
		{
			List<sObject> inserLabelsList = new List<sObject>();
			for(CW_Brand__c brand : [select id, Name from CW_Brand__c])
			{
				for(String domainStr : labelDomains)
				{
					Sobject so = (sObject) TestDataUtil.createLabel(brand.Id);
					so.put('Name',(object) (brand.Name + domainStr));
					so.put('Code__c',(object) (brand.Name + domainStr).replace('.',''));
					inserLabelsList.add(so);
				}
			}
			insert inserLabelsList;
			objectList.addAll(inserLabelsList);
		}
		
		// create name-object map for easier object retrieval
		Map<String,sObject> objectMap = new Map<String,sObject>();
		for(sObject so : objectList)
		{
			objectMap.put((String) so.get('Name'),so);
		}
		objectList.clear();	// not needed
		
		// create special combinations for Gemany [0] and France [1] fro all product except casino
		List<CW_Site_Language__c> scGermanFrench = new List<CW_Site_Language__c>();
		
		Set<String> removeObjectNames = new Set<String>();	// objects specific to Germany and France
		
		for(Integer i=0; i<2; i++)
		{
			String domain = i==0 ? TestDataUtil.DOTDE : TestDataUtil.DOTFR;
			String language = i==0 ? TestDataUtil.DE : TestDataUtil.FR;
			String country = i==0 ? TestDataUtil.GERMANY : TestDataUtil.FRANCE;
			
			for(String brand : brands)
			{
				String labelName = brand + domain;
				removeObjectNames.add(labelName);
				
				for(String prod : products)
				{
					if(prod == TestDataUtil.CASINO)	// no casinos for you
					{
						continue;
					}
					CW_Site_Catalogue__c sc =  TestDataUtil.createSiteCatalogue(
												((CW_Label__c) objectMap.get(labelName)).id,
												((CW_Country__c) objectMap.get(country)).id, 
												((CW_Product__c) objectMap.get(prod)).id);
					insert sc;
										
					CW_Site_Language__c sl = TestDataUtil.createSiteLanguage(sc.id, objectMap.get(language).id);
					scGermanFrench.add(sl);
				}
			}
			removeObjectNames.add(language);
			removeObjectNames.add(country);
		}
		insert scGermanFrench;
		
		// remove "used-up" objects
		for(String strKey : removeObjectNames)
		{
			objectMap.remove(strKey);
		}
		
		// permutate leftover objects
		List<CW_Site_Catalogue__c> scOther = new List<CW_Site_Catalogue__c>();
		List<CW_Site_Language__c> slOther = new List<CW_Site_Language__c>();
		
		for(String brand : brands)
		{
			for(String labelDomain : labelDomains)
			{
				String labelName = brand + labelDomain;
				if(!removeObjectNames.contains(labelName))
				{
					
					for(String country : countries)
					{
						if(!removeObjectNames.contains(country))
						{
							for(String prod : products)
							{
								scOther.add(TestDataUtil.createSiteCatalogue(
											((CW_Label__c) objectMap.get(labelName)).id,
											((CW_Country__c) objectMap.get(country)).id, 
											((CW_Product__c) objectMap.get(prod)).id));
							}
						}
					}
				}
			}
		}
		
		insert scOther;
		
		for(CW_Site_Catalogue__c sc : scOther)
		{
			for(String lang : languages)
			{
				if(!removeObjectNames.contains(lang))
				{
					slOther.add(TestDataUtil.createSiteLanguage(sc.id, objectMap.get(lang).id));
				}
			}
		}
		
		insert slOther;
		
	}
	
	// check data was inserted correctly
	public static void testDataSetup() 
    {
        // assert number of permutations in database
        System.assertEquals(4,[select count() from CW_Site_Catalogue__c where Country__r.Name = :TestDataUtil.GERMANY]);
        System.assertEquals(4,[select count() from CW_Site_Language__c 
        					where Site_Catalogue__r.Country__r.Name = :TestDataUtil.GERMANY and Language__r.Name = :TestDataUtil.DE]);
        System.assertEquals(4,[select count() from CW_Site_Catalogue__c where Country__r.Name = :TestDataUtil.FRANCE]);
       	System.assertEquals(4,[select count() from CW_Site_Language__c 
        					where Site_Catalogue__r.Country__r.Name = :TestDataUtil.FRANCE and Language__r.Name = :TestDataUtil.FR]);
        // epic assert
        System.assertEquals(
        	[select count() from CW_Site_Catalogue__c where Country__r.Name != :TestDataUtil.GERMANY 
        		and Country__r.Name != :TestDataUtil.FRANCE], (countries.size()-2) * brands.size() * products.size());
        System.assertEquals(
        	[select count() from CW_Site_Language__c where Language__r.Name != :TestDataUtil.DE and Language__r.Name != :TestDataUtil.FR],
        					(countries.size()-2) * brands.size() * products.size() * (languages.size()-2));
    }
}