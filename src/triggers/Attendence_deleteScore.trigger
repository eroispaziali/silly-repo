trigger Attendence_deleteScore on Attendence__c (after delete) {
    for (Attendence__c a : Trigger.old) {
    	// Look up parent Campaign Event's related campaign
       Campaign_Event__c ce = [select Name, Campaign__c from Campaign_Event__c where id = :a.Campaign_Event__c];
        	
        // get the score object's name
        String activity = 'Attended Event: ' + ce.Name;
        
        try {
        	// look up the object
        	MP_Score_per_Object__c score = [select id from MP_Score_per_Object__c
                                        	where Activity__c = :activity limit 1];
                                                                
        	// insert score to database
            delete score;
        } catch (Exception e) {
            // Do nothing
        }
    }
}