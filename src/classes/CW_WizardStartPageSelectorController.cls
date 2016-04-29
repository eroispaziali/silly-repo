public with sharing class CW_WizardStartPageSelectorController 
{
	public Boolean			isCIMorBIUser {get;set;}
	public Boolean			isMarcomUser {get;set;}
	public set<Id>			CimBiUsers;
	public Id				campaignId {get;set;}
	public CW_Campaign__c	camp;
	
	public CW_WizardStartPageSelectorController(Apexpages.standardController stdCtrl)
	{
		if(stdCtrl != null)
		{
			camp = (CW_Campaign__c) stdCtrl.getRecord();
			campaignId =  stdCtrl.getId();
		}
		Apexpages.currentPage().getParameters().put('id',campaignId);
		CimBiUsers = cimAndBiUsers();
		isCIMorBIUser = CimBiUsers.contains(Userinfo.getUserId());
		isMarcomUser = (UserUtil.getCurrentProfileName(Userinfo.getUserId()) == ConstantUtil.MARCOM_PROFILE) ? true : false;
	}
	
	public CW_WizardStartPageSelectorController()
	{
		CimBiUsers = cimAndBiUsers();
		isCIMorBIUser = CimBiUsers.contains(Userinfo.getUserId());
	}
	
	public set<Id> cimAndBiUsers()
	{
		Set<Id> userIds = new Set<Id>();
		
		List<UserRole> userRoleIds = [SELECT Id from UserRole WHERE Name =: ConstantUtil.CIM_ROLE OR Name =: ConstantUtil.SPORT_BI_ROLE];
		
		for(User users : [SELECT Id,UserRoleId FROM User WHERE UserRoleId IN :userRoleIds])
    	{
    		userIds.add(users.Id);
    	}
    	
    	return userIds;
	}
}