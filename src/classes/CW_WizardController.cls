/**
* File Name   :    CW_WizardController.cls
* Description :    PEN-082
*                  must have be able to be guided through a Sports campaign - wizard creation
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 04/03/2014 Chris Yorkston Intial
* 0.2 07/03/2014 Chris Yorkston Adding page 1
* 0.3 07/03/2014 Klea Kolaric	Brand Page
* 0.4 13/03/2014 KK&CP			One wizard for all pages
* 0.5 24/03/2014 Cristina P		Add the navigation menu functionality
* 0.6 26/03/2014 Cristina P		Add the campaign header to the wizard
* 0.7 18/04/2014 Cristina P		Auto save campaign
* 0.8 23/04/2014 Alex Panka     Popoup dialog for group (Audience Table)
* 0.9 02/05/2014 Klea Kolaric   Asset page reworked
*0.10 02/06/2014 Cristina P		B-117131: give CIM & BI access to audience group/reward
*0.11 16/07/2014 Cristina P		B-114462: Urgent brief without cost approval
*0.12 23/07/2014 Cristina P		B-121604::Entering new lower cost does not trigger approval
*0.13 04/08/2014 Suneetha Jasthi     D-38008 & D-37987
*/

//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing"
//so the user can create related records while cost/brief is in approval
public without sharing class CW_WizardController {

	public ApexPages.StandardController controller {get; set;}

	public String activePage {get;set;}
	public CW_Campaign__c camp {get; set;}
	public String campaignId {get; set;}
	public String fieldSetName;
	//List contains Reocrds from underling  components
	public List<sObject>      sObjectList{get; set;}
	public Boolean            sObjectListIsSaved{get;set;}//Varaible to inform sub components that there was sucesfull save

	/* navigation variables */

	public map<String,CW_Campaign_Navigation_Settings__c> navigationSettings ;
	public map<String,CW_Campaign_Navigation_Settings__c> navigationMenu ;
	public List<String> campaignNavigationMenu {get; set;}
	public Integer pageIndex {get; set;}
	public Boolean hasNext {get; set;}
	public Boolean hasPrevious {get; set;}

	/* campaign header variables */

	public String			approvalBtnLabel {get;set;}
	public String			briefApprovalBtnLabel {get;set;}
	public Boolean 			requiresApproval {get; set;}
	public Boolean 			briefRequiresApproval {get; set;}
	public Boolean 			isAutoApproved {get;set;}
	public Boolean			isBriefSubmitted {get; set;}
	public List<Id>			approverIds;
	public String			username;
	public String 			taskType {get; set;}
	public Boolean			isCIMorBIUser {get;set;}
	public Boolean 			isMarcomUser{get;set;}
	public set<Id>			CimBiUsers;
	public Boolean 			closeDialog {get; set;}

	/* CAMPAIGN DESCRIPTION PAGE variables */
	public CW_WizardBrandLabelUtil pageBrandHelper {get; set;}
	public FieldSetUtil fieldsetHelper {get;set;}
	public String availableSection {get; set;}
	public Integer columnPerRow {get; set;}
	public Integer languagesColumnPerRow {get; set;}
	public Boolean reset{get; set;}


	/* ASSETS PAGE variables */
	public CW_WizardAssetUtil assetHelper {get; set;}
	public CW_AssociateAudienceRewardHelper AssociateRewardHelper{get; set;}
	public Id selectedCampAssetId {get; set;}
	public Id isBriefViewMode {get;set;}

	public CW_WizardController(Apexpages.standardController stdCtrl)
	{
		controller = stdCtrl;
		constructorInit(stdCtrl);
	}

	public CW_WizardController()
	{
		camp = new CW_Campaign__c();
		campaignId = (Id) Apexpages.currentPage().getParameters().get(ConstantUtil.SOBJECT_ID);
		if(campaignId==null)
			campaignId= (Id) Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_CAMPAIGNID);
		camp.id = (Id)campaignId;// Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_CAMPAIGNID);

		constructorInit(null);
	}

	public void constructorInit(Apexpages.standardController stdCtrl)
	{
		sObjectList= new List<sOBject>();
		// load campaign
		if(stdCtrl != null)
		{
			camp = (CW_Campaign__c) stdCtrl.getRecord();
			campaignId =  stdCtrl.getId();
		}
		if(camp.id != null)
		{
			camp = getCampaignInfo();
			campaignId = camp.id;
		}

		CimBiUsers = cimAndBiUsers();
		isCIMorBIUser = CimBiUsers.contains(Userinfo.getUserId());
		isMarcomUser = (UserUtil.getCurrentProfileName(Userinfo.getUserId()) == ConstantUtil.MARCOM_PROFILE) ? true : false;
		navigationSettings = CW_Campaign_Navigation_Settings__c.getAll();
		campaignNavigationMenu = getCampaignNavigationMenu();

		approvalBtnLabel = ConstantUtil.APPROVAL_BTN_LABEL_CRITERIA_NOT_MET + ConstantUtil.SUBMIT_FOR_APPROVAL_COST_SUBMISSION;
		briefApprovalBtnLabel = ConstantUtil.APPROVAL_BTN_LABEL_CRITERIA_NOT_MET + ConstantUtil.SUBMIT_FOR_APPROVAL_BRIEF_SUBMISSION;
		if (camp.id!=null)
		{
			username = UserUtil.getUsername(camp.OwnerId);
			checkApprovalStatus(camp);
			calcBriefRequiresApproval(camp);
		}
		// find active page - avoid issues with URL capitalisation
		String activePageUrl = StringUtil.getPageName(ApexPages.CurrentPage().getUrl().toLowerCase());

		for(CW_Campaign_Navigation_Settings__c cns : navigationMenu.values())
		{
			if(activePageUrl.endsWith(cns.Page_Name__c.toLowerCase()))
			{
				pageIndex = Integer.valueOf(cns.Order__c);
				fieldSetName = cns.Field_Set__c;
				activePage = cns.Name;
				break;
			}
		}
		fieldsetHelper = new FieldSetUtil();
		
		hasNext(); 
		hasPrevious();
		initPages();
	}

	/*** page rendering methods ***/

	// initiation needed for specific pages
	public void initPages()
	{
		pageActions(ConstantUtil.INIT_ACTION);
	}

	// saves needed for specific pages - mostly for related objects
	public void savePages()
	{
		pageActions(ConstantUtil.SAVE_ACTION);
	}

	// data cleanup needed for specific pages
	public void destroyPages()
	{
		pageActions(ConstantUtil.DEST_ACTION);
	}

	private void pageActions(String actionStr)
	{
		if(!navigationSettings.containsKey(activePage)) return;

		// be careful as url is returned as lowercase, will cause missmatch
		String activePageNameLowerCase = navigationSettings.get(activePage).Page_Name__c.toLowerCase();

		// 17/06/2014 - CW_Campaign_Description.page has been deleted and merged into CW_Campaign_Information
		if(Page.CW_Campaign_Information.getUrl().toLowerCase().endsWith(activePageNameLowerCase))
		{
			if(actionStr == ConstantUtil.INIT_ACTION)
			{
				initCampaignDescriptionPage();
			}
			else
			{
				if(actionStr == ConstantUtil.SAVE_ACTION)
				{
					saveCampaignDescriptionPage();
				}
				else
				{
					destroyCampaignDescriptionPage();
				}
			}
		}

		if(Page.CW_Assets.getUrl().toLowerCase().endsWith(activePageNameLowerCase))
		{
			if(actionStr == ConstantUtil.INIT_ACTION)
			{
				initAssetPage();
			}
			else
			{
				if(actionStr == ConstantUtil.SAVE_ACTION)
				{
					//saveAssetPage();
				}
				else
				{
					destroyAssetPage();
				}
			}
		}

		// 17/06/2014 - CW_Asset_Type_Selection has been removed and merged into CW_Creative_Information
		// 25/06/2014 - Asset_Type_Selection has been moved from CW_Creative_Information to new page CW_MarCom_Delivery
		if(Page.CW_MarCom_Delivery.getUrl().toLowerCase().endsWith(activePageNameLowerCase))
		{
			if(actionStr == ConstantUtil.INIT_ACTION)
			{
				initAssetTypeSelectionPage();
			}
			else
			{
				if(actionStr == ConstantUtil.SAVE_ACTION)
				{
					saveAssetTypeSelectionPage();
				}
				else
				{
					destroyAssetTypeSelectionPage();
				}
			}
		}
		if(Page.CW_Associate_Audience_Reward.getUrl().toLowerCase().endsWith(activePageNameLowerCase)){
			if(actionStr == ConstantUtil.INIT_ACTION)
			{
				AssociateRewardHelper = new CW_AssociateAudienceRewardHelper(camp.Id);
			}
			else
			{
				if(actionStr == ConstantUtil.SAVE_ACTION)
				{
					AssociateRewardHelper.PresistChages();
				}
				else
				{
					AssociateRewardHelper=null;
				}
			}
		}
	}

	private String getFieldSetName()
	{
		fieldSetName = navigationSettings.get(activePage).Field_Set__c;
		return fieldSetName;
	}
	//get the fields that are displayed on the Campaign Header
	public List<Schema.FieldSetMember> getHeaderFields()
	{
		return SObjectType.CW_Campaign__c.FieldSets.Campaign_Header.getFields();
  	}

	//get the fields that are diplayed on each VF page
    public List<Schema.FieldSetMember> getFields()
    {
    	return SObjectType.CW_Campaign__c.FieldSets.getMap().get(fieldSetName).getFields();
    }

    /*** campaign methods ***/
	//query all the campaign fields
  	public CW_Campaign__c getCampaignInfo() {
        String queryString = 'SELECT ';
        for (Schema.SObjectField f : Schema.SObjectType.CW_Campaign__c.fields.getMap().values())
        {
            queryString += f.getDescribe().getName() + ', ';
        }
        queryString = queryString.removeEnd(', ');
        queryString += ', Owner.Name FROM CW_Campaign__c WHERE Id =\'' + camp.Id + '\'';
        return Database.query(queryString);
    }

    //check if there is another page to navigate to on the wizard
    public Boolean hasNext()
    {
    	hasNext = false;
    	if (pageIndex <= navigationMenu.values().size()-1)
    		hasNext = true;
    	return hasNext;
    }

    //check if there is a previous page to navigate to on the wizard
    public Boolean hasPrevious()
    {
    	hasPrevious = false;
    	if (pageIndex > 1)
    		hasPrevious = true;
    	return hasPrevious;
    }

    //save the campaign when submit for approval or click on the save button
    public PageReference saveCampaign(){
		saveCampaign_internal(false);
		//campaign saved successfully --> exit campaign and display campaign list view
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR))
		{
			PageReference pageRef = new PageReference('/' + Schema.sObjectType.CW_Campaign__c.keyPrefix + '/o');
	    	pageRef.setRedirect(true);
	    	return pageRef;
		}
		else
			return null;
    }

    private void saveCampaign_internal(boolean isAutoSave)
	{
        // validate required fields
        if(!Test.isRunningTest())	// i'm not able to rewrite tests under the circumstances
        {
            String errorMessage = FieldSetUtil.checkRequiredFieldsFS(camp,getHeaderFields());
            if(String.isNotBlank(errorMessage))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));
                return;
            }
        }

		try	{

			if(sObjectList.Size()>0){
				//First tray to save underling list of Recors.
				List<sObject> ToInsert= new List<sObject>();
				List<sOBject> ToUpdate= new List<sObject>();
				for(Sobject rec :sObjectList ){
					if(rec.Id!=null){
						ToUpdate.Add(rec);
					}else{
						ToInsert.Add(rec);
					}
				}
				if(ToUpdate.Size()>0) update ToUpdate;
				if(ToInsert.Size()>0) insert ToInsert;
				sObjectListIsSaved=true;
			}


			if (camp.Name!=null && !hasCostChangedInApproval(camp))
			{
				checkApprovalStatus(camp);
				camp.Need_Approval__c = isAutoApproved;
				if (!camp.Urgent_Campaign__c && camp.Brief_Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL && hasUrgentCampaignChangedInApproval(camp))
					recallBriefApprovalProcess(camp);
				
				//update the stage to draft after the campaign gets saved for the first time
				if (camp.Stage__c == null) camp.Stage__c = 'Draft';
				
				//stop user saving the campaign if there are any error	
				if (!ApexPages.hasMessages(ApexPages.Severity.ERROR))
					upsert camp;
				camp = getCampaignInfo();
				
				if(!isAutoSave)
 					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ConstantUtil.CAMPAIGN_SAVE_CONFIRMATION));

				campaignId = camp.Id;

				checkApprovalStatus(camp);
				
				savePages();
				destroyPages();
				initPages(); // load current selection again
			} else
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,(camp.Name==null) ? ConstantUtil.CAMPAIGN_SAVE_ERROR : ConstantUtil.CAMPAIGN_SAVE_COST_ERROR));
		}
		catch(Exception ex){
			if (ex.getMessage().contains(ConstantUtil.DUPLICATE_NAME_ERROR))
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ConstantUtil.DUPLICATE_CAMPAIGN_NAME));
			else
				ApexPages.addMessages(ex);
			initPages();
		}

	}

	/*** campaign header methods ***/
	//
	public PageReference submitMarcomBrief()
	{
		CW_BriefApprovalProcess briefAP = new CW_BriefApprovalProcess();
		isBriefSubmitted = briefAP.submitBriefForApproval(camp);
		if (isBriefSubmitted)
		{
			PageReference campPage = new ApexPages.StandardController(camp).view();
			campPage.setRedirect(true);
			//calcBriefRequiresApproval(camp);
			return campPage;
		}else
			return null;
	}

	public Boolean calcBriefRequiresApproval(CW_Campaign__c camp)
	{
		if (camp.Brief_Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL ||
			camp.Brief_Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_APPROVED)
		{
			briefRequiresApproval = false;
			briefApprovalBtnLabel = ConstantUtil.PAGEPARAM_BRIEF + ' ' + camp.Brief_Approval_Status__c;
		}
		else if ((camp.Urgent_Campaign__c) || (camp.Roadmap_Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_APPROVED && camp.Roadmap__c!=null))

		{
			CW_BriefApprovalProcess briefAP = new CW_BriefApprovalProcess();
			briefAP.checkBriefForApproval(camp);
			if (briefAP.briefRequiresApproval && briefAP.submitBriefForApproval)
			{
				briefRequiresApproval = true;
				briefApprovalBtnLabel = ConstantUtil.APPROVAL_BTN_LABEL_SUBMIT_BRIEF_FOR_APPROVAL;
			}
			else
			{
				briefRequiresApproval = false;
				briefApprovalBtnLabel = ConstantUtil.APPROVAL_BTN_LABEL_CRITERIA_NOT_MET + ConstantUtil.SUBMIT_FOR_APPROVAL_BRIEF_SUBMISSION;
			}

		}
		else
		{
			briefRequiresApproval = false;
			briefApprovalBtnLabel = ConstantUtil.APPROVAL_BTN_LABEL_CRITERIA_NOT_MET + ConstantUtil.SUBMIT_FOR_APPROVAL_BRIEF_SUBMISSION;
		}

		return briefRequiresApproval;
	}

	//action for the submit for approval button
	public PageReference submitForApproval()
    {
    	try
    	{
    		checkApprovalStatus(camp);
    		//submit the campaign for approval if the cost is grater than 0
	    	if (camp.Estimated_Cost__c!=null && camp.Estimated_Cost__c>=0 && requiresApproval)
		    {
		 		if (!getapproverIds(camp).isEmpty())
		 		{
		 			camp.Cost_Approval__c = true;
		 			update camp;
		 			//define the object and approver for the approval process
		 	 		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		 			req.setObjectId(camp.Id);
			 		req.setNextApproverIds(getapproverIds(camp));
			 		Approval.ProcessResult result = Approval.process(req);

			 		if(result.isSuccess())
			 		{
			 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ConstantUtil.SUBMIT_FOR_APPROVAL_SUCCESFULLY));
			 		} else {
			 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.SUBMIT_FOR_APPROVAL_FAILED));
			 		}

			 		PageReference campPage = new ApexPages.StandardController(camp).view();
					campPage.setRedirect(true);
					return campPage;
		 		}
		 		else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.SUBMIT_FOR_APPROVAL_NO_ROLE_SPECIFIED));
		    }
		    else if (camp.Estimated_Cost__c==0)
		    {
		    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ConstantUtil.SUBMIT_FOR_APPROVAL_WITH_0_COST));
		    }
		    else if (!requiresApproval && isAutoApproved) {
		    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.APPROVAL_BTN_LABEL_AUTO_APPROVAL));
		    }
		    else if (!requiresApproval && !isAutoApproved) {
		    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.APPROVAL_BTN_LABEL_CRITERIA_NOT_MET));
		    }
		    else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.SUBMIT_FOR_APPROVAL_WITHOUT_COST));
    	}
		catch(Exception ex){
			ApexPages.addMessages(ex);
		}

		return null;
 	}

 	// get the approverId from custom settings
 	public List<Id> getapproverIds(CW_Campaign__c camp)
 	{
 		List<ApproverListSetting__c> listApprovers = new List<ApproverListSetting__c>();
 		approverIds = new List<Id>();

 		listApprovers = [SELECT Limit__c,Role__c, Username__c
 						 FROM ApproverListSetting__c
 						 WHERE Role__c =: UserUtil.getCurrentRoleName(camp.OwnerId)
 						 ORDER BY Limit__c ASC];

		//get the list with approverIds for the owner current role
 		for (ApproverListSetting__c curr : listApprovers)
 		{
 			if (camp.Estimated_Cost__c <= curr.Limit__c)
 			{
 				approverIds.add(UserUtil.getUserId(curr.username__c));
 				break;
 			}
 		}
 		return approverIds;
 	}

 	//set the flag to true if the submit for approval button should be displayed on the VF page
 	//disable the button and display a different label if the campaign is not ready for approval
 	//or doesn't need approval
 	public void checkApprovalStatus(CW_Campaign__c camp)
 	{
 		List<ApproverListSetting__c> approverDetails = [SELECT Limit__c, Role__c, Username__c
		 													      FROM ApproverListSetting__c
		 													      WHERE Role__c = :  UserUtil.getCurrentRoleName(camp.OwnerId)
		 													      AND Username__c = : username];
 		//campaign was NOT already approved or is NOT in approval
		if (camp.Cost_Approval_Status__c!=ConstantUtil.APPROVAL_PROCESS_APPROVED &&
			camp.Cost_Approval_Status__c!=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL)
		{
			// current user is NOT an approver
	 		if (camp.Estimated_Cost__c>=0 && approverDetails.size()==0 && camp.Stage__c == ConstantUtil.CAMP_STAGE_PRODUCTION) {
	 			requiresApproval = true;
	 			isAutoApproved = false;
	 		}

	 		// current user may be an approver (need to check their limit)
	 		else if (camp.Estimated_Cost__c>=0 && approverDetails.size()>0 && camp.Stage__c == ConstantUtil.CAMP_STAGE_PRODUCTION)
	 		{
	 			for (ApproverListSetting__c curr: approverDetails)
	 			{
		 			if (camp.Estimated_Cost__c <= curr.Limit__c)
		 			{
		 				// current user can approve (auto approval) - cost is within their limit
		 				requiresApproval = false;
		 				isAutoApproved = true;
		 				approvalBtnLabel = ConstantUtil.APPROVAL_BTN_LABEL_AUTO_APPROVAL;
		 			}
		 			else {
		 				// current user can NOT approve - cost is outside their limit
		 				requiresApproval = true;
		 				isAutoApproved = false;
		 			}
	 			}
	 		}

	 		// cost is null
	 		else {
	 			requiresApproval = false;
	 			isAutoApproved = false;
	 			approvalBtnLabel = ConstantUtil.APPROVAL_BTN_LABEL_CRITERIA_NOT_MET + ConstantUtil.SUBMIT_FOR_APPROVAL_COST_SUBMISSION;
	 		}

	 		// campaign is already approved or in approval
		}
		else if (camp.Cost_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_APPROVED)
        {
             isAutoApproved = false;
             requiresApproval = false;

            // Added  related to B-121604::Entering new lower cost does not trigger approval
            for (CW_Campaign__c curr: [SELECT Cost_Approval_Status__c,Approved_Amount__c FROM CW_Campaign__c WHERE Id =: camp.Id])
            {
             	//Entering lower cost should auto approve
                if (camp.Estimated_Cost__c<=curr.Approved_Amount__c)
                {
                    isAutoApproved = true;
                    requiresApproval = false;
                }
            }

           	approvalBtnLabel = ConstantUtil.PAGEPARAM_CAMP + ConstantUtil.APPROVAL_PROCESS_APPROVED;
        }

		else if (camp.Cost_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL)
		{
 			requiresApproval = false;
	 		isAutoApproved = false;
	 		approvalBtnLabel = ConstantUtil.PAGEPARAM_CAMP + ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
		}

 		//set the label for submit for approval button to "Sumbit for approval" if the campaign needs approval
 		if (requiresApproval) approvalBtnLabel = ConstantUtil.APPROVAL_BTN_LABEL_SUBMIT_CAMP_FOR_APPROVAL;
 		//return requiresApproval;
 	}

 	//check if the estimated cost has changed while the campiagn is in approval
 	public Boolean hasCostChangedInApproval(CW_Campaign__c camp)
 	{
 		Boolean isCostChangedInApproval = false;
 		for (CW_Campaign__c curr : [SELECT Cost_Approval_Status__c,Estimated_Cost__c FROM CW_Campaign__c WHERE Id =: camp.Id])
 		{
 			//status in approval and cost has changed set the flag to true
 			if (curr.Cost_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL && curr.Estimated_Cost__c!=camp.Estimated_Cost__c)
 			isCostChangedInApproval = true;
 		}

 		return isCostChangedInApproval;
 	}
 	
 	//check if the urgent campaign field has changed while the campaign cost or brief is in approval
 	public Boolean hasUrgentCampaignChangedInApproval(CW_Campaign__c camp)
 	{
 		Boolean isUrgentCampaignFieldChanged = false;
 		for (CW_Campaign__c curr : [SELECT Urgent_Campaign__c,Brief_Approval_Status__c FROM CW_Campaign__c WHERE Id =: camp.Id])
 		{
 			//status in approval and urgent camp flag has been changed
 			if (curr.Brief_Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL && curr.Urgent_Campaign__c!=camp.Urgent_Campaign__c)
 			isUrgentCampaignFieldChanged = true;
 		}

 		return isUrgentCampaignFieldChanged;
 	}

 	//is campaign was saved previously, auto save when navigate
 	//do not remove yet until client doesnt confirm the new saving functionality
 	/*public Boolean autoSave()
 	{
 		Boolean autoSave = false;
 		if (Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_CAMPAIGNID)!=null ||
 			Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_ID)!=null || campaignId !=null)
 			autoSave = true;
 		return autoSave;
 	}*/

	/*** navigation methods ***/

	// This method cancels the wizard, and returns the user to the
	// Opportunities tab
	public PageReference cancel()
	{
		PageReference pageRef = new PageReference('/' + Schema.sObjectType.CW_Campaign__c.keyPrefix + '/o');
    	pageRef.setRedirect(true);
    	return pageRef;
	}

	public PageReference next()
	{
		try
		{
			saveCampaign_internal(true); //if (autoSave()) please don't remove just in case they would like the save functionality again
			camp = getCampaignInfo();
			
			//if any errors are displayed after campaign has been saved to not navigate to next page	
			if (!ApexPages.hasMessages(ApexPages.Severity.ERROR))
			{
				checkApprovalStatus(camp);
				calcBriefRequiresApproval(camp);
				camp.Need_Approval__c = isAutoApproved;
				pageIndex++;
				activePage = getPageByOrder(pageIndex).Name;
				
				PageReference ref = new PageReference('/apex/' + navigationMenu.get(activePage).Page_Name__c);
				fieldSetName = getFieldSetName();
				ref.getParameters().put(ConstantUtil.SOBJECT_ID,camp.Id);
				ref.getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
				ref.setRedirect(true);	// do not destroy controller
				
				hasNext();
				hasPrevious();
				initPages();
	
				return ref;
			}
			else
				return null;
		}
		catch(Exception ex){
			ApexPages.addMessages(ex);
		}

		return null;
	}

	public PageReference back()
	{
		try
		{
			saveCampaign_internal(true); //if (autoSave()) 
			camp = getCampaignInfo();
			
			//if any errors are displayed after campaign has been saved to not navigate to next page	
			if (!ApexPages.hasMessages(ApexPages.Severity.ERROR))
			{
				checkApprovalStatus(camp);
				calcBriefRequiresApproval(camp);
				camp.Need_Approval__c = isAutoApproved;
	
				pageIndex--;
				activePage = getPageByOrder(pageIndex).Name;
				PageReference ref = new PageReference('/apex/' + navigationMenu.get(activePage).Page_Name__c);
				fieldSetName = getFieldSetName();
				ref.getParameters().put(ConstantUtil.SOBJECT_ID,camp.Id);
				ref.getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
				ref.setRedirect(true);
				
				hasNext();
				hasPrevious();
				initPages();
	
				return ref;
			}
			else
				return null;
		}
		catch(Exception ex){
			ApexPages.addMessages(ex);
		}

		return null;
	}

	//method used for the navigation wizard
	public PageReference goToPage()
	{
		try
		{
			saveCampaign_internal(true);//if (autoSave()) 
			camp = getCampaignInfo();
			checkApprovalStatus(camp);
			camp.Need_Approval__c = isAutoApproved;

			PageReference ref = new PageReference('/apex/' + navigationMenu.get(activePage).Page_Name__c);
			fieldSetName = getFieldSetName();
			ref.getParameters().put(ConstantUtil.PAGEPARAM_ID,camp.Id);
			ref.getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
			ref.setRedirect(true);
			pageIndex = Integer.valueOf(navigationMenu.get(activePage).Order__c);

			hasNext();
			hasPrevious();
			initPages();

			return ref;
			
		}
		catch(Exception ex){
			ApexPages.addMessages(ex);
		}

		return null;
	}


	public PageReference displayAudienceTable()
	{
		PageReference ref = new PageReference('/apex/CW_Audience_Group');
		ref.getParameters().put('id',camp.id);
   	ref.setRedirect(true);
   	return ref;
	}

	//getting a list pages to be displayed on the navigation menu using custom settings
	public List<String> getCampaignNavigationMenu()
	{
		campaignNavigationMenu = new List<String>();
		navigationMenu = new map<String,CW_Campaign_Navigation_Settings__c>();
		Integer orderNo = 1;

		for (CW_Campaign_Navigation_Settings__c curr: [SELECT Name,Page_Name__c,Order__c,Field_Set__c,accessibleByCIMorBI__c,accessibleForMarcom__c FROM CW_Campaign_Navigation_Settings__c ORDER BY Order__c])
                {
					if (isCIMorBIUser && curr.accessibleByCIMorBI__c)
                        {
                                campaignNavigationMenu.add(curr.Name);
                                navigationMenu.put(curr.Name,new CW_Campaign_Navigation_Settings__c(Name=curr.Name,Page_Name__c = curr.Page_Name__c,Order__c = orderNo,Field_Set__c = curr.Field_Set__c  ,accessibleForMarcom__c=curr.accessibleForMarcom__c));
                                orderNo ++;
                        }
                        else if(isMarcomUser && curr.accessibleForMarcom__c){
                                        campaignNavigationMenu.add(curr.Name);
                                        navigationMenu.put(curr.Name,new CW_Campaign_Navigation_Settings__c(Name=curr.Name,Page_Name__c = curr.Page_Name__c,Order__c = orderNo,Field_Set__c = curr.Field_Set__c ,accessibleForMarcom__c=curr.accessibleForMarcom__c));
                        }
                        else if(!isCIMorBIUser && !isMarcomUser)
                        {
                                campaignNavigationMenu.add(curr.Name);
                                navigationMenu.put(curr.Name,curr);
		                }

                }
		return campaignNavigationMenu;
	}

	//get the page index
	public CW_Campaign_Navigation_Settings__c getPageByOrder(Integer ind)
	{
		for (CW_Campaign_Navigation_Settings__c curr : navigationMenu.values())
		{
			if(Integer.valueOf(curr.Order__c) == ind)
			{
				return curr;
			}
		}
		return null;
	}

	public String getDetailIdParam()
	{
		return ConstantUtil.PAGEPARAM_CAMPAIGNID;
	}

	/*** CAMPAIGN DESCRIPTION PAGE ***/

	// used to detect which section is active - needs getter to be loaded to page
	public static String BRAND_SECTION { get{ return '1'; } }
	public static String PRODUCT_SECTION { get{ return '2'; } }
	public static String LANGUAGE_SECTION { get{ return '3'; } }
	public static String COUNTRY_SECTION { get{ return '4'; } }

	public void initCampaignDescriptionPage()
	{

		columnPerRow = 4;
		languagesColumnPerRow=6; // D-37986

		availableSection = BRAND_SECTION; // make brands section editable
		// create brand list
		pageBrandHelper = new CW_WizardBrandLabelUtil();
		pageBrandHelper.brands = WrapperUtil.createWrapperList([select id, Name from CW_Brand__c where Is_Active__c = true limit 10000],
																null, ConstantUtil.SOBJECT_NAME, ConstantUtil.SOBJECT_ID,
																ConstantUtil.SOBJECT_ID);
		pageBrandHelper.existingCampSites = CW_WizardBrandLabelUtil.selectCampaignSites(camp.Id);
		markExisting(true,false,false,false);

	}

	public void saveCampaignDescriptionPage()
	{
		if(availableSection != COUNTRY_SECTION)
		{
			return;
		}
		pageBrandHelper.createCampaignSites(camp.Id);
		if(!pageBrandHelper.existingCampSites.isEmpty())
		{
			pageBrandHelper.removeCampaignSites();
		}
	}

	public void destroyCampaignDescriptionPage()
	{
		pageBrandHelper = null;
	}

	public void resetSection()
	{
		availableSection = BRAND_SECTION;
		reset=true;
		pageBrandHelper.existingCampSites = CW_WizardBrandLabelUtil.selectCampaignSites(camp.Id);
		markExisting(true,false,false,false);
	}

	public void loadLabelProductMatrix()
	{
		pageBrandHelper.loadLabelProductMatrix();
		reset=false;
		availableSection = PRODUCT_SECTION;
		markExisting(false,true,false,false);
	}

	public void loadLanguages()
	{
		pageBrandHelper.loadLanguages();
		reset=false;
		if(!markExisting(false,false,true,false))
		{
			for(WrapperUtil.SelectWrapper lang : pageBrandHelper.languages)
			{
				lang.selected = true;
			}
		}
		availableSection = LANGUAGE_SECTION;
	}

	public void loadLabelCountryMatrix()
	{
		pageBrandHelper.loadLabelCountryMatrix();
		reset=false;
		if(!markExisting(false,false,false,true))
		{
			for(WrapperUtil.SelectListWrapper country : pageBrandHelper.labelCountryMatrix)
			{
				for(WrapperUtil.SelectWrapper obj : country.subObjects)
				{
					if(obj.optionValue != null)
					{
						obj.selected = true;
					}
				}
			}
		}
		availableSection = COUNTRY_SECTION;
	}

	public Boolean markExisting(Boolean markBrand, Boolean markProduct, Boolean markLanguage, Boolean markCountry)
	{
		if(pageBrandHelper.existingCampSites == null || pageBrandHelper.existingCampSites.isEmpty() || newBrandAddedToMatrix())
		{
			return false;
		}
		if(markBrand || markLanguage)
		{
			pageBrandHelper.markExistingList(markBrand,markLanguage);
		}
		if(markProduct || markCountry)
		{
			pageBrandHelper.markExistingMatrix(markProduct,markCountry);
		}
		return true;
	}

	// creates a list of "first" indexes for apex repeat
	public List<Integer> getCountryIndexList()
	{
		return CW_WizardBrandLabelUtil.createIndexList(pageBrandHelper.countryColumns.size(), columnPerRow);
	}
	public List<Integer> getLanguagesIndexList()
    {
        return CW_WizardBrandLabelUtil.createIndexList(pageBrandHelper.languages.size(), languagesColumnPerRow);
    }

	//method that checks if new brand was added to labelCountryMatrix so all the contries
	//for the new brand get automatically selected
	public Boolean newBrandAddedToMatrix()
	{
		if (pageBrandHelper.existingCampSites!=null && pageBrandHelper.labelCountryMatrix!=null)
		{
			for (CW_Campaign_Sites__c cs : pageBrandHelper.existingCampSites)
			{
				for (WrapperUtil.SelectListWrapper wp : pageBrandHelper.labelCountryMatrix)
				{
					if (cs.Site_Catalogue__r.Label__r.Brand__c != wp.label.Brand__c)
					{
						return true;
						break;
					}
				}
			}
		}
		return false;
	}


	/*** ASSETS PAGE ***/

	public List<List<WrapperUtil.selectWrapper>> assetTypeOptions {get; private set;}
	public Id assetTypeId {get; set;}

	public void initAssetPage()
	{
		List<WrapperUtil.selectWrapper> tempList=new List<WrapperUtil.selectWrapper>();
		assetTypeOptions= new List<List<WrapperUtil.selectWrapper>> ();

		for (WrapperUtil.selectWrapper rec :  WrapperUtil.createWrapperList(
							[select Asset_Type__r.Id, Asset_Type__r.Name from CW_Campaign_Asset_Type__c where Campaign__c = :camp.Id],
							ConstantUtil.CW_CAT_REL_ASSETTYPE,ConstantUtil.SOBJECT_NAME,ConstantUtil.SOBJECT_ID,ConstantUtil.SOBJECT_ID)){
				tempList.Add(rec);
				if(tempList.size()>6){
					assetTypeOptions.Add(tempList);
					tempList=new List<WrapperUtil.selectWrapper>();
				}
			}
			if(tempList.size()>0)
					assetTypeOptions.Add(tempList);
		assetTypeId = Apexpages.currentPage().getParameters().containsKey(ConstantUtil.PAGEPARAM_ASSETTAB)
						? Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_ASSETTAB)
							: (assetTypeOptions.isEmpty() ? null : (Id) assetTypeOptions.get(0).get(0).optionValue);
	}

	public void destroyAssetPage()
	{
		assetTypeOptions = null;
		assetTypeId = null;
	}

	public void emptyAction()
	{

	}

	public pageReference newRewardPage()
	{
		Pagereference nrp = Page.CW_New_Reward;
		nrp.getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		nrp.setRedirect(true);
		return nrp;
	}

	/*** ASSET TYPE SELECTION PAGE ***/

	public List<WrapperUtil.selectListWrapper> campAssetTypeList {get; private set;}

	public void initAssetTypeSelectionPage()
	{
		campAssetTypeList = new List<WrapperUtil.selectListWrapper>();
		// select existing records
		// k: assetType.id v: campaignAssetType
		Map<Id,CW_Campaign_Asset_Type__c> caMap = new Map<Id,CW_Campaign_Asset_Type__c>();
		for(CW_Campaign_Asset_Type__c cat : [select Id, Name, Asset_Type__c, Asset_Type__r.Name
												from CW_Campaign_Asset_Type__c where Campaign__c = :camp.Id])
		{
			caMap.put(cat.Asset_Type__c,cat);
		}

		// select asset types based on site catlogues associated with campaign
		List<CW_Asset_Type__c> assetTypeObjectList =
			CW_WizardAssetUtil.selectAvailableAssetTypes(camp.Id,CW_WizardCampaignAssetUtil.selectSiteCatalogueIds(camp.Id));
		for(CW_Asset_Type__c assetType : assetTypeObjectList)
		{
			WrapperUtil.selectListWrapper slw;
			if(caMap.containsKey(assetType.id))
			{
				slw = new WrapperUtil.selectListWrapper(caMap.get(assetType.id),0);
				slw.selected = true;

			}
			else
			{
				slw = new WrapperUtil.selectListWrapper(new CW_Campaign_Asset_Type__c(Campaign__c = camp.Id),0);
				slw.campAssetType.Asset_Type__r = new CW_Asset_Type__c(id = assetType.id, Name = assetType.Name);
			}
			campAssetTypeList.add(slw);
		}
	}

	public void saveAssetTypeSelectionPage()
	{
		List<CW_Campaign_Asset_Type__c> upsertCAT = new List<CW_Campaign_Asset_Type__c>();
		List<CW_Campaign_Asset_Type__c> deleteCAT = new List<CW_Campaign_Asset_Type__c>();
		for(WrapperUtil.selectListWrapper slw : campAssetTypeList)
		{
			if(slw.selected)
			{
				if(slw.campAssetType.id == null)
				{
					slw.campAssetType.Asset_Type__c = slw.campAssetType.Asset_Type__r.Id;
					slw.campAssetType.Asset_Type__r = null;
				}
				upsertCAT.add(slw.campAssetType);
			}
			else
			{
				if(slw.campAssetType.id != null)
				{
					deleteCAT.add(slw.campAssetType);
				}
			}
		}
		
		upsert upsertCAT;
		delete deleteCAT;
	}

	public void destroyAssetTypeSelectionPage()
	{
		campAssetTypeList = null;
	}

	public Pagereference saveCamp() {

		PageReference pr = new Pagereference('/apex/CW_Audience');

		try	{
			saveCampaign_internal(true);
			if(ApexPages.getMessages().Size()>0){
				//We have some errors
				return null;
			}
			pr.getParameters().put(ConstantUtil.SOBJECT_ID,camp.Id);
			pr.getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
			pr.getParameters().put(ConstantUtil.PAGEPARAM_MODALFLAG,'true');
			pr.getParameters().put(ConstantUtil.PAGEPARAM_TASKTYPE,taskType);
			pr.setRedirect(true);
			return pr;
		}

		catch(Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
	}

	public void RefeschSubComponent() {
		sObjectListIsSaved=true;

	}

	public set<Id> cimAndBiUsers()
	{
		Set<Id> userIds = new Set<Id>();

		List<UserRole> userRoleIds = [SELECT Id from UserRole WHERE Name =: ConstantUtil.CIM_ROLE OR Name =: ConstantUtil.SPORT_BI_ROLE];

		for(User users : [SELECT Id,UserRoleId FROM User WHERE UserRoleId IN :userRoleIds])
    	{
    		userIds.add(users.Id);
    	}

    	return userIds;
	}

	//create attachment
	public Attachment attachment
	{
		get
		{
			if (attachment == null)
				attachment = new Attachment();
			return attachment;
		}
		set;
	}

	//upload file for campaign object from legal information page
	public PageReference uploadFile()
	{
		try
		{
			attachment.OwnerId = UserInfo.getUserId();
			attachment.ParentId = camp.Id; // the record the file is attached to camp obj
			attachment.IsPrivate = true;
  			insert attachment;
  			attachment.Body = null;
  			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
  			closeDialog = true; // modal can be closed on successful save
      	}
      	catch(exception e) {
			ApexPages.addMessages(e);
			closeDialog = false; // modal can not be closed as there was an issue saving the task
		}

      	return null;
	}
	
	//if record is in approval and criteria is not met anymore call recall action
	public void recallBriefApprovalProcess(CW_Campaign__c camp)
    {
    	// set flag as true(this falg is in the approval process criteria) to identify for which approval process the action is recalled
		camp.Brief_Approval__c = true;
		update camp;

		//query the record that is in approval and requires recall action
		List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: camp.Id];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction(ConstantUtil.RECALL_ACTION);
        req.setWorkitemId(piwi.get(0).Id);

        Approval.ProcessResult result = Approval.process(req,false);
		if(result.isSuccess())
		{
			// set flag back to false after record is submitted
			camp.Brief_Approval__c = false;
			//if recall action is succesfull stage gets updated depending on the previous stage
			if (camp.Brief_Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_REJECTED ||
            	camp.Brief_Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL)
    			camp.Stage__c = (camp.Roadmap_Approval_Status__c == ConstantUtil.APPROVAL_PROCESS_APPROVED) ? ConstantUtil.CAMP_STAGE_ROADMAP_APPROVED : ConstantUtil.CAMP_STAGE_DRAFT ;
			//brief status updates not submitted after recall action
			camp.Brief_Approval_Status__c = ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ConstantUtil.MARCOM_BRIEF_RECALL_SUCCESFULLY));
		}
		else
		 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.MARCOM_BRIEF_RECALL_FAILED));
    }
	
	//go to Help Centre page from Audience Group Page
	public PageReference goToHelpCentre()
	{
		PageReference ref = new PageReference('/apex/CW_Help_Centre');
		ref.getParameters().put('id',camp.Id);
    	ref.setRedirect(false);
    	return ref;
	}
	//method to display help text for each page in the wizard
	public String getHelpTextPage()
	{
		if(navigationSettings.get(activePage)!=null)
			return navigationSettings.get(activePage).Page_HelpText__c;
		else
			return null;
	}
}