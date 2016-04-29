/**
* File Name   :    CW_WizardAssetUtil.cls
* Description :    Page for configuring asset selection on campaign
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 28/03/2014 Klea Kolaric	Intial
* 0.2 07/05/2014 Klea Kolaric	Complete redo for B-114121 (add products)
* 0.3 12/05/2014 Klea Kolaric	B-108923 show Messaging related list
* 0.4 16/05/2014 Cristina P		B-108927 Approve / Reject Mailer Dispatch Dates
*				   				B-108925 Approve / Reject Teaser Dates
* 0.5 10/06/2014 Klea Kolaric	D-35790 Associating Labels to Assets Issue
* 0.6 01/08/2014 Suneetha Jasthi  B-122329 Messaging dates approval process
* 0.7 26/08/2014 Suneetha Jasthi B-129707-Handle Asset Messaging Object
*
*/

//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing"
//so the user can create related records while cost/brief is in approval
public without sharing class CW_WizardAssetUtil {

	public CW_Campaign_Asset__c campAsset {get; private set;}
	public List<CW_Localised_Asset__c> locAssets {get; private set;}
	public List<CW_Campaign_Sites__c> cmpSites {get; private set;}
	public List<Schema.FieldSetMember> fieldSetDV {get; set;}
	public List<WrapperUtil.SelectListWrapper> languageMatrix {get; set;}
	public List<WrapperUtil.SelectWrapper> languageColumns {get; set;}
	public FieldSetUtil fieldsetHelper {get;set;}

	public List<Schema.FieldSetMember> msgFields {get; set;}
	public List<CW_Messaging__c> msgList {get; set;}
	public Boolean msgEditMode {get; set;}
	public Id deleteMsgId {get; set;}
	public List<String> recInApproval;
	public String errorMessage {get;set;}
	public Set<String> assetLabelsSelected;

	public Boolean closeDialog{get;set;}
	public Boolean isBriefViewMode {get; set;}

	public Map<Id,CW_Messaging__c> oldMsgMap;
	public Map<Id,CW_Messaging__c> newMsgMap;

	public String messagingApprovalSummary{get; set;}

	public CW_WizardAssetUtil()
	{
		Id campAssetId = (Id) Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_CAMPASSETID);
		isBriefViewMode = Boolean.valueOf(Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE));
		campAsset = campAssetId == null ? new CW_Campaign_Asset__c() : findCampAsset(campAssetId);
		fieldsetHelper = new FieldSetUtil();
		closeDialog=false;
		if(campAsset.Id != null)
		{
			locAssets = selectLocalisedAssets(campAsset.Id);
			// only get relevant camp sites
			cmpSites = selectCampaignSitesLPC(campAsset.Campaign__c);
			cmpSites = filterSiteCatsByAsset(cmpSites);
			createLanguageMatrix();
			initMessaging();
		}
	}

	/**/

	public void initMessaging()
	{
		msgEditMode = false;
		Schema.Describesobjectresult dor = Schema.sObjectType.CW_Messaging__c;
		if(msgFields == null)
		{
			Map<String,Schema.FieldSet> fieldSetMap = dor.FieldSets.getMap();
			msgFields = FieldSetUtil.getFieldSet(fieldSetMap, campAsset.Asset__r.Asset_Type__r.Name);
		}
		if(!msgFields.isEmpty())
		{
			msgList = FieldSetUtil.queryViaFieldSet(msgFields, dor.Name,
				Schema.sObjectType.CW_Messaging__c.fields.Campaign_Asset__c.Name + ' = \'' + campAsset.Id + '\' ORDER BY CreatedDate');
			// ^ doesn't compile with dor (?)
		}
		getMessagingApprovalStatus();
	}

	 /* populating messagingapprovalsummay with date_approval_summary field value from Campaign Asset*/
        private void getMessagingApprovalStatus(){

           List<CW_Campaign_Asset__c> campAssetList=[SELECT Id,Name,Date_Approval_Summary__c from CW_Campaign_Asset__c where Id=:campAsset.Id];
                for(CW_Campaign_Asset__c campAsset : campAssetList)
                {

              messagingApprovalSummary= campAsset.Date_Approval_Summary__c;

                }
        }

	/**/

	public Boolean getCountrySpecific()
	{
		return campAsset.Asset__r.Asset_Type__r.Country_Specific__c;
	}

	/**/

	public void saveNewAssets()
	{
		try
		{
			applySelection();
			closeDialog=true;
			handleAssetMessagingLabell(msgList); ///B-129707-Handle Asset Messaging Object
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,System.Label.CW_Asset_Save_Confirmation));
		}
		catch(exception e)
		{
			ApexPages.addMessages(e);
		}
	}

	/**/

	// create matrix; rows(superobject): site catalogue; columns(subobjects): language
	public void createLanguageMatrix()
	{
		Map<Id,CW_Asset_Catalogue__c> assetCatMap = new Map<Id,CW_Asset_Catalogue__c>();
		// find all available languages
		{
			List<CW_Language__c> campLang = new List<CW_Language__c>();

			for (CW_Asset_Catalogue__c curr : [SELECT ID,Site_Catalogue__c FROM CW_Asset_Catalogue__c WHERE Asset__c =:campAsset.Asset__c])
			{
				assetcatMap.put(curr.Site_Catalogue__c,curr);
			}

			for(CW_Campaign_Sites__c cs : cmpSites)
			{
				campLang.add(cs.Language__r);
			}

			languageColumns = WrapperUtil.createWrapperList(campLang, null, ConstantUtil.SOBJECT_NAME,
															ConstantUtil.SOBJECT_ID, ConstantUtil.SOBJECT_ID);
		}

		// site catalogues contained in this list are already filtered based on asset catalogue,
		// and can therefore be directly saved
		languageMatrix = WrapperUtil.createObjectWrapperList(cmpSites, languageColumns, ConstantUtil.CW_CS_REL_SITECATALOGUE,
																ConstantUtil.CW_CS_REL_LANGUAGE, ConstantUtil.SOBJECT_NAME,
																ConstantUtil.SOBJECT_ID, ConstantUtil.SOBJECT_ID);

		//looping through the matrix hid ethe rows that are not available for the selected asset type
		for (WrapperUtil.SelectListWrapper curr : languageMatrix)
		{
			if (!assetcatMap.containsKey(curr.siteCat.Id))
				curr.showRow = false;
		}

		markPreselected();

		// hide single country labels if they have only one language
		// KK: this is now to be removed, but as I might be leaving the project I'll leave it in in case the requirements change again
		/*{
			// k: comboKey ; v: list of country ids
			Map<String,Set<Id>> countCountry = new Map<String,Set<Id>>();	// if set has only one value - only one country
			for(WrapperUtil.SelectListWrapper lm : languageMatrix)
			{
				String comboKey = CW_WizardBrandLabelUtil.createComboKey(lm.siteCat.Label__c, lm.siteCat.Product__c, null);
				if(!countCountry.containsKey(comboKey))
				{
					countCountry.put(comboKey,new Set<Id>());
				}
				countCountry.get(comboKey).add(lm.siteCat.Country__c);
			}
			for(WrapperUtil.SelectListWrapper lm : languageMatrix)
			{
				String comboKey = CW_WizardBrandLabelUtil.createComboKey(lm.siteCat.Label__c, lm.siteCat.Product__c, null);
				if(lm.getNotNullSubObjectSize() <= 1 && countCountry.get(comboKey).size() <= 1)
				{
					lm.showRow = false;
				}
			}
		}*/

		// we will only show one row per label/product (for country non-specific)
		// but when saving we will reload all site catalogues
		// 2014-05-08 (KK): Product is now part of comboKey
		// this code has no effect for Country Specific but I'm living it in due to deadlines
		Boolean countrySpecific = campAsset.Asset__r.Asset_Type__r.Country_Specific__c;
		{
			// k: comboKey ; v: position in map
			Map<String,Integer> deDupMap = new Map<String,Integer>();	// save first match and it's location in map
			Integer matrixSize = languageMatrix.size();
			for(Integer i=0; i<matrixSize; i++)
			{
				WrapperUtil.SelectListWrapper lm = languageMatrix.get(i);
				String comboKey = CW_WizardBrandLabelUtil.createComboKey(lm.siteCat.Label__c,
																			lm.siteCat.Product__c,
																			(countrySpecific ? lm.siteCat.Country__c : null));

				if(!deDupMap.containsKey(comboKey))
				{
					deDupMap.put(comboKey,i);
				}
				else
				{
					WrapperUtil.SelectListWrapper lmMain = languageMatrix.get(deDupMap.get(comboKey));
					lmMain.subObjects = joinSelectLists(lmMain.subObjects,lm.subObjects);
					languageMatrix.remove(i);
					i--;
					matrixSize--;
				}
			}
		}

		// this is not the most effective way to do this, but it introduces minimal changes
	}

	/**/

	// mark combinations that already exists in the database
	public void markPreselected()
	{
		Set<String> siteCatLangSet = getSiteCatLangComboFromLocAssets();	// create combination of siteCat.Id_lang.Id_

		for(WrapperUtil.SelectListWrapper labelRow : languageMatrix)
		{
			for(WrapperUtil.SelectWrapper lang : labelRow.subObjects)
			{
				if(String.isNotBlank(lang.optionValue))
				{
					String comboKey = CW_WizardBrandLabelUtil.createComboKey(labelRow.siteCat.Id,(Id) lang.optionValue,null);
					lang.selected = siteCatLangSet.contains(comboKey);
				}
			}
		}
	}

	/**/

	// create combination of siteCat.Id_lang.Id_ from Localised Assets
	public Set<String> getSiteCatLangComboFromLocAssets()
	{
		Boolean countrySpecific = campAsset.Asset__r.Asset_Type__r.Country_Specific__c;
		// extract existing combinations from localised assets
		Set<String> siteCatLangSet = new Set<String>();	// create combination of siteCat.Id_lang.Id_
		for(CW_Localised_Asset__c la : locAssets)
		{
			String comboKey = CW_WizardBrandLabelUtil.createComboKey(la.Asset_Catalogue__r.Site_Catalogue__c, la.Language__c, null);
			siteCatLangSet.add(comboKey);
		}
		return siteCatLangSet;
	}

	/**/

	// use this to merge existing lists for various Site Catalogues under one superObject option
	// that one selection will be propagated to all of them on save
	public List<WrapperUtil.SelectWrapper> joinSelectLists(List<WrapperUtil.SelectWrapper> list1, List<WrapperUtil.SelectWrapper> list2)
	{
		if(list1.size() != list2.size())
		{
			return list1;
		}
		List<WrapperUtil.SelectWrapper> retList = new List<WrapperUtil.SelectWrapper>();
		Integer listSize = list1.size();
		for(Integer i=0; i<listSize; i++)
		{
			WrapperUtil.SelectWrapper sw = list1.get(i).optionValue != null ? list1.get(i) : list2.get(i);
			sw.selected = list1.get(i).selected || list2.get(i).selected;
			retList.add(sw);
		}
		return retList;
	}

	/**/

	// save and delete in one method as I'm trying to speed it up and save on resources
	public void applySelection()
	{
		update campAsset;

		processSelection();	// expand matrix so lang selection exists per site catalogue record i.e. load all site catalogues

		// now that all the selections are sorted we can look up the asset catalogues

		Set<String> existingSiteCatLangSet = getSiteCatLangComboFromLocAssets();	// create combination of siteCat.Id_lang.Id_ from locAsst
		Set<String> selectedSiteCatLangSet = new Set<String>();	// create combination of siteCat.Id_lang.Id_ based on languageMatrix
		Set<Id> siteCatIds = new Set<Id>();	// all selected site cats

		for(WrapperUtil.SelectListWrapper lm : languageMatrix)
		{
			for(WrapperUtil.SelectWrapper lang : lm.subObjects)
			{
				if(lang.selected)
				{
					String comboKey = CW_WizardBrandLabelUtil.createComboKey(lm.siteCat.Id, (Id) lang.optionValue, null);
					selectedSiteCatLangSet.add(comboKey);
					siteCatIds.add(lm.siteCat.Id);
				}
			}
		}

		//*** create localised assets
		{
			// now create those which are selected but don't already exist
			Set<String> newSiteCatLangSet = new Set<String>();
			newSiteCatLangSet.addAll(selectedSiteCatLangSet);
			newSiteCatLangSet.removeAll(existingSiteCatLangSet);

			List<CW_Localised_Asset__c> insertLocAsset = new List<CW_Localised_Asset__c>();
			{
				List<CW_Site_Catalogue__c> siteCatsAsset
					= CW_WizardCampaignAssetUtil.selectSiteCatsForLocAsset(campAsset.Campaign__c,campAsset.Asset__c,siteCatIds);
				for(CW_Site_Catalogue__c siteCat : siteCatsAsset)
				{
					for(CW_Asset_Catalogue__c assetCat : siteCat.Asset_Catalogues__r)
					{
						for(CW_Campaign_Sites__c campSite : siteCat.Campaign_Sites__r)
						{
							String comboKey = CW_WizardBrandLabelUtil.createComboKey(siteCat.Id,campSite.Language__c,null);
							if(newSiteCatLangSet.contains(comboKey))
							{
								insertLocAsset.add(new CW_Localised_Asset__c(Campaign_Asset__c = campAsset.Id,
																				Language__c = campSite.Language__c,
																				Asset_Catalogue__c = assetCat.Id));
							}
						}
					}
				}
			}

			insert insertLocAsset;
		}

		//*** remove localised assets
		{
			Set<String> delSiteCatLangSet = new Set<String>();
			delSiteCatLangSet.addAll(existingSiteCatLangSet);
			delSiteCatLangSet.removeAll(selectedSiteCatLangSet);

			List<CW_Localised_Asset__c> deleteLocAsset = new List<CW_Localised_Asset__c>();
			for(CW_Localised_Asset__c la : locAssets)
			{
				String comboKey = CW_WizardBrandLabelUtil.createComboKey(la.Asset_Catalogue__r.Site_Catalogue__c,la.Language__c,null);
				if(delSiteCatLangSet.contains(comboKey))
				{
					deleteLocAsset.add(la);
				}
			}
			delete deleteLocAsset;
		}
	}

	/**/

	// match selections to site catalogues - see createLanguageMatrix() for explanation
	public void processSelection()
	{
		Boolean countrySpecific = campAsset.Asset__r.Asset_Type__r.Country_Specific__c;
		Map<String,List<WrapperUtil.SelectWrapper>> langPerCombo = new Map<String,List<WrapperUtil.SelectWrapper>>();

		// find rows holding the user selection - selection will apply to all siteCatalogues holding the combo
		for(WrapperUtil.SelectListWrapper comboRow : languageMatrix)
		{
			String comboKey =
				CW_WizardBrandLabelUtil.createComboKey(
					comboRow.siteCat.Label__c,comboRow.siteCat.Product__c,(countrySpecific ? comboRow.siteCat.Country__c : null));
			langPerCombo.put(comboKey,comboRow.subObjects.clone());
		}

		// reload matrix with all available options
		languageMatrix = WrapperUtil.createObjectWrapperList(cmpSites, languageColumns, ConstantUtil.CW_CS_REL_SITECATALOGUE,
																ConstantUtil.CW_CS_REL_LANGUAGE, ConstantUtil.SOBJECT_NAME,
																ConstantUtil.SOBJECT_ID, ConstantUtil.SOBJECT_ID);

		// now pair other, hidden rows with the selection
		for(WrapperUtil.SelectListWrapper siteCatRow : languageMatrix)
		{
			String comboKey =
				CW_WizardBrandLabelUtil.createComboKey(
					siteCatRow.siteCat.Label__c,siteCatRow.siteCat.Product__c,(countrySpecific ? siteCatRow.siteCat.Country__c : null));
			if(langPerCombo.containsKey(comboKey))	// this will avoid messing up single country labels
			{
				siteCatRow.subObjects = langPerCombo.get(comboKey);
			}
		}
	}

	/**/

	public List<CW_Campaign_Sites__c> filterSiteCatsByAsset(List<CW_Campaign_Sites__c> cmpSites)
	{
		Set<Id> siteCatIds = new Set<Id>();
		for(CW_Campaign_Sites__c cs : cmpSites)
		{
			//add id to the set only id the id hasnt been added previously
			if (!siteCatIds.contains(cs.Site_Catalogue__c))
				siteCatIds.add(cs.Site_Catalogue__c);
		}
		// find all site cats which have an asset cat
		{
			List<CW_Site_Catalogue__c> siteCatsAsset
				= CW_WizardCampaignAssetUtil.selectSiteCatsForLocAsset(campAsset.Campaign__c,campAsset.Asset__c,siteCatIds);

			for(CW_Site_Catalogue__c sc : siteCatsAsset)
			{
				//add id to the set only id the id hasnt been added previously
				if (!siteCatIds.contains(sc.Id))
					siteCatIds.add(sc.Id);
			}
		}

		// remove any site cats from the list
		Integer listSize = cmpSites.size();
		for(Integer i = 0; i < listSize; i++)
		{
			if(!siteCatIds.contains(cmpSites.get(i).Site_Catalogue__c))
			{
				cmpSites.remove(i);
				i--;
				listSize--;
			}
		}

		return cmpSites;
	}

	/**/

	public CW_Campaign_Asset__c findCampAsset(Id campAssetStringId)
	{
		CW_Asset__c asst = [select Asset__r.Name, Asset__r.Asset_Type__c, Asset__r.Asset_Type__r.Name, Asset__r.Asset_Type__r.Country_Specific__c,Campaign__c
							from CW_Campaign_Asset__c where id = :campAssetStringId].Asset__r;
		fieldSetDV = CW_WizardCampaignAssetUtil.getDetailViewFieldSet(asst.Asset_Type__r.Name);

		List<Schema.FieldSetMember> queryFieldSet = new List<Schema.FieldSetMember>();
		queryFieldSet.addAll(CW_WizardCampaignAssetUtil.getCampaignAssetDefaultFieldSet());
		queryFieldSet.addAll(fieldSetDV);
		CW_Campaign_Asset__c ca = (CW_Campaign_Asset__c) FieldSetUtil.queryViaFieldSet(
										queryFieldSet, Schema.sObjectType.CW_Campaign_Asset__c.Name, 'Id = \''+campAssetStringId+'\'').get(0);
		ca.Asset__r = asst;	// populate object
		return ca;
	}

	/**/

	public Boolean getMessagingAvailable()
	{
		return msgFields != null && !msgFields.isEmpty();
	}

	/**/

	public void addNewMessaging()
	{
		msgList.add(new CW_Messaging__c(Campaign_Asset__c = campAsset.id,Campaign__c = campAsset.Campaign__c));
	}

	/**/

	// adding new asset if last list member has empty id
	public Boolean getIsAddMode()
	{
		return !msgEditMode && !msgList.isEmpty() && msgList.get(msgList.size()-1).id == null;
	}

	/**/

	public void inlineEdit()
	{
		initOldMsgMap();
		msgEditMode = true;
	}

	/**/

	public Boolean getShowInlineEditButton()
	{
		return !msgList.isEmpty();
	}

	/**/

	public void saveEdit()
	{
		try{
			if(msgEditMode || getIsAddMode())	// these two can never be both true!
			{
				update campAsset;
				newMsgMap = new Map<Id,CW_Messaging__c>();
				recInApproval = new List<String>();
				List<String> recsSaved = new List<String>();
				List<CW_Messaging__c> recordsToSave = new List<CW_Messaging__c>();
				set<String> currentFieldSet = getFields();

				// marking approval_status to 'Not Submitted' when it is first created
				 for(CW_Messaging__c la:msgList)
					{
						if( la.Approval_Status__c=='' || la.Approval_Status__c==null){
						    la.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED;
						}
					 }

				List<CW_Messaging__c> modifeidMsg = msgEditMode ? msgList : new List<CW_Messaging__c>{msgList.get(msgList.size()-1)};

				String errorMsg = '';
				for(CW_Messaging__c msg : modifeidMsg)
				{
					newMsgMap.put(msg.Id,msg);
					errorMsg += FieldSetUtil.checkRequiredFieldsFS(msg, msgFields);
				}
				if(String.isNotBlank(errorMsg))
				{
					Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));
					return;
				}

				if (msgEditMode)
				{
					for (CW_Messaging__c curr: oldMsgMap.values())
					{
						CW_Messaging__c msgUpdated=newMsgMap.get(curr.Id);
						// Marking approval status to 'Not submitted' when dispatch date is changed by requestor
						if(campAsset.Asset__r.Asset_Type__r.Name==ConstantUtil.ASSET_TYPE_NAME || campAsset.Asset__r.Asset_Type__r.Name==ConstantUtil.SMS_ASSET_TYPE_NAME) 
						{ 
						   if(msgUpdated.Dispatch_Date__c!=curr.Dispatch_Date__c || msgUpdated.Target_Instructions__c!=curr.Target_Instructions__c)
							{
								msgUpdated.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED;
								recordsToSave.add(newMsgMap.get(curr.Id));
								recsSaved.add(curr.Name);
							}
						}
						else if(campAsset.Asset__r.Asset_Type__r.Name==ConstantUtil.TEASER_ASSET_TYPE_NAME)
						{ 
							if(msgUpdated.Live_Date__c!=curr.Live_Date__c ||  msgUpdated.End_Date__c!=curr.End_Date__c || msgUpdated.Label__c!=curr.Label__c)
							{
								msgUpdated.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED;
								recordsToSave.add(newMsgMap.get(curr.Id));
								recsSaved.add(curr.Name);
							}
						}
					}
					if (!recordsToSave.isEmpty())
					{
						if(validateMessagingLabel(recordsToSave)==null)
						{
							update recordsToSave;
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, recsSaved + ConstantUtil.RECORDS_SAVED));
							
						}
						else
							ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,errorMessage));
					}
				}
				else if (getIsAddMode())
				{

					if (validateMessagingLabel(newMsgMap.values())==null)
					{
						
						upsert modifeidMsg;
						//query for all fields after upsert
						msgList = UpdatedMsgList(campAsset.Id);
					}
					else
						ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,errorMessage));
				}
				
				if(!ApexPages.hasMessages(ApexPages.Severity.ERROR))
					msgEditMode = false;
			}
		}catch(Exception Ex){
			ApexPages.addMessages(Ex);
		}

	}

	/**/

	public void cancelEdit()
	{
		if(msgEditMode)
		{
			msgEditMode = false;
		}
		else
		{
			if(getIsAddMode())
			{
				msgList.remove(msgList.size()-1);	// last element is the new one
			}
		}
	}

	/**/

	public void deleteMsg()
	{
		initOldMsgMap();
		if(deleteMsgId != null && oldMsgMap.get(deleteMsgId)!=null && oldMsgMap.get(deleteMsgId).Approval_Status__c!=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL)
		{
			delete [select id from CW_Messaging__c where id = :deleteMsgId];
			deleteMsgId = null;
			initMessaging();
			removingMessagingApprovalStatusSummaryFromCampaign(ConstantUtil.ASSET_TYPE_NAME);
			removingMessagingApprovalStatusSummaryFromCampaign(ConstantUtil.TEASER_ASSET_TYPE_NAME);
			removingMessagingApprovalStatusSummaryFromCampaign(ConstantUtil.SMS_ASSET_TYPE_NAME);
		}
		else
		{
			if(oldMsgMap.get(deleteMsgId)!=null)
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oldMsgMap.get(deleteMsgId).Name + ' ' + ConstantUtil.RECORDS_IN_APPROVAL));
			else
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  ConstantUtil.RECORDS_IN_APPROVAL));
		}
	}

	/*  empty out messaging & mailer approval status fields from Campaign object when there are no messaging records*/
	private void removingMessagingApprovalStatusSummaryFromCampaign(String assetType)
	{
		List<CW_Messaging__c> listNew= [SELECT Id,Name, Campaign__c	  FROM CW_Messaging__c  WHERE Campaign__c =:  campAsset.Campaign__c and Campaign_Asset__c in :campaignAssetTypeIdSet(assetType)];
		Integer count=listNew.size();
		if(count==0)
		{
			List<CW_Campaign_Asset__c> campAssetList=[SELECT Id,Name,Date_Approval_Summary__c from CW_Campaign_Asset__c where Id in :campaignAssetTypeIdSet(assetType)];
			for(CW_Campaign_Asset__c campAsset : campAssetList)
			{
		  		campAsset.Date_Approval_Summary__c='';
			}
			update campAssetList;

			List<CW_Campaign__c> cmpList= [SELECT Id,Name, Messaging_Approval_Status__c,
												  Mailer_Messaging_Approval_Status__c,Teaser_Messaging_Approval_Status__c,
												  SMS_Messaging_Approval_Status__c
										   FROM CW_Campaign__c
										   WHERE Id =:  campAsset.Campaign__c];
			for(CW_Campaign__c cmp : cmpList)
			{
				cmp.Messaging_Approval_Status__c='';
				if(assetType==ConstantUtil.ASSET_TYPE_NAME)
					cmp.Mailer_Messaging_Approval_Status__c='';
				else if(assetType==ConstantUtil.TEASER_ASSET_TYPE_NAME)
				 	cmp.Teaser_Messaging_Approval_Status__c='';
				else if(assetType==ConstantUtil.SMS_ASSET_TYPE_NAME)
					cmp.SMS_Messaging_Approval_Status__c='';
			}
			update cmpList;
		}
	}

	//get all the field from fieldset
	public Set<String> getFields() {
		Set<String> fnames = new set<string>();

		for(Schema.FieldSetMember f : msgFields) {
           fnames.add(f.getFieldPath());
    	}
       return fnames;

    }

    //query all the fields before editing the table
    public void initOldMsgMap()
    {
    	oldMsgMap = new Map<Id,CW_Messaging__c>();
		for (CW_Messaging__c curr : [SELECT Id,Name, Dispatch_Date__c,Target_Instructions__c,
											Label__c, Live_Date__c,Old_dispatch_date__c,Old_live_date__c,Old_end_date__c,
											End_Date__c,Approval_Status__c,
											Campaign__c
									 FROM CW_Messaging__c
									 WHERE Campaign_Asset__c =: campAsset.Id])
		{
			oldMsgMap.put(curr.Id,curr);
		}
    }

    public String getRetUrl()
    {
    	String retUtl = Page.CW_Assets.getUrl();
    	retUtl += '?';
    	retUtl += ConstantUtil.PAGEPARAM_CAMPAIGNID + '=' + campAsset.Campaign__c;
    	retUtl += '&';
    	retUtl += ConstantUtil.PAGEPARAM_ID + '=' + campAsset.Campaign__c;
    	retUtl += '&';
    	retUtl += ConstantUtil.PAGEPARAM_ASSETTAB + '=' + campAsset.Asset__r.Asset_Type__c;
    	return retUtl;
    }


	/********************************/
	/***********STATIC***************/
	/********************************/

	/**/

	public static List<CW_Localised_Asset__c> selectLocalisedAssets(Id campAssetId)
	{
		return [select id, Name,
				Asset_Catalogue__c,
				Asset_Catalogue__r.Site_Catalogue__c,
				Asset_Catalogue__r.Site_Catalogue__r.Label__c,
				Asset_Catalogue__r.Site_Catalogue__r.Product__c,
				Asset_Catalogue__r.Site_Catalogue__r.Country__c,
				Language__c
				from CW_Localised_Asset__c
				where Campaign_Asset__c = :campAssetId];
	}

	/**/

	public static List<CW_Campaign_Sites__c> selectCampaignSitesLPC(Id campaignId)
	{
		return [select id,
				Name,
				Language__c,
				Language__r.Name,
				Site_Catalogue__c,
				Site_Catalogue__r.Name,
				Site_Catalogue__r.Country__c,
				Site_Catalogue__r.Country__r.Name,
				Site_Catalogue__r.Label__c,
				Site_Catalogue__r.Label__r.Name,
				Site_Catalogue__r.Product__c,
				Site_Catalogue__r.Product__r.Name
				from CW_Campaign_Sites__c
				where Campaign__c = :campaignId and Site_Catalogue__r.Is_Active__c = true
				order by Site_Catalogue__r.Label__r.Brand__r.Name asc,
					Site_Catalogue__r.Label__r.Name asc,
					Site_Catalogue__r.Product__r.Name asc,
					Site_Catalogue__r.Country__r.Name asc
		];
	}

	/**/

	// find available asset types based on campaign sites
	public static List<CW_Asset_Type__c> selectAvailableAssetTypes(Id campaignId, Set<Id> siteCatIds)
	{
		List<CW_Asset_Type__c> retList = new List<CW_Asset_Type__c>();

		AggregateResult[] groupedResults = [select count(Id),
												Asset__r.Asset_Type__c aTypeId,
												Asset__r.Asset_Type__r.Name aTypeName
											from CW_Asset_Catalogue__c
											where Site_Catalogue__c in :siteCatIds
											group by Asset__r.Asset_Type__c,
												Asset__r.Asset_Type__r.Name
											order by Asset__r.Asset_Type__r.Name asc]; // order by not to be removed, will break code

		for(AggregateResult gr : groupedResults)
		{
			// populate object as aggregate query can't fetch relationship field
			CW_Asset_Type__c assetType = new CW_Asset_Type__c();
			assetType.Id = (Id) gr.get('aTypeId');
			assetType.Name = (String) gr.get('aTypeName');

			// avoid duplicates, list sorted by name anyway
			if(retList.isEmpty() || retList.get(retList.size()-1).Id != assetType.Id)
			{
				retList.add(assetType);
			}
		}
		return retList;
	}

	public String validateMessagingLabel(List<CW_Messaging__c> msgsList)
	{
		//We are returning null if asset type is Mailer since this section is applicable to Mailer
		if( campAsset.Asset__r.Asset_Type__r.Name==ConstantUtil.TEASER_ASSET_TYPE_NAME)
		{
			assetLabelsSelected = new set<String>();
			for (WrapperUtil.SelectListWrapper slw:  languageMatrix)
			{
				for (WrapperUtil.SelectWrapper sw: slw.subObjects)
				{
					if (sw.selected)
						assetLabelsSelected.add(slw.siteCat.Label__c);
				}
			}

			for (CW_Messaging__c msg : msgsList)
			{
				if (msg.Label__c!=null && !assetLabelsSelected.contains(msg.Label__c))
					errorMessage = ConstantUtil.CAMP_ASSET_LABEL_ERROR;
				else
					errorMessage = null;
			}
		}
		return errorMessage;
	}

	//B-129707-Handle Asset Messaging Object
	public void handleAssetMessagingLabell(List<CW_Messaging__c> msgsList)
	{
		//We are returning null if asset type is Mailer since this section is not applicable to Mailer
		if( campAsset.Asset__r.Asset_Type__r.Name==ConstantUtil.TEASER_ASSET_TYPE_NAME)
		{
			assetLabelsSelected = new set<String>();

			for (WrapperUtil.SelectListWrapper slw:  languageMatrix)
			{
				for (WrapperUtil.SelectWrapper sw: slw.subObjects)
				{
					if (sw.selected)
						assetLabelsSelected.add(slw.siteCat.Label__c);
				}
			}
			List<CW_Messaging__c> toDeleteList=new List<CW_Messaging__c>();
			for (CW_Messaging__c msg : msgsList)
			{
				if (msg.Label__c!=null && !assetLabelsSelected.contains(msg.Label__c))
				{
					toDeleteList.add(msg);
				}
			}
			delete toDeleteList;
			removingMessagingApprovalStatusSummaryFromCampaign(ConstantUtil.TEASER_ASSET_TYPE_NAME); //to emptyout related summary fields once message gets deleted
		}
	}

	 private Set<Id> campaignAssetTypeIdSet(String assetType)
	 {
		Set<Id> assetIdSet=new Set<Id>();
		List<CW_Asset_Type__c> asset=[select Name from CW_Asset_Type__c where  name=:assetType];
		if(asset!=null && asset.size()>0)
		{
			List<CW_Campaign_Asset__c> asst = [select Id from CW_Campaign_Asset__c where Asset__r.Asset_Type__c in :asset];
			for (CW_Campaign_Asset__c campAsset : asst)
			{
				assetIdSet.add(campAsset.Id);
			}
		}
	  return assetIdSet;
	 }
	 
	 //get all messaging records fields after upsert
	 public List<CW_Messaging__c> UpdatedMsgList(Id campAssetId)
	 {
	 	return [SELECT Id,Name, Dispatch_Date__c,Target_Instructions__c,
					   Label__c, Live_Date__c,Old_dispatch_date__c,Old_live_date__c,Old_end_date__c,
					   End_Date__c,Approval_Status__c,
					   Campaign__c
			 	FROM CW_Messaging__c
			 	WHERE Campaign_Asset__c =: campAssetId];
	 }
}