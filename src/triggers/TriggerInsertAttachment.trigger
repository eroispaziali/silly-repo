trigger TriggerInsertAttachment on Attachment (before insert) {
 //Create a set of all unique Attachment Ids
   set<id> AttachmentIds = new set<id>();
    for (Attachment att: Trigger.new)
        AttachmentIds.add(att.ParentId);
    
    //Query for all the Recordtype Names on Contacts for the unique Attachment Ids in the records    
    //Create a map for a lookup for the Contact info    
    Map<id,Contact> Rectype = new Map<id,Contact>([Select Record_Type_Name__c from Contact where Id in :AttachmentIds]);  
    //Iterate over the list of records being processed in the trigger and
    //Check for the Record type Name 
    for(Attachment att: Trigger.new)
    try{
    if((Rectype.get(att.ParentId).Record_Type_Name__c == 'Person_with_dementia')
    ||(Rectype.get(att.ParentId).Record_Type_Name__c == 'Friend_or_Family_of_Person_with_Dementia' )
    ||(Rectype.get(att.ParentId).Record_Type_Name__c == 'Carer'))
        {
        att.addError ('You cannot insert Attachments to CRS Contacts');
        }
      }  
catch (Exception ex){
        // do nothing
        }
}