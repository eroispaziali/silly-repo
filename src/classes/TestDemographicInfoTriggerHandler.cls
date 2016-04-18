@isTest
public with sharing class TestDemographicInfoTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for DemographicInfoTriggerHandler Trigger.
 *  Author  : Ian Smith
 *  Date    : 24-06-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class to test DemographicInfoTriggerHandler trigger on the Demographic_Information__c
 *                  object. 
 *               
 *  Modification History
 *  Date            Who     Description 
 *  dd-mm-yyyy      ??      ??
 *                             
*******************************************************************************************/
private static final String RT_CON_INTERNAL = 'Person_with_dementia';


    static testMethod void testInsert(){
        //-----------------------------------------------------------------------------------------------------
        //People (Contact) Setup.
        //-----------------------------------------------------------------------------------------------------
        
        //Add People (Contact) RecordTypes to a Map Collection. 
        Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
        for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
            contactRTMap.put(rt.DeveloperName, rt);
        }  
        
        //New People (Contact) Record to be added to the test Data.
        Contact con = new Contact(Title = 'Mr',
                            FirstName = 'Joe', 
                            LastName = 'Bloggs', 
                            Gender__c = 'Male',
                            First_language__c = 'English',
                            Consent_Status__c = 'Awaiting Consent',
                            Deceased__c = False,
                            RecordTypeId = contactRTMap.get(RT_CON_INTERNAL).Id);
        insert con;              
              
        //-----------------------------------------------------------------------------------------------------
        //Demographic_Information__c Setup.
        //-----------------------------------------------------------------------------------------------------

        //New Demographic_Information__c Record to be added to the test Data.
        Demographic_Information__c demo = new Demographic_Information__c(Name = con.Client_reference_number__c, 
                                                                        Person__c = con.id, 
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
        
        //Now insert data causing the Demographic_Information__c trigger to fire. 
        Test.startTest();
        insert demo;
        Test.stopTest();
        
        System.assertEquals(demo.Person__c,con.Id);               
    }
    
    
   
    static testMethod void testBulkInsert(){
        //-----------------------------------------------------------------------------------------------------
        //People (Contact) Setup.
        //-----------------------------------------------------------------------------------------------------
        
        //Add People (Contact) RecordTypes to a Map Collection. 
        Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
        for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
            contactRTMap.put(rt.DeveloperName, rt);
        }  
        
        //New Batch of Contact Records to be added to the test Data.
        List<Contact> lstContact = new List<Contact>();

        //Create 200 new Contact Records for a Bulk test.
        for (Integer i=0 ; i <50; i++) {
            Contact c = new Contact(
                            Title = 'Mr',
                            FirstName = 'Joe', 
                            LastName = 'Bloggs' + i, 
                            Gender__c = 'Male',
                            First_language__c = 'English',
                            Consent_Status__c = 'Awaiting Consent',
                            Deceased__c = False,
                            RecordTypeId = contactRTMap.get(RT_CON_INTERNAL).Id);
            lstContact.add(c);
        }        
        insert lstContact;      
           
        //-----------------------------------------------------------------------------------------------------
        //Demographic_Information__c Setup.
        //-----------------------------------------------------------------------------------------------------
            
        //New Demographic_Information__c Record to be added to the test Data.
        Demographic_Information__c[] demoInfoToCreate = new Demographic_Information__c[]{};
        
        //Create 200 new DF_Contact Records for a Bulk test.
        for(Integer i=0; i< 50; i++){
            Demographic_Information__c d = new Demographic_Information__c(Person__c = lstContact[i].Id,
                Name = lstContact[i].Client_reference_number__c, 
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
                Veteran__c = 'Not Disclosed'
            );
            demoInfoToCreate.add(d);
        }
        
        //Now insert data causing the Demographic_Information__c trigger to fire. 
        Test.startTest();   
        insert demoInfoToCreate;
        Test.stopTest();    

    }    
    
        
        
    static testMethod void testUpdate(){
        //-----------------------------------------------------------------------------------------------------
        //People (Contact) Setup.
        //-----------------------------------------------------------------------------------------------------
        
        //Add People (Contact) RecordTypes to a Map Collection. 
        Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
        for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
            contactRTMap.put(rt.DeveloperName, rt);
        }  
        
        //New People (Contact) Record to be added to the test Data.
        Contact con = new Contact(Title = 'Mr',
                            FirstName = 'Joe', 
                            LastName = 'Bloggs', 
                            Gender__c = 'Male',
                            First_language__c = 'English',
                            Consent_Status__c = 'Awaiting Consent',
                            Deceased__c = False,
                            RecordTypeId = contactRTMap.get(RT_CON_INTERNAL).Id);
        insert con;              
              
        //-----------------------------------------------------------------------------------------------------
        //Demographic_Information__c Setup.
        //-----------------------------------------------------------------------------------------------------

        //New Demographic_Information__c Record to be added to the test Data.
        Demographic_Information__c demo = new Demographic_Information__c(Name = con.Client_reference_number__c, 
                                                                        Person__c = con.id, 
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
        
        //Now Update data causing the Demographic_Information__c trigger to fire. 
        Test.startTest();  // Start Executing the test.

        demo.Employment_Status__c = 'Unemployed';
        update demo;
                
        Test.stopTest();  // Stops the test execution.
                
        System.assertEquals('Unemployed', [SELECT Employment_Status__c FROM Demographic_Information__c WHERE id =: demo.id].Employment_Status__c);      

    }
    
    
    
    static testMethod void testDelete(){
        //-----------------------------------------------------------------------------------------------------
        //People (Contact) Setup.
        //-----------------------------------------------------------------------------------------------------
        
        //Add People (Contact) RecordTypes to a Map Collection. 
        Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
        for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
            contactRTMap.put(rt.DeveloperName, rt);
        }  
        
        //New People (Contact) Record to be added to the test Data.
        Contact con = new Contact(Title = 'Mr',
                            FirstName = 'Joe', 
                            LastName = 'Bloggs', 
                            Gender__c = 'Male',
                            First_language__c = 'English',
                            Consent_Status__c = 'Awaiting Consent',
                            Deceased__c = False,
                            RecordTypeId = contactRTMap.get(RT_CON_INTERNAL).Id);
        insert con;              
              
        //-----------------------------------------------------------------------------------------------------
        //Demographic_Information__c Setup.
        //-----------------------------------------------------------------------------------------------------

        //New Demographic_Information__c Record to be added to the test Data.
        Demographic_Information__c demo = new Demographic_Information__c(Name = con.Client_reference_number__c, 
                                                                        Person__c = con.id); 
        insert demo;
        
        //Now Delete data causing the Demographic_Information__c trigger to fire. 
        Test.startTest();  // Start Executing the test.            
        delete demo;
        Test.stopTest();  // Stops the test execution.
        
        System.assert(true, demo==null); 
    }    
    
 

    static testMethod void testDupeDemographicRecord(){
        //-----------------------------------------------------------------------------------------------------
        //People (Contact) Setup.
        //-----------------------------------------------------------------------------------------------------
        
        //Add People (Contact) RecordTypes to a Map Collection. 
        Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
        for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
            contactRTMap.put(rt.DeveloperName, rt);
        }  
        
        //New People (Contact) Record to be added to the test Data.
        Contact con = new Contact(Title = 'Mr',
                            FirstName = 'Joe', 
                            LastName = 'Bloggs', 
                            Gender__c = 'Male',
                            First_language__c = 'English',
                            Consent_Status__c = 'Awaiting Consent',
                            Deceased__c = False,
                            RecordTypeId = contactRTMap.get(RT_CON_INTERNAL).Id);
        insert con;
        
        //-----------------------------------------------------------------------------------------------------
        //Demographic_Information__c Setup.
        //-----------------------------------------------------------------------------------------------------

        //New Demographic_Information__c Record to be added to the test Data.
        Demographic_Information__c demo = new Demographic_Information__c(Name = con.Client_reference_number__c, 
                                                                        Person__c = con.id,
                                                                        NHS_Number__c = '1234567890');
        insert demo;
        
        Demographic_Information__c demo2 = new Demographic_Information__c(Name = con.Client_reference_number__c, 
                                                                        Person__c = con.id,
                                                                        NHS_Number__c = '0987654321');
     
        Test.startTest();  // Start Executing the test.  
        try{
            insert demo2;
        }catch(DmlException  e){
//          System.debug('****** testDupeDemographicRecord DmlException  ******'+ e.getMessage());
//          System.assert(e.getMessage().equals('A Demographic Infomation record for this Person already exists!'));
            
            System.assert(e.getMessage().contains('Insert failed. First exception on row 0; first error: ' +
                                'FIELD_CUSTOM_VALIDATION_EXCEPTION, A Demographic Information record ' + 
                                'for this Person already exists!: [Person__c]'), e.getMessage());
        }
        Test.stopTest();  // Stops the test execution.
    }



    static testMethod void testNegativeTestCase(){
        //-----------------------------------------------------------------------------------------------------
        //People (Contact) Setup.
        //-----------------------------------------------------------------------------------------------------
        
        //Add People (Contact) RecordTypes to a Map Collection. 
        Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
        for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
            contactRTMap.put(rt.DeveloperName, rt);
        }  
        
        //New People (Contact) Record to be added to the test Data.
        Contact con = new Contact(Title = 'Mr',
                            FirstName = 'Joe', 
                            LastName = 'Bloggs', 
                            Gender__c = 'Male',
                            First_language__c = 'English',
                            Consent_Status__c = 'Awaiting Consent',
                            Deceased__c = False,
                            RecordTypeId = contactRTMap.get(RT_CON_INTERNAL).Id);
        insert con;
        
        //-----------------------------------------------------------------------------------------------------
        //Demographic_Information__c Setup.
        //-----------------------------------------------------------------------------------------------------

        //New Demographic_Information__c Record to be added to the test Data.
        Demographic_Information__c demo = new Demographic_Information__c(Name = con.Client_reference_number__c, 
                                                                        Person__c = con.id,
                                                                        NHS_Number__c = '12345678908954');
 
        Test.startTest();  // Start Executing the test.  
        try{
            insert demo;
        }catch(DmlException  e){
            System.debug('****** testNegativeTestCase DmlException  ******'+ e.getMessage());

            System.assert(e.getMessage().contains('Insert failed. First exception on row 0; first error: STRING_TOO_LONG, NHS Number: data value too large: ' +
                + demo.NHS_Number__c + ' (max length=10): [NHS_Number__c]'), e.getMessage());
        }
        Test.stopTest();  // Stops the test execution.
    }
            
 
}