trigger APPG_deleteScore on APPG_Meeting_Attendee__c (after delete) {
    for (APPG_Meeting_Attendee__c a : Trigger.old) {
    	// Look up parent Campaign Event's related campaign
       APPG_Meeting__c ce = [select Name, Campaign__c from APPG_Meeting__c where id = :a.APPG_Meeting__c];
        	
        // get the score object's name
        String activity = 'Attended APPG Meeting: ' + ce.Name;
        
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