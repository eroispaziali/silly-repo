/*
 * Lookup record types for related contacts and write to relationship record 
 */
trigger LookupRelationshipRecordTypes on SFDC_Contact_Connector__c (before insert, before update) {
    Contact contact;
    string r;
    
    for (SFDC_Contact_Connector__c relationship : Trigger.new) {
        try {
            // Lookup record type of main contact
            contact = [select Id, RecordTypeId from Contact where Id = :relationship.Contact__c];
            
            r = [select Name from RecordType
                        where Id = :contact.RecordTypeId].Name;
            relationship.Contact_Record_Type__c = r;
            
        } catch (Exception e) {
            /* Do nothing */
            //relationship.addError('Recordtypeid=' + recordType.Id + ' name=' + recordType.Name);
        }
        
        try {
            // Lookup record type of related contact
            contact = [select Id, RecordTypeId, AccountId from Contact where Id = :relationship.Related_Contact__c];
            
            r = [select Name from RecordType
                 where Id = :contact.RecordTypeId].Name;
            relationship.Related_Record_Type__c = r;
            //change 238 - update organisation
            if (r=='Professional / Stakeholder') {
                relationship.Related_Organization__c = contact.accountid;
            }
        } catch (Exception e) {
            /* Do nothing */ 
            //relationship.addError('Recordtypeid=' + recordType.Id + ' name=' + recordType.Name);
        }
    }
}