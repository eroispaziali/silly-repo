trigger updateEvent on Contact_Event__c (after update) {
    // Declare event object that will be used throughout trigger
    Event e;
    
    // Look up Event based on pre-update Contact Event values
    for (Contact_Event__c ce : Trigger.Old) {
        Double duration_mins = ce.Duration__c;
        if (duration_mins == null)
            duration_mins = 0;
            
        try {
            // Find related event
            e = [select Id from Event
                 where Subject = :ce.Name
                 and   ActivityDateTime = :ce.Contact_Date_Time__c
                 and   StartDateTime = :ce.Contact_Date_Time__c
                 and   DurationInMinutes = :duration_mins.intValue()
                 and   OwnerId = :ce.OwnerId
                 and   Type = :ce.Event_Type__c
                 limit 1];
                 
        } catch (Exception ex) {
            e = null;
        }
    }
    
    // Take new values and update event
    for (Contact_Event__c ce : Trigger.new) {
        Double duration_mins = ce.Duration__c;
        if (duration_mins == null)
            duration_mins = 0;

        try {
            if (e <> null) {                
                // Update event
                e.Subject = ce.Name;
                e.ActivityDateTime = ce.Contact_Date_Time__c;
                e.StartDateTime = ce.Contact_Date_Time__c;
                e.ReminderDateTime = ce.Contact_Date_Time__c.addDays(-1);
                e.IsReminderSet = true;
                e.DurationInMinutes = (duration_mins.intValue());
                e.OwnerId = ce.OwnerId;
                e.Type = ce.Event_Type__c;
                e.Description = ce.Actions_taken__c;
                e.WhatId = ce.Id;
                e.WhoId = ce.Client__c;
                
                upsert e;
            }
        } catch (Exception ex) {
        }
    }
}