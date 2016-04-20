public class addEDMSignatories extends addContacts {
    private EDM__c edm;
    
    // Visualforce extension constructor
    public addEDMSignatories(ApexPages.StandardController controller) {
        edm = (EDM__c)controller.getRecord();
        recordTypeList.add('012700000009SAV'); // MP record type
    }
    
    // ----------------------------------------------------------------------
    // Save Button:
    // - Build a list of new edm Attendence records relating to the edm
    // - Upsert and report any errors
    // - Redirect to the edm
    // ----------------------------------------------------------------------
    public override pageReference doSave() {
        
        // Build a list of new attendence objects to insert
        List<MP_EDM_Association__c> attendences = new List<MP_EDM_Association__c>();
        MP_EDM_Association__c a;
        for (transferContactSearchResults c : searchResults) {
            if (c.selected) {
                // Create a new attendence record for each selected contact
                a = new MP_EDM_Association__c();
                a.Contact__c = c.contact.ID;
                a.EDM__c = edm.Id;
                attendences.add(a);
            }
        }
        if (DebugMode) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selected Count: ' + attendences.size()));


        // Process Errors and Count the Number of Records created
        Integer transferCount = 0;
        List<database.Upsertresult> srs = database.upsert(attendences);
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
        PageReference page = new PageReference('/' + edm.id);
        page.setRedirect(true);
        return page;
    }
    
    // Send user back to edm
    public override PageReference cancel() {
        PageReference page = new PageReference('/' + edm.id);
        page.setRedirect(true);
        return page;
    }
}