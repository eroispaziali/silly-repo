@isTest
public with sharing class TestBatchCreateDemographicInfo {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test APEX Class for BatchCreateDemographicInfo Apex Class.
 *  Author  : Ian Smith
 *  Date    : 11-06-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Test APEX Class for BatchCreateDemographicInfo Apex Class which 
 *                  cretaes Demographic Information records for certain Contact records..
 *
 *                  *Note that since email messages aren’t sent from tests, and because the batch 
 *                  class is invoked by a test method, the email notifications won’t be sent in this case. 
 *
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ??
 *                             
*******************************************************************************************/

    private static final String RT_CON_PWD = 'Person_with_dementia';
    
    static testMethod void TestBatchCreateDemographicInfo() {
		//-----------------------------------------------------------------------------------------------------
		//Contact Setup.
		//-----------------------------------------------------------------------------------------------------         
		//Add Contact RecordTypes to a Map Collection. 
		Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
		for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
		    contactRTMap.put(rt.DeveloperName, rt);
		}

        //New Contact Record to be added to the test Data.
        List<Contact> ContactToSave = new List<Contact>();
            
        for(integer i = 0; i < 200; i++){
            Contact con = new Contact();
            con.RecordTypeId = contactRTMap.get(RT_CON_PWD).Id;
            con.Title = 'Mr';
			con.FirstName = 'Joe'; 
			con.LastName = 'Bloggs' + i; 
			con.Gender__c = 'Male';
			con.First_language__c = 'English';
			con.Consent_Status__c = 'Awaiting Consent';
			con.Deceased__c = False; 
			con.Ethnic_Group__c = 'White: Gypsy or Irish Traveller';
			con.Ethnicitiy__c = 'Gypsy/Romany';
			con.Faith_Culture__c = 'Islam / Muslim';   
			con.Sexual_Status__c = 'Lesbian';
			con.Number_of_dependent_children__c = 8;
			con.Other_Demographic_Details__c = 'TestData';            
            contactToSave.add(con);
        }   
        insert contactToSave;

        //-----------------------------------------------------------------------------------------------------
        //Start Test.
        //-----------------------------------------------------------------------------------------------------         
        test.startTest();
        
        //Instantiate the class implementing the Database.Batchable interface.
        BatchCreateDemographicInfo batch = new BatchCreateDemographicInfo();
        
        batch.query = 'SELECT Id,Name,Client_reference_number__c,Date_of_Change_of_Living_Arrangements__c,Employment_Status__c ' +
 					',Ethnic_Group__c,Ethnicitiy__c,Faith_Culture__c,Living_arrangements__c,NI_Trust_Area__c ' +
 					',Number_of_dependent_children__c,Other_Demographic_Details__c,Partnership_status__c ' +
 					',People_in_household__c,Registered_with_Social_Services__c,Sexual_Status__c,Veteran__c ' +
 					'FROM Contact ' +
 					'WHERE Ethnic_Group__c <> NULL ' +
 						'OR Ethnicitiy__c  <> NULL ' +
 						'OR Faith_Culture__c  <> NULL ' +
 						'OR Partnership_status__c  <> NULL ' + 
 						'OR Sexual_Status__c  <> NULL ' +
 						'OR Veteran__c  <> NULL ' +
 						'OR NI_Trust_Area__c  <> NULL';
		 
        //Invoke the Batch class.
        ID batchprocessid = Database.executeBatch(batch);

        test.stopTest();  
        
		//-----------------------------------------------------------------------------------------------------
        //Assert that the Test worked as Expeted.
        //-----------------------------------------------------------------------------------------------------         
        //Get the Apex job and verify there are no errors.
        AsyncApexJob aaj = [Select JobType, TotalJobItems, JobItemsProcessed, Status, 
                            CompletedDate, CreatedDate, NumberOfErrors 
                            from AsyncApexJob where Id = :batchprocessid];
        System.assertEquals(0, aaj.NumberOfErrors);
        
		//Verify the Demographic Information Records were inserted.
		Integer i = [SELECT COUNT() FROM Demographic_Information__c WHERE Other_Demographic_Details__c = 'TestData'];
		System.assertEquals(i,200);

	}         

}