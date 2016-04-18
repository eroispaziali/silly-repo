global class ServiceUsageOwnerReassignment implements Database.Batchable<sObject>{
Public String query {get;set;}
Public String email{get;set;}
Public Id toUserId{get;set;}
Public Id fromUserId{get;set;}

global Database.querylocator start(Database.BatchableContext BC){
    System.debug('################query##############' + query);
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<Service_Usage__c> sus = new List<Service_Usage__c>();

   for(sObject s : scope){Service_Usage__c a = (Service_Usage__c)s;
        if(a.OwnerId==fromUserId){
            a.OwnerId=toUserId;
            a.Assigned_Worker__c=toUserId;
            sus.add(a);
            }
        }

update sus;
    
}
global void finish(Database.BatchableContext BC){
// First, reserve email capacity for the current Apex transaction to ensure
// that we won't exceed our daily email limits when sending email after
// the current transaction is committed.
Messaging.reserveSingleEmailCapacity(1);

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

mail.setToAddresses(new String[] {email});
mail.setReplyTo('mike.tinson@alzheimers.org.uk');
mail.setSenderDisplayName('Batch Processing');
mail.setSubject('Batch Process Completed');
String strMessage = 'Batch Process has completed';
strMessage = strMessage  + '\n query: ' + query;
strMessage = strMessage  + '\n toUserId: ' + toUserId;
strMessage = strMessage  + '\n fromUserId: ' + fromUserId;
mail.setPlainTextBody( strMessage );
//mail.setPlainTextBody('Batch Process Completed');
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}