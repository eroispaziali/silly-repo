/**
* File Name   :    CW_TaskController.cls
* Description :    Controller for CW_New_Task.page. Create tasks related to a campaign
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 07/04/2014 Chris Yorkston Initial version
* 0.2 22/04/2014 AleX Panka     Confirmation Message
* 0.3 29/07/2014 Cristina P		Help Center
*
*
*/
public with sharing class CW_TaskController
{
	public CW_Task__c 		newTask {get; set;}
	public CW_Task__c 		taskToEdit {get; set;}
	public List<CW_Task__c> tasksList {get;set;}
	public List<Attachment> campAttachs {get;set;}
	public List<ProcessInstance> appsProcess{get;set;}
	public Boolean IsSubmittedForMessagingApproval{get;set;}
	public Id 				campaignId {get;set;}
	public Id 				taskId {get;set;}
	public Id				attachId {get;set;}

	public Boolean 			closeDialog {get; set;}
	public Boolean 			createMode {get;set;}
	public Boolean 			editMode {get;set;}
	public Boolean 			canUserCreate {get;set;}
	public Boolean			showAttachTable {get;set;}
	public String 			URL {get;set;}
	public String mailerMessagingApprovalStatus{get; set;}
	public String teaserMessagingApprovalStatus{get; set;}
	public String smsMessagingApprovalStatus{get; set;}
	public Boolean messagingAvailable{get; set;}
	public Boolean teasermessagingAvailable{get; set;}
	public Boolean smsmessagingAvailable{get; set;}
	public String assetType{get;set;}
	//initiate controller
	public CW_TaskController()
	{
		campaignId = ApexPages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_ID);
		      	newTask = new CW_Task__c(Marketing_Campaign__c = campaignId,OwnerId= getDefaultOwnerId(),Requestor__c = Userinfo.getUserId());
      	if (campaignId!=null)
      	{
      		tasksList = getCampaignTasks(campaignId);
      		campAttachs = getCampaignAttach(campaignId);
      		appsProcess = getApprovalProcesses(campaignId);
      	}
      	if (ApexPages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_TASK_ID)!=null)
      	{
      		editMode = true;
      		createMode = false;
      		taskToEdit = getTaskToEditInfo(ApexPages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_TASK_ID));
      	}
      	else
      	{
      		editMode = false;
      		createMode = true;
      	}
      	canUserCreate = canLogInUserCreateTask();
        messagingAvailable= getMessagingAvailable(ConstantUtil.ASSET_TYPE_NAME);
		teasermessagingAvailable= getMessagingAvailable(ConstantUtil.TEASER_ASSET_TYPE_NAME);
		smsmessagingAvailable= getMessagingAvailable(ConstantUtil.SMS_ASSET_TYPE_NAME);
		messagingApprovalSummary();
        IsSubmittedForMessagingApproval();
	}

	/*							*/
	/*   BUTTONS FUNCTIONALITY  */
	/*							*/

	/* checks whether Campaign is submitted for messaging dates approval */
		public void IsSubmittedForMessagingApproval()
	{
		List<CW_Campaign__c> camptList= [select Id,Name,Is_submitted_for_messaging_approval__c  from CW_Campaign__c where Id  =:campaignId];
	      for(CW_Campaign__c camp : camptList)
	            {
			IsSubmittedForMessagingApproval= camp.Is_submitted_for_messaging_approval__c;
			    }
	}
	//update task
	public void updateTask()
   	{
   		try
		{
			update taskToEdit;
			closeDialog = true;
      		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,'Task succesfully updated'));
      	}
      	catch(exception e) {
			ApexPages.addMessages(e);
		}
   	}

   	//save task
	public void saveTask()
	{
		try
		{
			insert newTask;
			closeDialog = true;
      		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,System.Label.CW_Task_Creation_Confirmation));
      	}
      	catch(exception e) {
			ApexPages.addMessages(e);
		}
   }

   //update the task status if cancel button is pressed
   public void cancelTask()
   {
   		taskToEdit = [SELECT ID, Status__c FROM CW_Task__c WHERE ID=: taskId];
   		taskToEdit.Status__c = 'Cancel';
   		try {
			update taskToEdit;
   		}catch(exception e) {
			ApexPages.addMessages(e);
		}
   		tasksList = getCampaignTasks(campaignId);
   	}

   	public void deleteAttach()
   	{
   		Attachment attach = new Attachment();
   		attach = [SELECT Id, Name FROM Attachment WHERE ID=:attachID];
   		try
		{
			delete attach;
			campAttachs = getCampaignAttach(campaignId);
      		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,'Attachment succesfully deleted'));
      	}
      	catch(exception e) {
			ApexPages.addMessages(e);
		}
   	}

   	//query all fields needed to display on the page when editing the task
   	public CW_Task__c getTaskToEditInfo(Id taskId)
   	{
   		return [SELECT Name, Details__c, Due_Date__c, Status__c, Category__c,OwnerId, Requestor__c FROM CW_Task__c WHERE ID = : taskId];
   	}

   	//get the task queue id to default the owner when new task is created
   	public Id getDefaultOwnerId()
   	{
   		return [SELECT Id FROM Group WHERE Name =: ConstantUtil.TASK_QUEUE AND Type =: ConstantUtil.PAGEPARAM_QUEUE].Id;
   	}

   	// get all fields from fieldset to display on the task table
	public List<Schema.FieldSetMember> getFields() {
		return SObjectType.CW_Task__c.FieldSets.getMap().get(ConstantUtil.CAMPAIGN_TASK_FIELDSET_NAME).getFields();
	}

	// get all fields from fieldset to display on the edit task modal
	public List<Schema.FieldSetMember> getNewCampTask() {
		return SObjectType.CW_Task__c.FieldSets.getMap().get(ConstantUtil.NEW_CAMPAIGN_TASK_FIELDSET_NAME).getFields();
	}

	//query all tasks related to the campaign
	public List<CW_Task__c> getCampaignTasks(Id campId)
	{
		return [SELECT Id, Name, Details__c, Due_Date__c, Marketing_Campaign__c, Category__c, Status__c,OwnerId, Requestor__c,Has_Description__c FROM CW_Task__c WHERE Marketing_Campaign__c=: campId];
	}

	//get all the templates from HelpCentreUsefulLinks__c custom settings and display them in a table
	public List<HelpCentreUsefulLinks__c> getUsefulTemplates()
	{
		return [SELECT Id, Name, URL__c, Description__c FROM HelpCentreUsefulLinks__c];
	}

	public List<Attachment> getCampaignAttach(Id campId)
	{
		return [SELECT Id, Name, Body, Description, OwnerId FROM Attachment WHERE ParentID =: campId];
	}

	//get all approval process steps for current campaign
	public List<ProcessInstance> getApprovalProcesses(Id campId)
	{
		return [SELECT Id,CreatedDate,ProcessDefinitionId,ProcessDefinition.Name,
					   (SELECT Id, ActorId, Actor.Name, Comments, StepStatus, CreatedDate
					   FROM Steps ORDER BY CreatedDate)
			   FROM ProcessInstance
			   WHERE TargetObjectId=: campId
			   ORDER BY CreatedDate, ProcessDefinition.Name DESC];
	}

	//check if user has create access on task from the wizard Help Centre page (CIM and BI cannot see the create button)
	public Boolean canLogInUserCreateTask()
	{
		if (UserUtil.getCurrentRoleName(Userinfo.getUserId())!='CIM' && UserUtil.getCurrentRoleName(Userinfo.getUserId())!='Sports BI')
			return true;
		else
			return false;
	}

	//download template based on url parameter
	public PageReference downloadTemplates()
	{
		if (URL!=null)
		{
			Pagereference pagRef = new PageReference(URL);
			pagRef.setRedirect(false);
			return pagRef;
		}
		else
		{
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'There is no doc'));
			return null;

		}
	}

	public PageReference recall()
	{
		PageReference pg = null;

		List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId
											  FROM ProcessInstanceWorkitem
											  WHERE ProcessInstance.TargetObjectId =: campaignId];
		if (!piwi.isEmpty())
		{
	        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
	        req.setAction(ConstantUtil.RECALL_ACTION);
	        req.setWorkitemId(piwi.get(0).Id);

	        Approval.ProcessResult result = Approval.process(req,false);
			if(result.isSuccess())
			{
				pg = new PageReference('/apex/CW_Help_Centre?Id=' +campaignId);
				pg.setRedirect(true);
				appsProcess = getApprovalProcesses(campaignID);

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ConstantUtil.MARCOM_BRIEF_RECALL_SUCCESFULLY));
			}
			else
			 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.MARCOM_BRIEF_RECALL_FAILED));
		}
		else
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Approval cannot be recalled'));
		return pg;
	}
	/* Changing related messaging records approval status to 'In Approval' & summary fields status to 'In Approval' when it is submitted for approval  */
	public void submitForMessagingDatesApproval()
	{

		Integer  inApprovalRecordCount=0;
		List<CW_Campaign__c> camptList= [select Id,Name,Messaging_Approval_Status__c,Mailer_Messaging_Approval_Status__c,Teaser_Messaging_Approval_Status__c,SMS_Messaging_Approval_Status__c,Is_submitted_for_messaging_approval__c,Is_Submitted_for_Teaser_Approval__c,Is_Submitted_for_SMS_Approval__c,Is_recalled_from_teaser_approval__c,Is_recalled_from_SMS_approval__c,Is_recalled_from_messaging_approval__c  from CW_Campaign__c where Id  =:campaignId];
		for(CW_Campaign__c camp : camptList)
		{
			camp.Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;

			if(assetType==ConstantUtil.ASSET_TYPE_NAME){
				camp.Mailer_Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
				camp.Is_submitted_for_messaging_approval__c=true;
				camp.Is_recalled_from_messaging_approval__c=false;
			}else if(assetType==ConstantUtil.TEASER_ASSET_TYPE_NAME){
				camp.Teaser_Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
				camp.Is_recalled_from_teaser_approval__c=false;
				camp.Is_Submitted_for_Teaser_Approval__c=true;
			}else if(assetType==ConstantUtil.SMS_ASSET_TYPE_NAME){
				camp.SMS_Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
				camp.Is_recalled_from_SMS_approval__c=false;
				camp.Is_Submitted_for_SMS_Approval__c=true;
			}
		}
		update camptList;

		List<CW_Messaging__c> newList=new List<CW_Messaging__c>();
		List<CW_Messaging__c> msgList=mailerMessagingRecords(assetType);
   		 for(CW_Messaging__c msg : msgList)
            {
            	 if(msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED || msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_REJECTED)
            	 {
            	 	 msg.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
            	 	  newList.add(msg);
          	 	}
           }

		update newList;
  	}

	/* fetch summary messaging approval status fields from Campaign for display */
	public void messagingApprovalSummary(){
		 mailerMessagingApprovalStatus='';
		  teaserMessagingApprovalStatus='';
		   smsMessagingApprovalStatus='';
		List<CW_Campaign__c> campList=[SELECT Id,Name,Mailer_Messaging_Approval_Status__c,Teaser_Messaging_Approval_Status__c,SMS_Messaging_Approval_Status__c,Messaging_Approval_Status__c from CW_Campaign__c where Id=:campaignId ];
		for(CW_Campaign__c camp : campList)
		{
			  mailerMessagingApprovalStatus=camp.Mailer_Messaging_Approval_Status__c;
			  teaserMessagingApprovalStatus=camp.Teaser_Messaging_Approval_Status__c;
			   smsMessagingApprovalStatus=camp.SMS_Messaging_Approval_Status__c;
		}
   }
   /* checks available messaging records count to display summay fields..If count is 0 it will not display summary fields */
	public Boolean  getMessagingAvailable(String assetTypeName)
	{
		Boolean tempmessagingAvailable=false;
		List<CW_Asset_Type__c> asset=[select Name from CW_Asset_Type__c where  name =:assetTypeName];
		if(asset!=null && asset.size()>0){
				List<CW_Campaign_Asset__c> asst = [select Id from CW_Campaign_Asset__c where Asset__r.Asset_Type__c in :asset];
				if(asst!=null && asst.size()>0)
				{
					List<CW_Messaging__c> listNew= [SELECT Id,Name, Campaign__c	  FROM CW_Messaging__c  WHERE Campaign__c =:  campaignId and Campaign_Asset__c in :asst];
					 tempmessagingAvailable= listNew != null && listNew.size()>0;
				}
			}
			return tempmessagingAvailable;
	}

	/* It will chnage the status of all In approval records to Not submitted */
	public void recallMessagingDatesApproval()
	{
		Integer  inApprovalRecordCount=0;
		List<CW_Campaign__c> camptList= [select Id,Name,Messaging_Approval_Status__c,Mailer_Messaging_Approval_Status__c,Teaser_Messaging_Approval_Status__c,SMS_Messaging_Approval_Status__c,Is_submitted_for_messaging_approval__c,Is_Submitted_for_Teaser_Approval__c,Is_Submitted_for_SMS_Approval__c,Is_recalled_from_teaser_approval__c,Is_recalled_from_SMS_approval__c,Is_recalled_from_messaging_approval__c  from CW_Campaign__c where Id  =:campaignId];
		for(CW_Campaign__c camp : camptList)
		{

			camp.Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_NEEDS_SUBMISSION;

			if(assetType==ConstantUtil.ASSET_TYPE_NAME){
				camp.Mailer_Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_NEEDS_SUBMISSION;
				camp.Is_submitted_for_messaging_approval__c=false;
				camp.Is_recalled_from_messaging_approval__c=true;
			}else if(assetType==ConstantUtil.TEASER_ASSET_TYPE_NAME){
				camp.Teaser_Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_NEEDS_SUBMISSION;
				camp.Is_recalled_from_teaser_approval__c=true;
				camp.Is_Submitted_for_Teaser_Approval__c=false;
			}else if(assetType==ConstantUtil.SMS_ASSET_TYPE_NAME){
				camp.SMS_Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_NEEDS_SUBMISSION;
				camp.Is_recalled_from_SMS_approval__c=true;
				camp.Is_Submitted_for_SMS_Approval__c=false;
            }
		}
		update camptList;

		List<CW_Messaging__c> newList=new List<CW_Messaging__c>();
		List<CW_Messaging__c> msgList= mailerMessagingRecords(assetType);
		for(CW_Messaging__c msg : msgList)
		{
			if(msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL )
			{
				msg.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED;
                newList.add(msg);
			}
		}

		update newList;
    }

    private List<CW_Messaging__c> mailerMessagingRecords(String assetType)
    {
		List<CW_Messaging__c> listNew=new List<CW_Messaging__c>();
		List<CW_Asset_Type__c> asset=[select Id from CW_Asset_Type__c where  name=:assetType];
		if(asset!=null && asset.size()>0){
			List<CW_Campaign_Asset__c> asst = [select Id from CW_Campaign_Asset__c where Asset__r.Asset_Type__c in :asset];
			if(asst!=null && asst.size()>0)
			{
				listNew= [SELECT Id,Name, Dispatch_Date__c, Label__c, Live_Date__c, End_Date__c,Approval_Status__c, Campaign__c   FROM CW_Messaging__c  WHERE Campaign__c =:  campaignId and Campaign_Asset__c in :asst];
			}
        }
		return listNew;
    }

}