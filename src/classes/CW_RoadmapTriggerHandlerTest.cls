/**
* File Name   :    CW_RoadmapTriggerHandlerTest.cls
* Description :    B-108373
*                  trigger to copy Approval Status from Roadmap to all Child Campaigns when it changes.
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 29/04/2014 Alex Panka     Initial version
*
*
*/


@isTest
public with sharing class CW_RoadmapTriggerHandlerTest {
	
	static testMethod void copyApprovalStatusToCampaigns()
   {
    	
    	
   	CW_Roadmap__c roadmap = TestDataUtil.createRoadmap();
      insert roadmap;
        
      CW_Campaign__c campaign = TestDataUtil.createCampaign();
    	campaign.Roadmap__c = roadmap.Id;
    	insert campaign;
      	
    	roadmap.Approval_Status__c = ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
    	update roadmap;
    	System.Debug('####### ' +[SELECT id ,Roadmap_Approval_Status__c,Roadmap__r.Approval_Status__c FROM CW_Campaign__c] );
    	System.assertEquals(1,[SELECT id FROM CW_Campaign__c WHERE Id=:campaign.ID AND Roadmap_Approval_Status__c = :ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL ].size());
    	
    	roadmap.Approval_Status__c = ConstantUtil.APPROVAL_PROCESS_REJECTED;
    	update roadmap;
    	System.assertEquals(1,[SELECT id FROM CW_Campaign__c WHERE Id=:campaign.ID AND Roadmap_Approval_Status__c = :ConstantUtil.APPROVAL_PROCESS_REJECTED ].size());
    }

}