trigger Trigger_Collector_Session on Collector_Session__c (before insert, before update) {
/***
prevent duplicate sessions for the same person
***/
String errMsg = 'A session already exists for this collector at this session';

Map<String, Collector_Session__c> sessionMap = new Map<String, Collector_Session__c>();
Map<String, Collector_Session__c> sessionMap2 = new Map<String, Collector_Session__c>();

for (Collector_Session__c  sessionRec: System.Trigger.new){
    // make sure that we do not worry about updates of other fields
    if (System.Trigger.isInsert || (System.Trigger.isUpdate &&
                                     (sessionRec.CollectionSession__c!=System.Trigger.oldMap.get(sessionRec.Id).CollectionSession__c ||
                                      sessionRec.Collector__c!=System.Trigger.oldMap.get(sessionRec.Id).Collector__c)))
    {
        //make sure that not adding another duplicate
        if (sessionMap.containsKey(sessionRec.CollectionSession__c)&&sessionMap2.containsKey(sessionRec.Collector__c))
        {
            sessionRec.addError(errMsg);
        }
    else
        {
           sessionMap.put(sessionRec.CollectionSession__c,  sessionRec);
           sessionMap2.put(sessionRec.Collector__c,  sessionRec);
        
        }
    }
}
//using single database query find all duplicates
for (Collector_Session__c sessionDup : [SELECT CollectionSession__c,Collector__c from Collector_Session__c  WHERE
                                        CollectionSession__c IN:sessionMap.KeySet() AND
                                        Collector__c IN:sessionMap2.KeySet()])
{
    Collector_Session__c  newSession = sessionMap2.get(sessionDup.Collector__c);
    newSession.Collector__c.addError(errMsg);
} 

}