trigger deleteEvent on Contact_Event__c (after delete) {
    for (Contact_Event__c ce : Trigger.Old) {
        Double duration_mins = ce.Duration__c;
        if (duration_mins == null)
            duration_mins = 0;

        try {
            // Lookup Event based on pre-update Contact Event values
            Event e = [select Id from Event
                       where Subject = :ce.Name
                       and   ActivityDateTime = :ce.Contact_Date_Time__c
                       and   StartDateTime = :ce.Contact_Date_Time__c
                       and   DurationInMinutes = :duration_mins.intValue()
                       and   OwnerId = :ce.OwnerId
                       and   Type = :ce.Event_Type__c
                       limit 1];
                       
            delete e;
            
        } catch (Exception ex) {
        }
    }
}