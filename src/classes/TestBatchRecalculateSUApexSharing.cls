@isTest
private class TestBatchRecalculateSUApexSharing{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test APEX Class for BatchRecalculateSUApexSharing Apex Class.
 *  Author  : Ian Smith
 *  Date    : 11-06-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Test APEX Class for BatchRecalculateSUApexSharing Apex Class which 
 *                  re-calculates the Apex Sharing rules for selected Service Usage records.
 *
 *                  *Note that since email messages aren’t sent from tests, and because the batch 
 *                  class is invoked by a test method, the email notifications won’t be sent in this case. 
 *
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ??
 *                             
*******************************************************************************************/
    private static final String RT_SERV_INTERNAL = 'Internal';
    private static final String RT_ACC_INTERNAL = 'InternalOrganisation';
    private static final String RT_CON_INTERNAL = 'Person_with_dementia';
    private static final String RT_SU_DEMENTIASUPPORT = 'Dementia_Support_Service_Usage';
    private static final String PROFILE = 'CRS and Service Data Manager';
    private static final String USERROLE = 'Dementia Adviser & Dementia Support - Herefordshire, Worcs & The Black Country';
    
    static testMethod void TestBatchRecalculateSUApexSharing() {
    
        //-----------------------------------------------------------------------------------------------------
        //User Setup - Support Services Manager.
        //-----------------------------------------------------------------------------------------------------
        
        //DML operations on certain sObjects can’t be mixed with other sObjects in the same transaction.
        //Avoid MIXED_DML_OPERATION error in Salesforce tests that create Users.
        User ssm;
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];        
        
        //Add Security Profiles to a Map Collection. 
        Map<String, Profile> profileMap = new Map<String, Profile>();
        for (Profile p : [SELECT p.Id, p.name FROM Profile p]){
            profileMap.put(p.name, p);
        }   
        
        //Add Security User Roles to a Map Collection. 
        Map<String, UserRole> userRoleMap = new Map<String, UserRole>();
        for (UserRole ur : [SELECT ur.Id, ur.Name FROM UserRole ur]){
            userRoleMap.put(ur.name, ur);
        }     
        
        System.runAs(thisUser){
            //New Support Service Manager User Record to be added to the test Data.
            ssm = new User(Alias = 'TestSSM', 
                            Email='crssupport@alzheimers.org.uk', 
                            EmailEncodingKey='UTF-8',
                            Title='Services Manager', 
                            FirstName='ServiceSupport',
                            LastName='Manager', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_GB',
                            ProfileId = profileMap.get(PROFILE).Id,
                            UserRoleId = userRoleMap.get(USERROLE).Id, 
                            TimeZoneSidKey='GMT', 
                            UserName='servicesupportmanager@alzheimers.org.uk', 
                            IgnoreValidationRules__c=True);
            insert ssm;         
        }
        
        System.runAs(ssm){
        
            //-----------------------------------------------------------------------------------------------------
            //Account Hierarchy Setup.
            //-----------------------------------------------------------------------------------------------------
            //Add Organisation (Account) RecordTypes to a Map Collection. 
            Map<String, RecordType> accountRTMap = new Map<String, RecordType>();
            for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Account']){
                accountRTMap.put(rt.DeveloperName, rt);
            }               

            //New Internal Organisation "West Region"(Account) Record to be added to the test Data.
            Account acc1 = new Account(Name = 'West Region', 
                                                    RecordTypeId = accountRTMap.get(RT_ACC_INTERNAL).Id);
            insert acc1;
            
            //New Internal Organisation "West Midlands Area" (Account) Record to be added to the test Data.
            Account acc2 = new Account(Name = 'West Midlands Area', 
                                                    ParentId = acc1.Id,
                                                    RecordTypeId = accountRTMap.get(RT_ACC_INTERNAL).Id);
            insert acc2;
            
            //New Internal Organisation "Herefordshire & Worcestershire Locality" (Account) Record to be added to the test Data.
            Account acc3 = new Account(Name = 'Herefordshire & Worcestershire Locality', 
                                                    ParentId = acc2.Id,
                                                    RecordTypeId = accountRTMap.get(RT_ACC_INTERNAL).Id);
            insert acc3;
            
            //New Internal Organisation "Herefordshire & Worcestershire Locality" (Account) Record to be added to the test Data.
            Account acc4 = new Account(Name = 'Black Country Local Service Office', 
                                                    ParentId = acc3.Id,
                                                    RecordTypeId = accountRTMap.get(RT_ACC_INTERNAL).Id);
            insert acc4;

