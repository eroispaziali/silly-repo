trigger shareProposal on Proposal__c (after insert, after update) {
	// Declare variables for sharing Proposals
	Proposal__Share ProposalShare;
	
	// Create a new list of sharing objects for Proposal
	List<Proposal__Share> ProposalShares = new List<Proposal__Share>();
	
	for (Proposal__c p : Trigger.new) {
		// Instantiate the sharing objects
		ProposalShare = new Proposal__Share();
		
		// Set the ID of record being shared
		ProposalShare.ParentId = p.Id;
		
		// Set the access level
		ProposalShare.AccessLevel = 'edit';
		
		// Set the Apex sharing reason
		ProposalShare.RowCause = Schema.Proposal__Share.RowCause.BDM__c;
		
		// Link sharing rule to Business Development Manager
		ProposalShare.UserOrGroupId = p.BDM__c;
		
		// Add object to list for insert
		ProposalShares.add(ProposalShare);
	}
	
	// Insert sharing records and capture save result
    // The false parameter allows for partial processing if multiple records are passed
    // into the operation
    Database.SaveResult[] lsr = Database.insert(ProposalShares, false);
    
    // Create counter
    Integer i=0;
    
    // Process the save results
    for(Database.SaveResult sr : lsr){
        if(!sr.isSuccess()){
            // Get the first save result error
            Database.Error err = sr.getErrors()[0];
            
            // Check if the error is related to a trivial access level
            // Access levels equal or more permissive than the object's default
            // access level are not allowed.
            // These sharing records are not required and thus an insert exception is
            // acceptable.
            if(!(err.getStatusCode() == StatusCode.FIELD_INTEGRITY_EXCEPTION  &&  
                                               err.getMessage().contains('AccessLevel'))){
                // Throw an error when the error is not related to trivial access level.
                trigger.newMap.get(ProposalShares[i].ParentId).
                  addError('Unable to grant sharing access due to following exception: '
                          + err.getMessage());
            }
        }i++;
    }
}