public with sharing class listContacts {
    public ApexPages.StandardController stdController;
    public List<Contact> lstMatchingContacts {get;set;}
    private Contact person;
    private String lastName;
    private String firstName;
    private String postalcode;
    private String recordTypeName;
    private Id organisationId;
    private Contact c1;
    public Boolean canMerge {get;set;}
    public Boolean showBirthDate {get;set;}
    
// Standard controller constructor.
    public listContacts (ApexPages.StandardController pController) {
        stdController = pController;
        person =  [select id, LastName, FirstName, MailingPostalCode, BirthDate, Record_Type_Name__c, AccountId from Contact where id = :ApexPages.currentPage().getParameters().get('id')];
        system.debug('@@@@@@@@@@@@@@@'+person.id);
        lastName = person.LastName;
        firstName = person.FirstName;
        postalcode = person.MailingPostalCode;
        recordtypeName = person.Record_Type_Name__c;
        organisationId = person.AccountId;
        system.debug('@@@@@@@@@@@@@@@lastname  '+lastname);
        system.debug('@@@@@@@@@@@@@@@firstname '+firstname);
        system.debug('@@@@@@@@@@@@@@@postalcode'+postalcode );
        system.debug('@@@@@@@@@@@@@@@Birthdate '+Person.BirthDate );
        canMerge = Contact.sObjectType.getDescribe().isDeletable();
    }

public PageReference AutoRunListContacts(){ 
    lstMatchingContacts = new List<Contact>();
    Set<Id> contactIds = new Set<Id>();
    DeDuper objDeDuper = new DeDuper();
    if ((lastName =='*****') && (firstName=='*****')){ 
        return null;}
    else {
         if ((recordTypeName == 'Professional')
             ||(recordTypeName=='MP')
             ||(recordTypeName=='Former_MP') 
             ||(recordTypeName=='Peer')
             ||(recordTypeName=='Lord')
             ||(recordTypeName=='Peer')
             ||(recordTypeName=='Member_of_NI_Legislative_Assembly')
             ||(recordTypeName=='Member_of_Welsh_Assembly')
             ||(recordTypeName=='Volunteer')
             ||(recordTypeName=='Collector')
             ){
             contactIds = objDeDuper.SearchProfessionals(lastName, organisationId );
             lstMatchingContacts  = [SELECT id, Name, Email, Record_Type_Name__c, LastName, FirstName,  RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Date_of_Birth_Estimated__c,  Primary_care_trust__c, Local_authority__c, Constituency__c, Salutation 
                                     from Contact where id =:contactIds and id != :person.id ];
             showBirthDate=false;}
         else {
                lstMatchingContacts = objDeDuper.SearchNonProfessional(person, lastName, firstName, person.birthdate, PostalCode);
                showBirthDate =true;
             }
         }
    return null;
    }
    
//Test script for code coverage.
public testMethod static void testController()
{
    Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert con1;
    Account accRec = new Account(Name='External Test Org1',BillingPostalCode='SW1A 2AA',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id);
    insert accRec;
    Contact con2 = new Contact(Salutation='Mr',FirstName='Abc',LastName='ProTest1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        AccountId = accRec.id,
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Professional%'].id);
    insert con2;
    ApexPages.currentPage().getParameters().put('Id', con1.id);        
    listContacts conCls= new listContacts (new ApexPages.StandardController(con1));
    conCls.AutoRunListContacts();
    //now test professionals
    ApexPages.currentPage().getParameters().put('Id', con2.id);
    listContacts conCls2= new listContacts (new ApexPages.StandardController(con2));
    conCls2.AutoRunListContacts();
 
}    
}