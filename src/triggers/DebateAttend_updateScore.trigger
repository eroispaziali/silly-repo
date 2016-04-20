trigger DebateAttend_updateScore on MP_Debate_Association__c (after update) {
    // delete existing score
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
    
    // insert new score
    for (MP_Debate_Association__c da : Trigger.new) {
    	try {
        	// look up score for attending a debate
        	MP_Scores__c score = [select Score__c from MP_Scores__c where Name = 'Debate Attendee' limit 1];
        
        	// look up this association's debate
        	Debate__c d = [select Name, Organiser__c, Campaign__c from Debate__c where id = :da.Debate__C];
        
        	// create score object
        	MP_Score_per_Object__c mps = new MP_Score_per_Object__c(MP__c = da.MP__c,
            	                                                    Activity__c = 'Attended Debate: ' + d.Name,
                	                                                Score__c = score.Score__c,
                    	                                            Campaign__c = d.Campaign__c);
                                                                
        	// insert score to database
            insert mps;
        } catch (DmlException e) {
            // Do nothing
        }
    }
}