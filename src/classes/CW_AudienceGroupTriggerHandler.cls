/**
* File Name :   CW_AudienceGroupTriggerHandler.cls
* Description : D-106803
*
* Modification Log
* ============================================================================
* Ver Date	   Author		 Modification
* --- ---------- -------------- --------------------------
* 0.1 24/04/2014 AleX Panka      Initial version
* 0.2 25/04/2014 Klea Kolaric    B-111670
* 0.3 03/06/2014 Klea Kolaric    B-114503
*
*
*/
//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing" 
//so the user can create related records while cost/brief is in approval
public without sharing class CW_AudienceGroupTriggerHandler {
	
	public static final String SEPARATOR = '_';
	
	public static void OnBeforeUpdateValidation(List<CW_Audience_Group__c> oldRecs, Map<Id,CW_Audience_Group__c> newRecs){
		List<Id> IdsToCheck= new List<Id>();
		//As trhere is less control groups we fiter for them
		for(CW_Audience_Group__c Oldrec :oldRecs ){
			if(OldRec.Is_Control_Group__c){
				CW_Audience_Group__c NewRec=newRecs.get(OldRec.ID);
				if (!NewRec.Is_Control_Group__c){
					//We have winner ;-)
					IdsToCheck.Add(OldRec.ID);
				}
			}
		}
		if( IdsToCheck.Size()>0){
			system.debug('#############There a records to chceck');
			for(CW_Audience_Group__c Rec: [SELECT ID, 
																(Select Id  From Control_Groups__r Limit 1) 
						  								FROM CW_Audience_Group__c  
						  								WHERE ID =: IdsToCheck]){
				if(Rec.Control_Groups__r==null)	
					continue;
			}
		}else system.debug('#############There a no records chceck');
	}
	
	// update AGS if major changes on AG
	public static void updateAGS(Map<Id,CW_Audience_Group__c> newTriggerMap, Map<Id,CW_Audience_Group__c> oldTriggerMap)
	{
		List<CW_Audience_Group__c> changedGroups = new List<CW_Audience_Group__c>();	// only work with AG who's AGSs need update
		for(CW_Audience_Group__c ag : newTriggerMap.values())
		{
			if(ag.Is_Control_Group__c != oldTriggerMap.get(ag.Id).Is_Control_Group__c
				|| ag.Control_Group__c != oldTriggerMap.get(ag.Id).Control_Group__c)
			{
				changedGroups.add(ag);
			}
		}
		
		changedGroups = audienceGroupsWithAGS(changedGroups);
		List<CW_Audience_Group_Schedule__c> agss = new List<CW_Audience_Group_Schedule__c>();
		for(CW_Audience_Group__c ag : changedGroups)
		{
			for(CW_Audience_Group_Schedule__c ags : ag.Audience_Group_Schedules__r)
			{
				ags.Is_Control_Group__c = ag.Is_Control_Group__c;
				ags.Control_Group_Schedule__c = null;	// reset
			}
			agss.addAll(ag.Audience_Group_Schedules__r);
			ag.Audience_Group_Schedules__r.clear();		// reduce heap size
		}
		
		matchControlGroups(agss, new Map<Id,CW_Audience_Group__c>(changedGroups));
	}
	
	// create audience schedule group on after insert
	public static void createAGS(Map<Id,CW_Audience_Group__c> groupsMap)
	{
		
		// part 1: create AGS
		Map<Id,List<CW_Schedule__c>> campSchedules = new  Map<Id,List<CW_Schedule__c>>(); // k: campaign id, v: list of schedules of camp
		for(CW_Audience_Group__c gr : groupsMap.values())
		{
			campSchedules.put(gr.Campaign__c,new List<CW_Schedule__c>());
		}
		
		for(CW_Campaign__c camp : [select id, (select id from Schedules__r) from CW_Campaign__c where id in :campSchedules.keySet()])
		{
			campSchedules.get(camp.Id).addAll(camp.Schedules__r);
		}
		
		// now that we have all schedules, create AGS - only after insert
		List<CW_Audience_Group_Schedule__c> agss = new List<CW_Audience_Group_Schedule__c>();
		for(CW_Audience_Group__c gr : groupsMap.values())
		{
			for(CW_Schedule__c sch : campSchedules.get(gr.Campaign__c))
			{
				CW_Audience_Group_Schedule__c ags = new CW_Audience_Group_Schedule__c();
				ags.Audience_Group__c = gr.id;
				ags.Schedule__c = sch.id;
				ags.Is_Control_Group__c = gr.Is_Control_Group__c;
				agss.add(ags);
			}
		}
		insert agss;
		
		// part2: match control group schedules
		matchControlGroups(agss,groupsMap);
	}
	
	// fix links to control groups
	public static void matchControlGroups(List<CW_Audience_Group_Schedule__c> agss, Map<Id,CW_Audience_Group__c> groupsMap)
	{
		
		Map<String,CW_Audience_Group_Schedule__c> allAGS = createComboSet(agss);
		
		Set<Id> missingIds = new Set<Id>();	// control groups schedules we will need to select from the database
		for(CW_Audience_Group__c gr : groupsMap.values())
		{
			if(gr.Control_Group__c != null && !groupsMap.containsKey(gr.Control_Group__c))	// if the control group is not in trigger list
			{
				missingIds.add(gr.Control_Group__c);
			}
		}
		
		if(!missingIds.isEmpty())	// find any that might be missing from the trigger list
		{
			for(CW_Audience_Group_Schedule__c ags : 
					[select id, Audience_Group__c, Schedule__c from CW_Audience_Group_Schedule__c where Audience_Group__c in :missingIds])
			{
				allAGS.put(makeComboKey(ags.Audience_Group__c,ags.Schedule__c),ags);
			}
		}
		missingIds.clear();
		Set<String> removeKeys = new Set<String>();
		
		for(CW_Audience_Group_Schedule__c ags : allAGS.values())
		{
			if(groupsMap.containsKey(ags.Audience_Group__c))	// to avoid additionally added ags-s
			{
				Id controlGroup = groupsMap.get(ags.Audience_Group__c).Control_Group__c;
				if(String.isNotBlank(controlGroup))
				{
					String comboKey = makeComboKey(controlGroup,ags.Schedule__c);
					if(allAGS.containsKey(comboKey))
					{
						ags.Control_Group_Schedule__c = allAGS.get(comboKey).Id;
					}
				}
			}
			else
			{
				// we can remove AGS which weren't passed in
				removeKeys.add(makeComboKey(ags.Audience_Group__c,ags.Schedule__c));
			}
		}
		
		for(String comboKey : removeKeys)	// no need to update AGS which were added from missingIds
		{
			allAGS.remove(comboKey);
		}
		
		update allAGS.values();	// i'm updating all AGS that were passed in to make method more reusable
	}
	
	// this should happen on before delete because the required lookup will otherwise prevent delete
	public static void cascadeDelete(List<CW_Audience_Group__c> groups)
	{
		List<CW_Audience_Group_Schedule__c> removeAGS = new List<CW_Audience_Group_Schedule__c>();
		List<CW_Audience_Group_Schedule_Reward__c> removeAGSR = new List<CW_Audience_Group_Schedule_Reward__c>();
		
		for(CW_Audience_Group_Schedule__c ags : 
			[select id,(select id from Audience_Groups_Schedule_Reward__r) 
				from CW_Audience_Group_Schedule__c where Audience_Group__c = :groups])
		{
			removeAGS.add(ags);
			removeAGSR.addAll(ags.Audience_Groups_Schedule_Reward__r);
		}
		delete removeAGSR;
		delete removeAGS;
	}
	
	/* helper methods */
	
	private static Map<String,CW_Audience_Group_Schedule__c> createComboSet(List<CW_Audience_Group_Schedule__c> agss)
	{
		// k: AudienceGroup.id_Schedule.id, v: Audience_Group_Schedule
		Map<String,CW_Audience_Group_Schedule__c> allAGS = new Map<String,CW_Audience_Group_Schedule__c>();
		
		for(CW_Audience_Group_Schedule__c ags : agss)
		{
			allAGS.put(makeComboKey(ags.Audience_Group__c,ags.Schedule__c),ags);
		}
		return allAGS;
	}
	
	private static List<CW_Audience_Group__c> audienceGroupsWithAGS(List<CW_Audience_Group__c> groups)
	{
		return [select id, Is_Control_Group__c, Control_Group__c,
				(select id, Control_Group_Schedule__c, Is_Control_Group__c, Schedule__c from Audience_Group_Schedules__r)
				from CW_Audience_Group__c where id in :groups];
	}
	
	private static String makeComboKey(Id agId, Id schId)
	{
		return agId + SEPARATOR + schId;
	}
	
	// a control group can't have a control group associated with it so remove it
	public static void removeControlGroupsFromControlGroups(List<CW_Audience_Group__c> newTrigger)
	{
		for(CW_Audience_Group__c ag : newTrigger)
		{
			if(ag.Is_Control_Group__c)
			{
				ag.Control_Group__c = null;
			}
		}
	}

}