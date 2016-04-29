/**
* File Name   :    CW_BatchJobProgressPageControllerTest.cls
* Description :    B-110984
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 10/04/2014 Klea Kolaric	Initial version
*
*
*/
@isTest
private class CW_BatchJobProgressPageControllerTest {

    static testMethod void basicTest()
    {
    	CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
        // kick off batch
        CSVBatchReader batchJobClass = new CSVBatchReader(stringCSV,camp.id,sch.Id);
        Id batchJobId = Database.executeBatch(batchJobClass);
        
        Test.setCurrentPage(Page.CW_BatchJobProgressPage);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_BATCHJOBID,batchJobId);
		
        Test.startTest();
        CW_BatchJobProgressPageController bjppc = new CW_BatchJobProgressPageController();
        bjppc.getDisableActionPoller();
        bjppc.refreshData();
        bjppc.getProgressBarPercent();
        //bjppc.returnToAudiencePage();
        Test.stopTest();
    }
    
    static testMethod void emptyTest()
    {
    	CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
        Test.setCurrentPage(Page.CW_BatchJobProgressPage);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
        Test.startTest();
        CW_BatchJobProgressPageController bjppc = new CW_BatchJobProgressPageController();
        bjppc.getProgressBarPercent();
        Test.stopTest();
    }
    
    private static String stringCSV = 'Group Name,Account Name'+CSVReader.lineTerminator+'My Group,111111';
}