@isTest
private class CustomSettingUtilTest {
	
/**
* File Name   :    CustomSettingUtilTest.cls
* Description :    Test Class for CustomSettingUtilTest.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 24/04/2014 Chris Yorkston	Initial version
*
*
*/
	
	@isTest static void testCustomSettingUtil() {
		
		// setup data
		CW_CampaignListSetting__c batchRunDateRecord = new CW_CampaignListSetting__c();
		batchRunDateRecord.Name = ConstantUtil.BATCH_RUN_DATE;
		Date d = Date.today();
		batchRunDateRecord.Date_Value__c = d;
		insert batchRunDateRecord;
		
		// assert that method retreives run batch date
		Date runBatchDate = CustomSettingUtil.getRunBatchDate();
		system.assertEquals(d, runBatchDate);
		
		// setup data
		d = d.addDays(5);
		
		// assert
		CustomSettingUtil.updateRunBatchDate(d);
		batchRunDateRecord = CW_CampaignListSetting__c.getInstance(ConstantUtil.BATCH_RUN_DATE);
		
		// assert
		system.assertEquals(d, batchRunDateRecord.Date_Value__c);
	}
	
}