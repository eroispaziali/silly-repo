public class CustomSettingUtil {

/**
* File Name   :    CustomSettingUtil.cls
* Description :    
*                  
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 22/04/2014 Chris Yorkston Initial version
*
*
*/

	// update Run Batch Date in custom setting
	public static void updateRunBatchDate(Date d) {
		if (d!=null) {
			CW_CampaignListSetting__c batchRunDateRecord = CW_CampaignListSetting__c.getInstance(ConstantUtil.BATCH_RUN_DATE);
			if (batchRunDateRecord!=null) {
				batchRunDateRecord.Date_Value__c = d;
				update batchRunDateRecord;
			}
		}
	}
	
	// get Run Batch Date from custom setting
	public static Date getRunBatchDate() {
		Date d;
		
		CW_CampaignListSetting__c batchRunDateRecord = CW_CampaignListSetting__c.getInstance(ConstantUtil.BATCH_RUN_DATE);
		if (batchRunDateRecord!=null) d = batchRunDateRecord.Date_Value__c;
		
		return d; 
	}

}