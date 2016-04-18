public without sharing class ServiceUsageTriggerHandler {
/********************************************************************************
* To stop triggers firing more than once, put them in a handler class.
*
* Object: Service Usage
* Mike Tinson
* 1 November 2012
*
* 18/12/2012 - commented out routine SUApexSharing as I have reactivated the trigger.
* 13/11/2013 - change 375 - Closing Service usage should close down future events
*              class changed to run WITHOUT sharing
* 16/11/2015 -By Lakshmi R- Included TriggerSUApexSharingAfterInsert in handler class SUApexSharing method
                            and call the method from serviceusagetrigger
********************************************************************************/
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean firstRun = true;
    public static boolean firstBeforeUpdateRun = true;
    private boolean b_gotRecordTypes = false;
   // Public String email{get;set;}
    Id idServExtnRecId;
    private boolean b_gotMapUserRole = false;
    Map<string,UserRole> mapUserRoles = new Map<string,UserRole>();
    Map<string,Group> mapRoleGroups = new Map<string,Group>();
    Map<string,Group> mapRoleAndSubGroups = new Map<string,Group>();
    
    public ServiceUsageTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    //needed for testing only    
    Public void SetFirstRun(boolean pbFirstRun){
        firstRun = pbFirstRun;
    }
    
    public void OnAfterInsert(Service_Usage__c[] newServiceUsages, Map<ID, Service_Usage__c> ServiceUsageMap){
        if (firstRun) {
            firstRun = false;
            for(Service_Usage__c newSU : newServiceUsages){
            // SUApexSharing (ServiceUsageMap, newSU);
            }
            UpdateLastTransactionDate (newServiceUsages);
            
        }
        else {
            System.debug('Already ran!');
            return;
            } 
            
            SUApexSharingAfterInsertBeforeUpdate(newServiceUsages);       
    }
    
   
    
    public void OnBeforeUpdate(Service_Usage__c[] oldServiceUsages, Service_Usage__c[] updatedServiceUsages, Map<ID, Service_Usage__c> oldServiceUsageMap, Map<ID, Service_Usage__c> ServiceUsageMap){
        if (firstBeforeUpdateRun ) {
            firstBeforeUpdateRun = false;
            for(Service_Usage__c newSU : updatedServiceUsages){
            //SUUpdateOwnerToAssignedWorker(oldServiceUsageMap, ServiceUsageMap, newSU);  
            SUUpdateLastActivityDate (oldServiceUsageMap, ServiceUsageMap, newSU); 
            }
        }
        else {
            System.debug('Already ran!');
            return;
            }
         
          SUApexSharingAfterInsertBeforeUpdate(updatedServiceUsages);   
     }
    
    public void OnAfterUpdate(Service_Usage__c[] oldServiceUsages, Service_Usage__c[] updatedServiceUsages, Map<ID, Service_Usage__c> oldServiceUsageMap, Map<ID, Service_Usage__c> ServiceUsageMap){
        if (firstRun) {
            firstRun = false;
            for(Service_Usage__c newSU : updatedServiceUsages){
            // SUApexSharing (ServiceUsageMap, newSU);
            SUUpdatePublicAlertMessage (oldServiceUsageMap, ServiceUsageMap, newSU);
            SUUpdateCloseSUCloseEAD (oldServiceUsageMap, ServiceUsageMap, newSU);
            }
            UpdateLastTransactionDate (updatedServiceUsages);
        }
        else {
            System.debug('Already ran!');
            return;
            }
            
    }
    
    
    public void OnAfterDelete(Service_Usage__c[] deletedServiceUsages, Map<ID, Service_Usage__c> ServiceUsageMap){
        UpdateLastTransactionDate (deletedServiceUsages);    
    }
    
    
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    }

