@isTest
private class ContactWizardControllerTest2 {
/*
Test new controllers for Wizards developed for People Wizards developed for changes
431 - Wizard for deceased Contacts
426 - Wizard for Anonymise Person

20140114 test needs changing to add service id to create service usage.
*/
static testMethod void ContactWizardControllerTest(){
 //Initialise
    Contact recCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
    RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
    insert recCon;        
    Contact c2 = new Contact(FirstName='two', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
    RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Carer of Person with Dementia'].id);    

    Id personalRelRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='SFDC_Contact_Connector__c' AND Name ='Personal'].id;
    SFDC_Contact_Connector__c rRel = new SFDC_Contact_Connector__c(RecordTypeId=personalRelRT 
                                            , Contact__c=recCon.id, Type__c='Spouse of'
                                            ,Related_Contact__c=c2.id);
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
    insert serv; 

    //now add service usage
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    


   //create page and create controller with a reference to the StandardController    
    PageReference pageRef = Page.ContactWizard;
    test.setCurrentPage(pageRef);
    pageRef.getParameters().put('id', recCon.id); 

    ApexPages.StandardController stdCon = new ApexPages.StandardController(recCon);

    ContactWizardController cw = new ContactWizardController(stdCon);    
    
    ApexPages.currentPage().getParameters().put('id', recCon.id); 

  
    cw.getContactDetails();
    cw.btnDied();
    cw.inputContact.Deceased_Date__c = System.today().addYears(1);
    cw.btnDied();
    
    cw.inputContact.Deceased_Date__c = System.today().addYears(-1);
    insert recSU;
    cw.getServiceUsages(); 
    
    cw.btnDied();
    
     
     }
static testMethod void ContactWizardControllerTest2(){    
 //Initialise
    Contact recCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
    RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
    insert recCon;        
    Contact c2 = new Contact(FirstName='two', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
    RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Carer of Person with Dementia'].id);    

    Id personalRelRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='SFDC_Contact_Connector__c' AND Name ='Personal'].id;
    SFDC_Contact_Connector__c rRel = new SFDC_Contact_Connector__c(RecordTypeId=personalRelRT 
                                            , Contact__c=recCon.id, Type__c='Spouse of'
                                            ,Related_Contact__c=c2.id);

   //create page and create controller with a reference to the StandardController    
    PageReference pageRef = Page.ContactWizard;
    test.setCurrentPage(pageRef);
    pageRef.getParameters().put('id', recCon.id); 

    ApexPages.StandardController stdCon = new ApexPages.StandardController(recCon);

    ContactWizardController cw = new ContactWizardController(stdCon);    
    
    ApexPages.currentPage().getParameters().put('id', recCon.id); 


    cw.checkIfCanAnon();
    cw.AnonymisePerson();
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
    insert serv; 

    //now add service usage
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    
    insert recSU;
    cw.checkIfCanAnon();

    
    }
    
static testMethod void ContactWizardControllerTest3(){    
 //Initialise
    Contact recCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
    RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
    insert recCon;        
    Contact c2 = new Contact(FirstName='two', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
    RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Carer of Person with Dementia'].id);    

    Id personalRelRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='SFDC_Contact_Connector__c' AND Name ='Personal'].id;
    SFDC_Contact_Connector__c rRel = new SFDC_Contact_Connector__c(RecordTypeId=personalRelRT 
                                            , Contact__c=recCon.id, Type__c='Spouse of'
                                            ,Related_Contact__c=c2.id);

    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
    insert serv;    
    //now add service usage
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy' , RecordTypeId=[Select id from RecordType where SobjectType='Service_usage__c' and DeveloperName='Advocacy'].id);    
    insert recSU;
    Service_Usage__c recSU2 = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=c2.id,Service_Type__c='Advocacy',     RecordTypeId=[Select id from RecordType where SobjectType='Service_usage__c' and DeveloperName='Advocacy'].id);    
    insert recSU2;

    //create page and create controller with a reference to the StandardController    
    PageReference pageRef = Page.ContactWizard;
    test.setCurrentPage(pageRef);
    pageRef.getParameters().put('id', recCon.id); 

    ApexPages.StandardController stdCon = new ApexPages.StandardController(recCon);

    ContactWizardController cw = new ContactWizardController(stdCon);    
    
    ApexPages.currentPage().getParameters().put('id', recCon.id); 

    cw.getServiceUsages(); 

    //create task and request it is sent
    cw.tsk.ActivityDate = System.today();
    cw.tsk.Subject = 'Test 3';
    cw.tsk.Description = 'Test 3';
    //cw.tsk.Event_Status__c = tsk.Event_Status__c;
    cw.tsk.Format__c = 'Telephone';
    cw.tsk.In_Out__c = 'In coming';
    cw.tsk.Status = 'In progress';
    cw.tsk.Related_Outcomes__c = null;
    cw.tsk.Primary_Service_User_Involved__c = false;
    cw.tsk.Staff_Time_Minutes__c = 1;
    cw.tsk.Volunteer_Time_Minutes__c=0;
    cw.tsk.Completion_Date_Task__c=null;
    cw.tsk.Travel_Time_Minutes__c=null;
    cw.tsk.Information_Provided__c=null;   
    
    //select related service usage
    for (ContactWizardController.RelatedServiceUsageClass rec : cw.lstRelatedSU) {
        rec.selected = true;
    }
     
    cw.btnAddLogAnAction();
    
    cw.tsk.Status = 'Completed';
    cw.tsk.Staff_Time_Minutes__c = null;
    cw.btnAddLogAnAction();
    
    }   
}