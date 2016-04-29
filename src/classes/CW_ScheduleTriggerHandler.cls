/**
* File Name   :    CW_ScheduleTriggerHandler.cls
* Description :    Triiger supporter -> calculation of sumaty fields ( Max(date))
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 01/05/2014 Alex Panka	  Intial - Partial copy of CW_AudienceGroupControler 
* 0.2 23/06/2014 Cristina P.  Create AGS on schedule after insert if audience group exists
* 0.3 25/06/2014 Cristina P.  Updated the class from "with sharing" to "without sharing" so the user can create related records while cost/brief is in approval
*
*/

public without sharing class CW_ScheduleTriggerHandler {
	
	private Boolean m_isExecuting = false;

    public CW_ScheduleTriggerHandler(Boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    public void OnBeforeDelete(List<CW_Schedule__c> oldObjects) {
    	cascadeDelete(oldObjects);
	}
	
    public void OnBeforeInsert(List<CW_Schedule__c> newObjects, Map<Id,CW_Schedule__c> newObjectMap) {
		updateScheduleWithCampaignStage(newObjects);
	}
	
	public void OnAfterInsert( CW_Schedule__c[] newObjects, Map<Id,CW_Schedule__c> newObjectMap ) {
		setLastEndDateOnCamaign(newObjects,null);
		createAGS(newObjectMap);
    }
    
    public void OnAfterUpdate(
		CW_Schedule__c[] oldObjects, 
		CW_Schedule__c[] updatedObjects, 
		Map<Id,CW_Schedule__c> oldObjectMap, 
		Map<Id,CW_Schedule__c> updatedObjectMap
	) {
		setLastEndDateOnCamaign(updatedObjects,oldObjects);
	}
	
	public void OnAfterDelete( CW_Schedule__c[] deletedObjects, Map<Id,CW_Schedule__c> objectMap ) {
		setLastEndDateOnCamaign(deletedObjects,null);
    }
    
    public void updateScheduleWithCampaignStage(CW_Schedule__c[] schedules) {
    	
    	Set<Id> campaignIds = new Set<Id>();
		for (CW_Schedule__c s :schedules) campaignIds.add(s.Marketing_Campaign__c);
		Map<Id,CW_Campaign__c> campaigns = new Map<Id,CW_Campaign__c>([select Id, Stage__c from CW_Campaign__c where Id in :campaignIds]);
		
		for (CW_Schedule__c s :schedules) {
			CW_Campaign__c c = campaigns.get(s.Marketing_Campaign__c);
			s.Campaign_Stage__c = c.Stage__c;
		}
    }
	
	//Method for RollupSummaryOnCampaign besed on Shedule  -> MAx(EndDate),Max(EvaluationEndDate)
	public void setLastEndDateOnCamaign(List<CW_Schedule__c> lst1,List<CW_Schedule__c> lst2){
		//We must support delete so in parameter should be new and old
		Set<ID> CampIds= new Set<Id>();
		if(lst1!= null)
			CampIds.AddAll(getCamaignIdsFromScheduleList(lst1));
		if(lst2!= null)
			CampIds.AddAll(getCamaignIdsFromScheduleList(lst2));

		list<CW_Campaign__c> CampLstToUpd=new list<CW_Campaign__c>();
		list<CW_Campaign__c> CampLst=[Select ID, 
												   Latest_Schedule_Evaluation_End_Date__c,
												   Latest_Schedule_End_Date__c,
												   (Select End_Date__c, Evaluation_End_Date__c From Schedules__r)
												FROM CW_Campaign__c where ID=:CampIds ];
		//And now some work for preventing update of Campiagn
		for(CW_Campaign__c campRec :CampLst ){
			Date EndDate= date.newInstance(1900,01,01);
			Date EvalDate= date.newInstance(1900,01,01);
			
			for(CW_Schedule__c sRec : campRec.Schedules__r){
				if(sRec.End_Date__c!=null && sRec.End_Date__c>EndDate ){
					EndDate=sRec.End_Date__c;
				}
				if(sRec.Evaluation_End_Date__c!=null && sRec.Evaluation_End_Date__c>EvalDate ){
					EvalDate=sRec.Evaluation_End_Date__c;
				}
			}
			Boolean toUpdate=( campRec.Latest_Schedule_Evaluation_End_Date__c==null ) || ( campRec.Latest_Schedule_End_Date__c==null );
			if(!toUpdate){
				toUpdate= campRec.Latest_Schedule_Evaluation_End_Date__c!=EvalDate ;
				toUpdate= toUpdate || campRec.Latest_Schedule_End_Date__c!=EndDate ;
			}
			if(toUpdate){
				campRec.Latest_Schedule_End_Date__c=EndDate;
				campRec.Latest_Schedule_Evaluation_End_Date__c=EvalDate ;
				CampLstToUpd.Add(campRec);
			}
		}
		update CampLstToUpd;
		
	}
	
	private Set<Id> getCamaignIdsFromScheduleList(List<CW_Schedule__c> lst){
		Set<ID> ResIds= new Set<Id>();
		for (CW_Schedule__c rec :lst){
			if(!ResIds.contains(rec.Marketing_Campaign__c)){
				ResIds.Add(rec.Marketing_Campaign__c);
			}
		}
		return ResIds;
	}
	
	// remove related objects when deleting an schedule
	public void cascadeDelete(List<CW_Schedule__c> triggerOld)
	{
		// remove Messaging and AGS Reward + AGS Member
		List<CW_Audience_Group_Schedule_Reward__c> removeAGSR = new List<CW_Audience_Group_Schedule_Reward__c>();
		
		for(CW_Audience_Group_Schedule__c ags : 
			[select id, (select id from Audience_Groups_Schedule_Reward__r) 
				from CW_Audience_Group_Schedule__c where Schedule__c in :triggerOld])
		{
			removeAGSR.addAll(ags.Audience_Groups_Schedule_Reward__r);
		}
		delete removeAGSR;
	}
	
	public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    // create audience schedule group on after insert
	public void createAGS(Map<Id,CW_Schedule__c> groupsMap)
	{
		
		// part 1: create AGS
		Map<Id,List<CW_Audience_Group__c>> campAudience = new  Map<Id,List<CW_Audience_Group__c>>(); // k: campaign id, v: list of schedules of camp
		for(CW_Schedule__c gr : groupsMap.values())
		{
			campAudience.put(gr.Marketing_Campaign__c,new List<CW_Audience_Group__c>());
		}
		
		for(CW_Campaign__c camp : [select id, (Select Id, Name, Is_Control_Group__c,Control_Group__c from Audience_Groups__r) from CW_Campaign__c where id in :campAudience.keySet()])
		{
			campAudience.get(camp.Id).addAll(camp.Audience_Groups__r);
		}
		if (!campAudience.isEmpty())
		{
			// now that we have all schedules, create AGS - only after insert
			List<CW_Audience_Group_Schedule__c> agss = new List<CW_Audience_Group_Schedule__c>();
			Map<Id,CW_Audience_Group__c> agMap = new Map<Id,CW_Audience_Group__c>();
			
			for(CW_Schedule__c gr : groupsMap.values())
			{
				for(CW_Audience_Group__c aud : campAudience.get(gr.Marketing_Campaign__c))
				{
					agMap.put(aud.Id,aud);
					CW_Audience_Group_Schedule__c ags = new CW_Audience_Group_Schedule__c();
					ags.Audience_Group__c = aud.id;
					ags.Schedule__c = gr.id;
					ags.Is_Control_Group__c = aud.Is_Control_Group__c;
					agss.add(ags);
				}
			}
			insert agss;
			
			// part2: match control group schedules
			CW_AudienceGroupTriggerHandler.matchControlGroups(agss,agMap);
		}
	}
}