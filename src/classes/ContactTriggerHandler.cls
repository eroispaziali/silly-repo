public class ContactTriggerHandler {
/********************************************************************************
* To stop triggers firing more than once, put them in a handler class.
*
* Object: Contact
* Mike Tinson
* 31 October 2012
*    12 Feb 2014 Add calls to UpdateLastTransaction routine
*    09 Jan 2015 Added calls to splitpeopleaddresses and calls to setdefaultaccount
********************************************************************************/
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean firstRun = true;
    public static boolean firstRunAfter = true;
    private Id pwd; 
    private Id carer;
    private Id friend;
    private boolean b_gotrecordtypes = false;
    
    public ContactTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
        
/**
    public void OnBeforeInsert(Contact[] newContacts){
        
    
        //Example usage
        //for(Contact newContact : newContacts){
        //SetDefaultAccount(newContact);
        //Contact_WithdrawConsent_beforeUpdate(newContact);
        //ContactDeceased_beforeUpdate(newContact);
        //}
    }
**/
public void SetDefaultAccount(List<Contact> insertedContacts ){
    
    String RT_CON_PWD = 'Person_with_dementia';
    String RT_CON_CARER = 'Carer';
    String RT_CON_FPWD = 'Friend_or_Family_of_Person_with_Dementia';
    String RT_CON_COLL = 'Collector';
    
    //Add Contact RecordTypes to a Map Collection. 
    Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
    for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
        contactRTMap.put(rt.DeveloperName, rt);
    }    
    
    List<Account> defaultAcc = [SELECT Id FROM Account WHERE Name = 'Alzheimers Society' LIMIT 1];
    system.debug('****** defaultAcc: ' + defaultAcc.size() + ' ******');
    
    for(Contact con : insertedContacts){
        if (con.AccountId == NULL &&(con.RecordTypeId == contactRTMap.get(RT_CON_PWD).Id || con.RecordTypeId == contactRTMap.get(RT_CON_CARER).Id || con.RecordTypeId == contactRTMap.get(RT_CON_FPWD).Id
                                    || con.RecordTypeId == contactRTMap.get(RT_CON_COLL).Id)){
        
            try{    
                if(defaultAcc.size() > 0){
                    con.AccountId = defaultAcc[0].Id;
                }
            }catch(Exception e){
                // do nothing
            }
        }
    }
    
}

