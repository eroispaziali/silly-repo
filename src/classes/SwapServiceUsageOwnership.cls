Public with sharing class SwapServiceUsageOwnership {

//Public User FromUser {get;set;}
//Public User ToUser {get;set;}

Public Service_Usage__c fromSU {get;set;}
Public Service_Usage__c toSU {get;set;}
Public list<ServiceCountWrapper> ServiceWp {get;set;}
Public String debugLog {get;set;}
Public String ProcessingStage {get;set;}
Public SwapServiceUsageOwnership(ApexPages.StandardController stdCon){
//    FromUser = New User();
//    ToUser = New User();
    fromSU = New Service_Usage__c ();
    toSU = New Service_Usage__c ();
    ServiceWp = new List<ServiceCountWrapper>();
    ProcessingStage = '1';
    }
Public PageReference cancel() {
        return new PageReference('/');
    }
Public PageReference Find() {
    
    if ((fromSU.ownerid!=null)&&(toSU.ownerid!=null))
    {
        ServiceWp.Clear();
        List<aggregateResult> suAgg = [select service_field__c, service_field__r.name, count(id)
        from service_usage__c where ownerid=:fromSU.ownerid and closure_reason__c =null and Service_User_Deceased__c = 'FALSE'
        group by service_field__c, service_field__r.name
        order by service_field__r.name ];
        if (suAgg.size()>0){
            for (AggregateResult ar : suAgg){
            
            ServiceCountWrapper s = new ServiceCountWrapper();

            s.Serviceid =(String)ar.get('service_field__c');
            s.ServiceName = (String)ar.get('Name') ;
            s.isSelected = false;
            s.CountServiceUsage = (integer)ar.get('expr0') ;
            ServiceWp.Add(s);
            }    
            ProcessingStage = '2';
        }
        
        else
        {
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.WARNING,'No open service usage records found for old user.');
        ApexPages.addMessage(message);
        }
    } 
    else
    {
    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'From and to owners must be selected.');
    ApexPages.addMessage(message);
    }
    return null;
    } 
    
Public pageReference submit(){
    
    List <ServiceCountWrapper> suUpdateList = new list<ServiceCountWrapper>();
    String sfIds = '';
    debugLog = '';
    for (ServiceCountWrapper rec: ServiceWp){
        if (rec.isSelected) {
            suUpdateList.add(rec);
//            debugLog = debugLog + rec.serviceId + '=' + rec.ServiceName + ' ;';
            sfIds = sfIds + '\'' + rec.serviceId + '\',';
        }
    }
    if(suUpdateList.size()==0){
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'One or more service must be selected.');
        ApexPages.addMessage(message);
    }else{
        sfIds = sfIds.substring(0, sfIds.lastindexof(','));
        String query = 'select  id, name, ownerid, Assigned_Worker__c from Service_usage__c where service_field__c in (' + sfIds + ') and ownerid = \'' + fromSU.ownerid + '\'' + ' and closure_reason__c =null and Service_User_Deceased__c = \'FALSE\'';
        debugLog = debugLog + '<br/>Query is  ' + query; 
        ServiceUsageOwnerReassignment reassign = new ServiceUsageOwnerReassignment();
        reassign.query= query;
        reassign.email=UserInfo.getUserEmail();
        reassign.fromUserId = fromSU.ownerid;
        reassign.toUserId = toSU.ownerid;
        ID batchprocessid = Database.executeBatch(reassign, 20);
        
        debugLog=debugLog + '<br/> The batch results will be sent to  ' + UserInfo.getUserEmail();
        debugLog= debugLog + ' ' + '<br/> The batch process ID is batchprocessid  = ' + batchprocessid ;
        ProcessingStage = '3';
    }
    return null;  
}       
Public Class ServiceCountWrapper{
    Public Boolean isSelected {get; set;}
    Public String serviceId {get;set;}
    Public String ServiceName {get;set;}
    Public integer CountServiceUsage {get;set;}
    }
}