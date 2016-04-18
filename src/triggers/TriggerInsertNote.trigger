trigger TriggerInsertNote on Note (before insert) {
    //Create a set of all unique Note Ids
   set<id> NoteIds = new set<id>();
    for (Note nte: Trigger.new)
        NoteIds.add(nte.ParentId);
    
    //Query for all the Recordtype Names on Contacts for the unique Note Ids in the records    
    //Create a map for a lookup for the Contact info    
    Map<id,Contact> Rectype = new Map<id,Contact>([Select Record_Type_Name__c from Contact where Id in :NoteIds]);  
    //Iterate over the list of records being processed in the trigger and
    //Check for the Record type Name 
    for(Note nte: Trigger.new)
   try{
    if((Rectype.get(nte.ParentId).Record_Type_Name__c == 'Person_with_dementia')
    ||(Rectype.get(nte.ParentId).Record_Type_Name__c == 'Friend_or_Family_of_Person_with_Dementia' )
    ||(Rectype.get(nte.ParentId).Record_Type_Name__c == 'Carer'))
        {
        nte.addError ('You cannot insert notes to CRS Contracts');
        }
      }  
catch (Exception ex){
        // do nothing
        }
 }