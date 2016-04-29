/**
* File Name   :    CW_ScheduleDetailsController.cls
* Description :    Page for creating, editing and deleting schedules
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 28/05/2014 Klea Kolaric	Intial
* 0.2 30/05/2014 Klea Kolaric	B-114502 schedule generator
* 0.3 05/06/2014 Klea Kolaric	D-35748 moving into wizard page
*
*/
public without sharing class CW_ScheduleDetailsController {
	
	// constants
	public final String DAILY = 'Days';
	public final String WEEKLY = 'Weeks';
	public final String MONTHLY = 'Months';
	
	// variables
	public CW_Campaign__c camp;
	public List<CW_Schedule__c> schedules {get; set;}
	public List<Schema.FieldSetMember> schFields {get; set;}
	public Boolean schEditMode {get; set;}
	public Id deleteSchId {get; set;}
	
	public String lengthInDaysStr {get; set;}
	public String numOfPeriodsStr {get; set;}
	public String period {get; set;}
	public CW_Schedule__c dummySchedule {get; set;}
	
	public CW_ScheduleDetailsController(ApexPages.standardController stdCtrl)
	{
		Id campId = stdCtrl.getId();
		init(campId);
	}
	
	public CW_ScheduleDetailsController()
	{
		Id campId = (Id) Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_CAMPAIGNID);
		init(campId);
	}
	
	public void init(Id campId)
	{
		if (campId==null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A campaign first needs to be saved before you can manage schedules'));
		} else {
			schEditMode = false;
			camp = [select id, Recurrence_Type__c, Campaign_Start_Date__c, Campaign_End_Date__c from CW_Campaign__c where id = :campId];
			initSchedules();
			initGenerator();
		}
	}
	
	/**/
	
	public void initSchedules()
	{
		Schema.Describesobjectresult dor = Schema.sObjectType.CW_Schedule__c;
		if(schFields == null || schFields.isEmpty())
		{
			schFields = FieldSetUtil.getFieldSet(dor.FieldSets.getMap(),ConstantUtil.SCHEDULE_TABLEVIEW_FS);
		}
		schedules = FieldSetUtil.queryViaFieldSet(schFields, dor.Name, 
						'Marketing_Campaign__c = \'' + camp.Id + '\' ORDER BY Start_Date__c ASC, End_Date__c ASC');
		
		//if (schedules==null||schedules.isEmpty())
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not find any schedules'));
	}
	
	/**/
	
	public void initGenerator()
	{
		if(dummySchedule == null)
		{
			dummySchedule = new CW_Schedule__c();
		}
		dummySchedule.Start_Date__c = camp.Campaign_Start_Date__c;
		dummySchedule.End_Date__c = camp.Campaign_End_Date__c;
		lengthInDaysStr = null;
		numOfPeriodsStr = null;
		period = DAILY;
		
		if(getIsLifecycle())
		{
			initLifecycle();
		}
	}
	
	/**/
	
	public Boolean getIsLifecycle()
	{
		return camp.Recurrence_Type__c == ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_LIFECYCLE;
	}
	
	/**/
	
	public Boolean getIsSingle()
	{
		return camp.Recurrence_Type__c == ConstantUtil.CAMPAIGN_RECURRENCE_TYPE_SINGLE;
	}
	
	/**/
	
	public void initLifecycle()
	{
		lengthInDaysStr = '1';
		numOfPeriodsStr = '1';
		period = MONTHLY;
	}
	
	/**/
	
	public Boolean getRecurenceSet()
	{
		if (camp!=null) {
			return String.isNotBlank(camp.Recurrence_Type__c);
		} else {
			return false;
		}
	}
	
	/**/
	
	public List<Selectoption> getPeriodOptions()
	{
		List<Selectoption> options = new List<Selectoption>();
		options.add(new Selectoption(DAILY,DAILY));
		options.add(new Selectoption(WEEKLY,WEEKLY));
		options.add(new Selectoption(MONTHLY,MONTHLY));
		return options;
	}
	
	/**/
	
	public void generateSchedules()
	{
		List<CW_Schedule__c> newSch = new List<CW_Schedule__c>();
		
		// VALIDATIONS
		if(String.isBlank(lengthInDaysStr) || String.isBlank(numOfPeriodsStr))
		{
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill out all required fields.'));
			return;
		}
		if(dummySchedule.Start_Date__c > dummySchedule.End_Date__c)
		{
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date must be before End Date.'));
			return;
		}
		
		// try to covert to numbers
		Integer lengthInDays;
		Integer numOfPeriods;
		try
		{
			lengthInDays = Integer.valueOf(lengthInDaysStr);
			numOfPeriods = Integer.valueOf(numOfPeriodsStr);
		}
		catch(exception e)
		{
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid integer!'));
			return;
		}
		if(lengthInDays <= 0 || numOfPeriods <= 0)
		{
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only positive integers accepted!'));
			return;
		}
		
		// CALCULATION
		Date startDate = dummySchedule.Start_Date__c;
		while(startDate <= dummySchedule.End_Date__c)
		{
			// last day is the last day on which the campaign is running
			Date endDateCalculated = getIsLifecycle() ? startDate.addMonths(1).addDays(-1) : startDate.addDays(lengthInDays-1);
			Date endDate = endDateCalculated > dummySchedule.End_Date__c ? dummySchedule.End_Date__c : endDateCalculated;
							
			newSch.add(new CW_Schedule__c(
								Marketing_Campaign__c = camp.Id,
								Start_Date__c = startDate,
								End_Date__c = endDate,
								Evaluation_Start_Date__c = startDate,
								Evaluation_End_Date__c = endDate.addDays(ConstantUtil.EVALUATION_DATE_OFFSET)));
								
			startDate = period == MONTHLY ? 
							startDate.addMonths(numOfPeriods) : (startDate.addDays(numOfPeriods * (period == WEEKLY ? 7 : 1)));
		}
		
		delete schedules;
		insert newSch;
		
		initSchedules();
		initGenerator();
	}
	
	/**/
	
	public void addNewSchedule()
	{
		schedules.add(new CW_Schedule__c(Marketing_Campaign__c = camp.Id));
	}
	
	/**/
	
	// adding new schedule if last list member has empty id
	public Boolean getIsAddMode()
	{
		return !schEditMode && !schedules.isEmpty() && schedules.get(schedules.size()-1).id == null;
	}
	
	/**/
	
	public void inlineEdit()
	{
		schEditMode = true;
	}
	
	/**/
	
	public Boolean getShowInlineEditButton()
	{
		return !schedules.isEmpty();
	}
	
	/**/
	
	public void saveEdit()
	{
		if(schEditMode || getIsAddMode())	// these two can never be both true!
		{
			List<CW_Schedule__c> modifeidSch = schEditMode ? schedules : new List<CW_Schedule__c>{schedules.get(schedules.size()-1)};
			
			String errorMsg = '';
			for(CW_Schedule__c sch : modifeidSch)
			{
				errorMsg += FieldSetUtil.checkRequiredFieldsFS(sch, schFields);
			}
			if(String.isNotBlank(errorMsg))
			{
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));
				return;
			}
			try
			{
				upsert modifeidSch;
				schEditMode = false;
			}
			catch(Exception ex) 
			{
				ApexPages.addMessages(ex);
			}
			
		}
		initSchedules();
	}
	
	/**/
	
	public void cancelEdit()
	{
		if(schEditMode)
		{
			schEditMode = false;
			initSchedules();
		}
		else
		{
			if(getIsAddMode())
			{
				schedules.remove(schedules.size()-1);	// last element is the new one
			}
		}
	}
	
	/**/
	
	public void deleteSch()
	{
		if(deleteSchId != null)
		{
			delete [select id from CW_Schedule__c where id = :deleteSchId];
			deleteSchId = null;
			initSchedules();
		}
	}

}