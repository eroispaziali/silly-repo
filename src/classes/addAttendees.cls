public class addAttendees extends addContacts {

    // The campaign event MPs will be attending
    public Campaign_Event__c campaignEvent;
    
    // Attendee's status (invited, attending, declined etc)
    public string attendeeStatus;
    
    // Visualforce extension constructor
    public addAttendees(ApexPages.StandardController controller) {
        campaignEvent = (Campaign_Event__c)controller.getRecord();
        recordTypeList.add('012700000009SAV'); // MP record type
        recordTypeList.add('012700000009WHH'); // Stakeholder
    }
    
    // Get/Set methods for the attendee status
    public string getAttendeeStatus() { return attendeeStatus; }
    public void setAttendeeStatus(string status) { attendeeStatus = status; }
    
    // Create a SelectOption list of all values in the attendence status picklist
    public List<SelectOption> getAttendenceStatuses() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('', '--- select an invite status ---'));
        Schema.DescribeFieldResult fieldResult = Attendence__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple) {
            options.add(new SelectOption(p.getValue(), p.getValue()));
        }        
        return options;
    }
    
    // ----------------------------------------------------------------------
    // Save Button:
    // - Build a list of new Attendence records relating to the Campaign Event
    // - Upsert and report any errors
    // - Redirect to the Campaign Event
    // ----------------------------------------------------------------------
    public override pageReference doSave() {
        
        // Build a list of new attendence objects to insert
        List<Attendence__c> attendences = new List<Attendence__c>();
        Attendence__c a;
        for (transferContactSearchResults c : searchResults) {
            if (c.selected) {
                // Create a new attendence record for each selected contact
                a = new Attendence__c();
                a.Contact__c = c.contact.ID;
                a.Campaign_Event__c = campaignEvent.Id;
                a.Status__c = attendeeStatus;
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
        PageReference page = new PageReference('/' + campaignevent.id);
        page.setRedirect(true);
        return page;
    }
    
    // Send user back to campaign event
    public override PageReference cancel() {
        PageReference page = new PageReference('/' + campaignevent.id);
        page.setRedirect(true);
        return page;
    }
}