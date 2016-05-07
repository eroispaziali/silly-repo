/**
* File Name   :    CW_AudienceCSVProcessController.cls
* Description :    Page Contrloer for second step in importing Audience Rewards
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 20/05/2014 Alex Panka	  Intial 
*/

public with sharing class CW_AudienceCSVProcessController {
	public final static Integer BATCH_SIZE=2000;
	public CW_CSV_Import_Status__c impRevStat{get;private set;}
	
	public boolean IsProcessing{get;private set;}
	public ID  batchJobId{get;private set;}
	public integer countTiks{get;set;}
	public AsyncApexJob batchJob {get; private set;}
	private ID CsvStatRecId;
	
	public CW_AudienceCSVProcessController(){
		CsvStatRecId=(ID) Apexpages.currentPage().getParameters().get('ID');
		if(CsvStatRecId!=null){
			impRevStat= [Select Schedule__c, Reward_Catalogue__c, NoRecords__c, NoRecToUpload__c, Name, MissingGroup__c, MissingFreeBet__c, MissingContact__c, Marketing_Campaign__c, Id From CW_CSV_Import_Status__c WHERE ID=:CsvStatRecId ];
		}else{
			//Rise error
		}
		countTiks=0;
		refreshData();
	}
	
	public Boolean getDisableActionPoller()
	{
		return batchJob.Status == ConstantUtil.BATCH_JOB_STATUS_COMPLETED 
				|| batchJob.Status == ConstantUtil.BATCH_JOB_STATUS_ABORTED
				|| batchJob.Status == ConstantUtil.BATCH_JOB_STATUS_FAILED;
	}
	
	
	
	public void refreshData()
	{
		if(batchJobId==null){
			batchJob=new AsyncApexJob();
			IsProcessing=false;
		}else{
			integer lastJobItemsProcessed=0;
			if(batchJob!=null){
				lastJobItemsProcessed=batchJob.JobItemsProcessed;
			}
			List<AsyncApexJob> apxJbsLst=[select id,TotalJobItems,Status,NumberOfErrors,JobItemsProcessed,ExtendedStatus, 
							CreatedDate, CompletedDate	from AsyncApexJob where id = :batchJobId];
			if(apxJbsLst.Size()==0){
				batchJob=new AsyncApexJob();
				batchJobId=null;
				IsProcessing=false;
			}else{
				batchJob=apxJbsLst[0];
				IsProcessing=!getDisableActionPoller();
			}
			if(lastJobItemsProcessed!=batchJob.JobItemsProcessed)
				countTiks=0;//clear 
		}	
		countTiks+=1;
		if(CsvStatRecId!=null){
			impRevStat= [Select Schedule__c, Reward_Catalogue__c, NoRecords__c, NoRecToUpload__c, Name, MissingGroup__c, MissingFreeBet__c, MissingContact__c, Marketing_Campaign__c, Id From CW_CSV_Import_Status__c WHERE ID=:CsvStatRecId ];
		}
		
	}
	
	public void StartProcess(CSVBatchProcess.ProcesTypes ProcessID)
   {
    	 CSVBatchProcess batchProces;
    	 batchProces=new CSVBatchProcess( impRevStat.Id,ProcessID);
    	 batchJobId = Database.executeBatch(batchProces,BATCH_SIZE);
    	 IsProcessing=true;
    	 refreshData();
   }
	
	public String getProgressBarPercent()
	{
		Integer res=1;
		if(batchJob.id != null && batchJob.TotalJobItems > 0 ){
			res=((1.0*countTiks)/batchJob.TotalJobItems).IntValue();
			if( batchJob.JobItemsProcessed > 0)
			{	
				res=res+ (((100.0*batchJob.JobItemsProcessed)/batchJob.TotalJobItems).intValue());
			}
			
		}
		return ''+res;
	}
	
	//Procesiing Methods Create groups ,players, import all correct
	
	public void doCreateGroups(){
		StartProcess(CSVBatchProcess.ProcesTypes.CreateGroup);
	}
	
	public void doCreatePlayers(){
		StartProcess(CSVBatchProcess.ProcesTypes.CreateAccounts);
	}
	
	public void doImportCorrectRecords(){
			StartProcess(CSVBatchProcess.ProcesTypes.ImportRecords);
	}
	
	public void doCleanJob(){
		DELETE impRevStat;
	}
	
	// futher methods for schowing players, gorpps mising freeBets
	
	public PageReference ShowMissingPlayers(){
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Not implemented'));
		return null;	
	}
	
	public PageReference ShowMissingGroups(){
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Not implemented'));
		return null;	
	}
	
	public PageReference ShowMissingFreeBet(){
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Not implemented'));
		return null;	
	}
	

}