private void SUUpdatePublicAlertMessage (Map<ID, Service_Usage__c> oldServiceUsageMap, Map<ID, Service_Usage__c> ServiceUsageMap, Service_Usage__c newSU) {
    String message;
    boolean b_updateContact = false;
    System.Debug('++++++++++++++++++++++++++++SUUpdatePublicAlertMessage');
    try{
        if(newSU.Public_Alert_Message_Required__c==true){
            Contact  newContact = [select Id, rrpu__Alert_Message__c, Service_Usage_Alert_Count__c from Contact where Id = :newSU.Primary_Service_User__c]; 
            if (newContact!=null){
                message = newContact.rrpu__Alert_Message__c;
                if (message==null) {
                    message = 'Contact Service Usage Owner.';
                    b_updateContact = true;
                } else if (message!=null && !message.contains('Contact Service Usage Owner.') && message.length()<226) {
                        message += ' Contact Service Usage Owner.';
                        b_updateContact = true;}
                if (b_updateContact==true) {
                    newContact.rrpu__Alert_Message__c = message;
                    Decimal alertCount = 0.0;
                    if (newContact.Service_Usage_Alert_Count__c!=null) {
                        alertCount=newContact.Service_Usage_Alert_Count__c + 1.0;}
                    else {alertCount=1.0;}
                    newContact.Service_Usage_Alert_Count__c = alertCount;
                    update newContact;}
            }
        } else {
            Service_Usage__c oldSU = oldServiceUsageMap.get(newSU.Id);
            if (oldSU.Public_Alert_Message_Required__c==true) {
            System.Debug('++++++++++++++++++++++++++++alert message cleared');
            // need to check all other service usages for this contact to see if they have an alert 
                Contact  newContact = [select Id, rrpu__Alert_Message__c, Service_Usage_Alert_Count__c from Contact where Id = :newSU.Primary_Service_User__c]; 
                if (newContact!=null){
                    Decimal alertCount = 0.0;
                    if (newContact.Service_Usage_Alert_Count__c!=null){alertCount=newContact.Service_Usage_Alert_Count__c;}  
                    alertCount = alertCount -1;
                    if (alertCount <=0) {
                        System.Debug('++++++++++++++++++++++++++++remove alert message');
                        message = newContact.rrpu__Alert_Message__c;
                        if (message!=null && message.contains('Contact Service Usage Owner.')) {
                            message = message.replace('Contact Service Usage Owner.', '');}
                        }
                    newContact.rrpu__Alert_Message__c = message;
                    newContact.Service_Usage_Alert_Count__c = alertCount;
                    update newContact;}
            }
            }
    }catch(Exception ex){
        //maximum length exceeded for rrpu_alert_message__c 
                newSU.addError('Error updating contact:' + ex.getMessage()+'. Contact The CRS Helpdesk.');

        }
    }
    /******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Sharing Service Usage with other Roles.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-11-16
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: Apex Trigger for After Insert Service Usage, to create Apex sharing for other locality roles, 
 *               based on Service Type and Service Locality.
 *  
 *     
 *  Modification History
 *
 *  Date         Who    Description
 *  2012-07-27   MT     Service Type string is longer than the Name of the Sharing Rule, 
 *                      therefore only use the first 35 characters to match.
 *  2014-09-02   MT     Remove SOQL to look for account using related list.  Replace with formula field on service usage record.
 *
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/
public void SUApexSharingAfterInsertBeforeUpdate(List<Service_Usage__c> suList){


    System.debug('****** TriggerSUApexSharingAfterInsert ******');
        
    Set<Id> serUsageIds = new Set<Id>();
    
    RecordType rType = [Select Id, Name from RecordType where Name ='Outgoing Referral' and SobjectType = 'Service_Usage__c' limit 1];

    for(Service_Usage__c su : suList){
  
    
        serUsageIds.add(su.Id);
        
        
   
   }
    System.debug('****** serUsageIds ******: ' + serUsageIds.size());

    //Retrive all UserRoles.
    Map<string, Id> mapUserRoles = new Map<string, Id>();
    for(UserRole ur:[Select Name, Id from UserRole])
    {
       mapUserRoles.put(ur.Name, ur.id);    
    }
    System.debug('****** mapUserRoles.size ******: ' + mapUserRoles.size());

    Map<string,Group> mapRoleGroups = new Map<string,Group>();
    Map<string,Group> mapRoleAndSubGroups = new Map<string,Group>();
    
    //Retrieve all Groups of UserRoles, where Type is either Role or RoleAndSubordinates.
    List<Group> grp = [Select RelatedId,Type from Group where Type ='Role' or Type = 'RoleAndSubordinates'];    
    
    for(Group rec: grp)
    {
        //Depending of Type of Group asssign values to different Maps.
        if(rec.Type.equalsIgnoreCase('Role'))
            mapRoleGroups.put(rec.RelatedId,rec);          
        else
            mapRoleAndSubGroups.put(rec.RelatedId,rec); 
    }
    System.debug('****** mapRoleGroups ******: ' + mapRoleGroups.size());
    System.debug('****** mapRoleAndSubGroups ******: ' + mapRoleAndSubGroups.size());

    List<Service_Usage__Share> lstSUApexShare = new List<Service_Usage__Share>();

    //Retrieve Locality names for Service Usage records to a Map.
    //Map<Id,Service_Usage__c> lstSURecs = new Map<Id,Service_Usage__c>([Select Id,Service_Field__r.Locality__r.Name 
    //                                                                    from Service_Usage__c 
    //                                                                    where id=:serUsageIds]);
    //System.debug('****** lstSURecs ******: ' + lstSURecs.size());

    Map<String,String> mapRoles = new Map<String,String>();

    for (RegionAreaLocalityMap__c r : [Select RegionAreaLocalityName__c,RegionAreaLocalityNameNew__c FROM RegionAreaLocalityMap__c]) {
        mapRoles.put(r.RegionAreaLocalityName__c, r.RegionAreaLocalityNameNew__c);
    }
    System.debug('****** mapRoles ******: ' + mapRoles.size());

    for(Service_Usage__c rec: suList)
    {
        try
        {
            //Skip creating Sharing for Service Usage of External type.
            if(rType.Id != null && rType.Id == rec.RecordTypeId)
                continue;

            String strService_Type = String.ValueOf(rec.Service_Type__c);
            strService_Type = (strService_Type.length()>35)?strService_Type.substring(0,35):strService_Type;
            System.debug('****** strService_Type ******: ' + strService_Type);          

            //Only when custom setting has flag set to check Share with colleague on SU then become mandatory otherwise skip.
            if(ServiceUsageApexSharingCriteria__c.getAll().containsKey(strService_Type ))
            {
                if(ServiceUsageApexSharingCriteria__c.getAll().get(strService_Type ).Is_Colleague_Check_Mandatory__c && !rec.Share_with_colleagues__c)
                    continue;
            }   
            
            //Only if user has not selected Service Usage as Share_with_colleagues__c and have proper locality relationship.
            //if(lstSURecs.get(rec.id).Service_Field__r.Locality__r.Name != null)
            if(rec.LocalityName__c != null)
            {
                string strCustSetRoleName='';
                
                //For lengthy Organisation/Account Names, take left 42 characters.
                //string accName = lstSURecs.get(rec.id).Service_Field__r.Locality__r.Name.replace(' Locality','');
                string accName = rec.LocalityName__c;
                accName=accName.replace(' Locality','');
                System.debug('****** accName1 ******: ' + accName);
                accName = (accName.length()>42)?accName.substring(0,42):accName;
                System.debug('****** accName2 ******: ' + accName);
                
                //Looking for Service Type in Custom Settings and pickup Role name.
                if(ServiceUsageApexSharingCriteria__c.getAll().containsKey(strService_Type))
                {
                    strCustSetRoleName = mapRoles.get(ServiceUsageApexSharingCriteria__c.getAll().get(strService_Type).Role_Name__c + ' - ' + accName);
                    System.debug('****** strCustSetRoleName1 ******: ' + mapRoles.get(ServiceUsageApexSharingCriteria__c.getAll().get(strService_Type).Role_Name__c + ' - ' + accName));                
                }
                else
                {                
                    strCustSetRoleName = mapRoles.get('Locality Management - ' + accName);
                    System.debug('****** strCustSetRoleName2 ******: ' + strCustSetRoleName);
                }
                
                //Get the RoleId.
                string strRoleId = '';
                if(mapUserRoles.containsKey(strCustSetRoleName))
                {
                    strRoleId=mapUserRoles.get(strCustSetRoleName);
                    System.debug('****** strRoleId ******: ' + strRoleId);
                }
                else
                {
                    //If Role not found, alert error and skip creating Share record and continue loop.
                    rec.addError('Role to Share the record not found. Contact The CRS Helpdesk.');
                    continue;
                }   
                
                //Get GroupId.
                string strGroupId = '';
                
                //If RoleName starts with 'Locality Management' then share with Group and Subordinates.
                if(strCustSetRoleName.startsWith('Locality Management') && mapRoleAndSubGroups.containsKey(strRoleId))
                    strGroupId = mapRoleAndSubGroups.get(strRoleId).Id;  
                System.debug('****** strGroupId ******: ' + mapRoleAndSubGroups.containsKey(strRoleId));                    
                    
                    
                //If GroupId is not picked in above condition then look and set Group Id for the Role Id.
                if(mapRoleGroups.containsKey(strRoleId) && strGroupId.equals(''))
                    strGroupId = mapRoleGroups.get(strRoleId).Id;                  
                System.debug('****** strGroupId ******: ' + strGroupId);      
                
                //If Role Group is found then add for creating share.
                if(strGroupId.length()>0)
                {
                    lstSUApexShare.add(new Service_Usage__Share(UserOrGroupId = strGroupId, ParentId = rec.id, rowCause = Schema.Service_Usage__Share.RowCause.ApexSharing__c, AccessLevel = 'Edit'));
                }   
            }                       
        }
        catch(Exception ex)
        {
            rec.addError('Runtime Exception :'+ex.getMessage()+ ' Contact The CRS Helpdesk.');
        }
    }
    
    System.debug('****** lstSUApexShare ******: ' + lstSUApexShare);

    //Finally create share records.
    if(lstSUApexShare.size()>0)
    {
        Savepoint sp = Database.setSavepoint();

        try
        {
            System.debug('****** creating sharing for ******: ' + lstSUApexShare.size());
            insert lstSUApexShare;
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());Database.rollback(sp);throw ex;
        }    
    }
    
    //to remove sharing of flag if unchecked
    List<Id> suId = new List<Id>();
    for(Service_Usage__c rec: suList){
        if(!rec.Share_with_colleagues__c)
            suId.add(rec.Id);
    }
    
    List<Service_Usage__Share> lstSUApexShareToDelete = [SELECT s.Id, s.ParentId, s.IsDeleted, s.AccessLevel, s.RowCause
                                                         FROM Service_Usage__Share s WHERE ParentId in :suId 
                                                                                    AND IsDeleted!=true
                                                                                    AND AccessLevel='Edit' 
                                                                                    AND RowCause=:Schema.Service_Usage__Share.RowCause.ApexSharing__c];                                   
                                        
    if(lstSUApexShareToDelete.size()>0){
        System.debug('****** deleting sharing for ******: ' + lstSUApexShareToDelete.size());
        try
        {
            delete lstSUApexShareToDelete;
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());throw ex;
        } 
    }    
}

/******************************************************************************************
* SUUpdateCloseSUCloseEAD 
* Change 375 - Closing Service usage should close down future events
******************************************************************************************/
private void SUUpdateCloseSUCloseEAD (Map<ID, Service_Usage__c> oldServiceUsageMap, Map<ID, Service_Usage__c> ServiceUsageMap, Service_Usage__c newSU) {
    System.Debug('++++++++++++++++++++++++++++SUUpdateCloseSUCloseEAD ');
    try{
    Service_Usage__c oldSU = oldServiceUsageMap.get(newSU.ID);
    if ((oldSU!=null)&&(newSU!=null)){
        System.Debug('++++++++++++++++++++++++++++old reason: '+ oldSU.closure_reason__c + ' new reason: ' + newSU.closure_reason__c + ' close date:' + newSU.closure_date__c);
        if ((((newSU.closure_reason__c!=null)&&(oldSU.closure_reason__c==null))||(newSU.closure_reason__c!=oldSU.closure_reason__c)) && (newSU.closure_date__c!=null)){
            List <Event_Attendance_Details__c> ead =[select id, name, Attendance_Status__c, Event_Date_and_Time__c from Event_Attendance_Details__c where service_usage__c=:newSu.id and DAY_ONLY(Event_Date_and_Time__c)  > :newSU.closure_date__c];
            System.debug ('++++++++++++++++++++++++++++SUUpdateCloseSUCloseEAD ead: ' + ead.size() );
            delete ead;
            /**
            * now for the complicated bit.  Need to delete the EAD for the contact as well.  
            * To do this we need to find a list of the events for this service usage after closure date and then get a list of eventnumbers.  
            * From this search for any EADs with the current service users contact id.
            **/
            List <Event> EventRecs = [Select Id, EventNumber__c, RecurrenceActivityId  from Event where WhatId=:newSU.service_field__c and ActivityDateTime > :newSU.closure_date__c];
            System.debug ('++++++++++++++++++++++++++++EventRecs Size: ' + EventRecs.size() );
            
            Set<Id> setSeriesActivityId = new Set<ID>();
            for(Event eveRec: EventRecs )
            {
                if(!setSeriesActivityId.contains(eveRec.RecurrenceActivityId))
                    setSeriesActivityId.add(eveRec.RecurrenceActivityId);
            }
            System.debug ('++++++++++++++++++++++++++++SUUpdateCloseSUCloseEA setSeriesActivityId: ' + setSeriesActivityId);
            //now we have one or more ids for series, use this to get a set of event numbers for the series
            List <Event> EventOutstandingRecs = [Select Id, EventNumber__c   from Event where WhatId=:newSU.service_field__c and RecurrenceActivityId =:setSeriesActivityId];
            System.debug ('++++++++++++++++++++++++++++EventOutstandingRecs Size: ' + EventOutstandingRecs.size());

            Set<String> setEventAutoNum = new Set<String>();
            for (Event eveRec2: EventOutstandingRecs)
            {
                if(!setEventAutoNum.contains(eveRec2.EventNumber__c))
                    setEventAutoNum.add(eveRec2.EventNumber__c);
            }
            
            System.debug ('++++++++++++++++++++++++++++SUUpdateCloseSUCloseEA setEventAutoNum : ' + setEventAutoNum);
            List <Event_Attendance_Details__c> ead2 = [select id, name, Attendance_Status__c, Event_Date_and_Time__c 
                                                        from Event_Attendance_Details__c where EventNumber__c=:setEventAutoNum 
                                                        and Contact__c = :newSU.primary_service_user__c and DAY_ONLY(Event_Date_and_Time__c)  > :newSU.closure_date__c];
            System.debug ('++++++++++++++++++++++++++++SUUpdateCloseSUCloseEAD ead2: ' + ead2.size() );
            delete ead2;

            }
        }
    }catch(Exception ex){
        //maximum length exceeded for rrpu_alert_message__c 
                newSU.addError('Error updating service usage:' + ex.getMessage()+'. Contact The CRS Helpdesk.');

        }
    }
