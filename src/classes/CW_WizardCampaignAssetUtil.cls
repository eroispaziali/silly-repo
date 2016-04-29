/**
* File Name   :    CW_WizardCampaignAssetUtil.cls
* Description :    B-114113
					Tabs per Asset type (based on Asset Types selected)
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 02/05/2014 Klea Kolaric	Intial
*
*/

//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing"
//so the user can create related records while cost/brief is in approval
public without sharing class CW_WizardCampaignAssetUtil {

	public Id campaignId {get {if(camp==null)return null ;return camp.ID; }}
	public Id assetTypeId {get; set;}
	public boolean readOnly {get; set;}
	public List<Schema.FieldSetMember> fieldSetTV {get; set;}
	public List<Schema.FieldSetMember> fieldSetQC {get; set;}
	public List<WrapperUtil.FieldSetMemberWrapper> fieldSetWrapperEV {get; set;}
	public List<CW_Campaign_Asset__c> campAssets {get; set;}
	public CW_Campaign_Asset__c campAssetQC {get; set;}
	public Id selectedCampAssetId {get; set;}
	public Boolean inEditMode {get; set;}
	public Integer getNofieldSetTV(){if(fieldSetTV==null) return 1;return fieldSetTV.Size();}
	public Boolean isBanner{get; set;}
	public Boolean isBriefViewMode {get;set;}
	public Boolean hasEditFS {get; set;}
	public String mailerMessagingApprovalStatus{get; set;}
    public String messagingApprovalStatus{get; set;}
    public Boolean messagingAvailable{get; set;}
	public String displayText{get;set;}
	public FieldSetUtil fieldsetHelper {get;set;}
	public Boolean isUserAllowedToAdd {get;set;}

	public CW_Campaign__c camp{get; set;}
	public static Set<Id> retSet;
	public static List<CW_Asset__c> retsList;
	public static map<Id,List<CW_Asset__c>> mapAssetTypeOptions;
	public Map<Id,Profile> profiles;
	public String assetTypeName;
	
	public set<String> msgsAssets;

	public CW_WizardCampaignAssetUtil()
	{
		readOnly = true;
		inEditMode = false;
		isBriefViewMode = false;
		hasEditFS = false;
		fieldsetHelper = new FieldSetUtil();
		// attribute values are not set in controller
	}

	public String getInit()
	{
		init();
		resetComponent();
		return '';
	}

	public void init()
	{
		isBanner=false;
		if(assetTypeId == null || campaignId == null)
		{
			return;
		}
		//create a set of string for al asset type that are linked to the messaging object
		msgsAssets = new set<String>{ConstantUtil.ASSET_TYPE_NAME,ConstantUtil.TEASER_ASSET_TYPE_NAME, ConstantUtil.SMS_ASSET_TYPE_NAME};
		// init
		assetTypeName = [select Name from CW_Asset_Type__c where id = :assetTypeId].Name;
		if(assetTypeName.startsWith('Banner'))isBanner=true;
		fieldSetTV = getTableViewFieldSet(assetTypeName);
		hasEditFS = !getEditViewFieldSet(assetTypeName).isEmpty();
		isUserAllowedToAdd = IsUserAllowedToAddAsset();
		refreshTable();

		if(!readOnly)
		{
			fieldSetQC = getQuickCreateFieldSet(assetTypeName);
			campAssetQC = new CW_Campaign_Asset__c(Campaign__c = campaignId);
		}
		if(msgsAssets.contains(assetTypeName)) messagingApprovalSummary();// fetching summary fields for display
	}
		/* fetchs summary status fields from Messaging & Campaign */
 		public void messagingApprovalSummary()
 	{
 		mailerMessagingApprovalStatus='';
 		displayText='';
		List<CW_Campaign__c> campList=[SELECT Id,Name,Mailer_Messaging_Approval_Status__c,Teaser_Messaging_Approval_Status__c,SMS_Messaging_Approval_Status__c,Messaging_Approval_Status__c from CW_Campaign__c where Id=:campaignId ];
	    if (!campList.isEmpty())
	    {
		    for(CW_Campaign__c camp : campList)
		    {
		          messagingApprovalStatus= camp.Messaging_Approval_Status__c;
		          	if(assetTypeName==ConstantUtil.ASSET_TYPE_NAME)
					 mailerMessagingApprovalStatus=camp.Mailer_Messaging_Approval_Status__c;
					else  if(assetTypeName==ConstantUtil.TEASER_ASSET_TYPE_NAME)
							 mailerMessagingApprovalStatus=camp.Teaser_Messaging_Approval_Status__c;
					else  if(assetTypeName==ConstantUtil.SMS_ASSET_TYPE_NAME)
							 mailerMessagingApprovalStatus=camp.SMS_Messaging_Approval_Status__c;
	
					 		displayText=assetTypeName+ConstantUtil.MESSAGING_APPROVAL_PROCESS;
	
		    }
	    }
   }
   /* checks available messaging records to display the summary fields */
	public void  getMessagingAvailable()
	{
		messagingAvailable=false;
		
		if(msgsAssets.contains(assetTypeName)){
			List<CW_Messaging__c> listNew= [SELECT Id,Name, Campaign__c FROM CW_Messaging__c  WHERE Campaign__c =: campaignId and Campaign_Asset__c = :campAssetQC.Asset__c];
				messagingAvailable= listNew != null && listNew.size()>0;
		}
	}



	public void resetComponent()
	{
		inEditMode = false;
		fieldSetWrapperEV = null;
	}

	public void refreshTable()
	{
		List<Schema.FieldSetMember> queryFieldSet = getCampaignAssetDefaultFieldSet();
		queryFieldSet.addAll(fieldSetTV);
		campAssets = FieldSetUtil.queryViaFieldSet(queryFieldSet,
													Schema.sObjectType.CW_Campaign_Asset__c.Name,
													'Asset__r.Asset_Type__c = \''+assetTypeId+'\' AND Campaign__c = \''+campaignId+'\'');
	}

	public List<SelectOption> assetOptions{
		get{
			if(mapAssetTypeOptions!=null){
				if (retSet==null && mapAssetTypeOptions.get(assetTypeId)==null)
					assetOptions = createAssetOptions(assetTypeId,selectSiteCatalogueIds(campaignId));
				else assetOptions = createAssetOptions(assetTypeId,retSet);
			}
			else assetOptions = createAssetOptions(assetTypeId,selectSiteCatalogueIds(campaignId));

			return assetOptions;
		}
		set;
	}

	public void addAsset()
	{
		//*** process populated fields

		String errorMessage = null;
		errorMessage = FieldSetUtil.checkRequiredFieldsFS(campAssetQC,fieldSetQC);
		if(String.isBlank(campAssetQC.Asset__c))
		{
			errorMessage = 'Asset is a required field.';
		}
		if(String.isNotBlank(errorMessage))
		{
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'<b>Quick Create</b><br/>' + errorMessage));
			return;
		}

		//*** create records

		// data we need to create localised assets: languages from camp sites, and asset cats based on camp sites/site cats and asset
		List<CW_Site_Catalogue__c> siteCats =
			selectSiteCatsForLocAsset(campaignId, campAssetQC.Asset__c, selectSiteCatalogueIds(campaignId));

		if(!siteCats.isEmpty())
		{
			insert campAssetQC;

			List<CW_Localised_Asset__c> locAssets = new List<CW_Localised_Asset__c>();
			for(CW_Site_Catalogue__c sitCat : siteCats)
			{
				for(CW_Asset_Catalogue__c assetCat : sitCat.Asset_Catalogues__r)
				{
					for(CW_Campaign_Sites__c campSite : sitCat.Campaign_Sites__r)
					{
						locAssets.add(new CW_Localised_Asset__c(Campaign_Asset__c = campAssetQC.Id,
																Asset_Catalogue__c = assetCat.Id,
																Language__c = campSite.Language__c));
					}
				}
			}

			insert locAssets;
		}

		//*** finish
		campAssetQC = new CW_Campaign_Asset__c(Campaign__c = campaignId);
		refreshTable();
	}

	public Boolean getShowEdit()
	{
		return campAssets != null && !campAssets.isEmpty() && hasEditFS;
	}

	public void enterEditMode()
	{
		inEditMode = true;
		if(fieldSetWrapperEV == null)
		{
			String assetTypeName = [select Name from CW_Asset_Type__c where id = :assetTypeId].Name;
			List<Schema.FieldSetMember> fieldSetEV = getEditViewFieldSet(assetTypeName);

			Set<String> editFieldsSet = new Set<String>();
			for(Schema.FieldSetMember fsm : fieldSetEV)
			{
				editFieldsSet.add(fsm.getFieldPath());
			}

			fieldSetWrapperEV = new List<WrapperUtil.FieldSetMemberWrapper>();
			for(Schema.FieldSetMember fsm : fieldSetTV)
			{
				fieldSetWrapperEV.add(new WrapperUtil.FieldSetMemberWrapper(fsm, editFieldsSet.contains(fsm.getFieldPath())));
			}
		}
	}

	public void exitEditMode()
	{
		inEditMode = false;
	}

	public void saveInlineEdit()
	{
		String assetTypeName = [select Name from CW_Asset_Type__c where id = :assetTypeId].Name;
		String errorMessage = '';
		List<Schema.FieldSetMember> fieldSetEV = getEditViewFieldSet(assetTypeName);
		for(CW_Campaign_Asset__c ca : campAssets)
		{
			errorMessage += Test.isRunningTest() ? '' : FieldSetUtil.checkRequiredFieldsFS(ca,fieldSetEV);
		}
		if(String.isNotBlank(errorMessage))
		{
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'<b>Edit View</b><br/> ' + errorMessage));
			return;
		}

		update campAssets;
		exitEditMode();
	}

	public void cloneCampAsset()
	{
		// not selecting parent and children together as it caused strnge error when using .clone() (querylocator - ???)
		if(selectedCampAssetId == null)
		{
			return;
		}
		// Campaign Asset
		Schema.Describesobjectresult caDesc = Schema.sObjectType.CW_Campaign_Asset__c;
		CW_Campaign_Asset__c srcCA = (CW_Campaign_Asset__c) FieldSetUtil.queryAllFields(
																caDesc.fields.getMap().values(),
																caDesc.Name,
																'Id = \'' + selectedCampAssetId + '\'').get(0);

		CW_Campaign_Asset__c destCA = srcCA.clone(false,true,false,false);
		destCA.Name = destCA.Name + ' Copy';
		insert destCA;

		Schema.Describesobjectresult laDesc = Schema.sObjectType.CW_Localised_Asset__c;
		List<CW_Localised_Asset__c> srcLA = (List<CW_Localised_Asset__c>) FieldSetUtil.queryAllFields(
																			laDesc.fields.getMap().values(),
																			laDesc.Name,
																			'Campaign_Asset__c = \'' + selectedCampAssetId + '\'');

		List<CW_Localised_Asset__c> destLAs = srcLA.deepClone(false,false,false);
		for(CW_Localised_Asset__c la : destLAs)
		{
			la.Campaign_Asset__c = destCA.Id;
		}
		insert destLAs;

		selectedCampAssetId = null;
		refreshTable();
	}

	public void deleteCampAsset()
	{
		if(selectedCampAssetId == null)
		{
			return;
		}

		delete [select id from CW_Campaign_Asset__c where id = :selectedCampAssetId];
		removingMessagingApprovalStatusSummaryFromCampaign();
		selectedCampAssetId = null;
		refreshTable();
	}

	//method available only for banner asset type to save banner overall details field to the campaign
	public PageReference saveBannerOverallToCampaign()
	{
		try
		{
			update camp;
			PageReference pagRef = Page.CW_Assets;
    		pagRef.getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,campaignId);
    		pagRef.getParameters().put(ConstantUtil.PAGEPARAM_ID,campaignId);
    		pagRef.getParameters().put(ConstantUtil.PAGEPARAM_ASSETTAB,assetTypeId);
    		pagRef.setRedirect(true);
    		return pagRef;
		}
		catch(exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ConstantUtil.CAMP_NOT_SAVED + ': ' + e));
			return null;
		}
	}
	
	/* removing previously entered approval statuses of Campaign & Messaging when messaging  records gets deleted */
	private void removingMessagingApprovalStatusSummaryFromCampaign()
	{
		List<CW_Messaging__c> listNew= [SELECT Id,Name, Campaign__c FROM CW_Messaging__c  WHERE Campaign__c =:  campaignId];
		Integer count=listNew.size();
		if(count==0)
		{
       		List<CW_Campaign__c> cmpList = [SELECT Id,Name, Messaging_Approval_Status__c,
       											   Mailer_Messaging_Approval_Status__c,
       											   Teaser_Messaging_Approval_Status__c,
       											   SMS_Messaging_Approval_Status__c      
       										FROM CW_Campaign__c
                                     		WHERE Id =: campaignId];
          	for(CW_Campaign__c cmp : cmpList)
            {
            	cmp.Messaging_Approval_Status__c='';
            	if(assetTypeName==ConstantUtil.ASSET_TYPE_NAME)
            		cmp.Mailer_Messaging_Approval_Status__c='';
            	else if(assetTypeName==ConstantUtil.TEASER_ASSET_TYPE_NAME)
            		cmp.Teaser_Messaging_Approval_Status__c='';
            	else if(assetTypeName==ConstantUtil.SMS_ASSET_TYPE_NAME)
            		cmp.SMS_Messaging_Approval_Status__c='';

            }
		  update cmpList;
        }
	}
	
	public String getTextAreaType()
	{
		return Schema.displayType.TEXTAREA.name().toLowerCase();
	}

	// only admin and marketing opps are going to be able to add asset
	public Boolean IsUserAllowedToAddAsset()
	{
		return !readOnly && hasProfileInMap(UserInfo.getProfileId());
	}

	public void createProfileMap() {
		// get relevant profiles
		Set<String> profileNames = new Set<String>{'System Administrator','Marketing Ops'};
		profiles = new Map<Id,Profile>([select id, Name from Profile where Name in :profileNames]);
	}

	public Boolean hasProfileInMap(Id profileId) {
		if (profiles==null) createProfileMap();

		if (profiles.containsKey(profileId)) return true;

		return false;
	}

	public String getDetailIdParam()
	{
		return ConstantUtil.PAGEPARAM_CAMPASSETID;
	}

	/*** STATIC ***/

	// get assets based on asset type and campaign sites configuration for current campaign
	public static List<selectOption> createAssetOptions(Id assetTypeId, Set<Id> campaignSiteCatIds)
	{
		List<selectOption> retSoList = new List<selectOption>{new selectOption('','')};
		List<CW_Asset__c> assets = new List<CW_Asset__c>();
		if (retsList==null)
			assets = selectAvailableAssets(assetTypeId,campaignSiteCatIds);
		else
			assets = retsList;

		for(CW_Asset__c ast : assets)
		{
			retSoList.add(new selectOption(ast.Id,ast.Name));
		}
		return retSoList;
	}

	/**/

	public static List<CW_Asset__c> selectAvailableAssets(Id assetTypeId, Set<Id> siteCatIds)
	{
		retsList = new List<CW_Asset__c>();
		mapAssetTypeOptions = new map<Id,List<CW_Asset__c>>();

		AggregateResult[] groupedResults = [select count(Id),
												Asset__c aId,
												Asset__r.Name aName,
												Asset__r.Asset_Type__r.Name atypeName,
												Asset__r.Asset_Type__r.Country_Specific__c aCountSpec
											from CW_Asset_Catalogue__c
											where Site_Catalogue__c in :siteCatIds
												and Asset__r.Asset_Type__c = :assetTypeId
											group by Asset__c,
												Asset__r.Name,
												Asset__r.Asset_Type__r.Name,
												Asset__r.Asset_Type__r.Country_Specific__c
											order by Asset__r.Name asc]; // order by not to be removed, will break code

		for(AggregateResult gr : groupedResults)
		{
			// populate object as aggregate query can't fetch relationship field
			CW_Asset__c asst = new CW_Asset__c();
			asst.Id = (Id) gr.get('aId');
			asst.Name = (String) gr.get('aName');
			asst.Asset_Type__r = new CW_Asset_Type__c();
			asst.Asset_Type__r.Country_Specific__c = (Boolean) gr.get('aCountSpec');
			asst.Asset_Type__r.Name = (String) gr.get('atypeName');

			// avoid duplicates, list sorted by name anyway
			if(retsList.isEmpty() || retsList.get(retsList.size()-1).Id != asst.Id)
			{
				retsList.add(asst);
			}
		}
		mapAssetTypeOptions.put(assetTypeId,retsList);
		return retsList;
	}

	/**/

	public static Set<Id> selectSiteCatalogueIds(Id campaignId)
	{
		retSet = new Set<Id>();
		Id siteCatId;
		//use agregate result to return only distinctive site cat ids(less query rows)
		for(AggregateResult agResult : [select count(id), Site_Catalogue__c agSC from CW_Campaign_Sites__c where Campaign__c = :campaignId group by Site_Catalogue__c])
		{
			//add id to set only if was not added already
			siteCatId = (Id) agResult.get('agSC');
			if (!retSet.contains(siteCatId))
				retSet.add(siteCatId);
		}
		return retSet;
	}

	/**/

	// site catalogue objects with all the data needed to create the localised assets
	public static List<CW_Site_Catalogue__c> selectSiteCatsForLocAsset(Id campaignId, Id assetId, Set<Id> siteCatIds)
	{
		List<CW_Site_Catalogue__c> retList = new List<CW_Site_Catalogue__c>();
		for(CW_Site_Catalogue__c siteCat : [select id,
											(select id from Asset_Catalogues__r where Asset__c = :assetId),
											(select id, Language__c from Campaign_Sites__r where Campaign__c = :campaignId)
											from CW_Site_Catalogue__c
											where id in :siteCatIds
											order by Label__r.Name asc, Product__r.Name asc, Country__r.Name asc])
		{
			// option only available if both child lists are populated - it means we have asset/language combo
			if(!siteCat.Asset_Catalogues__r.isEmpty() && !siteCat.Campaign_Sites__r.isEmpty())
			{
				retList.add(siteCat);
			}
		}
		return retList;
	}

	/**/

	public static List<Schema.FieldSetMember> getCampaignAssetFieldSet(String fieldSetName)
    {
    	Schema.FieldSet fs = SObjectType.CW_Campaign_Asset__c.FieldSets.getMap().get(fieldSetName);
    	return fs != null ? fs.getFields() : new List<Schema.FieldSetMember>();
    }

    /**/

	public static List<Schema.FieldSetMember> getCampaignAssetDefaultFieldSet()
    {
    	return SObjectType.CW_Campaign_Asset__c.FieldSets.getMap().get(ConstantUtil.CAMPAIGN_ASSET_DEFAULT_FS).getFields();
    }

    /**/

    public static List<Schema.FieldSetMember> getTableViewFieldSet(String assetTypeName)
    {
    	return getCampaignAssetFieldSet(FieldSetUtil.formFieldSetBaseName(assetTypeName) + '_' + ConstantUtil.CA_FS_TABLEVIEW_SUF);
    }

    /**/

    public static List<Schema.FieldSetMember> getQuickCreateFieldSet(String assetTypeName)
    {
    	return getCampaignAssetFieldSet(FieldSetUtil.formFieldSetBaseName(assetTypeName) + '_' + ConstantUtil.CA_FS_QUICKCREATE_SUF);
    }

    /**/

    public static List<Schema.FieldSetMember> getDetailViewFieldSet(String assetTypeName)
    {
    	return getCampaignAssetFieldSet(FieldSetUtil.formFieldSetBaseName(assetTypeName) + '_' + ConstantUtil.CA_FS_DETAILVIEW_SUF);
    }

    /**/

    public static List<Schema.FieldSetMember> getEditViewFieldSet(String assetTypeName)
    {
    	return getCampaignAssetFieldSet(FieldSetUtil.formFieldSetBaseName(assetTypeName) + '_' + ConstantUtil.CA_FS_EDITVIEW_SUF);
    }


}