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
private class ServiceServiceUsageRelatedListCtr_Test {

    static testMethod void ServiceServiceUsageRelatedListCtr_Test() {
	Id servRT;
    servRT = [select Id from RecordType where DeveloperName ='Internal' and SObjectType='Services__c'].id;
    
    Id servUseageRT;
    servUseageRT = [select Id from RecordType where DeveloperName ='Dementia_Cafe' and SObjectType='Service_Usage__c'].id;
    
    Profile prof = [Select Id from Profile where Name = 'System Administrator' limit 1];
    User usr =[Select Id from User where IsActive =true and ProfileId =: prof.id  limit 1]; 
        
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;

    Account acc = new Account(Name='Test Region',RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'Internal%'].id);
    insert acc;                          
    
    Account landlord = new Account(Name='Test landlord',Category__c='Landlord',RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'External%'].id);
    insert landlord;                    
    
    Account landlordagent = new Account(Name='Test landlord agent',Category__c='Landlord Agent',RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'External%'].id);
    insert landlordagent;
    
    Location__c loc = new Location__c(Name='Test Location',RecordTypeId=[Select Id from RecordType where SObjectType='Location__c' and Name Like 'Lease/License'].id,
                             Where__c=acc.Id, Landlord__c=landlord.Id, Landlord_Agent__c=landlordagent.Id);
    insert loc;
    
    Services__c serv = new Services__c(Name='testControllerService', Locality__c=accRec.id,Service_Type__c='Dementia cafe',
    									Default_Location__c=loc.id, RecordTypeId=servRT, National_Service__c=false);
    insert serv;
 
	 //create look up used by trigger on Service Usage
	RegionAreaLocalityMap__c RALMap = new RegionAreaLocalityMap__c();
	RALMap.RegionAreaLocalityName__c='Locality Management - Midlands Central';
	RALMap.RegionAreaLocalityNameNew__c = 'Locality Management - Birmingham, Solihull, Coventry & Warks';
	insert RALMap;   
 
 
    Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert con1;
    
    Service_Usage__c servUsg1 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con1.id,
        Service_Type__c='Dementia cafe', RecordTypeId= servUseageRT);
    insert servUsg1;
    
    System.runAs(usr)
    {
    ApexPages.currentPage().getParameters().put('Id', serv.id);        
    ServiceServiceUsageRelatedListController conCls= new ServiceServiceUsageRelatedListController(new ApexPages.StandardController(serv));
    conCls.AutoRunNonExternalSU();
    String FirstName = conCls.CONFirstname;
    String SecondName=conCls.CONLastname;
    
    }

    ApexPages.currentPage().getParameters().put('Id', serv.id);        
    ServiceServiceUsageRelatedListController conCls2= new ServiceServiceUsageRelatedListController(new ApexPages.StandardController(serv));    
    conCls2.AutoRunNonExternalSU();
    

    }
}