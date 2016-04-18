global class BatchRecalculateSUApexSharing implements Database.Batchable <Sobject> {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Batch APEX Class to re-calculate the Apex Sharing rules for Service Usage records.
 *  Author  : Ian Smith
 *  Date    : 10-06-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Batch APEX Class to re-calculate the Apex Sharing rules for selected Service 
 *                  Usage records. 
 *
 *                  Called via the Execute Anonymous window. 
 *                  BatchRecalculateSUApexSharing su = new BatchRecalculateSUApexSharing();
 *                  su.query = 'SELECT su.Id FROM Service_Usage__c su WHERE su.Service_Field__r.Operated_By__r.Name = 'Black Country Local Service Office'';
 *               
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ??
 *                             
*******************************************************************************************/
    static String emailAddress = 'crssupport@alzheimers.org.uk';
    global String query {get; set;}
    global List<Service_Usage__c> saveList = new List<Service_Usage__c>();
    
    //*Note - the Query will be set when the code is called from an Execute Anonymous window.
    //Query set to - SELECT su.Id FROM Service_Usage__c su WHERE su.Service_Field__r.Operated_By__r.Name = '<LOCAL SERVICE OFFICE>'
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<Sobject> lstServiceUsage){
        system.debug('****** About to process ' + lstServiceUsage.size() + ' records in BatchRecalculateSUApexSharing.execute ******');

        if(lstServiceUsage.size() > 0){
            
            //get list of Apex sharing rows for these records
            List<Service_Usage__Share> lstSUApexShareToDelete = [SELECT s.Id, s.ParentId, s.IsDeleted, s.AccessLevel, s.RowCause
                                                                 FROM Service_Usage__Share s 
                                                                 WHERE ParentId in :lstServiceUsage 
                                                                 AND IsDeleted!=true
                                                                 AND AccessLevel='Edit' 
                                                                 AND RowCause=:Schema.Service_Usage__Share.RowCause.ApexSharing__c];                                   
            System.debug('****** lstSUApexShareToDelete.Size ******: ' + lstSUApexShareToDelete.Size());
            
            if(lstSUApexShareToDelete.size() > 0){
                //Attempt to delete the Apex Sharing Rules for the specified Service Usage records.
                try{
                    System.debug('****** Deleting Apex Sharing for ******: ' + lstSUApexShareToDelete.size() + ' Records.');
                    delete lstSUApexShareToDelete;
                }
                catch(DmlException e) {
                   //Send an email to crssupport on failure.
                    notificationExceptionEmail(e,'BatchRecalculateSUApexSharing',emailAddress);
                    throw e;
                } 
            } 
            
            if (lstServiceUsage.size() > 0){
                //Attempt to Update the Apex Sharing Rules for the specified Service Usage records lstServiceUsage
                //and force the Service Usage trigger to fire.
                try{
                    System.debug('****** Updating Apex Sharing for ******: ' + lstServiceUsage.size() + ' Records.');
                    update lstServiceUsage;
                }
                catch(DmlException e) {
                   //Send an email to crssupport on failure.
                    notificationExceptionEmail(e,'BatchRecalculateSUApexSharing',emailAddress);
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
        mail.setSubject('Batch Process BatchRecalculateSUApexSharing Completed');
        mail.setPlainTextBody('Batch Process BatchRecalculateSUApexSharing has completed');
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