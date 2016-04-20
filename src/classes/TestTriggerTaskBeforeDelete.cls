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
private class TestTriggerTaskBeforeDelete {

    static testMethod void testTriggerTaskBeforeDelete() {
  
  		//Get the Id of the CRS Profile. 
		Profile p = [SELECT Id FROM Profile WHERE Name='CRS'];
		
        //New User Record with IgnoreValidationRules__c = True.
        User U1 = new User(Alias = 'newUser1', Email='newuser1@alzheimers.org.uk', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
         				LocaleSidKey='en_GB', ProfileId = p.Id, TimeZoneSidKey='GMT', UserName='newuser1@alzheimers.org.uk', IgnoreValidationRules__c=True);
		insert U1;         				
	
		// New User Record with IgnoreValidationRules__c = False.
        User U2 = new User(Alias = 'newUser2', Email='newuser2@alzheimers.org.uk', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
         				LocaleSidKey='en_GB', ProfileId = p.Id, TimeZoneSidKey='GMT', UserName='newuser2@alzheimers.org.uk', IgnoreValidationRules__c=False);
		insert U2;  
		
		//Debug User Details.
	    System.debug('********** User1: ' + U1.UserName);
	    System.debug('********** User2: ' + U2.UserName);
	    
	    //Select the Id's of a CRS Record Type and a Non CRS Record Type.
		RecordType rtIdCRS = [SELECT Id FROM RecordType WHERE Name ='CRS Information Provision Task' AND SobjectType = 'Task'];
		RecordType rtIdNonCRS = [SELECT Id FROM RecordType WHERE Name ='Non-CRS Task' AND SobjectType = 'Task'];
		
		//Get a Record Type for the Contact Object.
		RecordType rtIdCON = [SELECT Id FROM RecordType WHERE Name ='Person with Dementia' AND SobjectType = 'Contact'];
				
		//Create a Contact to assign to the Task WhoId.
		Contact con = new Contact(FirstName='testFName', LastName='testLName', MailingPostalCode ='ABC123', MailingCity='abcd'
							, MailingCountry='abcd', MailingState='abcd', MailingStreet='abce',	RecordTypeId = rtIdCON.Id);    
        insert con;

		//WhoID refers to people things.  So that would be typically a Lead ID or a Contact ID
		//WhatID refers to object type things.  That would typically be an Account ID or an Opportunity ID
		
		//Create a Task for CRS Record Type.
		Task taskCreation1 = new Task(); 								//Object initialized.
                taskCreation1.RecordTypeId = rtIdCRS.Id;				//CRS Record Type;
                taskCreation1.Format__c = 'Telephone';					//Format of the Task.
                taskCreation1.Subject = 'Call'; 						//Subject for the task.
                taskCreation1.Priority = 'Normal'; 						//Setting the priority of the task.
                taskCreation1.Status = 'In Progress'; 					//Current status of the task.
                taskCreation1.Description = 'Task created for testing.';//Task Description.
                taskCreation1.WhoId = con.Id;							//The Contact the Task is assigned to.
                taskCreation1.OwnerId = U1.Id;
		insert taskCreation1;
		
		//Create a Task for a Non CRS Record Type.
		Task taskCreation2 = new Task(); 								//Object initialized.
                taskCreation2.RecordTypeId = rtIdNonCRS.Id;				//Non CRS Record Type.
                taskCreation2.Format__c = 'Telephone';					//Format of the Task.
                taskCreation2.Subject = 'Call'; 						//Subject for the task.
                taskCreation2.Priority = 'Normal'; 						//Setting the priority of the task.
                taskCreation2.Status = 'In Progress'; 					//Current status of the task.
                taskCreation2.Description = 'Task created for testing.';//Task Description.
                taskCreation2.WhoId = con.Id;							//The Contact the Task is assigned to.
                taskCreation2.OwnerId = U2.Id;
		insert taskCreation2;		
		
		//Now Delete the tasks causing the TriggerTaskBeforeDelete trigger to fire. 
        Test.startTest();
        delete taskCreation1;
        delete taskCreation2;
        Test.stopTest(); 
         
    }
}