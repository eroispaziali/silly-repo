/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Provide methods to be called from Visual Force Pages.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-12-08
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: VF Controller with Various method handlers for VF.
 *        1) ServiceUsageRelatedActivities
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2012-07-04 - MT -   Events should return StartTime not completion date.
 *  2012-10-08 - VA -   Updated Activity history PDF to display the Event/Task Status and Outcome Number.
 *  2012-10-09 - VA -   Updated Description field to display 255 charecters, It was 100 earlier.
*   2013-07-23  MT   Updated Description field to display 32000 charecters, It was 255 earlier.
*******************************************************************************************/
public class ServiceUsageRelatedActivitiesController
{
public Service_Usage__c recSU {get;set;}
public List<ActivityInnerClass> lstActivities {get;set;}
public Integer CHARS_TO_SHOW {get{return 32000;}}
public string sortDirection {get;set;}
public Contact person {get; set;}

//Contructor
public ServiceUsageRelatedActivitiesController(ApexPages.StandardController controller) {
        recSU = (Service_Usage__c)controller.getRecord();
        lstActivities = new List<ActivityInnerClass>();
        sortDirection='ASC';
        
        getPersonDetails();
        
        //Populate list with all Events where date is in the past for a SU.
        for(Event eveRec: [Select Subject,StartDateTime, ActivityDate,Description,Owner.Name,Event_Status__c,Related_Outcomes__c from Event where WhatId=:recSU.id and ActivityDate<=TODAY  AND IsDeleted = false ALL ROWS ])
        {
            ActivityInnerClass tmpRec = new ActivityInnerClass();
            tmpRec.recId=eveRec.Id;
            tmpRec.Subject =eveRec.Subject;
            tmpRec.ActivityDate=eveRec.ActivityDate;
            tmpRec.CompletionDate=eveRec.StartDateTime;
            tmpRec.Description=eveRec.Description;
            tmpRec.OwnerName=eveRec.Owner.Name;
            tmpRec.Status=eveRec.Event_Status__c;
            tmpRec.isEventType=true;
            tmpRec.OutcomeNumber=eveRec.Related_Outcomes__c;
            tmpRec.isElipsesOn=(eveRec.Description!=null)?(eveRec.Description.length()>CHARS_TO_SHOW):false;
            
            lstActivities.add(tmpRec);
            
        }
        
        //Populate list with all completed Task records for a SU.
        for(Task tskRec: [Select Subject,Completion_Date_Task__c,ActivityDate,Status, Description,Owner.Name,Related_Outcomes__c from Task where WhatId=:recSU.id and Status='Completed'  AND IsDeleted = false ALL ROWS  ])
        {
            ActivityInnerClass tmpRec = new ActivityInnerClass();
            tmpRec.recId=tskRec.Id;
            tmpRec.Subject =tskRec.Subject;
            tmpRec.ActivityDate=tskRec.ActivityDate;
            tmpRec.CompletionDate=tskRec.Completion_Date_Task__c;
            tmpRec.Description=tskRec.Description;
            tmpRec.OwnerName=tskRec.Owner.Name;
            tmpRec.Status=tskRec.Status;
            tmpRec.isEventType=false;
            tmpRec.OutcomeNumber=tskRec.Related_Outcomes__c;
            tmpRec.isElipsesOn=(tskRec.Description!=null)?(tskRec.Description.length()>CHARS_TO_SHOW):false;//?tskRec.Description.length()>10:false;
            
            lstActivities.add(tmpRec);

        }
        
        //Populate list with all EAD records Events scheduled for a SU and AcitivityDate is in Past.
        for(Event_Attendance_Details__c EADRec: [Select Event_Subject__c,Notes__c,Owner.Name,Attendance_Status__c,Event_Date_and_Time__c,Outcome_No_s__c from 
            Event_Attendance_Details__c where Service_Usage__c=:recSU.id and Event_Date_and_Time__c<=TODAY  AND IsDeleted = false ALL ROWS  ])
        {
            ActivityInnerClass tmpRec = new ActivityInnerClass();
            tmpRec.recId=EADRec.Id;
            tmpRec.Subject =EADRec.Event_Subject__c;
            tmpRec.ActivityDate=EADRec.Event_Date_and_Time__c;
            tmpRec.Description=EADRec.Notes__c;
            tmpRec.OwnerName=EADRec.Owner.Name;
            tmpRec.Status=EADRec.Attendance_Status__c;
            tmpRec.OutcomeNumber=EADRec.Outcome_No_s__c;
            tmpRec.isEventType=true;
            tmpRec.isElipsesOn=(EADRec.Notes__c!=null)?(EADRec.Notes__c.length()>CHARS_TO_SHOW):false;
            
            lstActivities.add(tmpRec);        
        }
        
system.debug('#######Before lstActivities#####'+lstActivities);        
        lstActivities=sortList(lstActivities);
system.debug('#######After lstActivities#####'+lstActivities);
    }
    
