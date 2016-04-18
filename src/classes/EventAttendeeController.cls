/******************************************************************************************
 *  Alzheimer's 
 *  
 *  Purpose : Provide methods to be called from Visual Force Pages.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-11-07
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: VF Controller with Various method handlers for 2 VF pages.
 *        1) EventUserAttendees 
*         2) EventContactAttendees
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2012-02-07  MT  removed secondary service user (Secondary_Service_User__c) 
 *  2013-03-27  MT  SoQL statement searching for events using autonumber not always working.
 *  2013-05-31  MT  Do not show duplicate events for same time, only ones for current event.
 *  2013-08-16  MT  Use of contacts as volunteers rather than users (Change 390)
 *  2014-12-23  MT  Change 575 - show summary counts of attendees to group events.
 *  2015-01-13  MT  Do not update records if they have not changed.Save Soql limits for real updates
 *  2015-01-19  LR  avoid null exceptions on Sort Methods  
 *  2015-01-21  MT  Tidy code - remove blocks of commented out code 
 *                  and review recurring events where duplicate EADs are being created. 
 *                  Move test to separate test class and increase Api Version. 
 *  2015-05     LV  Support of Print Event Register. 
*******************************************************************************************/
public class  EventAttendeeController
{

public ApexPages.StandardController stdController;
public Event eve;
public string strEventAutoNum {get;set;}
public datetime dtActivityDateTime {get;set;}
public string strServiceName {get;set;}
public boolean isServiceEvent {get;set;}
public list<ContactAttendeeClass> lstAvailableCons {get;set;}
public list<ContactAttendeeClass> lstAllOrderedCons {get;set;}
public list<ContactAttendeeClass> lstAddedCons {get;set;}
public list<WorkerAttendeeClass> lstWorkerAttendance {get;set;}
public List<SelectOption> lstAttendanceStatus {get;set;}  
public List<Event_Attendance_Details__c> lstEADToDel {set;get;}
public string removeConId {get;set;}
public string strInsertWithStatus {get; set;}
public string returnID {get;set;}
public string Log {get;set;}
public string Total_Attendees_ByType {get;set;}

private Id idWhatId {get;set;}
private List<Event> lstEventUsrAttendee {set;get;}
private list<VolunteerAttendeeClass> lstVolunteerAttendance {get;set;}
private list<UserAttendeeClass> lstUserAttendance {get;set;}
private Set<Id> setSUIds = new Set<Id>();
private RecordType VolunteerContactRecordType;
private RecordType ProfessionalContactRecordType;

private integer MAXRECORDSTOUPDATE = 50;
private boolean hasExceptionRaised=false;
private String strWhatId;
private Set<Id> setAddedContactIds = new Set<Id>();
private Integer IntUpdatedAttendedRecords;
private Integer IntPWDAttendeeCount;
private Integer IntCarerAttendeeCount;

/*****************************************
* Standard controller constructor.
*****************************************/
Public EventAttendeeController(ApexPages.StandardController pController) {

        //reset public variables 
        
        
        lstVolunteerAttendance = new List<VolunteerAttendeeClass>();
        lstWorkerAttendance = new List<WorkerAttendeeClass>();
        
        lstAvailableCons = new list<ContactAttendeeClass>();
        lstAllOrderedCons=new list<ContactAttendeeClass>();
        
        lstAddedCons = new List<ContactAttendeeClass>();
        lstEADToDel = new List<Event_Attendance_Details__c>();

        setAddedContactIds = new Set<Id>();

        //set up attendance status selection list
        lstAttendanceStatus = new List<SelectOption>();
        lstAttendanceStatus.add(new SelectOption('','--None--'));
        //Prepare a list of from AttendanceStatus, to show on DataTable column header.
        for(Schema.PicklistEntry pickList : Event_Attendance_Details__c.Attendance_Status__c.getDescribe().getPickListValues())
        {
            lstAttendanceStatus.add(new SelectOption(pickList.getValue(),pickList.getLabel()));
        }
      
        /*****************************************
        * Get Event and set up initial details
        ******************************************/
        // Saving the Old URL
        returnID = ApexPages.currentPage().getParameters().get('retURL'); 
        if(returnID != null) {
            if(returnID.lastIndexOf('/') > -1) {
                returnID = returnID.substring(returnID.lastIndexOf('/')+1);
            }
        }
        
        System.Debug('Constructor is Fired!');
        stdController = pController;
        
        eve = (Event) stdController.getRecord();
        
        //Retrieve the Event AutoNumber value.
        GetEventDetails();
        
        //get record types for Volunteers and Professionals
        VolunteerContactRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Contact' and DeveloperName = 'Volunteer'];
        ProfessionalContactRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Contact' and DeveloperName = 'Professional'];
        
        //Retrieve Event WhatId to check whether is it scheduled for Service.
        strWhatId = [Select WhatId from Event where id =: eve.id].WhatId;
        
        //Check if Event is scheduled for Services/GuideBook
        if([select id from Services__c where id =:strWhatId].size()==0) 
        {
            isServiceEvent=false;
            return;
        }    
        
        isServiceEvent=true;
        
        //Retrieve all User attendees from Event.  SoQL statement searching for events using autonumber not always working.
        //retrieve using datetime and whatid of event.
        lstEventUsrAttendee = [Select Id,OwnerId,Owner.Name,IsChild,What.Name,EventNumber__c from Event where Whatid=:idWhatId  AND ActivityDateTime =: dtActivityDateTime ];

        logMessage('idWhatId : ' + idWhatId + ' ActivityDateTime : ' + dtActivityDateTime + ' strEventAutoNum : ' + strEventAutoNum + '      lstEventUsrAttendee.size() :' + lstEventUsrAttendee.size());
        logMessage('lstEventUsrAttendee : ' + lstEventUsrAttendee);
        
        // get a list of existing event attendee details
        List<Event_Attendance_Details__c> lstTmpEADAttendee = GetExistingEventAttendanceDetails(lstEventUsrAttendee);           
      
        // Get Contacts (Service Users and Volunteers) from EAD
        PrepareServiceUserAndVolunteers(lstTmpEADAttendee);

        // Sort Added Contacts (Service Users)
        lstAddedCons = sortMethod(lstAddedCons);
        
        // Sort All Contacts (Service Users)
       lstAllOrderedCons=sortMethod(lstAllOrderedCons);

        // Get Users for Worker attendances from Event
        lstUserAttendance = PrepareUsers(lstEventUsrAttendee, lstTmpEADAttendee);
        
        // Merge the list of users and volunteers to make one list of "workers"
        // single list is lstWorkerAttendance
        lstWorkerAttendance = MergeUserAndVolunteers();
        
        // prepare list of service users who are not already attending  
        PrepareListNewServiceUsers();
        
        logListsPrepared();

        
    }
/***************************************************
* Retrieve event record and set up variables
***************************************************/
Public void GetEventDetails(){        
        eve = [Select id,Location, Total_Attendees_ByType__c, StartDateTime,
                      Subject,EventNumber__c,IsRecurrence, 
                      WhatId, Number_of_Person_with_Dementia_Attendees__c, 
                      Number_of_Carer_Attendees__c, 
                      ActivityDateTime,RecurrenceActivityId 
        from Event where id =:ApexPages.currentPage().getParameters().get('id')];
        
        strEventAutoNum =eve.EventNumber__c;
        Total_Attendees_ByType=eve.Total_Attendees_ByType__c;
        
        dtActivityDateTime  = eve.ActivityDateTime;
        idWhatId = eve.WhatId;
}
/***************************************************
* Contact (Service Users and Volunteers)
***************************************************/
Private void PrepareServiceUserAndVolunteers(List<Event_Attendance_Details__c> lstTmpEADAttendee ){
        // Prepares a list of already added Contact attendees.
        // Service User attendees are added to  lstAddedCons and their ID to setAddedContactIds.
        // Also any volunteers are added to lstVolunteerAttendance.
        for(Event_Attendance_Details__c rec: lstTmpEADAttendee)
        {
              if(rec.Type__c.equalsIgnoreCase('Contact')  && (rec.Contact__r.RecordType.Id !=VolunteerContactRecordType.Id))
              {
                  ContactAttendeeClass cls = new ContactAttendeeClass();
                  cls.contactName=rec.Contact__r.Contact_Full_Name__c;//rec.Contact__r.Name;
                  //new line added ny LR
                  cls.contactFullName= rec.Contact__r.Name;  
                  cls.PersonID=rec.Contact__r.Client_reference_number__c;          
                    cls.recEAT=rec;
                    //save old EAD record so we can compare and see if an update is necessary
                    cls.OldAttendance_Status =rec.Attendance_Status__c;
                    cls.OldNotes = rec.Notes__c;
                    cls.isSelected=false;
                    cls.contactId=rec.Contact__c;
                    cls.Phone=rec.Contact__r.HomePhone;
                    cls.postCode=rec.Contact__r.MailingPostalCode;
                    cls.birthDate=rec.Contact__r.Birthdate; 
                    cls.contactRecTypeName=rec.Contact__r.RecordType.Name;    
 
                  lstAddedCons.add(cls);
                  lstAllOrderedCons.add(cls);
                  
                  setAddedContactIds.add(rec.Contact__c);
              }
              //add volunteers to separate list
              if(rec.Type__c.equalsIgnoreCase('Contact')  && (rec.Contact__r.RecordType.Id == VolunteerContactRecordType.Id))
              {
                  VolunteerAttendeeClass cls = new VolunteerAttendeeClass();
                  cls.volunteerName=rec.Contact__r.Name; //rec.Contact__r.Contact_Full_Name__c;
                  cls.JobTitle =rec.Contact__r.Title;
                  cls.StaffVolunteerType = rec.Contact__r.Worker_Type__c;
                  cls.recEAT=rec;
                  cls.volunteerId=rec.Contact__c;
                  cls.volunteerContactRecTypeName=rec.Contact__r.RecordType.Name;    
 
                  lstVolunteerAttendance.add(cls);
              }
        }
        
    }
        
/***************************************************
* PrepareUsers - get worker attendance from event 
*                and EAD (if there is not an EAD then instantiate a new one). 
*       Returns lstUserAttendance
***************************************************/
Private List<UserAttendeeClass>  PrepareUsers(List<Event> pLstEventUserAttendee, List<Event_Attendance_Details__c> pLstEADAttendee){
        List<UserAttendeeClass> rtnLstUserAttendance = new List<UserAttendeeClass>();
        Set<Id> tmpSetOwnerIds = new Set<Id>();

        Map<string,Event_Attendance_Details__c> tmpMapEADUserOwner = new Map<string,Event_Attendance_Details__c>();
        
        //Loop through to pick record for Contact attendees.
        for(Event_Attendance_Details__c rec: pLstEADAttendee)
        {
            if(rec.Type__c.equalsIgnoreCase('User')){
                tmpMapEADUserOwner.put(rec.User__c,rec);
                logMessage('Adding tmpMapEADUserOwner : ' + rec.User__r.Name + ' EventNumber__c : ' + rec.EventNumber__c);
            }
        }
        
        for(Event eveRec: pLstEventUserAttendee)
        {
            if(!tmpSetOwnerIds.contains(eveRec.OwnerId))
                tmpSetOwnerIds.add(eveRec.OwnerId);
        }
        logMessage('tmpSetOwnerIds : ' + tmpSetOwnerIds);

        Map<id,User> mapUserWorkerType = new Map<id,User>([Select Worker_Type__c from User where id =:tmpSetOwnerIds]);
        //Loop to populate User attendee list.
        for(Event rec: pLstEventUserAttendee)
        {
              strServiceName=rec.What.Name;
              UserAttendeeClass cls = new UserAttendeeClass();
              
              cls.eventId=rec.Id;
              cls.ownerId=rec.OwnerId;
              cls.userName=rec.Owner.Name;
              cls.StaffVolunteerType = (mapUserWorkerType.containsKey(rec.OwnerId))?mapUserWorkerType.get(rec.OwnerId).Worker_Type__c:'';
              //If User is already added,then copy those values.
              if(tmpMapEADUserOwner.containsKey(rec.OwnerId))
              {
                  cls.recEAT=tmpMapEADUserOwner.get(rec.OwnerId);
                  logMessage('Retrieving User Invitee : ' + rec.Owner.Name + ' for rec.EventNumber__c: ' + rec.EventNumber__c);
              }
              else //If it is a new User Invitee then create list item with default values.
              {
                  cls.recEAT=new Event_Attendance_Details__c(EventId__c=rec.id,EventNumber__c=strEventAutoNum,Type__c='User',User__c=rec.OwnerId,Event_Date_and_Time__c = eve.ActivityDateTime, Event_Subject__c = eve.Subject );
                  logMessage('Adding User Invitee who does not have EAD: ' + rec.Owner.Name + ' for rec.EventNumber__c: ' + rec.EventNumber__c);
              }
              rtnLstUserAttendance.add(cls);
        }
        logMessage('rtnLstUserAttendance  :' +   rtnLstUserAttendance);
        return rtnLstUserAttendance;
    }
    
/***************************************************
* PrepareListNewServiceUsers
*       Create a list of Contacts which are not added.
*       List is lstAvailableCons
***************************************************/
Private void PrepareListNewServiceUsers(){

        /***************************************************
        * Retrieve all Contacts from Service Usage object for Event Service.
        ***************************************************/
        RetrieveServiceUsagesWithSharing clsSURecs = new RetrieveServiceUsagesWithSharing();
        
        /***************************************************
        * Create a list of Contacts which are not added.
        ***************************************************/
       
        for(Service_Usage__c rec: clsSURecs.getSURecordsOfService(strWhatId))
        {
       
          if(rec.Primary_Service_User__c !=null && !setAddedContactIds.contains(rec.Primary_Service_User__c))
          {
            ContactAttendeeClass tmpCls = new ContactAttendeeClass();
            tmpCls.isSelected=false;
            tmpCls.contactId=rec.Primary_Service_User__c;
            tmpCls.contactName=rec.Primary_Service_User__r.Contact_Full_Name__c;
            tmpCls.contactFullName=rec.Primary_Service_User__r.Name;
            tmpCls.Phone=rec.Primary_Service_User__r.HomePhone;
            tmpCls.postCode=rec.Primary_Service_User__r.MailingPostalCode;
            tmpCls.birthDate=rec.Primary_Service_User__r.Birthdate;
            tmpCls.contactRecTypeName=rec.Primary_Service_User__r.RecordType.Name;
            tmpCls.recEAT=new Event_Attendance_Details__c( Contact__c=rec.Primary_Service_User__c,
                EventNumber__c=strEventAutoNum, Type__c='Contact',EventId__c=eve.id,
                Service_Usage__c=rec.id,Event_Subject__c=eve.Subject,Event_Date_And_Time__c=eve.ActivityDateTime);
            lstAvailableCons.add(tmpCls);
            lstAllOrderedCons.add(tmpCls);
            
            }
            
           
          
          
          
               
          
          
        }
        
    }

/***************************************************
* now merge lstUserAttendance and lstVolunteerAttendance to create a single list - lstWorkerAttendance
***************************************************/        
Private List<WorkerAttendeeClass> MergeUserAndVolunteers(){
        List<WorkerAttendeeClass> rtnList = new List<WorkerAttendeeClass>();
        for (UserAttendeeClass rec: lstUserAttendance)
        {  WorkerAttendeeClass cls = new WorkerAttendeeClass();
           cls.eventId = rec.eventId;
           cls.workerId = rec.ownerId;
           cls.workerName = rec.UserName;
           cls.StaffVolunteerType = rec.StaffVolunteerType;
           cls.recEAT = rec.recEAT;
           
           rtnList.add(cls);
        }
        for (VolunteerAttendeeClass rec: lstVolunteerAttendance)
        {
            WorkerAttendeeClass cls = new WorkerAttendeeClass();
            cls.workerId = rec.volunteerId;
            cls.workerName = rec.VolunteerName;
            cls.StaffVolunteerType = rec.StaffVolunteerType;
            cls.recEAT = rec.recEAT;
            
            rtnList.add(cls);
        }
        return rtnList;
}
/***************************************************
* GetExistingEventAttendanceDetails
* Get existing Event attendee detail records
***************************************************/
Private List<Event_Attendance_Details__c> GetExistingEventAttendanceDetails(List<Event> pLstEventUsrAttendee){
        List<Event_Attendance_Details__c> rtnLstEADAttendee = new List<Event_Attendance_Details__c>();
    
       //get the set of autonumbers for this event (one for each user who has been invited + owner)
        Set<String> setEventAutoNum = new Set<String>();
        for(Event eveRec: pLstEventUsrAttendee)
        {
            if(!setEventAutoNum.contains(eveRec.EventNumber__c))
                setEventAutoNum.add(eveRec.EventNumber__c);
        }
        logMessage('setEventAutoNum : ' + setEventAutoNum);
    
        //Retrieve records from junction object Event_Attendance_Details__c, if added earlier.
        rtnLstEADAttendee = [Select Attendance_Duration_Minutes__c,Travel_Time_Minutes__c,Type__c,
           Preparation_Time_Minutes__c,EventAttendeeId__c,Contact__c,Contact__r.LastName,Contact__r.Name,EventId__c,User__c, User__r.Name, 
           Attendance_Status__c,Notes__c,EventNumber__c, Contact__r.HomePhone, Contact__r.MailingPostalCode, Contact__r.Birthdate,Contact__r.Contact_Full_Name__c,
           Contact__r.RecordType.Name,Contact__r.Record_Type_Name__c,Contact__r.Client_reference_number__c, Contact__r.Title, Contact__r.Worker_Type__c,Service_Usage__c,Event_Subject__c,Event_Date_And_Time__c,Attendance_Type__c
            from Event_Attendance_Details__c where EventNumber__c=:setEventAutoNum]; 
        
        logMessage('rtnLstEADAttendee : ' + rtnLstEADAttendee);
        return rtnLstEADAttendee;
   }


/******************************************************************************************
* Check for blanks
*****************************************************************************************/   
private list<ContactAttendeeClass> CheckForBlanks(list<ContactAttendeeClass> objList) {
    
    try{
        List<ContactAttendeeClass> newList = new List<ContactAttendeeClass>();
        for(ContactAttendeeClass eachItem : objList) {
            if(eachItem.contactName != null) {
                newList.add(eachItem);
            }
        }
        
        objList = newList;
    } catch (Exception ex) {
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
        ApexPages.addMessage(message);
        hasExceptionRaised=true;
        return null;
    }
    return objList;
}
/******************************************************************************************
* Sort Workers
*****************************************************************************************/
private list<WorkerAttendeeClass> sortMethodWorkers(list<WorkerAttendeeClass> objList){
    try {
          Map<String,String> mapSorting_l = new Map<String,String>();
          list<WorkerAttendeeClass> temp = new List<WorkerAttendeeClass>();
          for(WorkerAttendeeClass rec_l:objList){
               //Code added by lakshmi R 19/01 to check whether WorkerName is null 
              if(rec_l.WorkerName!=null){
                mapSorting_l.put(rec_l.WorkerName, rec_l.WorkerName);
              }
           }
          List<string> lstSorting_l = mapSorting_l.values();
          lstSorting_l.sort();
          Map<String, WorkerAttendeeClass> tempMap_l = new Map<String, WorkerAttendeeClass>();
          for(WorkerAttendeeClass cac_l:objList){
         
              tempMap_l.put(cac_l.WorkerName, cac_l);
              
          }
          //Integer listSize_l = lstSorting_l.size();
          for(String WorkerName_1 : lstSorting_l){
              for(String rec_l:tempMap_l.keyset()){
                  //split the formula field value which returns hyperlink value and compare to sort the column
                  if(rec_l==WorkerName_1){
                      temp.add(tempMap_l.get(rec_l));
                      tempMap_l.remove(rec_l);
                  }
              }
          }
          objList=temp ;
    } catch (Exception ex) {
        logMessage('exception during sortMethodWorkers - ' + ex.getMessage());
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
        ApexPages.addMessage(message);
        hasExceptionRaised=true;
        return null;
    }
      return objList;   
}
/******************************************************************************************
* Sort Attendees
******************************************************************************************/
private list<ContactAttendeeClass> sortMethod(list<ContactAttendeeClass> objList) {
    
    try {
      //Sorting added list by Person name, because we are using hyperlink formulea field, we have to split to achieve sorting.
      Map<String,String> mapSorting_l = new Map<String,String>();
      list<ContactAttendeeClass> temp = new List<ContactAttendeeClass>();
      for(ContactAttendeeClass rec_l:objList){
       //Code added by lakshmi R 19/01 to check whether ContactName is null to avoid null exception
          if(rec_l.contactName!=null){
           
              mapSorting_l.put(rec_l.contactName,rec_l.contactName.split('>')[1]);
              system.debug('list of contact'+mapSorting_l);
          }
      }
      List<string> lstSorting_l = mapSorting_l.values();
      lstSorting_l.sort();
      Map<String, ContactAttendeeClass> tempMap_l = new Map<String, ContactAttendeeClass>();
      for(ContactAttendeeClass cac_l:objList){
      if(cac_l.contactName!=null){
          tempMap_l.put(cac_l.contactName, cac_l);
          
          }
      
      }
      Integer listSize_l = lstSorting_l.size();
      for(String contactName_l : lstSorting_l){
          for(String rec_l:tempMap_l.keyset()){
              //split the formula field value which returns hyperlink value and compare to sort the column
              if(rec_l.split('>')[1].equals(contactName_l)&&rec_l.split('>')[1]!=null){
              
                  temp.add(tempMap_l.get(rec_l));
                  tempMap_l.remove(rec_l);
              }
          }
      }
      objList=temp ;
       
    } catch (Exception ex) {
        logMessage('exception during ContactAttendeeClass sortMethod - ' + ex.getMessage());
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
        ApexPages.addMessage(message);
        hasExceptionRaised=true;
        return null;
    }
      return objList;
}
/***************************************************
* Debug messages to show what we have got.
***************************************************/
 Private void logListsPrepared() {
        logMessage('lstVolunteerAttendance.size() : ' + lstVolunteerAttendance.size());
        logMessage('lstVolunteerAttendance : ' + lstVolunteerAttendance);
      
        lstWorkerAttendance =sortMethodWorkers(lstWorkerAttendance); 
        logMessage('lstWorkerAttendance.size() : ' + lstWorkerAttendance.size());
        logMessage('lstWorkerAttendance : ' + lstWorkerAttendance);
      
        lstAvailableCons = sortMethod(lstAvailableCons);
        //lstAllOrderedCons.sort();
        lstAllOrderedCons= sortMethod(lstAllOrderedCons);
        logMessage('lstAvailableCons.size() : ' + lstAvailableCons.size());
        logMessage('Available Contacts :' +   lstAvailableCons);
        lstAddedCons = CheckForBlanks(lstAddedCons);
        logMessage('Added Contacts :' + lstAddedCons);
    }         
 
