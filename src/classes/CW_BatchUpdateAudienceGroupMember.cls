global class CW_BatchUpdateAudienceGroupMember implements Database.Batchable<sObject>{
/**
* File Name   :    CW_BatchUpdateAudienceGroupMember.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 17/04/2014 Chris Yorkston Initial version
*
*
*/
	
	global final String query;
	
	global CW_BatchUpdateAudienceGroupMember() {
		Date runBatchDate = CustomSettingUtil.getRunBatchDate();	// get run batch date from custom setting
		
		// if run batch date is null, update custom setting with system timestamp
		if (runBatchDate==null) {
			runBatchDate = Date.today();
			CustomSettingUtil.updateRunBatchDate(runBatchDate);
		}
		
		// generate query using run batch date
		Datetime runBatchDateTime = Datetime.newInstance(runBatchDate.year(), runBatchDate.month(), runBatchDate.day());
		query = getQuery( runBatchDateTime.format('YYYY-MM-dd') );
		
	}
     
    global Database.querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<CW_Audience_Group_Member__c> scope){
		List<CW_Audience_Group_Member__c> members = new List<CW_Audience_Group_Member__c>();
 
   		for(CW_Audience_Group_Member__c s : scope){
       		s.Lifetime_NGR__c = s.Contact__r.Lifetime_NGR__c;
       		s.Lifetime_Wager__c = s.Contact__r.Lifetime_Wager__c;
       		members.add(s); 
   		}
 
		update members;
	}
     
	global void finish(Database.BatchableContext BC) {
		// at the end of batch run, update the next run batch date to tomorrow
		CustomSettingUtil.updateRunBatchDate( CustomSettingUtil.getRunBatchDate().addDays(1) );
	}
	
	// get SOQL query will supplied date - retreive KPI's from PersonAccount where supplied date is in an active schedule.
	private String getQuery(String d) {
		
		String query;
		if (d!=null) {
			query = 
		    	'select Id, Contact__r.Lifetime_NGR__c, Contact__r.Lifetime_Wager__c from CW_Audience_Group_Member__c ' 
		    	+' where ' 
		    	+' Audience_Group_Schedule__r.Schedule__r.Evaluation_Start_Date__c <= ' +d+
		    	+' and '
		    	+' Audience_Group_Schedule__r.Schedule__r.Evaluation_End_Date__c >= ' +d
		    ;
		}
		return query;
	}
	
}