public void splitPeopleAddresses (List<Contact> updatedContact,Map<ID,Contact> oldContact) {
    /*
     * Written By Lakshmi Rajendram
     *
     * Split the MailingStreet
     * on the services record to 
     * Street Line 1,Street Line 2,Street Line 3
     * If there is a MailingStreet with more than 3 lines then the live 4 onward
     * will be inserted on to Street Line 3 (comma seperated)
     *
     */

    List<Contact> contactsToUpdate = new List<Contact>();
    String AddressLine1 = '';
    String AddressLine2 = '';
    String AddressLine3 = '';
    String AddressLine4 = '';
    Boolean FirstAddressLineIsUsed = false;
    Boolean SecondAddressLineIsUsed = false;
    Boolean UpdateNeededOnAddress = false;

  //List<Contact> servicesList = [SELECT MailingStreet, Street_Line_1__c, Street_Line_2__c,Street_Line_3__c,Street_Line_4__c FROM Contact WHERE Id IN :Trigger.newMap.keySet()];
    for(Contact s : updatedContact){
        //Contact u_serv = [SELECT MailingStreet, Street_Line_1__c, Street_Line_2__c,Street_Line_3__c,Street_Line_4__c FROM Contact WHERE Id =: s.Id ];
 if (oldContact==null) {
           UpdateNeededOnAddress = s.MailingStreet != null;
}else{

        Contact olds = oldContact.get(s.ID); 
            
            UpdateNeededOnAddress = ((s.MailingStreet != olds.MailingStreet && s.MailingStreet != null) ||  ( s.Street_Line_1__c==null &&s.MailingStreet!=null)||(olds.MailingStreet ==null) ||(s.MailingStreet ==null)) ;
        }

        if (UpdateNeededOnAddress ) {    
            // initiate temp variables
            AddressLine1 = '';
            AddressLine2 = '';
            AddressLine3 = '';
            AddressLine4 = '';
            String streetAddress='';
            String[] sAddrList;
            FirstAddressLineIsUsed = false;
            SecondAddressLineIsUsed = false;
            
            If(s.MailingStreet!=null){
            streetAddress=s.MailingStreet.replace(',','\n');
            sAddrList = streetAddress.split('\n');
            
            
            system.debug('split address'+sAddrList);
            for (Integer i = 0; i < sAddrList.size(); i++) {
                if (i == 0) { // first item work first
                    if (sAddrList[0].length() > 80) {
                        AddressLine1 = sAddrList[0].substring(0,80);
                        AddressLine2 = sAddrList[0].substring(80);
                        FirstAddressLineIsUsed = true;
                    } else {
                        AddressLine1 = sAddrList[0];
                    }
                }
                // work with the next item on the list:
                if (i ==1) {
                    if ((AddressLine2 + (AddressLine2.length()>0?', ':'') + sAddrList[1]).length()< 80) { 
                        AddressLine2 = AddressLine2 + (AddressLine2.length()>0?', ':'') + sAddrList[1];
                        SecondAddressLineIsUsed = true;
                        system.debug('address line 2'+AddressLine2);
                    } else if(sAddrList[1].length() > 80){
                        AddressLine2 = AddressLine2 + (AddressLine2.length()>0?', ':'')+sAddrList[1].substring(0,80);
                        AddressLine3 = sAddrList[1].substring(80);
                    }else if(sAddrList[1].length() < 81){
                        AddressLine2 =sAddrList[1];
                    }
                }



                if (i==2 ){

                    if ((AddressLine3 + (AddressLine3.length()>0?', ':'') + sAddrList[2]).length() < 80) { 
                        AddressLine3 = AddressLine3 + (AddressLine3.length()>0?', ':'') + sAddrList[2];
                        system.debug('address line 3'+AddressLine3);
                    } else if(sAddrList[2].length() > 80){
                        AddressLine3 = sAddrList[2].substring(0,80);
                        AddressLine4 = sAddrList[2].substring(80);
                    }else if(sAddrList[2].length() < 81){
                        AddressLine3 =sAddrList[2];
                    }
                }
                if (i+3<sAddrList.size()){

                    if ((AddressLine4 + (AddressLine4.length()>0?', ':'') + sAddrList[i+3]).length() < 80) { 
                        AddressLine4 = AddressLine4 + (AddressLine4.length()>0?', ':'') + sAddrList[i+3];
                        system.debug('address line 4'+AddressLine4);
                    } else{

                        AddressLine4 = sAddrList[i+3];//.substring(0,80);


                    }
                }  

            }
        
           
           s.Street_Line_1__c = AddressLine1;
           s.Street_Line_2__c = AddressLine2;
           s.Street_Line_3__c = AddressLine3;
           s.Street_Line_4__c = AddressLine4;
        
           contactsToUpdate.add(s);

          }
          else{
          
           s.Street_Line_1__c = '';
           s.Street_Line_2__c = '';
           s.Street_Line_3__c = '';
           s.Street_Line_4__c = '';
        
          contactsToUpdate.add(s);
          
          
          }
             
         }   
        }
        
      }  
         
   
        
    public void OnAfterInsert(Contact[] newContacts, Map<ID, Contact> ContactMap){
        UpdateLastTransactionDate (newContacts);    
    }
    
    @future public static void OnAfterInsertAsync(Set<ID> newContactIDs){
        //Example usage
        List<Contact> newContacts = [select Id, Name from Contact where Id IN :newContactIDs];
    }

/**
  public void OnAfterInsert(Contact[] Contacts, Contact[] updatedContacts, Map<ID, Contact> ContactMap){
    if (firstRun) {
        firstRun = false;
        System.debug('****** ContactTriggerHandler.OnAfterInsert  ******');
        
        }
    else {
        System.debug('Already ran!');
        return;
        }
    } 
**/
    public void OnBeforeUpdate(Contact[] oldContacts, Contact[] updatedContacts, Map<ID, Contact> OldContactMap ,Map<ID, Contact> ContactMap){
        //Example Map usage
        //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where ContactId IN :ContactMap.keySet()] );
        if (firstRun) {
            firstRun = false;
            for(Contact newContact : updatedContacts){
        //  if(newContact.AnnualRevenue == null){
        //      newContact.AnnualRevenue.addError('Missing annual revenue');
        //  }
            Contact_WithdrawConsent_beforeUpdate(newContact);
            ContactDeceased_beforeUpdate(newContact);
            ContactBeforeUpdateRecordTypeChange (OldContactMap, newContact);
            UpdateContactHistory (OldContactMap, newContact);
            UpdateServiceUsageName (OldContactMap, newContact);
 
            }
            UpdateLastTransactionDate (updatedContacts);
        }
        else {
            System.debug('Already ran!');
            return;
            }
        }
