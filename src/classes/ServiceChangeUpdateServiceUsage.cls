/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Batch APEX Class to re-align Service Usage records after a service record is changed.
 *  Author  : Mike Tinson
 *  Date    : 25-06-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Batch APEX Class to re-align Service Usage records after a service record is changed
 *                  
 *
 *                  Called via the Execute Anonymous window. 
 *                  ServiceChangeUpdateServiceUsage suBatch = new ServiceChangeUpdateServiceUsage ();
 *                  suBatch.ServiceIdList = <<List of Ids for internal services to be updated>>
 *                  suBatch.BatchDescription = 'Test of Service Usage ServiceChangeUpdateServiceUsage';
 *                  suBatch.email=UserInfo.getUserEmail();
 *                  //Invoke the Batch class.
 *                  ID batchprocessid = Database.executeBatch(suBatch, 20);
 *                  
 *  Modification History
 *  Date            Who         Description 
 *  9-07-2014        MT         Do not attempt to update professionals who have been referred to a service (they should not!)
 *  MT 1/10/2014 Do not close service usage if closure date on service in future                           
*******************************************************************************************/

global class ServiceChangeUpdateServiceUsage implements Database.Batchable<sObject>{

Public List<Id> ServiceIdList {get;set;}
Public String email{get;set;}
Public String BatchDescription{get;set;}
Public Map<String, Id> SURecordtypeMap;

global Database.querylocator start(Database.BatchableContext BC){
    String  qryCommand;
    qryCommand = 'SELECT id, name, service_type__c, closure_date__c, closure_reason__c, Primary_Service_User__r.LastName, Primary_Service_User__r.FirstName, Service_Field__r.Name,  primary_service_user__r.Deceased__c ,service_field__c, service_field__r.service_type__c,service_field__r.service_closedate__c, recordtypeid from service_usage__c where service_field__c';
    qryCommand = qryCommand + ' IN :ServiceIdList';
    qryCommand = qryCommand + '  and closure_date__c =null and ((primary_service_user__r.Deceased__c=true and primary_service_user__r.Deceased_Date__c!=null) or (primary_service_user__r.Deceased__c=false))';
    qryCommand = qryCommand + '  and Service_User_Record_Type__c IN (\'Carer\',\'Person_with_dementia\')';
    System.debug('################query##############' + qryCommand );
    return Database.getQueryLocator(qryCommand );}

global void execute(Database.BatchableContext BC, List<sObject> scope){
    Boolean bUpdateRecord;
    String service_type;
    Id recordtypeId;
    String TestSUName;
    //get current date and time
    Datetime myDT = Datetime.now();
    //build map of recordtypes to be used later
    GetRecordtypes();
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
            //if record has been updated, then add to list    
                if (bUpdateRecord == true){
                    sus.add(a);
                }
        }
    update sus;
    
}
global void finish(Database.BatchableContext BC){
// First, reserve email capacity for the current Apex transaction to ensure
// that we won't exceed our daily email limits when sending email after
// the current transaction is committed.
Messaging.reserveSingleEmailCapacity(1);

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

mail.setToAddresses(new String[] {email});
mail.setReplyTo(email);
mail.setSenderDisplayName('Batch Processing');
mail.setSubject('Batch Process Completed');
String strMessage = 'Batch Process has completed';
strMessage = strMessage  + '\n Service IDs: ' + ServiceIdList;
strMessage = strMessage  + '\n BatchDescription: ' + BatchDescription;
strMessage = strMessage  + '\n Batch Process Completed';
mail.setPlainTextBody( strMessage );

Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
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
}