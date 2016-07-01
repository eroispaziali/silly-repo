public with sharing class Account_DeDuper {

  // Constructor.
Public AccountDe_Duper () {

}
public void badStuff() {}
public void badStuff2() {}
public void BADSTUFF3() {}
public void BADSTUFF__4() {}

Public List<Account> SearchAccount (Account pCurrentRecord, String pAccountName, String pPostCode, String pCity, id pRecordTypeId, Boolean pShowAllRecordTypes, Integer pSearchLimit) {
        Boolean postCodeValid = false;
        String AccountLikeName;
        List<String> AccountNameParts;
        String FirstName;
        // adding a comment somewhere
        List <Account> lstMatchingAccounts= new List<Account>();
        List <Account> ListOfMatches = new List<Account>(); 
        List <Account> ListOfAdditionalMatches = new List<Account>();
        integer currentLimit;
        // check that we have a valid post code
        postCodeValid=IsValidPostCode(pPostCode);
        
        //search
        //search # 1 match on name and postcode
        currentLimit = pSearchLimit;
        if ((pAccountName!=null&&pAccountName!='')&&postCodeValid){
            if (pShowAllRecordTypes) {
                ListOfMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where Name=:pAccountName and BillingPostalCode=:pPostCode order by Name LIMIT :currentLimit ];
            } 
            else {
                ListOfMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where Name=:pAccountName and BillingPostalCode=:pPostCode AND RecordTypeId =:pRecordTypeId order by Name LIMIT :currentLimit ];
            }
            System.Debug ('##################Search1: ' + ListOfMatches.size());
            currentLimit = currentLimit - ListOfMatches.size();
            }
        //search # 2 match on wildcard name and postcode
        if ((pAccountName!=null&&pAccountName!='')&&postCodeValid && (currentLimit>0)){
                AccountLikeName = pAccountName.trim()+'%';
                if (pShowAllRecordTypes) {
                    ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where Name LIKE :AccountLikeName and BillingPostalCode=:pPostCode order by Name LIMIT :currentLimit ];
                }
                else {
                    ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where Name LIKE :AccountLikeName and BillingPostalCode=:pPostCode AND RecordTypeId =:pRecordTypeId order by Name LIMIT :currentLimit ];
                }
                System.Debug ('##################Search2: ' + ListOfAdditionalMatches.size());
                currentLimit = currentLimit - ListOfAdditionalMatches.size();

                for(Account eachOrg : ListOfAdditionalMatches ) {   
                    ListOfMatches.Add(eachOrg);
                }
            }
        //search # 3 match on wildcard name
        if ((pAccountName!=null&&pAccountName!='')&& (currentLimit>0)){
                AccountLikeName = pAccountName.trim()+'%';
                if (pShowAllRecordTypes) {
                    ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where Name LIKE :AccountLikeName order by Name LIMIT :currentLimit ];
                }
                else {
                    ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where Name LIKE :AccountLikeName AND RecordTypeId =:pRecordTypeId order by Name LIMIT :currentLimit ];
                }
                System.Debug ('##################Search3: ' + ListOfAdditionalMatches.size());
                currentLimit = currentLimit - ListOfAdditionalMatches.size();
                for(Account eachOrg : ListOfAdditionalMatches ) {   
                    ListOfMatches.Add(eachOrg);
                }
            }

        //search # 4 match on first word of name
        if ((pAccountName!=null&&pAccountName!='')&& (currentLimit>0)){
            
            AccountNameParts = pAccountName.split(' ',2);
            if (AccountNameParts.size()>1) {
                if (AccountNameParts[0]=='The' && AccountNameParts.size()>=2 ) {
                    // do not search on The, search on second name
                    FirstName = '%' + AccountNameParts[1] + '%';
                }
                else {
                    FirstName = '%' + AccountNameParts[0] + '%';
                }
                System.Debug ('##################FirstName: ' + FirstName);
                 if (pShowAllRecordTypes) {
                     ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where Name LIKE :FirstName order by Name LIMIT :currentLimit ];
                 }
                 else {
                     ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where Name LIKE :FirstName AND RecordTypeId =:pRecordTypeId order by Name LIMIT :currentLimit ];
                     }
                System.Debug ('##################Search4: ' + ListOfAdditionalMatches.size());
                currentLimit = currentLimit - ListOfAdditionalMatches.size();
                for(Account eachOrg : ListOfAdditionalMatches ) {   
                    ListOfMatches.Add(eachOrg);
                }
            }
         }    
        //search # 5 match on city if no postcode
        if ((!postCodeValid)&&(pCity!=null)&&(pCity!='') && (currentLimit>0)) {
            if (pShowAllRecordTypes) {
                    ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where BillingCity=:pCity order by Name LIMIT :currentLimit ];
                }
                else {
                    ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where BillingCity=:pCity AND RecordTypeId =:pRecordTypeId order by Name LIMIT :currentLimit ];
                    }
                System.Debug ('##################Search5: ' + ListOfAdditionalMatches.size());
                currentLimit = currentLimit - ListOfAdditionalMatches.size();
                for(Account eachOrg : ListOfAdditionalMatches ) {   
                    ListOfMatches.Add(eachOrg);
                }
            }
        //search # 6 match on postcode only
        if ((postCodeValid)&& (currentLimit>0)){
            if (pShowAllRecordTypes) {
                    ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where BillingPostalCode=:pPostCode order by Name LIMIT :currentLimit ];
                }
                else {
                    ListOfAdditionalMatches = [select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c from Account where BillingPostalCode=:pPostCode AND RecordTypeId =:pRecordTypeId order by Name LIMIT :currentLimit ];
                    }
                System.Debug ('##################Search6: ' + ListOfAdditionalMatches.size());
                currentLimit = currentLimit - ListOfAdditionalMatches.size();
                for(Account eachOrg : ListOfAdditionalMatches ) {   
                    ListOfMatches.Add(eachOrg);
                }
            }
        
        //return lstMatchingAccounts without duplicates and without the current record
        Set <Account> conset = new Set<Account>();

        for (Account s : ListOfMatches) {
            if (conset.add(s)) {
                if (s.id!=pCurrentRecord.id) {
                    lstMatchingAccounts.add(s);
                }
            }
        }
        return lstMatchingAccounts;
    }

