public with sharing class CW_AdminController {
/**
* File Name   :    CW_AdminController.cls
* Description :    Apex Controller class for CW_Admin.page
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 17/04/2014 Chris Yorkston Initial version
* 0.2 14/05/2014 AleX Panka     Adding Uniqa groups
*
*
*/


	private List<CronTrigger> allCronJobs;

	public Id batchId {get; set;}
	public Boolean hasCronJob {
		get {
			return getCronJobs().Size()>0;
		}
		set;
	}

	public List<CronTrigger> getCronJobs(){
		List<CronTrigger> resLst= new List<CronTrigger>();
		for(CronTrigger rec: allCronJobs){
			if(rec.CronJobDetail.Name.StartsWith(ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_MEMBER))
				resLst.Add(rec);
		}
		return resLst;
	}


//Uniqa gruop Members params
	public String CntrGrpSuffix{get;set;}
	public String TrgtGrpSuffix{get;set;}
	public String batchIdUniqa{get;set;}
	public Boolean getHasUniqaCronJob() {
		return getUniqacronJobs().Size()>0;
	}
	public List<CronTrigger> getUniqacronJobs(){
		List<CronTrigger> resLst= new List<CronTrigger>();
		for(CronTrigger rec: allCronJobs){
			if(rec.CronJobDetail.Name.StartsWith(ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_RELATION))
				resLst.Add(rec);
		}
		return resLst;
	}

   public Date dateCustomSetting {get;set;}

	public CW_AdminController() {
	    ReloadCronJobs();
	    dateCustomSetting = CustomSettingUtil.getRunBatchDate();
        CntrGrpSuffix=CW_CampaignListSettingHelper.TextValue(ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_NAME,ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_VALUE);
        TrgtGrpSuffix=CW_CampaignListSettingHelper.TextValue(ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_NAME , ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_VALUE);

	}

	public Pagereference updateAudienceGroupMembers() {

		Id batchInstanceId = Database.executeBatch(new CW_BatchUpdateAudienceGroupMember(), 2000);
		batchId = batchInstanceId;

		return null;
	}

	public Pagereference addScheduledJobToUpdateAudienceGroupMembers() {

		// Instantiate the batch class
		CW_BatchUpdateAudienceGroupMember myBatch = new CW_BatchUpdateAudienceGroupMember();

		// Instantiate the scheduler
		BatchScheduler scheduler = new BatchScheduler();

		// Assign the batch class to the variable within the scheduler
		scheduler.batchClass = myBatch;

		// Get Schedule string - run every day at 1am (01:00)
		String sch = ConstantUtil.BATCH_APEX_SCHEDULE_UPDATE_AUDIENCE_GROUP_MEMBER;

 		// schedule batch apex job
		System.schedule(ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_MEMBER+' - Everyday at 1pm', sch, scheduler);

		// query cron jobs
		ReloadCronJobs();
		return null;
	}

	public Pagereference removeScheduledJobToUpdateAudienceGroupMembers() {

		// delete scheduled job
		for (CronTrigger jobs :getCronJobs()) {
			System.abortJob(jobs.Id);
		}

		// query cron jobs
		ReloadCronJobs();
		return null;
	}

	public void  ReloadCronJobs() {
		allCronJobs= [select Id, CronJobDetailId, CronJobDetail.Name 	from CronTrigger
			 where CronJobDetail.Name LIKE :ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_MEMBER+'%' OR
			 		 CronJobDetail.Name LIKE :ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_RELATION+'%'
	    ];
	    //Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,'Jobs Load size:'+allCronJobs.size()));
	    //Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,'Groups size:'+getCronJobs().size()));
	    //Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,'Uniqa size:'+getUniqacronJobs().size()));

	}


	public Pagereference removeScheduledJobToUpdateAudienceGroupRelation() {

		// delete scheduled job
		for (CronTrigger jobs :getUniqaCronJobs()) {
			System.abortJob(jobs.Id);
		}

		// query cron jobs
		ReloadCronJobs();
		return null;
	}

	private CW_BatchAudienceGroupRelationAssign craeteAudienceGroupRelationBatch(){

		if (CntrGrpSuffix!=null && CntrGrpSuffix.Trim()=='')
			CntrGrpSuffix=null;
		if (TrgtGrpSuffix!=null && 	TrgtGrpSuffix.Trim()=='')
			TrgtGrpSuffix=null;
        CW_CampaignListSettingHelper.SetTextValue(ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_NAME,ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_VALUE);
        CW_CampaignListSettingHelper.SetTextValue(ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_NAME , ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_VALUE);
		return new CW_BatchAudienceGroupRelationAssign(CntrGrpSuffix,TrgtGrpSuffix);
	}

	public Pagereference addScheduledJobToUpdateAudienceGroupRelation() {

		CW_BatchAudienceGroupRelationAssign myBatch =  craeteAudienceGroupRelationBatch();

		// Instantiate the scheduler
		BatchScheduler scheduler = new BatchScheduler();

		// Assign the batch class to the variable within the scheduler
		scheduler.batchClass = myBatch;

		// Get Schedule string - run every day at 1am (01:00)
		String sch = ConstantUtil.BATCH_APEX_SCHEDULE_UPDATE_AUDIENCE_GROUP_MEMBER;

 		// schedule batch apex job
		System.schedule(ConstantUtil.BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_RELATION+' - Everyday at 1pm', sch, scheduler);

		// query cron jobs
		ReloadCronJobs();
		return null;
	}

	public Pagereference updateAudienceGroupReference() {

		Id batchInstanceId = Database.executeBatch(craeteAudienceGroupRelationBatch(), 2000);
		batchIdUniqa = batchInstanceId;

		return null;
	}
}