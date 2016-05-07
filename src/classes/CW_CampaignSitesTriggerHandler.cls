global class CW_CampaignSitesTriggerHandler {
/**
* File Name   :    CW_CampaignSitesTriggerHandler.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 21/05/2014 Chris Yorskton Initial
* 0.2 28/05/2014 Klea Kolaric	Fixing trigger chunking
* 0.3 16/06/2014 Chris Yorskton Added the aggregation of Brands on Campaign object
*
*/	
	global static Boolean futureCalled = false;	// avoid multiple calls to future method
	
	private Boolean m_isExecuting = false;
	
    global CW_CampaignSitesTriggerHandler(Boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    global boolean IsTriggerContext{
        get{ return m_isExecuting; }
    }
	
	global void OnAfterInsert( CW_Campaign_Sites__c[] newObjects, Map<Id,CW_Campaign_Sites__c> newObjectMap ) {
		callFuture(newObjects);
    }
    
	global void OnAfterDelete( CW_Campaign_Sites__c[] oldObjects) {
		callFuture(oldObjects);
    }
	
	/*global void OnAfterUpdate(
		CW_Campaign_Sites__c[] oldObjects, 
		CW_Campaign_Sites__c[] updatedObjects, 
		Map<Id,CW_Campaign_Sites__c> oldObjectMap, 
		Map<Id,CW_Campaign_Sites__c> updatedObjectMap
	) {
		updateCampaignWithAggregateFields(oldObjects); //todo should this be oldObjects?
	}*/
	
	global void callFuture(CW_Campaign_Sites__c[] csList)
	{
		if(futureCalled) return;
		
		Set<Id> campaignIds = new Set<Id>();
		for(CW_Campaign_Sites__c cs : csList)
		{
			campaignIds.add(cs.Campaign__c);
		}
		updateCampaignWithAggregateFields(campaignIds);
		
		futureCalled = true;
	}
	
	@future
	global static void updateCampaignWithAggregateFields(Set<Id> campaignIds) {
		
		
		// maps that will contain aggregated code values - using set to de-dup
		// k: campaign.id; v: set of label/language/product codes
		Map<Id,Set<String>> lablsMap = new Map<Id,Set<String>>();
		Map<Id,Set<String>> langsMap = new Map<Id,Set<String>>();
		Map<Id,Set<String>> prodsMap = new Map<Id,Set<String>>();
		Map<Id,Set<String>> brandsMap = new Map<Id,Set<String>>();
		
		// collect all campaign asset ids
		for(Id campaignId : campaignIds) {
			lablsMap.put(campaignId,new Set<String>());
			langsMap.put(campaignId,new Set<String>());
			prodsMap.put(campaignId,new Set<String>());
			brandsMap.put(campaignId,new Set<String>());
		}
		
		// reselect campaign site based on passed in ids with all needed fields
		for(CW_Campaign_Sites__c cs : [
			select 
				Campaign__c, 
				Language__r.Code__c, 
				Site_Catalogue__r.Product__r.Code__c, 
				Site_Catalogue__r.Label__r.Code__c, 
				Site_Catalogue__r.Label__r.Brand__r.Name
			from CW_Campaign_Sites__c 
			where Campaign__c in :campaignIds 
			order by Campaign__c
		])
		{
			lablsMap.get(cs.Campaign__c).add(cs.Site_Catalogue__r.Label__r.Code__c);
			langsMap.get(cs.Campaign__c).add(cs.Language__r.Code__c);
			prodsMap.get(cs.Campaign__c).add(cs.Site_Catalogue__r.Product__r.Code__c);
			brandsMap.get(cs.Campaign__c).add(cs.Site_Catalogue__r.Label__r.Brand__r.Name);
		}
		
		List<CW_Campaign__c> campaigns = new List<CW_Campaign__c>();
		for(Id campaignId : campaignIds) {
			CW_Campaign__c c = new CW_Campaign__c(id = campaignId);
			c.Labels__c = StringUtil.delimitStrings(lablsMap.get(c.id));
			c.Languages__c = StringUtil.delimitStrings(langsMap.get(c.id));
			c.Products__c = StringUtil.delimitStrings(prodsMap.get(c.id));
			c.Brands__c = StringUtil.delimitStrings(brandsMap.get(c.id));
			campaigns.add(c);
		}
		
		update campaigns;
	}
	
}