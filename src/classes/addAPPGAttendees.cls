public with sharing class addAPPGAttendees extends addContacts {

    // The APPG meeting MPs will be attending
    public APPG_Meeting__c appg;
    
    // Attendee's status (invited, attending, declined etc)
    //public string attendeeStatus;
    
    // Visualforce extension constructor
    public addAPPGAttendees(ApexPages.StandardController controller) {
        appg = (APPG_Meeting__c)controller.getRecord();
        recordTypeList.add('012700000009SAV'); // MP record type
        recordTypeList.add('012700000009WHH'); // Stakeholder
    }
    
    // ----------------------------------------------------------------------
    // Save Button:
    // - Build a list of new Attendence records relating to the Campaign Event
    // - Upsert and report any errors
    // - Redirect to the Campaign Event
    // ----------------------------------------------------------------------
    public override pageReference doSave() {
        
        // Build a list of new attendence objects to insert
        List<APPG_Meeting_Attendee__c> attendences = new List<APPG_Meeting_Attendee__c>();
        APPG_Meeting_Attendee__c a;
        for (transferContactSearchResults c : searchResults) {
            if (c.selected) {
                // Create a new attendence record for each selected contact
                a = new APPG_Meeting_Attendee__c();
                a.Contact__c = c.contact.ID;
                a.APPG_Meeting__c = appg.Id;
                //a.Status__c = attendeeStatus;
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
        PageReference page = new PageReference('/' + appg.id);
        page.setRedirect(true);
        return page;
    }
    
    // Send user back to campaign event
    public override PageReference cancel() {
        PageReference page = new PageReference('/' + appg.id);
        page.setRedirect(true);
        return page;
    }
}