trigger EDM_updateScore on EDM__c (after update) {
    // delete existing score
    for (EDM__c edm : Trigger.old) {
    	try {
        	// get the score object's name
        	String activity = 'Authored EDM: ' + edm.Name;
        
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
    for (EDM__c edm : Trigger.new) {
    	try {
        	// look up score for writing an EDM
        	MP_Scores__c score = [select Score__c from MP_Scores__c where Name = 'EDM Author' limit 1];
        
        	// create score object
        	MP_Score_per_Object__c mps = new MP_Score_per_Object__c(MP__c = edm.Author__c,
            	                                                    Activity__c = 'Authored EDM: ' + edm.Name,
                	                                                Score__c = score.Score__c,
                    	                                            Campaign__c = edm.Campaign__c);
                                                                
        	// insert score to database
            insert mps;
        } catch (DmlException e) {
        	// Do nothing
        }
    }
}