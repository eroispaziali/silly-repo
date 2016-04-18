/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test method for Merge Contacts, allowing two contacts merged.
 *  Author  : Richard Cole
 *  Date    : 2014-08-22
 *  Version : UT1.1 
 *  Project : n/a
 *
 *  Description: Script to test the Merge Contact Method   
 *
 *  Modification History
 *
 *  Date         Who            Description 
 * 
 * 2014-08-22    Richard Cole   First iteration
   2015- 1-13    Gary Grant 	Support for Demographics and UI Participants 
 *                            
*******************************************************************************************/
@isTest
private class Test_MergeContacts {

    public testMethod static void testController(){

    Id servRT = getID('External', 'Services__c');
    Id servUseageRT = getID('Outgoing_Referral', 'Service_Usage__c');
    
    Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert con1;  
    
    Demographic_Information__c dgData1 = new Demographic_Information__c(Person__c = con1.id);
    insert dgData1; 
        
    Contact con2 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test2',MailingPostalCode ='ABC1234', Birthdate =Date.Today().addyears(-1),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Carer%'].id);
    insert con2;   
    
    Demographic_Information__c dgData2 = new Demographic_Information__c(Person__c = con2.id);
    insert dgData2;     
    
    Account accRec = new Account(Name='Essex Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name ='Internal Organisation'].id);  
    insert accRec;  
                        
    Services__c serv1 = new Services__c(Locality__c=accRec.id,RecordTypeId=servRT, Service_Type__c='Befriending',
        Name='testControllerService', National_Service__c=false);
    insert serv1;   
              
    Service_Usage__c servUsg1 = new Service_Usage__c(Service_Field__c=serv1.id,Primary_Service_User__c=con2.id,    
        Service_Type__c='Befriending', RecordTypeId= servUseageRT);        
    insert servUsg1;
  
    //Create instance of the class to test and initialise the list 
    mergeContacts conCls= new mergeContacts(); 
    
    conCls.AutoRunMergeContacts();
    ApexPages.currentPage().getParameters().put('masterid', con1.id); 
    
    conCls.AutoRunMergeContacts();
    ApexPages.currentPage().getParameters().put('childid', con2.id);

    /* Jan 2015 - merge Participants code */
    //UI_Participant__c p1 = UiUtils_Test.getTestParticipant(con1, true);
    UI_Participant__c p2 = UiUtils_Test.getTestParticipant(con2, true);

    conCls.AutoRunMergeContacts();
    conCls.mergePerson();
    conCls.requestMergePerson();
    } 

    public testMethod static void testController2(){

    Id servRT = getID('External', 'Services__c');
    Id servUseageRT = getID('Outgoing_Referral', 'Service_Usage__c');
    
    Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert con1;   
        
    Contact con2 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Carer%'].id);
    insert con2;       
    
    Demographic_Information__c dgData2 = new Demographic_Information__c(Person__c = con2.id);
    insert dgData2;     
    
    Account accRec = new Account(Name='Essex Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name ='Internal Organisation'].id);  
    insert accRec;  
                        
    Services__c serv1 = new Services__c(Locality__c=accRec.id,RecordTypeId=servRT, Service_Type__c='Befriending',
        Name='testControllerService', National_Service__c=false);
    insert serv1;   
              
    Service_Usage__c servUsg1 = new Service_Usage__c(Service_Field__c=serv1.id,Primary_Service_User__c=con2.id,    
        Service_Type__c='Befriending', RecordTypeId= servUseageRT);        
    insert servUsg1;
  
    //Create instance of the class to test and initialise the list 
    mergeContacts conCls= new mergeContacts(); 
    
    conCls.AutoRunMergeContacts();
    ApexPages.currentPage().getParameters().put('masterid', con1.id); 
    
    conCls.AutoRunMergeContacts();
    ApexPages.currentPage().getParameters().put('childid', con2.id);

    /* Jan 2015 - merge Participants code */
    UI_Participant__c p1 = UiUtils_Test.getTestParticipant(con1, true);
    UI_Participant__c p2 = UiUtils_Test.getTestParticipant(con2, true);

    conCls.AutoRunMergeContacts();
    conCls.mergePerson();
    conCls.requestMergePerson();
    } 

    
    private static ID getID(string developerName, string objectType)
    {
         return [select Id from RecordType where DeveloperName = :developerName and SObjectType= :objectType].id;    
    }
}