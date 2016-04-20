trigger APPG_updateScore on APPG_Meeting_Attendee__c (after update) {
	// DELETE
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
    
	// INSERT
    for (APPG_Meeting_Attendee__c a : Trigger.new) {
        try {
        	// look up score for attending a campaign event
        	MP_Scores__c score = [select Score__c from MP_Scores__c where Name = 'APPG Attendee' limit 1];
        
        	// Look up parent Campaign Event's related campaign
        	APPG_Meeting__c ce = [select Name, Campaign__c from APPG_Meeting__c where id = :a.APPG_Meeting__c]; 
                
        	// create score object
        	MP_Score_per_Object__c mps = new MP_Score_per_Object__c(MP__c = a.Contact__c,
                                             	Activity__c = 'Attended APPG Meeting: ' + ce.Name,
                                                Score__c = score.Score__c,
                                                Campaign__c = ce.Campaign__c);
                                                                
        	// insert score to database
            insert mps;
        } catch (DmlException e) {
            // Do nothing
        }
    }
}