/**    
    public void OnAfterUpdate(Contact[] oldContacts, Contact[] updatedContacts, Map<ID, Contact> ContactMap){
    if (firstRunAfter) {
        firstRunAfter= false;

        System.debug('****** ContactTriggerHandler.OnAfterUpdate  ******');
        

        }
    else {
        System.debug('Already ran!');
        return;
        }
    }
**/
/**    
    @future public static void OnAfterUpdateAsync(Set<ID> updatedContactIDs){
        List<Contact> updatedContacts = [select Id, Name from Contact where Id IN :updatedContactIDs];
    }
**/
    
    public void OnBeforeDelete(Contact[] ContactsToDelete, Map<ID, Contact> ContactMap){
        for(Contact oldContact : ContactsToDelete){
            ContactBeforeDeleteRemoveServiceUsage (oldContact);
        }
        UpdateLastTransactionDate (ContactsToDelete);
    }

  
/**
    public void OnAfterDelete(Contact[] deletedContacts, Map<ID, Contact> ContactMap){
        System.debug('****** ContactTriggerHandler.OnAfterUpdate  ******');
    
        List<Id> ContactIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        for(Contact df : deletedContacts){
            ContactIds.add(df.Id);
        }
        System.debug('****** ContactIds.Size ******' + ContactIds.Size());

        if(ContactIds.isEmpty() == false){
          
          //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
          LastTransactionDateLookup handler = new LastTransactionDateLookup();
          handler.UpdateLastTransactionDate(ContactIds[0], dtLastTransactionDate); 
          
        }
    }
**/
/**    
    @future public static void OnAfterDeleteAsync(Set<ID> deletedContactIDs){
        
    }
**/
/**    
    public void OnUndelete(Contact[] restoredContacts){
        
    }
**/
/**   
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    }
**/
/************************************************************
* getRecordTypes
************************************************************/
    private void getRecordTypes(){
        System.debug('+++++++++++++++++++++++getRecordTypes');
        b_gotrecordtypes = true;
        try {
        pwd = [select Id from RecordType where Name = 'Person with dementia'].Id;
        carer = [select Id from RecordType where Name = 'Carer of Person with Dementia'].Id;
        friend = [select Id from RecordType where Name = 'Friend or Family of Person with Dementia'].Id;
    } catch (Exception e) {
        // do nothing
        }
    }
/************************************************************
* SetDefaultAccount
************************************************************/
/**
** Disabled due to clash with Datascout Trigger
**    private void SetDefaultAccount(Contact newContact){
**    System.debug('+++++++++++++++++++++++SetDefaultAccount');
**    if (!b_gotrecordtypes) {
**        getrecordtypes();
**    }
**        if (newContact.AccountId == NULL && (newContact.RecordTypeId == pwd || newContact.RecordTypeId == carer  || newContact.RecordTypeId == friend )) {
**            try {
**                newContact.AccountId = [select Id from Account
**                                where Name = 'Alzheimers Society'].Id;
**            } catch(Exception e) {
**                // do nothing
**            }
**        }
**    }
**/
/************************************************************
* Contact_WithdrawConsent_beforeUpdate
************************************************************/
    private void Contact_WithdrawConsent_beforeUpdate(Contact newContact){
    String message;
    try{
    System.debug('+++++++++++++++++++++++Contact_WithdrawConsent_beforeUpdate');
    message = newContact.rrpu__Alert_Message__c;

    //If consentstatus == Withdrawn, set the 'Do Not Contact' flag to true 
    if(newContact.Consent_Status__c=='Withdrawn'){
        newContact.DoNotCall = true;
        if (message==null) {
            message = 'Consent Withdrawn - Do Not Contact. ';
        }else if (message!=null && !message.contains('Consent Withdrawn - Do Not Contact.') && message.length()<205) {
            message += ' Consent Withdrawn - Do Not Contact.';
        }else if(!newContact.DoNotCall && message!=null){
            message = message.replace('Consent Withdrawn - Do Not Contact.', '');
        }
    }
    //if consent is not withdrawn, remove the text from the message
    if(newContact.Consent_Status__c!='Withdrawn'){
        if (message!=null && message.contains('Consent Withdrawn - Do Not Contact.')) {
            message = message.replace('Consent Withdrawn - Do Not Contact.', '');
        }
    }
    //for Do Not Contact
    if (newContact.DoNotCall && newContact.Deceased__c==false && message==null) {
        message = 'Person does not wish to be contacted.';
    }else if (newContact.DoNotCall && newContact.Deceased__c==false && message!=null && !message.contains('Person does not wish to be contacted.') && message.length()<205) {
        message += ' Person does not wish to be contacted.';
    }else if(!newContact.DoNotCall && newContact.Deceased__c==false && message!=null){
        message = message.replace('Person does not wish to be contacted.', '');
    }
    }catch(Exception e){
    //maximum length exceeded for rrpu_alert_message__c 
    }
    newContact.rrpu__Alert_Message__c = message;
    }
