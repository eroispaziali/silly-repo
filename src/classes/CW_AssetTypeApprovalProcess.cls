/**
* File Name   :    CW_AssetTypeApprovalProcess.cls
* Description :    B-108927 Approve / Reject Mailer Dispatch Dates
*				   B-108925 Approve / Reject Teaser Dates
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 16/05/2014 Cristina P.	Intial
*
*/
public with sharing class CW_AssetTypeApprovalProcess 
{
	public void submitAssetTypeForApproval(Id messagingId)
	{
		CW_Messaging__c msg = [SELECT Dispatch_Date__c,Live_Date__c, End_Date__c
							   FROM CW_Messaging__c
							   WHERE Id=: messagingId]; 
							   
		//define the object and approver for the approval process
 	 	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
 		req.setObjectId(messagingId);
		
 		Approval.ProcessResult result = Approval.process(req);
 		if(result.isSuccess() && msg.Dispatch_Date__c!=null && !Apexpages.hasMessages())
	 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ConstantUtil.MAILER_DATE_SUBMITTED_SUCCESSFULLY)); 
 		else if(result.isSuccess() && msg.Live_Date__c!=null && msg.End_Date__c!=null && !Apexpages.hasMessages())
 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ConstantUtil.TEASER_DATES_SUBMITTED_SUCCESSFULLY)); 
		else
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.SUBMIT_FOR_APPROVAL_FAILED)); 
	}
	
}