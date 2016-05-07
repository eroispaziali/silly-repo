/**
* File Name   :    CW_CampaignAssetTypeTriggerHandler.cls
* Description :    B-108780: Lock the creation of new campaign asset type when the campaign 
*				   is linked to a roadmap that is "In Approval" or "Approved" 
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 16/04/2014 Cristina P.	Intial
*
*/
public with sharing class CW_CampaignAssetTypeTriggerHandler 
{
	public CW_CampaignAssetTypeTriggerHandler() {}
	
	public void onBeforeInsert(List<CW_Campaign_Asset_Type__c> newCampAT)
	{
		//check if campaign roadmap is locked before inserting new records
		if (checkRoadmapApprovalStatus(newCampAT))
			newCampAT[0].addError(ConstantUtil.BLOCKED_CAMPAIGN_ASSET_TYPE);
	}
	
	public void onBeforeUpdate(Map<Id,CW_Campaign_Asset_Type__c> newCampATMap, Map<Id,CW_Campaign_Asset_Type__c> oldCampATMap)
	{
		//check if campaign roadmap is locked
		Boolean isRoadmapLocked = checkRoadmapApprovalStatus(oldCampATMap.Values());
		for (Id id : newCampATMap.keySet())
		{
			//if camp asset type list has been changes and roadmap is locked stop user to save the records
			if (newCampATMap.get(id).Asset_Type__c!=oldCampATMap.get(id).Asset_Type__c && isRoadmapLocked)
			{
				oldCampATMap.get(id).Asset_Type__c.addError(ConstantUtil.BLOCKED_CAMPAIGN_ASSET_TYPE);
				break;
			}
		}
	}
	
	//check is campiagn roadmap is approved or in approval
	public Boolean checkRoadmapApprovalStatus(List<CW_Campaign_Asset_Type__c> newCampAT)
	{
		CW_Campaign__c campDetails = [SELECT Id,Locked_Roadmap__c 
											FROM CW_Campaign__c
											WHERE Id =: newCampAT[0].Campaign__c];

		if(campDetails!=null && campDetails.Locked_Roadmap__c)
			return true;
		else
			return false;
	}
}