/************************************************************
* ContactDeceased_beforeUpdate
************************************************************/
    private void ContactDeceased_beforeUpdate(Contact newContact){
    String message;
    try{
        System.debug('+++++++++++++++++++++++ContactDeceased_beforeUpdate');
        message = newContact.rrpu__Alert_Message__c;
        //If deceased is true, set the 'Do Not Contact' flag to true 
        if(newContact.Deceased__c==true){
            newContact.DoNotCall = true;
            if (message==null) {
                message = 'Person has died - Do Not Contact. ';
            }else if (message!=null && !message.contains('Person has died - Do Not Contact.') && message.length()<205) {
                message += ' Person has died - Do Not Contact.';
            }else if(!newContact.DoNotCall && message!=null){
                message = message.replace('Person has died - Do Not Contact.', '');
            }
            //change 175 - do not suggest that deceased wishes any further contacts with us
            if (message!=null && message.contains('Person does not wish to be contacted.')){
                message = message.replace('Person does not wish to be contacted.','');}
        }
        //if consent is not withdrawn, remove the text from the message
        if(newContact.Deceased__c==false){
            if (message!=null && message.contains('Person has died - Do Not Contact.')) {
                message = message.replace('Person has died - Do Not Contact.', '');
            }
        }
    }catch(Exception e){
        //maximum length exceeded for rrpu_alert_message__c 
    }
    System.debug('+++++++++++++++++++++++ContactDeceased_beforeUpdate after- ' + message );
    newContact.rrpu__Alert_Message__c = message;
    }
/********************************************************************************
* If record type is changed from either Person with Dementia or Carer of person with dementia
* to Friend or Family of Person with Dementia check that there are no Service Usage records.  
* If so stop the update.
*
* Mike Tinson  18-Oct-2012
********************************************************************************/
private void ContactBeforeUpdateRecordTypeChange (Map<ID, Contact> OldContactMap , Contact newContact){

    System.debug('+++++++++++++++++++++++ContactBeforeUpdateRecordTypeChange');
    if (!b_gotrecordtypes) {
        getrecordtypes();
    }
    if (newContact.RecordTypeId == friend){
        Contact oldContact = OldContactMap.get(newContact.ID);
        if(oldContact!=null && newContact!=null){
          if(oldContact.RecordTypeId != newContact.RecordTypeId){
            List<Service_Usage__c> lstServiceUsages = new List<Service_Usage__c>([Select Id from 
            Service_Usage__c where Primary_Service_User__c =:newContact.id ]);

            system.debug('#################lstServiceUsages.size() ##################'+lstServiceUsages.size() );
            if(lstServiceUsages.size()>0) {
                newContact.addError('Cannot change record type as Service Usage records exist');
              
          }
        }
       }
    }
}
/********************************************************************************
* UpdateServiceUsageName 
* Need to update service usage name if first or second name changes (or 
********************************************************************************/ 

private void UpdateServiceUsageName (Map<ID, Contact> OldContactMap, Contact newContact){
    System.debug('+++++++++++++++++++++++UpdateServiceUsageName');
    if (!b_gotrecordtypes) {
        getrecordtypes();
    }
    if ((newContact.RecordTypeId == pwd)||(newContact.RecordTypeId == carer)){
        Contact oldContact = OldContactMap.get(newContact.ID);
        if(oldContact!=null && newContact!=null){
            if ((oldContact.FirstName != newContact.FirstName)||(oldContact.LastName != newContact.LastName)){
                List<Service_Usage__c> lstServiceUsages = new List<Service_Usage__c>();
                Map<Id,Service_Usage__c> lstServUsage = new Map<Id,Service_Usage__c>([Select Name,Service_Field__c,Service_Field__r.Name,
                    Service_Type__c,Date_of_last_Activity__c,Referral_Date__c,Closure_Date__c,Risk_Identified__c,Public_Alert_Message_Required__c  
                    from Service_Usage__c where Primary_Service_User__c =:newContact.id]);
                        
                system.debug('#################lstServUsage.size() ##################'+lstServUsage.size() );    
                //This is Seperate Class which run query under User privileges.
                ContactServiceUsageWithSharing clsAccessible = new ContactServiceUsageWithSharing();
        
                //Returned accessible/visible ServiceUsage records Ids.
                Set<Id> setAccessibleRecs = clsAccessible.getAccessibleRecords(lstServUsage.keyset());
        
                //Iterate to populate special Inner Class with flag to say a ServiceUsage record is accessible to user.
                for(Service_Usage__c rec: lstServUsage.Values())
                    {
                        if (setAccessibleRecs.contains(rec.id))
                        { 
                            lstServiceUsages.add(rec);
                        }
                    }
                system.debug('#################lstServiceUsages.size() ##################'+lstServiceUsages.size() );
                // only update if we have access to all service records (otherwise we get a sharing error)
                if((lstServiceUsages.size()>0)) {
    
                Savepoint sp = Database.setSavepoint();
                try
                {
                   upsert lstServiceUsages;
                    }
                catch(Exception ex){
                    Database.rollback(sp);throw ex;}    
                    }
                }
            }
     }    
}

