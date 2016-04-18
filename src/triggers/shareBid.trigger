trigger shareBid on Bid__c (after insert, after update) {
	// Declare variables for sharing bids
	Bid__Share bidShare;
	
	// Create a new list of sharing objects for bid
	List<Bid__Share> bidShares = new List<Bid__Share>();
	
	for (Bid__c b : Trigger.new) {
		// Instantiate the sharing objects
		bidShare = new Bid__Share();
		
		// Set the ID of record being shared
		bidShare.ParentId = b.Id;
		
		// Set the access level
		bidShare.AccessLevel = 'edit';
		
		// Set the Apex sharing reason
		bidShare.RowCause = Schema.Bid__Share.RowCause.BDM__c;
		
		// Link sharing rule to Business Development Manager
		bidShare.UserOrGroupId = b.BDM__c;
		
		// Add object to list for insert
		bidShares.add(bidShare);
	}
	
	// Insert sharing records and capture save result
    // The false parameter allows for partial processing if multiple records are passed
    // into the operation
    Database.SaveResult[] lsr = Database.insert(bidShares, false);
    
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
                trigger.newMap.get(bidShares[i].ParentId).
                  addError('Unable to grant sharing access due to following exception: '
                          + err.getMessage());
            }
        }i++;
}
    }