private Boolean IsValidPostCode(string pPostcode) {
        boolean isValid = false;
        If (pPostcode==null||pPostcode=='') {
            isValid = false;
            return isValid;
        }
        // Regular Expression for Postcode
        String postcodeRegex= '^([A-PR-UWYZa-pr-uwyz]([0-9]{1,2}|([A-HK-Ya-hk-y][0-9]|[A-HK-Ya-hk-y][0-9]([0-9]|[ABEHMNPRV-Yabehmnprv-y]))|[0-9][A-HJKS-UWa-hjks-uw])\\ {0,1}[0-9][ABD-HJLNP-UW-Zabd-hjlnp-uw-z]{2}|([Gg][Ii][Rr]\\ 0[Aa][Aa])|([Ss][Aa][Nn]\\ {0,1}[Tt][Aa]1)|([Bb][Ff][Pp][Oo]\\ {0,1}([Cc]\\/[Oo]\\ )?[0-9]{1,4})|(([Aa][Ss][Cc][Nn]|[Bb][Bb][Nn][Dd]|[BFSbfs][Ii][Qq][Qq]|[Pp][Cc][Rr][Nn]|[Ss][Tt][Hh][Ll]|[Tt][Dd][Cc][Uu]|[Tt][Kk][Cc][Aa])\\ {0,1}1[Zz][Zz]))$';
        //'^([A-PR-UWYZa-pr-uwyz]([0-9]{1,2}|([A-HK-Ya-hk-y][0-9]|[A-HK-Ya-hk-y][0-9]([0-9]|[ABEHMNPRV-Yabehmnprv-y]))|[0-9][A-HJKS-UWa-hjks-uw])\ {0,1}[0-9][ABD-HJLNP-UW-Zabd-hjlnp-uw-z]{2}|([Gg][Ii][Rr]\ 0[Aa][Aa])|([Ss][Aa][Nn]\ {0,1}[Tt][Aa]1)|([Bb][Ff][Pp][Oo]\ {0,1}([Cc]\/[Oo]\ )?[0-9]{1,4})|(([Aa][Ss][Cc][Nn]|[Bb][Bb][Nn][Dd]|[BFSbfs][Ii][Qq][Qq]|[Pp][Cc][Rr][Nn]|[Ss][Tt][Hh][Ll]|[Tt][Dd][Cc][Uu]|[Tt][Kk][Cc][Aa])\ {0,1}1[Zz][Zz]))$');
        Pattern MyPattern = Pattern.compile(postcodeRegex);

        // then instantiate a new Matcher object ”MyMatcher”
        Matcher MyMatcher = MyPattern.matcher(pPostcode);

        if (!MyMatcher.matches()) {
            isValid = false;
        }else{
              isValid = true;
        }
        return isValid;
    } 

private static testMethod void testNewAccountController() {    
    Account accRec = new Account(Name='External Test Org1',BillingPostalCode='SW1A 2AA',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id);
    insert accRec;
    List <Account> lstAccs= new List<Account>();
    Boolean bShowAll = true;
    Boolean bShowOne = false;
    Integer NoRecords = 100;
    String sAccountName = '';
    String sPostcode = '';
    String sCity='';
    
    Id RecordTypeId;
    RecordTypeId =[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id;
    AccountDeDuper dd = new AccountDeDuper();
    
    
    lstAccs =dd.SearchAccount (accRec, sAccountName , sPostcode, sCity, RecordTypeId, bShowAll , NoRecords );  
    sAccountName = 'External';
    lstAccs =dd.SearchAccount (accRec, sAccountName , sPostcode, sCity, RecordTypeId, bShowAll , NoRecords );
    lstAccs =dd.SearchAccount (accRec,sAccountName , sPostcode, sCity, RecordTypeId, bShowOne , NoRecords );
    sPostcode = 'ABC1234';
    lstAccs =dd.SearchAccount (accRec,sAccountName , sPostcode, sCity, RecordTypeId, bShowAll , NoRecords );  
    lstAccs =dd.SearchAccount (accRec,sAccountName , sPostcode, sCity, RecordTypeId, bShowOne , NoRecords );
    sAccountName = 'The External Test';
    sPostcode = 'SW1A 2AA';
    lstAccs =dd.SearchAccount (accRec,sAccountName , sPostcode, sCity, RecordTypeId, bShowAll , NoRecords );  
    lstAccs =dd.SearchAccount (accRec,sAccountName , sPostcode, sCity, RecordTypeId, bShowOne , NoRecords );
    sAccountName ='External Test Org1';
    sPostCode = null;
    sCity = 'London';
    lstAccs =dd.SearchAccount (accRec,sAccountName , sPostcode, sCity, RecordTypeId, bShowAll , NoRecords );  
    lstAccs =dd.SearchAccount (accRec,sAccountName , sPostcode, sCity, RecordTypeId, bShowOne , NoRecords );
                
    } 

}
