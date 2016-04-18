@isTest
public with sharing class TestDF_ContactTriggerHandler{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for DF_ContactTriggerHandler Trigger.
 *  Author  : Ian Smith
 *  Date    : 23-01-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:	Apex Class to test DF_ContactTriggerHandler trigger on the DF_Contact__c object. 
 *               
 *  Modification History
 *  Date        	Who    	Description 
 *  dd-mm-yyyy		??		??
 *                             
*******************************************************************************************/

    static testMethod void testInsert(){
              
		//New Partner_Organisation__c Record to be added to the DF_Contact__c test Data.
		Partner_Organisation__c pa = new Partner_Organisation__c(Name='Test Org', DFC_Code__c='ABC123', Partner_External_Id__c=1234);
		insert pa;              
		
		//New DF_Contact__c Record to be added to the test Data.
		DF_Contact__c df = new DF_Contact__c(Name='Test DFC', Partner_Organisation_ID__c = pa.id, Contact_Ext_Id__c = 12345678);
        
        //Now insert data causing the DF_Contact__c trigger to fire. 
        Test.startTest();
		insert df;
        Test.stopTest(); 
    }
    
    
    
	static testMethod void testBulkInsert(){
              
		//New Partner_Organisation__c Record to be added to the DF_Contact__c test Data.
		Partner_Organisation__c pa = new Partner_Organisation__c(Name='Test Org', DFC_Code__c='ABC123', Partner_External_Id__c=1234);
		insert pa;              
		
		//New DF_Contact__c Record to be added to the test Data.
        DF_Contact__c[] dfConToCreate = new DF_Contact__c[]{};
        
        //Create 200 new DF_Contact Records for a Bulk test.
        for(Integer i=0; i< 200; i++){
            DF_Contact__c df = new DF_Contact__c(Name = 'Test DF Con',
				Contact_Ext_Id__c = i,
				Partner_Organisation_ID__c = pa.id
			);
            dfConToCreate.add(df);
        }
        
        //Now insert data causing the DF_Contact__c trigger to fire. 
        Test.startTest();	
        insert dfConToCreate;
        Test.stopTest();	
    }    
    
    
    
    static testMethod void testUpdate(){
    	
		// New Partner_Organisation__c Record to be added to the DF_Contact__c test Data.
		Partner_Organisation__c pa = new Partner_Organisation__c(Name='Test Org', DFC_Code__c='ABC123', Partner_External_Id__c=1234);
		insert pa;              
		
		// New DF_Contact__c Record to be added to the test Data.
		DF_Contact__c df = new DF_Contact__c(Name='Test DFC', Partner_Organisation_ID__c = pa.id, Contact_Ext_Id__c = 12345678);
		insert df;	
		
		Test.startTest();  // Start Executing the test.

		df.Name = 'TestDFC';
		df.First_Name__c = 'Test FirstName';
		df.Last_Name__c = 'Test LastName';	
		update df;
		        
        Test.stopTest();  // Stops the test execution.
                
        System.assertEquals('TestDFC', [select Name from DF_Contact__c where id =: df.id].Name);
	}
  
  
  
	static testMethod void testBulkUpdate(){
    	
		//New Partner_Organisation__c Record to be added to the DF_Contact__c test Data.
		Partner_Organisation__c pa = new Partner_Organisation__c(Name='Test Org', DFC_Code__c='ABC123', Partner_External_Id__c=1234);
		insert pa;              
		
		//New Batch of DF_Contact__c Records to be added to the test Data.
		List<DF_Contact__c> lstDFContact = new List<DF_Contact__c>();

		//Create 200 new DF_Contact Records for a Bulk test.
		for (Integer i=0 ; i <200; i++) {
			DF_Contact__c df = new DF_Contact__c(
				Name = 'Test DF Con',
				Contact_Ext_Id__c = i,
				Partner_Organisation_ID__c = pa.id
			);	
            lstDFContact.add(df);
        }

		List<DF_Contact__c> lstToUpdate = [select Id, Name from DF_Contact__c where Name = 'Test DF Con'];
		for(DF_Contact__c df : lstToUpdate){
            df.Name = 'TestDFcon';
        }
	 
		Test.startTest();  // Start Executing the test.	 
		update lstToUpdate;
        Test.stopTest();  // Stops the test execution.
	}
    
    
    
    static testMethod void testDelete(){

		//New Partner_Organisation__c Record to be added to the DF_Contact__c test Data.
		Partner_Organisation__c pa = new Partner_Organisation__c(Name='Test Org', DFC_Code__c='ABC123', Partner_External_Id__c=1234);
		insert pa;              
		
		//New DF_Contact__c Record to be added to the test Data.
		DF_Contact__c df = new DF_Contact__c(Name='Test DFC', Partner_Organisation_ID__c = pa.id, Contact_Ext_Id__c = 12345678);
		insert df;
		
		Test.startTest();  // Start Executing the test.		       
		delete df;
		Test.stopTest();  // Stops the test execution.
  }    
    
 
 
}