/**
* File Name   :    CW_AudienceGroupController.cls
* Description :    B-110228/B-110230/B-109518
*                  CIM, BI, Marketer must be able to View,Edit,Delete audience groups 
*				   that are linked to the campaign 
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 01/04/2014 Cristina P.	Intial
* 0.2 08/04/2014 Cristina P.	B-109513 - download the audience group template
* 0.3 24/04/2014 Alex Panka   D-106803, B-110234
*
*/

public with sharing class CW_AudienceGroupController {
	
	public List<CW_Audience_Group__c> 	audienceGroups {get; set;}
	public List<audienceGroupWrapper> 	campGroups {get; set;}
	public CW_Campaign__c 				camp {get; set;}
	public set<Id> 						controlGroupsIds;
	public Id							campId{get; set;}
	public String 						contextItem {get;set;}
	public Decimal						totalSize {get;set;}
	public Decimal 						pageSize;
	public Decimal 						pages;
	public String 						deleteMessage {get; set;}
	public String						campName {get; set;}
	/* view mode variables */
	public Boolean						inputMode {get;set;}
	public Boolean						outputMode {get;set;}
	
	/* buttons variables */
	public Boolean						editDisabled {get;set;}
	public Boolean						deleteDisabled {get;set;}
	public Boolean						saveDisabled {get;set;}
	public Boolean						cancelDisabled {get;set;}
	public Boolean						selectAll {get;set;}
	public Boolean						controlGroupVisible {get;set;}
	public Boolean						hasFirstPage {get;set;}
	public Boolean						hasLastPage {get;set;}
	public Boolean						editControlGroup {get; set;}
	public Boolean						addGroup;
	
	public CW_CampaignListSetting__c audienceGroupPageSizeRecord;
	public String 						taskType {get; set;}
	
	/* set controller variables */
	public ApexPages.StandardSetController setGroups;
	public Set<Id> selectedGroupIds;
	
	public CW_AudienceGroupController()
	{
		outputMode=true;
		inputMode=false;
		
		//init variable
		audienceGroupPageSizeRecord = CW_CampaignListSetting__c.getValues(ConstantUtil.AUDIENCE_GROUP_PAGE_SIZE);
		this.selectedGroupIds= new Set<Id>();
		campId = (Id) Apexpages.currentPage().getParameters().get('id');
		if (campId!=null)
		{
			campName = getCampaignName(campId);
			deleteMessage ='';
			init();
		}
	}
	
	public void init()
	{
		//set the data display mode
		outputMode=true;
		inputMode=false;
		editDisabled=false;
		deleteDisabled = true;
		saveDisabled = true;
        cancelDisabled = true;
        selectAll = false;
        addGroup = false;
        
        //gather data set
		this.setGroups= new ApexPages.StandardSetController(getAudienceSetGroups(campId));
		this.setGroups.setpageNumber(1);
		if (audienceGroupPageSizeRecord!=null && audienceGroupPageSizeRecord.Integer_Value__c!=null){
			this.setGroups.setPageSize(Integer.valueOf(audienceGroupPageSizeRecord.Integer_Value__c));
		}	else {
			this.setGroups.setPageSize(100);
      }
		totalSize = this.setGroups.getResultSize();
		
		campGroups = getAudienceGroup();
		getHasFirstAndLast();
		getControlGroupIds(); 
	}
	
    //list of audience group records linked to the campaign
	public List<CW_Audience_Group__c> getAudienceSetGroups(Id campId)
	{
		audienceGroups = [SELECT Name, Is_Control_Group__c, 
								 Description__c,
								 Control_Group__c,
								 Control_Group__r.Name,
								 Unica_Id__c,
								 Campaign__c,
								 //Number_of_Players_in_Group__c - TODO
								 (Select Id From Audience_Group_Members1__r),
								 (Select Id  From Control_Groups__r Limit 1) 
						  FROM CW_Audience_Group__c
						  WHERE Campaign__c =: campId
						  ORDER BY CreatedDate DESC];
		
		return audienceGroups;
	}
	
	//Wrapper class that represents a row
	public with sharing class audienceGroupWrapper
    {
		public CW_Audience_Group__c aGroup{get;set;}
		public Boolean 				 isSelected{get;set;}
		//For control groups indicate if group is used 
		public Boolean              getIsUsed(){ 
			if(aGroup.Control_Groups__r==null)
				return false;
			return aGroup.Control_Groups__r.size()>0;
		}
		
		public Integer getNumberOfMembers(){
			if(aGroup.Audience_Group_Members1__r==null)
				return 0;
			return aGroup.Audience_Group_Members1__r.Size();
		}

		public audienceGroupWrapper(CW_Audience_Group__c ag, Boolean s)
		{
			this.aGroup=ag;
			this.IsSelected=s;
		}
	}

	//create wrapper class that returns current page of groups
	public List<audienceGroupWrapper> getAudienceGroup()
	{
		campGroups = new List<audienceGroupWrapper>();

		if (this.setGroups!=null)
		{
			for(sObject r : this.setGroups.getRecords())
			{
				CW_Audience_Group__c ag = (CW_Audience_Group__c)r;
	
				audienceGroupWrapper audienceGroup = new audienceGroupWrapper(ag,false);
				if(this.selectedGroupIds.contains(ag.Id)){
					audienceGroup.IsSelected=true;
				}
				else{
					audienceGroup.IsSelected=false;
				}
				campGroups.add(audienceGroup);
			}
		} 
		
		if (addGroup == true)
		{
			campGroups = new List<audienceGroupWrapper>();
			campGroups.add(new audienceGroupWrapper(new CW_Audience_Group__c(Campaign__c = campId),false));
		}
			
			
		return campGroups;
	}
	
	//get the fields that are diplayed on each VF page
    public List<Schema.FieldSetMember> getFields() 
    {
    	return SObjectType.CW_Campaign__c.FieldSets.getMap().get('Audience').getFields();
    }
	
	/*							*/
	/*   BUTTONS FUNCTIONALITY  */
	/*							*/
	
	//create new group
	public void addGroup()
	{
		inputMode = true;
		outputMode = false;
		addGroup = true;
		editDisabled = true;
		saveDisabled = false;
		cancelDisabled = false;    
	}
	
	//edit multiple groups
	public void editGroups()
	{
		outputMode=false;
		inputMode=true;
		editDisabled = true;
		deleteDisabled = true;
		saveDisabled = false;
		cancelDisabled = false;
	}
	
    //delete selected groups
	public void deleteGroups()
	{
		List<CW_Audience_Group__c> groupsToDelete = new List<CW_Audience_Group__c>();
		for (Id curr : selectedGroupIds)
		{
			//remove the selected group id from the set
			this.selectedGroupIds.remove(curr);
			//add the selected group to the list of groups to delete
			groupsToDelete.add(new CW_Audience_Group__c(Id = curr));	
		}
		
		try 
    	{
			if (!groupsToDelete.isEmpty())
			{
				delete groupsToDelete;
				init();
			}
    	}catch(Exception ex){
			ApexPages.addMessages(ex);
		}
	}
	
	//save the groups after edit
	public void saveGroups()
	{
		Boolean existingGroup;
		String existingGroupName;
		
		List<CW_Audience_Group__c> groupsToUpdate = new List<CW_Audience_Group__c>();
		if (campId!=null)
			{
			for (audienceGroupWrapper curr : campGroups)
			{
				if(curr.aGroup.Name!=null && curr.aGroup.Name!='')
					groupsToUpdate.add(curr.aGroup);
				else
				{ 
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantUtil.CREATE_AUDIENCE_GROUP_NO_NAME)); 
					break;
				}
			}
			//if target group is being changed to control group remove control group
			for (CW_Audience_Group__c curr : groupsToUpdate) {
				if (curr.Is_Control_Group__c && curr.Control_Group__c != null)
				{
					curr.Control_Group__c = null;
				}
			}	
			
			//save changes
			//setGroups.save(); 
			if (!groupsToUpdate.isEmpty())
			{
				upsert groupsToUpdate;
				init();
			}
		}
	}

	//cancel the edit mode
	public void cancel()
	{
		init();
    }

	/*										*/
	/*   SELECT & DESELECT FUNCTIONALITY  	*/
	/*										*/

	//handle item selected
	public void doSelectItem()
	{
		this.selectedGroupIds.add(this.contextItem);
		deleteDisabled=false;
		//black the message after select so no duplicated groups are added
		deleteMessage = '';
		deleteMessage = getDeleteMessage();
	}

	//handle item deselected
	public void doDeselectItem()
	{
		this.selectedGroupIds.remove(this.contextItem);
		// disable delete button only if all the groups were deselected
		if (selectedGroupIds.size()==0) deleteDisabled=true;
	}
	
	//handle all items selected
	public void selectDeselectAllItems()
	{
		list<CW_Audience_Group__c> groupsInPage = new list<CW_Audience_Group__c>();
		groupsInPage = setGroups.getRecords();
		
		for (CW_Audience_Group__c curr : groupsInPage)
		{
			if (selectAll)
				this.selectedGroupIds.add(curr.Id);
			else
			{
				this.selectedGroupIds.remove(curr.Id);
				selectAll = false;
			}
		}
		
		if (selectAll)
			deleteDisabled=false;
		else 
			deleteDisabled=true;
	}
	
	//deselect all groups
	public void resetCheckBoxes()
	{
		selectAll=false;
		selectDeselectAllItems();
		getSelectedCount();
	}
	
	/*								*/
	/*   NAVIGATION FUNCTIONALITY  	*/
    /*								*/
	
	//go to first page
	public void first()
	{
		this.setGroups.first();
		getHasFirstAndLast();
	}
	
	//go to last page
	public void last()
	{
		this.setGroups.last();
		getHasFirstAndLast();
	}
	
	//advance to next page
	public void doNext()
	{
		if(this.setGroups.getHasNext())
		{
			this.setGroups.next();
			getHasFirstAndLast();
			resetCheckBoxes();
		}
	}

 	//advance to previous page
 	public void doPrevious()
 	{
		if(this.setGroups.getHasPrevious())
		{
			this.setGroups.previous();
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
		if(this.setGroups!=null)
			return this.setGroups.getHasPrevious();
		else 
			return null;
	}

	//return whether next page exists
	public Boolean getHasNext()
	{
		if(this.setGroups!=null)
			return this.setGroups.getHasNext();
		else 
			return null;
	}

	//return page number
	public Integer getPageNumber()
	{
		if(this.setGroups!=null)
			return this.setGroups.getPageNumber();
		else 
			return null;
	}

	//return total pages
	Public Integer getTotalPages()
	{
		if (this.setGroups!=null)
		{
			pageSize = this.setGroups.getPageSize();
			pages = totalSize/pageSize;
		
			return (Integer)pages.round(System.RoundingMode.CEILING);
		}
		else 
			return null;
	}
	
	//return count of selected items
	public Integer getSelectedCount()
	{
		return this.selectedGroupIds.size();
	}
	
	//return a set of control groups
	public set<Id> getControlGroupIds()
	{
		controlGroupsIds = new Set<Id>();
						  
		for (CW_Audience_Group__c curr : audienceGroups)
		{
			if (curr.Control_Group__c!=null)
				controlGroupsIds.add(curr.Control_Group__c);
		}
		
		return controlGroupsIds;
	}
	
	public String getDeleteMessage()
	{
		List<CW_Audience_Group__c> groupsToDelete = new List<CW_Audience_Group__c>();
		List<CW_Audience_Group__c> groupsSelected = new List<CW_Audience_Group__c>();
		List<CW_Audience_Group__c> selectedControlGroups = new List<CW_Audience_Group__c>();
		
		//get the set of control groups
		controlGroupsIds = getControlGroupIds();
		//list of groups selected for deletion
		groupsSelected = [SELECT Id, Name, Is_Control_Group__c, 
								 Description__c,
								 Control_Group__c//, 
								 //Number_of_Players_in_Group__c - TODO
						  FROM CW_Audience_Group__c
						  WHERE Id IN : this.selectedGroupIds];
		for (CW_Audience_Group__c curr : groupsSelected)
		{	
			// check if the group selected is
			if (controlGroupsIds.contains(curr.Id))
			{	
				//create list with all selected groups that are controlling groups as well
				selectedControlGroups.add(curr);
				//add the group name to the message
				if (deleteMessage!='')
					deleteMessage += ', ' + curr.Name ;
				else deleteMessage += curr.Name ;
			}  
		}

		//MORE than 1 group selected is a control group
		if (selectedControlGroups.size()>1)
		{
			deleteMessage +=ConstantUtil.AUDIENCE_GROUP_MULTIPLE_CONTROL_GROUPS + System.Label.Audience_Group_Delete_Message;
		} 
		//only ONE group from the selected ones, is control group
		else if (selectedControlGroups.size()==1)
		{ 
			deleteMessage += ConstantUtil.AUDIENCE_GROUP_SINGLE_CONTROL_GROUP + System.Label.Audience_Group_Delete_Message;
		}
		//NONE of the groups selected, is control group
		else deleteMessage= ConstantUtil.AUDIENCE_GROUP_NO_CONTROL_GROUP;
		
		return deleteMessage;
	}
	
	public String getCampaignName(Id campId)
	{
		String campName = [SELECT Name FROM CW_Campaign__c WHERE Id =: campId].Name;
		
		return campName;
	}
	
	//download audience groups into csv file
	public PageReference downloadAudienceGroupTemplate()
	{
		PageReference ref = new PageReference('/apex/CW_Audience_Group_Template');
		ref.getParameters().put('id',campId);
    	ref.setRedirect(false);
    	return ref;
	}
	
	//download group members template into csv file
	public PageReference downloadGroupMembersTemplate()
	{
		PageReference ref = new PageReference('/apex/CW_Audience_Group_Members_Template');
		ref.getParameters().put('id',campId);
    	ref.setRedirect(false);
    	return ref;
	}
	
	/*** AUDIENCE PAGE ***/
	
	
	// called from Audience page when Creating BI and CIM task (tasks must be associated to a saved campaign)
	// todo merge and refactor other save methods
	public Pagereference saveCamp() {
		
		PageReference pr = new Pagereference('/apex/CW_Audience');
		
		try	{
			upsert camp;
			pr.getParameters().put(ConstantUtil.SOBJECT_ID,camp.Id);
			pr.getParameters().put(ConstantUtil.PAGEPARAM_MODALFLAG,'true');
			pr.getParameters().put(ConstantUtil.PAGEPARAM_TASKTYPE,taskType);
			pr.setRedirect(true);
			return pr;
		}
		
		catch(Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
	}
}