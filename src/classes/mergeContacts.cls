public with sharing class mergeContacts {
//public ApexPages.StandardController stdController;

/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Page controller methods for Merge Contacts, allowing two contacts to be merged.
 *  Author  : Richard Cole
 *  Date    : 2014-08-22
 *  Version : 1.1 
 *  Project : n/a
 *
 *  Description: Page controller to merge two contacts into one object and assign service usage 
 *               of the child node to the master record. 
 *               User can pick information from the child record if the field is different    
 *
 *  Modification History
 *
 *  Date         Who            Description 
 * 
 * 2014-08-22    Richard Cole   First iteration 
 * 2014-10-02    Mike Tinson    Reapplied Ian Smith Demographic Merge code
   2014-12-05 	 Gary Grant		Added support for User Involvement Participants 
 *                            
*******************************************************************************************/

public Contact master{get;set;}
public Contact child{get;set;}

public Map<Integer,List<SelectOption>> radioMap { get; set;}
public Map<Integer,string> titleMap { get; set;}
public List<string> postValues { get; set; }

public Boolean canMerge {get;set;}
public Integer nextStep {get;set;}

public Boolean mergeRequested {get;set;}
public Boolean bIsCRSContact {get;set;}

private string message = 
        'Please check that the two records are for the same person and confirm that should be merged together. ' +
        '<b>Before merging, please copy any data you need to keep from the person record to be merged</b>. ' + 
        '(Attached records such as Service Usages and relationships will be copied over.) ' +
        '<br>Once you have checked the records, please click the "{0}Merge People" button.';

private string noMasterRecord = 'Cannot find records.';
private string noChildRecord  = 'Cannot find record to be merged. ' + 
                                'This probably means that the merge has already been done. ' +
                                'Please check the audit trail of the Master Record.';
                                
private string redirectURL = '/apex/MergeContacts?masterid={0}&childid={1}&selection={2}';                      
                                
private string mergeMessage = '<b>Merged contacts</b> - {0} ({1}) with {2} ({3})<br/>' +
                              'The merged records audit trail has been merged with the current person.<BR/>';

// Request email recipients and templates
private List<string> toEmailAddress = new List<String> {'CRSSupport@alzheimers.org.uk'};
private string senderName        = 'Salesforce Support';
private string emailTitle        = 'Merge Contacts Request: {0} ({1}) with  {2} ({3})';     
private string plainBody         = 'Merge Request: /apex/MergeContacts?masterid={0}&childid={1}&selection={2}';
private string htmlBody          = 'Your merge request: <b>{0}</b> with {1} has been created.<p>'+
                                   'To view the merge request <a href="https://{4}/apex/' +
                                   'MergeContacts?masterid={2}&childid={3}&selection={5}">click here</a>.';                                                     
                                                              
    public mergeContacts () 
    {
    }
    
    public PageReference AutoRunMergeContacts()
    {      
        // Get the selection parameter that may be submitted by a remote user or user that doesn't
        // have admin privileges
        string selectionString = ApexPages.currentPage().getParameters().get('selection');          
        Integer selected = 0;
        
        mergeRequested = false;   
        titleMap       = new Map<Integer,string>();     
        radioMap       = new Map<Integer,List<SelectOption>>();
        postValues     = new List<string>();
        nextStep       = 0;                
                
        if (selectionString != null)
        {
            selected = integer.valueof(selectionString);
        }
           
        try 
        {
            master = GetContactDetails(ApexPages.currentPage().getParameters().get('masterid'));                                                     
            system.debug('@@@@@@@@@@@@@@@' + master.id);
        }
        catch (Exception ex) 
        {           
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,noMasterRecord));            
            return null;
        }
        
        try 
        {                                   
            child =  GetContactDetails(ApexPages.currentPage().getParameters().get('childid'));  
            system.debug('@@@@@@@@@@@@@@@' + child.id);
        }
        catch (Exception ex) 
        {          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, noChildRecord));
            return null;
        }
                  
        system.debug('master.AccountId' + master.AccountId);
        
        // Get both Organisation names for both contacts
        String masterOrg = GetOrgAccountName(master.AccountId); 
        String childOrg = GetOrgAccountName(child.AccountId); 
                              
        // Populate the display data                              
        titleMap.put(0,'Name');
        radioMap.put(0, CreateSelectOption(master.Name, child.Name));
        postValues.add(removeNullValues(master.Name));
        titleMap.put(1,'Date of Birth');
        radioMap.put(1, CreateSelectOption(convertDate(master.BirthDate), convertDate(child.BirthDate)));
        postValues.add(convertDate(master.BirthDate));
        titleMap.put(2,'Record Type');
        radioMap.put(2, CreateSelectOption(master.Record_Type_Name__c, child.Record_Type_Name__c));
        postValues.add(removeNullValues(master.Record_Type_Name__c));
        titleMap.put(3,'Organisation');
        radioMap.put(3, CreateSelectOption(masterOrg, childOrg));
        postValues.add(removeNullValues(masterOrg));
        titleMap.put(4,'Gender');
        radioMap.put(4, CreateSelectOption(master.gender__c, child.gender__c));
        postValues.add(removeNullValues(master.gender__c));
        titleMap.put(5,'Street');
        radioMap.put(5, CreateSelectOption(master.MailingStreet, child.MailingStreet));
        postValues.add(removeNullValues(master.MailingStreet));
        titleMap.put(6,'City');
        radioMap.put(6, CreateSelectOption(master.MailingCity, child.MailingCity));
        postValues.add(removeNullValues(master.MailingCity));
        titleMap.put(7,'Post Code');
        radioMap.put(7, CreateSelectOption(master.MailingPostalCode, child.MailingPostalCode));
        postValues.add(removeNullValues(master.MailingPostalCode));
        titleMap.put(8,'Phone');
        radioMap.put(8, CreateSelectOption(master.HomePhone, child.HomePhone));
        postValues.add(removeNullValues(master.HomePhone));
        titleMap.put(9,'Mobile');
        radioMap.put(9, CreateSelectOption(master.MobilePhone, child.MobilePhone));
        postValues.add(removeNullValues(master.MobilePhone));
        titleMap.put(10,'Dementia Diagnosis');        
        radioMap.put(10, CreateSelectOption(master.Diagnosis__c, child.Diagnosis__c));
        postValues.add(removeNullValues(master.Diagnosis__c));
        titleMap.put(11,'Consent Status');
        radioMap.put(11, CreateSelectOption(master.Consent_Status__c, child.Consent_Status__c));
        postValues.add(removeNullValues(master.Consent_Status__c));         
        titleMap.put(12,'Date of Consent');
        radioMap.put(12, CreateSelectOption(convertDate(master.Database_consent_Date__c), convertDate(child.Database_consent_Date__c)));
        postValues.add(convertDate(master.Database_consent_Date__c));          
        titleMap.put(13,'Location of Consent form');
        radioMap.put(13, CreateSelectOption(master.Location_of_Consent_Form__c, child.Location_of_Consent_Form__c));
        postValues.add(removeNullValues(master.Location_of_Consent_Form__c));                                               
        
        // change selection of radio buttons if applicable.
        getRadioSelection(13, 8192, selected, removeNullValues(child.Location_of_Consent_Form__c));
        getRadioSelection(12, 4096, selected, convertDate(child.Database_consent_Date__c));
        getRadioSelection(11, 2048, selected, removeNullValues(child.Consent_Status__c));
        getRadioSelection(10, 1024, selected, removeNullValues(child.Diagnosis__c));
        getRadioSelection(9, 512, selected, removeNullValues(child.MobilePhone));
        getRadioSelection(8, 256, selected, removeNullValues(child.HomePhone));
        getRadioSelection(7, 128, selected, removeNullValues(child.MailingPostalCode));
        getRadioSelection(6, 64, selected, removeNullValues(child.MailingCity));
        getRadioSelection(5, 32, selected, removeNullValues(child.MailingStreet));
        getRadioSelection(4, 16, selected, removeNullValues(child.gender__c));
        getRadioSelection(3, 8, selected, removeNullValues(childOrg));
        getRadioSelection(2, 4, selected, removeNullValues(child.Record_Type_Name__c));
        getRadioSelection(1, 2, selected, convertDate(child.BirthDate));
        getRadioSelection(0, 1, selected, removeNullValues(child.Name));
                           
        //check to see if user can delete contacts.  If they cannot they they will have to contact CRS support.
        Boolean canDelete = Contact.sObjectType.getDescribe().isDeletable();
                                                     
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 
            string.format(message, new List<String> { canDelete ? '' : 'Request '})));                   
            
        nextStep = canDelete ? 2 : 1;
        
        return null;
    }
    
    private void getRadioSelection(Integer index, Integer boolValue, Integer selection, string selectValue)
    {
        if ((selection & boolValue) == boolValue)
        { 
            postValues[index] = selectValue; 
        }               
    }
    
    private Integer setRadioSelection(Integer index, Integer boolValue, Integer selection, string selectValue)
    {         
        Integer output = selection;
        
        if (isDifferent(index, selectValue))
        {
            output += boolValue;    
        }
        
        return output;
    }
    
    private boolean isDifferent(Integer index, string selectValue)
    {
        // check the values selected and the post back values from the page selection
        return (postValues[index] != null && selectValue.trim() != postValues[index].trim());
    }    
    
    private string convertDate(Date dt)
    {    
        return dt == null ? ' ' : dt.format();     
    }
    
    public string removeNullValues(string value)
    {
        //substitute a nbsp for a null value
        return  value == null ? ' ' : value ; 
    }
        
    private List<SelectOption> CreateSelectOption(string master, string child)
    {    
        // Create a radio button select object to be displayed on the website.
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(master == null ? ' ' : master,master == null ? '' : master, master == child));     
        options.add(new SelectOption(child == null ? ' ' :  child,child == null ? '' :  child, master == child)); 
        return options;
    }
    
    private Contact GetContactDetails(Id contactId)
    {
        // Generic select for contacts using a dynamic ID
        return [select  id, Name, Client_reference_number__c, Email, 
                        FirstName, LastName, Database_consent_Date__c, 
                        Location_of_Consent_Form__c,
                        Record_Type_Name__c, AccountId, RecordTypeId, 
                        Diagnosis__c, Consent_Status__c, MailingStreet, 
                        MailingState, MailingPostalCode, MailingCountry,
                        MailingCity, HomePhone, MobilePhone, Birthdate, 
                        Ward__c, Primary_care_trust__c, Local_authority__c, 
                        Constituency__c, Salutation, Gender__c 
                from Contact 
                where id = :contactId 
                limit 1];        
    }
    
    private string GetOrgAccountName(Id contactId)
    {
        // Setting the Org from the account object.
        List<Account> OrgAccount = [select id, name from Account where id =:contactId limit 1];        
        return OrgAccount.size()==0 ? ' ' : OrgAccount[0].name; 
    }   
    
    public PageReference switchPerson()
    {               
        // 16383 is the larges number that can be derived from the boolean values of the radio buttons.     
        Integer selected = 16383 - getRadioBinary();
        
        PageReference reference = new  PageReference(string.format(redirectURL, new String[]            
                        { child.Id, master.Id, string.valueof(selected) }));
                        
        reference.setRedirect(true);                
        return reference;
    }
    
    private Integer getRadioBinary()
    {
        Integer selected = 0;
        
        // Calculate selection value before sending email. This number will determine what radio buttons 
        // are selected when viewed by an admin.
        selected = setRadioSelection(13, 8192, selected, removeNullValues(master.Location_of_Consent_Form__c));
        selected = setRadioSelection(12, 4096, selected, convertDate(master.Database_consent_Date__c));
        selected = setRadioSelection(11, 2048, selected, removeNullValues(master.Consent_Status__c));
        selected = setRadioSelection(10, 1024, selected, removeNullValues(master.Diagnosis__c));
        selected = setRadioSelection(9, 512, selected, removeNullValues(master.MobilePhone));
        selected = setRadioSelection(8, 256, selected, removeNullValues(master.HomePhone));
        selected = setRadioSelection(7, 128, selected, removeNullValues(master.MailingPostalCode));
        selected = setRadioSelection(6, 64, selected, removeNullValues(master.MailingCity));
        selected = setRadioSelection(5, 32, selected, removeNullValues(master.MailingStreet));
        selected = setRadioSelection(4, 16, selected, removeNullValues(master.gender__c));
        selected = setRadioSelection(3, 8, selected, removeNullValues(GetOrgAccountName(master.AccountId)));
        selected = setRadioSelection(2, 4, selected, removeNullValues(master.Record_Type_Name__c));
        selected = setRadioSelection(1, 2, selected, convertDate(master.BirthDate));
        selected = setRadioSelection(0, 1, selected, removeNullValues(master.Name));
        
        return selected;    
    }
    
    public PageReference mergePerson()
    {                                                                           
        try 
        {
            // Start transaction
            Savepoint sp = Database.setSavepoint();            
            
            // Add action to history object
            Contact_History__c history = new Contact_History__c();             
            history.Action__c = string.format(mergeMessage, new List<string>{child.id, child.name, master.id, master.name});
            history.Contact_History__c = master.Id;
            history.Date__c = datetime.now().addHours(1);
            history.User__c = [select id, name from User where id = :UserInfo.getUserId() limit 1].Name;                        
            if (history.Action__c != null) insert history;
            
            //move service usages explicitly as they do not move via the merge command
            List<Service_Usage__c> serviceUsage = 
                [Select Id, Name, Service_Field__c, primary_service_user__c 
                 from Service_Usage__c 
                 where primary_service_user__c=:child.id];
             
            if (serviceUsage.size() > 0)
            {
                List<Service_Usage__c> serviceUsageToUpdate = new List<Service_Usage__c>();
                
                // TODO: find a better method to update this data             
                for (Service_Usage__c rec: serviceUsage)
                {
                    System.debug('>>>>>>>>>>>Name:' + rec.Name);
                    System.debug('>>>>>>>>>>>Id:  ' + rec.id);
                    
                    rec.primary_service_user__c = master.id;
                    serviceUsageToUpdate.add(rec);
                }
                
                if (serviceUsageToUpdate.size() > 0)
                {
                    //Update ServiceUsage records.
                    try
                    {                       
                        upsert serviceUsageToUpdate;
                    }
                    catch(Exception ex)
                    {
                        Database.rollback(sp);
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while updating Service Usages.'));                        
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                        return null;
                    }                
                }
            }
            
                        
            /* Added by Gary Dec 2014 */
            
            	Boolean b = mergeParticipants(master, child);
            
            /*End Participant merge	*/
            
            
            //****** ADDED BY IanSm 02/07/14 - START ******
            
            //List of Demographic Information Id's to delete.
            List<Demographic_Information__c> lstTobeDeleted = new List<Demographic_Information__c>();
            
            //Query the Demographic_Information__c sObject and check the (crec) "Record to be Merged" has a demographic Infomation record.
            List<Demographic_Information__c> lstToBeMerged = [SELECT Id FROM Demographic_Information__c WHERE Person__c =: child.Id];
            System.debug('****** The Record to be Merged has: ' + lstToBeMerged.Size() + ' Demographic Info records. ******');
            
            if(lstToBeMerged.Size() > 0){
                //The "Record to be Merged" has a demographic Infomation record related to the Contact record.
                System.debug('****** lstToBeMerged ******' + lstToBeMerged.Size());
    
                //Query the Demographic_Information__c sObject and check the (mrec) "Record to be Merged" has a demographic Infomation record.
                List<Demographic_Information__c> lstMaster = [SELECT Id, Person__c FROM Demographic_Information__c WHERE Person__c =: master.Id];
                System.debug('****** lstMaster ******' + lstMaster.Size());
    
                if(lstMaster.Size() > 0){
                    //Iterate over the lstToBeMerged Collection and add the Demographic_Information__c.Id to a New List (lstTobeDeleted). 
                    for(Demographic_Information__c di : lstToBeMerged){
                            lstTobeDeleted.add(di);
                    }
                    System.debug('****** lstTobeDeleted ******' + lstTobeDeleted.Size());
                    
                    //The "Master Record" & "Record to be Merged" have demographic Infomation records related to the Contact record master & child.
                    //Merge the contacts mrec & crec and re-parent any related records. We can then delete the "Record to be Merged" Demo Info record.
                    //merge mrec crec;
                              
          if(lstToBeDeleted.Size() > 0){
              try{
                  //Attempt to delete the "Record to be Merged" Demographic_Information__c record.
                  delete lstToBeDeleted;
                  System.debug('****** Deleting : ' + lstToBeDeleted.Size() + ' Demo Info Records. ******');
              }
              catch(DmlException ex) {
                  //Process exceptions
                 System.debug('****** An unexpected error has occurred ******: ' + ex.getMessage()); 
                 ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while deleting the "Record to be Merged" Demographic Information record.');
                 ApexPages.addMessage(message);
                 message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
                 ApexPages.addMessage(message);
                 return null;
              }
          }                    
                }
                else{
                    //The "Master Record" doesn't have a demographic Infomation record related to the Contact record.
                    //Merge the contacts mrce & crec and re-parent any related records.
                    //merge mrec crec;
                    
          Set<Id> conIds = new Set<Id>();
          
            //Get the "Master" Demographic_Information__c record and Update the Name (Description) Field.
            List<Demographic_Information__c> lstToUpdate = [SELECT Id, Name, Person__r.Client_reference_number__c FROM Demographic_Information__c WHERE Person__c =: master.Id];
            System.debug('****** lstToUpdate ******' + lstToUpdate.Size());          
          
          for(Demographic_Information__c d : lstToUpdate){
            conIds.add(d.Person__c);
          } 

                    //Add People (Contact) to a Map Collection. 
              Map<String, Contact> contactRTMap = new Map<String, Contact>();
              for (Contact con : [SELECT c.Id, c.Name, c.Client_reference_number__c FROM Contact c WHERE c.Id IN :conIds]){
                  contactRTMap.put(con.Id, con);
              } 

            if(lstToUpdate.Size() > 0){
                //Now need to Update the Name (PersonId) field to the correct PersonId value.
                for(Demographic_Information__c demo : lstToUpdate){
                    demo.Name = contactRTMap.get(demo.Person__c).Client_reference_number__c;
                }
                try{
                    update lstToUpdate;
                    System.debug('****** Updating : ' + lstToUpdate.Size() + ' Demo Info Records. ******');
                }
                catch(DmlException ex) {
                    // Process exceptions
                    System.debug('****** An unexpected error has occurred ******: ' + ex.getMessage()); 
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while Updating the "Master" Demographic Information record.');
                    ApexPages.addMessage(message);
                    message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
                    ApexPages.addMessage(message);
                    return null;                  
                }
            }                    
                }
            }
            //else{
                //The "Record to be Merged" doesn't have a demographic Infomation record related to the Contact record.
                //Merge the contacts mrce & crec and re-parent any related records.
                //merge mrec crec;
            //}
            
            
            //****** ADDED BY IanSm 02/07/14 - END ******       
      
            
            
                     
            boolean hasChanges = false;
            
            if (isDifferent(0, removeNullValues(master.name)))
            {
                master.FirstName = child.FirstName;
                master.LastName = child.LastName;       
                hasChanges = true;  
            }
            
            if (isDifferent(1, convertDate(master.BirthDate)))
            {
                master.BirthDate = child.BirthDate; 
                hasChanges = true;          
            }
            
            if (isDifferent(2, removeNullValues(master.Record_Type_Name__c)))
            {
                master.RecordTypeId = child.RecordTypeId;
                hasChanges = true;              
            }
            
            if (isDifferent(3, GetOrgAccountName(master.AccountId)))
            {
                master.AccountId = child.AccountId;
                hasChanges = true;              
            }       
            
            if (isDifferent(4, removeNullValues(master.gender__c)))
            {
                master.gender__c = child.gender__c;
                hasChanges = true;              
            }           
            
            if (isDifferent(5, removeNullValues(master.MailingStreet)))
            {
                master.MailingStreet = child.MailingStreet;
                hasChanges = true;  
            }
            
            if (isDifferent(6, removeNullValues(master.MailingCity)))
            {
                master.MailingCity = child.MailingCity;
                hasChanges = true;  
            }
            
            if (isDifferent(7, removeNullValues(master.MailingPostalCode)))
            {
                master.MailingPostalCode = child.MailingPostalCode;
                hasChanges = true;  
            }
            
            if (isDifferent(8, removeNullValues(master.HomePhone)))
            {
                master.HomePhone = child.HomePhone;
                hasChanges = true;  
            }
            
            if (isDifferent(9, removeNullValues(master.MobilePhone)))
            {               
                master.MobilePhone = child.MobilePhone;
                hasChanges = true;  
            }
            
            if (isDifferent(10, removeNullValues(master.Diagnosis__c)))         
            {
                master.Diagnosis__c = child.Diagnosis__c;
                hasChanges = true;  
            }
            
            if (isDifferent(11, removeNullValues(master.Consent_Status__c)))
            {
                master.Consent_Status__c = child.Consent_Status__c;
                hasChanges = true;  
            } 
            
            if (isDifferent(12, convertDate(master.Database_consent_Date__c)))          
            {
                master.Database_consent_Date__c = child.Database_consent_Date__c;
                hasChanges = true;  
            }
            
            if (isDifferent(13, removeNullValues(master.Location_of_Consent_Form__c)))
            {
                master.Location_of_Consent_Form__c = child.Location_of_Consent_Form__c;
                hasChanges = true;  
            } 

            if (hasChanges) { upsert master; }
    
            // Merge the two records together
            Contact mrec = [select id  from Contact where id =:master.id LIMIT 1];
            Contact crec = [select id  from Contact where id =:child.id LIMIT 1];    
              
            merge mrec crec;
        } 
        catch (DmlException ex) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while merging the records.'));          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
          
        return new Pagereference('/' + master.Id);
    }
    
    public PageReference requestMergePerson()
    {
        Integer selected = getRadioBinary();            
                        
        // Build text for email from static templates
        string emailSubject = string.format(emailTitle, new List<string> {master.id, master.Client_reference_number__c, 
                                        child.id, child.Client_reference_number__c});                                                
        string plainText    = string.format(plainBody, new List<string> { master.id, child.id, string.valueof(selected)});  
        string htmlText     = string.format(htmlBody, new List<string> {master.Client_reference_number__c, 
                                        child.Client_reference_number__c, master.Id, child.id, 
                                        URL.getSalesforceBaseUrl().getHost(), string.valueof(selected)});       
                                                           
        string replyEmailAddress = [select id, email from User where id = :UserInfo.getUserId() limit 1].email;
        
        // Prepare email object            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
        mail.setToAddresses(toEmailAddress);
        mail.setReplyTo(replyEmailAddress);    
        mail.setSenderDisplayName(senderName);
        mail.setSubject(emailSubject);
        mail.setBccSender(true);
        mail.setUseSignature(false);       
        mail.setPlainTextBody(plainText);       
        mail.setHtmlBody(htmlText);
        
        try 
        {
            //send email
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            mergeRequested = true;
        } 
        catch (Exception ex) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while requesting the merge.'));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
            
        return null;
    }   
    
    private Boolean mergeParticipants(Contact master, Contact child)
    {
    	/******* Dec 2014 Merge Participants ******/
                       
        //Check the Master has a Participant record.
        List<UI_Participant__c> lisChildParticipants = [SELECT Id FROM UI_Participant__c WHERE Contact__c =: child.Id];
        system.debug('Merge Participants : Child Id' + lisChildParticipants.size());
        
        UI_Participant__c pChild = null;
        UI_Participant__c pMaster = null;
        
        //If the child has no participant, then just exit
        if (lisChildParticipants.size()==0) {
        	 system.debug('Merge Participants : No Child Participant');
        	 return true; 
        }

		try {
            
            List<String> lisMasterIds = new List<String>();
            
	        //If the Master has no participant, move the child to the parent and exit   
	        List<UI_Participant__c> lisMasterParticipants = [SELECT Id, Contact__c FROM UI_Participant__c WHERE Status__c !='Merged' and Contact__c =: master.Id];
	        if (lisMasterParticipants.size()==0) { 
	        	
	        	/*There should only ever be one Participant that is not merged */
	        	for (UI_Participant__c pC : lisChildParticipants) {
		        			        	
		        	/* Update the Contact to the new Master */ 
		        	pC.Contact__c = master.id;
		        	if (pC.Status__c=='Active') {	 
		        		lisMasterIds.add(master.id);       			        				
		        	}		        	        	
	        	}   
	        	
	        	update lisChildParticipants;    	
	        	UIUtils.doSharePersonRecords(lisMasterIds);
	        		      		
	      		/* Unshare the old Child */ 
	        	List<String> lisChildIds = new List<String>();
	        	lisChildIds.add(child.id);	        	
	        	UIUtils.doUnSharePersonRecords(lisChildIds);
	        		        	
	        	return true; 
	        	
	        } else {
	          pMaster = lisMasterParticipants[0];	
	        }
	        
	        /* At this point, both the master and the child have a Participant
	           - move the child to the parent and set status to "Merged"
	           - move all the participation to the master participant
	           
	           The query fetches all Participation that is linked to a Participant linked to the relevant child Person record	           
	        */	        	        	        
	        List<UI_Activity_Participation__c> lisParticipation = [select id, UI_Participant__c from UI_Activity_Participation__c where UI_Participant__r.Contact__c = :child.id];
	        for (UI_Activity_Participation__c pt : lisParticipation) {        	
	        	pt.UI_Participant__c = pMaster.id;
	        }
	
	        update lisParticipation;
	        
	        // The child will need to be deleted by hand once the 
	        // data has been moved over to the master
	        for (UI_Participant__c pC : lisChildParticipants) {
	        	pC.Contact__c = master.id;
	       		pC.Status__c = 'Merged';
	       	}
	        update lisChildParticipants;   
	        
		} catch (Exception ex) {			
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred in the Participant records while merging the contacts.'));          
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
           return false;        
		}
		
		return true;
                	
    }
    
}