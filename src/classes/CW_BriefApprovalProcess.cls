/**
* File Name   :    CW_BriefApprovalProcess .cls
* Description :    B-106804 As a Marketing Ops I want the ability to submit a MarCom Brief
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 24/04/2014 Cristina P.	Intial
*
*/
public with sharing class CW_BriefApprovalProcess 
{
	public Set<String> 	briefFieldSet;
	public String 		errorMessage;
	public Boolean briefRequiresApproval;
	public Boolean submitBriefForApproval;
	
	//check if required fields are populated
	public Boolean checkBriefForApproval(CW_Campaign__c camp)
 	{
		//loop though required fields from brief fieldset
 		for (CW_Campaign__c curr : getBriefRequiredFields(camp.Id))
		{
			for (String s : briefFieldSet)
			{
				if (curr.get(s)!=null && curr.get(s)!=0)
					briefRequiresApproval = true;
				else
				{
					briefRequiresApproval = false;
					break;
				}
			}
		}
		//brand, label, language, country are required fields from brief approval
		//check if there is a campaign site associated to the campiagn
		List<CW_Campaign_Sites__c> campSites = [SELECT Name FROM CW_Campaign_Sites__c WHERE Campaign__c =: camp.Id];						
 		//fields required are all populated an there is campSite for the Brief
 		if (briefRequiresApproval && !campSites.isEmpty())
 		{
 			if (!camp.Urgent_Campaign__c)
 			{
 				// brief is linked to a roadmap
	 			if (camp.Roadmap__c!=null)
	 			{
	 				//roadmap MUST be approved so Brief can be submitted
		 			String RoadmapStatus = [SELECT Approval_Status__c 
		 									FROM CW_Roadmap__c 
		 									WHERE Id =: camp.Roadmap__c].Approval_Status__c;
	 				
	 				//roadmap APPROVED so brief can be submitted for approval
			 		if (RoadmapStatus == ConstantUtil.APPROVAL_PROCESS_APPROVED)
			 			submitBriefForApproval = true;
			 		else
			 		{
			 			//roadmap NOT APPROVED so brief CANNOT be submitted for approval
			 			errorMessage = ConstantUtil.SUBMIT_FOR_APPROVAL_BRIEF_NO_ROADMAP_APPROVED + RoadmapStatus;
			 				
			 			submitBriefForApproval = false;
			 		}
	 			}
	 			else
	 			{
	 				//Brief NOT linked to a roadmap
	 				errorMessage = ConstantUtil.SUBMIT_FOR_APPROVAL_BRIEF_NO_ROADMAP;
			 		submitBriefForApproval = false;
	 			}
 			}
 			// campaign IS urgent
 			else 
 				submitBriefForApproval = true;
 		}
 		else 
 		{
 			//NOT all the required fields are populated Brief CANNOT be submitted
 			submitBriefForApproval = false;
 		}
 		
		if (getapproverIds().isEmpty())
		{
			submitBriefForApproval = false;
			errorMessage = ConstantUtil.SUBMIT_FOR_APPROVAL_NO_BRIEF_APPROVER;
		} 
 		
 		return submitBriefForApproval;
 	}
 	
 	//get all the field from fieldset
	public Set<String> getBriefFieldset() {
		Set<String> fnames = new set<string>();         
    	
    	for(Schema.FieldSetMember f : Schema.SObjectType.CW_Campaign__c.FieldSets.Marcom_Brief_Fields.getFields()) {
           fnames.add(f.getFieldPath());
    	}
       return fnames; 
    }
    
    // query all the campaigns related to the roadmap
    public List<CW_Campaign__c> getBriefRequiredFields(Id campId)
    {
    	briefFieldSet = getBriefFieldset();
		
		String queryString = 'SELECT ';		
		
		for (String curr: briefFieldset){
			queryString += curr + ', ';
			
		}
		queryString = queryString.removeEnd(', ');
        queryString += ' FROM CW_Campaign__c WHERE Id =\'' + campId + '\'';
        return Database.query(queryString);
    }
 	
 	//if submit brief criteria is met submit for approval
	public Boolean submitBriefForApproval(CW_Campaign__c camp) 
    {
    	Boolean isSubmitted = false;

    	if (checkBriefForApproval(camp))
    	{
    		camp.Brief_Approval__c = true;
    		upsert camp;
	    	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
	 		req.setObjectId(camp.Id);
		 	req.setNextApproverIds(getapproverIds());
		 	Approval.ProcessResult result = Approval.process(req);
				
		 		if(result.isSuccess()) 
		 		{ 
		 			//CW_LockFieldsApprovalSubmission lockBriefFileds = new CW_LockFieldsApprovalSubmission();
		 			//lockBriefFileds.lockFields(ConstantUtil.MARCOM_BRIEF_FIELDSET_NAME,ConstantUtil.MARCOM_BRIEF_LOCKED_FIELDSET_NAME);
		 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ConstantUtil.SUBMIT_FOR_APPROVAL_SUCCESFULLY)); 
		 			isSubmitted = true;
		 			
		 		} 
		 		else { 
		 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.SUBMIT_FOR_APPROVAL_FAILED)); 
		 		} 
    	}
    	//notify user why Brief CANNOT be submitted
 		else if (errorMessage!= null)
 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
    	
    	return isSubmitted;
    }
    
    // get the approverId from custom settings
 	public static List<Id> getApproverIds()
 	{
 		List<ApproverListSetting__c> briefApprover = new List<ApproverListSetting__c>();
 		
 		List<Id> briefApproverIds = new List<Id>();
		
		//get approver for Roadmap
 		briefApprover = [SELECT Role__c, Username__c, Type__c 
 						 FROM ApproverListSetting__c
 						 WHERE Role__c =:UserUtil.getCurrentRoleName(Userinfo.getUserId())
 						 AND Type__c =: ConstantUtil.APPROVER_TYPE_BRIEF];
		
		if (!briefApprover.isEmpty() && UserUtil.getUserId(briefApprover[0].username__c)!=null)
			briefApproverIds.add(UserUtil.getUserId(briefApprover[0].username__c));
 		
 		return briefApproverIds;
 	}
 	
}