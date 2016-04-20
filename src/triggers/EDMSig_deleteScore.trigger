trigger EDMSig_deleteScore on MP_EDM_Association__c (after delete) {
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
}