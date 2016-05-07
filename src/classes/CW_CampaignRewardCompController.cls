/**
* File Name   :    CW_CampaignRewardCompController.cls
* Description :    B-109691 - Reward Summary Table 
*				   that are linked to the campaign 
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 07/05/2014 Alex Panka	  Intial  
* 0.2 08/05/2014 Chris Yorkston added method updateRewardWithFreebetId() to 
*                               retreive Freebet Id from Apex Callout (HTTP)
* 0.3 20/07/2014 Cristina P.	B-122940 Campaign Reward - Many Rewards per Trigger
*/
 
public with sharing class CW_CampaignRewardCompController {
	public enum ControlerStatus {View, Edit, NEWREC, Library}
//Local Variables to store data
	
	/* set controller variables */
	public Id			campId;
	public Integer     pageSize; 
	
	public Id			campOfferId {get;set;}
	public Set<Id>      selectedRewardIds;
	public String 		contextItem {get;set;}
	public String		fieldsetName;
	public Boolean 		isMockAPI;

	public Boolean		selectAll {get;set;}
	public Boolean		isReadOnly {get; set;}
	public Id       	rewardTypeId {get; set;}
	public Id			offerTypeId {get;set;}
	public Set<Id>		availableRewardTypes;
	public Boolean		createLibrary {get;set;}
	public Boolean		showLibrary {get;set;}
	public Boolean		hasLibrary {get; set;}
	
	/*reward navigation variable*/
	public Boolean		hasFirstPage {get;set;}
	public Boolean		hasLastPage {get;set;}
	public Decimal 		pages;
	
	/* buttons variables */
	
	public  Boolean		getDeleteDisabled() {return  selectedRewardIds.Size()==0;}
	
	public ApexPages.StandardSetController 	RewardStdSetCtrl;
	public ControlerStatus					CntrlState {get;private set;}
	public CW_Campaign_Reward__c           	newRec {get;set;}
	public CW_Campaign_Offer__c				campOffer{get;set;}
	public CW_Reward_Library__c				newLibrary {get;set;}
	public List<selectOption> 				libraryRewards {get; set;}	
	public Set<String> 						fieldsName; 
	
	/* view mode variables */
	//disable all button when user adds or eddits new reward or library
	public  Boolean	disabledButtons 
	{
		get
		{
			return CntrlState!=ControlerStatus.VIEW;
		}
	}
	
	//display field in edit mode when user can edit fields
	public  Boolean editMode
 	{ 
 		get
 		{
 			return CntrlState==ControlerStatus.Edit;
 		}
 	}
 	
 	//display new table when creating new reward
 	public  Boolean NewRecMode
	{ 
		get
		{
			return CntrlState==ControlerStatus.NewRec;
		}
	}
	 
	public Boolean savedByParent
	{
		get{return false;}
		set{ if( value==true)  CntrlState=ControlerStatus.View;}
	}
	
		
	public  Decimal	totalSize 
	{
		get
		{
			if( this.RewardStdSetCtrl==null) 
				return 0; 
			return this.RewardStdSetCtrl.getResultSize();
		}
	}
	
	public CW_CampaignRewardCompController()
	{
		campId = Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_ID);
		CntrlState=ControlerStatus.VIEW;
		selectedRewardIds= new Set<Id>();
		newRec= new CW_Campaign_Reward__c();
		newLibrary = new CW_Reward_Library__c();
		init();
	}
	
	public String getInit()
	{
		init();
		return '';
	}
	
	public void init()
	{
		String mockParam = ApexPages.currentPage().getParameters().get('mock');
        isMockAPI = (mockParam!=null&&mockParam=='true') ? true : false;
		//set the data display mode
		pageSize=CW_CampaignListSettingHelper.getIntegerValue(ConstantUtil.AUDIENCE_GROUP_PAGE_SIZE,10);
      	selectAll = false;
      	selectedRewardIds.clear();
      	
      	this.RewardStdSetCtrl= new ApexPages.StandardSetController(getRewardsInfo(campOfferId));
		this.RewardStdSetCtrl.setpageNumber(1);
		this.RewardStdSetCtrl.setPageSize(pagesize);
		campOfferOrRewardHasLibrary();
	}
	
	//query all campaign rewards already created for the selected campaign offer
	public List<CW_Campaign_Reward__c> getRewardsInfo(Id campOfferId)
	{
		List<CW_Campaign_Reward__c> rewards = [SELECT Name, Campaign_Offer__c,
													  Reward_Catalogue__c,
													  Reward_Library__c,
													  Reward_Library__r.Freebet_Name__c,
													  Reward_Library__r.Freebet_ID__c,
													  Code__c, Bonus_Id__c,
													  Amount__c,
													  Currency__c,
													  Reward_Catalogue__r.Offer_Type__r.Name,
													  Reward_Type__r.Name, Reward_Type__c,
													  Reward_Catalogue__r.Library__c
											   FROM CW_Campaign_Reward__c
											   WHERE Campaign_Offer__c =: campOfferId 
											   ORDER BY CreatedDate desc];
		return rewards;
	}
	
	//get campaign offer fields from fieldset depending on selected offer type
    public List<Schema.FieldSetMember> getFields()
    {
    	if (offerTypeId!=null && rewardTypeId!=null)
	        getFieldsetName(offerTypeId,rewardTypeId);
	        Map<String,Schema.FieldSet> fieldSets = SObjectType.CW_Reward_Library__c.FieldSets.getMap();

	        if(fieldSets.containsKey(fieldsetName))
	            return SObjectType.CW_Reward_Library__c.FieldSets.getMap().get(fieldSetName).getFields();
	        else
	           return SObjectType.CW_Reward_Library__c.FieldSets.Default_Fieldset.getFields();
    }
    
    //return fieldset name based on trigger type and reward type
    public String getFieldsetName(Id offerTypeId, Id rewardTypeId)
    {
       	CW_Reward_Catalogue__c rewardCatalogue = new CW_Reward_Catalogue__c();
        
        rewardCatalogue = [SELECT Id, Offer_Type__r.Name, Reward_Type__r.Name FROM CW_Reward_Catalogue__c WHERE Offer_Type__c =: offerTypeID AND Reward_Type__c =: rewardTypeId];
                        
        fieldSetName = rewardCatalogue.Offer_Type__r.Name + rewardCatalogue.Reward_Type__r.Name + ConstantUtil.CAMPAIGN_OFFER_FS_SUFFIX;
        fieldSetName = fieldSetName.replaceAll( '\\s+', '');
        fieldSetName = fieldSetName.replaceAll( '_', '');
        return fieldSetName;
    }
    
    //get all fields from fieldset when creating reward library
    public Set<String> getLibraryFieldName() 
    {
		fieldsName = new set<string>();         
    	
    	for(Schema.FieldSetMember f : getFields()) 
    	{
           fieldsName.add(f.getFieldPath());
    	}
       	return fieldsName; 
    }
	
	//Wrapper class that represents a row
	public with sharing class rewardWrapper
    {
		public CW_Campaign_Reward__c 	rec{get;set;}
		public Boolean					rewLibrary {get; set;}
		public Boolean 				 	isSelected{get;set;}
		
		public Id						recordId 
		{
			get {
				if (recordId==null)
					recordId = rec.Reward_Type__c;
				return recordId;
			}	
			set{
				recordID = value;
				rec.Reward_Type__c = recordId;
			}
		}
	
		public rewardWrapper(CW_Campaign_Reward__c r, Boolean l, Boolean s)
		{
			this.rec=r;
			this.rewLibrary = l;
			this.IsSelected=s;
		}
	}
	
	//get reward list to populate reward table
	public List<rewardWrapper> 	getRewardList() 
	{
		List<rewardWrapper> RewardWraperList = new List<rewardWrapper>();
		if (this.RewardStdSetCtrl!=null)
		{
			for(sObject r : this.RewardStdSetCtrl.getRecords())
			{
				CW_Campaign_Reward__c rec = (CW_Campaign_Reward__c)r;
				rewardWrapper Reward = new rewardWrapper(rec,true,this.selectedRewardIds.contains(rec.Id));
				if (rec.Reward_Catalogue__r.Library__c)
					Reward.rewLibrary = true;
				else 
					Reward.rewLibrary = false;
				RewardWraperList.add(Reward);
			}
		}
		return RewardWraperList;
	}
	
	//display all reward types available for selected offer type 
	public List<selectOption> getRewardTypeOptions()
    {
        List<selectOption> options = new List<selectOption>{new selectOption('','')};
        availableRewardTypes = new set<Id>();
        for(CW_Reward_Catalogue__c curr : [SELECT Reward_Type__c,Reward_Type__r.Name FROM CW_Reward_Catalogue__c WHERE Offer_Type__c =: offerTypeId])
        {
             options.add(new selectOption(curr.Reward_Type__c,curr.Reward_Type__r.Name));
             availableRewardTypes.add(curr.Reward_Type__c);
        }
        return options;
    }
    
    //display all reward types available for selected offer type 
	public List<selectOption> RewardTypeForLibraryOptions()
    {
        List<selectOption> options = new List<selectOption>();
        for(CW_Reward_Catalogue__c curr : [SELECT Reward_Type__c,Reward_Type__r.Name FROM CW_Reward_Catalogue__c WHERE Offer_Type__c =: offerTypeId AND Library__c = true])
        {
             options.add(new selectOption(curr.Reward_Type__c,curr.Reward_Type__r.Name));
        }
        return options;
    }
    
    //select reward catalogue
    public CW_Reward_Catalogue__c getRewardCatalogue(Id offerTypeId,Id rewardTypeId)
    {
        CW_Reward_Catalogue__c rewardCat = [SELECT Id,Offer_Type__c, Reward_Type__c, Reward_Type__r.Name 
					                    	  FROM CW_Reward_Catalogue__c 
					                    	  WHERE Offer_Type__c=: offerTypeId
					                    	  AND Reward_Type__c =: rewardTypeId];
                         
        return rewardCat;
    }
    
    //check if offer type has library creation available and if campaign reward has library linked to it
    public Boolean campOfferOrRewardHasLibrary()
    {
		if (rewardTypeId!=null && offerTypeId!=null) 
		{   	
	    	hasLibrary = [SELECT Id,Offer_Type__c, Reward_Type__c,Library__c 
	                    	  	  FROM CW_Reward_Catalogue__c 
	                    	  	  WHERE Offer_Type__c=: offerTypeId
	                    	  	  AND Reward_Type__c =: rewardTypeId].Library__c;
			return hasLibrary;
		}
	    else if (offerTypeId!=null)
		{
			List<CW_Reward_Catalogue__c> rewCat = [SELECT Id,Offer_Type__c, Reward_Type__c,Library__c 
					                    	  	  FROM CW_Reward_Catalogue__c 
					                    	  	  WHERE Offer_Type__c=: offerTypeId AND Library__c =: true];
			
			showLibrary = (rewCat.size()>0) ? true : false;
			return showLibrary;
		} 
			else return false;
        
    }
    
    //get reward library info
    public CW_Reward_Library__c getRewardLibraryInfo(Id rewardLibraryId)
    {
    	return [SELECT ID, FreeBet_Name__c, FreeBet_Id__c, Amount__c, Currency__c FROM CW_Reward_Library__c WHERE ID=: rewardLibraryId];
    }
    
    public Boolean checkAllRequiredFields()
    {
    	Boolean passed = false;
    	//loop though all required fields and if any of them is null return false
    	for (String curr: getLibraryFieldName())
		{
			passed = (newLibrary.get(curr)!=null) ? true : false; 
		}
		return passed;
    }
    
    // Apex Callout - Promo API - Freebet creation
    public void updateRewardWithFreebetId() 
    {
        // select endpoint setting name
        String apexCalloutSettingName = (isMockAPI) ? ConstantUtil.APEX_CALLOUT_PROMO_API_FREEBET_CREATION_MOCK : ConstantUtil.APEX_CALLOUT_PROMO_API_FREEBET_CREATION_QA;
        RESTfulCalloutPromoAPI calloutPromoAPI = new RESTfulCalloutPromoAPI(apexCalloutSettingName);
        String freebetId = calloutPromoAPI.getFreebetId(campId, newLibrary, getRewardCatalogue(offerTypeId,newLibrary.Reward_Type__c));
        newLibrary.FreeBet_Id__c = freebetId;
    }
    
	
	/*							*/
	/*   BUTTONS FUNCTIONALITY  */
	/*							*/
	
	//create new group
	public void addReward()
	{
		CntrlState = ControlerStatus.NewRec;
		newrec= new CW_Campaign_Reward__c(Campaign_Offer__c = campOfferId,Reward_Type__c = getDefaultRTId('Cash'));
	}
	
	//save new reward
	public void SaveNewRecord()
	{
		newrec.Reward_Type__c = rewardTypeId;
		if (String.isNotBlank(newrec.Reward_Type__c))
		{
			//display error message if amount or currency field are left black
			if ((newrec.Amount__c ==null || !String.isNotBlank(newRec.Currency__c)) && !hasLibrary)
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ConstantUtil.REWARD_AMOUNT_CURRENCY_REQUIRED));
			else if (hasLibrary && !String.isNotBlank(newrec.Reward_Library__c))
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ConstantUtil.REWARD_WITHOUT_LIBRARY));
			else
			{
				try{
					Insert newrec;
					Init();
					CntrlState=ControlerStatus.View;
					rewardTypeId = null;
				}catch (Exception ex){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ConstantUtil.REWARD_NOT_SAVED + ': ' + ex));
				}
			}
		}
		else
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ConstantUtil.REWARD_TYPE_MISSING));
		
	}
	
	
	//save all changes made inline edit
	public void saveAllRecords()
	{
		List<CW_Campaign_Reward__c> recordsToUpdate = new List<CW_Campaign_Reward__c>();
		CW_Reward_Library__c rewLibrary = new CW_Reward_Library__c();
		getRewardTypeOptions();
		for (rewardWrapper curr : getRewardList())
		{
			//if library has been selected replace Reward code, reward id, amount, currency with freebet code and freebet id from Reward Library
			if (curr.rec.Reward_Library__c!=null)
			{
				if (rewLibrary.Id==null || rewLibrary.Id!= curr.rec.Reward_Library__c)  rewLibrary = getRewardLibraryInfo(curr.rec.Reward_Library__c);
				curr.rec.Code__c = rewLibrary.FreeBet_Name__c;
				curr.rec.Bonus_ID__c = rewLibrary.FreeBet_Id__c;
				curr.rec.Currency__c = rewLibrary.Currency__c;
				curr.rec.Amount__c = rewLibrary.Amount__c;
			}
			else if(curr.rewLibrary)
			{
				//stop user save the reward that requires library without a library
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ConstantUtil.REWARD_SAVED_WITHOUT_REWARD_LIBRARY));
				break;
			}
			recordsToUpdate.add(curr.rec);
		}
		
		if (!recordsToUpdate.IsEmpty())
		{
			try 
			{
				//stop user saving the reward if there are any error	
				if (!ApexPages.hasMessages(ApexPages.Severity.ERROR))
				{
					update recordsToUpdate;
					init();
					CntrlState=ControlerStatus.View;
				}
			}
			catch(Exception ex)
			{
				ApexPages.addMessages(ex);
			} 	
			
		}		
	}
	
	//initiate reward library and add picklist default value
	public void createRewardLibrary()
	{
		CntrlState = ControlerStatus.Library;
		createLibrary = true;
		libraryRewards = RewardTypeForLibraryOptions();
		rewardTypeId = libraryRewards[0].getValue();
		newLibrary = new CW_Reward_Library__c();
	}
	
	//save library and create new campaign reward with the library created
	public void saveLibrary()
	{
		try 
		{
			newLibrary.Reward_Type__c = rewardTypeId;
			if (checkAllRequiredFields())
			{
				updateRewardWithFreebetId();
				insert newLibrary;
				newrec = new CW_Campaign_Reward__c(Campaign_Offer__c = campOfferId);
				newrec.Reward_Type__c = newLibrary.Reward_Type__c;
				newrec.Reward_Library__c = newLibrary.Id;
				newrec.Code__c = newLibrary.FreeBet_Name__c;
				newrec.Bonus_ID__c = newLibrary.FreeBet_Id__c;
				newrec.Amount__c = newLibrary.Amount__c;
				newrec.Currency__c = newLibrary.Currency__c;
				newrec.Reward_Catalogue__c = getRewardCatalogue(offerTypeId,newLibrary.Reward_Type__c).Id;
				insert newrec;
				init();
				createLibrary = false;
				//change to view mode after reward library and reward is created
				CntrlState = ControlerStatus.View;
			}	
			else
				//display error message when required fields are left blank
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.REWARD_LIBRARY_ALL_FIELDS_REQUIRED)); 	
		}
		catch(Exception ex)
		{
			ApexPages.addMessages(ex);
		} 
	}
	
	//update reward catalogue field
	public void updateRewardCat()
	{
		campOfferOrRewardHasLibrary();
		if(rewardTypeId!=null) 
		{
			newrec.Reward_Catalogue__c = getRewardCatalogue(offerTypeId,rewardTypeId).Id;
			newrec.Reward_Type__c = rewardTypeId;
		}
	}
	
	//inline edit 
	public void editRewards()
	{
		CntrlState=ControlerStatus.Edit;
	}
	
	//delete selected records 
	public void deleteRewards()
	{
		
		if(selectedRewardIds.Size()==0)
			return;
		List<CW_Campaign_Reward__c> objectToDelete = new List<CW_Campaign_Reward__c>();
		for (Id curr : selectedRewardIds)
		{
			objectToDelete.add(new CW_Campaign_Reward__c(Id = curr));	
		}
		//remove the selected group id from the set
		try 
    	{
			delete objectToDelete;
			this.selectedRewardIds.Clear();
			init();
    	}catch(Exception ex){
			ApexPages.addMessages(ex);
		}
	}
	
	//cancel action
	public void Cancel(){
		CntrlState=ControlerStatus.View;
		createLibrary = false;
	}
	
	/*										*/
	/*   SELECT & DESELECT FUNCTIONALITY  	*/
	/*										*/

	//handle item selected
	public void doSelectItem()
	{
		this.selectedRewardIds.add(this.contextItem);
		//black the message after select so no duplicated groups are added

	}

	//handle item deselected
	public void doDeselectItem()
	{
		this.selectedRewardIds.remove(this.contextItem);
	}
	
	//handle all items selected
	public void selectDeselectAllItems()
	{
		for (sObject  curr : RewardStdSetCtrl.getRecords())
		{
			if (selectAll)
				this.selectedRewardIds.add(curr.Id);
			else
			{
				this.selectedRewardIds.remove(curr.Id);
				selectAll = false;
			}
		}
	}
	
	//deselect all groups
	public void resetCheckBoxes()
	{
		selectAll=false;
		this.selectedRewardIds.Clear();
	}
	
	/*								*/
	/*   NAVIGATION FUNCTIONALITY  	*/
    /*								*/
	
	//go to first page
	public void first()
	{
		this.RewardStdSetCtrl.first();
		getHasFirstAndLast();
	}
	
	//go to last page
	public void last()
	{
		this.RewardStdSetCtrl.last();
		getHasFirstAndLast();
	}
	
	//advance to next page
	public void doNext()
	{
		if(this.RewardStdSetCtrl.getHasNext())
		{
			this.RewardStdSetCtrl.next();
			getHasFirstAndLast();
			resetCheckBoxes();
		}
	}

 	//advance to previous page
 	public void doPrevious()
 	{
		if(this.RewardStdSetCtrl.getHasPrevious())
		{
			this.RewardStdSetCtrl.previous();
			getHasFirstAndLast();
			resetCheckBoxes();
		}
	}
	
	//check whether first and last page exists
	public void getHasFirstAndLast()
	{
		if (getPageNumber()==1 && getPageNumber() != getTotalPages())
		{
			hasFirstPage = false;
			hasLastPage = true;
		} 
		else if (getPageNumber() == getTotalPages() && getTotalPages()!=1)
		{
			hasFirstPage = true;
			hasLastPage = false;
		} 
		else if (getPageNumber() == getTotalPages() && getTotalPages()==1)
		{
			hasFirstPage = false;
			hasLastPage = false;
		}
		else {
			hasFirstPage = true;
			hasLastPage = true;
		} 
	}

	//return whether previous page exists
	public Boolean getHasPrevious()
	{
		if(this.RewardStdSetCtrl!=null)
			return this.RewardStdSetCtrl.getHasPrevious();
		else 
			return null;
	}

	//return whether next page exists
	public Boolean getHasNext()
	{
		if(this.RewardStdSetCtrl!=null)
			return this.RewardStdSetCtrl.getHasNext();
		else 
			return null;
	}

	//return page number
	public Integer getPageNumber()
	{
		if(this.RewardStdSetCtrl!=null)
			return this.RewardStdSetCtrl.getPageNumber();
		else 
			return null;
	}

	//return total pages
	Public Integer getTotalPages()
	{
		if (this.RewardStdSetCtrl!=null)
		{
			pageSize = this.RewardStdSetCtrl.getPageSize();
			pages = totalSize/pageSize;
		
			return (Integer)pages.round(System.RoundingMode.CEILING);
		}
		else 
			return null;
	}
	
	//return count of selected items
	public Integer getSelectedCount()
	{
		return this.selectedRewardIds.size();
	}
	
	//display confirmation message with the campaign rewards selected for deletion
	public String getDeleteMessage()
	{
		String deleteMessage='';
		for(CW_Campaign_Reward__c curr: [SELECT Id, Name FROM CW_Campaign_Reward__c  WHERE Id =: this.selectedRewardIds]){
			if (deleteMessage!='')
				deleteMessage += ', ' + curr.Name ;
			else deleteMessage += curr.Name ;
		}
		return deleteMessage;
	}
	
	public Id getDefaultRTId(String rewardTypeName)
	{
		return [SELECT Id FROM CW_Reward_Type__c WHERE Name =: rewardTypeName].Id;
	}
	
}