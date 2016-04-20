/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : VF Page controller methods for CreateRelationship, Allow to search or create contact before creating Relationship.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2012-01-24
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *  Copyright (c) Saaspoint 2012 as per Master Services Agreement
 *
 *  Description: VF Page controller, allow user to search for existing/matching contacts in system. 
 *               Either they can select one from Result or force create new Contact with details provide.    
 *               And create Relationship record for selected Contacts and filled data.
 *
 *  Modification History
 *
 *  Date         Who            Description 
 *  2012-02-29   Nupoor Pandey  Integration with Data Scout. Added logic, validation and new fields
 *  2012-10-09   Venkat Akula   Added 'Other' relationship to professional relations.                        
*******************************************************************************************/
public with sharing class CreateRelationshipController 
{
    public SFDC_Contact_Connector__c recRelationship {get;set;}
    public Id recordTypeId {get;set;}
    public Id conRecordTypeId {get;set;}
    public Contact relContact {get;set;}
    public List<Contact> lstMatchingContacts {get;set;}
    public String lastName {get;set;}
    public String selectedRelContactId {get;set;}
    public String selectedRelContactName {get;set;}
    public Contact cont;
    public Boolean ignoreAndCreate {get;set;}
    public Boolean hasAddress {get;set;}
    public Boolean searchDone {get;set;}
    public Map<Id,String> mapOfContactRecordTypes;
    
    //Constructor
    public CreateRelationshipController(ApexPages.StandardController stdCon){
        recRelationship = new SFDC_Contact_Connector__c();
        relContact = new Contact();
        lstMatchingContacts = new List<Contact>();
        mapOfContactRecordTypes = new Map<Id,String>();
        getContactRecordTypes();
        cont = [select id, Email, Record_Type_Name__c, RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, 
                MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Primary_care_trust__c, Clinical_Commissioning_Group__c, Local_authority__c, Constituency__c,
                salutation, Constituency_Derived__c from Contact where id = :ApexPages.currentPage().getParameters().get('id')];
        //if the first contact does not have address, do not display the 'Same Address' checkbox
        if(cont.MailingStreet==null && cont.MailingState==null && cont.MailingPostalCode==null && cont.MailingCountry==null && cont.MailingCity==null)
            hasAddress = false;
        else
            hasAddress = true;
        searchDone = false;
        ignoreAndCreate = false;
    }
   
   //Returns Recordtypes of Contact available for current User.
   public List<SelectOption> getContactRecordTypes(){
        List<SelectOption> lstRecordTypes = new List<SelectOption>();
        //Retrive all Contact RecordTypes
        for(RecordTypeInfo rec: Contact.SObjectType.getDescribe().getRecordTypeInfosById().values()){
          //Check if recordtype is visible/available for current user.
          if(rec.isAvailable()&& rec.getName()!='Master'){
              mapOfContactRecordTypes.put(rec.getRecordTypeId(), rec.getName());
              lstRecordTypes.add(new SelectOption(rec.getRecordTypeId(),rec.getName()));
          }
        }
        return lstRecordTypes;
   }
    
    //Prepare RecordType list for Relationship Object (Ideally Personall/Professinal)
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> lstRecordTypes = new List<SelectOption>();
        for(RecordType rec: [SELECT Id,Name FROM RecordType WHERE SobjectType='SFDC_Contact_Connector__c']){
            lstRecordTypes.add(new SelectOption(rec.id,rec.name));
        }
        return lstRecordTypes;
    }
    
    public PageReference RecordTypeChanged(){
        recRelationship = new SFDC_Contact_Connector__c(RecordTypeId=recordTypeId);
        recRelationship.Current__c=true;
        return null;
    }
    //Returns RecordType name for a Relationship RecordType Id.
    public string getSelectedRecordTypeName(){
       //Check if User has selected RecordType on VF Page.
       if(recordTypeId==null)return null;
       system.debug('++recordTypeId+++++++++++++'+recordTypeId);
       return SFDC_Contact_Connector__c.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }
    //Returns RecordType name for the Contact RecordType Id.
    public string getSelectedContactRecordTypeName(){
        //Check if User has selected RecordType on VF Page.
       if(relContact.recordTypeId==null){
            //each profile will have a default Person Record Type, 
            
            RecordType rt;
            String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
            if(usrProfileName=='CRS' || usrProfileName=='CRS and BDC' || usrProfileName=='CRS Read Only' || usrProfileName=='CRS - One App User' || usrProfileName=='CRS and Service Data Manager'  || usrProfileName=='CEO'){
                rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Person with Dementia'];
                relContact.recordTypeId = rt.Id;
                system.debug('returning PWD: '+relContact.recordTypeId);
                return rt.Name;
            }else if(usrProfileName=='External Affairs' || usrProfileName=='External Affairs - Administrator' || usrProfileName=='Facilities - Platform' || usrProfileName=='Risk'){
                rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Professional / Stakeholder'];
                relContact.recordTypeId = rt.Id;
                system.debug('returning P/S: '+relContact.recordTypeId);
                return rt.Name;
            }else if(usrProfileName.contains('Trading')){
                rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name LIKE '%Trading%'];
                relContact.recordTypeId = rt.Id;
                system.debug('returning Trading: '+relContact.recordTypeId);
                return rt.Name;
            }else{
                rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Person with Dementia'];
                relContact.recordTypeId = rt.Id;
                system.debug('returning else PWD: '+relContact.recordTypeId);
                return rt.Name;
            }
       }
       system.debug('++recordTypeId+++++++++++++'+relContact.recordTypeId);
       system.debug('+++++++++++++++++++++++++++'+mapOfContactRecordTypes.get(relContact.recordTypeId));
       //return Contact.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
       return mapOfContactRecordTypes.get(relContact.recordTypeId);
    }
    public Boolean ValidateScreen() {
        Boolean isError = false;
        String recType = SFDC_Contact_Connector__c.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();

            if(recRelationship.Type__c==null ){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter a Relationship.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if(relContact.FirstName==null &&  relContact.Salutation==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter First Name or Title.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if(lastName==null || lastName==''){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Last Name.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if(relContact.MailingPostalCode==null &&  relContact.Birthdate==null && recType=='Personal' && recRelationship.Same_Address__c!=true){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter either a Postcode, a Date of Birth, or both.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if(recType=='Professional' && (relContact.MailingPostalCode==null || relContact.MailingPostalCode=='') && recRelationship.Related_Organization__c==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Organisation name.');
                ApexPages.addMessage(message);
                isError = true;
            }else if(recType=='Professional' && recRelationship.Related_Organization__c==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Organisation name.');
                ApexPages.addMessage(message);
                isError = true;
            }
            //do not allow professionals to be added if no address on organisation
            if(recType=='Professional' && recRelationship.Related_Organization__c!=null){ 
                Account selectedAccount = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                                    From Account a where id=:recRelationship.Related_Organization__c];                
                if ((selectedAccount.BillingPostalCode==null)||(selectedAccount.BillingPostalCode=='')){             
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The Organisation you have selected does not have a postcode.  The Organisation\'s record has to be changed before people can be associated with it.');
                    ApexPages.addMessage(message);
                    isError = true;  }       
            }
            if(relContact.Birthdate>System.today()){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Date of Birth must be in the past.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if((relContact.Birthdate!=null && relContact.Birthdate > System.today().addYears(-18)) 
                            && relContact.Birthdate<=System.today() && recType=='Personal'){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Warning,'The Date of Birth entered is for a person under 18 years old.');
                ApexPages.addMessage(message);
                //isError = true;
            }
            if((relContact.MailingPostalCode==null || relContact.MailingPostalCode=='')  &&  (relContact.MailingCountry==null || 
                                                        relContact.MailingCountry=='United Kingdom') 
                                                        && recRelationship.Same_Address__c!=true 
                                                        && recType=='Personal'){
                String sRecordtypename = getSelectedContactRecordTypeName();
                if (sRecordtypename == null || sRecordtypename =='') {
                    sRecordtypename = 'Person with Dementia, Carer of Person with Dementia or Friend of Person with Dementia';}
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'You will need a Postcode for a UK address to create a record type of ' + sRecordtypename + '. ' 
                                                                                            + '   (If the person lives at the same address click the Same Adddress check box).'  );
                ApexPages.addMessage(message);
                //isError = true;
            }
        return isError;
    }    
    //This search is Mimic for DataScout integration search.
    public PageReference doSearch(){
    /**
        string srchKeyword = '%'+lastName+'%';
        lstMatchingContacts = [Select id, Email, Name, Record_Type_Name__c, RecordTypeId, Diagnosis__c, MailingStreet, MailingState, 
                                MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Primary_care_trust__c, 
                                Local_authority__c, Constituency__c, Salutation, Constituency_Derived__c 
                                from Contact where LastName like :srchKeyword];
        return null;   
    **/
    Boolean isError = false;
    isError = ValidateScreen();
        if (isError == true) {
        searchDone = false;
        return null;}
    else {searchDone = true;
          }
        // Local Variables
    DeDuper objDeDuper = new DeDuper();         
    Set<Id> contactIds = new Set<Id>();
    Boolean ProfessionalSearch = false;
    String tLastName = lastName;
    String tPostCode = relContact.MailingPostalCode;
    Date tBirthDate = relContact.Birthdate;
    Id AccountIDForProfessionals;
    String recType = SFDC_Contact_Connector__c.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    system.debug('#############rectype:#############'+recType);
    // Conditions.
    //if the user has given address details, search for duplicates using these details
    if(relContact.MailingPostalCode!=null || relContact.MailingCity!=null || relContact.MailingCountry!=null || relContact.MailingState!=null || relContact.MailingStreet!=null){
        tPostCode = relContact.MailingPostalCode;
    //for Personal relationships and same address, get the address details from first contact
    }else if(recRelationship.Same_Address__c && recType=='Personal' && 
            (cont.MailingCity!=null || cont.MailingCountry!=null || cont.MailingState!=null || cont.MailingStreet!=null || cont.MailingPostalCode!=null)){
        tPostCode = cont.MailingPostalCode;            
    //for Personal relationships and no address on first contact, display error message
    }else if(recRelationship.Same_Address__c && recType=='Personal' && 
            (cont.MailingCity!=null && cont.MailingCountry!=null && cont.MailingState!=null && cont.MailingStreet!=null && cont.MailingPostalCode!=null)){
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter a Date of Birth.');
        ApexPages.addMessage(message);
        return null;
    //for Professional relationships, get the address details from organisation
    }else if(recRelationship.Related_Organization__c!=null && recType=='Professional'){
        Account organisation = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                From Account a where id = :recRelationship.Related_Organization__c];
        
        tPostCode = organisation.BillingPostalCode;
        AccountIDForProfessionals = organisation.Id;
        ProfessionalSearch = true;
    }   
     
    if(!ProfessionalSearch)  {
        // Perform Search. 
        lstMatchingContacts = objDeDuper.SearchNonProfessional(cont, tLastName,relContact.firstname, tBirthDate, tPostCode); 
    }else {
        contactIds = objDeDuper.SearchProfessionals(tLastName, AccountIDForProfessionals); 
        lstMatchingContacts = [Select id, Name, Email, Record_Type_Name__c, RecordTypeId, Diagnosis__c, MailingStreet, MailingState, 
                            MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Primary_care_trust__c, 
                            Local_authority__c, Constituency__c, Salutation from Contact where id in :contactIds];
    }
    
    /**
    END : DeDuper Integration
    */
    
    
    //if no duplicates are found, create relationship and contact and then go to contacts page
    if(lstMatchingContacts.size()<1){
        
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'No matches found');
            ApexPages.addMessage(message);
            return null;
        }
    else {
        //if dupes are found, return the contact list to the page
        system.debug('#############dupes found-lstMatchingContacts:#############'+lstMatchingContacts);
        ignoreAndCreate = true;
        searchDone = false;
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Matching people have been found, please use one of the two buttons at the bottom of the screen to continue.');
        ApexPages.addMessage(message);
        return null;
    }
}

    /**
        This method handler will allow user to create new Relationship record.
        if the dupe contact is not selected:
        1)run validations
        2)create relContact 
        3)create relationship
        */
    public PageReference createRelationship(){
        Boolean isError = false;
        if((selectedRelContactId==null || selectedRelContactId=='')&& ignoreAndCreate ==true){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must select a person to create a relationship with a selected person.');
                ApexPages.addMessage(message);
                return null;
            }
            else if((selectedRelContactId!=null) && ignoreAndCreate ==true){
            try{
                //get the details of the selected dupe contact
                Contact dupeContact = [Select c.Email, c.Salutation, c.Name, c.MobilePhone, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, 
                c.MailingCity, c.LastName, c.Id, c.Gender__c, c.FirstName, c.Diagnosis__c, c.Date_of_diagnosis__c, c.Contact_Full_Name__c, c.Consent_Status__c, 
                c.Birthdate, c.Active__c, c.Record_Type_Name__c, c.RecordTypeId, c.AccountId, c.Ward__c, c.Primary_care_trust__c, c.Clinical_Commissioning_Group__c, 
                c.Local_authority__c, c.Constituency__c, Constituency_Derived__c From Contact c where id = :selectedRelContactId];
                             
                //populate the relationship using dupe contact details
                populateRelationship(dupeContact);
                
                //insert recRelationship;
                return new Pagereference('/'+cont.Id); //return to contact details page, from where the 'new relationship' button was clicked
            }catch(Exception ex){ 
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while creating Relationship using duplicate Contact.');
                ApexPages.addMessage(message);
                return null;
            }
        }
        else if (ignoreAndCreate ==false){
            //stop user changing things and then creating a duplicate
            isError =ValidateScreen();
            if (isError==true){
             return null;}
            
            try{
                //create related contact first
                //create related contact first. If user has entered address information, use that 
                //otherwise look for First contact's address - Personal Relationship and Same Address ticked 
                //or Organisation's address - Professional Relationship and Organisation!=null
                //if relationship type is professional, get the address details from the organisation
                if(recRelationship.Related_Organization__c!=null){
                    system.debug('>>>>>>>>> professional record');
                    Account selectedAccount = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity,a.Phone 
                                                    From Account a where id=:recRelationship.Related_Organization__c];
                    relContact.MailingCity = selectedAccount.BillingCity;
                    relContact.MailingCountry = selectedAccount.BillingCountry;
                    relContact.MailingPostalCode = selectedAccount.BillingPostalCode;
                    relContact.MailingState = selectedAccount.BillingState;
                    relContact.MailingStreet = selectedAccount.BillingStreet;
                    relContact.HomePhone=selectedAccount.Phone;
                    relContact.AccountId = selectedAccount.Id;
                    relContact.RecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where SObjectType='Contact' and DeveloperName='Professional'].Id;
                }
                if(relContact.MailingPostalCode==null && relContact.MailingCity==null && relContact.MailingCountry==null && relContact.MailingState==null && relContact.MailingStreet==null){
                    if(recRelationship.Same_Address__c){
                        relContact.MailingCity = cont.MailingCity;
                        relContact.MailingCountry = cont.MailingCountry;
                        relContact.MailingPostalCode = cont.MailingPostalCode;
                        relContact.MailingState = cont.MailingState;
                        relContact.MailingStreet = cont.MailingStreet;
                        //postcode details
                        relContact.Constituency_Derived__c = cont.Constituency_Derived__c;
                        relContact.Local_authority__c = cont.Local_authority__c;
                        relContact.Primary_care_trust__c = cont.Primary_care_trust__c;
                        relContact.Clinical_Commissioning_Group__c = cont.Clinical_Commissioning_Group__c;
                        relContact.Ward__c = cont.Ward__c;
                    }
                    //if relationship type is professional, get the address details from the organisation
                    if(recRelationship.Related_Organization__c!=null){
                        Account selectedAccount = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity,a.phone 
                                                        From Account a where id=:recRelationship.Related_Organization__c];
                        relContact.MailingCity = selectedAccount.BillingCity;
                        relContact.MailingCountry = selectedAccount.BillingCountry;
                        relContact.MailingPostalCode = selectedAccount.BillingPostalCode;
                        relContact.MailingState = selectedAccount.BillingState;
                        relContact.MailingStreet = selectedAccount.BillingStreet;
                        relContact.HomePhone=selectedAccount.Phone;
                        relContact.AccountId = selectedAccount.Id;
                        relContact.RecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where SObjectType='Contact' and DeveloperName='Professional'].Id;
                    }
                }
                relContact.LastName=lastName;
                //set person record type for professional relationship
                if(getSelectedContactRecordTypeName()=='Professional'){
                    relContact.RecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where SObjectType='Contact' and DeveloperName='Professional'].Id;
                    relContact.AccountId = recRelationship.Related_Organization__c;
                }
                //set organisation name for professional relationship
                if(getSelectedContactRecordTypeName()=='Professional' && recRelationship.Related_Organization__c!=null){
                    relContact.AccountId = recRelationship.Related_Organization__c;
                }
                system.debug('>>>>>>>>>>>AccountId: ' + relContact.AccountId);
                system.debug('>>>>>>>>>>>PostCode:  ' + relContact.MailingPostalCode);
                system.debug('>>>>>>>>>>>Recordtype:' + relContact.RecordTypeId);
                
                insert relContact; 
                populateRelationship(relContact);
                //insert recRelationship;
                return new Pagereference('/'+cont.Id); //return to new contact details page
            }catch(Exception ex){ 
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while creating Contact and Relationship.');
                ApexPages.addMessage(message);
                return null;
            }
        }
        return new Pagereference('/apex/CreateRelationship?id='+cont.Id);
    }
    
    public PageReference ignoreCreateRelationship(){
        Boolean isError = false;
        //stop user changing things and then creating a duplicate
        isError =ValidateScreen();
        if (isError==true){
         return null;}
        
        try{
            //create related contact first
            //create related contact first. If user has entered address information, use that 
            //otherwise look for First contact's address - Personal Relationship and Same Address ticked 
            //or Organisation's address - Professional Relationship and Organisation!=null
            if(relContact.MailingPostalCode==null && relContact.MailingCity==null && relContact.MailingCountry==null && relContact.MailingState==null && relContact.MailingStreet==null){
                if(recRelationship.Same_Address__c){
                    relContact.MailingCity = cont.MailingCity;
                    relContact.MailingCountry = cont.MailingCountry;
                    relContact.MailingPostalCode = cont.MailingPostalCode;
                    relContact.MailingState = cont.MailingState;
                    relContact.MailingStreet = cont.MailingStreet;
                    //postcode details
                    relContact.Constituency_Derived__c = cont.Constituency_Derived__c;
                    relContact.Local_authority__c = cont.Local_authority__c;
                    relContact.Primary_care_trust__c = cont.Primary_care_trust__c;
                    relContact.Clinical_Commissioning_Group__c = cont.Clinical_Commissioning_Group__c;
                    relContact.Ward__c = cont.Ward__c;
                }
                //if relationship type is professional, get the address details from the organisation
                if(recRelationship.Related_Organization__c!=null){
                    Account selectedAccount = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                                    From Account a where id=:recRelationship.Related_Organization__c];
                    relContact.MailingCity = selectedAccount.BillingCity;
                    relContact.MailingCountry = selectedAccount.BillingCountry;
                    relContact.MailingPostalCode = selectedAccount.BillingPostalCode;
                    relContact.MailingState = selectedAccount.BillingState;
                    relContact.MailingStreet = selectedAccount.BillingStreet;
                    relContact.AccountId = selectedAccount.Id;
                }
            }
            relContact.LastName=lastName;
            //set person record type for professional relationship
            if(getSelectedContactRecordTypeName()=='Professional'){
                relContact.RecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where SObjectType='Contact' and DeveloperName='Professional'].Id;
                relContact.AccountId = recRelationship.Related_Organization__c;
            }
            //set organisation name for professional relationship
            if(getSelectedContactRecordTypeName()=='Professional' && recRelationship.Related_Organization__c!=null){
                relContact.AccountId = recRelationship.Related_Organization__c;
            }
            insert relContact; 
            populateRelationship(relContact);
            //insert recRelationship;
            return new Pagereference('/'+cont.Id); //return to new contact details page
        }catch(Exception ex){ 
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while creating Contact and Relationship.');
            ApexPages.addMessage(message);
            return null;
        }
    }
    
    private void populateRelationship(Contact contact_l){
        //create the relationship
        recRelationship.Contact__c=cont.Id; //this is the first contact, from which the 'new relationship' button was clicked
        recRelationship.Contact_Record_Type__c=cont.Record_Type_Name__c; //this is the first contact, from which the 'new relationship' button was clicked
        recRelationship.Related_Contact__c=contact_l.Id;
        recRelationship.Related_Record_Type__c=contact_l.Record_Type_Name__c;
        //recRelationship.Status__c='';
        //based on Relationship type, set the Reverse Relationship type
        // ANY CHANGES HERE NEED TO BE REPRODUCED IN Trigger - RelationshipUpdateReverseRelationship 
        //
        recRelationship.Reverse_Relationship_Type__c= GetReverseRelationship(recRelationship.Type__c);
        /*
        if(recRelationship.Type__c=='Consultant of')
            recRelationship.Reverse_Relationship_Type__c='Patient of (Consultant)';
        else if(recRelationship.Type__c=='Social care worker of')
            recRelationship.Reverse_Relationship_Type__c='Client of (Social care worker)';
        else if(recRelationship.Type__c=='Social worker of')
            recRelationship.Reverse_Relationship_Type__c='Client of (Social worker)';
        else if(recRelationship.Type__c=='Care manager of')
            recRelationship.Reverse_Relationship_Type__c='Patient of (Care Manager)';
        else if(recRelationship.Type__c=='Community psychiatric nurse of')
            recRelationship.Reverse_Relationship_Type__c='Patient of (CPN)';
        else if(recRelationship.Type__c=='Admiral nurse of')
            recRelationship.Reverse_Relationship_Type__c='Patient of (Admiral nurse)';
        else if(recRelationship.Type__c=='Patient of (GP)') 
            recRelationship.Reverse_Relationship_Type__c='GP of';
        else if(recRelationship.Type__c=='Patient of (Consultant)')
            recRelationship.Reverse_Relationship_Type__c='Consultant of';
        else if(recRelationship.Type__c=='Patient of (Care Manager)')
            recRelationship.Reverse_Relationship_Type__c='Client of (Care Manager)';
        else if(recRelationship.Type__c=='Patient of (CPN)')
            recRelationship.Reverse_Relationship_Type__c='Community psychiatric nurse of';
        else if(recRelationship.Type__c=='Patient of (Admiral nurse)')
            recRelationship.Reverse_Relationship_Type__c='Admiral nurse of';
        else if(recRelationship.Type__c=='Client of (Social care worker)')
            recRelationship.Reverse_Relationship_Type__c='Social care worker of';
        else if(recRelationship.Type__c=='Client of (Social worker)')
            recRelationship.Reverse_Relationship_Type__c='Social worker of';
        else if(recRelationship.Type__c=='Client of (Care manager)')
            recRelationship.Reverse_Relationship_Type__c='Care manager of';
        else if(recRelationship.Type__c=='Neighbour of')
            recRelationship.Reverse_Relationship_Type__c='Neighbour of';
        else if(recRelationship.Type__c=='Partner of')
            recRelationship.Reverse_Relationship_Type__c='Partner of';
        else if(recRelationship.Type__c=='Spouse of')
            recRelationship.Reverse_Relationship_Type__c='Spouse of';
        else if(recRelationship.Type__c=='Parent of')
            recRelationship.Reverse_Relationship_Type__c='Son/daughter of';
        else if(recRelationship.Type__c=='Son/daughter of')
            recRelationship.Reverse_Relationship_Type__c='Parent of';
        else if(recRelationship.Type__c=='Sibling of')
            recRelationship.Reverse_Relationship_Type__c='Sibling of';
        else if(recRelationship.Type__c=='Cousin of')
            recRelationship.Reverse_Relationship_Type__c='Cousin of';
        else if(recRelationship.Type__c=='Nephew/niece of')
            recRelationship.Reverse_Relationship_Type__c='Uncle/aunt of';
        else if(recRelationship.Type__c=='Uncle/aunt of')
            recRelationship.Reverse_Relationship_Type__c='Nephew/niece of';
        else if(recRelationship.Type__c=='Grandparent of')
            recRelationship.Reverse_Relationship_Type__c='Grandson/daughter of';
        else if(recRelationship.Type__c=='Grandson/daughter of')
            recRelationship.Reverse_Relationship_Type__c='Grandparent of';
        else if(recRelationship.Type__c=='Parent in-law of')
            recRelationship.Reverse_Relationship_Type__c='Son/daughter-in-law of';
        else if(recRelationship.Type__c=='Son/daughter-in-law of')
            recRelationship.Reverse_Relationship_Type__c='Parent in-law of';
        else if(recRelationship.Type__c=='Sibling in-law of')
            recRelationship.Reverse_Relationship_Type__c='Sibling in-law of';
        else if(recRelationship.Type__c=='Step-parent of')
            recRelationship.Reverse_Relationship_Type__c='Step-child of';
        else if(recRelationship.Type__c=='Step-child of')
            recRelationship.Reverse_Relationship_Type__c='Step-parent of';
        else if(recRelationship.Type__c=='Step-sibling of')
            recRelationship.Reverse_Relationship_Type__c='Step-sibling of';
        else if(recRelationship.Type__c=='Half-sibling of')
            recRelationship.Reverse_Relationship_Type__c='Half-sibling of';
        else if(recRelationship.Type__c=='Friend of')
            recRelationship.Reverse_Relationship_Type__c='Friend of';
        else if(recRelationship.Type__c=='GP of')
            recRelationship.Reverse_Relationship_Type__c='Patient of (GP)';
        else if(recRelationship.Type__c=='Other')    
            recRelationship.Reverse_Relationship_Type__c='Other';
        */
        insert recRelationship;
    }
    public string GetReverseRelationship(string forwardRelationship) {
        String reverseRelationship = '';
        //recRelationship.Status__c='';
        //based on Relationship type, set the Reverse Relationship type
        // ANY CHANGES HERE NEED TO BE REPRODUCED IN Trigger - RelationshipUpdateReverseRelationship 
        //
        if(forwardRelationship=='Consultant of')
            reverseRelationship='Patient of (Consultant)';
        else if(forwardRelationship=='Social care worker of')
            reverseRelationship='Client of (Social care worker)';
        else if(forwardRelationship=='Social worker of')
            reverseRelationship='Client of (Social worker)';
        else if(forwardRelationship=='Care manager of')
            reverseRelationship='Patient of (Care Manager)';
        else if(forwardRelationship=='Community psychiatric nurse of')
            reverseRelationship='Patient of (CPN)';
        else if(forwardRelationship=='Admiral nurse of')
            reverseRelationship='Patient of (Admiral nurse)';
        else if(forwardRelationship=='Patient of (GP)') 
            reverseRelationship='GP of';
        else if(forwardRelationship=='Patient of (Consultant)')
            reverseRelationship='Consultant of';
        else if(forwardRelationship=='Patient of (Care Manager)')
            reverseRelationship='Client of (Care Manager)';
        else if(forwardRelationship=='Patient of (CPN)')
            reverseRelationship='Community psychiatric nurse of';
        else if(forwardRelationship=='Patient of (Admiral nurse)')
            reverseRelationship='Admiral nurse of';
        else if(forwardRelationship=='Client of (Social care worker)')
            reverseRelationship='Social care worker of';
        else if(forwardRelationship=='Client of (Social worker)')
            reverseRelationship='Social worker of';
        else if(forwardRelationship=='Client of (Care manager)')
            reverseRelationship='Care manager of';
        else if(forwardRelationship=='Neighbour of')
            reverseRelationship='Neighbour of';
        else if(forwardRelationship=='Partner of')
            reverseRelationship='Partner of';
        else if(forwardRelationship=='Spouse of')
            reverseRelationship='Spouse of';
        else if(forwardRelationship=='Parent of')
            reverseRelationship='Son/daughter of';
        else if(forwardRelationship=='Son/daughter of')
            reverseRelationship='Parent of';
        else if(forwardRelationship=='Sibling of')
            reverseRelationship='Sibling of';
        else if(forwardRelationship=='Cousin of')
            reverseRelationship='Cousin of';
        else if(forwardRelationship=='Nephew/niece of')
            reverseRelationship='Uncle/aunt of';
        else if(forwardRelationship=='Uncle/aunt of')
            reverseRelationship='Nephew/niece of';
        else if(forwardRelationship=='Grandparent of')
            reverseRelationship='Grandson/daughter of';
        else if(forwardRelationship=='Grandson/daughter of')
            reverseRelationship='Grandparent of';
        else if(forwardRelationship=='Parent in-law of')
            reverseRelationship='Son/daughter-in-law of';
        else if(forwardRelationship=='Son/daughter-in-law of')
            reverseRelationship='Parent in-law of';
        else if(forwardRelationship=='Sibling in-law of')
            reverseRelationship='Sibling in-law of';
        else if(forwardRelationship=='Step-parent of')
            reverseRelationship='Step-child of';
        else if(forwardRelationship=='Step-child of')
            reverseRelationship='Step-parent of';
        else if(forwardRelationship=='Step-sibling of')
            reverseRelationship='Step-sibling of';
        else if(forwardRelationship=='Half-sibling of')
            reverseRelationship='Half-sibling of';
        else if(forwardRelationship=='Friend of')
            reverseRelationship='Friend of';
        else if(forwardRelationship=='GP of')
            reverseRelationship='Patient of (GP)';
        else if(forwardRelationship=='Other')    
            reverseRelationship='Other';
        else if(forwardRelationship=='Client of (paid carer)')    
            reverseRelationship='Paid carer of';
        else if(forwardRelationship=='Paid carer of')    
            reverseRelationship='Client of (paid carer)';
        return reverseRelationship;
        }
  //
  // TEST CASE
  //
  private static testMethod void testRelationships() {
        Contact c1 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
            MailingCity='Abcd', MailingCountry='Abcd', MailingState='Abcd', MailingStreet='Abcd',
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);    
        insert c1;
        Contact c2 = new Contact(FirstName='two', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Carer of Person with Dementia'].id);    
//c        insert c2;
        Contact c3= new Contact(FirstName='two', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Carer of Person with Dementia'].id);    
//b        insert c3;
        Contact c4= new Contact(FirstName='two', LastName='related',MailingPostalCode ='SW1A 2AA', Birthdate =Date.Today().addyears(-1),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Carer of Person with Dementia'].id);    
       insert c4;
//find  a professional
        Id ProfRecordTypeId= [select Id from RecordType where SObjectType='Contact' and DeveloperName = 'Professional'].Id;
        Contact c99 = [Select id, Lastname, firstname, Birthdate, MailingPostalCode from Contact where RecordTypeId = :ProfRecordTypeId LIMIT 1]; 
        system.debug('###########C99#########'+c99.Lastname);
//       Contact c99= new Contact(FirstName='two', LastName='related',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
//            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Carer of Person with Dementia'].id);    
//do not create it        insert c99;


    //a block of similar people
//           Contact c10 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
//            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);    
//        insert c10;
//       Contact c11 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
//            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);    
//        insert c11;
//       Contact c12 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
//            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);    
//        insert c12;
//       Contact c13 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
//            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);    
//        insert c13;
//       Contact c14 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
//            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);    
//        insert c14;

        Account acc = new Account(Name='Test External Org',BillingPostalCode='XX1 2ZZ', RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'External%'].id);
        insert acc;  
        
        Id personal = [SELECT Id,Name FROM RecordType WHERE SobjectType='SFDC_Contact_Connector__c' AND Name ='Personal'].id;
        Id professional  = [SELECT Id,Name FROM RecordType WHERE SobjectType='SFDC_Contact_Connector__c' AND Name ='Professional'].id;
 
        SFDC_Contact_Connector__c rRel = new SFDC_Contact_Connector__c(RecordTypeId=personal, Contact__c=c1.id, Type__c='Spouse of');
        SFDC_Contact_Connector__c rRel2 = new SFDC_Contact_Connector__c(RecordTypeId=personal, Contact__c=c4.id);
        SFDC_Contact_Connector__c rRel99 = new SFDC_Contact_Connector__c(RecordTypeId=professional, Contact__c=c99.id, Related_Organization__c=acc.id);

        insert rRel;
        rRel.Type__c='Other';
        update rRel;

         
        // Set up the VF page
        PageReference pageRef = Page.CreateRelationship;
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', c1.Id);
        
        //CreateRelationshipController cnt = new CreateRelationshipController();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c1);
        CreateRelationshipController cnt = new CreateRelationshipController(stdCon);

        //CreateRelationshipController with no address
        pageRef.getParameters().put('Id', c4.Id);
        ApexPages.StandardController stdCon2 = new ApexPages.StandardController(c4);
        CreateRelationshipController cnt2 = new CreateRelationshipController(stdCon2);
        
        system.debug('#############test1#############');
        pageRef.getParameters().put('Id', c1.Id);

        cnt.getContactRecordTypes();
        cnt.getRecordTypes();
        cnt.recordTypeId = personal;
        system.assertEquals(cnt.validatescreen(), true);
        cnt.recordTypeId = professional;
        system.assertEquals(cnt.validatescreen(), true);
        
        cnt.recordTypeId = personal;
        cnt.recRelationship.Type__c='Spouse of';
        cnt.recRelationship=rRel;
        cnt.lastName='test';

        cnt.relContact = c4;
        rrel.Same_Address__c=true;

        cnt.RecordTypeChanged();
        cnt.recordTypeId=cnt.getRecordTypes().get(0).getValue();
        cnt.RecordTypeChanged();
        cnt.getSelectedContactRecordTypeName();
        cnt.dosearch();
        cnt.createRelationship();
        
        String s = cnt.getSelectedRecordTypeName();
        
        system.debug('#############test2#############');
        cnt.recRelationship.Type__c='Nuffik';
        cnt.dosearch();
        cnt.createRelationship();
        cnt.lastName='test';
        cnt.relContact.MailingPostalCode='XX1 2ZZ';
        cnt.relContact.Birthdate=Date.Today().addyears(-69);
        
        system.debug('#############test3#############');
        cnt.recRelationship.Type__c='Other';
        cnt.doSearch();
        cnt.createRelationship();

        system.debug('#############test4#############');
        cnt.relContact = new Contact();
        cnt.lastName='test';
        cnt.relContact.FirstName='Test';
        cnt.relContact.Birthdate=Date.Today().addyears(-69);
        cnt.relContact.MailingPostalCode=null;
        cnt.relContact.MailingCity=null;
        cnt.relContact.MailingCountry=null;
        cnt.relContact.MailingState=null;
        cnt.relContact.MailingStreet=null;
        
        rrel.Same_Address__c=true;
        cnt.doSearch();
        cnt.ignoreCreateRelationship();
        
        cnt.relContact = c4;
        cnt.lastName='test';
        cnt.relContact.MailingPostalCode=null;
        cnt.doSearch();
        cnt.selectedRelContactId = c4.id;
        system.debug('selectedRelContactId =' + cnt.selectedRelContactId );
        cnt.createRelationship();
        //cnt.populateRelationship(c3);
        cnt.ignoreCreateRelationship();

        cnt.recordTypeId = personal;
        cnt.relContact = c3;
        cnt.createRelationship(); 
        cnt.ignoreCreateRelationship();
 
        cnt.relContact.MailingPostalCode=null;
        cnt.relContact.MailingCity=null; 
        cnt.relContact.MailingCountry=null;
        cnt.relContact.MailingState=null; 
        cnt.relContact.MailingStreet=null;
        cnt.recRelationship.Same_Address__c = true;
        cnt.ignoreCreateRelationship();
              
        cnt.recordTypeId = personal;
        rrel.Same_Address__c=false;
        cnt.relContact.MailingPostalCode=null;
        cnt.relContact.Birthdate=null;
        cnt.createRelationship(); 
//        cnt.ignoreCreateRelationship();

        //test on cnt2 - no address on contact
/**
        cnt2.recordTypeId = personal;
        cnt2.relContact = c1;
        rrel2.Same_Address__c=true;
        cnt2.createRelationship(); 
//        cnt2.ignoreCreateRelationship();
**/ 
        system.debug('#############test5#############');               
        cnt.recordTypeId = professional;
        cnt.recRelationship=rRel99 ;
        cnt.recRelationship.Type__c='Patient of (GP)';
        cnt.lastName='test';
        rrel.Same_Address__c=false;
        cnt.relContact.MailingPostalCode='XX1 2ZZ';
        rrel.Related_Organization__c=acc.id;
        cnt.relContact = c99;
        cnt.relContact.MailingPostalCode=null;
        cnt.relContact.MailingStreet=null;
        cnt.relContact.MailingCity=null;
        cnt.relContact.MailingCountry=null;
        cnt.relContact.MailingState=null;
        cnt.doSearch();   
        cnt.createRelationship(); 
//        cnt.ignoreCreateRelationship();

/**      
        cnt.recordTypeId = professional;       
        rrel.Same_Address__c=true;
        cnt.relContact.MailingPostalCode=null;
        rrel.Related_Organization__c=null;
        cnt.relContact = c4;
        cnt.createRelationship(); 
        cnt.ignoreCreateRelationship();

        cnt.recordTypeId = professional; 
        cnt.recRelationship.Type__c='GP of';
        rrel.Same_Address__c=false;
        cnt.relContact.MailingPostalCode='ABC';
        rrel.Related_Organization__c=null;
        cnt.relContact = c99;
        //cnt.populateRelationship(c1);
        cnt.createRelationship(); 
//        cnt.ignoreCreateRelationship();
**/        
        

 //       cnt.populateRelationship(c10);
 
        //cnt.recordTypeId = personal;
        //cnt.lastName='test';
        //cnt.relContact.FirstName='one'; 
        //cnt.relContact.LastName='test';
        //cnt.relContact.Salutation='Mr';
        //cnt.relContact.MailingPostalCode ='ABC123';
        //cnt.relContact.Birthdate =Date.Today().addyears(-1);
        //cnt.recRelationship.Type__c='Spouse of';
        //cnt.relContact = c10;
        //cnt.createRelationship(); 
        //cnt.ignoreCreateRelationship();

        //rrel.Same_Address__c=true;
        //cnt.createRelationship(); 
        //cnt.ignoreCreateRelationship();
        //rrel.Same_Address__c=false;
/**
        cnt.recordTypeId = personal;
        rrel.Same_Address__c=true;
        cnt.lastName='test';
 
        system.debug('#############test20#############');       
        cnt.selectedRelContactId='1234';
        cnt.recRelationship.Type__c='GP of';
        cnt.recordTypeId = personal;
        rrel.Same_Address__c=true;
        cnt.lastName='test';
        cnt.relContact = c99;
        
        cnt.ignorecreateRelationship(); 
        cnt.createRelationship();
        
        cnt.selectedRelContactId=null;
        
        //test validation of createrelationship
        system.debug('#############test30#############');       
        //test validation of createrelationship
        cnt.recordTypeId = personal;
        rrel.Same_Address__c=true;
        cnt.relContact = c10;
        cnt.lastName='test';
        cnt.relContact.FirstName='one'; 
        cnt.relContact.LastName='test';
        cnt.relContact.Salutation='Mr';
        cnt.relContact.MailingPostalCode ='ABC123';
         
        cnt.relContact.Birthdate=Date.Today().addyears(1);
        cnt.createRelationship(); 
 
        cnt.relContact.Birthdate=null;
        cnt.relContact.MailingPostalCode=null;
        cnt.createRelationship(); 
        
        cnt.lastName=null;
        cnt.createRelationship(); 
 
        cnt.relContact.Salutation=null;
        cnt.relContact.FirstName=null;
        cnt.createRelationship(); 
        
        cnt.recRelationship.Type__c=null;
        cnt.createRelationship();
**/
    String reverseRel;

    reverseRel = cnt.GetReverseRelationship('Consultant of');

    reverseRel = cnt.GetReverseRelationship('Social care worker of');

    reverseRel = cnt.GetReverseRelationship('Social worker of');

    reverseRel = cnt.GetReverseRelationship('Care manager of');

    reverseRel = cnt.GetReverseRelationship('Community psychiatric nurse of');

    reverseRel = cnt.GetReverseRelationship('Admiral nurse of');

    reverseRel = cnt.GetReverseRelationship('Patient of (GP)') ;

    reverseRel = cnt.GetReverseRelationship('Patient of (Consultant)');

    reverseRel = cnt.GetReverseRelationship('Patient of (Care Manager)');

    reverseRel = cnt.GetReverseRelationship('Patient of (CPN))');

    reverseRel = cnt.GetReverseRelationship('Patient of (Admiral nurse)');

    reverseRel = cnt.GetReverseRelationship('Client of (Social care worker)');

    reverseRel = cnt.GetReverseRelationship('Client of (Social worker)');

    reverseRel = cnt.GetReverseRelationship('Client of (Care manager)');

    reverseRel = cnt.GetReverseRelationship('Neighbour of');

    reverseRel = cnt.GetReverseRelationship('Partner of');

    reverseRel = cnt.GetReverseRelationship('Spouse of');

    reverseRel = cnt.GetReverseRelationship('Parent of');

    reverseRel = cnt.GetReverseRelationship('Son/daughter of');

    reverseRel = cnt.GetReverseRelationship('Sibling of');

    reverseRel = cnt.GetReverseRelationship('Cousin of');

    reverseRel = cnt.GetReverseRelationship('Nephew/niece of');

    reverseRel = cnt.GetReverseRelationship('Uncle/aunt of');

    reverseRel = cnt.GetReverseRelationship('Grandparent of');

    reverseRel = cnt.GetReverseRelationship('Grandson/daughter of');

    reverseRel = cnt.GetReverseRelationship('Parent in-law of');

    reverseRel = cnt.GetReverseRelationship('Son/daughter-in-law of');

    reverseRel = cnt.GetReverseRelationship('Sibling in-law of');

    reverseRel = cnt.GetReverseRelationship('Step-parent of');

    reverseRel = cnt.GetReverseRelationship('Step-child of');

    reverseRel = cnt.GetReverseRelationship('Step-sibling of');

    reverseRel = cnt.GetReverseRelationship('Half-sibling of');

    reverseRel = cnt.GetReverseRelationship('Friend of');

    reverseRel = cnt.GetReverseRelationship('GP of');

    reverseRel = cnt.GetReverseRelationship('Other');
 
   }    
}