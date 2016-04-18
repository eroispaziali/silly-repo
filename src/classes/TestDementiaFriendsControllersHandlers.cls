@isTest
private class TestDementiaFriendsControllersHandlers {
/*
Mike Tinson 24 Jan 2014

After creating trigger handler classes for DF_Contact, DF_Event and DF_EventAttendee.
Need a test class

*/
static testMethod void TestDementiaFriendsHandlers ()
{
   DF_Contact__c dfcon = new DF_Contact__c(Name='Test dfcontact',First_Name__c='Test',Last_Name__c='dfcontact',Status__c='Prospective',Email__c='test@dfcon.com',
   RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id,
                                            Contact_Number__c='12345678',Eligible__c=FALSE,Contacted__c=FALSE,
                                            Attended__c=FALSE,Note__c='Test Notes');
    insert dfcon;
    DF_Event__c dfeve = new DF_Event__c(Name='dfevent test',
       RecordTypeId=[Select Id from RecordType where SObjectType='DF_Event__c' and Name Like 'Champion Training Course'].Id);
    insert dfeve;
    DF_EventAttendee__c dfeveattnd = new DF_EventAttendee__c(DF_Contact__c=dfcon.Id,DF_Event__c=dfeve.Id);
    insert dfeveattnd;
    ApexPages.currentPage().getParameters().put('id',dfeve.Id);
    DfEventAttendeeController dfevAt = new DfEventAttendeeController(new ApexPages.Standardcontroller(dfeve));  
    dfevAt.getlstdfcontacts();
    dfevAt.save();       
    update dfeveattnd;
    update dfeve;
    update dfcon;
    delete dfeveattnd;
    delete dfeve;
    delete dfcon;
}
static testMethod void TestDementiaFriendsHandlers2 ()
{
   // insert and update multiple rows
   
   DF_Contact__c dfcon = new DF_Contact__c(Name='Test dfcontact',First_Name__c='Test',Last_Name__c='dfcontact',Status__c='Prospective',Email__c='test@dfcon.com',
   RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id,
                                            Contact_Number__c='12345678',Eligible__c=FALSE,Contacted__c=FALSE,
                                            Attended__c=FALSE,Note__c='Test Notes');
   DF_Contact__c dfcon2 = new DF_Contact__c(Name='Test dfcontact2',First_Name__c='Test',Last_Name__c='dfcontact2',Status__c='Prospective',Email__c='test@dfcon.com',
   RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id,
                                            Contact_Number__c='12345678',Eligible__c=FALSE,Contacted__c=FALSE,
                                            Attended__c=FALSE,Note__c='Test Notes');

    List <DF_Contact__c> lstDFC = New List<DF_Contact__c>();
    lstDFC.add(dfcon);
    lstDFC.add(dfcon2);
    
    insert lstDFC;
    update lstDFC;
    
    DF_Event__c dfeve = new DF_Event__c(Name='dfevent test',
       RecordTypeId=[Select Id from RecordType where SObjectType='DF_Event__c' and Name Like 'Champion Training Course'].Id);
    DF_Event__c dfeve2 = new DF_Event__c(Name='dfevent test2',
       RecordTypeId=[Select Id from RecordType where SObjectType='DF_Event__c' and Name Like 'Champion Training Course'].Id);


    List<DF_Event__c> lstDFE = new List<DF_Event__c>();
    lstDFE.add(dfeve);
    lstDFE.add(dfeve2);
    insert lstDFE;
    update lstDFE;
    DF_EventAttendee__c dfeveattnd = new DF_EventAttendee__c(DF_Contact__c=dfcon.Id,DF_Event__c=dfeve.Id);
    DF_EventAttendee__c dfeveattnd2 = new DF_EventAttendee__c(DF_Contact__c=dfcon.Id,DF_Event__c=dfeve.Id);
    List<DF_EventAttendee__c> lstDFEA = New List<DF_EventAttendee__c>();
    lstDFEA.add(dfeveattnd);
    lstDFEA.add(dfeveattnd2);
    insert lstDFEA;
    update lstDFEA;

    /*
    now deletes
    */
    delete lstDFEA;
    delete lstDFE;
    delete lstDFC;
}


}