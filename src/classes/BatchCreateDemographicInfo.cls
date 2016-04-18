global with sharing class BatchCreateDemographicInfo implements Database.Batchable <Sobject> {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Batch APEX Class to Create Demographic Information records for Contacts.
 *  Author  : Ian Smith
 *  Date    : 10-06-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Batch APEX Class to Create Demographic Information records for Contacts. 
 *
 *                  Called via the Execute Anonymous window. 
 *                  BatchCreateDemographicInfo b = new BatchCreateDemographicInfo();
 *                  b.query = '[SELECT Id,Client_reference_number__c,Date_of_Change_of_Living_Arrangements__c,Employment_Status__c
 *                              ,Ethnic_Group__c,Ethnicitiy__c,Faith_Culture__c,Living_arrangements__c,NI_Trust_Area__c
 *                              ,Number_of_dependent_children__c,Other_Demographic_Details__c,Partnership_status__c
 *                              ,People_in_household__c,Registered_with_Social_Services__c,Sexual_Status__c,Veteran__c
 *                              FROM Contact
 *                              WHERE Ethnic_Group__c <> NULL
 *                                  OR Ethnicitiy__c  <> NULL
 *                                  OR Faith_Culture__c  <> NULL
 *                                  OR Partnership_status__c  <> NULL
 *                                  OR Sexual_Status__c  <> NULL
 *                                  OR Veteran__c  <> NULL
 *                                  OR NI_Trust_Area__c  <> NULL]';
 *
 *                  //Invoke the Batch class.
 *                  ID batchprocessid = Database.executeBatch(b);
 *               
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ??
 *                             
*******************************************************************************************/
    static String emailAddress = 'crssupport@alzheimers.org.uk';
    global String query {get; set;}
    global List<Contact> saveList = new List<Contact>();
    
    //*Note - the Query will be set when the code is called from an Execute Anonymous window.
    //Query set to - SELECT su.Id FROM Service_Usage__c su WHERE ?????'
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<Contact> lstContacts){
        system.debug('****** About to process ' + lstContacts.size() + ' records in BatchCreateDemographicInfo.execute ******');

        if(lstContacts.size() > 0){
            
            //New Demographic_Information__c Records to be added.
            List<Demographic_Information__c> lstDemoInfo = new List<Demographic_Information__c>();

            for(Contact c : lstContacts){   
                Demographic_Information__c d = new Demographic_Information__c(
                                Person__c = c.Id,
                                Name = c.Client_reference_number__c, 
                                Date_of_Change_of_Living_Arrangements__c = c.Date_of_Change_of_Living_Arrangements__c,
                                Employment_Status__c = c.Employment_Status__c, 
                                Ethnic_Group__c = c.Ethnic_Group__c, 
                                Ethnicitiy__c = c.Ethnicitiy__c,
                                Faith_Culture__c = c.Faith_Culture__c,
                                Living_arrangements__c = c.Living_arrangements__c,
                                Number_of_dependent_children__c = c.Number_of_dependent_children__c,
                                Other_Demographic_Details__c = c.Other_Demographic_Details__c,
                                Partnership_status__c = c.Partnership_status__c,
                                People_in_household__c = c.People_in_household__c,
                                Registered_with_Social_Services__c = c.Registered_with_Social_Services__c,
                                Sexual_Status__c = c.Sexual_Status__c,
                                Veteran__c = c.Veteran__c);
                lstDemoInfo.add(d);
            } 
            System.debug('****** lstDemoInfo.Size ******' + lstDemoInfo.Size());       

            if(lstDemoInfo.size() > 0){
                //Attempt to Insert Demographic Info records..
                try{
                    System.debug('****** Inserting: ' + lstDemoInfo.size() + ' Demographic Info Records.');
                    insert lstDemoInfo;
                }
                catch(DmlException e) {
                   //Send an email to crssupport on failure.
                    notificationExceptionEmail(e,'BatchCreateDemographicInfo',emailAddress);
                    throw e;
                } 
            } 
        }
        
          
    }
    
    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailAddress}; 
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process BatchCreateDemographicInfo Completed');
        mail.setPlainTextBody('Batch Process BatchCreateDemographicInfo has completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }   
    
    public static void notificationExceptionEmail(Exception e, String locationName, String email) {
        //Send an email to crssupport on DmlException failure.
        String orgId = UserInfo.getOrganizationId();
        String orgName = UserInfo.getOrganizationName();
        String user = UserInfo.getUserName();
        String message = e.getMessage();
        String stacktrace = e.getStackTraceString();
        String exType = '' + e.getTypeName();
        String line = '' + e.getLineNumber();
        String theTime = '' + System.now();
        
        String subject = String.format('Exception thrown at {0} by user {1} in org {2} (Id: {3})', new List<String>{ locationName, user, orgName, orgId });
        String body = String.format('Time: {0}\nMessage: {1}\nStacktrace: {2}\nLine: {3}', new List<String>{ theTime, message, stacktrace, line });
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {email}; 
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject(subject);
        mail.setUseSignature(false);
        mail.setPlainTextBody(Body);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}