/********************************************************************************
* UpdateContactHistory
********************************************************************************/ 
private void UpdateContactHistory (Map<ID, Contact> OldContactMap , Contact newContact){
    System.debug('+++++++++++++++++++++++UpdateContactHistory');
    Contact_History__c history = new Contact_History__c();
    boolean isChanged;
    if(newContact.testFlag__c != false) {
        //Contact oldContact = Trigger.oldMap.get(newContact.ID);
        Contact oldContact = OldContactMap.get(newContact.ID);
        System.debug('11111111111111111111 newContact: '+newContact);
        System.debug('22222222222222222222 oldContact: '+oldContact);
        System.debug('33333333333333333333 history: '+history);
        if(oldContact!=null && newContact!=null){
            if (newContact.rrpu__Alert_Message__c != oldContact.rrpu__Alert_Message__c) {
                history.Alert_Message__c = newContact.rrpu__Alert_Message__c;
                if(newContact.rrpu__Alert_Message__c==null || newContact.rrpu__Alert_Message__c=='')
                    history.Action__c = 'Deleted <b>Alert Message</b>'+ '<br/>';
                else if(oldContact.rrpu__Alert_Message__c==null || oldContact.rrpu__Alert_Message__c=='')
                    history.Action__c = 'Added <b>Alert Message</b> '+ newContact.rrpu__Alert_Message__c + '<br/>';
                else
                    history.Action__c = 'Changed <b>Alert Message</b>'+ ' from '+ oldContact.rrpu__Alert_Message__c +' to '+ newContact.rrpu__Alert_Message__c + '<br/>';
                isChanged =  true;
            }
            if (newContact.Birthdate != oldContact.Birthdate) {
                //history.Birthdate = newContact.Birthdate;
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Date of Birth</b> from '+oldContact.Birthdate+ ' to '+newContact.Birthdate + '<br/>';
                else
                    history.Action__c = 'Changed <b>Date of Birth</b> from '+oldContact.Birthdate+ ' to '+newContact.Birthdate + '<br/>';
                isChanged =  true;
            }
            if (newContact.Date_of_diagnosis__c != oldContact.Date_of_diagnosis__c) {
                history.Date_of_Diagnosis__c = newContact.Date_of_diagnosis__c;
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Date of Diagnosis</b> from '+oldContact.Date_of_diagnosis__c+ ' to '+newContact.Date_of_diagnosis__c + '<br/>';
                else
                    history.Action__c = 'Changed <b>Date of Diagnosis</b> from '+oldContact.Date_of_diagnosis__c+ ' to '+newContact.Date_of_diagnosis__c + '<br/>';
                isChanged =  true;
            }
            if (newContact.Diagnosis__c != oldContact.Diagnosis__c) {
                history.Diagnosis__c = String.valueOf(newContact.Diagnosis__c);
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Dementia Diagnosis</b> from '+oldContact.Diagnosis__c+ ' to '+newContact.Diagnosis__c + '<br/>';
                else
                    history.Action__c = 'Changed <b>Dementia Diagnosis</b> from '+oldContact.Diagnosis__c+ ' to '+newContact.Diagnosis__c + '<br/>';
                isChanged =  true;
            }
            if(newContact.Diagnosis_made_by__c != oldContact.Diagnosis_made_by__c){
                history.Diagnosis_made_by__c = String.valueOf(newContact.Diagnosis_made_by__c);
                Contact oldUser;
                Contact newUser;
                if(oldContact.Diagnosis_made_by__c!=null)
                    oldUser = [Select u.Name, u.LastName, u.Id, u.FirstName From Contact u where id = :oldContact.Diagnosis_made_by__c];
                
                if(newContact.Diagnosis_made_by__c!=null)
                    newUser = [Select u.Name, u.LastName, u.Id, u.FirstName From Contact u where id = :newContact.Diagnosis_made_by__c];
                
                System.debug('oldUser: '+oldUser);
                System.debug('newUser: '+newUser);
                if(history.Action__c!=null){
                    history.Action__c += 'Changed <b>Diagnosis made by</b> from ';
                    if(oldUser!=null)
                        history.Action__c += + ' '+oldUser.FirstName+ ' '+oldUser.LastName;
                    else
                        history.Action__c += ' Nothing ';
                    if(newUser!=null)
                        history.Action__c += ' to '+newUser.FirstName+ ' '+newUser.LastName + '<br/>';
                    else
                        history.Action__c += ' to Nothing ';
                }else{
                    //history.Action__c = 'Changed <b>Diagnosis made by</b> from '+oldUser.FirstName+ ' '+oldUser.LastName+ ' to '+newContact.FirstName+ ' '+newContact.LastName + '<br/>';
                    history.Action__c = 'Changed <b>Diagnosis made by</b> from ';
                    if(oldUser!=null)
                        history.Action__c += + ' '+oldUser.FirstName+ ' '+oldUser.LastName;
                    else
                        history.Action__c += ' Nothing ';
                    if(newUser!=null)
                        history.Action__c += ' to '+newUser.FirstName+ ' '+newUser.LastName + '<br/>';
                    else
                        history.Action__c += ' to Nothing ';
                }
                isChanged =  true;
            }
            if(newContact.Firstname != oldContact.FirstName){
                history.Firstname__c = String.valueOf(newContact.Firstname);
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>First Name</b> from '+oldContact.FirstName+ ' to '+newContact.FirstName + '<br/>';
                else
                    history.Action__c = 'Changed <b>First Name</b> from '+oldContact.FirstName+ ' to '+newContact.FirstName + '<br/>';
                isChanged =  true;
            }
            if(newContact.LastName != oldContact.LastName){
                history.Lastname__c = String.valueOf(newContact.LastName);
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Last Name</b> from '+oldContact.LastName+ ' to '+newContact.LastName + '<br/>';
                else
                    history.Action__c = 'Changed <b>Last Name</b> from '+oldContact.LastName+ ' to '+newContact.LastName + '<br/>';
                isChanged =  true;
            }
            if(newContact.MailingStreet != oldContact.MailingStreet || newContact.MailingCity != oldContact.MailingCity
                    || newContact.MailingState != oldContact.MailingState || newContact.MailingCountry != oldContact.MailingCountry
                    || newContact.MailingPostalCode != oldContact.MailingPostalCode){
                history.MailingStreet__c = String.valueOf(newContact.MailingStreet);
                history.MailingCity__c = String.valueOf(newContact.MailingCity);
                history.MailingState__c = String.valueOf(newContact.MailingState);
                history.MailingCountry__c = String.valueOf(newContact.MailingCountry);
                history.MailingPostalCode__c = String.valueOf(newContact.MailingPostalCode);
                if(history.Action__c!=null){
                    history.Action__c += 'Changed <b>Address</b> from '+ '<br/>';
                }else{
                    history.Action__c = 'Changed <b>Address</b> from '+ '<br/>';}                    
                if(oldContact.MailingStreet!=null) history.Action__c += '  '+oldContact.MailingStreet+ '<br/>';
                if(oldContact.MailingCity!=null) history.Action__c += '  '+oldContact.MailingCity+ '<br/>';
                if(oldContact.MailingState!=null) history.Action__c += '  '+oldContact.MailingState+ '<br/>';
                if(oldContact.MailingCountry!=null) history.Action__c += '  '+oldContact.MailingCountry+ '<br/>';
                if(oldContact.MailingPostalCode!=null) history.Action__c += '  '+oldContact.MailingPostalCode+ '<br/>';
                if(newContact.MailingStreet!=null) history.Action__c += ' to '+newContact.MailingStreet + '<br/>';
                if(newContact.MailingCity!=null) history.Action__c += ' '+newContact.MailingCity + '<br/>';
                if(newContact.MailingState!=null) history.Action__c += ' '+newContact.MailingState + '<br/>';
                if(newContact.MailingCountry!=null) history.Action__c += ' '+newContact.MailingCountry + '<br/>';
                if(newContact.MailingPostalCode!=null) history.Action__c += ' '+newContact.MailingPostalCode + '<br/>';
                isChanged =  true;
            }
            if(newContact.MailingCity != oldContact.MailingCity){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>City</b> from '+oldContact.MailingCity+ ' to '+newContact.MailingCity + '<br/>';
                else
                    history.Action__c = 'Changed <b>City</b> from '+oldContact.MailingCity+ ' to '+newContact.MailingCity + '<br/>';
                isChanged =  true;
            }
            if(newContact.MailingState != oldContact.MailingState){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>County</b> from '+oldContact.MailingState+ ' to '+newContact.MailingState + '<br/>';
                else
                    history.Action__c = 'Changed <b>County</b> from '+oldContact.MailingState+ ' to '+newContact.MailingState + '<br/>';
                isChanged =  true;
            }
            if(newContact.MailingCountry != oldContact.MailingCountry){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Country</b> from '+oldContact.MailingCountry+ ' to '+newContact.MailingCountry + '<br/>';
                else
                    history.Action__c = 'Changed <b>Country</b> from '+oldContact.MailingCountry+ ' to '+newContact.MailingCountry + '<br/>';
                isChanged =  true;
            }
            if(newContact.MailingPostalCode != oldContact.MailingPostalCode){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Post Code</b> from '+oldContact.MailingPostalCode+ ' to '+newContact.MailingPostalCode + '<br/>';
                else
                    history.Action__c = 'Changed <b>Post Code</b> from '+oldContact.MailingPostalCode+ ' to '+newContact.MailingPostalCode + '<br/>';
                isChanged =  true;
            }
            if(newContact.Service_user_aware_of_diagnosis__c != oldContact.Service_user_aware_of_diagnosis__c){
                //history.Service_User_aware_of_diagnosis__c = newContact.Service_user_aware_of_diagnosis__c;
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Service User aware of diagnosis</b> from '+oldContact.Service_user_aware_of_diagnosis__c+ ' to '+newContact.Service_user_aware_of_diagnosis__c + '<br/>';
                else
                    history.Action__c = 'Changed <b>Service User aware of diagnosis</b> from '+oldContact.Service_user_aware_of_diagnosis__c+ ' to '+newContact.Service_user_aware_of_diagnosis__c + '<br/>';
                isChanged =  true;
            }
            if(newContact.Specialist_Communication_Needs__c != oldContact.Specialist_Communication_Needs__c){
                //history.Specialist_Communication_Needs__c = String.valueOf(contact.Specialist_Communication_Needs__c);
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Specialist Communication Needs</b>'+ '<br/>';
                else
                    history.Action__c = 'Changed <b>Specialist Communication Needs</b>'+ '<br/>';
                isChanged =  true;
            }
            if(newContact.Consent_Status__c != oldContact.Consent_Status__c){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Consent Status</b> from '+ oldContact.Consent_Status__c+ ' to '+newContact.Consent_Status__c +'<br/>';
                else
                    history.Action__c = 'Changed <b>Consent Status</b> from '+ oldContact.Consent_Status__c+ ' to '+newContact.Consent_Status__c +'<br/>';
                isChanged =  true;
            }
            if(newContact.Database_consent_Date__c != oldContact.Database_consent_Date__c){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Date consent obtained</b> from '+ oldContact.Database_consent_Date__c+ ' to '+newContact.Database_consent_Date__c +'<br/>';
                else
                    history.Action__c = 'Changed <b>Date consent obtained</b> from '+ oldContact.Database_consent_Date__c+ ' to '+newContact.Database_consent_Date__c +'<br/>';
                isChanged =  true;
            }
            if(newContact.Date_of_Change_of_Living_Arrangements__c != oldContact.Date_of_Change_of_Living_Arrangements__c){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Date of Change of Living Arrangements</b> from '+ oldContact.Date_of_Change_of_Living_Arrangements__c+ ' to '+newContact.Date_of_Change_of_Living_Arrangements__c +'<br/>';
                else
                    history.Action__c = 'Changed <b>Date of Change of Living Arrangements</b> from '+ oldContact.Date_of_Change_of_Living_Arrangements__c+ ' to '+newContact.Date_of_Change_of_Living_Arrangements__c +'<br/>';
                isChanged =  true;
            }
            if(newContact.Deceased_Date__c != oldContact.Deceased_Date__c){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Deceased Date</b> from '+ oldContact.Deceased_Date__c+ ' to '+newContact.Deceased_Date__c +'<br/>';
                else
                    history.Action__c = 'Changed <b>Deceased Date</b> from '+ oldContact.Deceased_Date__c+ ' to '+newContact.Deceased_Date__c +'<br/>';
                isChanged =  true;
            }
            if(newContact.Key_Health_Issues__c != oldContact.Key_Health_Issues__c){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Key Health Issues</b> from '+ oldContact.Key_Health_Issues__c+ ' to '+newContact.Key_Health_Issues__c +'<br/>';
                else
                    history.Action__c = 'Changed <b>Key Health Issues</b> from '+ oldContact.Key_Health_Issues__c+ ' to '+newContact.Key_Health_Issues__c +'<br/>';
                isChanged =  true;
            }
            if(newContact.Location_of_Consent_Form__c != oldContact.Location_of_Consent_Form__c){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Location of Consent Form</b> from '+ oldContact.Location_of_Consent_Form__c+ ' to '+newContact.Location_of_Consent_Form__c +'<br/>';
                else
                    history.Action__c = 'Changed <b>Location of Consent Form</b> from '+ oldContact.Location_of_Consent_Form__c+ ' to '+newContact.Location_of_Consent_Form__c +'<br/>';
                isChanged =  true;
            }
            if(newContact.Power_of_attorney_established__c != oldContact.Power_of_attorney_established__c){
                if(history.Action__c!=null)
                    history.Action__c += 'Changed <b>Power of attorney established?</b> from '+ oldContact.Power_of_attorney_established__c+ ' to '+newContact.Power_of_attorney_established__c +'<br/>';
                else
                    history.Action__c = 'Changed <b>Power of attorney established?</b> from '+ oldContact.Power_of_attorney_established__c+ ' to '+newContact.Power_of_attorney_established__c +'<br/>';
                isChanged =  true;
            }
            isChanged =  true;
            //if the values have been changed, create new history record
            System.debug('>>>>>>>>>>>>>>>>>>>>>>>isChanged>>>>>>>>>>>>>>>>>>>' + isChanged);
            if(isChanged)
            {
                history.Contact_History__c = newContact.Id;
                history.Date__c = datetime.now().addHours(1);
                List<user> updatedBy = [select id, name from User where id = :UserInfo.getUserId()];
                history.User__c = updatedBy[0].Name;
                if(history.Action__c!=null) insert history;
            }
        }
        //update contacts 
        }
        else if(newContact.testFlag__c == false) 
        {
            newContact.testFlag__c = true;
        }
    }
