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
 *  2013-05-14    MT    Redevelop to remove some anoyances.  Split into two page solution 
 *                      - this page add a task, next page add person/Contact
 *                             
*******************************************************************************************/
public with sharing class QuickEntryTaskPersonController{

    public Task recTask {get;set;}
    public Id recordTypeId {get;set;}
    public Id conRecordTypeId {get;set;}
    public String selectedRecordTypeName {get;set;}
    public String selectedRelContactId {get;set;}
    public String selectedRelContactName {get;set;}
    public Contact cont;
    public Boolean ignoreAndCreate {get;set;}
    public String lastName {get;set;}
    public String selectedServiceName {get;set;}
    public List<SelectOption> lstRecordTypes{get;set;}
    public Boolean testIgnoreMessages {get;set;}
    String postcodeRegex = '[a-zA-Z]{1,2}[0-9][0-9a-zA-Z]?\\s[0-9]{1}';
    Pattern MyPattern = Pattern.compile(postcodeRegex);

// Then instantiate a new Matcher object "MyMatcher"


    //Constructor
    public QuickEntryTaskPersonController(ApexPages.StandardController stdCon){
        recTask = new Task();
        recTask.OwnerId = UserInfo.getUserId();
        RecordType recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name = 'CRS Information Provision Task'];
        recTask.RecordTypeId = recordType.id;
        recTask.Subject = 'Information Provision';
        //when the page loads, default Person record Type to the first option in the list(Carer of Person with Dementia)
        //change the query if the first option in the list is not 'Carer of Person with Dementia'
        recordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Carer of Person with Dementia'].Id;
        selectedRecordTypeName = Contact.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        testIgnoreMessages = false;
    }

    //Prepare Service Name list. Mandatory lookup showing 'Internal' Service of type 'Information Provision' within the user's locality
    public List<SelectOption> getServiceNames(){
        List<SelectOption> lstServiceNames = new List<SelectOption>();
       
        Set<String> setLocality = new Set<String>();
       // lstServiceNames.add(new SelectOption(new Id(),'None'));
       lstServiceNames.add(new SelectOption('0001', '--None--'));
       
        User currentUser = [Select u.Locality__c, u.Area__c, u.email, u.Id, u.Name From User u where u.Id = :Userinfo.getUserId()];
        System.debug('****** currentUser ******: '  + currentUser.Name + '|' + currentUser.Locality__c + '|' + currentUser.Area__c);    
        
        for (AggregateResult results : [Select Area__c from User Where email = :currentUser.email   
                                                                        and isactive=true and Area__c <>'' 
                                                                        group by Area__c order by Area__c]){
            setLocality.add((String)results.get('Area__c'));
        }

        //DEBUG INFO!!
        List<String> listStrings = new List<String>(setLocality);
        System.debug('****** listStringsSize ******: '  + listStrings.Size());
        for (Integer i = 0; i < listStrings.size(); i++){
            System.debug('****** listStrings ******: '  + listStrings[i]);
        }

        RecordType serviceRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Services__c' and Name = 'Internal Service'];
        
        if (setLocality.size()> 1 && currentUser.email!='CRSSupport@alzheimers.org.uk'){
           for(Services__c service: [Select service_type__c, RecordTypeId, Name, Locality__r.Name, Locality__r.AreaLookup__c, Operated_By__r.Name, service_closedate__c, Id, service_status__c From Services__c  
                                            where RecordTypeId = :serviceRecordType.Id 
                                            and Locality__r.AreaLookup__c = :setLocality
                                            and service_type__c = 'Information provision'
                                            and service_status__c = 'Open']){
                if(service.service_closedate__c==null || service.service_closedate__c>System.Today())
                    lstServiceNames.add(new SelectOption(service.id,service.name +' (Operated by:'+service.Operated_By__r.Name+')'+' ('+service.Locality__r.Name+')'));
            }        
        }
        else {
            for(Services__c service: [Select service_type__c, RecordTypeId, Name, Locality__r.Name, Locality__r.AreaLookup__c, Operated_By__r.Name, service_closedate__c, Id, service_status__c From Services__c  
                                            where RecordTypeId = :serviceRecordType.Id 
                                            and Locality__r.AreaLookup__c = :currentUser.Area__c
                                            and service_type__c = 'Information provision'
                                            and service_status__c = 'Open']){
                if(service.service_closedate__c==null || service.service_closedate__c>System.Today())
                    lstServiceNames.add(new SelectOption(service.id,service.name +' (Operated by:'+service.Operated_By__r.Name+')'));
            }
        }
        
        //DEBUG INFO!!
        for (Integer i = 0; i < lstServiceNames.size(); i++){
            System.debug('****** lstServiceNames ******: '  + lstServiceNames[i]);
        }        

        return lstServiceNames;
    }
    
    /*
    This method handler will run validations on new task record.
    */
    public PageReference createTaskValidation(){
    
        if(selectedServiceName==null || selectedServiceName=='' || selectedServiceName=='0001'){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must select a Service.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.Time_of_call__c==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Time of call.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.Description==null || recTask.Description==''){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Comments.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.OwnerId==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Worker.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.Caller_type__c==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Caller type.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.Format__c==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Format.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.In_Out__c==null && recTask.Format__c!='Face to Face'){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Value for In/Out is required unless Format is Face to Face.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.Subject==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Subject.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.Call_Outcome__c==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Call Outcome.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.Staff_Time_Minutes__c==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Staff Time.');
            ApexPages.addMessage(message);
            return null;
        }
        if(recTask.Volunteer_Time_Minutes__c==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Volunteer Time.');
            ApexPages.addMessage(message);
            return null;
        }
        //check that if a postcode sector, only the sector - XX1X+space+Number have been added.
        if ((recTask.Postcode_Sector__c!=null)&&(recTask.Postcode_Sector__c!='')) {
            Matcher MyMatcher = MyPattern.matcher(recTask.Postcode_Sector__c);
            if (!MyMatcher.matches()) {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Postcode sector must be in valid format.The postcode sector is made up of the postcode district, the single space, and the first character of the inward code. It is between four and six characters long (including the single space).');
                ApexPages.addMessage(message);
                return null;
                }
        }    
        return null;
    }
    
    /*
    This method handler will allow user to create new task record.
    */
    public PageReference createTask(){
        //run Task validations
        createTaskValidation();
        
        //if there are validation errors, display them on the screen
        if(Apexpages.getMessages().size()>0 && !testIgnoreMessages)
            return null;
       
        //if no validation errors, create task
        try{
            RecordType recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name = 'CRS Information Provision Task'];
            recTask.RecordTypeId = recordType.id;
            recTask.WhatId = selectedServiceName;
            recTask.Status = 'Completed';
            recTask.ActivityDate = System.today();
            recTask.Completion_Date_Task__c = System.today();
            upsert recTask;
        }catch(System.DmlException e){ 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
        //display Task when ceated
        return new Pagereference('/'+recTask.Id); //return to task details page
    }
    /*
    This method handler will save an new task record and then moved to new screen to add person.
    */
    public PageReference createTaskAndSearchForPerson(){
        //run Task validations
        createTaskValidation();
        
        //if there are validation errors, display them on the screen
        if(Apexpages.getMessages().size()>0 && !testIgnoreMessages)
            return null;
        
        //if no validation errors, create task
        try{
            RecordType recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name = 'CRS Information Provision Task'];
            recTask.RecordTypeId = recordType.id;
            recTask.WhatId = selectedServiceName;
            recTask.Status = 'Completed';
            recTask.ActivityDate = System.today();
            recTask.Completion_Date_Task__c = System.today();
            
            upsert recTask;
        }catch(DmlException e){ 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
           
            return null;
        }
        //take user to next screen to add person details.display Task when ceated
        return new Pagereference('/apex/QuickEntryTaskAddPerson?id='+recTask.Id); //return to task details page
    }
    
 
  //
  // TEST CASE
  //
  private static testMethod void testQuickEntry() {
        Services__c service = new Services__c(Name='Test service');
//t        User currentUser = [Select u.Locality__c, u.Id From User u where id = :Userinfo.getUserId()];
        User currentUser = [Select u.Id From User u where id = :Userinfo.getUserId()];
        RecordType serviceRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Services__c' and Name = 'Internal Service'];
        
        Account acc = new Account(Name='Essex Locality',RecordTypeId=[Select Id from RecordType where 
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
        
        Contact c1 = new Contact(Salutation='Mr',FirstName='one', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today());
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
        Contact c2 = new Contact(Salutation='Mr',FirstName='one', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today());
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
        PageReference pageRef = Page.QuickEntryTaskPerson;
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', c1.Id);
        
        //CreateRelationshipController cnt = new CreateRelationshipController();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c1);
        QuickEntryTaskPersonController cnt = new QuickEntryTaskPersonController(stdCon);
        
 
         //cnt.getSelectedRecordTypeName();
        cnt.getServiceNames();

        t1.Description=null;
        upsert t1;
        cnt.createTaskValidation();
        cnt.createTask();
        cnt.createTaskValidation();
        
        
       
        
        //use second task
        //CreateRelationshipController cnt2 = new CreateRelationshipController();
        ApexPages.StandardController stdCon2 = new ApexPages.StandardController(c2);
        QuickEntryTaskPersonController cnt2 = new QuickEntryTaskPersonController(stdCon2);
        cnt2.testIgnoreMessages = true;

        cnt2.recTask = t2;


        

        //cnt2.getSelectedRecordTypeName();
        cnt2.getServiceNames();
        cnt2.recTask = t2;
        cnt2.selectedServiceName=service.id;

      
        t2.Description='task 2 desc';
        upsert t2;
        cnt2.createTaskValidation();
        cnt2.createTask();
        // test createPersonValidation more
        cnt2.createTaskAndSearchForPerson();
        //clear messages
        ApexPages.getMessages().clear();
        
        
        //carer
        t2.Caller_type__c='Carer';
        upsert t2;
        cnt2.recTask = t2;
        
        
        
        
        
        //test createTaskValidation thoroughly
        cnt2.selectedServiceName='Test';
        cnt2.createTaskValidation();
        cnt2.recTask.Volunteer_Time_Minutes__c=null;
        cnt2.createTaskValidation();
        cnt2.recTask.Staff_Time_Minutes__c=null;
        cnt2.createTaskValidation();
        cnt2.recTask.Call_Outcome__c=null;
        cnt2.createTaskValidation();
        cnt2.recTask.Subject=null;
        cnt2.createTaskValidation();
        cnt2.recTask.In_Out__c=null; 
        cnt2.recTask.Format__c='Telephone';
        cnt2.createTaskValidation();

        cnt2.recTask.Format__c=null;
        cnt2.createTaskValidation();
        cnt2.recTask.Caller_type__c=null;
        cnt2.createTaskValidation();
        cnt2.recTask.OwnerId=null;
        cnt2.createTaskValidation();
        cnt2.recTask.Description=null;
        cnt2.createTaskValidation();
        cnt2.recTask.Time_of_call__c=null;
        cnt2.createTaskValidation();
        
        delete t1;
        delete t2;
    }    
}