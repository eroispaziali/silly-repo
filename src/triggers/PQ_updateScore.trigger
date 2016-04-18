trigger PQ_updateScore on PQ__c (after update) {
	try {
	
    // delete old score
    for (PQ__c pq : Trigger.old) {
        // get the score object's name
        String activity = 'Asked PQ: ' + pq.Subject__c;
        
        // look up the object
        MP_Score_per_Object__c score = [select id from MP_Score_per_Object__c
                                        where Activity__c = :activity limit 1];
        
        // and delete
        delete score;
    }
    
    // insert new score
    for (PQ__c pq : Trigger.new) {
        // look up score for asking a PQ
        MP_Scores__c score = [select Score__c from MP_Scores__c where Name = 'PQ' limit 1];
        
        // create score object
        MP_Score_per_Object__c mps = new MP_Score_per_Object__c(MP__c = pq.Contact__c,
                                                                Activity__c = 'Asked PQ: ' + pq.Subject__c,
                                                                Score__c = score.Score__c,
                                                                Campaign__c = pq.Campaign__c);
                                                                
        // insert score to database
        insert mps;
    }
    
    } catch (DmlException e) {
		// Do nothing
    }
}