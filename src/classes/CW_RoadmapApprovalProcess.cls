/**
* File Name   :    CW_RoadmapApprovalProcess.cls
* Description :    B-108780 As a Marketing Ops Roadmapper I want the ability to send 
*				   a roadmap for MarCom approval.
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 14/04/2014 Cristina P.	Intial
*
*/
global class CW_RoadmapApprovalProcess 
{
	public static Boolean 		isRoadmapper;
	public static Boolean 		submitForApproval;
	public static String 		submitForApprovalMessage;
	public static Set<String> 	currentFieldSet;
	
	//send campaign for approval
	WebService static String SendForApproval(Id roadmapId) 
	{
		String Status = [SELECT Approval_Status__c FROM CW_Roadmap__c WHERE Id =: roadmapId].Approval_Status__c;
		
		List<CW_Campaign__c> campsInRoadmap = new List<CW_Campaign__c>();
		campsInRoadmap = getRoadmapFields(roadmapId);
		
		if (Status !=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL)
		{
			if (campsInRoadmap!=null && !campsInRoadmap.isEmpty())
			{
				if (canUserSubmitForApproval())
				{
					for (CW_Campaign__c curr : campsInRoadmap)
					{
						for (String s : currentFieldSet)
						{
							if (curr.get(s)!=null && curr.get(s)!=0)
								submitForApproval = true;
							else
							{
								submitForApproval = false;
								submitForApprovalMessage = curr.Name;
								break;
							}
						}
						if (submitForApprovalMessage!=null)
							break;
					}
					submitForApprovalMessage += ConstantUtil.SUBMIT_FOR_APPROVAL_ROADMAP_NULL_FIELDS;
				}
				else
				{
					submitForApproval = false;
					submitForApprovalMessage = ConstantUtil.SUBMIT_FOR_APPROVAL_NON_ROADMAPPER; 
				}
			}
			else
			{
				submitForApproval = false;
				submitForApprovalMessage = ConstantUtil.SUBMIT_FOR_APPROVAL_ROADMAP_NO_CAMPS;
			}
			
			if(getApproverIds().isEmpty())
			{
				submitForApproval = false;
				submitForApprovalMessage = ConstantUtil.SUBMIT_FOR_APPROVAL_NO_ROADMAP_APPROVER;
			}	
		}
		else
		{
			submitForApproval = false;
			submitForApprovalMessage = ConstantUtil.SUBMIT_FOR_APPROVAL_ROADMAP_IN_APPROVAL;
		}
		 
		
		if (submitForApproval)
			submitRoadmapForApproval(roadmapId);
		return submitForApprovalMessage;
	}
	
	//get all the field from fieldset
	public static Set<String> getRoadmapFieldset() {
		Set<String> fnames = new set<string>();         
    	
    	for(Schema.FieldSetMember f : Schema.SObjectType.CW_Campaign__c.FieldSets.Roadmap_Fieldset.getFields()) {
           fnames.add(f.getFieldPath());
    	}
       return fnames; 
      
    }
    
    // query all the campaigns related to the roadmap
    public static List<CW_Campaign__c> getRoadmapFields(Id roadmapId)
    {
    	currentFieldSet = getRoadmapFieldset();
		
		String queryString = 'SELECT ';		
		
		for (String curr: currentFieldSet){
			queryString += curr + ', ';
			
		}
		queryString = queryString.removeEnd(', ');
        queryString += ' FROM CW_Campaign__c WHERE Roadmap__c =\'' + roadmapId + '\'';
        return Database.query(queryString);
    }
    
    //submit for approval process
    public static PageReference submitRoadmapForApproval(Id roadmapId) 
    { 
    	
		//submit the roadmap for approval 
    	if (SubmitForApproval)
	    {
 			//define the object and approver for the approval process
 	 		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
 			req.setObjectId(roadmapId);
	 		if (!getapproverIds().isEmpty())
	 		{
	 			req.setNextApproverIds(getapproverIds());
	 			Approval.ProcessResult result = Approval.process(req);
	 			if(result.isSuccess())
		 			submitForApprovalMessage = ConstantUtil.SUBMIT_FOR_APPROVAL_SUCCESFULLY;
	 		} 
	 		else	
	 			submitForApprovalMessage = ConstantUtil.SUBMIT_FOR_APPROVAL_NO_ROADMAP_APPROVER; 
	    } 
		
		return null;
		
 	} 
 	
 	// get the approverId from custom settings
 	public static List<Id> getApproverIds()
 	{
 		List<ApproverListSetting__c> roadmapApprover = new List<ApproverListSetting__c>();
 		List<Id> approverIds = new List<Id>();
		
		//get approver for Roadmap
 		roadmapApprover = [SELECT Type__c, Username__c 
 						   FROM ApproverListSetting__c
 						   WHERE Type__c =: ConstantUtil.APPROVER_TYPE];
		
		if (!roadmapApprover.isEmpty() && UserUtil.getUserId(roadmapApprover[0].username__c)!=null)
			approverIds.add(UserUtil.getUserId(roadmapApprover[0].username__c));
 		
 		return approverIds;
 	}
 	
 	//check if user can submit for approval 
 	//(only users in Roadmapper public group can submit for approval)
 	public static Boolean canUserSubmitForApproval()
 	{
 		//check if user is member of "Roadmapper" group
 		List<GroupMember> groupMembers = [SELECT Id, Group.Id, 
 												 Group.Name, 
 												 Group.Type,
 												 UserOrGroupId 
 										  FROM GroupMember
 										  WHERE UserOrGroupId =:Userinfo.getUserId()
 										  AND Group.Name =: ConstantUtil.APPROVER_TYPE];

 		if (groupMembers.isEmpty())
 			isRoadmapper = false;
 		else 
 			isRoadmapper = true;

 		return isRoadmapper;
 	}

}