trigger Debate_updateScore on Debate__c (after update) {
    // delete existing score
    for (Debate__c d : Trigger.old) {
        // get the score object's name
        String activity = 'Organised Debate: ' + d.Name;
        
        try{
        	// look up the object
        	MP_Score_per_Object__c score = [select id from MP_Score_per_Object__c
            	                            where Activity__c = :activity limit 1];
        
        	// and delete
            delete score;
        } catch (Exception e) {
        	// Do nothing
        }
    }

    // insert new score
    for (Debate__c d : Trigger.new) {
    	try {
        	// look up score for asking a PQ
        	MP_Scores__c score = [select Score__c from MP_Scores__c where Name = 'Debate Organiser' limit 1];
        
        	// create score object
        	MP_Score_per_Object__c mps = new MP_Score_per_Object__c(MP__c = d.Organiser__c,
            	                                                    Activity__c = 'Organised Debate: ' + d.Name,
                	                                                Score__c = score.Score__c,
                    	                                            Campaign__c = d.Campaign__c);
                                                                
        	// insert score to database
            insert mps;
        } catch (DmlException e) {
            // Do nothing
        }
    }
}