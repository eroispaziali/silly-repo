/**
* File Name   :    CW_WizardBrandLabelUtil.cls
* Description :    PEN-131
*                  must have be able to select Brand, Label, Language, Product, Country for Site Catalogue
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 05/03/2014 Klea Kolaric	Initial version
*
*
* Users will select a combination of Label/Product/Country and all Site Catalogues that match that combination should be selected
*
*/

//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing" 
//so the user can create related records while cost/brief is in approval
public without sharing class CW_WizardBrandLabelUtil {
	
	// CONSTANTS
	public static final String DELIMITER = '_';
	// keys of type label.Id_product.Id_country.Id
	public static final Integer LABEL_INDEX = 0;
	public static final Integer PRODUCT_INDEX = 1;
	public static final Integer COUNTRY_INDEX = 2;
	
	// instance variables - will make it easier to remove when changing pages
	public List<WrapperUtil.SelectWrapper> brands {get; set;}
	public List<WrapperUtil.SelectWrapper> languages {get; set;}
	public List<WrapperUtil.SelectWrapper> productColumns {get; set;}
	public List<WrapperUtil.SelectWrapper> countryColumns {get; set;}
	public List<WrapperUtil.SelectListWrapper> labelProductMatrix {get; set;}
	public List<WrapperUtil.SelectListWrapper> labelCountryMatrix {get; set;}
	public List<CW_Site_Catalogue__c> siteCats {get; set;}
	public List<CW_Campaign_Sites__c> existingCampSites {get; set;}
	
	public CW_WizardBrandLabelUtil()
	{
		
	}
	
	/**/
	
	// load available products for labels contained in the selected brands, columns are aligned
	public void loadLabelProductMatrix()
	{
		Set<Id> brandIds = WrapperUtil.createdSelectedObjectSet(brands);
		
		if(!brandIds.isEmpty())
		{
			siteCats = selectSiteCatalogues(brandIds);
			productColumns = WrapperUtil.createWrapperList(siteCats, ConstantUtil.CW_SC_REL_PRODUCT, ConstantUtil.SOBJECT_NAME, 
															ConstantUtil.SOBJECT_ID, ConstantUtil.SOBJECT_ID);
			labelProductMatrix = createLabelWrapperList(siteCats, productColumns, ConstantUtil.CW_SC_REL_PRODUCT, ConstantUtil.SOBJECT_NAME, 
															ConstantUtil.SOBJECT_ID, ConstantUtil.SOBJECT_ID);
		}
	}
	
	/**/
	
	// load available languages for selected labels and product, present as one list
	public void loadLanguages()
	{
		// languages list depends on selected label-product combinations - keys will be of type: 'labelId_productId_'
		Set<String> selectedCombos = createSelectedPermutations(labelProductMatrix);
		
		Map<Id,CW_Language__c> selectedSL = new Map<Id,CW_Language__c>();
		for(CW_Site_Catalogue__c sc : siteCats)
		{
			String comboKey = createComboKey((String) sc.Label__c, (String) sc.Product__c, null);
			if(selectedCombos.contains(comboKey))
			{
				for(CW_Site_Language__c sl : sc.Site_Languages__r)
				{
					selectedSL.put(sl.Language__c,sl.Language__r);
				}
			}
		}
		// create options from a list of available languages
		languages = WrapperUtil.createWrapperList(selectedSL.values(), null, ConstantUtil.SOBJECT_NAME, ConstantUtil.SOBJECT_ID, 
													ConstantUtil.SOBJECT_ID);
		languages.sort();
	}
	
	/**/
	
	// load available countries for selected labels, display per label, no need to align columns
	public void loadLabelCountryMatrix()
	{
		Set<String> selectedCombos = createSelectedPermutations(labelProductMatrix);
		Set<Id> selectedLabelIds = new Set<Id>();
		// extract selected labels
		for(String strCombo : selectedCombos)
		{
			selectedLabelIds.add((Id) strCombo.split(DELIMITER).get(LABEL_INDEX));
		}
		
		// remove unselected labels
		List<CW_Site_Catalogue__c> selectedSiteCats = new List<CW_Site_Catalogue__c>();
		for(CW_Site_Catalogue__c sc : siteCats)
		{
			if(selectedLabelIds.contains(sc.Label__c))
			{
				selectedSiteCats.add(sc);
			}
		}
		
		if(selectedSiteCats.isEmpty())
		{
			return;
		}
		
		// create tables from selected objects
		countryColumns = WrapperUtil.createWrapperList(selectedSiteCats, ConstantUtil.CW_SC_REL_COUNTRY, ConstantUtil.SOBJECT_NAME, 
														ConstantUtil.SOBJECT_ID, ConstantUtil.SOBJECT_ID);
		labelCountryMatrix = createLabelWrapperList(selectedSiteCats, countryColumns, ConstantUtil.CW_SC_REL_COUNTRY, 
														ConstantUtil.SOBJECT_NAME, ConstantUtil.SOBJECT_ID, ConstantUtil.SOBJECT_ID);
		
		selectedSiteCats.clear();
		
		// remove empty columns - O.K. only if we have no need for aligning columns
		// also set showRow property - don't show labels with only one country
		for(WrapperUtil.SelectListWrapper lw : labelCountryMatrix)
		{
			lw.showRow = lw.getNotNullSubObjectSize() > 1;
			if(!lw.showRow)
			{
				lw.selectAll();	// this row is hidden so user can't select it manually
			}
			
			Integer listSize = lw.subObjects.size();
			for(Integer i=0; i<listSize; i++)
			{
				if(lw.subObjects.get(i).optionValue == null)
				{
					lw.subObjects.remove(i);
					// reset indexes
					i--;
					listSize--;
				}
			}
		}
	}
	
	/**/
	
	// mark preselected items in a list - supports doing both lists at once
	public void markExistingList(Boolean markBrand, Boolean markLanguage)
	{
		Set<Id> markSet = new Set<Id>();
		for(CW_Campaign_Sites__c cs : existingCampSites)
		{
			if(markBrand)
			{
				markSet.add(cs.Site_Catalogue__r.Label__r.Brand__c);
			}
			if(markLanguage)
			{
				markSet.add(cs.Language__c);
			}
		}
		
		List<WrapperUtil.SelectWrapper> markList = new List<WrapperUtil.SelectWrapper>();
		
		for(Integer i=0; i<2; i++)
		{
			if(i == 0 && markBrand)
			{
				markList = brands;
			}
			if(i == 1 && markLanguage)
			{
				markList = languages;
			}
			
			for(WrapperUtil.SelectWrapper sw : markList)
			{
				if(markSet.contains((Id) sw.optionValue))
				{
					sw.selected = true;
				}
			}
		}
	}
	
	/**/
	
	// mark preselected items in a matrix - supports setting both matrixes at once
	public void markExistingMatrix(Boolean markProduct, Boolean markCountry)
	{
		// a set of all existing combinations of label/product/language/country
		Set<String> existingComboKeySet = createAvailableCombinationMapFromCS(existingCampSites).keySet();
		// keys of type label.Id_product.Id_language.Id_country.Id
		
		//for product and country the procedute is the same - still, I'm avoiding new methods as the class is already pretty loaded
		if(markProduct)
		{
			markExistingMatrix(existingComboKeySet, PRODUCT_INDEX, labelProductMatrix);
		}
		if(markCountry)
		{
			markExistingMatrix(existingComboKeySet, COUNTRY_INDEX, labelCountryMatrix);
		}
	}
	
	/**/
	
	// associate selected Site Catalogues to the campaign, or remove any if needed
	public void createCampaignSites(Id campaignId)
	{
		// find selected values
		Map<String,CW_Site_Catalogue__c> siteCatsMap = createAvailableCombinationMap(siteCats);
		Set<String> selectedCombos = createSelectedPermutations(labelProductMatrix, labelCountryMatrix);
		Set<Id> selectedLanguages = WrapperUtil.createdSelectedObjectSet(languages);
		
		// find existing values
		Set<String> existingCombos = createAvailableCombinationMapFromCS(existingCampSites).keySet();
		Set<Id> existingLangs = new Set<Id>();
		for(CW_Campaign_Sites__c cs : existingCampSites)
		{
				existingLangs.add(cs.Language__c);
		}
		
		List<CW_Campaign_Sites__c> insertList = new List<CW_Campaign_Sites__c>();
		
		for(String comboKey : siteCatsMap.keySet())
		{
			if(selectedCombos.contains(comboKey))
			{
				CW_Site_Catalogue__c sc = siteCatsMap.get(comboKey);
				for(CW_Site_Language__c sl : sc.Site_Languages__r)
				{
					// only create camp site if adding new language or new site catalogue
					if(selectedLanguages.contains(sl.Language__c) 
						&& (!existingCombos.contains(comboKey) || !existingLangs.contains(sl.Language__c)))
					{
						insertList.add(
							new CW_Campaign_Sites__c(Site_Catalogue__c = sc.Id, Campaign__c = campaignId, Language__c = sl.Language__c)
						);
					}
				}
			}
		}
		
		if(!insertList.isEmpty())
		{
			insert insertList;
		}
	}
	
	/**/
	
	// remove any if needed
	public void removeCampaignSites()
	{
		Set<String> selectedCombos = createSelectedPermutations(labelProductMatrix, labelCountryMatrix);
		Set<Id> selectedLanguages = WrapperUtil.createdSelectedObjectSet(languages);
		List<CW_Campaign_Sites__c> deleteList = new List<CW_Campaign_Sites__c>();
		
		
		// remove deselected campaign site combinations
		for(CW_Campaign_Sites__c cs : existingCampSites)
		{
			String comboKey = createComboKey((String) cs.Site_Catalogue__r.Label__c,
											(String) cs.Site_Catalogue__r.Product__c, 
											(String) cs.Site_Catalogue__r.Country__c);
			// if combo was deselected or language no longer supported
			if(!selectedCombos.contains(comboKey) || !selectedLanguages.contains(cs.Language__c))
			{
				deleteList.add(cs);
			}
		}
		
		if(!deleteList.isEmpty())
		{
			delete deleteList;
		}
	}
	
	
	/********************************/
	/***********STATIC***************/
	/********************************/
	
	/*** utils ***/
	
	// create combo key - label.Id_product.Id_language.Id_country.Id
	public static String createComboKey(String val1, String val2, String val3)
	{
		return (val1 != null ? (val1+DELIMITER) : '') 
				+ (val2 != null ? (val2+DELIMITER) : '') 
				+ (val3 != null ? val3 : '');
	}
	
	/**/
	
	// helper when CW_Site_Catalogue__c is inside CW_Campaign_Sites__c
	public static Map<String,CW_Site_Catalogue__c> createAvailableCombinationMapFromCS(List<CW_Campaign_Sites__c> campSites)
	{
		List<CW_Site_Catalogue__c> siteCats = new List<CW_Site_Catalogue__c>();
		for(CW_Campaign_Sites__c cs : campSites)
		{
			siteCats.add(cs.Site_Catalogue__r);
		}
		return createAvailableCombinationMap(siteCats);
	}
	
	/**/
	
	// create map of of site catalogues grouped by Label/Product/Country
	public static Map<String,CW_Site_Catalogue__c> createAvailableCombinationMap(List<CW_Site_Catalogue__c> siteCats)
	{
		Map<String,CW_Site_Catalogue__c> retMap = new Map<String,CW_Site_Catalogue__c>();
		
		for(CW_Site_Catalogue__c siteCat : siteCats)
		{
			String mapKey = createComboKey((String) siteCat.Label__c,
											(String) siteCat.Product__c,
											(String) siteCat.Country__c);
			
			retMap.put(mapKey,siteCat);
		}
		return retMap;
	}
	
	/**/

	// extract selected only labels and products
	public static Set<String> createSelectedPermutations(List<WrapperUtil.SelectListWrapper> productsWs)
	{
		List<WrapperUtil.SelectListWrapper> fakeCountry = new List<WrapperUtil.SelectListWrapper>();
		for(WrapperUtil.SelectListWrapper lp : productsWs)
		{
			WrapperUtil.SelectListWrapper lw = new WrapperUtil.SelectListWrapper(lp.label,1);
			lw.subObjects.get(0).selected = true;
			fakeCountry.add(lw);
		}
		
		return createSelectedPermutations(productsWs,fakeCountry);
	}
	
	/**/
	
	// create a keySet comprising the user selection of Label/Product/Country
	public static Set<String> createSelectedPermutations(List<WrapperUtil.SelectListWrapper> productsWs, 
		List<WrapperUtil.SelectListWrapper> countriesWs)
	{
		Set<String> retSet = new Set<String>();
		
		// remove all unselected items for faster looping
		Map<Id,Set<Id>> labelProductMap = WrapperUtil.createdSelectedParentSubObjectMappedSet(productsWs);
		Map<Id,Set<Id>> labelCountryMap = WrapperUtil.createdSelectedParentSubObjectMappedSet(countriesWs);
		
		for(Id labelId : labelProductMap.keySet())
		{
			Set<Id> productIdSet = labelProductMap.get(labelId);
			for(Id prodId : productIdSet)
			{
				Set<Id> countryIdSet = labelCountryMap.get(labelId);
				for(Id countryId : countryIdSet)
				{
					retSet.add(createComboKey((String) labelId,
												(String) prodId,
												(String) countryId));
				}
			}
		}
		
		return retSet;
	}
	
	/**/
	
	// create a list of labels, each containing a list of available products suitable for table display
	public static List<WrapperUtil.SelectListWrapper> createLabelWrapperList(List<CW_Site_Catalogue__c> siteCats, 
		List<WrapperUtil.SelectWrapper> columnList, String relation, String nameField, String valueField, String idField)
	{
		return WrapperUtil.createObjectWrapperList(siteCats, columnList, ConstantUtil.CW_SC_REL_LABEL, relation,
													nameField, valueField, idField);
	}
	
	/**/
	
	//for product and country the procedute is the same
	public static void markExistingMatrix(Set<String> existingComboKeySet, Integer index, List<WrapperUtil.SelectListWrapper> labelMatrix)
	{
		Set<String> markSet = new Set<String>();
		
		for(String comboKey : existingComboKeySet)
		{
			List<String> comboKeyComponents = comboKey.split(DELIMITER);
			markSet.add(createComboKey(comboKeyComponents.get(LABEL_INDEX),comboKeyComponents.get(index),null));
		}
		
		for(WrapperUtil.SelectListWrapper lw : labelMatrix)
		{
			for(WrapperUtil.SelectWrapper sw : lw.subObjects)
			{
				String comboKey = createComboKey((String) lw.label.id, sw.optionValue, null);
				if(markSet.contains(comboKey))
				{
					sw.selected = true;
				}
			}
		}
		
	}
	
	/**/
	
	// used to break up long lists into more rows in a table
	public static List<Integer> createIndexList(Integer listSize, Integer columnPerRow)
	{
		List<Integer> indexList = new List<Integer>();
		Integer i = 0;
		
		while(i < listSize)
		{
			indexList.add(i);
			i += columnPerRow;
		}
		return indexList;
	}
	
	/**/
	
	// select active site catalogues for selected brands, order/group by Brand > Label > Product
	public static List<CW_Site_Catalogue__c> selectSiteCatalogues(Set<Id> brandIds)
	{
		return [select
				Is_Active__c,
				Name,
				Country__c,
				Country__r.Name,
				Label__c,
				Label__r.Name,
				Label__r.Brand__c,
				Label__r.Brand__r.Name,
				//Language__c,
				//Language__r.Name,
				Product__c,
				Product__r.Name,
				(select Language__c, Language__r.Name from Site_Languages__r)
				from CW_Site_Catalogue__c
				where Is_Active__c = true
					and Label__r.Brand__c in :brandIds
					and Product__c != null
				order by Label__r.Brand__r.Name asc, Label__r.Name asc, Product__r.Name asc
		];
	}
	
	/**/
	
	// select current Campaign Sites for Campaign
	public static List<CW_Campaign_Sites__c> selectCampaignSites(Id campaignId)
	{
		return [select
				Campaign__c,
				Language__c,
				Language__r.Name,
				Site_Catalogue__c,
				Site_Catalogue__r.Is_Active__c,
				Site_Catalogue__r.Name,
				Site_Catalogue__r.Country__c,
				Site_Catalogue__r.Country__r.Name,
				Site_Catalogue__r.Label__c,
				Site_Catalogue__r.Label__r.Name,
				Site_Catalogue__r.Label__r.Brand__c,
				Site_Catalogue__r.Label__r.Brand__r.Name,
				Site_Catalogue__r.Product__c,
				Site_Catalogue__r.Product__r.Name
				from CW_Campaign_Sites__c
				where Campaign__c = :campaignId
				order by Site_Catalogue__r.Label__r.Brand__r.Name asc, 
					Site_Catalogue__r.Label__r.Name asc, 
					Site_Catalogue__r.Product__r.Name asc
		];
	}
	
}