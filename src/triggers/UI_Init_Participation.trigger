trigger UI_Init_Participation on UI_Activity_Participation__c (before insert, before update) {
    
    
    /* Add the Contact Id to the record to enable a direct connection */
        
    Map<String, String> mapParticipants =  new Map<String,String>();    
    List<String> lisParticipantIds = new List<String>();
  
    /* Get all the participant Ids */        
    for (UI_Activity_Participation__c p : trigger.new) {
    
        lisParticipantIds.add(p.UI_Participant__c);
        
    }
        
    /* Get the contacts and put them in a map */    
    List<UI_Participant__c> participants = [select id, Contact__c from UI_Participant__c where id in:lisParticipantIds];
    for (UI_Participant__c participant : participants) {    

        mapParticipants.put(participant.id, participant.Contact__c);        

    }    
    
    /* Insert the contact Ids from the map */
    for (UI_Activity_Participation__c p : trigger.new) {    

        p.Contact__c = mapParticipants.get(p.UI_Participant__c);        

    }
    
}