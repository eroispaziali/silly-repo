public with sharing class listAccounts {
    public ApexPages.StandardController stdController;
    public List<Account> lstMatchingAccounts {get;set;}
    private Account acc;
    private String AccountName;
    private String postalcode;
    private String City;
    private Id recordTypeId;
    static final boolean ShowAllRecordTypes = false;
    static final integer SEARCHLIMIT = 30;
// Standard controller constructor.
    public listAccounts (ApexPages.StandardController pController) {
        stdController = pController;
        acc=  [select id, Name, BillingPostalCode, BillingCity, recordTypeId from Account where id = :ApexPages.currentPage().getParameters().get('id')];
        system.debug('@@@@@@@@@@@@@@@'+acc.id);
        AccountName= acc.Name;
        City = acc.BillingCity ;
        postalcode = acc.BillingPostalCode;
        recordTypeId  = acc.recordTypeId;
        system.debug('@@@@@@@@@@@@@@@AccountName'+AccountName);
        system.debug('@@@@@@@@@@@@@@@City '+City );
        system.debug('@@@@@@@@@@@@@@@postalcode '+postalcode );
        
    }    
public PageReference AutoRunListAccounts(){     
     lstMatchingAccounts = new List<Account>();  
     AccountDeDuper objAccDeDupe = new AccountDeDuper();
     if (AccountName=='' || AccountName==null){
          return null;}
             
     lstMatchingAccounts = objAccDeDupe.SearchAccount(acc, AccountName, postalcode, City, recordTypeId, ShowAllRecordTypes, SEARCHLIMIT);     
     return null;
}
//Test script for code coverage.
public testMethod static void testController()
{
   Account accRec = new Account(Name='External Test Org1',BillingPostalCode='SW1A 2AA',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id);
    insert accRec;
    ApexPages.currentPage().getParameters().put('Id', accRec.id);        
    listAccounts conCls= new listAccounts (new ApexPages.StandardController(accRec));
    conCls.AutoRunListAccounts();   

}
    
}