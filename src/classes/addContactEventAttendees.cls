public class addContactEventAttendees extends addContacts {
    public Contact_Event__c contactEvent;
    
    // Visualforce extension constructor
    public addContactEventAttendees(ApexPages.StandardController controller) {
        contactEvent = (Contact_Event__c)controller.getRecord();
        
        recordTypeList.add('012700000009b4B'); // Person with dementia
        recordTypeList.add('012700000009b49'); // Carer / family member / friend
        recordTypeList.add('012700000009b4A'); // Health/Social Care Professional record type
    }
        
    // ----------------------------------------------------------------------
    // Save Button:
    // - Build a list of new Attendence records relating to the contact Event
    // - Upsert and report any errors
    // - Redirect to the contact Event
    // ----------------------------------------------------------------------
    public override pageReference doSave() {
        
        // Build a list of new attendence objects to insert
        List<Contact_Event_Contact_Connector__c> attendences = new List<Contact_Event_Contact_Connector__c>();
        Contact_Event_Contact_Connector__c a;
        for (transferContactSearchResults c : searchResults) {
            if (c.selected) {
                // Create a new attendence record for each selected contact
                a = new Contact_Event_Contact_Connector__c();
                a.Contact__c = c.contact.ID;
                a.Contact_Event__c = contactEvent.Id;
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
        
        // Send the user to the detail page for the contact event
        PageReference page = new PageReference('/' + contactEvent.id);
        page.setRedirect(true);
        return page;
    }
    
    // Send user back to contact event
    public override PageReference cancel() {
        PageReference page = new PageReference('/' + contactEvent.id);
        page.setRedirect(true);
        return page;
    }
}