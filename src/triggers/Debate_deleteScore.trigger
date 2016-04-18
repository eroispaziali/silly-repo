trigger Debate_deleteScore on Debate__c (after delete) {
    for (Debate__c d : Trigger.old) {
    	try {
        	// get the score object's name
        	String activity = 'Organised Debate: ' + d.Name;
        
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