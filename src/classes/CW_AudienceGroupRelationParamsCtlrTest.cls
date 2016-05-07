/**
* File Name   :    CW_AudienceGroupRelationParamsCtlrTest.cls
* Description :    B-122759 - Process Naming Convention
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 10/07/2014 Amar Reddy     Initial version
*
*
*/

@IsTest
public with sharing class CW_AudienceGroupRelationParamsCtlrTest {

    static testMethod void testStartBatch()
    {
        List<CW_Audience_Group__c> audienceGroupRecords= new List<CW_Audience_Group__c>();
        List<CW_Campaign__c> campaignRecords = TestDataUtil.getCampaigns(1);
        insert campaignRecords;
        List<Id> campaignIds = new List<Id>();
        for(CW_Campaign__c campaignRecord: campaignRecords)
        {
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'AGTest_C'));
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'AGTest_T'));
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'AGTest'));            
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'AG_Test_T'));            
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'AG_Test______T'));
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'AG_Test______C'));
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'AG_Test____T______C'));
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'AG_Test'));
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'_T'));
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'_C'));
            campaignIds.add(campaignRecord.Id);
        }
        for(CW_Audience_Group__c audienceGroupRecord:audienceGroupRecords)
        {
            audienceGroupRecord.Name = audienceGroupRecord.Name.substring(0,audienceGroupRecord.Name.length()-1);       
        }
        insert audienceGroupRecords;

        CW_AudienceGroupRelationParamsController audienceGroupRelationParamsControllerObj = new CW_AudienceGroupRelationParamsController();
        audienceGroupRelationParamsControllerObj.campaignId = campaignIds[0];

        Test.StartTest();
        audienceGroupRelationParamsControllerObj.startBatch();
        Test.StopTest();
    }
}