 /******************************************************************************************
* Save and Return Button handler.
*****************************************************************************************/
public PageReference saveUsersNReturn() {
    try{hasExceptionRaised=false;
      saveUsers();
      }catch(Exception ex){
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
                    ApexPages.addMessage(message);
                    return null;}
  if (hasExceptionRaised) {return null;}
  else {return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));}
  //return null;
 }
/******************************************************************************************
* Save User and Return to Service Usage Page Button handler .
*****************************************************************************************/
public PageReference saveUsersNServiceUsers() {
    try{hasExceptionRaised=false;
      saveUsers();
      }catch(Exception ex){
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
                    ApexPages.addMessage(message);
                    return null;}
  if (hasExceptionRaised) {return null;}
  else {
        GetEventDetails();
        return new PageReference('/apex/EventContactAttendees?id='+ApexPages.currentPage().getParameters().get('id'));}
  //return null;
 }
  
/******************************************************************************************
* Mark for Deletion from selected list.
*****************************************************************************************/
public PageReference RemoveContact() {

    Integer cnt = 0;
     for(ContactAttendeeClass rec:lstAddedCons)
     {
         if(rec.recEAT.Contact__c==removeConId)
         {
            rec.isSelected=false;
            lstAvailableCons.add(rec);
            lstAddedCons.remove(cnt);

            //If the Contact was already added then should delete record from EAD.
            if(rec.recEAT.id!=null)
            {
                lstEADToDel.add(rec.recEAT);
            }    
            
            //Removed record, if have Service Usage Id, then we have to populate Date Of Last Activity field.    
            if(rec.recEAT.Service_Usage__c !=null && !setSUIds.contains(rec.recEAT.Service_Usage__c))
                setSUIds.add(rec.recEAT.Service_Usage__c);    
            
            
            break;
         }
         cnt++;
     }
  return null;
  //return null value;
 } 
 