            //-----------------------------------------------------------------------------------------------------
            //Contact Setup - Services User.
            //-----------------------------------------------------------------------------------------------------
            //Add People (Contact) RecordTypes to a Map Collection. 
            Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
            for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
                contactRTMap.put(rt.DeveloperName, rt);
            }  
            
            //New Support Service Manager User Record to be added to the test Data.
            Contact psu = new Contact(Title = 'Mr',
                                FirstName = 'Joe', 
                                LastName = 'Bloggs', 
                                Gender__c = 'Male',
                                First_language__c = 'English',
                                Consent_Status__c = 'Awaiting Consent',
                                Deceased__c = False,
                                RecordTypeId = contactRTMap.get(RT_CON_INTERNAL).Id);
            insert psu; 
    
            //-----------------------------------------------------------------------------------------------------
            //Dementia Connect Service Setup.
            //-----------------------------------------------------------------------------------------------------
            //Add Dementia Connect Service RecordTypes to a Map Collection. 
            Map<String, RecordType> servicesRTMap = new Map<String, RecordType>();
            for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Services__c']){
                servicesRTMap.put(rt.DeveloperName, rt);
            }
    
            //New Internal Service Record to be added to the test Data.
            Services__c internalService = new Services__c(Name = 'Testtown - Dementia Support Service',
                                                            service_type__c = 'Dementia support',
                                                            Locality__c = acc3.Id,
                                                            Operated_By__c = acc4.Id,
                                                            SSM__c = ssm.Id,
                                                            service_status__c = 'Open',
                                                            service_opendate__c = Date.today() - 15,
                                                            Postcodes_Covered__c = 'E1W 1LB',
                                                            service_description__c = 'Test Service for Black Country Local Service Office',
                                                            RecordTypeId = servicesRTMap.get(RT_SERV_INTERNAL).Id);
            insert internalService; 
                
            //-----------------------------------------------------------------------------------------------------
            //Service Usage Setup.
            //-----------------------------------------------------------------------------------------------------         
            //Add Service Usage RecordTypes to a Map Collection. 
            Map<String, RecordType> servicesUsageRTMap = new Map<String, RecordType>();
            for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Service_Usage__c']){
                servicesUsageRTMap.put(rt.DeveloperName, rt);
            }
    
            //New Dementia Support Service Usage Record to be added to the test Data.
            List<Service_Usage__c> servUsageToSave = new List<Service_Usage__c>();
            
            for(integer i = 0; i < 20; i++){
                Service_Usage__c su = new Service_Usage__c();
                su.Name = psu.Name + ' ' + i + ' Dementia Support Service';
                su.RecordTypeId = servicesUsageRTMap.get(RT_SU_DEMENTIASUPPORT).Id;
                su.Service_Field__c = internalService.Id;
                su.Primary_Service_User__c = psu.Id;
                su.Referral_Source__c = 'Internal Referral';
                su.Referral_Date__c = Date.today() - 15;
                su.Service_User_Aware_of_Referral__c = 'Yes';
                su.Service_Type__c = 'Dementia support';
                servUsageToSave.add(su);
            }   
            insert servUsageToSave;     
            
            //-----------------------------------------------------------------------------------------------------
            //Start Test.
            //-----------------------------------------------------------------------------------------------------         
            test.startTest();
            
            //Instantiate the class implementing the Database.Batchable interface.
            BatchRecalculateSUApexSharing suBatch = new BatchRecalculateSUApexSharing();
            suBatch.query = 'SELECT su.Id FROM Service_Usage__c su WHERE su.Service_Field__r.Operated_By__r.Name = \'Black Country Local Service Office\' and Closure_Reason__c =null LIMIT 20';
            
            
            //Invoke the Batch class.
            ID batchprocessid = Database.executeBatch(suBatch);
    
            test.stopTest();                            
    
            //-----------------------------------------------------------------------------------------------------
            //Assert that the Test worked as Expeted.
            //-----------------------------------------------------------------------------------------------------         
        
            //Get the Apex job and verify there are no errors.
            AsyncApexJob aaj = [Select JobType, TotalJobItems, JobItemsProcessed, Status, 
                                CompletedDate, CreatedDate, NumberOfErrors 
                                from AsyncApexJob where Id = :batchprocessid];
            System.assertEquals(0, aaj.NumberOfErrors);
            
            //Query returns Service Usage and related sharing records that were created       
            //by the batch job's execute method.
            List<Service_Usage__c> lstSU = [SELECT Id, 
                                                (SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause 
                                                 FROM Shares 
                                                 WHERE (RowCause = :Schema.Service_Usage__Share.RowCause.ApexSharing__c))
                                            FROM Service_Usage__c
                                            WHERE Id IN: servUsageToSave];        
    
            //Validate that Apex managed sharing exists on Service_Usage__c Records.     
            for(Service_Usage__c su : lstSU){
                //One Apex managed sharing record should exist for each Service Usage Record in the lstSU Collection.
                System.assert(su.Shares.size() == 1);
                
                for(Service_Usage__Share suShr : su.Shares){
                    //Test the sharing record for ApexSharing__c on the Service Usage record.             
                    if(suShr.RowCause == Schema.Service_Usage__Share.RowCause.ApexSharing__c){
                        System.assertEquals(suShr.ParentId,su.Id);
                        System.assertEquals(suShr.AccessLevel,'Edit');
                    }
                }
            } 
        
        } //System.runAs(ssm)
                  
    }
    
}