/******************************************************************************************
* ContactBeforeDeleteRemoveServiceUsage
*******************************************************************************************/
private void ContactBeforeDeleteRemoveServiceUsage (Contact oldContact) {
    System.debug('+++++++++++++++++++++++ContactBeforeDeleteRemoveServiceUsage');
    List<Service_Usage__c> lstServiceUsages = new List<Service_Usage__c>([Select Id from 
            Service_Usage__c where Primary_Service_User__c =:oldContact.id ]);

        system.debug('#################lstServiceUsages.size() ##################'+lstServiceUsages.size() );

        if(lstServiceUsages.size()>0){
            Savepoint sp = Database.setSavepoint();
            try
                {
                delete lstServiceUsages;
                }
            catch(Exception ex){system.debug(ex.getMessage());Database.rollback(sp);trigger.old[0].addError('Cannot delete associated Service Usage records.');}
            }
    }

/*
**
**/
public void UpdateLastTransactionDate(Contact[] updatedContacts){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> ContactIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Contact df : updatedContacts){
        ContactIds.add(df.Id);
    }
    System.debug('****** ContactIds.Size ******' + ContactIds.Size());

    if(ContactIds.isEmpty() == false){
      
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
      LastTransactionDateLookup handler = new LastTransactionDateLookup();
      handler.UpdateLastTransactionDate(ContactIds[0], dtLastTransactionDate); 
      
        }

}
private static testMethod void testContactTriggerHandler() {
    Contact c1 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
        rrpu__Alert_Message__c='test',
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);    
    insert c1;
    Contact c2 = new Contact(FirstName='two', LastName='test2',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
        MailingCity='Abcd', MailingCountry='Abcd', MailingState='Abcd', MailingStreet='Abcd',
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and DeveloperName = 'Professional'].id);    
    insert c2;
    firstRun = true;   
    c1.Lastname='test2';
    update c1;
    c1.MailingCity='Abcd';
    c1.MailingCountry='Abcd';
    c1.MailingState='Abcd';
    c1.MailingStreet='Abcd';
    update c1;
    firstRun = true;
    c1.Lastname='test3';
    c1.MailingStreet='Abcde';
    c1.MailingCity='Abcde';
    c1.BirthDate=Date.Today().addyears(-10);
    c1.Service_user_aware_of_diagnosis__c=true;
    c1.Specialist_Communication_Needs__c='abcde';
    c1.Diagnosis_made_by__c = c2.id;
    c1.Date_of_Diagnosis__c = Date.Today().addmonths(-9);
    c1.Diagnosis__c = 'Dementia with Lewy bodies';
    c1.Firstname='newadcd';
    c1.Consent_Status__c='Awaiting Consent';
    c1.Database_consent_Date__c=Date.Today().Addmonths(-4);
    c1.Date_of_Change_of_Living_Arrangements__c=Date.Today().Addmonths(-4);
    c1.Key_Health_Issues__c ='Hearing impairment';
    c1.Power_of_attorney_established__c=true;
    c1.Consent_Status__c='Withdrawn';
    update c1;
    c1.Consent_Status__c='Awaiting Consent';
    c1.rrpu__Alert_Message__c = '';
    c1.DoNotCall = true;
    update c1;

    firstRun = true;
    c1.Deceased__c = true;
    c1.Deceased_Date__c = Date.Today().adddays(-3);
    update c1;
    
    delete c1;
    }
}