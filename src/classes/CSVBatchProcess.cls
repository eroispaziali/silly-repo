/**
* File Name :   CSVBatchProcess.cls
* Description : Class processing iported CSV file in batches
*               
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 20/05/2014 Alex PAnka     Initial version
*
*
*/
global with sharing class CSVBatchProcess implements Database.Batchable<sObject>{
	
	global enum ProcesTypes{ CreateAccounts,CreateGroup,ImportRecords}
	global Id CSVImportID;
	global ProcesTypes ProcessID;

	
	global CSVBatchProcess( Id CSVRecId, ProcesTypes ProcType)
	{
		this.CSVImportID=CSVRecId;
		this.ProcessID=ProcType;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		String sSQL='Select isSetGroup__c, isSetCOntact__c, Reward_Library__c, PlayerId__c, IsSetFreeBet__c,Group_Name__c, FreeBetId__c, Currency__c, ';
		sSQL=sSQL +' Contact_ref__c, CSV_Import_Status__c, Audience_Group_ref__c,Amount__c, ';
		sSQL=sSQL +' Audience_Group_ref__r.Is_Control_Group__c,Audience_Group_ref__r.Control_Group__c, ';
		sSQL=sSQL +' Reward_Library__r.FreeBet_Id__c, Reward_Library__r.Currency__c';
		
		sSQL=sSQL +' From CW_CSV_Stage_AudienceMembers__c WHERE CSV_Import_Status__c=\''+CSVImportID+'\' ';
		if(ProcessID==ProcesTypes.CreateAccounts){
			sSQL=sSQL+ ' AND Contact_ref__c=null ';
		}
		if(ProcessID==ProcesTypes.CreateGroup){
			sSQL=sSQL+ ' AND Audience_Group_ref__c=null ';
		}
		if(ProcessID==ProcesTypes.ImportRecords){
			sSQL=sSQL+ 'AND Audience_Group_ref__c<>null AND Contact_ref__c<>null  AND Reward_Library__c<>null ';
		}
      return Database.getQueryLocator(sSQL);
     
   }
   
	 
	global void execute(Database.BatchableContext batchableContext, List<CW_CSV_Stage_AudienceMembers__c> scope) 
	{
		/*CW_AudienceCSVProcessHelper processHelper= new CW_AudienceCSVProcessHelper(CSVImportID);
		
		if(ProcessID==ProcesTypes.CreateAccounts){
			processHelper.processCreateSheildAccounts(scope);
		}
		if(ProcessID==ProcesTypes.CreateGroup){
			processHelper.processCreateAudienceGroups(scope);
		}
		if(ProcessID==ProcesTypes.ImportRecords){
			processHelper.processImportDataToCamp(scope);
		}
		*/
	}
	
	global void finish(Database.BatchableContext batchableContext)
	{
		// currently not used mayby we schold do cleanup a liltle bit
		
	}
}