/******************************************************************************************
* Save and Return Button handler.
*****************************************************************************************/
public PageReference saveContactsNReturn() {
  try{
      hasExceptionRaised=false;
      this.log='';
      saveContacts();
  }catch(Exception ex){
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
                    ApexPages.addMessage(message);
                    return null;
                    }
  If (hasExceptionRaised) {return null;}
  else {return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
        //return null;
  }
  
 } 
/******************************************************************************************
* Save and Return to Workers Button handler.
*****************************************************************************************/
public PageReference saveContactsNWorkers() {
  try{
      hasExceptionRaised=false;
      this.log='';
      saveContacts();
  }catch(Exception ex){
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
                    ApexPages.addMessage(message);
                    return null;
                    }
  If (hasExceptionRaised) {return null;}
  else {
        GetEventDetails();
        return new PageReference('/apex/EventUserAttendees?id='+ApexPages.currentPage().getParameters().get('id'));}
  //return null;
 }

/******************************************************************************************
* Save button handler. Commit changes made To Contacts to junction object
*****************************************************************************************/
public PageReference saveContacts() {

    List<Event_Attendance_Details__c> lstContactAttendeeToUpsert = new  List<Event_Attendance_Details__c>();
    IntUpdatedAttendedRecords =0;
    IntPWDAttendeeCount =0;
    IntCarerAttendeeCount=0;
    // REMOVE List<String> eventNumberForSeries = new List<String>();
    
    
    logMessage('Gunish Says saveContacts');
   //For individual/single day Event. 
   if(!Eve.IsRecurrence){

        lstContactAttendeeToUpsert = lstBuildListContactAttendeeToUpsert();
        logMessage('IntPWDAttendeeCount :' + IntPWDAttendeeCount);
        logMessage('IntCarerAttendeeCount :' + IntCarerAttendeeCount);
        
        //update event with attendees.  Only do this for a single event. 
        Eve.Number_of_Person_with_Dementia_Attendees__c  = IntPWDAttendeeCount;
        Eve.Number_of_Carer_Attendees__c = IntCarerAttendeeCount;
        }
   // For recurring event.
   else {
        //get a list of event numbers for the series
        // REMOVE eventNumberForSeries = lstBuildListEventNumbers();
        //build a list of service user attendees for the series.   
        lstContactAttendeeToUpsert = lstBuildListContactAttendeeSeriesToUpsert( );
        }
   //fail if too many to do!!   Attended EAD makes series of triggers fire as it updates last activity on Service Usage, so cannot do many at a time.
   if (IntUpdatedAttendedRecords>=MAXRECORDSTOUPDATE){
         ApexPages.Message message = new ApexPages.message(ApexPages.severity.Error,'Too many records are being updated to the status of \'Attended\' at once (' + MAXRECORDSTOUPDATE +').  Close screen and try again with a smaller number of updates.');
         ApexPages.addMessage(message);
         hasExceptionRaised=true;
         return null;
    }
  logMessage('Gunish Says Final Record Prepared :' + lstContactAttendeeToUpsert.size());
  logMessage('Gunish Says Final Record Prepared :' + lstContactAttendeeToUpsert);
  
  // Create a series record for each contact added to the list.
  // Create a set of Contacts added to the list and maintain that list,. 
  // REMOVE 
  // REMOVE if(eventNumberForSeries.size() > 0) {
  // REMOVE set<Id> tempContactIDs = new Set<Id>();
  // REMOVE integer counter = 0;
  // REMOVE List<Event_Attendance_Details__c> seriesEAD = new List<Event_Attendance_Details__c>();
  // REMOVE for(Event_Attendance_Details__c tempEAD : lstContactAttendeeToUpsert ) {
  // REMOVE   if(!tempContactIDs.contains(tempEAD.Contact__c)) {
  // REMOVE       tempContactIDs.add(tempEAD.Contact__c);
  // REMOVE       Event_Attendance_Details__c tmpRec2 = new Event_Attendance_Details__c();
  // REMOVE       tmpRec2.Attendance_Status__c = tempEAD.Attendance_Status__c;
  // REMOVE       tmpRec2.Notes__c = tempEAD.Notes__c;
  // REMOVE       tmpRec2.Contact__c = tempEAD.Contact__c; 
  // REMOVE       tmpRec2.EventNumber__c = eventNumberForSeries.get(counter); 
  // REMOVE       tmpRec2.Type__c = 'Contact';
  // REMOVE       tmpRec2.Event_Subject__c = tempEAD.Event_Subject__c;
  // REMOVE       tmpRec2.Event_Date_And_Time__c = tempEAD.Event_Date_And_Time__c;
  // REMOVE        
  // REMOVE       seriesEAD.add(tmpRec2);
  // REMOVE       //counter;
  // REMOVE   }
  // REMOVE }
  // REMOVElstContactAttendeeToUpsert.addAll(seriesEAD);
  // REMOVE} 
    
  Savepoint sp = Database.setSavepoint();
  PassedExceptionClass passException = new PassedExceptionClass();
  //boolean hasDMLExceptionRaised=false;
  //Exception exToPass;
  
  if(lstContactAttendeeToUpsert.size()>0){
      try{
          upsert lstContactAttendeeToUpsert;
      }catch(Exception ex){passException.hasDMLExceptionRaised=true;passException.exToPass=ex;}
   }
  // delete EADs 
  DeleteContactEADs(passException);

  //If have Service Usage Id, then we have to populate Date Of Last Activity field.
  UpdateDateOfLastActivity(lstContactAttendeeToUpsert, passException);
  
  //Update Event 
  UpdateEvent(passException);
  
  //there should only be One EventAttendanceDetail for a Service_Usage__c and Event
  //delete duplicate ones
  
  logMessage('DML Exception Status =' + passException.hasDMLExceptionRaised);
   // Revert the database to the original state
   if(passException.hasDMLExceptionRaised){        
       Database.rollback(sp);
       //throw exToPass;
       ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,passException.exToPass.getMessage());
       ApexPages.addMessage(message);
       hasExceptionRaised=true;
       return null;
   }    
  return null;
}
/******************************************************************************************
* Build Contacts for Saving - for one event
*****************************************************************************************/ 
private List<Event_Attendance_Details__c> lstBuildListContactAttendeeToUpsert(){
    List<Event_Attendance_Details__c> rtnLstContactAttendee = new  List<Event_Attendance_Details__c>();
    // REMOVE Set<string> setEveNums = new Set<string>();
    //prepare a list of Contacts to be created.
    for(ContactAttendeeClass rec: lstAddedCons){
      //do not update records unless necessary
      if (rec.OldAttendance_Status ==null)
        {                                          
          rtnLstContactAttendee.add(rec.recEAT);
          logMessage('Added new contact ' + rec.ContactName); 
          if (rec.recEAT.Attendance_Status__c=='Attended') {IntUpdatedAttendedRecords++;}
        }
      else if (((rec.recEAT.Attendance_Status__c <>rec.OldAttendance_Status )
                                  ||(rec.recEAT.Notes__c <> rec.OldNotes)))
        {                                          
          rtnLstContactAttendee.add(rec.recEAT);
          logMessage('Updated existing contact ' + rec.ContactName); 
          if (rec.recEAT.Attendance_Status__c=='Attended') {IntUpdatedAttendedRecords++;}
        }
        else {logMessage('No changes to  ' +  rec.recEAT.Attendance_Status__c);  
                         logMessage('No changes to  ' +  rec.OldAttendance_Status );  }
         
        if(rec.contactRecTypeName=='Person with dementia' && rec.recEAT.Attendance_Status__c=='Attended'){
            IntPWDAttendeeCount++;
        }
        if(rec.contactRecTypeName=='Carer of Person with Dementia' && rec.recEAT.Attendance_Status__c=='Attended'){
            IntCarerAttendeeCount++;
        }
        
    }          
    // REMOVE for(Event_Attendance_Details__c recToDel: lstEADToDel){
    // REMOVE if(!setEveNums.contains(recToDel.EventNumber__c))
    // REMOVE     setEveNums.add(recToDel.EventNumber__c);    
    // REMOVE}
    
    return rtnLstContactAttendee;
}
/******************************************************************************************
* Build list of event numbers for the series
*****************************************************************************************/  
// REMOVE private List<String>  lstBuildListEventNumbers(){
// REMOVE   List<String> retLstEventNumberForSeries = new List<String>();
// REMOVE 
// REMOVE     List<Event> lstRecurEvents2= new List<Event>([select EventNumber__c,ActivityDateTime, isGroupEvent from Event where 
// REMOVE         ((Id =:Eve.id) or ((RecurrenceActivityId =:Eve.id) and ActivityDateTime>=:Datetime.now())) and IsRecurrence = true ]);
// REMOVE         
// REMOVE     System.Debug('Gunish XXX :' + lstRecurEvents2 );
// REMOVE     logMessage('Gunish Says List of recurring events :' + lstRecurEvents2);
// REMOVE     for(Event eachEvent : lstRecurEvents2) {
// REMOVE             retLstEventNumberForSeries.add(eachEvent.EventNumber__c);
// REMOVE         }
// REMOVE     logMessage('Gunish Says  list of series numbers :' + retLstEventNumberForSeries);
// REMOVE     logMessage('Event Number for Series :' + retLstEventNumberForSeries ) ;   
// REMOVE   return retLstEventNumberForSeries;
// REMOVE 
// REMOVE }
/******************************************************************************************
* For a deleted contact, remove all EADs for them 
*****************************************************************************************/  
private void AddAllEADforDeletedContacts(List<Event_Attendance_Details__c> lstEADForRecurEvents){
    //Delete removed contact from all occurrence in series.
    logMessage('Gunish Says To Delete:' + lstEADToDel);
    List<Event_Attendance_Details__c> tmpRecsToDel = new List<Event_Attendance_Details__c>();  

    for(Event_Attendance_Details__c recToDel: lstEADToDel){
    if(recToDel.EventAttendeeId__c == null) {
        for(Event_Attendance_Details__c recEAD: lstEADForRecurEvents){
            if(recToDel.EventAttendeeId__c ==null && recToDel.Contact__c==recEAD.Contact__c ){
                tmpRecsToDel.add(recEAD);
            }
        }              
     }
    }
    lstEADToDel.addAll(tmpRecsToDel);

    logMessage('Gunish Says Final Record to Delete :' +lstEADToDel ); 
    
}
/******************************************************************************************
* Update Service Usage records with the date of last activity
*****************************************************************************************/ 
Private void UpdateDateOfLastActivity(List<Event_Attendance_Details__c> lstContactAttendeeToUpsert, PassedExceptionClass passException) {
    
    for(Event_Attendance_Details__c rec:lstContactAttendeeToUpsert){
        if(rec.Service_Usage__c !=null && !setSUIds.contains(rec.Service_Usage__c))
            setSUIds.add(rec.Service_Usage__c);   
    }
    //Update date of last Activity field for service usage records.
    Map<Id,Date> mapSUActivityDates = ServiceUsageDateOfLastActivity.getDateOfLastActivity(setSUIds);
    List<Service_Usage__c> lstSUToUpdate = new List<Service_Usage__c>();
    if(mapSUActivityDates!=null){
        for(Id SUId:mapSUActivityDates.keySet()){
            lstSUToUpdate.add(new Service_Usage__c(Id=SUId,Date_of_last_Activity__c=mapSUActivityDates.get(SUId)));
        }
        try{
            Update(lstSUToUpdate);
        }catch(Exception ex){passException.hasDMLExceptionRaised=true;
                             passException.exToPass=ex;
                            }
    }
        
}        
/******************************************************************************************
*   Update the Event record
*****************************************************************************************/  
Private void UpdateEvent(PassedExceptionClass passException){
    try{ Update(eve);
        }catch(Exception ex){passException.hasDMLExceptionRaised=true;
                            passException.exToPass=ex;
                            logMessage('DML Exception Status =' + passException.hasDMLExceptionRaised);
                            }


}
/******************************************************************************************
*   Delete Existing EADs during Transaction     
*****************************************************************************************/
Private Void DeleteContactEADs(PassedExceptionClass passException){
    if(lstEADToDel.size()>0 && !passException.hasDMLExceptionRaised){
      Set<Id> setConsToDel = new Set<Id>();
      //Prepare list of Contacts against whose EAD were created, for deletion.
      for(Event_Attendance_Details__c recToDel: lstEADToDel){
           setConsToDel.add(recToDel.Contact__c);
       }
      try{
        //Delete, removed contacts from all Events.
        
        delete lstEADToDel;
        }
        catch(Exception ex){passException.hasDMLExceptionRaised=true;
                            passException.exToPass=ex;}
    }      
}   
/******************************************************************************************
* Build Contacts for Saving - for a recurring event series
*       Returns list of EADs, number of updated EADs with an attendance status of Attended.
*       Also updates list of deleted contacts (lstEADToDel)
*       
*****************************************************************************************/  
private List<Event_Attendance_Details__c> lstBuildListContactAttendeeSeriesToUpsert(){
    List<Event_Attendance_Details__c> rtnLstContactAttendee = new  List<Event_Attendance_Details__c>();
    Set<string> tmpSetEveNums = new Set<string>();
    Map<string,DateTime> tmpMapRecurEveDateTime = new Map<string,DateTime>();
    List<String> tempLstEventNos = new List<String>();
    List<DateTime> tmpLstActivityTime = new List<DateTime>();
    Set<DateTime> tmpSetOfActivityTime = new Set<DateTime>();
    Set<string> tmpSetUpdatedForEveNums = new Set<string>();
                
    //Get all the recurring event ids for event dates today or later. Exclude the ones in the past

    List<Event> lstRecurEvents= new List<Event>([select EventNumber__c,ActivityDateTime, isGroupEvent from Event where 
    ((Id =:Eve.id) or ((RecurrenceActivityId =:Eve.id) and ActivityDateTime>=:Datetime.now())) and IsRecurrence = false ]);

    //get a list of unique activity times - set used to check for duplicates
    for(Event rec2: lstRecurEvents){
       tempLstEventNos.add(rec2.EventNumber__c);
       if(rec2.ActivityDateTime>=Datetime.now()) {
           if(!tmpSetOfActivityTime.contains(rec2.ActivityDateTime)) {
                tmpSetOfActivityTime.add(rec2.ActivityDateTime);
                tmpLstActivityTime.add(rec2.ActivityDateTime);
            }
        }  
    }
    // get map of event number to activity times and a set of event numbers
     for(Integer i=0; i<tmpLstActivityTime.size(); i++){
        if(!tmpSetEveNums.contains(tempLstEventNos[i])){
            tmpSetEveNums.add(tempLstEventNos[i]);
            tmpMapRecurEveDateTime.put(tempLstEventNos[i],tmpLstActivityTime[i]);
        }
    }

    //Retrieve all EAD records for EventNumber for Contacts only
    List<Event_Attendance_Details__c> lstEADForRecurEvents = new List<Event_Attendance_Details__c>(
        [Select Contact__c, EventAttendeeId__c, EventId__c, EventNumber__c,Service_Usage__c, 
        Type__c from Event_Attendance_Details__c e where EventNumber__c=: tmpSetEveNums and Contact__c !=null]);
      
    //prepare a list of Contacts to be Upserted.
    for(ContactAttendeeClass recCAC: lstAddedCons){              

        //Find for existing contacts for every EventNumber and try to update Notes and Status fields.
        for(Event_Attendance_Details__c recEAD: lstEADForRecurEvents){
              //For records already added will be updated, hence populating record id.
              if(recCAC.recEAT.Contact__c==recEAD.Contact__c){
                    
                    Event_Attendance_Details__c tmpRec = new Event_Attendance_Details__c(id=recEAD.id,
                    
                    Attendance_Status__c=recCAC.recEAT.Attendance_Status__c,Notes__c=recCAC.recEAT.Notes__c);
                                        
                    rtnLstContactAttendee.add(tmpRec);  
                    
                    if (tmpRec.Attendance_Status__c=='Attended') {IntUpdatedAttendedRecords++;}
                    
                    if(!tmpSetUpdatedForEveNums.contains(recEAD.EventNumber__c+recEAD.Contact__c)) {
                        tmpSetUpdatedForEveNums.add(recEAD.EventNumber__c+recEAD.Contact__c);
                    }
              }   
        }//End for, recEAD
              
        //Add new EAD for all EventNumbers except if any occurrence was manually added earlier
        for(String strEveNum: tmpSetEveNums){
            
            //Add new contact for every event
            if(!tmpSetUpdatedForEveNums.contains(strEveNum+recCAC.recEAT.Contact__c)){
                      Event_Attendance_Details__c tmpRec = new Event_Attendance_Details__c(
                      Attendance_Status__c=recCAC.recEAT.Attendance_Status__c,Notes__c=recCAC.recEAT.Notes__c,
                      Contact__c=recCAC.recEAT.Contact__c, EventNumber__c=strEveNum, Type__c='Contact',
                      Service_Usage__c=recCAC.recEAT.Service_Usage__c,
                      Event_Subject__c=recCAC.recEAT.Event_Subject__c,
                      Event_Date_And_Time__c=tmpMapRecurEveDateTime.get(strEveNum));//recCAC.recEAT.Event_Date_And_Time__c);
                      
                    
                      if(tmprec.Event_Date_And_Time__c>=Datetime.now()) {
                          rtnLstContactAttendee.add(tmpRec); 
                          if (tmpRec.Attendance_Status__c=='Attended') {IntUpdatedAttendedRecords++;}}
                  }
        }//end for, strEveNum
      
      
    }//End for, recCAC

    //get all affected EADs for a contact to be removed
    AddAllEADforDeletedContacts(lstEADForRecurEvents);

    return rtnLstContactAttendee;
}
/******************************************************************************************
* Save Users.   Save button handler. Commit changes made to invitee users to junction object
*****************************************************************************************/
public PageReference saveUsers() {
    integer WorkerAttendeeCount=0;
    integer VolunterAttendeeCount=0;
      logMessage ('Saving Users');
      List<Event_Attendance_Details__c> lstUserAttendeeToCreate = new  List<Event_Attendance_Details__c>();
      //prepare a list of User Invitees to be created.
      for(WorkerAttendeeClass rec: lstWorkerAttendance)
      {
          lstUserAttendeeToCreate.add(rec.recEAT);
          if (rec.StaffVolunteerType=='Staff' && rec.recEAT.Attendance_Status__c=='Attended'){
            WorkerAttendeeCount++;
          }
          else if (rec.StaffVolunteerType=='Volunteer' && rec.recEAT.Attendance_Status__c=='Attended'){
            VolunterAttendeeCount++;
          }
      }
      logMessage ('Saving Users lstUserAttendeeToCreate.size() : ' + lstUserAttendeeToCreate.size());

      Eve.Number_of_Worker_Attendees__c=WorkerAttendeeCount ;
      Eve.Number_of_Volunteer_Attendees__c=VolunterAttendeeCount;
      // Create a savepoint because the data should not be committed to the database
      Savepoint sp = Database.setSavepoint();
      boolean hasDMLExceptionRaised=false;
      Exception exToPass;
  
      if(lstUserAttendeeToCreate.size()>0)
      {
          try
          {
          upsert lstUserAttendeeToCreate;
          }catch(Exception ex){exToPass=ex;hasDMLExceptionRaised=true;}
      }
        try{ Update(eve);
        }catch(Exception ex){hasDMLExceptionRaised=true;exToPass=ex;
                            }
      // Revert the database to the original state on Exception
      if(hasDMLExceptionRaised)
      {
        Database.rollback(sp);      
        //throw exToPass;
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,exToPass.getMessage());
        ApexPages.addMessage(message);
        return null;
      }  
      
      return null;
    }
