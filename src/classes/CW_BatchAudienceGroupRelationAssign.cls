/**
* File Name   :    CW_BatchAudienceGroupRelationAssign.cls
* Description :    B-115203 - Target and Control group Naming Convention
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 13/05/2014 Alex Panka     Initial version
* 0.2 10/07/2014 Amar Reddy     B-122759 : Process Relationship based on Group Name
*
*/

global class CW_BatchAudienceGroupRelationAssign implements Database.Batchable<sObject>{

    global String controlGroupSuffix=CW_CampaignListSettingHelper.TextValue(ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_NAME,ConstantUtil.AUDIENCE_CONTROL_GROUP_SUFFIX_VALUE);
    global String targetGroupSuffix=CW_CampaignListSettingHelper.TextValue(ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_NAME , ConstantUtil.AUDIENCE_TARGET_GROUP_SUFFIX_VALUE);
    global String suffixIndicator=CW_CampaignListSettingHelper.TextValue(ConstantUtil.AUDIENCE_GROUP_SUFFIX_SEPARATOR_NAME , ConstantUtil.AUDIENCE_GROUP_SUFFIX_SEPARATOR_VALUE);
    global Set<Id> campaignIds;

    private List<CW_Audience_Group__c> recordsToUpdate= new List<CW_Audience_Group__c>();

    global CW_BatchAudienceGroupRelationAssign( )
    {
        campaignIds=null;
    }


    global CW_BatchAudienceGroupRelationAssign(String ctrlGrpSuffix,String trgtGrpSuffix )
    {
        controlGroupSuffix=ctrlGrpSuffix;
        targetGroupSuffix=trgtGrpSuffix ;
        campaignIds=null;
    }
    global CW_BatchAudienceGroupRelationAssign(String ctrlGrpSuffix,String trgtGrpSuffix ,List<Id> campIds )
    {
        controlGroupSuffix=ctrlGrpSuffix;
        targetGroupSuffix=trgtGrpSuffix;
        campaignIds=new Set<Id>(campIds);
    }

    global Database.QueryLocator start(Database.BatchableContext batchContext)
    {
        return Database.getQueryLocator('SELECT ID,(SELECT ID,Name,Is_Control_Group__c ,Control_Group__c FROM Audience_Groups__r) FROM CW_Campaign__c  ' +getWhereString());
    }

    global void execute(Database.BatchableContext batchContext, List<CW_Campaign__c> campaignRecords)
    {
        for(CW_Campaign__c campaignRecord :campaignRecords)
        {
            processRelationships(campaignRecord);
        }
        try
        {
            update recordsToUpdate;
        }
        catch(DMLException dmlExceptionObject)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,dmlExceptionObject.getMessage()));
        }

        catch(Exception exceptionObject)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,exceptionObject.getMessage()));
        }
    }

    global void finish(Database.BatchableContext batchContext)
    {

    }

    private String getWhereString()
    {
        if(campaignIds==null || campaignIds.size()==0)
        {
            return '';
        }
        String sWhere='';
        for(Id campaignId:campaignIds)
        {
            if(sWhere=='')
            {
                sWhere=' WHERE Id in ( \'' +campaignId+ '\' ';
            }
            else
            {
                sWhere+= ',\'' +campaignId+ '\' ';
            }
        }
        return sWhere +')';
    }

    private String getNameWithoutSuffix(String groupName)
    {
        Integer lastIndex=groupName.lastIndexOf(suffixIndicator);
        return groupName.substring(0,lastIndex);
    }

    private void processRelationships(CW_Campaign__c campaignRecord)
    {
        List<CW_Audience_Group__c> targetGroupRecords = new List<CW_Audience_Group__c>();
        List<CW_Audience_Group__c> controlGroupRecords = new List<CW_Audience_Group__c>();

        for(CW_Audience_Group__c audienceGroupRecord : campaignRecord.Audience_Groups__r)
        {

            if(audienceGroupRecord.Name.endsWith(targetGroupSuffix))
            {
                audienceGroupRecord.Is_control_group__c = false;
                targetGroupRecords.add(audienceGroupRecord);
            }
            else if(audienceGroupRecord.Name.endsWith(controlGroupSuffix))
            {
                audienceGroupRecord.Is_control_group__c = true;
                audienceGroupRecord.Control_group__c = null;
                controlGroupRecords.add(audienceGroupRecord);

            }

        }

      
            for(CW_Audience_Group__c targetGroupRecord : targetGroupRecords)
            {
                    for(CW_Audience_Group__c controlGroupRecord : controlGroupRecords)
                    {
                        if(getNameWithoutSuffix(targetGroupRecord.Name).equals(getNameWithoutSuffix(controlGroupRecord.Name))  )
                        {
                            targetGroupRecord.Control_group__c = controlGroupRecord.Id;
                        }
                    }
                }

        recordsToUpdate.AddAll(targetGroupRecords);
        recordsToUpdate.AddAll(controlGroupRecords);
    }
}