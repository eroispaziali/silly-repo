/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : VF Page controller methods for contact wizard screen.
 *  Author  : Mike Tinson
 *  Date    : 31-10-2013
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *
 *  Description: Provide some standard routines for users to run which avoids the problems of 
 *  updating service usage records that they do not have access to.    
 *
 *  Modification History
 *
 *  Date         Who            Description 
 *  16-1-2014    Mike Tinson    Update Last Activity Date on Service Usages when closed on death 
 *  3-7-2014     Mike Tinson    IM085811 - Fault with People Wizard Log a Call
    12-1-2015	 Gary Grant	    Support for User Involvement Participants                          
*******************************************************************************************/
public without sharing class ContactWizardController{

    public Contact recContact {get;set;}
    public Id recId {get;set;}
    public String recRecordTypeName {get;set;}
    public List<RelatedServiceUsageClass> lstContactSU {get;set;}    
    public List<RelatedServiceUsageClass> lstRelatedSU {get;set;}    
    public Integer totalRecCnt {get;set;}
    public Integer totalRelatedRecCnt {get;set;}  //total number of open service usages for related people
    public Integer totalOpenCnt {get;set;}
    public Integer totalClosedCnt  {get;set;}
    public Contact inputContact {get;set;}
    public Task Tsk {get;set;}
    public String DeceasedNote {get;set;}
    public String Note {get;set;}
    public Boolean CanAnon {get;set;}
    public String AnonymisingHelpText {get;set;}
    private string SERVICE_EXT_RECTYPE ='External Service';
    private string RELATIONSHIP_PERSONAL_RECTYPE='Personal';
    public List<Id> RelatedIdLst {get;set;}
    public Boolean chkSendEmail {get;set;}
   
    public ContactWizardController (ApexPages.StandardController stdCon){
        recContact = (Contact)stdCon.getRecord();
        if(recContact ==null) recContact = new Contact();
        recId = ApexPages.currentPage().getParameters().get('recId');
        getContactDetails();
        getRecordTypeName();
        getServiceUsages();
        getCountofServices();
        checkIfCanAnon();
        getRelatedServiceUsages();

        putDefaultContactDetails();
        putDefaultTaskDetails();
     }


    Public void checkIfCanAnon(){
        CanAnon = True;
        List <Id> ContactIdLst;
        RecordType rt;
        Id RELATIONSHIP_PERSONAL_RECTYPE;
        
        //get record type of personal relationships
        rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where  SobjectType ='SFDC_Contact_Connector__c' and DeveloperName='Personal'];
        RELATIONSHIP_PERSONAL_RECTYPE= rt.Id;
       //check for ALL Service Usages with a referral outcome of either "service declined" or "service inappropriate" or "person ineligible for service"
       //for(RelatedServiceUsageClass rec: lstContactSU ){
       //    System.debug('#############id:'+rec.recSU.id + ' ' + rec.recSU.name);
       //    System.debug('#############outcome:' + rec.recSU.Referral_Outcome__c);
       //    if ((rec.recSU.Referral_Outcome__c ==null || rec.recSU.Referral_Outcome__c =='' ||
       //        rec.recSU.Referral_Outcome__c =='Not Eligible (Referred on)' ||
       //        rec.recSU.Referral_Outcome__c =='Not Eligible (No further action)' || 
       //        rec.recSU.Referral_Outcome__c =='Service Declined (Referred on)' || 
       //        rec.recSU.Referral_Outcome__c =='Service Declined (No further action)' || 
       //        rec.recSU.Referral_Outcome__c =='Not Interested')==true) { 
               //       ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'This person cannot be anonymised.  There are service usages that have a Referral Outcome that is not  \'Service Declined...\', \'Not Eligible...\', \'Not Interested...\'.');
               //       ApexPages.addMessage(message);
       //        CanAnon = False;
       //        break;
       //     }
       // }
       //Now check for other relationships with this person - if any personal relationships have a service usage then stop the anonymise process
        List<SFDC_Contact_Connector__c> relrecs = [Select Contact__c, Related_Contact__c from SFDC_Contact_Connector__c 
                                             where Contact__c=:recContact.id and RecordTypeId=:RELATIONSHIP_PERSONAL_RECTYPE];
        List<SFDC_Contact_Connector__c> relrecs2 = [Select Contact__c, Related_Contact__c from SFDC_Contact_Connector__c 
                                             where Related_Contact__c=:recContact.id  and RecordTypeId=:RELATIONSHIP_PERSONAL_RECTYPE];
        
        //now combine the lists, removing any duplicates
        Set <Id> relIdSet = new Set<Id>();
        RelatedIdLst = New List<Id>();

        for (SFDC_Contact_Connector__c loopRel : relrecs) {
            if (relIdSet.add(loopRel.Related_Contact__c )){
                RelatedIdLst.add(loopRel.Related_Contact__c);
            }
        }        
        for (SFDC_Contact_Connector__c loopRel : relrecs2 ) {
            if (relIdSet.add(loopRel.Contact__c )){
                RelatedIdLst.add(loopRel.Contact__c);
            }
        }
        System.debug('############## size of rel: ' + RelatedIdLst.Size());
        //Add contact to the list of relatedIds.
        ContactIdLst = New List<Id>();
        ContactIdLst = RelatedIdLst.clone();
        ContactIdLst.add(recContact.id);

        
        //now get all service usages for this list of contacts
        List<Service_Usage__c> relServiceUsage = [Select id, name, Referral_Outcome__c
                        from Service_Usage__c  Where primary_service_user__c IN :ContactIdLst];
        for(Service_Usage__c rec: relServiceUsage ){
           
           System.debug('#############id:' + rec.id );
           System.debug('#############outcome:' + rec.Referral_Outcome__c);
           
           if ((rec.Referral_Outcome__c ==null || rec.Referral_Outcome__c =='' ||
               rec.Referral_Outcome__c =='Not Eligible (Referred on)' ||
               rec.Referral_Outcome__c =='Not Eligible (No further action)' || 
               rec.Referral_Outcome__c =='Service Declined (Referred on)' || 
               rec.Referral_Outcome__c =='Service Declined (No further action)' || 
               rec.Referral_Outcome__c =='Not Interested')==false) { 
               //       ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'This person cannot be anonymised.  There are service usages that have a Referral Outcome that is not  \'Service Declined...\', \'Not Eligible...\', \'Not Interested...\'.');
               //       ApexPages.addMessage(message);
               CanAnon = False;
               break;
            }
        }
    System.debug('#############CanAnon :' + CanAnon  );
   }
    
    /*The button pressed when a person is marked deceased */     
    public pageReference btnDied(){
    
        List <Service_Usage__c> SUToUpdate;
        Id ResponsibleUser;
        RecordType rt;
        Id CRSTASK;
        //get record type for tasks
        rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where  SobjectType ='Task' and DeveloperName='CRS_Task'];
        CRSTASK = rt.Id;
        
        //validate date of death - must not be in future and must be completed
        if (ValidateDeceaseDate()){
            return null;}
        else {
            // Create a savepoint because the data should not be committed to the database
            Savepoint sp = Database.setSavepoint();
            try{
                recContact.Deceased_Date__c = inputContact.Deceased_Date__c;
                recContact.Deceased__c = true;
                //now loop through all service usages for this person, closing them with this date
                //with the closure reason -Service User or person cared for deceased.
                SUToUpdate = new List <Service_Usage__c>();
                
                for(RelatedServiceUsageClass rec: lstContactSU)
                {   
                    if (rec.recSU.Closure_reason__c ==null) {
                        rec.recSU.Closure_reason__c = 'Service User or person cared for deceased';
                        rec.recSU.Closure_date__c = inputContact.Deceased_Date__c;
                        rec.recSU.Date_of_last_Activity__c =System.today(); //change 380 - update last activity
                        SUToUpdate.Add(rec.recSU);
                        //add a note to each service usage.
                        note n = new note();
                        n.parentId= rec.recSU.Id; 
                        n.body=DeceasedNote;
                        n.title='Person has died'; 
                        n.isPrivate=false;  // if private it will be visible only for the owner and any user with modify all permission
                        insert n; //insert the record
                        
                        //add task to service usage record to make sure everything is closed down.
                        //find who to assign task to.  Either the assigned worker or the owner of the service usage
                        if (rec.recSU.Assigned_Worker__c==null){
                            ResponsibleUser = rec.recSU.OwnerId;}
                        else {ResponsibleUser = rec.recSU.Assigned_Worker__c;}
                        //we cannot add a task if the responsible person has been deactivated.
                        User usr;
                        usr = [select id,name, IsActive from User where id=:ResponsibleUser];
                        if (usr.IsActive==true){
                            Task tsk = new Task();
                            tsk.OwnerID=ResponsibleUser;
                            //tsk.Activity_Status__c='Not Started';
                            tsk.ActivityDate=System.Today();
                            tsk.Description=DeceasedNote;
                            tsk.Event_Status__c='Confirmed';
                            tsk.Format__c='Other';
                            tsk.In_Out__c='Outgoing';
                            tsk.Status='Not Started';
                            tsk.WhatId=rec.recSU.Id;
                            tsk.RecordTypeId= CRSTASK;
                            tsk.Subject='Person has died';
                            tsk.IsReminderSet=true;
                            insert tsk;
                        }
                    }
                }
                System.debug('############## SUToUpdate.size(): ' + SUToUpdate.size());
                if (SUToUpdate.size()>0) {
                    upsert SUToUpdate;}
                upsert recContact ;
                
                /* Make the call to set a Participant record to Deceased, if there is one */
                UiUtils.setParticipantDeceased(recContact);
                
                }catch(Exception ex){
                    Database.rollback(sp); 
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while updating details.');
                    ApexPages.addMessage(message);
                    return null;
                }
            PageReference pr=new PageReference('/'+ recContact.Id);
            pr.setRedirect(true);
            return pr;
            }
        }    
    Public PageReference btnAddLogAnAction(){
        List <Service_Usage__c> SUToUpdate; 
        User usr;
        Id ResponsibleUser;
        String ResponsibleUserName;
        RecordType rt;
        Id CRSTASK;
        String temail;
        String userEmail;
        String currentUserName;
        
        system.debug('@@@@@@@@@@@@@@@@@@@@ start of btnAddLogAnAction');
        //get record type for tasks
        rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where  SobjectType ='Task' and DeveloperName='CRS_Task'];
        CRSTASK = rt.Id;  
        //get current users email address - just the once
        ResponsibleUser=UserInfo.getUserId();
        userEmail = UserInfo.getUserEmail();
        currentUserName=UserInfo.getUserName();
        if (!validateLogAnAction()){
            return null;}
        else {
            system.debug('@@@@@@@@@@@@@@@@@@@@ get savepoint');
            // Create a savepoint because the data should not be committed to the database
            Savepoint sp = Database.setSavepoint();
            try{
                //now loop through all service usages for this person, closing them with this date
                //with the closure reason -Service User or person cared for deceased.
                SUToUpdate = new List <Service_Usage__c>();
                System.debug('############## lstContactSU.size(): ' + lstContactSU.size());
                System.debug('############## lstRelatedSU.size(): ' + lstRelatedSU.size());
                for(RelatedServiceUsageClass rec: lstContactSU)
                {   
                     if (rec.Selected) {
                         SUToUpdate.add(rec.recSU);
                     }
                }
                for(RelatedServiceUsageClass rec2: lstRelatedSU)
                {   
                     if (rec2.Selected) {
                         SUToUpdate.add(rec2.recSU);
                     }
                }
                System.debug('############## SUToUpdate.size(): ' + SUToUpdate.size());
                if (SUToUpdate.size()>0) {
                    for (Service_Usage__c su: SUToUpdate) {
                    
                        //deep clone
                        //Task newTask = tsk.Clone(false,true);
                        //
                        //newTask.WhatId= su.id;
                        if (su.Assigned_Worker__c==null){
                                ResponsibleUser = su.OwnerId;}
                        else {ResponsibleUser = su.Assigned_Worker__c;}
                        //we cannot add a task if the responsible person has been deactivated.
                        
                        usr = [select id,name,email, IsActive from User where id=:ResponsibleUser];
                        temail= usr.email;
                        ResponsibleUserName = usr.name;
                        if (usr.IsActive==false) {
                            ResponsibleUser= UserInfo.getUserId();
                            ResponsibleUserName = UserInfo.getUserName();
                            temail = userEmail;
                            }
                        Task newTsk = new Task();
                        newTsk.RecordTypeId = CRSTASK;
                        newTsk.OwnerID=ResponsibleUser;
                        //tsk.Activity_Status__c='Not Started';
                        newTsk.ActivityDate = tsk.ActivityDate;
                        newTsk.Subject = tsk.Subject;
                        newTsk.Description = tsk.Description;
                        newTsk.Event_Status__c = tsk.Event_Status__c;
                        newTsk.Format__c = tsk.Format__c;
                        newTsk.In_Out__c = tsk.In_Out__c;
                        newTsk.Status = tsk.Status;
                        newTsk.Related_Outcomes__c = tsk.Related_Outcomes__c;
                        newTsk.Primary_Service_User_Involved__c = tsk.Primary_Service_User_Involved__c;
                        newTsk.Staff_Time_Minutes__c = tsk.Staff_Time_Minutes__c;
                        newTsk.Volunteer_Time_Minutes__c=tsk.Volunteer_Time_Minutes__c;
                        newTsk.Completion_Date_Task__c=tsk.Completion_Date_Task__c;
                        newTsk.Travel_Time_Minutes__c=tsk.Travel_Time_Minutes__c;
                        newTsk.Information_Provided__c=tsk.Information_Provided__c;
                        newTsk.WhatId = su.Id;
                        newTsk.IsReminderSet=true;
                        
                        //send email 
                        if ((chkSendEmail) ){
                            system.debug('@@@@@@@@@@@@@@@@@@@@ send email for task');
                            Database.DMLOptions dmlo = new Database.DMLOptions();
                            dmlo.EmailHeader.triggerUserEmail = true;
                            //Check return result from insert method
                            Database.SaveResult sr  = database.insert(newTsk, dmlo);
                            // Iterate through each returned result
                            //for (Database.SaveResult sr : srList) {
                                if (sr.isSuccess()) {
                                    // Operation was successful, so get the ID of the record that was processed
                                    System.debug('Successfully inserted task. Task ID: ' + sr.getId());
                                }
                                else {
                               // Operation failed, so get all errors                
                                    for(Database.Error err : sr.getErrors()) {
                                        ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while updating details ' + err.getMessage() + ' ' + err.getStatusCode());
                                        ApexPages.addMessage(message);
                                        return null;
                                    }
                                }
                            //}
                        }
                        else {
                            system.debug('@@@@@@@@@@@@@@@@@@@@ insert task, no email');
                            insert newTsk;
                            }
                       }
                    }
                }catch(Exception ex){
                    Database.rollback(sp); 
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while updating details.');
                    ApexPages.addMessage(message);
                    return null;
                }
            PageReference pr=new PageReference('/'+ recContact.Id);
            pr.setRedirect(true);
            return pr;
            }
    }
    Private Boolean validateLogAnAction(){
        Integer countapprovedrecords=0;
        for (RelatedServiceUsageClass record : lstContactSU){
             if(record.selected){
             countapprovedrecords++;
             }
        }
        for (RelatedServiceUsageClass record2 : lstRelatedSU){
             if(record2.selected){
             countapprovedrecords++;
             }
        }

        if (countapprovedrecords==0){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must select one or more services to record this Log An Action against.');
            ApexPages.addMessage(message);
            
            return false;
        }
        
        if (tsk.Status=='Completed'){
            if ((Tsk.Staff_Time_Minutes__c==null)){
              ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Staff Time for a completed Log An Action.');
              ApexPages.addMessage(message);
              return false;  
              }
        }
        if (tsk.Status=='Completed'){
            if ((Tsk.Volunteer_Time_Minutes__c==null)){
              ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Volunteer Time for a completed Log An Action.');
              ApexPages.addMessage(message);
              return false;  
              }
        }

        if (tsk.Status=='Completed'){
            if ((Tsk.Completion_Date_Task__c==null)){
              ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter a Completion Date for a completed Log An Action.');
              ApexPages.addMessage(message);
              return false;  
              }
        }
        return true;
    }
    Private Boolean ValidateDeceaseDate(){
        Boolean isError;
        isError = false;
        if ((inputContact.Deceased_Date__c==null)){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.Error,'You must enter the Deceased Date (or an estimated date).');
            ApexPages.addMessage(message);
            isError=true;
        }
        if((inputContact.Deceased_Date__c!=null) && (inputContact.Deceased_Date__c> System.today())) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.Error,'The Deceased Date entered is in the future.');
            ApexPages.addMessage(message);
            isError=true;
        }
        return isError;
    }
 
    public void putDefaultContactDetails(){
    //temporary contact record for inputs
    inputContact = new Contact();
    // defaults
    DeceasedNote = 'Please note that ' + recContact.Name + ' has died.';
    AnonymisingHelpText ='Anonymising is only permitted if the individual or any people who have a relationship created to the individual on CRS HAVE NOT ever received any services from Alzheimer\'s Society. If in doubt, do not anonymise - ask your SIM for guidance.';
    
    } 
    public Contact getContactDetails() {
        recContact = [select id, name, Birthdate,Client_reference_number__c,RecordTypeId
                        ,Deceased__c,Deceased_Date__c,rrpu__Alert_Message__c
          from Contact where id=:ApexPages.currentPage().getParameters().get('id')];
        return recContact ;
    
    }
    public void putDefaultTaskDetails(){
        Tsk = new Task();
        Tsk.Status='In Progress';  
        Tsk.ActivityDate=System.Today();
        //Tsk.Completion_Date_Task__c=System.Today();
    }
    public String getRecordTypeName() {
         List<RecordType> lstRec =[SELECT Id, Name FROM RecordType WHERE SobjectType='Contact' and Id=:recContact.RecordTypeId];
         if (lstRec.size()==0){
             recRecordTypeName ='';}
         else {recRecordTypeName = lstRec[0].Name;}
         return recRecordTypeName;
    }
    public void getCountOfServices(){
           //Get the count of records, this derives whether More link on Page be shown or not.
        totalRecCnt = [Select count() from Service_Usage__c where (Primary_Service_User__c =:recContact.id ) and Service_Field__r.RecordType.Name !=: SERVICE_EXT_RECTYPE];
        totalClosedCnt = [Select count() from Service_Usage__c where (Primary_Service_User__c =:recContact.id ) and (Closure_Reason__c !='') and (Service_Field__r.RecordType.Name !=: SERVICE_EXT_RECTYPE)];
        totalOpenCnt = totalRecCnt - totalClosedCnt; 
    
    }
    
 
    public void getServiceUsages() {

        Map<Id,Service_Usage__c> lstServUsage = new Map<Id,Service_Usage__c>([Select Id, Name,Service_Field__c,Service_Field__r.Name,
        Service_Type__c,Date_of_last_Activity__c,Referral_Date__c,Closure_Date__c, Closure_Reason__c,
         Referral_Outcome__c,
         Risk_Identified__c,Public_Alert_Message_Required__c,Assigned_Worker__c, Assigned_Worker__r.Name,
         OwnerId
        from Service_Usage__c where (Primary_Service_User__c =:recContact.id ) 
        and Service_Field__r.RecordType.Name !=: SERVICE_EXT_RECTYPE]);

        //This is Seperate Class which run query under User privileges.
        ContactServiceUsageWithSharing clsAccessible = new ContactServiceUsageWithSharing();
        
        //Returned accessible/visible ServiceUsage records Ids.
        Set<Id> setAccessibleRecs = clsAccessible.getAccessibleRecords(lstServUsage.keyset());
        
        lstContactSU = new List<RelatedServiceUsageClass>();
        
        //Iterate to populate specail Inner Class with flag to say a ServiceUsage record is accessible to user.
        for(Service_Usage__c rec: lstServUsage.Values())
        {
            RelatedServiceUsageClass cls = new RelatedServiceUsageClass();
            cls.recSU = rec;
            
            //If record found in Accessible set then will have edit and view link of page.
            cls.isAccessible = setAccessibleRecs.contains(rec.id);
            if (rec.Closure_Reason__c!=null){
                cls.isClosed=true;}
            else {cls.isClosed=false;
                //only add open services to the list
                cls.Selected=true;
                lstContactSU.add(cls);
            }
        }
       
        
       
    }
    Private void getRelatedServiceUsages(){
        //Now add related service usages but do not select them.
        Map<Id,Service_Usage__c> lstServUsage = new Map<Id,Service_Usage__c>([Select Id, Name,Service_Field__c,Service_Field__r.Name,
        Service_Type__c,Date_of_last_Activity__c,Referral_Date__c,Closure_Date__c, Closure_Reason__c,
         Referral_Outcome__c,
         Risk_Identified__c,Public_Alert_Message_Required__c,Assigned_Worker__c, Assigned_Worker__r.Name,
         OwnerId
        from Service_Usage__c where (Primary_Service_User__c IN :RelatedIdLst )
//        and Closure_Reason__c!=null 
        and Service_Field__r.RecordType.Name !=: SERVICE_EXT_RECTYPE]);

        //This is Seperate Class which run query under User privileges.
        ContactServiceUsageWithSharing clsAccessible = new ContactServiceUsageWithSharing();
        
        //Returned accessible/visible ServiceUsage records Ids.
        Set<Id> setAccessibleRecs = clsAccessible.getAccessibleRecords(lstServUsage.keyset());
        
        lstRelatedSU = new List<RelatedServiceUsageClass>();
        //Iterate to populate specail Inner Class with flag to say a ServiceUsage record is accessible to user.
        for(Service_Usage__c rec: lstServUsage.Values())
        {
            RelatedServiceUsageClass cls = new RelatedServiceUsageClass();
            cls.recSU = rec;
            
            //If record found in Accessible set then will have edit and view link of page.
            cls.isAccessible = setAccessibleRecs.contains(rec.id);
            if (rec.Closure_Reason__c!=null){
                cls.isClosed=true;}
            else {cls.isClosed=false;
                //only add open services to the list
                cls.Selected=false;
                lstRelatedSU.add(cls);
            }
        }
        //return the number of related open SUs
        totalRelatedRecCnt = lstRelatedSU.size();

    }
    /**
        Method to delete the details of the contact record.
    **/
    public PageReference AnonymisePerson() {
        Id thisUserId;
        Integer count;
        thisUserId = UserInfo.getUserId();
        Contact anonPerson;
        List<Contact_History__c> contactHistory;  
        String diagnosis;
        
        If (CanAnon == False){return null;} 
        anonPerson= [Select c.Specialist_Communication_Needs__c, c.Social_Service_Ref_No__c, c.Service_user_aware_of_diagnosis__c, 
            c.Salutation, c.Preferred_means_of_contact__c, c.PoA_Notes__c, c.Other_Demographic_Details__c, c.OtherStreet, 
            c.OtherState, c.OtherPhone, c.OtherCountry, c.OtherCity, c.MobilePhone, c.Means_of_first_contact__c, c.Diagnosis__c, 
            c.MailingStreet, c.MailingState, c.MailingCountry, c.MailingCity, c.LastName, c.Known_as__c, c.Id, c.HomePhone, 
            c.First_language__c, c.FirstName, c.Email, c.Key_Health_Issues__c,  
            c.Diagnosis_made_by__c, c.Diagnosis_Details__c, 
            c.Date_of_diagnosis__c, c.Consent_Status__c, c.Brief_Outline_of_Personal_History__c, c.Approximate_date_of_diagnosis__c, 
            c.Advance_Directives__c, c.Additional_Health_Information__c, c.rrpu__Alert_Message__c, c.Phone From Contact c 
            WHERE id=:recContact.id];

        // Create a savepoint because the data should not be committed to the database
        Savepoint sp = Database.setSavepoint();
        boolean hasDMLExceptionRaised=false;
        Exception exToPass;

        try{
            anonPerson.Specialist_Communication_Needs__c = '';
            anonPerson.Social_Service_Ref_No__c = '';
            anonPerson.Service_user_aware_of_diagnosis__c = false;
            anonPerson.Salutation = '';
            anonPerson.Preferred_means_of_contact__c = '';
            anonPerson.PoA_Notes__c = '';
            anonPerson.Other_Demographic_Details__c = '';
            anonPerson.OtherStreet = '';
            anonPerson.OtherState = '';
            anonPerson.OtherPhone = '';
            anonPerson.OtherCountry = '';
            anonPerson.OtherCity = '';
            anonPerson.OtherPostalCode='';
            anonPerson.MobilePhone = '';
            anonPerson.Means_of_first_contact__c = '';
            anonPerson.MailingStreet = '';
            anonPerson.MailingState = '';
            anonPerson.MailingCountry = '';
            anonPerson.MailingCity = '';
            anonPerson.MailingPostalCode='';
            anonPerson.LastName = '*****';
            anonPerson.Known_as__c = '';
            anonPerson.HomePhone = '';
            anonPerson.First_language__c = '';
            anonPerson.FirstName = '*****';
            anonPerson.Email = '';
            anonPerson.Key_Health_Issues__c = '';
            anonPerson.Diagnosis_made_by__c = null;
            diagnosis = anonPerson.Diagnosis__c;
            if (diagnosis!=null && diagnosis!='' && diagnosis.contains('Other')) 
                anonPerson.Diagnosis_Details__c = '*****';
            else 
                anonPerson.Diagnosis_Details__c = '';   
            anonPerson.Date_of_diagnosis__c = Date.today();
            anonPerson.Consent_Status__c = '';
            anonPerson.Brief_Outline_of_Personal_History__c = '';
            anonPerson.Approximate_date_of_diagnosis__c = false;
            anonPerson.Advance_Directives__c = '';
            anonPerson.Additional_Health_Information__c = '';
            anonPerson.Phone = '';
            if(anonPerson.DoNotCall) anonPerson.rrpu__Alert_Message__c = '******'; else anonPerson.rrpu__Alert_Message__c = '';
            
            update anonPerson;
            
            //remove the contact details from contct history as well
            contactHistory = [Select c.OwnerId, c.Specialist_Communication_Needs__c, c.Service_User_aware_of_diagnosis__c, c.Name, c.Mailing_Address__c, 
                                c.Lastname__c, c.Id, c.Firstname__c, c.Diagnosis_made_by__c, c.Diagnosis__c, c.Date_of_Diagnosis__c, 
                                c.Contact_History__c, c.Alert_Message__c From Contact_History__c c 
                                where Contact_History__c = :anonPerson.Id];
            //update owner of contact history records
            count = 0;
            List<Contact_History__c> chToUpdate = new List<Contact_History__c>();
            for(Contact_History__c ch : contactHistory ){
                if(ch.OwnerId!= thisUserId){
                     ch.OwnerId = thisUserId;
                     chToUpdate.add(ch);
                     count++;
                                          }   
            
            }
            if (count>0){
                system.debug('##########records to be updated ##########' + count);
                update chToUpdate;
                }
            delete contactHistory;
            
        }catch(Exception ex){exToPass=ex;hasDMLExceptionRaised=true;}
      // Revert the database to the original state on Exception
      if(hasDMLExceptionRaised)
      {
        Database.rollback(sp);      
        ApexPages.addMessages(exToPass);

        ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, 'Contact The CRS Helpdesk.');
        ApexPages.addMessage(message);
        return null;  
      }  
      return new PageReference('/'+anonPerson.Id);
    }
    

    //Inner Class
    public class RelatedServiceUsageClass
    {
        public boolean isAccessible {get;set;}
        public boolean isClosed {get;set;}
        public Service_Usage__c recSU {get;set;}
        public Boolean selected {get; set;}

    }    
    
}