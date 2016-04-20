trigger CEAttendee_Insert on Contact_Event_Contact_Connector__c (after insert) {
/*
    for (Contact_Event_Contact_Connector__c cc : Trigger.New) {
        // Get the contact linked to this event
        Contact c = [select id, status__c from Contact where id = :cc.Contact__c limit 1];
        
        // Change contact's status if they are a new referral
        if (c.status__c == 'New referral')
            c.status__c = 'Ongoing support';
            
        update c;
    }
*/
}