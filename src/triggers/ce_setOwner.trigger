trigger ce_setOwner on Contact_Event__c (before insert, before update) {
    for (Contact_Event__c ce : Trigger.new) {
        try {
            // If 'assigned to' has been set, make owner equal assigned to user
            if (ce.User__c == null) {
                // Set 'assigned to' equal to the owner
                ce.User__c = ce.OwnerID;
            } else {
                // Set the owner to be the 'assigned to' user
                ce.OwnerID = ce.User__c;
            }
        } catch (DMLException e) {
        }
    }
}