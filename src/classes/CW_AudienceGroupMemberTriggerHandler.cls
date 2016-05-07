/**
* File Name :   CW_AudienceGroupMemberTriggerHandler.cls
* Description : B-106803
*
* Modification Log
* ============================================================================
* Ver Date	   Author		 Modification
* --- ---------- -------------- --------------------------
* 0.1 15/04/2014 Klea Kolaric   Initial version
*
*
*/
public with sharing class CW_AudienceGroupMemberTriggerHandler {
	
	public static void onBeforeInsert(List<CW_Audience_Group_Member__c> newTrigger)
	{
		findScheduleGroup(newTrigger);
	}
	
	// find the most recent group schedule (based on start date) and associate new group members to this
	public static void findScheduleGroup(List<CW_Audience_Group_Member__c> newTrigger)
	{
	Set<Id> groupIds = new Set<Id>();
		for(CW_Audience_Group_Member__c agm : newTrigger)
		{
			if(agm.Audience_Group_LU__c != null)
			{
				groupIds.add(agm.Audience_Group_LU__c);
			}
		}
		
		Date uploadDate = Date.today();
		// key: CW_Audience_Group__c.Id
		Map<Id,CW_Audience_Group_Schedule__c> groupSchedules = new Map<Id,CW_Audience_Group_Schedule__c>();
		
		// select schedules where TODAY is between start and end date i.e. current schedules
		// order by Evaluation_Start_Date__c desc to get closest to TODAY first
		for(CW_Audience_Group_Schedule__c ags : [select id, Audience_Group__c 
												from CW_Audience_Group_Schedule__c
												where Schedule__r.Evaluation_Start_Date__c <= :uploadDate 
													and Schedule__r.Evaluation_End_Date__c >= :uploadDate
													and Audience_Group__c in :groupIds
												order by Schedule__r.Evaluation_Start_Date__c desc])
		{
			// only use first/newest result
			if(!groupSchedules.containsKey(ags.Audience_Group__c))
			{
				groupSchedules.put(ags.Audience_Group__c,ags);
			}
		}
		
		for(CW_Audience_Group_Member__c agm : newTrigger)
		{
			if(agm.Audience_Group_LU__c != null)
			{
				CW_Audience_Group_Schedule__c audienceGroupSchedule = groupSchedules.get(agm.Audience_Group_LU__c);
				if (audienceGroupSchedule!=null)
					agm.Audience_Group_Schedule__c = audienceGroupSchedule.Id;
			}
		}	
	}

}