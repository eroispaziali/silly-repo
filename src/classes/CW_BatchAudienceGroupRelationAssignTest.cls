/**
* File Name   :    CW_BatchAudienceGroupRelationAssignTest.cls
* Description :    B-115203 - Target and Control group Naming Convention
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 13/05/2014 Alex Panka     Initial version
* 0.2 10/07/2014 Amar Reddy     
*
*/
@IsTest
public with sharing class CW_BatchAudienceGroupRelationAssignTest {

    static testMethod void testBatch()
    {
        List<CW_Audience_Group__c> audienceGroupRecords= new List<CW_Audience_Group__c>();
        List<CW_Campaign__c> campaignRecords = TestDataUtil.getCampaigns(2);
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
            audienceGroupRecords.AddAll(TestDataUtil.createAudienceGroups(campaignRecord.Id,1,false,'AG_Test____T______T'));            
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

        CW_BatchAudienceGroupRelationAssign batchJob1 = new CW_BatchAudienceGroupRelationAssign();
        CW_BatchAudienceGroupRelationAssign batchJob2 = new CW_BatchAudienceGroupRelationAssign(ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_VALUE, ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_VALUE);
        CW_BatchAudienceGroupRelationAssign batchJob3 = new CW_BatchAudienceGroupRelationAssign(ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_VALUE, ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_VALUE, campaignIds);

        Test.StartTest();
        Id batchJobId1 = Database.executeBatch(batchJob1);
        Id batchJobId2 = Database.executeBatch(batchJob2);
        Id batchJobId3 = Database.executeBatch(batchJob3);
        Test.StopTest();
        System.AssertEquals(true, [SELECT Id, Is_Control_Group__c from CW_Audience_Group__c WHERE Name='AGTest_C'][0].Is_Control_Group__c);
        System.AssertEquals(true, [SELECT Id, Is_Control_Group__c from CW_Audience_Group__c WHERE Name='AG_Test______C'][0].Is_Control_Group__c); 
        System.AssertEquals(true, [SELECT Id, Is_Control_Group__c from CW_Audience_Group__c WHERE Name='AG_Test____T______C'][0].Is_Control_Group__c); 
        
        System.AssertEquals([SELECT Id from CW_Audience_Group__c WHERE Name='AGTest_C'][0].Id, [SELECT Id, Control_Group__c from CW_Audience_Group__c WHERE Name='AGTest_T'][0].Control_Group__c);
        System.AssertEquals([SELECT Id from CW_Audience_Group__c WHERE Name='AG_Test______C'][0].Id, [SELECT Id, Control_Group__c from CW_Audience_Group__c WHERE Name='AG_Test______T'][0].Control_Group__c); 
        System.AssertEquals([SELECT Id from CW_Audience_Group__c WHERE Name='AG_Test____T______C'][0].Id, [SELECT Id, Control_Group__c from CW_Audience_Group__c WHERE Name='AG_Test____T______T'][0].Control_Group__c); 

    }
}