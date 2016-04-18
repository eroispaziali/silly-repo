trigger PQ_addScore on PQ__c (after insert) {
    for (PQ__c pq : Trigger.new) {
    	try {
        	// look up score for asking a PQ
        	MP_Scores__c score = [select Score__c from MP_Scores__c where Name = 'PQ' limit 1];
        
        	// create score object
        	MP_Score_per_Object__c mps = new MP_Score_per_Object__c(MP__c = pq.Contact__c,
													Activity__c = 'Asked PQ: ' + pq.Subject__c,
                                                    Score__c = score.Score__c,
                                                    Campaign__c = pq.Campaign__c);
                                                                
        	// insert score to database
            insert mps;
        } catch (DmlException e) {
            // Do nothing
        }
    }
}