/**
Change 380 - Last Activity Date on Service Usage
    Update last activity date on Service usage when an assessment is updated.
    Mike Tinson 14 Jan 2014
**/

trigger Completed_Assessment_UpdateSULastActivityDate on Completed_Assessment__c (after insert, after update) {

Set<Id> SUIds = new Set<ID>();
for (Completed_Assessment__c newCA : Trigger.New){
    SUIds.add(newCA.service_usage__c);
    }
Map<Id,Service_Usage__c> Service_Usages = new Map<Id,Service_Usage__c>(
    [select id,Date_of_last_Activity__c from Service_Usage__c where id in :SUIds]);     
for (Completed_Assessment__c newCA : Trigger.New){
    try {
        Service_Usage__c su = Service_Usages.get(newCA.service_usage__c) ;
        if (su !=null){
            su.Date_of_last_Activity__c = newCA.LastModifiedDate.Date();
            update su;
            }
        } catch (DmlException ex) {
              // Do nothing
          newCA.addError('Error updating service usage:' + ex.getMessage()+'. Contact The CRS Helpdesk.');
        }
    }
}