/**
    Change 380 - Last Activity Date on Service Usage.
    Add update to Service Usage Trigger to update Last Activity Date when Service Usage Initial Assessment,Referral Outcome, Date Assessment Commenced, Service Usage Notes, and Closure Date are changed. 
**/
private void SUUpdateLastActivityDate  (Map<ID, Service_Usage__c> oldServiceUsageMap, Map<ID, Service_Usage__c> ServiceUsageMap, Service_Usage__c newSU) {
    System.Debug('++++++++++++++++++++++++++++SUUpdateLastActivityDate  ');
    try{
        Map<Id,Service_Usage__c> lstSURecs = new Map<Id,Service_Usage__c>([Select Id
                                                                          ,Referral_Assessment_Date__c
                                                                          ,Referral_Outcome__c
                                                                          ,Date_Assessment_Commenced__c
                                                                          ,Service_Usage_Notes__c
                                                                          ,Closure_Date__c
                                                                          from Service_Usage__c where id=:oldServiceUsageMap.keyset()]);
//    

    Service_Usage__c oldSU = oldServiceUsageMap.get(newSU.ID);

    if ((oldSU.Referral_Assessment_Date__c <> newSU.Referral_Assessment_Date__c)
        || (oldSU.Referral_Outcome__c <> newSU.Referral_Outcome__c )
        || (oldSU.Date_Assessment_Commenced__c <> newSU.Date_Assessment_Commenced__c )
        || (oldSU.Service_Usage_Notes__c <> newSU.Service_Usage_Notes__c )
        || (oldSU.Closure_Date__c <> newSU.Closure_Date__c )){
        newSU.Date_of_last_Activity__c =newSU.LastModifiedDate.date();
        }
    }catch(Exception ex){
        //error updating SU.
        newSU.addError('Error updating service usage:' + ex.getMessage()+'. Contact The CRS Helpdesk.');
        }
   
    }    

public void UpdateLastTransactionDate(Service_Usage__c[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Service_Usage__c df : updatedSUs){
        SUIds.add(df.Id);
    }
    System.debug('****** SUIds.Size ******' + SUIds.Size());

    if(SUIds.isEmpty() == false){
      
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
      LastTransactionDateLookup handler = new LastTransactionDateLookup();
      handler.UpdateLastTransactionDate(SUIds[0], dtLastTransactionDate); 
      
        }
    
}
   
}