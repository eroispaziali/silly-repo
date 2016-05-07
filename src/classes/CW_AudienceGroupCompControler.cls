/**
* File Name   :    CW_AudienceGroupCompControler.cls
* Description :    B-110228/B-110230/B-109518
*                  CIM, BI, Marketer must be able to View,Edit,Delete audience groups 
*				   that are linked to the campaign 
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 01/05/2014 Alex Panka		Intial - Partial copy of CW_AudienceGroupControler 
* 0.2 03/05/2014 Alex Panka   	Revrite some functionality - (Best Practice)
* 0.3 20/08/2014 Cristina P		Geeting members number for each group
*/
//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing" 
//so the user can create related records while cost/brief is in approval 
public without sharing class CW_AudienceGroupCompControler {
	public enum ControlerStatus {View, Edit, NEWREC}

	/* set controller variables */
	private List<sObject>					audienceGroups_local;
	private Id						       	campId_Local;
	private Integer          				pageSize; 
	
	public Set<Id>                         	selectedGroupIds;
	public Set<Id> 							groupsIds;
	public String 							contextItem {get;set;}
	public ApexPages.StandardSetController 	setGroups;
	public CW_Audience_Group__c            	newRec {get;set;}
		
	public ControlerStatus					CntrlState {get;private set;}
	public Boolean							selectAll {get;set;}
	public Boolean                			isReadOnly{get; set;}
	public Boolean							hasUnicaSgm {get;set;} 	
	public Map<Id,Integer> 					audienceGroupMembers;
	 
	public Transient String                 ErrorMessage{get;private set;}
	public Transient Boolean                IsError{get;private set;}

	// Geter and seter avaliable from commponent ( Initailization after constructor)
	//Important  Empty List is from master controler so dont destroy and only add/delete records !!!!
	public List<sObject> 		            audienceGroups
	{
		get
			{ return audienceGroups_local;}
		set
		{
			if (value==null)
				return;
			if(audienceGroups_local.Size()>0 && value.size()==0)
				value.AddAll(audienceGroups_local);
				
			audienceGroups_local=value;
		}
	}
	
	public Id						        campId
	{
		get
			{return campId_Local;}
		set{
			//This is important becouse value is set on every change on page
			boolean doInit=(campId_Local!=value);
			campId_Local=value;
			if(doInit)
			{
				init();	
			}
		}
	} 
	
	public Boolean                         	savedByParent
	{
		get
			{return false;}
		set{ 
			 if( value==true) 
			 {
			 	CntrlState=ControlerStatus.View;
			 	Init();
			}
		}
	}
	
	//add set controller to the group wrapper 
	public List<audienceGroupWrapper> 	campGroups 
	{
		get{
			List<audienceGroupWrapper> GroupWraperList = new List<audienceGroupWrapper>();
			if (this.setGroups!=null)
			{
				for(sObject r : this.setGroups.getRecords())
				{
					CW_Audience_Group__c ag = (CW_Audience_Group__c)r;
					audienceGroupWrapper audienceGroup = new audienceGroupWrapper(ag,this.selectedGroupIds.contains(ag.Id),audienceGroupMembers.get(ag.Id));
					GroupWraperList.add(audienceGroup);
				}
			}
			return GroupWraperList;
		}
	}
	
	//get total sizze for the set controller	
	public  Decimal		totalSize 
	{	
		get
		{
			if( this.setGroups==null) 
				return 0; 
			return this.setGroups.getResultSize();
		}
	}

	/* view mode variables */
	public  Boolean		getInputMode()  { return CntrlState!=ControlerStatus.View;}
	public  Boolean		getOutputMode() { return CntrlState==ControlerStatus.View;}
	public  Boolean      getNewRecMode() { return CntrlState==ControlerStatus.NewRec;}
	/* buttons variables */
	public  Boolean		getEditDisabled() { return (CntrlState!=ControlerStatus.VIEW) || isReadOnly;}
	public  Boolean		getDeleteDisabled(){return  (selectedGroupIds.Size()==0) || isReadOnly;}
	
	public CW_AudienceGroupCompControler()
	{
		isReadOnly=true;// Initialize this to false.
		pageSize=100;
		CntrlState=ControlerStatus.VIEW;
		audienceGroups_local= new List<sObject>();
		selectedGroupIds= new Set<Id>();
		newRec= new CW_Audience_Group__c(Campaign__c = campId);
	}
	
	public void init()
	{
		//set the data display mode
      	selectAll = false;
      	pageSize=CW_CampaignListSettingHelper.getIntegerValue(ConstantUtil.AUDIENCE_GROUP_PAGE_SIZE,10);
        //gather data set
      	this.setGroups= new ApexPages.StandardSetController(getAudienceSetGroups(campId));
		this.setGroups.setpageNumber(1);
		this.setGroups.setPageSize(pagesize);

	}
	
    //list of audience group records linked to the campaign
	public List<CW_Audience_Group__c> getAudienceSetGroups(Id campId)
	{
		groupsIds = new set<Id>();
		List<CW_Audience_Group__c> resultLst =	[SELECT Id,Name, Is_Control_Group__c, 
														 Description__c,
														 Control_Group__c,
														 Control_Group__r.Name,
														 Unica_Id__c,
														 Campaign__c,
														 (Select Id  From Control_Groups__r Limit 1) 
												  FROM CW_Audience_Group__c
												  WHERE Campaign__c =: campId
												  ORDER BY CreatedDate DESC];
		audienceGroups.Clear();
		//add all records to the audienceGroups list and crate a set of groups Id to help populate the members map
		for(CW_Audience_Group__c rec :resultLst)
		{
			groupsIds.add(rec.Id);
			audienceGroups.Add(rec);
		}
		if(groupsIds!=null) getMembersMap(groupsIds);
		
		return resultLst;
	}
	
	//return number of members for each group
	public void getMembersMap(Set<Id> groupsIds)
	{
		audienceGroupMembers = new map<Id,Integer>();
		for (CW_Audience_Group_Schedule__c curr: [select Audience_Group__c,Audience_Group_Member_Count__c from CW_Audience_Group_Schedule__c where Audience_Group__c IN: groupsIds])
		{
			audienceGroupMembers.put(curr.Audience_Group__c,Integer.valueOf(curr.Audience_Group_Member_Count__c));
		}
	}
	
	//Wrapper class that represents a row
	public with sharing class audienceGroupWrapper
    {
		public CW_Audience_Group__c aGroup{get;set;}
		public Boolean 				isSelected{get;set;}
		public Integer				members{get;set;}
		///Wrapers that add logic behind changing isControlGroup
		private ID                  ControlGrupId;
		 
		public Boolean              isControlGroup
		{
			get
				{return aGroup.Is_Control_Group__c;}
			set
			{
				aGroup.Is_Control_Group__c=value;
				if(value){
					//Make copy and clear control group
					ControlGrupId=aGroup.Control_Group__c;
					aGroup.Control_Group__c=null;
				}
				else
				{
					//Restore control gropu ID
					aGroup.Control_Group__c=ControlGrupId;
				}
			}
		}
		//For control groups indicate if group is used
		public Boolean              getIsUsed()
		{ 
			if(aGroup.Control_Groups__r==null)
				return false;
			return aGroup.Control_Groups__r.size()>0;
		}
		
		public audienceGroupWrapper(CW_Audience_Group__c ag, Boolean s, Integer members)
		{
			this.aGroup=ag;
			this.IsSelected=s;
			this.members = members; 
		}
	}

	/*							*/
	/*   BUTTONS FUNCTIONALITY  */
	/*							*/
	
	//create new group
	public void addGroup()
	{
		CntrlState = ControlerStatus.NewRec;
		newrec= new CW_Audience_Group__c(Campaign__c=campId_Local);
	}
	
	//save new record functionality
	public void SaveNewRecord()
	{
		try
		{
			//save record only if the name field is populated
			if (newrec.Name!=null && newrec.Name!='')
			{
				Insert newrec;
				Init();
				CntrlState=ControlerStatus.View;
			}
			else
			{
				//display errror message for records without name
				ErrorMessage = ConstantUtil.CREATE_AUDIENCE_GROUP_NO_NAME;
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ErrorMessage));
				IsError=true;
			}	
		}
		catch (Exception ex)
		{
			ErrorMessage=ex.getMessage();
			if (ErrorMessage.contains(ConstantUtil.DUPLICATE_NAME_ERROR))
				ErrorMessage = newrec.Name + ' ' + ConstantUtil.DUPLICATE_AUDIENCE_GROUP_NAME;
			IsError=true;
			ApexPages.addMessages(ex);
		}
	}
	
	//cancel functionality
	public void Cancel()
	{
		CntrlState=ControlerStatus.View;
		init();
	}
	
	//edit multiple groups
	public void editGroups()
	{
		CntrlState=ControlerStatus.Edit;
	}
	
	//save all records that have been updated in inline edit mode
	public void saveAllGroups()
	{
		List<CW_Audience_Group__c> groupsToUpdate = new List<CW_Audience_Group__c>();
		Set<Id>                    controlGroupIds = new set<Id>();
		IsError = false;
		if (campId!=null)
		{
			//get all groups Id that are control group
			controlGroupIds = getControlGroupIds();	
			//loop though the list of groups and make sure all groups have a name
			for (audienceGroupWrapper curr : campGroups)
			{
				if(curr.aGroup.Name!=null && curr.aGroup.Name!='')
					groupsToUpdate.add(curr.aGroup);
				else
				{ 
					ErrorMessage = ConstantUtil.CREATE_AUDIENCE_GROUP_NO_NAME;
					CntrlState=ControlerStatus.Edit;
					ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ErrorMessage));
					IsError=true;
					break;
				}
			}
			
			//check control groups and update groups only if there are no errors after validating the data
			if (!IsError)
			{
				//if target group is being changed to control group remove control group
				for (CW_Audience_Group__c curr : groupsToUpdate) {
					if (curr.Is_Control_Group__c && curr.Control_Group__c != null)
					{
						curr.Control_Group__c = null;
					}
					//Cristina P: 11/07/14: if control group is changed to target group remove all 
					//relationships that the group has with the other target groups
					if(controlGroupIds.contains(curr.Id) && !curr.Is_Control_Group__c)
					{
						for (audienceGroupWrapper wrap : campGroups)
						{
							if (wrap.aGroup.Control_Group__c == curr.Id)
								wrap.aGroup.Control_Group__c =null;
						}
					}
				}	
				
				//save changes
				if (!groupsToUpdate.isEmpty())
				{
					try
					{
						upsert groupsToUpdate;
						CntrlState=ControlerStatus.View;
					}catch (Exception ex)
					{
						ErrorMessage=ex.getMessage();
						if (ErrorMessage.contains(ConstantUtil.DUPLICATE_NAME_ERROR))
							ErrorMessage = 'Duplicate value found.Group Name must be unique.';
						IsError=true;
						ApexPages.addMessages(ex);
					}
				}
			}
		}
	}
	
    //delete selected groups
	public void deleteGroups()
	{
		List<CW_Audience_Group__c> groupsToDelete = new List<CW_Audience_Group__c>();
		if(selectedGroupIds.Size()==0)
			return;
		for (Id curr : selectedGroupIds)
		{
			//add the selected group to the list of groups to delete
			groupsToDelete.add(new CW_Audience_Group__c(Id = curr));	
		}
		//remove the selected group id from the set
		this.selectedGroupIds.Clear();
		try 
    	{
			delete groupsToDelete;
			init();
    	}catch(Exception ex){
    		ErrorMessage=ex.getMessage();
			IsError=true;
			ApexPages.addMessages(ex);
		}
	}
	
	/*										*/
	/*   SELECT & DESELECT FUNCTIONALITY  	*/
	/*										*/

	//handle item selected
	public void doSelectItem()
	{
		this.selectedGroupIds.add(this.contextItem);
	}	

	//handle item deselected
	public void doDeselectItem()
	{
		this.selectedGroupIds.remove(this.contextItem);
	}
	
	//changing control group to target group after is control group is selected or deselected to display the right values in the lookup filter
	public void changeCGtoTGorTGtoCG()
	{
		CW_Audience_Group__c tgToUpdate = [SELECT Id,Is_Control_Group__c FROM CW_Audience_Group__c WHERE Id=:this.contextItem]; 
		tgToUpdate.Is_Control_Group__c = (tgToUpdate.Is_Control_Group__c) ? false : true;
		update tgToUpdate;
	}
	
	//handle all items selected
	public void selectDeselectAllItems()
	{
		list<CW_Audience_Group__c> groupsInPage = new list<CW_Audience_Group__c>();
		groupsInPage = setGroups.getRecords();
		//loop though all group displayed on the page and check which have beeen deselected
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
	}
	
	//deselect all groups
	public void resetCheckBoxes()
	{
		selectAll=false;
		this.selectedGroupIds.Clear();
	}
	
	/*								*/
	/*   NAVIGATION FUNCTIONALITY  	*/
    /*								*/
	
	//go to first page
	public void first()
	{
		this.setGroups.first();
	}
	
	//go to last page
	public void last()
	{
		this.setGroups.last();
	}
	
	//advance to next page
	public void doNext()
	{
		if(this.setGroups.getHasNext())
		{
			this.setGroups.next();
			resetCheckBoxes();
		}
	}

 	//advance to previous page
 	public void doPrevious()
 	{
		if(this.setGroups.getHasPrevious())
		{
			this.setGroups.previous();
			resetCheckBoxes();
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
	public Integer getTotalPages()
	{
		if (this.setGroups!=null)
		{
			decimal pages = (decimal)totalSize/(decimal)pageSize;
			return (Integer)pages.round(System.RoundingMode.CEILING);
		}
		else 
			return 0;
	}
	
	//return count of selected items
	public Integer getSelectedCount()
	{
		return this.selectedGroupIds.size();
	}
	
	//return a set of control groups
	public set<Id> getControlGroupIds()
	{
		set<Id> controlGroupsIds = new Set<Id>();
		for (sObject  rec : audienceGroups)
		{
			CW_Audience_Group__c curr=(CW_Audience_Group__c)rec;
			if (curr.Control_Group__c!=null)
				controlGroupsIds.add(curr.Control_Group__c);
		}
		return controlGroupsIds;
	}
	
	//display groups that have been selected for deletion
	public String getDeleteMessage()
	{
		List<CW_Audience_Group__c> groupsToDelete = new List<CW_Audience_Group__c>();
		List<CW_Audience_Group__c> groupsSelected = new List<CW_Audience_Group__c>();
		List<CW_Audience_Group__c> selectedControlGroups = new List<CW_Audience_Group__c>();
		String deleteMessage='';
		//get the set of control groups
		set<Id> controlGroupsIds = getControlGroupIds();
		//list of groups selected for deletion
		groupsSelected = [SELECT Id, Name, Is_Control_Group__c, 
								 Description__c,
								 Control_Group__c//, 
								 //Number_of_Players_in_Group__c - TODO
						  FROM CW_Audience_Group__c
						  WHERE Id IN : this.selectedGroupIds];
		for (CW_Audience_Group__c curr : groupsSelected)
		{	
			// check if the group selected is control group
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
}