trigger DebateAttend_deleteScore on MP_Debate_Association__c (after delete) {
    for (MP_Debate_Association__c da : Trigger.old) {
    	try {
        	// look up this association's EDM
        	Debate__c d = [select Name from Debate__c where id = :da.Debate__C];
        
        	// get the score object's name
        	String activity = 'Attended Debate: ' + d.Name;
        
        	// look up the object
        	MP_Score_per_Object__c score = [select id from MP_Score_per_Object__c
            	                            where Activity__c = :activity limit 1];
                                                                
        	// insert score to database
            delete score;
        } catch (DmlException e) {
            // Do nothing
        }
    }
}