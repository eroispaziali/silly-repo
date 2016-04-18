trigger EDMSig_addScore on MP_EDM_Association__c (after insert) {
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