/**
* File Name   :    CW_MarcomBriefViewSelectorController.cls
* Description :    B-109868: Add Related objects to the MarCom Brief View 
*				   Displayes VF page for marcom and marketing users and 
*				   standard page layout for other profiles
*
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 05/06/2014 Cristina P.	Intial
*
*/
public with sharing class CW_MarcomBriefViewSelectorController 
{
	public Boolean 			isMarcomUser {get; set;}
	public Id 				campaignId {get; set;}
	public CW_Campaign__c 	camp;
	
	public CW_MarcomBriefViewSelectorController(Apexpages.standardController stdCtrl)
	{
		if(stdCtrl != null)
		{
			camp = (CW_Campaign__c) stdCtrl.getRecord();
			campaignId =  stdCtrl.getId();
		}
		Apexpages.currentPage().getParameters().put('id',campaignId);
		
		if (UserUtil.getCurrentProfileName(Userinfo.getUserId())==ConstantUtil.MARCOM_PROFILE ||
			UserUtil.getCurrentProfileName(Userinfo.getUserId()) == ConstantUtil.MARKETING_PROFILE)
			isMarcomUser = true;
		else
			isMarcomUser = false;
	}
}