    public Contact getPersonDetails(){
        //get the person Id
        Service_Usage__c tempSU = [select id, Primary_Service_User__c from Service_Usage__c where id =:recSU.Id];
        if(tempSU.Primary_Service_User__c!=null) person = [select id, Client_reference_number__c from Contact where id=:tempSU.Primary_Service_User__c];
        return person;
    }

//Sorting the List by Date Chronologically.
private List<ActivityInnerClass> sortList(List<ActivityInnerClass> lstActivities)
{
        if(lstActivities.size()==0)
                return null;
        
        Map<DateTime,DateTime> mapUniqDates = new map<DateTime,DateTime>();
        
        //Prepare a Map with unique Activity date
        for(ActivityInnerClass rec: lstActivities)
        {
            if(!mapUniqDates.containsKey(rec.ActivityDate))
                mapUniqDates.put(rec.ActivityDate,rec.ActivityDate);  
        }
system.debug('##########mapUniqDates##############'+mapUniqDates);        

        //If Dates are found for sorting.
        if(mapUniqDates.keySet().size()>0)
        {
            List<DateTime> lstUniqueDates = mapUniqDates.values();
            
            //Sort the Dates List
            lstUniqueDates.sort();
            List<ActivityInnerClass> lstTmpActRecs = new List<ActivityInnerClass>();

            //If sorting direction is ASC
            if((sortDirection.equalsIgnoreCase('ASC')))
            {
                //Iterate and prepare list.
                for(Integer i=0;i<lstUniqueDates.size();i++)
                {
                    for(ActivityInnerClass rec:lstActivities)
                    {
                        //To add all Acitivities matching the sorted Date
                        if(lstUniqueDates.get(i)==rec.ActivityDate)
                        {
                            rec.rowIndex =lstTmpActRecs.size()+1;
                            lstTmpActRecs.add(rec);
                        }
                    }
                }
            }
            else //If softing direction is DESC
            {
                //Iterate and prepare list in reverse order. 
                for(Integer i=lstUniqueDates.size()-1;i>=0;i--)
                {
                    for(ActivityInnerClass rec:lstActivities)
                    {
                        //To add all Acitivities matching the sorted Date
                        if(lstUniqueDates.get(i)==rec.ActivityDate)
                        {
                            rec.rowIndex =lstTmpActRecs.size()+1;
                            lstTmpActRecs.add(rec);
                        }
                    }
                }            
            }
            
            lstActivities=lstTmpActRecs;
system.debug('##########lstTmpActRecs##############'+lstTmpActRecs);            
        }
        return lstActivities;
}

public PageReference sort()
{
    //Toggle sorting order.
    sortDirection = (sortDirection.equalsIgnoreCase('ASC'))? 'DESC' : 'ASC';
    lstActivities=sortList(lstActivities);
    return null;
}

//CommandLink handler, to show complete description text.
public PageReference FullDesciption()
{
    Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
    
    //Toggle the More/Lesser link button on VF Page.
    lstActivities.get(rowIndex-1).isElipsesOn=!lstActivities.get(rowIndex-1).isElipsesOn;
    return null;
}

//Inner class to hold common field values from Event and Task records.
public class ActivityInnerClass
{
    public Id recId {get;set;}
    public string Subject {get;set;}
    public DateTime ActivityDate{get;set;}
    public DateTime CompletionDate{get;set;}
    public string Description{get;set;}
    public string OwnerName{get;set;}
    public string Status{get;set;}
    public boolean isEventType {get;set;}
    public Integer rowIndex {get;set;}
    public string OutcomeNumber{get;set;}
    public boolean isElipsesOn {get;set;}
} 
public testMethod static void testController()
{
    Contact recCon = new Contact(Salutation='Mr', FirstName='Abc',LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
    insert recCon;        
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
    insert serv;    
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    
    insert recSU;
    
    Event eveRec = new Event(WhatId=recSU.id,Subject='Test Subject',DurationInMinutes=30,
            ActivityDateTime=System.now()-1,Format__c='Face to Face', In_Out__c='Outgoing',Location_Type_Event__c='Service User Home');
    insert eveRec;
    
    Event eveRec2 = new Event(WhatId=recSU.id,Subject='Test Subject',DurationInMinutes=30,
            ActivityDateTime=System.now()-1,Format__c='Face to Face', In_Out__c='Outgoing',Location_Type_Event__c='Office');
    insert eveRec2;    

    Task tskRec = new Task(WhatId=recSU.id,Subject='Test Subject',Format__c='Face to Face', 
            In_Out__c='Outgoing',Status='Completed',Completion_Date_Task__c=Date.Today(),Staff_Time_Minutes__c=30,
            Volunteer_Time_Minutes__c=30);
    insert tskRec; 
    
    Event_Attendance_Details__c EADRec = new Event_Attendance_Details__c(Service_Usage__c=recSU.id, Event_Date_and_Time__c=System.now()-1);  
    insert EADRec; 
    
    ApexPages.currentPage().getParameters().put('id', recSU.id);  
    ServiceUsageRelatedActivitiesController conCls= new ServiceUsageRelatedActivitiesController(new ApexPages.StandardController(recSU));
    ApexPages.currentPage().getParameters().put('rowIndex', '1'); 
    
    conCls.FullDesciption();
    conCls.sort();
    
    update eveRec;

}   
}