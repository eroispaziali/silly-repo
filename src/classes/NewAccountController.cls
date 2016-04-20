/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  New Account (External Organisation)
 *
 *  Modification History
 *
 *  Date         Who            Description 
 *                             
*******************************************************************************************/
public with sharing class NewAccountController {

    public String AccountName {get;set;}
    public Id recordTypeId {get;set;}
    
    public String postalcode {get;set;}
    public String street {get;set;}
    public String billingCity {get;set;}
    public String billingState {get;set;}
    public Boolean ShowAllRecordTypes {get;set;}
    public Integer CountOfAvailableRecordTypes {get; private set;}
    public Account relAccount {get;set;}
    public List<Account> lstMatchingAccounts {get;set;}
    public Boolean searchDone {get;set;}
    public Map<Id,String> mapOfRecordTypes;
    public String recId {get;set;}
    public String selectedRelAccountId {get;set;}
    public String selectedRelAccountName {get;set;}
    public Boolean ignoreAndCreate {get;set;}
    static final Integer SEARCHLIMIT =100;
    
    //Constructor
    public NewAccountController(ApexPages.StandardController stdCon){
        RecordType rt;
        relAccount = (Account)stdCon.getRecord();
        if(relAccount==null) relAccount = new Account();
        lstMatchingAccounts = new List<Account>();
        recId = ApexPages.currentPage().getParameters().get('recId');

        if(recId!=null){
            relAccount.RecordTypeId=[SELECT Id,Name FROM RecordType WHERE SobjectType='Account' and Id=:recId].id;
            //relAccount.RecordTypeId=recId;
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ recId: '+recId);
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ relAccount.RecordTypeId: '+relAccount.RecordTypeId);
        }
        //get default record type - external for everyone except for Alz Trading
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        if(usrProfileName.contains('Trading')){
                rt = [Select id,name, developername from Recordtype where sObjecttype='Account' and Developername = 'Alzheimer_s_Trading_Ltd_Accounts'];
                }
            else {
                rt = [Select id,name, developername from Recordtype where sObjecttype='Account' and Developername = 'External_organisation'];
                }
        recordTypeId = rt.Id;
        mapOfRecordTypes = new Map<Id,String>();
        getAccountRecordTypes();
        searchDone = false;
              
    }
   //Returns Recordtypes of Account available for current User.
   public List<SelectOption> getAccountRecordTypes(){
        List<SelectOption> lstRecordTypes = new List<SelectOption>();
        //Retrive all Account RecordTypes
        for(RecordTypeInfo rec: Account.SObjectType.getDescribe().getRecordTypeInfosById().values()){
          //Check if recordtype is visible/available for current user.
          if(rec.isAvailable() && rec.getName()!='Master'){
              mapOfRecordTypes.put(rec.getRecordTypeId(), rec.getName());
              lstRecordTypes.add(new SelectOption(rec.getRecordTypeId(),rec.getName()));
          }
        }       
        CountOfAvailableRecordTypes = lstRecordTypes.size();
        return lstRecordTypes;
   }
    public PageReference selectAccount(){
        system.debug('>>>>>>>>>>>>>> createAccount' ); 
        if(selectedrelAccountId!=null){
            try{
                //get the details of the selected dupe contact
                Account dupeAccount = [Select id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, Category__c, Owner.Alias, Record_Type_Name__c From Account c where id = :selectedrelAccountId];

                return new Pagereference('/'+dupeAccount.Id+'/e?retURL=%2F'+dupeAccount.Id); //return to contact details page
            }catch(Exception ex){ 
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while selecting existing Account.');
                ApexPages.addMessage(message);
                return null;
            }
        }
        return new Pagereference('/apex/NewAccount?id='+relAccount.Id+'/e?retURL=%2F'+relAccount.Id);
    }
    public PageReference ignoreCreateAccount(){
        // create account
        try{
            //set variables captured as inputtext on page
            relAccount.Name=AccountName ;
            relAccount.BillingPostalCode = postalcode;
            relAccount.BillingStreet = street;
            relAccount.BillingCity = BillingCity;
            relAccount.BillingState = BillingState;
            relAccount.RecordTypeId = recordTypeId;
            insert relAccount; 
            return new Pagereference('/'+relAccount.Id+'/e?retURL=%2F'+relAccount.Id); //return to new account details page
            }
        catch(Exception ex){ 
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
            ApexPages.addMessage(message);
            return null;
            }
    }
    public PageReference doSearch(){
        Boolean isError = false;
        Boolean postCodeValid = false;
        String AccountLikeName;
        List<String> AccountNameParts;
        String FirstName;
        List <Account> ListOfMatches = new List<Account>(); 
        List <Account> ListOfAdditionalMatches = new List<Account>();
        lstMatchingAccounts.clear();
        //validation
        if (AccountName==null||AccountName==''){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter the Organisation Name.');
            ApexPages.addMessage(message);
            isError = true;
        }
        if (isError){
            searchDone = false;
            return null;
        }
        searchDone = true;

        //perform search
        AccountDeDuper objAccDeDupe = new AccountDeDuper();
        
        lstMatchingAccounts = objAccDeDupe.SearchAccount(relAccount, AccountName, postalcode, billingCity, recordTypeId, ShowAllRecordTypes, SEARCHLIMIT);   

        //finish search, return message about what we have found
        //found duplicates, return warning
         if(lstMatchingAccounts.size()>0){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Matching Organisations have been found, please use one of the two buttons at the bottom of the screen to continue.');
            ApexPages.addMessage(message);
            
            ignoreAndCreate =true;
            searchDone=false;
 
        }else{
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'No matches found');
            ApexPages.addMessage(message);
            ignoreAndCreate = false;
            searchDone=true;

        }                        
        return null;
    }
    
  //
  // TEST CASE
  //
private static testMethod void testNewAccountController() {    
    Account accRec = new Account(Name='External Test Org1',BillingPostalCode='SW1A 2AA',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id);
    insert accRec;
   
    // Set up the VF page
    PageReference pageRef = Page.CreateRelationship;
    test.setCurrentPage(pageRef);
    pageRef.getParameters().put('Id', accRec.Id);
    
    //CreateRelationshipController cnt = new CreateRelationshipController();
    ApexPages.StandardController stdCon = new ApexPages.StandardController(accRec );
    NewAccountController cnt = new NewAccountController (stdCon);

    cnt.getAccountRecordTypes();
    
    cnt.recordTypeId=cnt.getAccountRecordTypes().get(0).getValue();
    //no account name - invalid
    cnt.doSearch();
    
    cnt.AccountName='External Test Org1';
    cnt.ShowAllRecordTypes = true;
    cnt.doSearch();
    cnt.ShowAllRecordTypes = false;
    cnt.billingCity='aaaaa';
    cnt.doSearch();
    cnt.postalcode='SW1A 2AA';
    cnt.street='aaaaaaaaa';
    cnt.billingState='UK';
    cnt.doSearch();
    cnt.AccountName='The ' + 'External Test Org1';

    cnt.doSearch();
    cnt.ignoreCreateAccount();
    
    cnt.selectedrelAccountId = accRec.Id;
    cnt.selectAccount();
                
    }      
}