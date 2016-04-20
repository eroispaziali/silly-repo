trigger addEvent on Contact_Event__c (after insert) {
    for (Contact_Event__c ce : Trigger.new) {
        try {
            // Convert Duration to minutes
            Double duration_mins = ce.Duration__c;
            if (duration_mins == null)
                duration_mins = 0;
            
            // Create new Event based on this Contact Event
            Event e = new Event(Subject = ce.Name,
                                ActivityDateTime = ce.Contact_Date_Time__c,
                                StartDateTime = ce.Contact_Date_Time__c,
                                ReminderDateTime = ce.Contact_Date_Time__c.addDays(-1),
                                IsReminderSet = true,
                                DurationInMinutes = duration_mins.intValue(),
                                Description = ce.Actions_taken__c,
                                OwnerId = ce.OwnerId,
                                Type = ce.Event_Type__c,
                                WhatId = ce.Id,
                                WhoId = ce.Client__c
                                );
                                
            // Insert new event
            insert e;

        } catch (DMLException e) {
        }
    }
}