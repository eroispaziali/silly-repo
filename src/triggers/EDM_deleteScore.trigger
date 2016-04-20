trigger EDM_deleteScore on EDM__c (after delete) {
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
}