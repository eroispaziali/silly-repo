public class addDebateAttendees extends addContacts {
    private Debate__c debate;
    
    // Visualforce extension constructor
    public addDebateAttendees(ApexPages.StandardController controller) {
        debate = (Debate__c)controller.getRecord();
        recordTypeList.add('012700000009SAV'); // MP record type
    }
    
    // ----------------------------------------------------------------------
    // Save Button:
    // - Build a list of new Debate Attendence records relating to the Debate
    // - Upsert and report any errors
    // - Redirect to the Debate
    // ----------------------------------------------------------------------
    public override pageReference doSave() {
        
        // Build a list of new attendence objects to insert
        List<MP_Debate_Association__c> connector = new List<MP_Debate_Association__c>();
        MP_Debate_Association__c a;
        for (transferContactSearchResults c : searchResults) {
            if (c.selected) {
                // Create a new attendence record for each selected contact
                a = new MP_Debate_Association__c();
                a.MP__c = c.contact.ID;
                a.Debate__c = debate.Id;
                connector.add(a);
            }
        }
        if (DebugMode) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selected Count: ' + connector.size()));


        // Process Errors and Count the Number of Records created
        Integer transferCount = 0;
        List<database.Upsertresult> srs = database.upsert(connector);
        for (database.Upsertresult sr : srs) {
            if (!sr.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL, sr.getId() + '/' + sr.getErrors()[0].getMessage() ));
            } else {
                transferCount++; 
            }
        }
    
        // Display the Transfer Count
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, transferCount + ' Records Successfully Transfered' ));
        
        // Set the flag that this just finished
        transferJustCompleted = true;       
        
        // Send the user to the detail page for the campaign event
        PageReference page = new PageReference('/' + debate.id);
        page.setRedirect(true);
        return page;
    }
    
    // Send user back to debate
    public override PageReference cancel() {
        PageReference page = new PageReference('/' + debate.id);
        page.setRedirect(true);
        return page;
    }
}