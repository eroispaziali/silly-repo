/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : VF Page controller methods for NewPerson, Allow to search for contacts before creating new.
 *  Author  : Fujitsu - Nupoor Pandey
 *  Date    : 2012-04-18
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *
 *  Description: VF Page controller, allow user to search for existing/matching contacts in system. 
 *               Either they can select one from Result or force create new Contact with details provided.    
 *
 *  Modification History
 *
 *  Date         Who            Description 
 *  14/10/2014   MT     Text Santa changes for Collectors
    Dec 2014     gary.grant@conseq.co.uk Added support for UI Participant creation

 *                             
*******************************************************************************************/
public with sharing class NewPersonController {

    public SFDC_Contact_Connector__c recRelationship {get;set;}
    public Id recordTypeId {
        get;
        set;
    }
    
    public Id conRecordTypeId {get;set;}
    public Contact relContact {get;set;}
    public List<Contact> lstMatchingContacts {get;set;}
    public String lastName {get;set;}
    public String firstName {get;set;}
    public String salutation {get;set;}
    //currently a date does not get displayed with a date picker unless part of an sObject so use a tempory contact record to do this
    public Contact tempBirthDate {get;set;}
    public String gender {get;set;}
    public String mainphone {get;set;}
    public String mobilephone {get;set;}
    public String emailaddress {get;set;}
    public String postalcode {get;set;}
    public String street {get;set;}
    public String mailingCity {get;set;}
    public String mailingState {get;set;}
    public String Constituency {get;set;}
    public String Local_authority {get;set;}
    public String Primary_care_trust {get;set;}
    public String Clinical_Commissioning_Group {get;set;}
    public String Ward {get;set;}
    
    public String selectedRelContactId {get;set;}
    public String selectedRelContactName {get;set;}
    public Boolean ignoreAndCreate {get;set;}
    public Boolean hasAddress {get;set;}
    public String recId {get;set;}
    
    public AccountLink__c accountLink {get;set;}
    
    public Boolean isProfessional {get;set;}
    public Boolean searchDone {get;set;}
    public string sourceOrgID {get;set;}
    public Map<Id,String> mapOfRecordTypes;

    /*Dec 2014 Avariable to capture if this new user is being added as a User Involvement Participant
               In that case the re-direct will be adjusted with a retUrl value to the Participant record
     */
    public Boolean isParticipant {get;set;}
    
    
    //Constructor
    public NewPersonController(ApexPages.StandardController stdCon){
        recRelationship = new SFDC_Contact_Connector__c();
        relContact = (Contact)stdCon.getRecord();
        if(relContact==null) relContact = new Contact();
        lstMatchingContacts = new List<Contact>();
        recId = ApexPages.currentPage().getParameters().get('recId');
        sourceOrgID = ''; 
        sourceOrgID = ApexPages.currentPage().getParameters().get('orgId');
        tempBirthDate = new Contact();
        
        /* Start Update : Dec 2014. Added to support pre-filling fields on the form 
           isParticipant will allow re-direction back to the Participant record after the 
           Person record is saved.          
        */
        
        lastName = ApexPages.currentPage().getParameters().get('lastName');
        firstName = ApexPages.currentPage().getParameters().get('firstName');
        postalCode = ApexPages.currentPage().getParameters().get('postalCode');
        String sDate = ApexPages.currentPage().getParameters().get('birthDate');        
        if ( sDate !=null && sDate !='') {
            tempBirthDate.birthDate = Date.parse(sDate);
        }
        String isP = ApexPages.currentPage().getParameters().get('participant');
        isParticipant=false;
        if ( isP !=null && isP =='true') {
            isParticipant = true;
        }   
        
        /* End update : Dec 2014 */
        
        
        if(recId!=null){
            relContact.RecordTypeId=[SELECT Id,Name FROM RecordType WHERE SobjectType='Contact' and Id=:recId].id;
            //relContact.RecordTypeId=recId;
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ recId: '+recId);
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ relContact.RecordTypeId: '+relContact.RecordTypeId);
        }
        //Id contactId = ApexPages.currentPage().getParameters().get('id');
        
        // Default is a person type of contact, set isProfessional to false.
        isProfessional = false;
        accountLink  = new AccountLink__c();
        
        mapOfRecordTypes = new Map<Id,String>();
        getContactRecordTypes();
        SetCurrentRecordTypeToProfessionalWrapper();
        
        if(isProfessionalRecord(getSelectedRecordTypeName())) {
            isProfessional = true;
        }
        searchDone = false;
              
    }

   private Boolean isProfessionalRecord(string recordTypeName) {
        
        Boolean Professional = true;
        
        if(recordTypeName == 'Person with Dementia') {
            //System.Debug('GUNISH : PWD');
            Professional = false;
        } else if (recordTypeName == 'Carer of Person with Dementia') {
            //System.Debug('GUNISH : CPD');
            Professional = false;
        } else if(recordTypeName == 'Friend or Family of Person with Dementia') {
            //System.Debug('GUNISH : FFPD');
            Professional = false;
        } else {
            //System.Debug('GUNISH : No Match / Professional');
            Professional = true;
        }
        
        return Professional;
   }
   public Id SetCurrentRecordTypeToProfessional() {
        System.Debug('GUNISH : Here');
        Id returnValue;
        if(sourceOrgID != '' && sourceOrgID != null) {
            for(Id trecordTypeID : mapOfRecordTypes.keySet()) {
                if(isProfessionalRecord(mapOfRecordTypes.get(trecordTypeID))){
                    returnValue = trecordTypeID;
                    isProfessional = true;
                    accountLink.Account__c = sourceOrgID;
                }
            }
        } else {
            
        
            if(mapOfRecordTypes.keySet().size() == 1){
            for(Id trecordTypeID : mapOfRecordTypes.keySet()) {
                if(isProfessionalRecord(mapOfRecordTypes.get(trecordTypeID))){
                    returnValue = trecordTypeID;
                    isProfessional = true;
                    //accountLink.Account__c = sourceOrgID;
                    
                    if (mapOfRecordTypes.get(trecordTypeID) == 'Collector'){
                    Id CollectorAccountId = [select Id from Account
                                        where Name = 'Alzheimers Society'].Id;
                    accountLink.Account__c = CollectorAccountId;
                    }
                     
                    
                    
                    
                }
            }
            }
        }
        return returnValue; 
   }
   
   public void SetCurrentRecordTypeToProfessionalWrapper() {
        this.recordTypeId = SetCurrentRecordTypeToProfessional();
   }
   
   //Returns Recordtypes of Contact available for current User.
   public List<SelectOption> getContactRecordTypes(){
        List<SelectOption> lstRecordTypes = new List<SelectOption>();
        //Retrive all Contact RecordTypes
        for(RecordTypeInfo rec: Contact.SObjectType.getDescribe().getRecordTypeInfosById().values()){
          //Check if recordtype is visible/available for current user.
          if(rec.isAvailable() && rec.getName()!='Master'){
              mapOfRecordTypes.put(rec.getRecordTypeId(), rec.getName());
              lstRecordTypes.add(new SelectOption(rec.getRecordTypeId(),rec.getName()));
          }
        }       
        
        return lstRecordTypes;
   }
    
    //Prepare RecordType list for Relationship Object (Ideally Personall/Professinal)
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> lstRecordTypes = new List<SelectOption>();
        for(RecordType rec: [SELECT Id,Name FROM RecordType WHERE SobjectType='Contact']){
            lstRecordTypes.add(new SelectOption(rec.id,rec.name));
        }
        return lstRecordTypes;
    }
    public List<selectOption> getTitles() {
    List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('', '--None--')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        //options.add(new selectOption('Mr','Mr'));
        Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
        for(Schema.PicklistEntry f  :  fieldResult.getPicklistValues() )
          {
          String sTitle = f.getValue();
          options.add(new selectOption(sTitle,sTitle)); 
          }
        return options; //return the picklist options
    }
    public List<selectOption> getGenders() {
    List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('', '--None--')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        Schema.DescribeFieldResult fieldResult = Contact.Gender__c.getDescribe();
        for(Schema.PicklistEntry f  :  fieldResult.getPicklistValues() )
          {
          String sGender = f.getValue();
          options.add(new selectOption(sGender ,sGender )); 
          }
        return options; //return the picklist options
    }   
    public PageReference RecordTypeChanged(){
        relContact = new Contact(RecordTypeId=recordTypeId);
        System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! relContact.RecordTypeId: '+relContact.RecordTypeId);
        SetVisibilityOfProfessionalFieldsSection();
        return null;
    }
    
    private void SetVisibilityOfProfessionalFieldsSection() {
        
        String recordTypeName = getSelectedRecordTypeName();
        //System.Debug('GUNISH RTN :' + recordTypeName);
        
        if(recordTypeName == 'Person with Dementia') {
            //System.Debug('GUNISH : PWD');
            isProfessional = false;
        } else if (recordTypeName == 'Carer of Person with Dementia') {
            //System.Debug('GUNISH : CPD');
            isProfessional = false;
        } else if(recordTypeName == 'Friend or Family of Person with Dementia') {
            //System.Debug('GUNISH : FFPD');
            isProfessional = false;
        } else {
            //System.Debug('GUNISH : No Match / Professional');
            isProfessional = true;
        }
        
    }
    
    
    //Returns RecordType name for a Relationship RecordType Id.
    public string getSelectedRecordTypeName(){
       //Check if User has selected RecordType on VF Page.
       if(recordTypeId==null){
            //each profile will have a default Person Record Type, 
            if(recId==null){
                RecordType rt;
                String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
                if(usrProfileName=='CRS' || usrProfileName=='CRS and BDC' || usrProfileName=='CRS Read Only' || usrProfileName=='CRS - One App User' || usrProfileName=='CRS and Service Data Manager'  || usrProfileName=='CEO'){
                    rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Person with Dementia'];
                    recordTypeId = rt.Id;
                    system.debug('returning PWD: '+recordTypeId);
                    return rt.Name;
                }else if(usrProfileName=='External Affairs' || usrProfileName=='External Affairs - Administrator' || usrProfileName=='Facilities - Platform' || usrProfileName=='Risk'){
                    rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Professional / Stakeholder'];
                    recordTypeId = rt.Id;
                    system.debug('returning P/S: '+recordTypeId);
                    return rt.Name;
                }else if(usrProfileName=='Fundraising'){
                    rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Collector'];
                    recordTypeId = rt.Id;
                    system.debug('returning Collector: '+recordTypeId);
                    return rt.Name;
                }else if(usrProfileName.contains('Trading')){
                    rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name LIKE '%Trading%'];
                    recordTypeId = rt.Id;
                    system.debug('returning Trading: '+recordTypeId);
                    return rt.Name;
                }else{
                    rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where SobjectType = 'Contact' and name = 'Person with Dementia'];
                    recordTypeId = rt.Id;
                    system.debug('returning else PWD: '+recordTypeId);
                    return rt.Name;
                }
            }else {
                system.debug('returning RT from url parameter: '+recordTypeId);
                return [SELECT Id,Name FROM RecordType WHERE SobjectType='Contact' and id=:recId].Name;
            }
       }
       system.debug('++recordTypeId+++++++++++++'+recordTypeId);
       system.debug('+++++++++++++++++++++++++++'+mapOfRecordTypes.get(recordTypeId));
       //return Contact.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
       return mapOfRecordTypes.get(recordTypeId);
    }
    
    public Boolean IsValidPostCode(string pPostcode) {
        boolean isValid = false;
        // Regular Expression for Postcode
        String postcodeRegex= '^([A-PR-UWYZa-pr-uwyz]([0-9]{1,2}|([A-HK-Ya-hk-y][0-9]|[A-HK-Ya-hk-y][0-9]([0-9]|[ABEHMNPRV-Yabehmnprv-y]))|[0-9][A-HJKS-UWa-hjks-uw])\\ {0,1}[0-9][ABD-HJLNP-UW-Zabd-hjlnp-uw-z]{2}|([Gg][Ii][Rr]\\ 0[Aa][Aa])|([Ss][Aa][Nn]\\ {0,1}[Tt][Aa]1)|([Bb][Ff][Pp][Oo]\\ {0,1}([Cc]\\/[Oo]\\ )?[0-9]{1,4})|(([Aa][Ss][Cc][Nn]|[Bb][Bb][Nn][Dd]|[BFSbfs][Ii][Qq][Qq]|[Pp][Cc][Rr][Nn]|[Ss][Tt][Hh][Ll]|[Tt][Dd][Cc][Uu]|[Tt][Kk][Cc][Aa])\\ {0,1}1[Zz][Zz]))$';
        //'^([A-PR-UWYZa-pr-uwyz]([0-9]{1,2}|([A-HK-Ya-hk-y][0-9]|[A-HK-Ya-hk-y][0-9]([0-9]|[ABEHMNPRV-Yabehmnprv-y]))|[0-9][A-HJKS-UWa-hjks-uw])\ {0,1}[0-9][ABD-HJLNP-UW-Zabd-hjlnp-uw-z]{2}|([Gg][Ii][Rr]\ 0[Aa][Aa])|([Ss][Aa][Nn]\ {0,1}[Tt][Aa]1)|([Bb][Ff][Pp][Oo]\ {0,1}([Cc]\/[Oo]\ )?[0-9]{1,4})|(([Aa][Ss][Cc][Nn]|[Bb][Bb][Nn][Dd]|[BFSbfs][Ii][Qq][Qq]|[Pp][Cc][Rr][Nn]|[Ss][Tt][Hh][Ll]|[Tt][Dd][Cc][Uu]|[Tt][Kk][Cc][Aa])\ {0,1}1[Zz][Zz]))$');
        Pattern MyPattern = Pattern.compile(postcodeRegex);

        // then instantiate a new Matcher object �MyMatcher�
        Matcher MyMatcher = MyPattern.matcher(pPostcode);

        if (!MyMatcher.matches()) {
            isValid = false;
        }else{
              isValid = true;
        }
        return isValid;
    }

    public PageReference doSearch(){
            Boolean isError = false;
            if(firstName==null &&  salutation==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter First Name or Title.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if(lastName==null || lastName==''){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Last Name.');
                ApexPages.addMessage(message);
                isError = true;
            }
             if((postalcode==null || postalcode=='')  &&  (tempBirthDate.MailingCountry==null || 
                                                        tempBirthDate.MailingCountry=='United Kingdom') && 
                            (getSelectedRecordTypeName()=='Carer of Person with Dementia' ||
                             getSelectedRecordTypeName()=='Person with Dementia' ||
                             getSelectedRecordTypeName()=='Friend or Family of Person with Dementia')){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'You will need a Postcode for a UK address to create a record type of ' + getSelectedRecordTypeName() + '.');
                ApexPages.addMessage(message);
                //isError = true;
            }
            if((postalcode==null || postalcode=='') &&  tempBirthdate.birthdate==null && 
                            (getSelectedRecordTypeName()=='Carer of Person with Dementia' ||
                             getSelectedRecordTypeName()=='Person with Dementia' ||
                             getSelectedRecordTypeName()=='Friend or Family of Person with Dementia')){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter either a Postcode, a Date of Birth, or both.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if((tempBirthdate.birthdate!=null && tempBirthdate.birthdate > System.today().addYears(-18)) 
                            && tempBirthdate.birthdate<=System.today() &&
                            (getSelectedRecordTypeName()=='Carer of Person with Dementia' ||
                             getSelectedRecordTypeName()=='Person with Dementia' ||
                             getSelectedRecordTypeName()=='Friend or Family of Person with Dementia')){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Warning,'The Date of Birth entered is for a person under 18 years old.');
                ApexPages.addMessage(message);
                //isError = true;
            }
            if(getSelectedRecordTypeName()!='Carer of Person with Dementia' &&
                             getSelectedRecordTypeName()!='Person with Dementia' &&
                             getSelectedRecordTypeName()!='Friend or Family of Person with Dementia' &&
                             (PostalCode==null || PostalCode=='') && 
                             accountLink.Account__c==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Organisation name.');
                ApexPages.addMessage(message);
                isError = true;
            }else if(getSelectedRecordTypeName()!='Carer of Person with Dementia' &&
                             getSelectedRecordTypeName()!='Person with Dementia' &&
                             getSelectedRecordTypeName()!='Friend or Family of Person with Dementia'&& 
                             accountLink.Account__c==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Organisation name.');
                ApexPages.addMessage(message);
                isError = true;
            }
            //do not allow professionals to be added if no address on organisation
            if(getSelectedRecordTypeName()!='Carer of Person with Dementia' &&
                             getSelectedRecordTypeName()!='Person with Dementia' &&
                             getSelectedRecordTypeName()!='Friend or Family of Person with Dementia'&& 
                             accountLink.Account__c!=null){ 
                Account selectedAccount = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                                    From Account a where id=:accountLink.Account__c];                
                if ((selectedAccount.BillingPostalCode==null)||(selectedAccount.BillingPostalCode=='')){             
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The Organisation you have selected does not have a postcode.  The Organisation\'s record has to be changed before people can be associated with it.');
                    ApexPages.addMessage(message);
                    isError = true;  }       
                             
            }                 
            if(tempBirthdate.birthdate>System.today()){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Date of Birth must be in the past.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if((postalcode!=null && postalcode!='')  &&  (tempBirthDate.MailingCountry==null || 
                                                        tempBirthDate.MailingCountry=='United Kingdom')  
                                                  && !IsValidPostCode(PostalCode)){
                           ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Postcode formatting is wrong. This will affect the ability of the system to search for matching records.');
                ApexPages.addMessage(message);
                //isError = true;;
            
            }
            if(isError == true) {
                return null;
            }
            /**
            START : Data Scout Integration
            
            Contact c1 = new Contact(DSE__DS_Synchronize__c=true, FirstName=firstName, LastName=lastName, MailingPostalCode =relContact.MailingPostalCode, Birthdate =tempBirthdate.birthdate);
            c1.Email = relContact.Email;
            //if the user has given address details, search for duplicates using these details
            if(relContact.MailingPostalCode!=null || MailingCity!=null || MailingCountry!=null || MailingState!=null || street!=null){
                c1.MailingCity = MailingCity;
                c1.MailingCountry = MailingCountry;
                c1.MailingState = MailingState;
                c1.MailingStreet = street;
                c1.MailingPostalCode = relContact.MailingPostalCode;
            //for Personal relationships and no address on first contact, display error message
            }else if((getSelectedRecordTypeName()=='Carer of Person with Dementia' || getSelectedRecordTypeName()=='Person with Dementia' || getSelectedRecordTypeName()=='Friend or Family of Person with Dementia') && 
                    (MailingCity!=null && MailingCountry!=null && MailingState!=null && street!=null && relContact.MailingPostalCode!=null)){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter a Date of Birth.');
                ApexPages.addMessage(message);
                return null;
            //for Professional relationships, get the address details from organisation
            }else if(accountLink.Account__c!=null && 
                             getSelectedRecordTypeName()!='Carer of Person with Dementia' &&
                             getSelectedRecordTypeName()!='Person with Dementia' &&
                             getSelectedRecordTypeName()!='Friend or Family of Person with Dementia'){
                Account organisation = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                        From Account a where id = :accountLink.Account__c];
                System.debug('33333333333333333333333333333333 organisation:'+organisation);
                c1.MailingCity = organisation.BillingCity;
                c1.MailingCountry = organisation.BillingCountry;
                c1.MailingState = organisation.BillingState;
                c1.MailingStreet = organisation.BillingStreet;
                c1.MailingPostalCode = organisation.BillingPostalCode;
            }   
                
            // Create a Set of search sources
            Set<String> sSources =  new Set<String>{'Contact', 'Lead'};
            
            ///** Implement fuzzySearch, which is the default one called from the main screens. On main DS screens, fuzzySearch is done by defailt on
                Lead as well as Contacts. Hence, the parameter 'sSources' has Contact as well as 'Lead' object names in it.
                Store the search results in a list of Beans /
            //  
            //List<DSE__DS_Bean__c> beans = DSE.API_DuplicateSearch.basicSearch(c1,'AND',sSources,null); 
            List<DSE__DS_Bean__c> beans = DSE.API_DuplicateSearch.fuzzySearch(c1,sSources,null); 
            ignoreAndCreate=false;
            //get all the contact Ids from the list returned
            Set<Id> contactIds = new Set<Id>();
            for(DSE__DS_Bean__c  contactBean: beans){
                contactIds.add(contactBean.DSE__DS_Contact__c);
                System.debug('???????????????????????????????? contactBean.DSE__DS_Score__c: '+contactBean.DSE__DS_Score__c);
                if(contactBean.DSE__DS_Score__c<300)  
                    ignoreAndCreate=true;
            }
            
            END : Data Scout Integration
            */
            
            /** 
            OVERRIDE DATASCOUT : 
            
            DeDuper Begin
            */
            
                
            //try
                
                DeDuper objDeDuper = new DeDuper();
                Id OrganisationIs; 
                
                if(isProfessionalRecord(getSelectedRecordTypeName())) { 
                    Set<Id> contactIds = new Set<Id>();                                
                    contactIds = objDeDuper.SearchProfessionals(lastName,accountLink.Account__c);   
                    if(contactIds.size() > 0) {
                        ignoreAndCreate = true;
                    //force users to look at bottom of form and if necessary use the ignore and create button
                        searchDone = false;
                        
                    lstMatchingContacts = [Select id, Name, Email, Record_Type_Name__c, RecordTypeId, Diagnosis__c, MailingStreet, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Primary_care_trust__c, Clinical_Commissioning_Group__c,
                                    Local_authority__c, Constituency__c, Salutation from Contact where id in :contactIds];
                        
                        
                    }
                    else {
                        searchDone = true;
                    }
                } else {
                    
                    lstMatchingContacts = objDeDuper.SearchNonProfessional(relContact, lastName, firstName, tempBirthdate.birthdate, PostalCode);
                    if(lstMatchingContacts.size() > 0) {
                        ignoreAndCreate = true;
                    //force users to look at bottom of form and if necessary use the ignore and create button
                        searchDone = false;
                    }
                    else {
                        searchDone = true;
                    }
                }
                
                //ignoreAndCreate = false;
                
            /** 
            OVERRIDE DATASCOUT : 
            
            DeDuper End
            */
            //found duplicates, return warning
             if(lstMatchingContacts.size()>0){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Matching people have been found, please use one of the two buttons at the bottom of the screen to continue.');
                ApexPages.addMessage(message);
            }else{
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'No matches found');
                ApexPages.addMessage(message);
            }                        
            return null;
       
    }
    
    /**
        This method handler will allow user to create new Relationship record.
        if the dupe contact is not selected:
        1)run validations
        2)create relContact 
        */
    public PageReference createPerson(){
        system.debug('>>>>>>>>>>>>>> createPerson' );
        if(selectedRelContactId==null || selectedRelContactId==''){
            system.debug('#############no dupes selected-selectedRelContactId:#############'+selectedRelContactId);
            if(firstName==null &&  salutation==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter First Name or Title.');
                ApexPages.addMessage(message);
                return null;
            }
            if(lastName==null || lastName==''){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Last Name.');
                ApexPages.addMessage(message);
                return null;
            }
            if((postalcode==null || postalcode=='') &&  (tempBirthDate.MailingCountry==null || 
                                                        tempBirthDate.MailingCountry=='United Kingdom') && 
                            (getSelectedRecordTypeName()=='Carer of Person with Dementia' ||
                             getSelectedRecordTypeName()=='Person with Dementia' ||
                             getSelectedRecordTypeName()=='Friend or Family of Person with Dementia')){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Error,'You must enter a Postcode for a UK address to create a record type of ' + getSelectedRecordTypeName() + '.');
                ApexPages.addMessage(message);
                return null;
            }
            if(PostalCode==null &&  tempBirthdate.birthdate==null && 
                            (getSelectedRecordTypeName()=='Carer of Person with Dementia' ||
                             getSelectedRecordTypeName()=='Person with Dementia' ||
                             getSelectedRecordTypeName()=='Friend or Family of Person with Dementia')){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter either a Postcode, a Date of Birth, or both.');
                ApexPages.addMessage(message);
                return null;
            }
            if(getSelectedRecordTypeName()!='Carer of Person with Dementia' &&
                             getSelectedRecordTypeName()!='Person with Dementia' &&
                             getSelectedRecordTypeName()!='Friend or Family of Person with Dementia' &&
                             (PostalCode==null || PostalCode=='') && 
                             accountLink.Account__c==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Organisation name.');
                ApexPages.addMessage(message);
                return null;
            }else if(getSelectedRecordTypeName()!='Carer of Person with Dementia' &&
                             getSelectedRecordTypeName()!='Person with Dementia' &&
                             getSelectedRecordTypeName()!='Friend or Family of Person with Dementia'&& 
                             accountLink.Account__c==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Organisation name.');
                ApexPages.addMessage(message);
                return null;
            }
            //do not allow professionals to be added if no address on organisation
            if(getSelectedRecordTypeName()!='Carer of Person with Dementia' &&
                             getSelectedRecordTypeName()!='Person with Dementia' &&
                             getSelectedRecordTypeName()!='Friend or Family of Person with Dementia'&& 
                             accountLink.Account__c!=null){ 
                Account selectedAccount = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                                    From Account a where id=:accountLink.Account__c];                
                if ((selectedAccount.BillingPostalCode==null)||(selectedAccount.BillingPostalCode=='')){             
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The Organisation you have selected does not have a postcode.  The Organisation\'s record has to be changed before people can be associated with it.');
                    ApexPages.addMessage(message);
                    return null;  }       
                             
            }
            if(tempBirthdate.birthdate>System.today()){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Date of Birth must be in the past.');
                ApexPages.addMessage(message);
                return null;
            }
            if((postalcode!=null && postalcode!='')  &&  (tempBirthDate.MailingCountry==null || 
                                                        tempBirthDate.MailingCountry=='United Kingdom')  
                                                  && !IsValidPostCode(PostalCode)){
                           ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Postcode formatting is wrong. This will affect the ability of the system to search for matching records.');
                ApexPages.addMessage(message);
                return null;
            
            }    
            /**
            START : Data Scout Integration
            
            Contact c1 = new Contact(DSE__DS_Synchronize__c=true, FirstName=firstName, LastName=lastName, MailingPostalCode =relContact.MailingPostalCode, Birthdate =tempBirthdate.birthdate);
            c1.Email = relContact.Email;
            //if the user has given address details, search for duplicates using these details
            if(relContact.MailingPostalCode!=null || MailingCity!=null || MailingCountry!=null || MailingState!=null || street!=null){
                c1.MailingCity = MailingCity;
                c1.MailingCountry = MailingCountry;
                c1.MailingState = MailingState;
                c1.MailingStreet = street;
                c1.MailingPostalCode = relContact.MailingPostalCode;
            //for Personal relationships and no address on first contact, display error message
            }else if((getSelectedRecordTypeName()=='Carer of Person with Dementia' || getSelectedRecordTypeName()=='Person with Dementia' || getSelectedRecordTypeName()=='Friend or Family of Person with Dementia') && 
                    (MailingCity!=null && MailingCountry!=null && MailingState!=null && street!=null && relContact.MailingPostalCode!=null)){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter a Date of Birth.');
                ApexPages.addMessage(message);
                return null;
            //for Professional relationships, get the address details from organisation
            }else if(accountLink.Account__c!=null && 
                             getSelectedRecordTypeName()!='Carer of Person with Dementia' &&
                             getSelectedRecordTypeName()!='Person with Dementia' &&
                             getSelectedRecordTypeName()!='Friend or Family of Person with Dementia'){
                Account organisation = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                        From Account a where id = :accountLink.Account__c];
                System.debug('33333333333333333333333333333333 organisation:'+organisation);
                c1.MailingCity = organisation.BillingCity;
                c1.MailingCountry = organisation.BillingCountry;
                c1.MailingState = organisation.BillingState;
                c1.MailingStreet = organisation.BillingStreet;
                c1.MailingPostalCode = organisation.BillingPostalCode;
            }   
                
            // Create a Set of search sources
            Set<String> sSources =  new Set<String>{'Contact', 'Lead'};
            
            /** Implement fuzzySearch, which is the default one called from the main screens. On main DS screens, fuzzySearch is done by defailt on
                Lead as well as Contacts. Hence, the parameter 'sSources' has Contact as well as 'Lead' object names in it.
                Store the search results in a list of Beans
                
            //List<DSE__DS_Bean__c> beans = DSE.API_DuplicateSearch.basicSearch(c1,'AND',sSources,null); 
            List<DSE__DS_Bean__c> beans = DSE.API_DuplicateSearch.fuzzySearch(c1,sSources,null); 
            
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
            
                
            //try{
                Set<Id> contactIds = new Set<Id>();
                DeDuper objDeDuper = new DeDuper();
                Id OrganisationIs; 
                 system.debug('>>>>>>>>>>>>>>' + getSelectedRecordTypeName());
                 // Populate the Organization Related Information.
                 if(isProfessionalRecord(getSelectedRecordTypeName()) && relContact.mailingpostalcode == null && getSelectedRecordTypeName()!='Collector') {
                        Account testAccount = [select id, name, billingpostalcode, billingcity, billingstate, billingcountry, billingstreet from account where id = : accountlink.account__c];
                        postalcode= testAccount.billingpostalcode;
                        street = testAccount.billingstreet;
                        MailingCity = testAccount.billingcity;
                        MailingState = testAccount.billingstate;
                        tempBirthDate.MailingCountry = testAccount.billingcountry;
                    }
                relContact.AccountId = accountLink.Account__c;               
                if(isProfessionalRecord(getSelectedRecordTypeName())) {                                 
                        contactIds = objDeDuper.SearchProfessionals(lastName,accountLink.Account__c);
                    
                    // Populate the Organization Related Information.
                    if(relContact.mailingpostalcode == null && getSelectedRecordTypeName()!='Collector') {
                        Account testAccount = [select id, name, billingpostalcode, billingcity, billingstate, billingcountry, billingstreet from account where id = : accountlink.account__c];
                        postalcode = testAccount.billingpostalcode;
                        street = testAccount.billingstreet;
                        MailingCity = testAccount.billingcity;
                        MailingState = testAccount.billingstate;
                        tempBirthDate.MailingCountry = testAccount.billingcountry;
                    }
                    relContact.AccountId = accountLink.Account__c;
                    lstMatchingContacts = [Select id, Name, Email, Record_Type_Name__c, RecordTypeId, Diagnosis__c, MailingStreet, MailingState, 
                                            MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Primary_care_trust__c, Clinical_Commissioning_Group__c,
                                            Local_authority__c, Constituency__c, Salutation from Contact where id in :contactIds];
                                
                } else {
                    
                    lstMatchingContacts= objDeDuper.SearchNonProfessional(relContact, lastName, firstName, tempBirthdate.birthdate, PostalCode);
                }
                
                ignoreAndCreate = false;
                if(lstMatchingContacts.size() > 0) {
                    ignoreAndCreate = true;
                }
            /** 
            OVERRIDE DATASCOUT : 
            
            DeDuper End
            */
            
            //if no duplicates are found, create contact and then go to contacts page
            if(lstMatchingContacts.size()<1){
                try{
                    //set variables captured as inputtext on page
                    relContact.Salutation=salutation;
                    relContact.FirstName=firstName;
                    relContact.LastName=lastName;
                    relContact.Birthdate = tempBirthdate.birthdate;
                    relContact.Gender__c = gender;
                    relContact.HomePhone = mainphone;
                    relContact.MobilePhone = mobilephone;
                    relContact.email = TempBirthDate.email;
                    relContact.MailingPostalCode = postalcode;
                    relContact.MailingStreet = street;
                    relContact.MailingCity = mailingCity;
                    relContact.MailingCountry = tempBirthdate.mailingCountry;
                    relContact.MailingState = MailingState;
                    relContact.Constituency_Derived__c= Constituency ;
                    relContact.Local_authority__c= Local_authority;
                    relContact.Primary_care_trust__c= Primary_care_trust;
                    relContact.Clinical_Commissioning_Group__c = Clinical_Commissioning_Group;
                    relContact.Ward__c= Ward;
                    //set person record type
                    if(getSelectedRecordTypeName()!=null){
                        relContact.RecordTypeId = recordTypeId;
                    }
                    System.debug('c getSelectedRecordTypeName(): '+getSelectedRecordTypeName());
                    System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!! relContact.RecordTypeId: '+relContact.RecordTypeId);
                    insert relContact; 
                    //return new Pagereference('/'+relContact.Id+'/e?retURL=%2F'+relContact.Id); //return to new contact details page
                
                /* Start Update Dec 2014
               Append a parameter to tell the form to re-direct back to a participant record after saving 
               This code will create a new Participant Record
               */    
            
                String sUrl = '/'+relContact.Id+'/e?retURL=%2F';
                if ( isParticipant ) {
                    
                    system.debug('Creating a Participant');
                    UI_Participant__c uip= new UI_Participant__c();
                    uip.Contact__c = relContact.Id;
                    uip.Contact__c=relContact.id;
                    uip.Name = relContact.Name;
                    uip.Status__c = 'Unconfirmed'; 
                    insert uip;
                    
                    sUrl += uip.id + '%2Fe%3FretURL=%2F' + uip.id;                              
                } else {
                    sUrl += relContact.Id;
                }           
                
                return new Pagereference(sUrl); //return to new contact details page
                
            /* End Update Dec 2014 */
                
                
                
                
                

                }catch(Exception ex){ 
                    //ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while creating new Person.');
                    //ApexPages.addMessage(message);
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
                    ApexPages.addMessage(message);
                    return null;
                }
            }
             if(lstMatchingContacts.size()>0){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Matching people have been found, please use one of the two buttons at the bottom of the screen to continue.');
                ApexPages.addMessage(message);
            }
            //if dupes are found, return the contact list to the page
            system.debug('#############dupes found-lstMatchingContacts:#############'+lstMatchingContacts);
            ignoreAndCreate = true;
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Matching people have been found, please use one of the two buttons at the bottom of the screen to continue.');
            ApexPages.addMessage(message);
            return null;
        /**
        if the dupe contact is selected:
        1)use the dupe contact as the relContact
        2)create relationship
        */
        }else if(selectedRelContactId!=null){
            try{
                //get the details of the selected dupe contact
                Contact dupeContact = [Select c.Email, c.Salutation, c.Name, c.MobilePhone, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, 
                c.MailingCity, c.LastName, c.Id, c.Gender__c, c.FirstName, c.Diagnosis__c, c.Date_of_diagnosis__c, c.Contact_Full_Name__c, c.Consent_Status__c, 
                c.Birthdate, c.Active__c, c.Record_Type_Name__c, c.RecordTypeId, c.AccountId, c.Ward__c, c.Primary_care_trust__c, c.Clinical_Commissioning_Group__c, c.Local_authority__c, 
                c.Constituency__c, Constituency_Derived__c From Contact c where id = :selectedRelContactId];

                return new Pagereference('/'+dupeContact.Id+'/e?retURL=%2F'+dupeContact.Id); //return to contact details page
            }catch(Exception ex){ 
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while selecting existing Person.');
                ApexPages.addMessage(message);
                return null;
            }
        }
        return new Pagereference('/apex/NewPerson?id='+relContact.Id+'/e?retURL=%2F'+relContact.Id);
    }
    
    public PageReference ignoreCreatePerson(){
        try{
            Boolean isError = false;
            //create related contact first
            if(firstName==null &&  salutation==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter First Name or Title.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if(lastName==null || lastName==''){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Last Name.');
                ApexPages.addMessage(message);
                isError = true;
            }
            if((postalcode==null || postalcode=='') &&  (tempBirthDate.MailingCountry==null || 
                                                        tempBirthDate.MailingCountry=='United Kingdom') && 
                            (getSelectedRecordTypeName()=='Carer of Person with Dementia' ||
                             getSelectedRecordTypeName()=='Person with Dementia' ||
                             getSelectedRecordTypeName()=='Friend or Family of Person with Dementia')){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.Error,'You must enter a Postcode for a UK address to create a record type of ' + getSelectedRecordTypeName() + '.');
                ApexPages.addMessage(message);
                isError = true;
            }else if((postalcode!=null && postalcode!='')  &&  (tempBirthDate.MailingCountry==null || 
                                                        tempBirthDate.MailingCountry=='United Kingdom')  
                                                  && !IsValidPostCode(PostalCode)){
                           ApexPages.Message message = new ApexPages.message(ApexPages.severity.Error,'Postcode formatting is wrong.');
                ApexPages.addMessage(message);
                isError = true;
            }           
            //if(relContact.MailingPostalCode==null &&  tempBirthdate.birthdate==null && !isProfessionalRecord(getSelectedRecordTypeName())){
            //    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter either a Postcode, a Date of Birth, or both.');
            //    ApexPages.addMessage(message);
            //    isError = true;
            //}
            if(isProfessionalRecord(getSelectedRecordTypeName()) && (PostalCode==null || PostalCode=='') && accountLink.Account__c==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Organisation name.');
                ApexPages.addMessage(message);
                isError = true;
            }else if(getSelectedRecordTypeName()=='Professional' && accountLink.Account__c==null){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter Organisation name.');
                ApexPages.addMessage(message);
                isError = true;
            }
            //do not allow professionals to be added if no address on organisation
            if(getSelectedRecordTypeName()!='Carer of Person with Dementia' &&
                             getSelectedRecordTypeName()!='Person with Dementia' &&
                             getSelectedRecordTypeName()!='Friend or Family of Person with Dementia'&& 
                             accountLink.Account__c!=null){ 
                Account selectedAccount = [Select a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity 
                                                    From Account a where id=:accountLink.Account__c];                
                if ((selectedAccount.BillingPostalCode==null)||(selectedAccount.BillingPostalCode=='')){             
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The Organisation you have selected does not have a postcode.  The Organisation\'s record has to be changed before people can be associated with it.');
                    ApexPages.addMessage(message);
                    isError = true;  }       
                             
            } 
            if(tempBirthdate.birthdate>System.today()){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Date of Birth must be in the past.');
                ApexPages.addMessage(message);
                isError = true;
            }
    
            if (isError == true) {
                return null;}
                
             // Populate the Organization Related Information.
            if(isProfessionalRecord(getSelectedRecordTypeName()) && relContact.mailingpostalcode == null) {
                Account testAccount = [select id, name, billingpostalcode, billingcity, billingstate, billingcountry, billingstreet from account where id = : accountlink.account__c];
                relContact.mailingpostalcode = testAccount.billingpostalcode;
                street = testAccount.billingstreet;
                MailingCity = testAccount.billingcity;
                MailingState = testAccount.billingstate;
                tempBirthDate.MailingCountry = testAccount.billingcountry;
            }
            relContact.AccountId = accountLink.Account__c;               
                
            relContact.Salutation=salutation;
            relContact.FirstName=FirstName;
            relContact.LastName=lastName;
            relContact.Birthdate=tempBirthdate.birthdate;
            relContact.Gender__c = gender;
            relContact.HomePhone = mainphone;
            relContact.MobilePhone = mobilephone;
            relContact.email = TempBirthDate.email;
            relContact.MailingPostalCode = postalcode;
            relContact.MailingStreet = street;
            relContact.MailingCity = mailingCity;
            relContact.MailingCountry = tempBirthdate.mailingCountry;
            relContact.MailingState = MailingState;
            relContact.Constituency_Derived__c= Constituency ;
            relContact.Local_authority__c= Local_authority;
            relContact.Primary_care_trust__c= Primary_care_trust;
            relContact.Clinical_Commissioning_Group__c = Clinical_Commissioning_Group;
            relContact.Ward__c= Ward;
            //set person record type
            /*if(getSelectedRecordTypeName()!=null){
                relContact.RecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where SObjectType='Contact' and DeveloperName=:getSelectedRecordTypeName()].Id;
            }*/
            relContact.RecordTypeId = recordTypeId;
            System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!! getSelectedRecordTypeName(): '+getSelectedRecordTypeName());
            System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!! relContact.RecordTypeId: '+relContact.RecordTypeId);
            insert relContact; 
            
            /* Start Update Dec 2014
               Append a parameter to tell the form to re-direct back to a participant record after saving 
               This code will create a new Participant Record
               */    
            
            String sUrl = '/'+relContact.Id+'/e?retURL=%2F';
            if ( isParticipant ) {
                
                system.debug('Creating a Participant');
                UI_Participant__c uip= new UI_Participant__c();
                uip.Contact__c = relContact.Id;
                uip.Contact__c=relContact.id;
                uip.Name = relContact.Name;
                uip.Status__c = 'Unconfirmed'; 
                insert uip;
                            
                sUrl += uip.id + '%2Fe%3FretURL=%2F' + uip.id;                              
            } else {
                sUrl += relContact.Id;
            }           
            
            return new Pagereference(sUrl); //return to new contact details page
            
            /* End Update Dec 2014 */
            
        }catch(Exception ex){ 
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while creating New Person.');
            ApexPages.addMessage(message);
            return null;
        }
    }
    
    
   /*Dec 2014. This action will create (or fetch) Participant record 
               The action is relevant if the user is creating a new Participant
               The action is called from the VF Page action button
               isParticipant=true  
   */ 
   public pageReference createParticipant()
   { 
   
      if(selectedRelContactId==null){ return null; }
      try{
       //get the details of the selected dupe contact
       Contact dupeContact = [Select id From Contact c where id = :selectedRelContactId];
       String sUrl = UIRestUtils.getParticipantUrl(dupeContact.id);
       return new Pagereference(sUrl); 
           
      }catch(Exception ex){ 
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while selecting existing Person.');
        ApexPages.addMessage(message);
        return null;
      }
      
   }

    
  //
  // TEST CASE
  // Dec '14, modified to include UI Participant code
  //
  private static testMethod void testRelationships()   
  {
        Contact c1 = getTestContact();     	
		
		PageReference pageRef = Page.CreateRelationship;
        test.setCurrentPage(pageRef); 
        pageRef.getParameters().put('Id', c1.Id);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c1);
        NewPersonController cnt = new NewPersonController(stdCon);
        
        doStandardTest(cnt);        
  }     
  
  private static testMethod void testCreateUIParticipant()
  {
  	Contact c1 = getTestContact();
  	
  	PageReference pageRef = Page.NewPerson;
    test.setCurrentPage(pageRef); 
    pageRef.getParameters().put('Id', c1.Id);
        
    ApexPages.StandardController stdCon = new ApexPages.StandardController(c1);
    NewPersonController cnt = new NewPersonController(stdCon);
  	
  	cnt.selectedRelContactId = getTestContact().id;
  	PageReference pr = cnt.createParticipant();
  	
  }
  
  private static testMethod void testRelationshipsUIParticipant()   
  {
        Contact c1 = getTestContact();     	
		
		PageReference pageRef = Page.NewPerson;
        test.setCurrentPage(pageRef); 
        pageRef.getParameters().put('Id', c1.Id);
        pageRef.getParameters().put('participant', 'true');
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c1);
        NewPersonController cnt = new NewPersonController(stdCon);
        
        doStandardTest(cnt);        
  }
  
  private static Contact getTestContact()
  {  	
  	    Contact c1 = new Contact(FirstName='one', LastName='related',MailingPostalCode ='SW1A 2AA', Birthdate =Date.Today());
        insert c1;        
        return c1;
  }
   
  private static Account getTestAccount()
  { 
        Account accRec = new Account(Name='External Test Org1',BillingPostalCode='SW1A 2AA',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id);
        insert accRec;        
        return accRec;
  }
        
  private static void doStandardTest(NewPersonController cnt)
  {
  		
        //CreateRelationshipController cnt = new CreateRelationshipController();
        
        cnt.getContactRecordTypes();
        cnt.getRecordTypes();
        
        cnt.RecordTypeChanged();
        cnt.recordTypeId=cnt.getRecordTypes().get(0).getValue();
        cnt.ignoreCreatePerson();
        cnt.getSelectedRecordTypeName();
        cnt.createPerson();
        cnt.getTitles();
        cnt.getGenders();
        cnt.IsValidPostCode('ABC123');
        cnt.IsValidPostCode('SW1A 2AA');
        cnt.doSearch();
        cnt.ignoreCreatePerson();
        cnt.CreatePerson();
                
        cnt.firstname='one';
        cnt.doSearch();
        cnt.ignoreCreatePerson();
        cnt.CreatePerson();
        cnt.lastName = 'related';
        cnt.tempBirthdate.birthdate=null;
        cnt.postalcode =null;
        cnt.recordtypeid= [SELECT Id FROM RecordType WHERE SobjectType='Contact' and Name = 'Person with Dementia'].id;
        cnt.doSearch();

        
        cnt.ignoreCreatePerson();
        cnt.CreatePerson();
        cnt.tempBirthdate.birthdate= Date.Today();
        cnt.doSearch();
        cnt.postalcode = 'SW1A 2AA';
        cnt.doSearch();

        System.debug('test test test 1');
        cnt.CreatePerson();
        System.debug('test test test 2');
        cnt.lastName = 'related' + Date.Today();
        cnt.CreatePerson();        
        cnt.ignoreCreatePerson();
        System.debug('test test test 3');
                
        RecordType recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Contact' and Name = 'Carer of Person with Dementia'];
        cnt.recordtypeid= recordType.Id;
        cnt.getSelectedRecordTypeName();
        cnt.RecordTypeChanged();
        cnt.recordtypeid= [SELECT Id FROM RecordType WHERE SobjectType='Contact' and Name = 'Friend or Family of Person with Dementia'].id;
        cnt.getSelectedRecordTypeName();
        cnt.RecordTypeChanged();
        cnt.recordtypeid= [SELECT Id FROM RecordType WHERE SobjectType='Contact' and Name = 'Professional / Stakeholder'].id;
        cnt.getSelectedRecordTypeName();
        cnt.RecordTypeChanged();
        cnt.doSearch();
        System.debug('test test test 4');


        System.AssertEquals(cnt.isProfessionalRecord('Carer of Person with Dementia'), false);
        System.AssertEquals(cnt.isProfessionalRecord('Friend or Family of Person with Dementia'),false);
        System.AssertEquals(cnt.isProfessionalRecord('Professional / Stakeholder'),true);

		Account accRec = getTestAccount();        
        cnt.sourceOrgID  = accRec.ID;
        Id profid = cnt.SetCurrentRecordTypeToProfessional(); 
        cnt.doSearch();
        cnt.CreatePerson();        
        cnt.ignoreCreatePerson();
    }    
}