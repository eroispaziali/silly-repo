public with sharing class CW_CampaignRewardTriggerHandler 
{
	private Boolean m_isExecuting = false;

    public CW_CampaignRewardTriggerHandler(Boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    public void OnBeforeUpdate(Map<Id,CW_Campaign_Reward__c> oldMap, Map<Id,CW_Campaign_Reward__c> newMap)
	{
		clearRewardIdAndBonus(oldMap,newMap);	
	}
	
	public void clearRewardIdAndBonus(Map<Id,CW_Campaign_Reward__c> oldMap,Map<Id,CW_Campaign_Reward__c> newMap)
	{
		for(Id id : newMap.keySet())
		{
			//if reward type has been changed or reward library has been removed reset all the reward fiels from the table
			if(newMap.get(id).Reward_Type__c!=oldMap.get(id).Reward_Type__c || 
			(newMap.get(id).Reward_Library__c!=oldMap.get(id).Reward_Library__c && newMap.get(id).Reward_Library__c==null))
			{
				newMap.get(id).Code__c = null;
				newMap.get(id).Bonus_ID__c = null;
				newMap.get(id).Reward_Library__c = null;
				newMap.get(id).Amount__c = null;
				newMap.get(id).Currency__c = null;
			}
		}
	}
}