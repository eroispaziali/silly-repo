@isTest
public class TestServiceChangeUpdateServiceUsage {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test APEX Class for ServiceChangeUpdateServiceUsage Apex Class.
 *  Author  : Mike Tinson
 *  Date    : 26-06-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Test APEX Class for ServiceChangeUpdateServiceUsage Apex Class which 
 *                  realigns service usage records for a selected Service.
 *
 *                  *Note that since email messages aren’t sent from tests, and because the batch 
 *                  class is invoked by a test method, the email notifications won’t be sent in this case. 
 *
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ??
 *                             
*******************************************************************************************/
static testMethod void mainTest(){

Contact recCon = new Contact(FirstName = 'Albert', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
insert recCon;  

Account accRec = new Account(Name='North West London Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
insert accRec;
Services__c serv = new Services__c(Name='North West London DS test', Locality__c=accRec.id,Service_Type__c='Dementia support', National_Service__c=false);//Name='testControllerService');
insert serv;    
Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Dementia support', RecordTypeId=[
        select id from RecordType where SobjectType = 'Service_usage__c' and DeveloperName='Dementia_Support_Service_Usage'].id);    
    
insert recSU;

Test.StartTest();

List<Id> IdLst = New List<id>();
IdLst.add(serv.id);

ServiceChangeUpdateServiceUsage suBatch = new ServiceChangeUpdateServiceUsage();
suBatch.ServiceIdList = IdLst;
suBatch.email='crssupport@alzheimers.org.uk';

suBatch.BatchDescription = 'Test ServiceChangeUpdateServiceUsage';

//test routines that work out new service type for a service usage if the service service type has changed.
String resultStr;
    resultStr = suBatch.CheckServiceType('xxx','Activity group');
    resultStr = suBatch.CheckServiceType('xxx','Advocacy');
    resultStr = suBatch.CheckServiceType('xxx','Befriending');
    resultStr = suBatch.CheckServiceType('xxx','Community support service');
    resultStr = suBatch.CheckServiceType('xxx','Day care and support (establishment based)');
    resultStr = suBatch.CheckServiceType('xxx','Dementia adviser');
    resultStr = suBatch.CheckServiceType('xxx','Dementia cafe');
    resultStr = suBatch.CheckServiceType('xxx','Dementia support');
    resultStr = suBatch.CheckServiceType('xxx','Information programme');
    resultStr = suBatch.CheckServiceType('xxx','Newsletter');
    resultStr = suBatch.CheckServiceType('xxx','Other (one to one)');
    resultStr = suBatch.CheckServiceType('xxx','Peer support group');
    resultStr = suBatch.CheckServiceType('xxx','Registered home care and support');
    resultStr = suBatch.CheckServiceType('xxx','Singing for the Brain');
    resultStr = suBatch.CheckServiceType('xxx','yyyy');
Id resultId;
    //call routine to fill map with record types.  This is usually done at start of execute call.
    suBatch.GetRecordtypes();
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Activity group');     
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Advocacy');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Befriending');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Community support service');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Day care and support (establishment based)');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Dementia adviser');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Dementia cafe');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Dementia support');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Information programme');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Newsletter');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Other (one to one)');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Peer support group');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Registered home care and support');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'Singing for the Brain');
    resultId = suBatch.CheckRecordType(recSU.recordtypeid,'yyyy');

//now exercise the batch
ID batchprocessid = Database.executeBatch(suBatch);
Test.StopTest();

}
}