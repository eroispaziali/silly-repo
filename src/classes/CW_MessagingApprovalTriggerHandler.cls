/**
* File Name   :    CW_MessagingApprovalController.cls
* Description :    Page for approving messaging records
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 10/08/2014 Suneetha Jasthi	 B-122329 Messaging dates approval process
*/
public without sharing class CW_MessagingApprovalTriggerHandler{

  	private Boolean m_isExecuting = false;
	private Id campaignId {get; set;}

    public CW_MessagingApprovalTriggerHandler(Boolean isExecuting) {
        m_isExecuting = isExecuting;
    }
	public void OnAfterInsert( CW_Messaging__c[] newObjects, Map<Id,CW_Messaging__c> newObjectMap )
	 {

           updatetMessagingApprovalStatus(newObjects,ConstantUtil.ASSET_TYPE_NAME);
           updatetMessagingApprovalStatus(newObjects,ConstantUtil.TEASER_ASSET_TYPE_NAME);
           updatetMessagingApprovalStatus(newObjects,ConstantUtil.SMS_ASSET_TYPE_NAME);
    }

    public void OnAfterUpdate( CW_Messaging__c[] newObjects, Map<Id,CW_Messaging__c> newObjectMap )
     {

		      updatetMessagingApprovalStatus(newObjects,ConstantUtil.ASSET_TYPE_NAME);
		      updatetMessagingApprovalStatus(newObjects,ConstantUtil.TEASER_ASSET_TYPE_NAME);
		      updatetMessagingApprovalStatus(newObjects,ConstantUtil.SMS_ASSET_TYPE_NAME);
    }

	/* updates the messaging approval status of parent asset with the rollup summary of all messaging records */
     public void updatetMessagingApprovalStatus(CW_Messaging__c[] newObjects,String assetType){
			Integer totalInapprovalRecordCount=0;
			String messagingApprovalSummary='';
			Set<Id> campAssetIds = new Set<Id>();
			Set<Id> tempAssetIds = new Set<Id>();
			Map<Id,List<CW_Messaging__c>>assetsMap = new Map<Id,List<CW_Messaging__c>>();
			Map<Id,String> assetStatusMap = new Map<Id,String>();
			Set<Id> mailAssetTypes=mailerAssetTypes(assetType);

			// fetching campaign_asset_ids from messaging object
			 for(CW_Messaging__c la : newObjects)
		    {
		    	if(mailAssetTypes.contains(la.Campaign_Asset__c))
		      campAssetIds.add(la.Campaign_Asset__c);
		        }

		 	 List<CW_Messaging__c> msgList=new List<CW_Messaging__c>();
		 	 //creating map to store camapign aseet related messaging records..so that it will be easy to update corresponding asset summary field based on child messaging records
		    for(CW_Messaging__c la : [select Campaign__c,Campaign_Asset__c, Approval_Status__c
		                      from CW_Messaging__c
		                    where Campaign_Asset__c in :campAssetIds
		                    order by Campaign_Asset__c])
		    {

		    	if(!tempAssetIds.contains(la.Campaign_Asset__c))
		    	{
			    		msgList=new List<CW_Messaging__c>();
			    		 tempAssetIds.add(la.Campaign_Asset__c);
			    		 msgList.add(la);
			    		 assetsMap.put(la.Campaign_Asset__c,msgList);
		    	}else{
		    			 msgList.add(la);
		    			 assetsMap.put(la.Campaign_Asset__c,msgList);
		    	}
				campaignId=la.Campaign__c;
   			 }

			// Iterating map to calculate rollup summary of child messaging records
			for(Id assetId:assetsMap.keySet())
			{
				Integer  notSubmittedRecordCount=0;
				Integer  inApprovalRecordCount=0;
				Integer  rejectedRecordCount=0;
				Integer approvedRecordCount=0;
			 	messagingApprovalSummary='';
				 msgList=	assetsMap.get(assetId);
				  for(CW_Messaging__c msg : msgList)
			            {
			                if(msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED || msg.Approval_Status__c==''  || msg.Approval_Status__c==null){
			                	notSubmittedRecordCount++;

			                }else if(msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL){
			                	inApprovalRecordCount++;

			                }else if(msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_REJECTED){
			                	rejectedRecordCount++;
			                }else  if(msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_APPROVED || msg.Approval_Status__c==ConstantUtil.APPROVAL_PROCESS_ALL_APPROVED){
	                			approvedRecordCount++;
	               			 }
			           }
		         messagingApprovalSummary=calculateMessagingApprovalSummary( notSubmittedRecordCount, inApprovalRecordCount, rejectedRecordCount, approvedRecordCount);
		         assetStatusMap.put(assetId,messagingApprovalSummary);
		}

			//updating date_approval_summary of CW_Campaign_Asset__c
		   List<CW_Campaign_Asset__c> campAssetList= [select Id,Name,Date_Approval_Summary__c  from CW_Campaign_Asset__c where Id in :campAssetIds];
		    for(CW_Campaign_Asset__c campAsset : campAssetList)
		            {
					campAsset.Date_Approval_Summary__c=assetStatusMap.get(campAsset.Id).trim();
					if(assetStatusMap.get(campAsset.Id).trim()==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL){
						totalInapprovalRecordCount++;
					}
		    		}
		    update campAssetList;
			if(totalInapprovalRecordCount==0)
			{
				updateCampaignMailerMessagingApprovalSummary(assetType,mailAssetTypes);
			}

    }



    /* calculates the final approval status based on different status counts */
  private String calculateMessagingApprovalSummary(Integer notSubmittedRecordCount,Integer inApprovalRecordCount,Integer rejectedRecordCount,Integer approvedRecordCount)
  {
    	  if(rejectedRecordCount>0){
 				 return  ConstantUtil.APPROVAL_PROCESS_SOME_REJECTED;
           }else if(inApprovalRecordCount>0){
           		return  ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
           }else if(notSubmittedRecordCount>0){
          		return 	 ConstantUtil.APPROVAL_PROCESS_NEEDS_SUBMISSION;
           }else if(approvedRecordCount>0){
          		return  ConstantUtil.APPROVAL_PROCESS_ALL_APPROVED;
           }else {
           		return '';
           }
    }

	/* updates the Mailer messaging approval status on Campaign object */
	public void  updateCampaignMailerMessagingApprovalSummary(String assetType,Set<Id> mailerAssetTypes)
	{
		String messagingApprovalSummary='';
		Integer  notSubmittedRecordCount=0;
		Integer  inApprovalRecordCount=0;
		Integer  rejectedRecordCount=0;
		Integer approvedRecordCount=0;
		  List<CW_Campaign_Asset__c> campAssetList= [select Id,Name,Date_Approval_Summary__c  from CW_Campaign_Asset__c where Campaign__c=:campaignId and Id in :mailerAssetTypes];
	      for(CW_Campaign_Asset__c campAsset : campAssetList)
	            {
	            	if(campAsset.Date_Approval_Summary__c==ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED || campAsset.Date_Approval_Summary__c==ConstantUtil.APPROVAL_PROCESS_NEEDS_SUBMISSION || campAsset.Date_Approval_Summary__c=='' || campAsset.Date_Approval_Summary__c==null){
	                	notSubmittedRecordCount++;

	                }else if(campAsset.Date_Approval_Summary__c==ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL){
	                	inApprovalRecordCount++;
	                }else if(campAsset.Date_Approval_Summary__c==ConstantUtil.APPROVAL_PROCESS_REJECTED || campAsset.Date_Approval_Summary__c==ConstantUtil.APPROVAL_PROCESS_SOME_REJECTED){
	                	rejectedRecordCount++;
	                }else  if(campAsset.Date_Approval_Summary__c==ConstantUtil.APPROVAL_PROCESS_APPROVED || campAsset.Date_Approval_Summary__c==ConstantUtil.APPROVAL_PROCESS_ALL_APPROVED){
	                	approvedRecordCount++;
	                }
	    }
	       messagingApprovalSummary=calculateMessagingApprovalSummary(notSubmittedRecordCount, inApprovalRecordCount, rejectedRecordCount, approvedRecordCount);

	      List<CW_Campaign__c> camptList= [select Id,Name,Mailer_Messaging_Approval_Status__c,Teaser_Messaging_Approval_Status__c,SMS_Messaging_Approval_Status__c  from CW_Campaign__c where Id  =:campaignId];
	      for(CW_Campaign__c camp : camptList)
	            {
				if(assetType==ConstantUtil.ASSET_TYPE_NAME)
					camp.Mailer_Messaging_Approval_Status__c=messagingApprovalSummary;
				else if(assetType==ConstantUtil.TEASER_ASSET_TYPE_NAME)
					camp.Teaser_Messaging_Approval_Status__c=messagingApprovalSummary;
				else if(assetType==ConstantUtil.SMS_ASSET_TYPE_NAME)
					camp.SMS_Messaging_Approval_Status__c=messagingApprovalSummary;

	    	update camptList;

		}
	}

		/* fetch the mailet asset types  */
		 private Set<Id> mailerAssetTypes(String assetType)
 	 {
 	 	Set<Id> campAssetIdList=new Set<Id>();
  		List<CW_Asset_Type__c> asset=[select Name from CW_Asset_Type__c where  name=:assetType];
		if(asset!=null && asset.size()>0){
				 List<CW_Campaign_Asset__c> asst = [select Id from CW_Campaign_Asset__c where Asset__r.Asset_Type__c in :asset];
				for(CW_Campaign_Asset__c campAsset : asst)
		            {
		            campAssetIdList.add(campAsset.Id);
		            }
			}
			return campAssetIdList;
	  }
    }