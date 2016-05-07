/**
* File Name   :    CW_MessagingApprovalController.cls
* Description :    Page for approving messaging records
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 04/08/2014 Suneetha Jasthi	 B-122329 Messaging dates approval process
*/
public with sharing class CW_MessagingApprovalController 
{

	public Boolean canSeeApproveButton{get;set;}
	public Id 				campaignId {get;set;}
	public Boolean isSubmittedForMessagingApproval{get; set;}
	public List<Schema.FieldSetMember> msgFields {get; set;}
	public List<Schema.FieldSetMember> assetMsgFields {get; set;}
	public List<Schema.FieldSetMember> appmsgFields {get; set;}
	public Map<String,List<CW_Messaging__c>>assetsMapNew{get; set;}
	public Map<String,Map<String,List<CW_Messaging__c>>>assetTypeMap{get; set;}
	public Map<String,String>assetApprovalStatusMap{get; set;}
	public Map<Id,String>assetIdNameMap{get; set;}
	public Map<Id,CW_Messaging__c>currentAssetsMap{get; set;}
	public List<CW_Campaign__c> appmsgList {get; set;}
 	public List<List<WrapperUtil.selectWrapper>> assetTypeOptions {get; private set;}
	public Id assetTypeId {get; set;}
	public String mailerMessagingApprovalStatus{get;set;}
	public String teaserMessagingApprovalStatus{get;set;}
	public String smsMessagingApprovalStatus{get;set;}


	public CW_MessagingApprovalController()
	{
		campaignId = ApexPages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_ID);

      	if (campaignId!=null)
      	{
      		initAssets();
      		assetTypeMap = new Map<String,Map<String,List<CW_Messaging__c>>>();
      		assetsMapNew=new Map<String,List<CW_Messaging__c>>();
      		assetIdNameMap=new Map<Id,String>();
      		currentAssetsMap=new Map<Id,CW_Messaging__c>();
      		assetApprovalStatusMap=new Map<String,String>();
      		mailerMessagingApprovalStatus='';
		 	teaserMessagingApprovalStatus='';
		 	smsMessagingApprovalStatus='';
			messagingApprovalSummary();
			List<String> submittedForApprovalAssetsList=getAssetTypeList();
			for(String assetType:submittedForApprovalAssetsList){
				initMessaging(assetType);
			}
		}
	}
	
	public void initNew()
	{
		String assetTypeName = [select Name from CW_Asset_Type__c where id = :assetTypeId].Name;
		checkCampaignIsSubmittedForApproval(assetTypeName);
		canLogInUserCanApprove(assetTypeName);
	}
	
	/* fetches required asset types for approval */
	public void initAssets()
	{
		List<WrapperUtil.selectWrapper> tempList=new List<WrapperUtil.selectWrapper>();
        assetTypeOptions= new List<List<WrapperUtil.selectWrapper>> ();

	    for (WrapperUtil.selectWrapper rec :  WrapperUtil.createWrapperList(
        	[select Asset_Type__r.Id, Asset_Type__r.Name from CW_Campaign_Asset_Type__c where Campaign__c = :campaignId and Asset_Type__r.Name in :getAssetTypeList()],
            ConstantUtil.CW_CAT_REL_ASSETTYPE,ConstantUtil.SOBJECT_NAME,ConstantUtil.SOBJECT_ID,ConstantUtil.SOBJECT_ID))
        {
      		tempList.Add(rec);
      		if(tempList.size()>6)
      		{
	            assetTypeOptions.Add(tempList);
	            tempList=new List<WrapperUtil.selectWrapper>();
        	}
        }
        if(tempList.size()>0) assetTypeOptions.Add(tempList);
	}

	/* fetchs summary status fields from Messaging & Campaign */
 	public void messagingApprovalSummary()
 	{
		List<CW_Campaign__c> campList=[SELECT Id,Name,Mailer_Messaging_Approval_Status__c,Teaser_Messaging_Approval_Status__c,SMS_Messaging_Approval_Status__c,Messaging_Approval_Status__c from CW_Campaign__c where Id=:campaignId ];
	    for(CW_Campaign__c camp : campList)
	    {
			 mailerMessagingApprovalStatus=camp.Mailer_Messaging_Approval_Status__c;
			 teaserMessagingApprovalStatus=camp.Teaser_Messaging_Approval_Status__c;
			 smsMessagingApprovalStatus=camp.SMS_Messaging_Approval_Status__c;
	    }
	}

	public Boolean getMessagingAvailable()
	{
		return msgFields != null && !msgFields.isEmpty();
	}

	/* fetches and related messaging records of passed asset type  */
	public void initMessaging(String assetTypeName)
	{
		Set<String> campAssetIds = new Set<String>();
		Set<String> tempAssetIds = new Set<String>();
		Map<String,List<CW_Messaging__c>> assetsMap = new Map<String,List<CW_Messaging__c>>();

		try
		{
			Schema.Describesobjectresult dor = Schema.sObjectType.CW_Messaging__c;
			if(msgFields == null)
			{
				Map<String,Schema.FieldSet> fieldSetMap = dor.FieldSets.getMap();
				String fieldSetName=assetTypeName+ConstantUtil.UNDERSCORE_APPROVAL;
				msgFields = FieldSetUtil.getFieldSet(fieldSetMap, fieldSetName);
			}

			Set<Id> assetIds=mailerAssetTypes(assetTypeName);

			List<CW_Messaging__c> msgLisNewt=[select Campaign__c,Campaign_Asset__c, Approval_Status__c,Dispatch_Date__c,
													 Name,Id,Old_dispatch_date__c,Live_Date__c,Old_live_date__c,End_Date__c,
													 Old_end_date__c
		                      				  from CW_Messaging__c
		                       				  where Campaign__c=:campaignId  
		                       				  and Approval_Status__c!=:ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED 
		                       				  order by Campaign_Asset__c];

			// to keep the current record values
			for(CW_Messaging__c la : msgLisNewt)
			{
				if(assetIds.contains(la.Campaign_Asset__c))
				{
		      		campAssetIds.add(la.Campaign_Asset__c);
		      		currentAssetsMap.put(la.Id,la);
		    	}
			}

		    //get date_approval_status & assettypename from Campaign_ASSET__c
			// to keep asset Id & Name as key value pair
		    for(CW_Campaign_Asset__c asset :[select Campaign__c,Date_Approval_Summary__c,Name,Id
		                      				 from CW_Campaign_Asset__c
		    								 where Campaign__c=:campaignId 
		    								 and Id in :campAssetIds 
		    								 order by Name])
		    {
	        	assetApprovalStatusMap.put(asset.Id,asset.Date_Approval_Summary__c);
				assetIdNameMap.put(asset.Id,asset.Name);
		    }

			//creating map with campaign_asset Id & related messaging records
			List<CW_Messaging__c>  tempmsgList=new List<CW_Messaging__c>();

			List<CW_Messaging__c> msgTempList= [select Campaign__c,Campaign_Asset__c, Approval_Status__c,Name,Dispatch_Date__c,
														Id,Old_dispatch_date__c,Live_Date__c,Old_live_date__c,End_Date__c,
														Old_end_date__c
			                      				from CW_Messaging__c
			                    				where Campaign_Asset__c in :campAssetIds 
			                    				and  Approval_Status__c!=:ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED
			                    				order by Campaign_Asset__c];
			for(CW_Messaging__c la :msgTempList)
			{
				if(!tempAssetIds.contains(la.Campaign_Asset__c))
				{
			   		tempmsgList=new List<CW_Messaging__c>();
			    	tempAssetIds.add(la.Campaign_Asset__c);
			    	tempmsgList.add(la);
			    	assetsMap.put(la.Campaign_Asset__c,tempmsgList);
			    }
			    else
			    {
	    			 tempmsgList.add(la);
	    			 assetsMap.put(la.Campaign_Asset__c,tempmsgList);
			    }
			}

			//TO display status fields from campaign object
		 	dor = Schema.sObjectType.CW_Campaign__c;
			if(appmsgFields == null)
			{
				Map<String,Schema.FieldSet> fieldSetMap = dor.FieldSets.getMap();
				String fieldSetName=assetTypeName+' Approval';
				appmsgFields = FieldSetUtil.getFieldSet(fieldSetMap, fieldSetName);
			}
			if(!appmsgFields.isEmpty())
			{
					appmsgList = FieldSetUtil.queryViaFieldSet(appmsgFields,
														Schema.sObjectType.CW_Campaign__c.Name,	'Id = \''+campaignId+'\'');
			}
			assetTypeMap.put(assetTypeName,assetsMap);
			checkCampaignIsSubmittedForApproval(assetTypeName);
		}
		catch(exception e){
				ApexPages.addMessages(e);
		}
	}
	
	/* checks whether campaign is submitted for particular asset type  */
	private void checkCampaignIsSubmittedForApproval(String assetType)
	{
		isSubmittedForMessagingApproval=false;

		List<CW_Campaign__c> camptList= [select Id,Name,Is_submitted_for_messaging_approval__c,Is_Submitted_for_Teaser_Approval__c ,Is_Submitted_for_SMS_Approval__c from CW_Campaign__c where Id  =:campaignId];
		for(CW_Campaign__c camp : camptList)
		{
	    	if(assetType==ConstantUtil.ASSET_TYPE_NAME)
					isSubmittedForMessagingApproval=camp.Is_submitted_for_messaging_approval__c;
			else if(assetType==ConstantUtil.TEASER_ASSET_TYPE_NAME)
							isSubmittedForMessagingApproval=camp.Is_Submitted_for_Teaser_Approval__c;
			else if (assetType==ConstantUtil.SMS_ASSET_TYPE_NAME)
						isSubmittedForMessagingApproval=camp.Is_Submitted_for_SMS_Approval__c;
		 }
	}
	
	/* decide who can approve & can edit messaging records of specific asset type  */
    public void canLogInUserCanApprove(String assetTypeName)
	{
		try
		{
			String fieldName='';
			canSeeApproveButton=false;
			if(assetTypeName==ConstantUtil.ASSET_TYPE_NAME)
					fieldName=ConstantUtil.MAILER_APPROVER_QUEUE_NAME;
			else if(assetTypeName==ConstantUtil.TEASER_ASSET_TYPE_NAME)
						fieldName=ConstantUtil.TEASER_APPROVER_QUEUE_NAME;
			else if (assetTypeName==ConstantUtil.SMS_ASSET_TYPE_NAME)
						fieldName=ConstantUtil.SMS_APPROVER_QUEUE_NAME;
			Group mailerApprovalGroup=GroupUtil.getQueue(fieldName);
			List<GroupMember> memeberList=[SELECT Id FROM GroupMember WHERE  UserOrGroupId=:Userinfo.getUserId() and GroupId=:mailerApprovalGroup.Id];
			if(memeberList!=null && memeberList.size()>0){
					canSeeApproveButton=true;
			}else{
					canSeeApproveButton= false;
			}
		}
		catch(exception e)
		{
			canSeeApproveButton= false;
		}
	}
	
	/* Changes the approval status of all Campain asset & Campaign based on approver selection */
	public void approveMessaging()
	{
		try
		{
			String assetType = [select Name from CW_Asset_Type__c where id = :assetTypeId].Name;
			//get current

			List<CW_Messaging__c> updatedList=new List<CW_Messaging__c>();
			assetsMapNew=assetTypeMap.get(assetType);
			for(String asset:assetsMapNew.keySet())
			{
				for(CW_Messaging__c msg:assetsMapNew.get(asset))
				{
					CW_Messaging__c currentMsg=currentAssetsMap.get(msg.Id); //getting curent record
					//If dispatch date is changed by approver we need to keep that previous value in old dispatch date
					if(assetType==ConstantUtil.ASSET_TYPE_NAME || assetType==ConstantUtil.SMS_ASSET_TYPE_NAME)
					{
						String errorMsg='';
						if(msg.Dispatch_Date__c==null){
							errorMsg='Dispatch Date is a Required field';
						}
						if(String.isNotBlank(errorMsg))
						{
							Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));
							return;
						}
	
						if(currentMsg.Dispatch_Date__c!=msg.Dispatch_Date__c)
						{
							//converting date to string to assign it to old dispatch date
							Datetime dispatchDate = Datetime.newInstance(currentMsg.Dispatch_Date__c.year(), currentMsg.Dispatch_Date__c.month(), currentMsg.Dispatch_Date__c.day());
							String dtString= dispatchDate.format('dd/MM/yyyy') ;
							msg.Old_dispatch_date__c=dtString;
						}
					}
					else if(assetType==ConstantUtil.TEASER_ASSET_TYPE_NAME)
					{
						String errorMsg='';
						if(msg.Live_Date__c==null)
							errorMsg+='Live Date is a Required field';
						if(msg.End_Date__c==null)
							errorMsg+='End Date is a Required field';
						if(String.isNotBlank(errorMsg))
						{
							Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));
							return;
						}

						if(currentMsg.Live_Date__c!=msg.Live_Date__c)
						{
							//converting date to string to assign it to old dispatch date
							Datetime liveDate = Datetime.newInstance(currentMsg.Live_Date__c.year(), currentMsg.Live_Date__c.month(), currentMsg.Live_Date__c.day());
							String dtString= liveDate.format('dd/MM/yyyy') ;
							msg.Old_live_date__c=dtString;
						}
						if(currentMsg.End_Date__c!=msg.End_Date__c)
						{
							//converting date to string to assign it to old dispatch date
							Datetime endDate = Datetime.newInstance(currentMsg.End_Date__c.year(), currentMsg.End_Date__c.month(), currentMsg.End_Date__c.day());
							String dtString= endDate.format('dd/MM/yyyy') ;
							msg.Old_end_date__c=dtString;
						}
					}

					//changing status of all In approval ststus fields to Approved
					if(msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL){
						msg.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_APPROVED;
					}
					updatedList.add(msg);
				}
			}
			
			update updatedList;
			List<CW_Campaign__c> camptList= [select Id,Name,Messaging_Approval_Status__c,Is_submitted_for_messaging_approval__c,Is_Submitted_for_Teaser_Approval__c,Is_Submitted_for_SMS_Approval__c  from CW_Campaign__c where Id  =:campaignId];
		    for(CW_Campaign__c camp : camptList)
		    {
				camp.Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_APPROVED;
				if(assetType==ConstantUtil.ASSET_TYPE_NAME)
					camp.Is_submitted_for_messaging_approval__c=false;
				else if(assetType==ConstantUtil.TEASER_ASSET_TYPE_NAME)
							camp.Is_Submitted_for_Teaser_Approval__c=false;
				else if(assetType==ConstantUtil.SMS_ASSET_TYPE_NAME)
							camp.Is_Submitted_for_SMS_Approval__c=false;
		    }
			update camptList;

			 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Records approved successfully'));

		}catch(exception e){
			 ApexPages.addMessages(e);
		}
	}
	
	/* Changes the approval status of all Campain asset & Campaign based on approver selection */
	public void rejectMessaging()
	{
		try
		{
			String assetType = [select Name from CW_Asset_Type__c where id = :assetTypeId].Name;

			List<CW_Messaging__c> updatedList=new List<CW_Messaging__c>();
			assetsMapNew=assetTypeMap.get(assetType);
			for(String asset:assetsMapNew.keySet())
			{
				for(CW_Messaging__c msg:assetsMapNew.get(asset))
				{
					CW_Messaging__c currentMsg=currentAssetsMap.get(msg.Id); //getting curent record
					//keeping old date value if that is changed by approver
					if(assetType==ConstantUtil.ASSET_TYPE_NAME || assetType==ConstantUtil.SMS_ASSET_TYPE_NAME){
					String errorMsg='';
					if(msg.Dispatch_Date__c==null)
					{
						errorMsg='Dispatch Date is a Required field';
						if(String.isNotBlank(errorMsg))
						{
							Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));
							return;
						}
					}
					if(currentMsg.Dispatch_Date__c!=msg.Dispatch_Date__c)
					{
						//converting date to string to assign it to old dispatch date
						Datetime dispatchDate = Datetime.newInstance(currentMsg.Dispatch_Date__c.year(), currentMsg.Dispatch_Date__c.month(), currentMsg.Dispatch_Date__c.day());
						String dtString= dispatchDate.format('dd/MM/yyyy') ;
						msg.Old_dispatch_date__c=dtString;
					}
				}
				else if(assetType==ConstantUtil.TEASER_ASSET_TYPE_NAME)
				{
					String errorMsg='';
					if(msg.Live_Date__c==null)
						errorMsg+='Live Date is a Required field';
					if(msg.End_Date__c==null)
						errorMsg+='End Date is a Required field';
					if(String.isNotBlank(errorMsg))
						{
							Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));
							return;
						}
					if(currentMsg.Live_Date__c!=msg.Live_Date__c)
					{
						//converting date to string to assign it to old dispatch date
						Datetime liveDate = Datetime.newInstance(currentMsg.Live_Date__c.year(), currentMsg.Live_Date__c.month(), currentMsg.Live_Date__c.day());
						String dtString= liveDate.format('dd/MM/yyyy') ;
						msg.Old_live_date__c=dtString;
					}
					if(currentMsg.End_Date__c!=msg.End_Date__c)
					{
						//converting date to string to assign it to old dispatch date
						Datetime endDate = Datetime.newInstance(currentMsg.End_Date__c.year(), currentMsg.End_Date__c.month(), currentMsg.End_Date__c.day());
						String dtString= endDate.format('dd/MM/yyyy') ;
						msg.Old_end_date__c=dtString;
					}
				}
				if(msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_APPROVED){
						msg.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_APPROVED;
				}else{
						msg.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_REJECTED;
				}
				updatedList.add(msg);
			}
		}
		update updatedList;

		List<CW_Campaign__c> camptList= [select Id,Name,Messaging_Approval_Status__c,Is_submitted_for_messaging_approval__c,Is_Submitted_for_Teaser_Approval__c,Is_Submitted_for_SMS_Approval__c  from CW_Campaign__c where Id  =:campaignId];
	   	for(CW_Campaign__c camp : camptList)
	    {
			camp.Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_REJECTED;
			if(assetType==ConstantUtil.ASSET_TYPE_NAME)
					camp.Is_submitted_for_messaging_approval__c=false;
			else if(assetType==ConstantUtil.TEASER_ASSET_TYPE_NAME)
							camp.Is_Submitted_for_Teaser_Approval__c=false;
			else if(assetType==ConstantUtil.SMS_ASSET_TYPE_NAME)
							camp.Is_Submitted_for_SMS_Approval__c=false;
   		}
		update camptList;
		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Records rejected successfully'));
		}catch(exception e){
			 ApexPages.addMessages(e);
		}
	}

	/* returns Campaign assets Ids related to passed asset type */
	private Set<Id> mailerAssetTypes(String assetType)
 	{
 	 	Set<Id> campAssetIdList=new Set<Id>();
  		List<CW_Asset_Type__c> asset=[select Id from CW_Asset_Type__c where  name=:assetType];
		if(asset!=null && asset.size()>0)
		{
			List<CW_Campaign_Asset__c> asst = [select Id from CW_Campaign_Asset__c where Asset__r.Asset_Type__c in :asset];
			for(CW_Campaign_Asset__c campAsset : asst)
            {
            campAssetIdList.add(campAsset.Id);
            }
		}
		return campAssetIdList;
	}
	
	/* checks any messaging records are in approval */
	public Boolean  getAssetTypeMessagingAvailable(String assetTypeName)
	{
		Boolean tempmessagingAvailable=false;
		List<CW_Asset_Type__c> asset=[select Name from CW_Asset_Type__c where  name =:assetTypeName];
		if(asset!=null && asset.size()>0)
		{
			List<CW_Campaign_Asset__c> asst = [select Id from CW_Campaign_Asset__c where Asset__r.Asset_Type__c in :asset];
			if(asst!=null && asst.size()>0)
			{
				List<CW_Messaging__c> listNew= [SELECT Id,Name, Campaign__c	  FROM CW_Messaging__c  WHERE Campaign__c =:  campaignId and Campaign_Asset__c in :asst and Approval_Status__c!=:ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED];
				 tempmessagingAvailable= listNew != null && listNew.size()>0;
			}
		}
		return tempmessagingAvailable;
	}
	
	/* return the asset types required for messaging approval */
	public  List<String> getAssetTypeList()
    {
    	List<String> assetTypeList=new List<String>();
    	if(getAssetTypeMessagingAvailable(ConstantUtil.ASSET_TYPE_NAME))
    			assetTypeList.add(ConstantUtil.ASSET_TYPE_NAME);
    	if(getAssetTypeMessagingAvailable(ConstantUtil.SMS_ASSET_TYPE_NAME))
    			assetTypeList.add(ConstantUtil.SMS_ASSET_TYPE_NAME);
    	if(getAssetTypeMessagingAvailable(ConstantUtil.TEASER_ASSET_TYPE_NAME))
    			assetTypeList.add(ConstantUtil.TEASER_ASSET_TYPE_NAME);
		return assetTypeList;
    }

}