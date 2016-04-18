trigger EDMSig_updateScore on MP_EDM_Association__c (after update) {
    // delete existing score
    for (MP_EDM_Association__c edma : Trigger.old) {
    	try {
        	// look up this association's EDM
        	EDM__c edm = [select Name from EDM__c where id = :edma.EDM__C];
        
        	// get the score object's name
        	String activity = 'Signed EDM: ' + edm.Name;
        
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
    for (MP_EDM_Association__c edma : Trigger.new) {
    	try {
        	// look up score for signing an EDM
        	MP_Scores__c score = [select Score__c from MP_Scores__c where Name = 'EDM Signatory' limit 1];
        
        	// look up this association's EDM
        	EDM__c edm = [select Name, Author__c, Campaign__c from EDM__c where id = :edma.EDM__C];
        
        	// create score object
        	MP_Score_per_Object__c mps = new MP_Score_per_Object__c(MP__c = edma.Contact__c,
            	                                                    Activity__c = 'Signed EDM: ' + edm.Name,
                	                                                Score__c = score.Score__c,
                    	                                            Campaign__c = edm.Campaign__c);
                                                                
        	// insert score to database
            insert mps;
        } catch (DmlException e) {
            // Do nothing
        }
    }
}