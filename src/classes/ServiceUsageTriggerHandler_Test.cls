/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ServiceUsageTriggerHandler_Test {

    static testMethod void testTriggerSUApexSharingAfterInsert() {
        
       Contact recCon = new Contact(FirstName = 'Albert', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
insert recCon;  
System.debug('****** Contact ******: ' + recCon.FirstName);
Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
insert accRec;
System.debug('****** Account ******: ' + accRec.Name);
Services__c serv = new Services__c(Name='Awareness Raising - East Herts', Locality__c=accRec.id,Service_Type__c='Dementia support', National_Service__c=false);//Name='testControllerService');
insert serv; 
//create look up used by trigger on Service Usage
RegionAreaLocalityMap__c RALMap = new RegionAreaLocalityMap__c();
RALMap.RegionAreaLocalityName__c='Locality Management - Midlands Central';
RALMap.RegionAreaLocalityNameNew__c = 'Locality Management - Birmingham, Solihull, Coventry & Warks';
insert RALMap;   
System.debug('****** Services******: ' + serv.Name);
Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Dementia support', RecordTypeId=[
        select id from RecordType where Name ='Outgoing Referral' and SobjectType = 'Service_Usage__c'].id,Share_with_colleagues__c=True);    
insert recSU;
System.debug('****** Service Usage******: ' + recSU.Name);

Test.StartTest();
UserRole ur=[Select Name, Id from UserRole where id='00E700000010JCPEA2'];
System.debug('******UserRole******: ' + ur.Name);
Group grp = [Select id,RelatedId,Type from Group where  Type='RoleAndSubordinates' and id='00G70000001S8GhEAK'];
System.debug('******Group******: ' + grp.id);
//RegionAreaLocalityMap__c r =[Select id,RegionAreaLocalityName__c,RegionAreaLocalityNameNew__c FROM RegionAreaLocalityMap__c where RegionAreaLocalityName__c='Locality Management - Hertfordshire' and RegionAreaLocalityNameNew__c='Locality Management - Hertfordshire' limit 1];
//System.debug('******RegionArea Locality Map******: ' + r.RegionAreaLocalityName__c);
ServiceUsageApexSharingCriteria__c suas=new ServiceUsageApexSharingCriteria__c(Name='Dementia support',Is_Colleague_Check_Mandatory__c=True,Role_Name__c='Dementia Adviser & Dementia Support'); 
      //For lengthy Organisation/Account Names, take left 42 characters.
              string accName = accRec.Name.replace(' Locality','');
              System.debug('****** accName1 ******: ' + accName);
              accName = (accName.length()>42)?accName.substring(0,42):accName;
              System.debug('****** accName2 ******: ' + accName);
              recSU.Share_with_colleagues__c=False;
              update   recSU;
 Test.StopTest(); 
    }
//
// TEST CASE moved from Trigger Handler class
//
static testMethod  void testServiceUsageTriggerHandler(){
    Contact recCon = new Contact(FirstName = 'Albert', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
    insert recCon;        
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
    insert serv; 
    //create look up used by trigger on Service Usage
    RegionAreaLocalityMap__c RALMap = new RegionAreaLocalityMap__c();
    RALMap.RegionAreaLocalityName__c='Locality Management - Midlands Central';
    RALMap.RegionAreaLocalityNameNew__c = 'Locality Management - Birmingham, Solihull, Coventry & Warks';
    insert RALMap; 
    Test.StartTest(); 
    //create handler
    ServiceUsageTriggerHandler testHandler = new ServiceUsageTriggerHandler(false,1); 
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    
    // Start the test.
    //test.startTest();
    insert recSU;

    testHandler.SetFirstRun(true);   
    recSU.Public_Alert_message_Required__c=true;
    recSU.Referral_Assessment_Date__c=Date.Today();
    recSU.Referral_Outcome__c = 'Case Opened';
    update recSU;
    testHandler.SetFirstRun(true);   
    recSU.Public_Alert_message_Required__c=false;
    recSU.Service_Usage_Notes__c='test 1 2 3';
    update recSU;
    
    testHandler.SetFirstRun(true);   
    recSU.closure_date__c = Date.Today();
    recSU.closure_reason__c = 'Service no longer required';
    update recSU;
    testHandler.SetFirstRun(true);
    try
        {
            recSU.Primary_Service_User__c=UserInfo.getUserId(); //invalid
            update recSU;
        }
    catch(Exception e)
    {
    System.Assert(e.getMessage().contains('id value of incorrect type'));
    //System.Assert(e.getMessage().contains('Product2Id'));
    //System.Assert(e.getMessage().contains('My Error Message'));
    } 
   
    testHandler.SetFirstRun(true);
    delete recSU;
    
    
    System.debug('IsTriggerContext' + testHandler.IsTriggerContext);
    System.debug('IsVisualforcePageContext' + testHandler.IsVisualforcePageContext);
    System.debug('IsWebServiceContext' + testHandler.IsWebServiceContext);
    System.debug('IsExecuteAnonymousContext' + testHandler.IsExecuteAnonymousContext); 
    Test.StopTest(); 
    }
static testMethod  void testServiceUsageChangeAssignedWorker(){
	
	User U1 = [select id, name from User where Profile.Name='CRS' and UserRole.Name like 'Dementia Adviser & Dementia Support - North West London%'  and IsActive=true LIMIT 1];
	
    Contact recCon = new Contact(FirstName = 'Albert', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
    insert recCon;        
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
    insert serv; 
    //create look up used by trigger on Service Usage
    RegionAreaLocalityMap__c RALMap = new RegionAreaLocalityMap__c();
    RALMap.RegionAreaLocalityName__c='Locality Management - Midlands Central';
    RALMap.RegionAreaLocalityNameNew__c = 'Locality Management - Birmingham, Solihull, Coventry & Warks';
    insert RALMap; 
    Test.StartTest(); 
    //create handler
    ServiceUsageTriggerHandler testHandler = new ServiceUsageTriggerHandler(false,1); 
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy'
    											, Referral_Assessment_Date__c=Date.Today().addDays(-7)
    											,Referral_Outcome__c = 'Case Opened'); 
    // Start the test.
    //test.startTest();
    insert recSU;

    testHandler.SetFirstRun(true);   
    recSU.Assigned_Worker__c = U1.id;
    recSU.Referral_Assessment_Date__c=Date.Today().addDays(-1);
    update recSU;
    
    Test.StopTest(); 
    }      
}