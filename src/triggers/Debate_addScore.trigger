trigger Debate_addScore on Debate__c (after insert) {
    for (Debate__c d : Trigger.new) {
    	try{
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