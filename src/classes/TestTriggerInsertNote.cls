@isTest
private class TestTriggerInsertNote {

    static testMethod void myUnitTest() {
        RecordType rt = [Select id, Name from RecordType where DeveloperName = 'Person_with_dementia' and sObjectType='Contact'];
        Contact cnew = new Contact(Birthdate=System.today(),LastName = 'Test Contact1', FirstName = 'First', RecordTypeId = rt.Id);
        insert cnew;
        Note theNote = new Note();
        Attachment theAttachment = new Attachment();
        theAttachment.ParentId = cnew.Id;
        theNote.ParentId = cnew.Id;
        try
        {
            insert theNote;
        }
        catch(System.DMLException e)
        {
         System.assert(e.getMessage().contains('You cannot insert notes to CRS Contracts'));
        }
        try
        {
            insert theAttachment;
        }
        catch(System.DMLException e)
        {
         System.assert(e.getMessage().contains('You cannot insert Attachments to CRS Contacts'));
        }
    }
}