trigger Attendence_addScore on Attendence__c (after insert) {
    for (Attendence__c a : Trigger.new) {
    	// Only add score if the MP 'attended' the event
      	if (a.Status__c == 'Attended') {
	        try {
	        	// look up score for attending a campaign event
	        	MP_Scores__c score = [select Score__c from MP_Scores__c where Name = 'Event Attendee' limit 1];
	        
	        	// Look up parent Campaign Event's related campaign
	        	Campaign_Event__c ce = [select Name, Campaign__c from Campaign_Event__c where id = :a.Campaign_Event__c]; 
	                
	        	// create score object
	        	MP_Score_per_Object__c mps = new MP_Score_per_Object__c(MP__c = a.Contact__c,
	                                             	Activity__c = 'Attended Event: ' + ce.Name,
	                                                Score__c = score.Score__c,
	                                                Campaign__c = ce.Campaign__c);
	                                                                
	        	// insert score to database
	            insert mps;
	        } catch (DmlException e) {
	            // Do nothing
	        }
      	}
    }
}