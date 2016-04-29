/**
* File Name   :    PermissionUtil.cls
* Description :    Various utility functions based on the User permissions
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 30/06/2014 Cristina P.	Initial version
*
*
*/
public with sharing class PermissionUtil 
{
	public static CW_CampaignWizardAccessSettings__c mcbas; 
	
	public static Boolean hasUserEditPermission(Id UserId)
	{
		mcbas = CW_CampaignWizardAccessSettings__c.getInstance(UserId);
		if (mcbas!=null)
			return mcbas.Has_MarcomBriefEditAccess__c;
		
		return false;
	}
}