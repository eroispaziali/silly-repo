trigger PQ_deleteScore on PQ__c (after delete) {
    for (PQ__c pq : Trigger.old) {
    	try {
        	// get the score object's name
        	String activity = 'Asked PQ: ' + pq.Subject__c;
        
        	// look up the object
        	MP_Score_per_Object__c score = [select id from MP_Score_per_Object__c
            	                            where Activity__c = :activity limit 1];
        
        	// and delete
            delete score;
        } catch (Exception e) {
        	// Do nothing
        }
    }
}