/******************************************************************************************
* Add button handler, to add contacts to list.
*****************************************************************************************/
public PageReference AddToList() {
      list<ContactAttendeeClass> lstTmp = new list<ContactAttendeeClass>();
      Integer cnt=0;
      for(ContactAttendeeClass rec: lstAvailableCons){
          if(rec.isSelected){
              rec.recEAT.Attendance_Status__c=strInsertWithStatus;
              lstAddedCons.add(rec);
          }else{
              lstTmp.add(rec);
          }
      }
      lstAvailableCons = lstTmp;
               
      //Sorting added list by Person name, because we are using hyperlink formulea field, we have to split to achieve sorting.
      Map<String,String> mapSorting = new Map<String,String>();
      for(ContactAttendeeClass rec:lstAddedCons){
          if(!mapSorting.containsKey(rec.contactName.split('>')[1])){
              mapSorting.put(rec.contactName,rec.contactName.split('>')[1]);
          }
      }
      List<string> lstSorting = mapSorting.values();
      lstSorting.sort();
      List<ContactAttendeeClass> lstTmpRecs = new List<ContactAttendeeClass>();
      Map<String, ContactAttendeeClass> tempMap = new Map<String, ContactAttendeeClass>();
      for(ContactAttendeeClass cac:lstAddedCons){
          tempMap.put(cac.contactName, cac);
      }
      Integer listSize = lstSorting.size();

      for(String contactName : lstSorting){
          for(String rec:tempMap.keyset()){
              //split the formula field value which returns hyperlink value and compare to sort the column
              if(rec.split('>')[1].equals(contactName)){
                  lstTmpRecs.add(tempMap.get(rec));
                  tempMap.remove(rec);
              }
          }
      }
      lstAddedCons=lstTmpRecs ;
      return null;
  }
    /****************************************
    * Debugging Log
    ****************************************/
    public void logMessage (string logString) {
        if (this.Log ==null){
            this.Log =  logString;
            }
        else {
            this.Log = this.Log + '<br/><br/>' + logString;
        }
    }

