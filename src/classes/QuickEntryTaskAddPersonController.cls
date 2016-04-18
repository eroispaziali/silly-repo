/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : VF Page controller methods for creating task and related person, Allow to search or create contact before creating Task.
 *  Author  : Fujitsu - Nupoor Pandey
 *  Date    : 2012-02-28
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *
 *  Description: VF Page controller, allows user to search for existing/matching contacts in system. 
 *               Either they can select one from Result or force create new Contact with details provide.    
 *               And create Task record for selected Contacts and filled data.
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  2013-05-14    MT    Redevelop to remove some anoyances
 *                             
*******************************************************************************************/
public with sharing class QuickEntryTaskAddPersonController{

    public Task recTask {get;set;}
    public Id recordTypeId {get;set;}
    public Id conRecordTypeId {get;set;}
    public Contact relContact {get;set;}
    public Contact relContact2 {get;set;}
    public List<Contact> lstMatchingContacts {get;set;}
    public String selectedRecordTypeName {get;set;}
    public String selectedRelContactId {get;set;}
    public String selectedRelContactName {get;set;}
    public Contact cont;
    public Boolean ignoreAndCreate {get;set;}
    public String lastName {get;set;}
    public String selectedServiceName {get;set;}
    public AccountLink__c accountLink {get;set;}
    public List<SelectOption> lstRecordTypes{get;set;}
    public Boolean testIgnoreMessages {get;set;}


    //Constructor
    public QuickEntryTaskAddPersonController(ApexPages.StandardController stdCon){
            
        recTask = new Task(); 
        
        recTask = [select id, WhatId, Time_of_call__c, Description, Information_Provided__c, Other_Information_Provided__c,Other_Caller_type__c, 
                    Caller_type__c,Format__c,In_Out__c,Subject, Call_Outcome__c,Staff_Time_Minutes__c,Volunteer_Time_Minutes__c,WhoId 
                    from Task where id = :ApexPages.currentPage().getParameters().get('id')];
        //recTask.OwnerId = UserInfo.getUserId();
        //RecordType recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name = 'CRS Information Provision Task'];
        //RecordType recordType.id = recTask.RecordTypeId;
        //recTask.Subject = 'Information Provision';
        List<Services__c > serviceName = [select name from Services__c where id = :recTask.WhatId LIMIT 1];
        if (serviceName.size()==0){
            selectedServiceName = '';}
        else {
            selectedServiceName = serviceName[0].name;}
        
        relContact = new Contact();
        relContact2 = new Contact();
        lstMatchingContacts = new List<Contact>();
        accountLink = new AccountLink__c();
        //when the page loads, default Person record Type to the first option in the list(Carer of Person with Dementia)
        //change the query if the first option in the list is not 'Carer of Person with Dementia'
        recordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Carer of Person with Dementia'].Id;
        relContact.RecordTypeId = recordTypeId;
        selectedRecordTypeName = Contact.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        CallerTypeChanged();
        testIgnoreMessages = false;

    }
   
    public PageReference CallerTypeChanged(){
        lstRecordTypes = new List<SelectOption>();
        if(recTask.Caller_type__c==null){
            
        }else if(recTask.Caller_type__c=='Person with Dementia' || recTask.Caller_type__c=='Worry may have' || recTask.Caller_type__c=='Worried about memory'){
            lstRecordTypes = new List<SelectOption>(); 
            for(RecordTypeInfo rec: Contact.SObjectType.getDescribe().getRecordTypeInfosById().values()){
              //Check if recordtype is visible/available for current user.
              if(rec.isAvailable()){
                    if(rec.getName()=='Person with Dementia')
                  lstRecordTypes.add(new SelectOption(rec.getRecordTypeId(),rec.getName()));
              }
            }
            recordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Person with Dementia'].Id;
        }else if(recTask.Caller_type__c=='Carer'){
            lstRecordTypes = new List<SelectOption>(); 
            for(RecordTypeInfo rec: Contact.SObjectType.getDescribe().getRecordTypeInfosById().values()){
              //Check if recordtype is visible/available for current user.
              if(rec.isAvailable()){
                    if(rec.getName()=='Carer of Person with Dementia')
                  lstRecordTypes.add(new SelectOption(rec.getRecordTypeId(),rec.getName()));
              }
            }
            recordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Carer of Person with Dementia'].Id;
        }else if(recTask.Caller_type__c=='Family/Friend'){
            lstRecordTypes = new List<SelectOption>(); 
            for(RecordTypeInfo rec: Contact.SObjectType.getDescribe().getRecordTypeInfosById().values()){
              //Check if recordtype is visible/available for current user.
              if(rec.isAvailable()){
                    if(rec.getName()=='Friend or Family of Person with Dementia')
                  lstRecordTypes.add(new SelectOption(rec.getRecordTypeId(),rec.getName()));
              }
            }
            recordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Friend or Family of Person with Dementia'].Id;
        }else if(recTask.Caller_type__c=='Health Services' || recTask.Caller_type__c=='Social Services' ||
                    recTask.Caller_type__c=='Education Sector' || recTask.Caller_type__c=='Voluntary Sector' ||
                    recTask.Caller_type__c=='Student'){
            lstRecordTypes = new List<SelectOption>(); 
            for(RecordTypeInfo rec: Contact.SObjectType.getDescribe().getRecordTypeInfosById().values()){
              //Check if recordtype is visible/available for current user.
              if(rec.isAvailable()){
                    if(rec.getName()=='Professional / Stakeholder')
                  lstRecordTypes.add(new SelectOption(rec.getRecordTypeId(),rec.getName()));
              }
            }
            recordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Professional / Stakeholder'].Id;
        }
       
        relContact = new Contact(RecordTypeId=recordTypeId);
        selectedRecordTypeName = Contact.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        System.debug('11111111111111111111111111111111111 recTask.Caller_type__c: '+ recTask.Caller_type__c);
        System.debug('11111111111111111111111111111111111 recordTypeId: '+ recordTypeId );
        System.debug('11111111111111111111111111111111111 relContact: '+ relContact);
        return null;
    }
    
    
    /*
    This method handler will run validations on new task record.
    */
    public PageReference createPersonValidation(){
        //first copy address details from relContact2 to relContact - this second contact record is used to stop refreshes of the addresses on the Visual Force page which stops PCA button appearing.
        relContact.MailingCountry = relContact2.MailingCountry;
        relContact.MailingPostalCode = relContact2.MailingPostalCode;
        relContact.MailingStreet = relContact2.MailingStreet;
        relContact.MailingCity = relContact2.MailingCity;
        relContact.MailingState = relContact2.MailingState;
        relContact.Constituency_Derived__c = relContact2.Constituency_Derived__c;
        relContact.Local_authority__c = relContact2.Local_authority__c;
        relContact.Primary_care_trust__c = relContact2.Primary_care_trust__c;
        relContact.Ward__c = relContact2.Ward__c;

        //Person validations
        if(relContact.FirstName==null &&  relContact.Salutation==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Title or First Name.');
            ApexPages.addMessage(message);
            return null;
        }
        if(lastName==null || lastName==''){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Last Name.');
            ApexPages.addMessage(message);
            return null;
        }
        if(relContact.MailingPostalCode==null &&  relContact.Birthdate==null && selectedRecordTypeName!='Professional / Stakeholder'){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter either a Postcode, a Date of Birth, or both.');
            ApexPages.addMessage(message);
            return null;
        }
        if(selectedRecordTypeName=='Professional / Stakeholder' && accountLink.Account__c==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Organisation name.');
            ApexPages.addMessage(message);
            return null;
        }
        if(relContact.Birthdate>System.today()){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Date of Birth must be in the past.');
            ApexPages.addMessage(message);
            return null;
        }
        return null;
    }
    
   
    public PageReference searchPerson(){
       //run Person validation
        createPersonValidation();
        
        //if there are validation errors, display them on the screen
        if(Apexpages.getMessages().size()>0 && !testIgnoreMessages)
            return null;
            
       /**
        START : Data Scout Integration
       
        
       
        try{
            Contact c1 = new Contact(DSE__DS_Synchronize__c=true, FirstName=relContact.FirstName, LastName=lastName, MailingPostalCode =relContact.MailingPostalCode, Birthdate =relContact.Birthdate);
            if(relContact.MailingPostalCode!=null || relContact.MailingCity!=null || relContact.MailingCountry!=null || relContact.MailingState!=null || relContact.MailingStreet!=null){
                c1.MailingCity = relContact.MailingCity;
                c1.MailingCountry = relContact.MailingCountry;
                c1.MailingState = relContact.MailingState;
                c1.MailingStreet = relContact.MailingStreet;
                c1.MailingPostalCode = relContact.MailingPostalCode;
            }else if(accountLink.Account__c!=null){
                Account organisation = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                    From Account a where id = :accountLink.Account__c];
                c1.MailingCity = organisation.BillingCity;
                c1.MailingCountry = organisation.BillingCountry;
                c1.MailingState = organisation.BillingState;
                c1.MailingStreet = organisation.BillingStreet;
                c1.MailingPostalCode = organisation.BillingPostalCode;
            }
            
            // Create a Set of search sources
            Set<String> sSources =  new Set<String>{'Contact', 'Lead'};
            
            // Store the search results in a list of Beans
            //List<DSE__DS_Bean__c> beans = DSE.API_DuplicateSearch.basicSearch(c1,'AND',sSources,null); 
            List<DSE__DS_Bean__c> beans = new List<DSE__DS_Bean__c>();
            if(c1!=null)
                beans = DSE.API_DuplicateSearch.fuzzySearch(c1,sSources,null); 
            
            //get all the contact Ids from the list returned
            Set<Id> contactIds = new Set<Id>();
            for(DSE__DS_Bean__c  contactBean: beans){
                contactIds.add(contactBean.DSE__DS_Contact__c);
            }
           
           /**
            END : Data Scout Integration
            */
            
            
            /** 
            OVERRIDE DATASCOUT : 
            
            DeDuper Begin
            */
            
                
            try{
                Set<Id> contactIds = new Set<Id>();
                DeDuper objDeDuper = new DeDuper();
                Id OrganisationIs; 
                
                if(accountLink.Account__c!=null) {                                  
                    contactIds = objDeDuper.SearchProfessionals(lastName,accountLink.Account__c);   
                } else {
                    contactIds = objDeDuper.SearchNonProfessional(lastName, relContact.Birthdate, relContact.MailingPostalCode);
                }
            /** 
            OVERRIDE DATASCOUT : 
            
            DeDuper End
            */
            
            lstMatchingContacts = [Select id, Name, Email, Record_Type_Name__c, RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate from Contact where id in :contactIds];
            ignoreAndCreate = true;
            
            if(lstMatchingContacts.size()<1){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Warning,'There are no matching duplicates for the Person.');
                ApexPages.addMessage(message);
            }//if duplicates found, return tp page with duplicate list
            if(lstMatchingContacts.size()>0){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Warning,'Matching people have been found, please use one of the two buttons below the list of matching people to continue.');
                ApexPages.addMessage(message);
            }
            return null;
        }catch(Exception ex){ 
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while searching duplicates.');
            ApexPages.addMessage(message);
            return null;
        }
    }
    
    public PageReference ignoreCreatePerson(){
        //recTask.WhoId
        ignoreAndCreate = false;
        
        //run Person validation
        createPersonValidation();
        
        //if there are validation errors, display them on the screen
        if(Apexpages.getMessages().size()>0 && !testIgnoreMessages)
            return null;
        
       
        try{
            //create contact first
            relContact.LastName=lastName;
            if(relContact.MailingPostalCode!=null || relContact.MailingCity!=null || relContact.MailingCountry!=null || relContact.MailingState!=null || relContact.MailingStreet!=null){
                if(accountLink.Account__c!=null){
                        Account organisation_l = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                        From Account a where id = :accountLink.Account__c];
                        relContact.AccountId = organisation_l.Id; 
                    }
                relContact.MailingCity = relContact.MailingCity;
                relContact.MailingCountry = relContact.MailingCountry;
                relContact.MailingState = relContact.MailingState;
                relContact.MailingStreet = relContact.MailingStreet;
                relContact.MailingPostalCode = relContact.MailingPostalCode;
            }else if(accountLink.Account__c!=null){
                Account organisation = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                    From Account a where id = :accountLink.Account__c];
                relContact.MailingCity = organisation.BillingCity;
                relContact.MailingCountry = organisation.BillingCountry;
                relContact.MailingState = organisation.BillingState;
                relContact.MailingStreet = organisation.BillingStreet;
                relContact.MailingPostalCode = organisation.BillingPostalCode;  
                relContact.AccountId = organisation.Id;                 
            }
            insert relContact; 

            //relate Task and Selected Person
            //create Task 

            recTask.WhoId = relContact.Id; //Person Involved is the contact selected by User
            upsert recTask;
            
            return new Pagereference('/'+recTask.Id); //return to task details page
            
        }catch(Exception ex){ 
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while creating Person and Task.');
            ApexPages.addMessage(message);
            return null;
        }
        return null;
    }
    
    public PageReference AddSelectedPersonToTask(){
        //recTask.WhoId
        ignoreAndCreate = false;
        
        //run Person validation
        createPersonValidation();
        
    
        //if there are validation errors, display them on the screen
        if(Apexpages.getMessages().size()>0)
            return null;
        
        if(selectedRelContactId!=null){
            system.debug('#############dupes selected-selectedRelContactId:#############'+selectedRelContactId);
            try{
                //get the details of the selected dupe contact
                Contact dupeContact = [Select c.Email, c.Salutation, c.Name, c.MobilePhone, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, 
                c.MailingCity, c.LastName, c.Id, c.Gender__c, c.FirstName, c.Diagnosis__c, c.Date_of_diagnosis__c, c.Contact_Full_Name__c, c.Consent_Status__c, 
                c.Birthdate, c.Active__c, c.Record_Type_Name__c, c.RecordTypeId, c.AccountId, c.Ward__c, c.Primary_care_trust__c, c.Local_authority__c, c.Constituency__c
                From Contact c where id = :selectedRelContactId];
                
                //relate Task and Selected Person
                //create Task 

                recTask.WhoId = dupeContact.Id; //Person Involved is the contact selected by User
                upsert recTask;
                
                return new Pagereference('/'+recTask.Id); //return to task details page
            }catch(Exception ex){ 
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while creating Task using duplicate Person.');
                ApexPages.addMessage(message);
                return null;
            }
        }
        return null;
    }
  

  //
  // TEST CASE
  //
  private static testMethod void testQuickEntry() {
        Services__c service = new Services__c(Name='Test service');
        User currentUser = [Select u.Locality__c, u.Id From User u where id = :Userinfo.getUserId()];
        RecordType serviceRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Services__c' and Name = 'Internal Service'];
        
        Account acc = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where 
        SObjectType='Account' and Name like 'Internal%'].id);
        insert acc;

        Account acc2 = new Account(Name='Test External Org',RecordTypeId=[Select Id from RecordType where 
        SObjectType='Account' and Name like 'External%'].id);
        insert acc2;

        AccountLink__c accLink = new AccountLink__c(Account__c=acc2.Id);
        insert accLink;
        
        service.service_type__c='Information provision';
        service.Locality__c=acc.Id;
        insert service;
            
        Contact c1 = new Contact(Salutation='Mr',FirstName='one', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today().addYears(-1));
        insert c1;
        
        Task t1 = new Task();
        RecordType recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name = 'CRS Information Provision Task'];
        t1.RecordTypeId = recordType.id;
        t1.WhatId = service.Id;
        t1.WhoId = c1.Id; //Person Involved is the contact selected by User
        t1.Status = 'Completed';
        t1.ActivityDate = System.today();
        t1.Completion_Date_Task__c = System.today();
        t1.Format__c='Face to Face';
        t1.Staff_Time_Minutes__c=2;
        t1.Call_Outcome__c='Information provided verbally';
        t1.Time_of_call__c=System.today();
        t1.Description='gdfvbdfv';
        t1.Subject='Call';
        t1.Volunteer_Time_Minutes__c=2;
        insert t1;
        //second contact and task
        Contact c2 = new Contact(Salutation='Mr',FirstName='one', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today().addYears(-1));
        insert c2;

        Task t2 = new Task();
        //RecordType recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name = 'CRS Information Provision Task'];
        t2.RecordTypeId = recordType.id;
        t2.WhatId = service.Id;
        t2.WhoId = c2.Id; //Person Involved is the contact selected by User
        t2.Status = 'Completed';
        t2.ActivityDate = System.today();
        t2.Completion_Date_Task__c = System.today();
        t2.Format__c='Face to Face';
        t2.Staff_Time_Minutes__c=2;
        t2.Call_Outcome__c='Information provided verbally';
        t2.Time_of_call__c=System.today();
        t2.Description='gdfvbdfv';
        t2.Subject='Call';
        t2.Volunteer_Time_Minutes__c=2;
        t2.OwnerId = currentUser.id;
        t2.Caller_type__c='Person with Dementia';
        insert t2;
        
        
        
        
        // Set up the VF page
        PageReference pageRef = Page.QuickEntryTaskAddPerson;
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', t1.Id);
        
        //CreateRelationshipController cnt = new CreateRelationshipController();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(t1);
        QuickEntryTaskAddPersonController cnt = new QuickEntryTaskAddPersonController(stdCon);
        
        cnt.CallerTypeChanged();

        cnt.searchPerson();
        cnt.createPersonValidation();
        
        cnt.AddSelectedPersonToTask();
        //cnt.ignoreCreatePerson();
        
        //use second task
        ApexPages.StandardController stdCon2 = new ApexPages.StandardController(t2);
        QuickEntryTaskAddPersonController cnt2 = new QuickEntryTaskAddPersonController(stdCon2);
        cnt2.testIgnoreMessages = true;
        cnt2.accountLink = accLink;
        cnt2.recTask = t2;
        cnt2.relContact = c2;
        cnt2.CallerTypeChanged();

        cnt2.recTask = t2;
        cnt2.selectedServiceName=service.Name;

        cnt2.searchPerson();
        //now repeat search for non-professional
        cnt2.accountLink.Account__c = null;
        cnt2.searchPerson();
        
        cnt2.accountLink = accLink;
        t2.Description='task 2 desc';
        upsert t2;

        //clear messages
        ApexPages.getMessages().clear();
        
        // test createPersonValidation more
        cnt2.relContact2.FirstName='Harry';
        cnt2.relContact2.Salutation='Mr';
        cnt2.lastName = c2.LastName;
        cnt2.relContact2.MailingPostalCode='AB2 2AA';        
        cnt2.relContact2.Birthdate=date.today().addYears(-1);        
        cnt2.createPersonValidation();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.debug('tttttttttttttttttttt ' +   msg.getSummary());
        }
        cnt2.ignoreCreatePerson();        
        //clear messages
        ApexPages.getMessages().clear();
        
        
        cnt2.AddSelectedPersonToTask();
        cnt2.ignoreCreatePerson();
        //carer
        t2.Caller_type__c='Carer';
        upsert t2;
        cnt2.recTask = t2;

        cnt2.CallerTypeChanged();
 
        //clear messages
        ApexPages.getMessages().clear();
        
        cnt2.createPersonValidation();
        //clear messages
        ApexPages.getMessages().clear();
    
        cnt2.AddSelectedPersonToTask();
        //clear messages
        ApexPages.getMessages().clear();
       
        cnt2.ignoreCreatePerson();
        //
        t2.Caller_type__c='Family/Friend';
        upsert t2;
        cnt2.recTask = t2;
        cnt2.CallerTypeChanged();
 
        
        cnt2.createPersonValidation();

       
        cnt2.AddSelectedPersonToTask();
        cnt2.ignoreCreatePerson();
        //health 
        t2.Caller_type__c='Health Services';
        t2.OwnerId = currentUser.id;
        upsert t2;
        cnt2.recTask = t2;
        cnt2.CallerTypeChanged();

        
      // test createPersonValidation more
        cnt2.relContact.FirstName='Harry';
        cnt2.relContact.Salutation='Mr';
        cnt2.lastName = c2.LastName;
        cnt2.relContact.MailingPostalCode='AB2 2AA';  
        cnt2.relContact.Birthdate=date.today();   
           
        cnt2.createPersonValidation();
        
        cnt2.AddSelectedPersonToTask();
        cnt2.ignoreCreatePerson();

     // test createPersonValidation more
        cnt2.selectedRecordTypeName='Carer of Person with Dementia';
        cnt2.relContact.FirstName='Harry';
        cnt2.relContact.Salutation='Mr';
        cnt2.lastName = c2.LastName;
        cnt2.relContact.MailingPostalCode=null;  
        cnt2.relContact.Birthdate=null;
        cnt2.createPersonValidation();
        cnt2.LastName=null;
        cnt2.createPersonValidation();
        
        
        delete t1;
        delete t2;
    }    
}