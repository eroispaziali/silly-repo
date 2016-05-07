/**
* File Name   :    CW_AudienceGroupRelationParamsController.cls
* Description :    Class for page with params for running batch
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 01/05/2014 Alex Panka   Intial
* 0.2 10/07/2014 Amar Reddy   B-122759 related changes
*/

public with sharing class CW_AudienceGroupRelationParamsController {

    public String controlGroupSuffix;
    public String targetGroupSuffix;
    public String suffixSeparator;
    public Id      campaignId{get;set;}
    public Boolean closeDialog{get;set;}

    public CW_AudienceGroupRelationParamsController()
    {
        closeDialog=false;
        controlGroupSuffix=CW_CampaignListSettingHelper.TextValue(ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_NAME,ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_VALUE);
        targetGroupSuffix=CW_CampaignListSettingHelper.TextValue(ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_NAME , ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_VALUE);
        suffixSeparator=CW_CampaignListSettingHelper.TextValue(ConstantUtil.AUDIENCE_GROUP_SUFFIX_SEPARATOR_NAME , ConstantUtil.AUDIENCE_GROUP_SUFFIX_SEPARATOR_VALUE);
        campaignId = (Id) Apexpages.currentPage().getParameters().get(ConstantUtil.SOBJECT_ID);
        if(campaignId==null)
            campaignId= (Id) Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_CAMPAIGNID);

    }

    public PageReference startBatch()
    {
        CW_CampaignListSettingHelper.SetTextValue(ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_NAME, controlGroupSuffix);
        CW_CampaignListSettingHelper.SetTextValue(ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_NAME , targetGroupSuffix);
        CW_CampaignListSettingHelper.SetTextValue(ConstantUtil.AUDIENCE_GROUP_SUFFIX_SEPARATOR_NAME , suffixSeparator);

        CW_BatchAudienceGroupRelationAssign audienceGroupBatch= new CW_BatchAudienceGroupRelationAssign(controlGroupSuffix,targetGroupSuffix,new List<Id>{campaignId});
        audienceGroupBatch.suffixIndicator=suffixSeparator;
        Id batchJobId = Database.executeBatch(audienceGroupBatch, 2000);
        PageReference progressPage = Page.CW_BatchJobProgressPage;
        progressPage.setRedirect(true);
        progressPage.getParameters().put(ConstantUtil.PAGEPARAM_BATCHJOBID,batchJobId);
        progressPage.getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,campaignId);
        return progressPage;

    }
}