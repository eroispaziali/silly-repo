/**
* File Name   :    CW_LocalisedAssetTriggerHelper.cls
* Description :    B-114115 Denormalised list of labels, products, country, languages
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 06/05/2014 Klea Kolaric	Initial version
* 0.2 25/06/2014 Cristina P		Changed the class from "with sharing" to "without sharing" so the user can create related records while cost/brief is in approval
*
*
*/

public without sharing class CW_LocalisedAssetTriggerHelper {
	
	private Boolean m_isExecuting = false;

    public CW_LocalisedAssetTriggerHelper(Boolean isExecuting) {
        m_isExecuting = isExecuting;
    }
    
    public void OnAfterInsert( CW_Localised_Asset__c[] newObjects, Map<Id,CW_Localised_Asset__c> newObjectMap ) {
    	updateCampaignAssetAggregateFields(newObjects);
    }
    
    public void OnAfterDelete( CW_Localised_Asset__c[] deletedObjects, Map<Id,CW_Localised_Asset__c> objectMap ) {
    	updateCampaignAssetAggregateFields(deletedObjects);
    }
	
	// update Languages, Labels, Products aggregate fields
	public static void updateCampaignAssetAggregateFields(List<CW_Localised_Asset__c> locAssets)
	{
		// set of all campaignAsset ids
		Set<Id> campAssetIds = new Set<Id>();
		
		// maps that will contain aggregated code values - using set to de-dup
		// k: campaignAsset.id; v: set of label/language/product codes
		Map<Id,Set<String>> lablsMap = new Map<Id,Set<String>>();
		Map<Id,Set<String>> langsMap = new Map<Id,Set<String>>();
		Map<Id,Set<String>> prodsMap = new Map<Id,Set<String>>();
		
		// collect all campaign asset ids
		for(CW_Localised_Asset__c la : locAssets)
		{
			campAssetIds.add(la.Campaign_Asset__c);
			lablsMap.put(la.Campaign_Asset__c,new Set<String>());
			langsMap.put(la.Campaign_Asset__c,new Set<String>());
			prodsMap.put(la.Campaign_Asset__c,new Set<String>());
		}
		
		// reselect local asset based on passed in ids with all needed fields
		for(CW_Localised_Asset__c la : [select Campaign_Asset__c, 
												Language__r.Code__c, 
												Asset_Catalogue__r.Site_Catalogue__r.Product__r.Code__c, 
												Asset_Catalogue__r.Site_Catalogue__r.Label__r.Code__c
										from CW_Localised_Asset__c
										where Campaign_Asset__c in :campAssetIds
										order by Campaign_Asset__c])
		{
			lablsMap.get(la.Campaign_Asset__c).add(la.Asset_Catalogue__r.Site_Catalogue__r.Label__r.Code__c);
			langsMap.get(la.Campaign_Asset__c).add(la.Language__r.Code__c);
			prodsMap.get(la.Campaign_Asset__c).add(la.Asset_Catalogue__r.Site_Catalogue__r.Product__r.Code__c);
		}
		
		List<CW_Campaign_Asset__c> campAssets = new List<CW_Campaign_Asset__c>();
		for(Id caId : campAssetIds)
		{
			CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c(id = caId);
			ca.Labels__c = StringUtil.delimitStrings(lablsMap.get(ca.id));
			ca.Languages__c = StringUtil.delimitStrings(langsMap.get(ca.id));
			ca.Products__c = StringUtil.delimitStrings(prodsMap.get(ca.id));
			campAssets.add(ca);
		}
		update campAssets;
	}

}