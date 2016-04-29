/**
* File Name   :    CW_CampaignTriggerHandler.cls
* Description :    B-108780: Lock the creation of new campaign for a roadmap that 
*				   is "In Approval" or "Approved"
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 16/04/2014 Cristina P.	Intial
* 0.2 29/04/2014 Chris Yorskton MarCom Points on Campaign rolled up to Roadmap
* 0.3 21/05/2014 Chris Yorskton Trigger on Campaign, every time stage changes, update stage (picklist) on all child schedules
*
*/

//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing" 
//so the user can create related records while cost/brief is in approval
public without sharing class CW_CampaignTriggerHandler 
{
	
	private Boolean m_isExecuting = false;

    public CW_CampaignTriggerHandler(Boolean isExecuting){
        m_isExecuting = isExecuting;
    }
	
	public void OnBeforeInsert(
		List<CW_Campaign__c> newObjects, 
		Map<Id,CW_Campaign__c> newObjectMap
	)
	{
		stopNewCampaignCreationWhenRoadmapLocked(newObjects);
	}
	
	public void OnAfterInsert( CW_Campaign__c[] newObjects, Map<Id,CW_Campaign__c> newObjectMap ) {
		rollupPointsOnCampaignToRoadmap(newObjects);
		createSingleSchedules(newObjects);
    }
    
	public void OnBeforeUpdate( Map<Id,CW_Campaign__c> oldObjectMap, Map<Id,CW_Campaign__c> newObjectMap )
	{
		for(Id id : newObjectMap.keySet())
		{
			//stop user change points if roadmap is approved or in approval
			if ((newObjectMap.get(id).Roadmap_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_APPROVED||
            	newObjectMap.get(id).Roadmap_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL) &&
            	newObjectMap.get(Id).Points__c!=oldObjectMap.get(Id).Points__c)
            	newObjectMap.get(id).addError(ConstantUtil.POINTS_CANNOT_BE_UPDATED);
            	
            if(newObjectMap.get(id).Roadmap__c != oldObjectMap.get(id).Roadmap__c)
            {
            	//stop user add a new campaign to a roadmap that is in approval or already approved
            	stopNewCampaignCreationWhenRoadmapLocked(newObjectMap.Values()); 
            	//stop user saving the campaign is roadmap is in approval or approved
            	if (oldObjectMap.get(id).Roadmap_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_APPROVED||
            	oldObjectMap.get(id).Roadmap_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL)
            		newObjectMap.get(id).addError(ConstantUtil.REMOVE_ROADMAP_ERROR);
            }
            //if brief is rejected or brief approval status has been changed to not submitted when brief was recalled 
            //using standard recall functionality, change the campaign stage based on roadmap approval status	
 			if ((newObjectMap.get(id).Brief_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_REJECTED || 
 				newObjectMap.get(id).Brief_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED) && 
 			    newObjectMap.get(id).Brief_Approval_Status__c!=oldObjectMap.get(id).Brief_Approval_Status__c)
 			{
 				if(oldObjectMap.get(id).Roadmap_Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_APPROVED)
 					newObjectMap.get(id).Stage__c = ConstantUtil.CAMP_STAGE_ROADMAP_APPROVED;
 				else
 					newObjectMap.get(id).Stage__c = ConstantUtil.CAMP_STAGE_DRAFT;
 			}
 		}
 	}
            	
	public void OnAfterUpdate(
		CW_Campaign__c[] oldObjects, 
		CW_Campaign__c[] updatedObjects, 
		Map<Id,CW_Campaign__c> oldObjectMap, 
		Map<Id,CW_Campaign__c> updatedObjectMap
	) {
		// we are interested in Campaigns where the points have changed
		// OR where the campaign was previous a child of a Roadmap (parent) and will impact points on the parent
		List<CW_Campaign__c> campaignsWithUpdatedPoints = new List<CW_Campaign__c>();
		Map<Id,List<CW_Campaign__c>> reparentedObjectMap = new Map<Id,List<CW_Campaign__c>>();
		
		// we are interested in campaigns where the stage has changed
		Map<Id,CW_Campaign__c> campaignsWithUpdatedStage = new Map<Id,CW_Campaign__c>();
		
		for (CW_Campaign__c c :updatedObjects) {
			
			CW_Campaign__c oldObject = oldObjectMap.get(c.Id);
			
			// campaign has a Roadmap (parent)
			if ( c.Roadmap__c!=null ) {
				
				// we are interested in campaigns where points have changed
				// OR the campaign previously did not have a Roadmap and will now have a impact on points
				if ( 
					c.Points__c!=oldObject.Points__c 
					|| ( oldObject.Roadmap__c==null && ( oldObject.Points__c!=null && oldObject.Points__c!=0 ) )
				) {
					campaignsWithUpdatedPoints.add(c);
				}
			}
			// campaign does not have a Roadmap (parent)
			else {
				
				// we are only interested in campaigns which previously had a roadmap AND will have an impact on points
				if ( oldObject.Roadmap__c!=null && ( oldObject.Points__c!=null && oldObject.Points__c!=0 ) ) {
					List<CW_Campaign__c> reparentedCamps = reparentedObjectMap.get(oldObject.Roadmap__c);
					if (reparentedCamps==null) reparentedCamps = new List<CW_Campaign__c>();
					reparentedCamps.add(c);
					reparentedObjectMap.put(oldObject.Roadmap__c, reparentedCamps);
				}
			}
			
			// campaign stage has changed
			if (c.Stage__c!=oldObject.Stage__c) {
				campaignsWithUpdatedStage.put(c.Id,c);
			}
		}
		
		// if campaign previously had a roadmap, remove its campaigns points from the Roadmap (parent)
    	if (!reparentedObjectMap.isEmpty()) updateRoadmapWhenCampaignsHaveBeenReparented(reparentedObjectMap);
    	
        if (!campaignsWithUpdatedPoints.isEmpty()) rollupPointsOnCampaignToRoadmap(campaignsWithUpdatedPoints);
        
        // if campaign stage has changed, update its child schedules with the new stage
        if (!campaignsWithUpdatedStage.isEmpty()) updateChildSchedulesWithCampaignStage(campaignsWithUpdatedStage);
        
        // handle schedules
        cascadeDeleteSchedulesOnUpdate(updatedObjects,oldObjectMap);
    }
    
    public void OnAfterDelete( CW_Campaign__c[] deletedObjects, Map<Id,CW_Campaign__c> objectMap ) {
        rollupPointsOnCampaignToRoadmap(deletedObjects);
    }

    public void OnUndelete( CW_Campaign__c[] restoredObjects, Map<Id,CW_Campaign__c> restoredObjectMap ) {
        rollupPointsOnCampaignToRoadmap(restoredObjects);
    }
    
    // rollup summary - sum all points on Campaigns (children) to Roadmap (parent)
    public void rollupPointsOnCampaignToRoadmap(CW_Campaign__c[] campaigns) {
    	
    	List<CW_Campaign__c> objects = new List<CW_Campaign__c>();
    	
    	for (CW_Campaign__c c :campaigns) {
			// only include those campaigns that have a roadmap parent
			if ( c.Roadmap__c!=null ) objects.add(c);
    	}
			
    	/*
      		First step is to create a context for LREngine, by specifying parent and child objects and
      		lookup relationship field name
     	*/
     	LREngine.Context ctx = new LREngine.Context(
			CW_Roadmap__c.SobjectType, // parent object
			CW_Campaign__c.SobjectType,  // child object
			Schema.SObjectType.CW_Campaign__c.fields.Roadmap__c // relationship field name
		);
		
		/*
	      Next, one can add multiple rollup fields on the above relationship. 
	      Here specify 
	       1. The field to aggregate in child object
	       2. The field to which aggregated value will be saved in master/parent object
	       3. The aggregate operation to be done i.e. SUM, AVG, COUNT, MIN/MAX
     	*/
     	
		ctx.add(
			new LREngine.RollupSummaryField(
				Schema.SObjectType.CW_Roadmap__c.fields.Points_Used__c,
				Schema.SObjectType.CW_Campaign__c.fields.Points__c,
				LREngine.RollupOperation.Sum 
			)
		); 
	
		/* 
			Calling rollup method returns in memory master objects with aggregated values in them. 
			Please note these master records are not persisted back, so that client gets a chance 
			to post process them after rollup
		*/ 
		Sobject[] masters = LREngine.rollUp(ctx, objects);  
		
		// Persist the changes in master
		if (!masters.isEmpty()) update masters;
    }
    
    // Update Roadmap points where campaign previously had a roadmap; remove its campaigns points from the Roadmap (parent)
    // Key of map is Roadmap Id, Value is list of Campaigns that previously had lookup to Roadmap key
    public void updateRoadmapWhenCampaignsHaveBeenReparented(Map<Id,List<CW_Campaign__c>> reparentedObjectMap) {
    	
    	Map<Id,CW_Roadmap__c> roadmaps = new Map<Id,CW_Roadmap__c>([select Id, Points_Used__c from CW_Roadmap__c where Id in :reparentedObjectMap.keySet()]);
		List<CW_Roadmap__c> roadmapsToUpdate = new List<CW_Roadmap__c>();
		
		for (Id roadmapId :reparentedObjectMap.keySet()) {
			Double pointsToRemove = 0;
			List<CW_Campaign__c> camps = reparentedObjectMap.get(roadmapId);
			for (CW_Campaign__c c :camps) {
				pointsToRemove += c.Points__c;
			}
			CW_Roadmap__c roadmap = roadmaps.get(roadmapId);
			if (pointsToRemove!=0) {
				roadmap.Points_Used__c -= pointsToRemove;
				roadmapsToUpdate.add(roadmap);
			}
			
		}
		
		if (!roadmapsToUpdate.isEmpty()) update roadmapsToUpdate;
    }
    
    // update campaign stage on schedules with associated stage on campaign
    public static void updateChildSchedulesWithCampaignStage(Map<Id,CW_Campaign__c> campaigns) {
    	
    	List<CW_Schedule__c> schedules = [select Id, Marketing_Campaign__c, Campaign_Stage__c from CW_Schedule__c where Marketing_Campaign__c in :campaigns.keySet()];
    	
    	// key: campaign Id, value: associated schedules
    	Map<Id,List<CW_Schedule__c>> campaignScheduleMap = new Map<Id,List<CW_Schedule__c>>(); 
    	for (CW_Schedule__c s :schedules) {
    		List<CW_Schedule__c> campaignSchedules = campaignScheduleMap.get(s.Marketing_Campaign__c);
    		if (campaignSchedules==null) campaignSchedules = new List<CW_Schedule__c>();
    		campaignSchedules.add(s);
    		campaignScheduleMap.put(s.Marketing_Campaign__c,campaignSchedules);
    	}
    	
    	// update schedules with Campaign stage value
    	List<CW_Schedule__c> schedulesToUpdate = new List<CW_Schedule__c>();
    	for (CW_Campaign__c c :campaigns.values()) {
    		List<CW_Schedule__c> campaignSchedules = campaignScheduleMap.get(c.Id);
    		
    		if (campaignSchedules!=null) {
	    		for (CW_Schedule__c s :campaignSchedules) {
	    			s.Campaign_Stage__c = c.Stage__c;
	    			schedulesToUpdate.add(s);
	    		}
    		}
    	}
    	
    	if (!schedulesToUpdate.isEmpty()) update schedulesToUpdate;
    }
	
	public void stopNewCampaignCreationWhenRoadmapLocked(List<CW_Campaign__c> newObjects)
	{
		List<CW_Roadmap__c> roadmapDetails = [SELECT Id, Approval_Status__c
											  FROM CW_Roadmap__c
											  WHERE Id =: newObjects[0].Roadmap__c];
											  
		if (!roadmapDetails.isEmpty())
		{
			for (CW_Roadmap__c curr : roadmapDetails)
			{
				if (curr.Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_APPROVED ||
					curr.Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL)
				{
					newObjects[0].addError(ConstantUtil.BLOCKED_NEW_CAMPAIGN);
					break;
				}
			}
		}
	}
	
	public void createSingleSchedules(List<CW_Campaign__c> newCamps)
	{
		List<CW_Schedule__c> schs = new List<CW_Schedule__c>();
		for(CW_Campaign__c camp : newCamps)
		{
			if(camp.Recurrence_Type__c == ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_SINGLE)
			{
				CW_Schedule__c sch = new CW_Schedule__c();
				sch.Marketing_Campaign__c = camp.id;
				sch.Start_Date__c = camp.Campaign_Start_Date__c;
				sch.End_Date__c = camp.Campaign_End_Date__c;
				sch.Evaluation_Start_Date__c = sch.Start_Date__c;
				sch.Evaluation_End_Date__c = sch.End_Date__c.addDays(ConstantUtil.EVALUATION_DATE_OFFSET);
				schs.add(sch);
			}
		}
		insert schs;
	}
	
	public void cascadeDeleteSchedulesOnUpdate(List<CW_Campaign__c> newObjects, Map<Id,CW_Campaign__c> oldObjectMap)
	{
		List<CW_Campaign__c> camps = new List<CW_Campaign__c>();	// list of campaigns which need schedules removed
		for(CW_Campaign__c camp : newObjects)
		{
			if(camp.Recurrence_Type__c != oldObjectMap.get(camp.id).Recurrence_Type__c ||
			   camp.Campaign_Start_Date__c != oldObjectMap.get(camp.id).Campaign_Start_Date__c ||
			   camp.Campaign_End_Date__c != oldObjectMap.get(camp.id).Campaign_End_Date__c)
			{
				camps.add(camp);
			}
		}
		
		if(camps.isEmpty())
		{
			return;
		}
				
		// remove Schedule + AGS + AGM, Schedule trigger will remove Messaging and AGS Reward + AGS Member
		delete [select id from CW_Schedule__c where Marketing_Campaign__c in :camps];
		// create any new single schedules if needed
		createSingleSchedules(camps);
	}
	
	public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}