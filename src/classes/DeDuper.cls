public with sharing class DeDuper {
    
    private List<Contact> SearchResults;    
    
    // Constructor.
    public DeDuper() {
        this.SearchResults = new List<Contact>();
    }
    
    public Set<Id> SearchProfessionals(string pLastName, Id pOrganizationId) {
        System.Debug('DD : SearchProfessionals');
        string LastName = pLastName + '%';
        list<Contact> listOfContacts;
        
        if((pLastName != null || pLastName != '') && (pOrganizationId != null || pOrganizationId != '')) {
            listOfContacts = [select id from Contact where LastName  LIKE: LastName and AccountId =:pOrganizationId];
        }
        
        Set<Id> SetOfIds = new Set<Id>();
        for(Contact contactItem : listOfContacts) {
            setOfIDs.add(contactItem.Id);
            //return listOfContacts;    
        }
        return SetOfIds;
    }
    
    public Set<Id> SearchNonProfessional(string pLastName, date pDoB, string pPostCode) {
        
        string LastName = pLastName + '%';
        date Birthdate = date.valueOf(pDoB);
        string PostCode = pPostCode + '%';
        string sDoB = string.valueOf(pDoB);
        System.Debug('Gunish Says String pDoB: ' + string.valueOf(pDoB));
        System.Debug('Gunish Says LastName: ' + string.valueOf(LastName));
        System.Debug('Gunish Result :' + ((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' )));
        list<Contact> listOfContacts;

        // Scenario 1, Last Name = X, DOB = X, PostCode = X.
        if((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' ) && (pPostCode != null && pPostCode != '')) {
            listOfContacts = [select id, LastName, Birthdate, MailingPostalCode from Contact where LastName LIKE:LastName and Birthdate =:Birthdate and MailingPostalCode LIKE:PostCode ];
            System.Debug('DD : Scenario 1');
        }
        
        // Scenario 2, Last Name = X, DOB = X, PostCode = 0. 
        else if((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' )) {
            listOfContacts = [select id, LastName, Birthdate, MailingPostalCode from Contact where LastName LIKE:LastName and Birthdate =:Birthdate ];
            System.Debug('Gunish : System Date OF Birth :' + pDoB);
            System.Debug('DD : Scenario 2');
        }
        
        // Scenario 3, Last Name = X, DOB = 0, PostCode = X. 
        else if((pLastName != null && pLastName != '') && (pPostCode != null && pPostCode != '')) {
            listOfContacts = [select id, LastName, Birthdate, MailingPostalCode from Contact where LastName LIKE:LastName and MailingPostalCode LIKE:PostCode ];
            System.Debug('DD : Scenario 3');
        }
        
        List<Contact> listOfAditionalContacts = new List<Contact>();
        // Find Additional Records.
        
        
        
        
        // Scenario 6, Last Name = X, DOB = X/NULL(DB), PostCode = X/NULL(DB).
        if((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' ) && (pPostCode != null && pPostCode != '')) {
            System.Debug('DD : Scenario 6');
            listOfAditionalContacts = [select id, LastName, Birthdate, MailingPostalCode  from Contact where LastName LIKE:LastName];
            System.Debug('Gunish :' + listOfAditionalContacts.size());
            for(Contact eachContact : listOfAditionalContacts) {
                System.Debug('Gunish : eachContact.Birthdate' + eachContact.Birthdate);
                
                // If Last Name Matches but both DOB and PostCode are NULL in the Database then it's a match.
                if((eachContact.Birthdate == null || string.valueOf(eachContact.Birthdate) == '') && (eachContact.MailingPostalCode == null || eachContact.MailingPostalCode == '')) {
                    listOfContacts.add(eachContact);
                    System.Debug('Gunish : One');
                }
                
                // If Last Name and DOB Match, but  PostCode is NULL in the datase, then it's a match.
                else if(eachContact.Birthdate == pDoB && (eachContact.MailingPostalCode == null || eachContact.MailingPostalCode == '')) {
                    listOfContacts.add(eachContact);
                    System.Debug('Gunish : Two');                   
                }
                
                // If Last Name and Post Code Match, but DOB is null in the database, then it's a match.
                else if((eachContact.Birthdate == null || string.valueOf(eachContact.Birthdate) == '')) {
                    if(eachContact.MailingPostalCode != null) {
                        if(eachContact.MailingPostalCode.contains(pPostCode)) {
                            listOfContacts.add(eachContact);
                            System.Debug('Gunish : Three');
                        }
                    }
                }
            }
        } 
        
        // Scenario 4, Last Name = X, DOB = X/NULL(DB), PostCode = 0.
        else if((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' )) {
            listOfAditionalContacts = [select id, LastName, Birthdate, MailingPostalCode from Contact where LastName LIKE:LastName ];
            for(Contact eachContact : listOfAditionalContacts) {
                if(eachContact.Birthdate == null || string.valueOf(eachContact.Birthdate) == '')
                    listOfContacts.add(eachContact);
            }
            System.Debug('DD : Scenario 4');
        }
        
        // Scenario 5, Last Name = X, DOB = 0, PostCode = X/NULL(DB).
        else if((pLastName != null && pLastName != '') && (pPostCode != null && pPostCode != '')) {
            listOfAditionalContacts = [select id, LastName, Birthdate, MailingPostalCode from Contact where LastName LIKE:LastName ];
            for(Contact eachContact : listOfAditionalContacts) {
                if(eachContact.MailingPostalCode == null || eachContact.MailingPostalCode == '')
                    listOfContacts.add(eachContact);
            }
            System.Debug('DD : Scenario 5');
        }
        
        Set<Id> setOfIDs = new Set<Id>();
        for(Contact contactItem : listOfContacts) {
            setOfIDs.add(contactItem.Id);
            //return listOfContacts;    
        }
        
        return setOfIDs;
    }
    // new calls
        public List<Contact> SearchNonProfessional(Contact pCurrentContact, string pLastName, string pFirstName, date pDoB, string pPostCode) {
        System.Debug('DD : SearchNonProfessional new calls');
        string LastName = pLastName + '%';
        string FirstName;
        date Birthdate = date.valueOf(pDoB);
        date dToday = date.newinstance(2008,1, 1);
        string PostCode = pPostCode + '%';
        string strPostCode;
        string CompressedPostCode = PostCode.replaceAll('\\s+','');
        integer currentLimit;
        currentLimit = 200;
        If (pFirstName==null||pFirstName=='') { FirstName = '%';
            } 
        else { FirstName = pFirstName.left(1) + '%';}
        // Instantiate a new Pattern object "MyPattern"
        Pattern PostcodePattern = Pattern.compile('([a-zA-Z0-9]{3}|[a-zA-Z0-9]{4}) [a-zA-Z0-9]{3}');
        Matcher PostcodeMatcher;
        Boolean bPostcodeValidFormat;
        string sDoB = string.valueOf(pDoB);
        System.Debug('Gunish Says String pDoB: ' + string.valueOf(pDoB));
        System.Debug('Gunish Says LastName: ' + string.valueOf(LastName));
        System.Debug('Gunish Result :' + ((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' )));
        list<Contact> listOfContacts;
        list<RecordType> listOfCRSRecordTypes;
        listOfCRSRecordTypes = [Select id, name from RecordType where SobjectType='Contact' and (Name='Person with Dementia' or Name = 'Carer of Person with Dementia' or Name = 'Friend or Family of Person with Dementia')];
        //ignore an invaid postcode being passed in
        if (pPostCode !=null & pPostCode !=''){
            PostcodeMatcher  = PostcodePattern.matcher(pPostCode);
            If (PostcodeMatcher.matches()==true){
                strPostCode = pPostCode;}
            else {strPostcode ='';}
            }
        else {strPostcode='';}
        //ignore a date of birth in future being passed in
        if (Birthdate>dToday){sDoB='';}
        System.Debug('Gunish Says String sDoB: ' + string.valueOf(sDoB));
        
        // Scenario 1, Last Name = X, DOB = X, PostCode = X.
        if((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' ) && (strPostCode != null && strPostCode != '')) {
            System.Debug('DD : Scenario 1');
            listOfContacts = [select id, Name, Email, Record_Type_Name__c, LastName, FirstName,  RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Date_of_Birth_Estimated__c,  Primary_care_trust__c, Local_authority__c, Constituency__c, Salutation from Contact where LastName LIKE:LastName and Birthdate =:Birthdate and MailingPostalCode LIKE:PostCode and FirstName LIKE:FirstName and RecordTypeId =:listOfCRSRecordTypes LIMIT :currentLimit ];
            currentLimit = currentLimit - listOfContacts.size();
        }
        
        // Scenario 2, Last Name = X, DOB = X, PostCode = 0. 
        else if((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' )) {
            listOfContacts = [select id, Name, Email, Record_Type_Name__c, LastName, FirstName,  RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Date_of_Birth_Estimated__c,  Primary_care_trust__c, Local_authority__c, Constituency__c, Salutation from Contact where LastName LIKE:LastName and Birthdate =:Birthdate and FirstName LIKE:FirstName and RecordTypeId =:listOfCRSRecordTypes  LIMIT :currentLimit ];
            System.Debug('Gunish : System Date OF Birth :' + pDoB);
            System.Debug('DD : Scenario 2');
            currentLimit = currentLimit - listOfContacts.size();
        }
        
        // Scenario 3, Last Name = X, DOB = 0, PostCode = X. 
        else if((pLastName != null && pLastName != '') && (strPostCode != null && strPostCode != '')) {
            System.Debug('DD : Scenario 3');
            listOfContacts = [select id, Name, Email, Record_Type_Name__c, LastName, FirstName,  RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Date_of_Birth_Estimated__c,  Primary_care_trust__c, Local_authority__c, Constituency__c, Salutation from Contact where LastName LIKE:LastName and MailingPostalCode LIKE:PostCode and FirstName LIKE:FirstName and RecordTypeId =:listOfCRSRecordTypes  LIMIT :currentLimit];
            currentLimit = currentLimit - listOfContacts.size();
        }
        //debugging MT
        //for (Contact eachContact: listOfContacts) {
        //    System.Debug ('DDMT : '+ eachContact.FirstName + ':' +  eachContact.LastName + ':' +eachContact.Id  + ':' +eachContact.MailingPostalCode  + ':' + eachContact.Birthdate);
        //}
        List<Contact> listOfAditionalContacts = new List<Contact>();
        // Find Additional Records.
        // Scenario 6, Last Name = X, DOB = X/NULL(DB), PostCode = X/NULL(DB).
        if((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' ) && (strPostCode != null && strPostCode != '')) {
            System.Debug('DD : Scenario 6');
            listOfAditionalContacts = [select id, Name, Email, Record_Type_Name__c, LastName, FirstName,  RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Date_of_Birth_Estimated__c,  Primary_care_trust__c, Local_authority__c, Constituency__c, Salutation  from Contact where LastName LIKE:LastName  and FirstName LIKE:FirstName and RecordTypeId =:listOfCRSRecordTypes  LIMIT :currentLimit ];
            System.Debug('Gunish :' + listOfAditionalContacts.size());
            for(Contact eachContact : listOfAditionalContacts) {
                System.Debug('Gunish : eachContact.Birthdate' + eachContact.Birthdate);
                System.Debug('Mike : eachContact.MailingPostalCode' + eachContact.MailingPostalCode);
                
                if (eachContact.MailingPostalCode != null && eachContact.MailingPostalCode != ''){
                    PostcodeMatcher  = PostcodePattern.matcher(string.valueOf(eachContact.MailingPostalCode));
                    System.Debug('Mike : valid UK Postcode: ' + PostcodeMatcher.matches());
                    bPostcodeValidFormat = PostcodeMatcher.matches();
                }
                else {bPostcodeValidFormat = false;}

                // If Last Name Matches but both DOB and PostCode are NULL in the Database then it's a match.
                if((eachContact.Birthdate == null || string.valueOf(eachContact.Birthdate) == '' || eachContact.Birthdate >=dToday || eachContact.Date_of_Birth_Estimated__c ==true) && (eachContact.MailingPostalCode == null || eachContact.MailingPostalCode == '' || bPostcodeValidFormat ==false)) {
                    System.Debug('Gunish : One');
                    System.Debug ('DDMT : ' + eachContact.LastName + ':' +eachContact.Id  + ':' +eachContact.MailingPostalCode  + ':' + eachContact.Birthdate);
                    listOfContacts.add(eachContact);
                }
                
                // If Last Name and DOB Match, but  PostCode is NULL in the datase, then it's a match.
                else if(eachContact.Birthdate == pDoB && (eachContact.MailingPostalCode == null || eachContact.MailingPostalCode == '' || bPostcodeValidFormat ==false)) {
                    System.Debug('Gunish : Two');                   
                    System.Debug ('DDMT : ' + eachContact.LastName + ':' +eachContact.Id  + ':' +eachContact.MailingPostalCode  + ':' + eachContact.Birthdate);
                    listOfContacts.add(eachContact);
                }
                
                // If Last Name and Post Code Match, but DOB is null in the database, then it's a match.
                else if((eachContact.Birthdate == null || string.valueOf(eachContact.Birthdate) == '' || eachContact.Birthdate >=dToday || eachContact.Date_of_Birth_Estimated__c ==true)) {
                    if(eachContact.MailingPostalCode != null) {
                        if(eachContact.MailingPostalCode.contains(strPostCode)) {
                            System.Debug('Gunish : Three');
                            System.Debug ('DDMT : ' + eachContact.LastName + ':' +eachContact.Id  + ':' +eachContact.MailingPostalCode  + ':' + eachContact.Birthdate);
                            listOfContacts.add(eachContact);
                        }
                    }
                }
            }
        } 
        
        // Scenario 4, Last Name = X, DOB = X/NULL(DB), PostCode = 0.
        else if((pLastName != null && pLastName != '') && (sDoB != null && sDoB != '' )) {
            System.Debug('DD : Scenario 4');
            listOfAditionalContacts = [select id, Name, Email, Record_Type_Name__c, LastName, FirstName,  RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Date_of_Birth_Estimated__c,  Primary_care_trust__c, Local_authority__c, Constituency__c, Salutation from Contact where LastName LIKE:LastName  and FirstName LIKE:FirstName and RecordTypeId =:listOfCRSRecordTypes LIMIT :currentLimit ];
            System.Debug('Gunish :' + listOfAditionalContacts.size());
            for(Contact eachContact : listOfAditionalContacts) {
                if(eachContact.Birthdate == null || string.valueOf(eachContact.Birthdate) == '' || eachContact.Birthdate >=dToday || eachContact.Date_of_Birth_Estimated__c ==true)
                    listOfContacts.add(eachContact);
            }

        }
        
        // Scenario 5, Last Name = X, DOB = 0, PostCode = X/NULL(DB).
        else if((pLastName != null && pLastName != '') && (strPostCode != null && strPostCode != '')) {
            System.Debug('DD : Scenario 5');
            listOfAditionalContacts = [select id, Name, Email, Record_Type_Name__c, LastName, FirstName,  RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Date_of_Birth_Estimated__c,  Primary_care_trust__c, Local_authority__c, Constituency__c, Salutation from Contact where LastName LIKE:LastName  and FirstName LIKE:FirstName and RecordTypeId =:listOfCRSRecordTypes LIMIT :currentLimit  ];
            System.Debug('Gunish :' + listOfAditionalContacts.size());
            for(Contact eachContact : listOfAditionalContacts) {
                if (eachContact.MailingPostalCode == null || eachContact.MailingPostalCode == ''){
                    bPostcodeValidFormat = false;}
                else {
                    PostcodeMatcher  = PostcodePattern.matcher(string.valueOf(eachContact.MailingPostalCode));
                    System.Debug('Mike : valid UK Postcode: ' + PostcodeMatcher.matches());
                    bPostcodeValidFormat = PostcodeMatcher.matches();
                }
            
                if((eachContact.MailingPostalCode == null || eachContact.MailingPostalCode == '' || bPostcodeValidFormat ==false) || (bPostcodeValidFormat ==true))
                    listOfContacts.add(eachContact);
            }
        }
        // Scenario 7, Last Name = X, DOB = X/NULL, PostCode = X/NULL(DB).
        // in this case we have no listOfContacts - thing would have fallen through the gaps in scenarios 1,2 and 3
        else if((pLastName != null && pLastName != '') && (strPostCode == null || strPostCode == '') && (sDoB == null || sDoB == '' )) {
            System.Debug('DD : Scenario 7');             
            listOfContacts= [select id, Name, Email, Record_Type_Name__c, LastName, FirstName,  RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Date_of_Birth_Estimated__c,  Primary_care_trust__c, Local_authority__c, Constituency__c, Salutation from Contact where LastName LIKE:LastName  and FirstName LIKE:FirstName and RecordTypeId =:listOfCRSRecordTypes LIMIT 100];
            System.Debug('Gunish :' + listOfContacts.size());
        }
        
        // Scenario 8 - search on lastname and first name - ignore DOB and PostCode
        if((pLastName != null && pLastName != '') && (pFirstName != null && pFirstName != '')){
            System.Debug('DD : Scenario 8');
           listOfAditionalContacts = [select id, Name, Email, Record_Type_Name__c, LastName, FirstName,  RecordTypeId, Diagnosis__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Phone, Birthdate, Ward__c, Date_of_Birth_Estimated__c,  Primary_care_trust__c, Local_authority__c, Constituency__c, Salutation from Contact where LastName LIKE:LastName  and FirstName LIKE:FirstName and RecordTypeId =:listOfCRSRecordTypes LIMIT 20];
           System.Debug('Gunish :' + listOfAditionalContacts.size());
           for(Contact eachContact : listOfAditionalContacts) {
               System.Debug ('DDMT : ' + eachContact.LastName + ':' +eachContact.Id  + ':' +eachContact.MailingPostalCode  + ':' + eachContact.Birthdate);
               listOfContacts.add(eachContact);
           }
        }
        List<Id> setOfIDs = new List<Id>();
        for(Contact contactItem : listOfContacts) {
            System.Debug ('DDMT2 : ' + contactItem.LastName + ':' +contactItem.Id  + ':' +contactItem.MailingPostalCode  + ':' + contactItem.Birthdate);
            setOfIDs.add(contactItem.Id);
            //return listOfContacts;    
        }
        //return listOfContacts without duplicates
        Set <Contact> conset = new Set<Contact>();
        List <Contact> returnListOfContacts = new List<Contact>();
        for (Contact s : listOfContacts) {
            if (conset.add(s)) {
                if (s.id!=pCurrentContact.id){
                    returnListOfContacts.add(s);
                }
            }
        }
        return returnListOfContacts;
}
//
// TEST CASE
//
  private static testMethod void testDeDuper() {
  
    Contact c1 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
    RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
    insert c1;
    Contact c2 = new Contact(Salutation='Mrs',FirstName='two', LastName='test2',MailingPostalCode ='ABC123', Birthdate =null,
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Carer of Person with Dementia'].id);
    insert c2;

    Account acc2 = new Account(Name='Test External Org',RecordTypeId=[Select Id from RecordType where
             SObjectType='Account' and Name like 'External%'].id);
    insert acc2;  
    Contact c3 = new Contact(Salutation='Dr',FirstName='three', LastName='testPro3',MailingPostalCode ='ABC123', Birthdate =null,
            AccountId=acc2.id,
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Professional / Stakeholder'].id);
    insert c3;
  
  
  
    Set<Id> SetOfIds = new Set<Id>();
    List<Contact> lstContacts = new List<Contact>();
    
    //Scenario 1, Last Name = X, DOB = X, PostCode = X
    String sLastName = 'test';
    String sFirstName = 'one';
    Date oDoB = system.today();
    String sPostCode = 'ABC123';
    DeDuper  dd = new DeDuper();
    SetOfIds = dd.SearchNonProfessional(sLastName, oDoB, sPostCode);
    lstContacts  = dd.SearchNonProfessional(c1, sLastName, sFirstName, oDoB, sPostCode);
    
    //Scenario 2, Last Name = X, DOB = X, PostCode = 0.     
    sLastName = 'test';
    sFirstName = 'one';
    oDoB = system.today();
    sPostCode = '';
    SetOfIds = dd.SearchNonProfessional(sLastName, oDoB, sPostCode);
    lstContacts  = dd.SearchNonProfessional(c1, sLastName, sFirstName, oDoB, sPostCode);

    // Scenario 3, Last Name = X, DOB = 0, PostCode = X.
    sLastName = 'test';
    sFirstName = 'one';
    oDoB = null;
    sPostCode = 'ABC123';
    SetOfIds = dd.SearchNonProfessional( sLastName, oDoB, sPostCode);
    lstContacts   = dd.SearchNonProfessional(c1,sLastName, sFirstName, oDoB, sPostCode);
    
    //If Last Name and Post Code Match, but DOB is null in the database, then it's a match
    sLastName = 'test2';
    sFirstName = 'one';
    oDoB = system.today();
    sPostCode = 'ABC123';
    SetOfIds = dd.SearchNonProfessional(sLastName, oDoB, sPostCode);
    lstContacts  = dd.SearchNonProfessional(c1, sLastName, sFirstName, oDoB, sPostCode);
    //Only a surname
    oDoB = null;
    sPostCode = null;
    lstContacts = dd.SearchNonProfessional(c1, sLastName, sFirstName, oDoB, sPostCode);
    
    //now test SearchProfessionals
    sLastName = 'testPro3';
    Id orgId = acc2.id;
    SetOfIds = dd.SearchProfessionals(sLastName,  orgId );

    }  

}