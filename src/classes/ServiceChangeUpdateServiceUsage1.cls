/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Batch APEX Class to re-align Service Usage records after a service record is changed.
 *  Author  : Lakshmi Rajendram
 *  Date    : 08-09-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Batch APEX Class to re-align Service Usage records after a service record is changed
 *                  
 *  Code to be executed in an anonymouse block
 *                  String CRON_EXP = '0 0 * * * ?';
 *                  ServiceChangeUpdateServiceUsage1 sch = new ServiceChangeUpdateServiceUsage1();
 *                  system.schedule('Hourly  Batch Schedule job', CRON_EXP, sch);
 *                  
 * Modification History
 *   MT 1/10/2014 Do not close service usage if closure date on service in future
 *                      

*******************************************************************************************/

global class ServiceChangeUpdateServiceUsage1 implements Database.Batchable<sObject>,Schedulable{


Public String email{get;set;}
Public String BatchDescription{get;set;}
Public Map<String, Id> SURecordtypeMap;
Public List<Services__c> ServiceIdList;
Private Set<Id> SetServiceId;
Public Boolean isRunningTest=False;
global Database.querylocator start(Database.BatchableContext BC){

 List<Services__c> ServiceIdList= [select id from Services__c where Is_Updated__c=True];
    
    String  qryCommand;
    qryCommand = 'SELECT id, name, service_type__c,createddate,closure_date__c,service_field__r.Is_Updated__c,closure_reason__c, Primary_Service_User__r.LastName, Primary_Service_User__r.FirstName, Service_Field__r.Name,  primary_service_user__r.Deceased__c ,service_field__c, service_field__r.service_type__c,service_field__r.service_closedate__c, recordtypeid from service_usage__c where service_field__r.id'  ; //where service_field__r.Is_Updated__c=True';
    qryCommand = qryCommand + ' IN :ServiceIdList';
    qryCommand = qryCommand + '  and closure_date__c =null and ((primary_service_user__r.Deceased__c=true and primary_service_user__r.Deceased_Date__c!=null) or (primary_service_user__r.Deceased__c=false))';
    qryCommand = qryCommand + '  and Service_User_Record_Type__c IN (\'Carer\',\'Person_with_dementia\')';
    System.debug('################query##############' + qryCommand );
    system.debug('################service##############' + ServiceIdList);
   if(isRunningTest)
    {
    qryCommand += ' Limit 1';
    }
  
  
    return Database.getQueryLocator(qryCommand );
    
     
    }

global void execute(Database.BatchableContext BC, List<sObject> scope){
    Boolean bUpdateRecord;
    String service_type;
    Id recordtypeId;
    String TestSUName;
    //get current date and time
    Datetime myDT = Datetime.now();
    //build map of recordtypes to be used later
    GetRecordtypes();
    Map<Id,Services__c>  su= new Map<Id,Services__c>();
    List<Service_Usage__c> sus = new List<Service_Usage__c>();
     
     
       for(sObject s : scope){
            Service_Usage__c a = (Service_Usage__c)s;
           
            //flag to see if record needs updating
            bUpdateRecord = false;
            //if service is closed close service usage
            if(a.service_field__r.service_closedate__c != null && a.Closure_reason__c==null && a.service_field__r.service_closedate__c<=myDT){
                a.Closure_date__c = a.service_field__r.service_closedate__c;
                a.Closure_reason__c = 'Service closed';
                bUpdateRecord = true;
                }
            //Service type changes - recalculate what the service type should be from the service type on the service.
                service_type = CheckServiceType(a.service_type__c,a.service_field__r.service_type__c);  
                if (service_type !=a.service_type__c){
                    a.service_type__c=service_type;
                    bUpdateRecord = true;
                }
            //check that the record type is correct.  
                recordtypeId = CheckRecordType(a.recordtypeid, a.service_field__r.service_type__c);
                if (recordtypeId!=a.recordtypeid){
                    a.recordtypeid = recordtypeid;
                    bUpdateRecord = true;
                }
            //check if name of service has changed
                TestSUName = a.Primary_Service_User__r.LastName + ', ' + a.Primary_Service_User__r.FirstName + ' (' +  a.Service_Field__r.Name ;    
                TestSUName = TestSUName.Left(79) + ')';
                if (TestSUName != a.Name){
                    bUpdateRecord = true;
                    //workflow rule will update name of record.
                }
             
               
       If(a.service_field__r.Is_Updated__c==True){
             List<Services__c> servs=[Select id,name from Services__c where id =:a.service_field__c];
             For(Services__c ss :servs){
             ss.Is_Updated__c=False;
             su.put(ss.id,ss);}
          
          }
               
               
            //if record has been updated, then add to list    
                if (bUpdateRecord == true){
                a.service_field__r.Is_Updated__c=False;
                    sus.add(a);
                   
                    
                }
                
        }
        
        
    update sus;
    update su.values();
   
}

global void finish(Database.BatchableContext BC){

  
  
}
global Id CheckRecordType(Id psu_recortypeid, String pservice_service_type){
    //from the service type of the dementia connnect service work out what the service type on the service usage should be.
    Id recordtypeId;
    if (pservice_service_type =='Activity group'){
        recordtypeId = SURecordtypeMap.get('Social Activity Group');
        return recordtypeId;
    }
    if (pservice_service_type =='Advocacy'){
        recordtypeId = SURecordtypeMap.get('Advocacy');
        return recordtypeId;
    }
    if (pservice_service_type =='Befriending'){
        recordtypeId = SURecordtypeMap.get('Volunteer Befriending');
        return recordtypeId;
    }
    if (pservice_service_type =='Community support service'){
        recordtypeId = SURecordtypeMap.get('Social Inclusion');
        return recordtypeId;
    }
    if (pservice_service_type =='Day care and support (establishment based)'){
        recordtypeId = SURecordtypeMap.get('Day Support (Premises Based)');
        return recordtypeId;
    }
    if (pservice_service_type =='Dementia adviser'){
        recordtypeId = SURecordtypeMap.get('Dementia Adviser');
        return recordtypeId;
    }
    if (pservice_service_type =='Dementia cafe'){
        recordtypeId = SURecordtypeMap.get('Dementia Cafe');
        return recordtypeId;
    }
    if (pservice_service_type =='Dementia support'){
        recordtypeId = SURecordtypeMap.get('Dementia Support');
        return recordtypeId;
    }
    if (pservice_service_type =='Information programme'){
        recordtypeId = SURecordtypeMap.get('Information Programme');
        return recordtypeId;
    }
    if (pservice_service_type =='Newsletter'){
        recordtypeId = SURecordtypeMap.get('Newsletter');
        return recordtypeId;
    }
    if (pservice_service_type =='Other (one to one)'){
        recordtypeId = SURecordtypeMap.get('Other');
        return recordtypeId;
    }
    if (pservice_service_type =='Peer support group'){
        recordtypeId = SURecordtypeMap.get('Peer Support Group');
        return recordtypeId;
    }
    if (pservice_service_type =='Registered home care and support'){
        recordtypeId = SURecordtypeMap.get('Home Support (Registered)');
        return recordtypeId;
    }
    if (pservice_service_type =='Singing for the Brain'){
        recordtypeId = SURecordtypeMap.get('Singing for the Brain');
        return recordtypeId;
    }
    return psu_recortypeid;
}
global String CheckServiceType(String psu_service_type, String pservice_service_type){
    //make sure that the service type on the service usage matches the corresponding service type on the service.  
    //at the moment there is a one to one equivalence, but that may not always be the case.
    System.debug('############# Service Usage : ' + psu_service_type);
    System.debug('############# Service       : ' + pservice_service_type);
    
    if (pservice_service_type =='Activity group'){
        return 'Activity group';
    }
    if (pservice_service_type =='Advocacy'){
        return 'Advocacy';
    }
    if (pservice_service_type =='Befriending'){
        return 'Befriending';
    }
    if (pservice_service_type =='Community support service'){
        return 'Community support service';
    }
    if (pservice_service_type =='Day care and support (establishment based)'){
        return 'Day care and support (establishment based)';
    }
    if (pservice_service_type =='Dementia adviser'){
        return 'Dementia adviser';
    }
    if (pservice_service_type =='Dementia cafe'){
        return 'Dementia cafe';
    }
    if (pservice_service_type =='Dementia support'){
        return 'Dementia support';
    }
    if (pservice_service_type =='Information programme'){
        return 'Information programme';
    }
    if (pservice_service_type =='Newsletter'){
        return 'Newsletter';
    }
    if (pservice_service_type =='Other (one to one)'){
        return 'Other (one to one)';
    }
    if (pservice_service_type =='Peer support group'){
        return 'Peer support group';
    }
    if (pservice_service_type =='Registered home care and support'){
        return 'Registered home care and support';
    }
    if (pservice_service_type =='Singing for the Brain'){
        return 'Singing for the Brain';
    }
    return psu_service_type;
    }
Public boolean GetRecordtypes(){
    SURecordtypeMap= new Map<String, Id>();
    List <Recordtype> RTList= new List<Recordtype>([SELECT Name, Id from Recordtype where Sobjecttype='Service_usage__c' and Name!='Outgoing Referral']);
    For (Recordtype rec: RTList){
        SURecordtypeMap.put(rec.name, rec.id);
    }
    if  (SURecordtypeMap.size() > 0) {
        return true;}
    else {
        return false;}
    }
    
     global void execute(SchedulableContext SC) 
  {
      ServiceChangeUpdateServiceUsage1 suUpdate = new ServiceChangeUpdateServiceUsage1();
      Database.executeBatch(suUpdate,20);
  }
}