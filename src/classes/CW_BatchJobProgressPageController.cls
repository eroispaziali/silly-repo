/**
* File Name   :    CW_BatchJobProgressPageController.cls
* Description :    B-110984
*                  show progress of CSV upload
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 09/04/2014 Klea Kolaric	  Initial version
* 0.2 20/05/2015 Alex Panka     Adding Next page 
*
*/
public with sharing class CW_BatchJobProgressPageController {
	
	public AsyncApexJob batchJob {get; private set;}
	
	public Boolean isForwardToPage{
		get{
			if(ForwardToPage==null)return false;
			if(ForwardToPage.Trim()=='')return false;
			return true;
		}
	}
	public string ForwardToPage{get;set;}
	
	public CW_BatchJobProgressPageController()
	{
		
		Id batchJobId = (Id) Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_BATCHJOBID);
		
		ForwardToPage =Apexpages.currentPage().getParameters().get('retUrl');
		if(isForwardToPage){
			ForwardToPage=Encodingutil.urlDecode(ForwardToPage,'utf-8');
		}
		batchJob = new AsyncApexJob();	// avoid null exception
		if(String.isNotBlank(batchJobId))
		{
			batchJob = selectBatchJob(batchJobId);
		}
	}
	
	public void refreshData()
	{
		batchJob = selectBatchJob(batchJob.Id);
	}
	
	public Boolean getDisableActionPoller()
	{
		return batchJob.Status == ConstantUtil.BATCH_JOB_STATUS_COMPLETED 
				|| batchJob.Status == ConstantUtil.BATCH_JOB_STATUS_ABORTED
				|| batchJob.Status == ConstantUtil.BATCH_JOB_STATUS_FAILED;
	}
	
	public Boolean getIsCompleted()
	{
		return batchJob.Status == ConstantUtil.BATCH_JOB_STATUS_COMPLETED && batchJob.NumberOfErrors==0;
	}
	
	public Boolean getIsFailed()
	{
		return  batchJob.NumberOfErrors>0;
	}
	
	public String getProgressBarPercent()
	{
		if(batchJob.id != null && batchJob.TotalJobItems > 0 && batchJob.JobItemsProcessed > 0)
		{
			return '' + ((((1.0*batchJob.JobItemsProcessed)/batchJob.TotalJobItems)*100).intValue());
		}
		return '1';
	}
	
	
	public static AsyncApexJob selectBatchJob(Id batchJobId)
	{
		return [select id,
				TotalJobItems,
				Status,
				NumberOfErrors, 
				JobItemsProcessed, 
				ExtendedStatus, 
				CreatedDate, 
				CompletedDate
				from AsyncApexJob where id = :batchJobId];
	}
	
	public Pagereference goToNextPage(){
		return new Pagereference(ForwardToPage );
	}

}