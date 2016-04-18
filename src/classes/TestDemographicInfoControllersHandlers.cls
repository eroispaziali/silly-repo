@isTest
private class TestDemographicInfoControllersHandlers {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Test Class to test the controllers relating to the Demographic_Information__c object
 *  Author  : Ian Smith
 *  Date    : 13 August 2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Test 
 *                     ServiceUageDemographicInfoRLController
 *                     DemographicInformationController2
 *               
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ????                           
*******************************************************************************************/

static testMethod void TestDemographicControllers (){
    Profile prof = [Select Id from Profile where Name = 'System Administrator' limit 1];
    User usr =[Select Id from User where IsActive =true and ProfileId =: prof.id  limit 1]; 
        
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    
    Services__c serv = new Services__c(Locality__c=accRec.id,Service_Type__c='Advocacy');//Name='testControllerService');
    insert serv;
    
 
 
    Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert con1;
            //-----------------------------------------------------------------------------------------------------
        //Demographic_Information__c Setup.
        //-----------------------------------------------------------------------------------------------------

    //New Demographic_Information__c Record to be added to the test Data.
    Demographic_Information__c demo = new Demographic_Information__c(Name = con1.Client_reference_number__c, 
                                    Person__c = con1.id, 
                                    Date_of_Change_of_Living_Arrangements__c = Date.today(),
                                    Employment_Status__c = 'Employed',
                                    Ethnic_Group__c = 'White: Gypsy or Irish Traveller',
                                    Ethnicitiy__c = 'Irish Traveller',
                                    Faith_Culture__c = 'Catholic',
                                    Living_arrangements__c = 'Not disclosed',
                                    NHS_Number__c = '1234567890',
                                    NI_Trust_Area__c = 'BHSCT',
                                    Number_of_dependent_children__c = 9,
                                    Other_Demographic_Details__c = '',
                                    Partnership_status__c = 'Not disclosed',
                                    People_in_household__c = 'Unknown',
                                    Registered_with_Social_Services__c = false,
                                    Sexual_Status__c = 'Not Disclosed',
                                    Veteran__c = 'Not Disclosed');
                                    
     insert demo;                                    
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
    
    //service was 'Home facilities & services'
    //Services__c serv2 = new Services__c(Locality__c=accRec.id,Service_Type__c='Newsletter',
    //    Primary_contact__c=usr.id,Default_Location__c=loc.id);
    Services__c serv2 = new Services__c(Locality__c=accRec.id,Service_Type__c='Newsletter',
        Default_Location__c=loc.id);
    
    insert serv2;   
    
    Service_Usage__c servUsg1 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con1.id,
        Service_Type__c='Advocacy');
    insert servUsg1;
    

    //System.runAs(usr)
    //{
    ApexPages.currentPage().getParameters().put('Id', servUsg1.id);        
    DemographicInformationController suCls= new DemographicInformationController(new ApexPages.StandardController(servUsg1));
    suCls.save();
    
    ServiceUsageDemographicInfoRLController suDemoInfRL = new ServiceUsageDemographicInfoRLController(new ApexPages.StandardController(servUsg1));
    suDemoInfRL.create();
    System.Debug(suDemoInfRL.getIsNewButtonDisabled());
    PageReference testPage = suDemoInfRL.NewImplementation();
    //}

 



}

}