/******************************************************************************************
*  Inner Class to maintain Available Contacts.  
*****************************************************************************************/
public class ContactAttendeeClass
{
    public boolean isSelected {get;set;}
    public Id contactId {get;set;}
    public string contactName {get;set;}
    public string contactFullName {get;set;}
    public string PersonID {get;set;}
    public string Phone {get;set;}
    public string postCode {get;set;}
    public date birthDate {get;set;}
    public string contactRecTypeName {get;set;}
    public Event_Attendance_Details__c recEAT {get;set;}
    public String OldAttendance_Status {get;set;}
    public String OldNotes {get;set;}
} 

/******************************************************************************************
*  Inner Class to maintain Volunteers recorded as Contacts
*****************************************************************************************/
public class VolunteerAttendeeClass
{
    public Id volunteerId {get;set;}
    public string volunteerName {get;set;}
    public string JobTitle {get;set;}
    public string StaffVolunteerType {get;set;}
    public string volunteerContactRecTypeName {get;set;}
    public Event_Attendance_Details__c recEAT {get;set;}
} 
/******************************************************************************************
*  Inner Class to maintain User Invitee.
*****************************************************************************************/
public class UserAttendeeClass
{
    public Id eventId {get;set;}
    public Id ownerId {get;set;}
    public string userName {get;set;}
    public string StaffVolunteerType {get;set;}
    public Event_Attendance_Details__c recEAT {get;set;}
}
/******************************************************************************************
*  Inner Class to maintain Workers (both User Invitee and Contacts)
*****************************************************************************************/ 
public class WorkerAttendeeClass
{
    
    public Id eventId {get;set;}
    //maps to ownerId for User, VolunteerId for Contact 
    public Id workerId {get;set;}
    public string workerName {get;set;}
    public string StaffVolunteerType {get;set;}
    public Event_Attendance_Details__c recEAT {get;set;}    
}
private class PassedExceptionClass
{
    boolean hasDMLExceptionRaised=false;
    Exception exToPass;
}

}