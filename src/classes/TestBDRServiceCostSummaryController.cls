@isTest
private class TestBDRServiceCostSummaryController {

/********************************************************************************************* 
 *   @author          gary.grant@conseq.co.uk
 *   @date            Sept 2014
 * 
 *   @description     Test for the Dementia Connect Cost Summary
 *
**********************************************************************************************/


/* The controller extension doesn't do any processing, it just displays data */
static testMethod void TestServiceCostSummaryController()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    BdrWrapper bdrW = new BdrWrapper(bdr);
    Services__c svc1 = bdrW.services.svcWrappers[0].svc;

    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.standardController(svc1);
    BdrServiceCostExtension e = new BdrServiceCostExtension(sc);    

}

}