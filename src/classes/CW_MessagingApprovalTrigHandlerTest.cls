/**
* File Name   :    CW_MessagingApprovalTrigHandlerTest
* Description :    trigger to update asset date approval process whenever related messaging records got changed
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 20/08/2014Suneetha Jasthi     B-122329  Mailer/teaser/SMS messaging approval processes
*
*/


@isTest
private  class CW_MessagingApprovalTrigHandlerTest
{


   static testMethod void testupdatetMessagingApprovalStatus()
    {
        // if this field set doesn't exist, there is no point in executing test
        if(Schema.sObjectType.CW_Messaging__c.FieldSets.getMap().containsKey(TestDataUtil.MAILER))
        {
            CW_WizardBrandLabelUtilTest.dataSetup();
            CW_WizardAssetUtilTest.dataSetup();

            CW_Campaign__c camp = TestDataUtil.createCampaign();
            insert camp;
            CW_WizardAssetUtilTest.associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
            CW_WizardAssetUtilTest.addAllAssetTypesToCampaign(camp.Id);

            // create asset selection on campaign
            CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c();
            ca.Campaign__c = camp.Id;
            ca.Asset__c = [select id from CW_Asset__c where Name = :(TestDataUtil.MAILER+' '+TestDataUtil.BASIC) limit 1].id;
            insert ca;

            List<CW_Localised_Asset__c> loc = new List<CW_Localised_Asset__c>();
            Id enId = [select id from CW_Language__c where Name = :TestDataUtil.EN limit 1].id;

            for(CW_Asset_Catalogue__c ac : [select id from CW_Asset_Catalogue__c where Asset__c = :ca.Asset__c])
            {
                CW_Localised_Asset__c la = new CW_Localised_Asset__c();
                la.Campaign_Asset__c = ca.Id;
                la.Asset_Catalogue__c = ac.Id;
                la.Language__c = enId;
                loc.add(la);
            }
            insert loc;

            // pre add messaging object
            CW_Messaging__c msg1 = new CW_Messaging__c(Campaign__c=camp.Id,Campaign_Asset__c = ca.Id, Dispatch_Date__c = Date.Today().addDays(2));
            insert msg1;
            msg1.Approval_Status__c = 'Rejected';
            update msg1;

            Test.setCurrentPage(Page.CW_Campaign_Asset_Details);
            Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPASSETID,ca.Id);
            Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE,'false');

            CW_Messaging__c msg2 = new CW_Messaging__c(Campaign__c=camp.Id,Campaign_Asset__c = ca.Id, Dispatch_Date__c = Date.Today().addDays(2));
            insert msg2;
            msg2.Approval_Status__c = 'Rejected';
            update msg2;

            List<CW_Messaging__c> newObjects=new List<CW_Messaging__c>();
            newObjects.add(msg1);
            newObjects.add(msg2);

            CW_MessagingApprovalTriggerHandler approvalTrigger=new CW_MessagingApprovalTriggerHandler(true);

             Test.startTest();
            approvalTrigger.updatetMessagingApprovalStatus(newObjects,ConstantUtil.ASSET_TYPE_NAME);
            Test.stopTest();

            Integer count= [select count() from  CW_Campaign_Asset__c where Id=:ca.Id and Campaign__c=:camp.Id ];
         	system.assertEquals(count, [select count() from  CW_Campaign_Asset__c where Id=:ca.Id and Campaign__c=:camp.Id and Date_Approval_Summary__c=:ConstantUtil.APPROVAL_PROCESS_SOME_REJECTED]);
		 	system.assertEquals(1, [select count()  from CW_Campaign__c where Id=:camp.Id and Mailer_Messaging_Approval_Status__c=:ConstantUtil.APPROVAL_PROCESS_SOME_REJECTED]);
        }
    }

}