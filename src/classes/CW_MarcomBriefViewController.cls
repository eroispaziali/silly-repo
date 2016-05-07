/**
* File Name   :    CW_MarcomBriefViewController.cls
* Description :    B-109868: Add Related objects to the MarCom Brief View 
*
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 04/06/2014 Cristina P.	Intial
* 0.2 30/06/2014 Cristina P.	B-120546: Change Account Partner Privileges
*
*/
public without sharing class CW_MarcomBriefViewController 
{
	public CW_Campaign__c 	camp {get; set;}
	public String 			fieldsetName {get;set;}	
	public Id 				campaignId {get;set;}
	public Boolean			isBriefViewMode {get; set;}	
	public Boolean 			isMarketingUser {get; set;}
	public Boolean			hasDeleteAccess {get;set;}
	public Boolean 			hasPermission {get; set;}
	
	public List<WrapperUtil.SelectWrapper> productColumns {get; set;}
	public List<WrapperUtil.SelectWrapper> languages {get; set;}
	public List<WrapperUtil.SelectListWrapper> labelProductMatrix {get; set;}
	public CW_AssociateAudienceRewardHelper AssociateRewardHelper{get; set;}
	public CW_WizardRewardUtil rewardHelper {get;set;}
	public CW_WizardBrandLabelUtil pageBrandHelper {get; set;}
	public List<WrapperUtil.FieldSetMemberWrapper> fieldSetWrapper {get; set;}
	public List<CW_Task__c> tasks {get;set;}
	
	public List<Schema.FieldSetMember> schFields {get; set;}
	public List<CW_Schedule__c> schedules {get; set;}
	
	public List<String> assetType {get; set;}
	public List<List<WrapperUtil.selectWrapper>> assetTypeOptions {get; private set;}
	public Id assetTypeId {get; set;}
	
	public List<CW_Campaign_Reward__c>	crList {get;set;}
	public List<CW_Audience_Group_Schedule_Reward__c> agsrList {get;set;}
	public List<sObject>      sObjectList{get; set;}
	
	public CW_MarcomBriefViewController()
	{
		camp = new CW_Campaign__c();
	}
	
	public CW_MarcomBriefViewController(Apexpages.standardController stdCtrl)
	{
		camp = (CW_Campaign__c) stdCtrl.getRecord();
		if(camp.id != null)
		{
			camp = getCampaignInfo();
		}
		
		hasDeleteAccess = (camp.OwnerId ==Userinfo.getUserId() && camp.Stage__c == ConstantUtil.CAMP_STAGE_DRAFT) ? true : false;
		isMarketingUser = (UserUtil.getCurrentProfileName(Userinfo.getUserId()) == ConstantUtil.MARKETING_PROFILE) ? true : false;
		hasPermission = PermissionUtil.hasUserEditPermission(Userinfo.getUserId());
		
		// load page section data
		pageBrandHelper = new CW_WizardBrandLabelUtil();
		loadProductLabelMatrix();
		loadSchedules();
		initAssetPage();
		AssociateRewardHelper = new CW_AssociateAudienceRewardHelper(camp.Id);
		rewardHelper = new CW_WizardRewardUtil();
		tasks = getRelatedTasks(camp.Id);
	}
	
	//get the fields that are diplayed on each VF page
    public List<WrapperUtil.FieldSetMemberWrapper> getCampaignInformationFieldset() 
    {
    	Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.CW_Campaign__c.fields.getMap();
    	fieldSetWrapper = new List<WrapperUtil.FieldSetMemberWrapper>();
		for(Schema.FieldSetMember fsm : SObjectType.CW_Campaign__c.FieldSets.getMap().get(ConstantUtil.MARCOM_CAMP_INFO_BV).getFields())
		{
			if (fsm.getFieldPath()!='Owner.Name' && fsm.getFieldPath()!='Name' && hasPermission)
			{
				if(mapFields.get(fsm.getFieldPath()).getDescribe().isUpdateable()) 
					fieldSetWrapper.add(new WrapperUtil.FieldSetMemberWrapper(fsm, true));
				else
					fieldSetWrapper.add(new WrapperUtil.FieldSetMemberWrapper(fsm, false));
			}
			else
				fieldSetWrapper.add(new WrapperUtil.FieldSetMemberWrapper(fsm, false));
       	}
       	
		return fieldSetWrapper;
    }
    
    //fieldset to display specific fields from the business case section
    public List<Schema.FieldSetMember> getBusinessCaseFieldset() 
    {
    	return SObjectType.CW_Campaign__c.FieldSets.getMap().get(ConstantUtil.MARCOM_BUSINESS_CASE_BV).getFields();
    }
    //fieldset to display specific fields from the creative concept section
    public List<Schema.FieldSetMember> getCreativeConceptFieldset() 
    {
    	return SObjectType.CW_Campaign__c.FieldSets.getMap().get(ConstantUtil.MARCOM_CREATIVE_CONCEPT_BV).getFields();
    }
    //fieldset to display specific fields from the legal information section
    public List<Schema.FieldSetMember> getLegalInfoFieldset() 
    {
    	return SObjectType.CW_Campaign__c.FieldSets.getMap().get(ConstantUtil.MARCOM_LEGAL_INFO_BV).getFields();
    }
    //fieldset to display specific fields from the offer & reward section
    public List<Schema.FieldSetMember> getOfferRewardFieldset() 
    {
    	return SObjectType.CW_Campaign__c.FieldSets.getMap().get(ConstantUtil.MARCOM_REWARD_BV).getFields();
    }
    
    //lod the brand product label matrix
    public void loadProductLabelMatrix()
    {
    	// create brand list
		CW_WizardBrandLabelUtil pageBrandHelper = new CW_WizardBrandLabelUtil();
		pageBrandHelper.brands = WrapperUtil.createWrapperList([select id, Name from CW_Brand__c where Is_Active__c = true limit 10000], 
																null, ConstantUtil.SOBJECT_NAME, ConstantUtil.SOBJECT_ID, 
																ConstantUtil.SOBJECT_ID);
																
		pageBrandHelper.existingCampSites = CW_WizardBrandLabelUtil.selectCampaignSites(camp.Id);
		if(pageBrandHelper.existingCampSites == null || pageBrandHelper.existingCampSites.isEmpty())
		{
			return; // no objects to show
		}
		
		pageBrandHelper.markExistingList(true,false);
		pageBrandHelper.loadLabelProductMatrix();
		pageBrandHelper.markExistingMatrix(true,false);
		
		labelProductMatrix = pageBrandHelper.labelProductMatrix;
		productColumns = pageBrandHelper.productColumns;
		//load languages
		pageBrandHelper.loadLanguages();
		//preselect all the languages
		pageBrandHelper.markExistingList(false,true);
		
		languages = pageBrandHelper.languages;
    }
    
    //load all th existing schedules
    public void loadSchedules()
    {
    	Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
    	CW_ScheduleDetailsController sdc = new CW_ScheduleDetailsController();
    	if(sdc.schedules != null && !sdc.schedules.isEmpty())
    	{
    		schedules = sdc.schedules;
    		schFields = sdc.schFields;
    	}
    	
    	Apexpages.currentPage().getParameters().remove(ConstantUtil.PAGEPARAM_CAMPAIGNID);
    }
    
    //load all assets
	public void initAssetPage()
	{
		List<WrapperUtil.selectWrapper> tempList=new List<WrapperUtil.selectWrapper>();
		assetTypeOptions= new List<List<WrapperUtil.selectWrapper>> ();
		
		for (WrapperUtil.selectWrapper rec :  WrapperUtil.createWrapperList(
							[select Asset_Type__r.Id, Asset_Type__r.Name from CW_Campaign_Asset_Type__c where Campaign__c = :camp.Id],
							ConstantUtil.CW_CAT_REL_ASSETTYPE,ConstantUtil.SOBJECT_NAME,ConstantUtil.SOBJECT_ID,ConstantUtil.SOBJECT_ID)){
				tempList.Add(rec);
				if(tempList.size()>6){
					assetTypeOptions.Add(tempList);
					tempList=new List<WrapperUtil.selectWrapper>();
				}
			}
			if(tempList.size()>0)
					assetTypeOptions.Add(tempList);
		assetTypeId = assetTypeOptions.isEmpty() ? null : (Id) assetTypeOptions.get(0).get(0).optionValue;
	}
    
    //query all the campaign fields
  	private CW_Campaign__c getCampaignInfo() {
        String queryString = 'SELECT ';
        for (Schema.SObjectField f : Schema.SObjectType.CW_Campaign__c.fields.getMap().values())
        {
            queryString += f.getDescribe().getName() + ', ';
        }
        //queryString = queryString.removeEnd(', ');
        queryString += 'Owner.Name FROM CW_Campaign__c WHERE Id =\'' + camp.Id + '\'';
        
        return Database.query(queryString);
    }
    
    public pageReference editRecord()
    {
    	PageReference ref = Page.CW_WizardStartPageSelector;
    	ref.getParameters().put(ConstantUtil.SOBJECT_ID,camp.Id);
    	ref.getParameters().put(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE,'False');
    	return ref;
    }
    
    public pageReference deleteRecord()
    {
    	try 
    	{
    		delete camp;
    	
	    	PageReference pageRef = new PageReference('/' + Schema.sObjectType.CW_Campaign__c.keyPrefix + '/o');    
	    	pageRef.setRedirect(true);
	    	return pageRef; 
	    	
    	}catch(Exception ex){
			ApexPages.addMessages(ex);
		}
		
		return null;
    }
    
    public pageReference backToListView()
    {
    	PageReference pageRef = new PageReference('/' + Schema.sObjectType.CW_Campaign__c.keyPrefix + '/o');    
    	pageRef.setRedirect(true);
    	return pageRef; 
    }
    
    public List<WagerUplift> getWagerUplift() {
            return getWagerUpliftFields();
    }
    
    public List<NGRUplift> getNGRUplift() {
            return getNGRUpliftFields();
    }
    
    public List<WagerUplift> getWagerUpliftFields() 
   	{
        List<WagerUplift> WagerUpliftFields = new List<WagerUplift>();

        CW_Campaign__c dataItems = [SELECT Average_Wager_Uplift_Control__c, 
        								   Average_Wager_Uplift_Target__c,
        								   Average_NGR_Uplift_Control__c,
        								   Average_NGR_Uplift_Target__c 
        							FROM CW_Campaign__c
        							WHERE Id=: camp.Id];
        
       WagerUplift uplift = new WagerUplift ('Control', dataItems.Average_Wager_Uplift_Control__c);
       WagerUpliftFields.add(uplift);
       
       uplift = new WagerUplift ('Target', dataItems.Average_Wager_Uplift_Target__c);
       WagerUpliftFields.add(uplift);
       
       return WagerUpliftFields;
    }
    
    public List<NGRUplift> getNGRUpliftFields() 
   	{
        List<NGRUplift> NGRUpliftFields = new List<NGRUplift>();

        CW_Campaign__c dataItems = [SELECT Average_Wager_Uplift_Control__c, 
        								   Average_Wager_Uplift_Target__c,
        								   Average_NGR_Uplift_Control__c,
        								   Average_NGR_Uplift_Target__c 
        							FROM CW_Campaign__c
        							WHERE Id=: camp.Id];
        
       NGRUplift uplift = new NGRUplift ('Control', dataItems.Average_NGR_Uplift_Control__c);
       NGRUpliftFields.add(uplift);
       
       uplift = new NGRUplift ('Target', dataItems.Average_NGR_Uplift_Target__c);
       NGRUpliftFields.add(uplift);
       
       return NGRUpliftFields;
    }
    
    public class WagerUplift {
        public String WagerUpliftName { get; set; }        
        public Decimal WagerUpliftValue { get; set; }

        public WagerUplift(String WagerUpliftName, Decimal WagerUpliftValue) {
            this.WagerUpliftName = WagerUpliftName;
            this.WagerUpliftValue = (WagerUpliftValue != null) ? WagerUpliftValue : 0.0;           
        }
    }
    
    public class NGRUplift {
        public String NGRUpliftName { get; set; }        
        public Decimal NGRUpliftValue { get; set; }

        public NGRUplift(String NGRUpliftName, Decimal NGRUpliftValue) {
            this.NGRUpliftName = NGRUpliftName;
            this.NGRUpliftValue = (NGRUpliftValue != null) ? NGRUpliftValue : 0.0;           
        }
    }
    public void emptyAction()
	{
		
	}
	
	public List<CW_Task__c> getRelatedTasks(Id campId)
	{
		tasks = [SELECT Id, Name, Due_Date__c, Marketing_Campaign__c, Requestor__c, Status__c
				 FROM CW_Task__c  WHERE Marketing_Campaign__c =: campId];
				 
		return tasks;
	}
	
	public void saveCampaign()
	{
		try
		{
			update camp;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ConstantUtil.POINTS_SAVED_SUCCESFULLY));
		}
		catch(Exception ex)
		{
			ApexPages.addMessages(ex);
		}
	}
}