public with sharing class AccountTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Accounts Trigger.
 *  Author  : Mike Tinson
 *  Date    : 13-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the Accounts Record.
 *               
 *  Modification History
 *  Date            Who                     Description 
 * 15/10/2014      Lakshmi Rajendram        populate Address on internal orgs from property
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public AccountTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(Account[] NewAccounts, Map<ID, Account> AccountsMap){
        System.debug('****** AccountTriggerHandler.OnAfterInsert  ******');
        
        
        UpdateLastTransactionDate(NewAccounts);
    }   
 

    
    public void OnAfterUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> AccountsMap){
        System.debug('****** AccountsTriggerHandler.OnAfterUpdate  ******');
        //adding a comment
        UpdateLastTransactionDate(updatedAccounts);
    }



    public void OnAfterDelete(Account[] oldAccounts, Map<ID, Account> AccountsMap){
    
        System.debug('****** AccountsTriggerHandler.OnAfterDelete  ******');
        
        UpdateLastTransactionDate(oldAccounts);
    }
     
    public void emptyMethod() {}
    public void abstract emptyAbstract();
    public void virtual emptyVirtual(){}
     
    Public void OnBeforeUpdate(Account[]  updatedAccounts){
    
    Id InternalAccount;
    
    InternalAccount = [select Id from RecordType where SObjectType = 'Account' and DeveloperName ='InternalOrganisation'].Id;
    
    Set<ID> setLocIds = new Set<ID>();
    for (Account na:updatedAccounts) {
        if (na.Property__c != NULL && (na.RecordTypeId == InternalAccount)){
       
         setLocIds.add(na.Property__c);
          }
       
       }
         
      MAP<ID , Location__c> maploc = new MAP<ID , Location__c>([select Postcode__c, Street__c, City__c, County__c, Country__c,Postcode_Constituency__c,Postcode_Local_Authority__c,Postcode_Primary_Care_Trust__c,Postcode_Ward__c,Clinical_Commissioning_Group__c from Location__c where id in: setLocIds]);
            for (Account na:updatedAccounts) {
             if (na.Property__c != NULL && (na.RecordTypeId == InternalAccount)){

           Location__c loc = maploc.get(na.Property__c);

                na.BillingPostalCode = loc.Postcode__c;
                na.BillingStreet = loc.Street__c;
                na.BillingCity = loc.City__c;
                na.BillingState = loc.County__c;
                na.BillingCountry = loc.Country__c;
                na.Constituency_Derived__c = loc.Postcode_Constituency__c;
                na.Local_authority__c      = loc.Postcode_Local_Authority__c;
                na.Primary_care_trust__c = loc.Postcode_Primary_Care_Trust__c;
                na.Ward__c = loc.Postcode_Ward__c;
                na.Clinical_Commissioning_Group__c = loc.Clinical_Commissioning_Group__c;
                na.AreaLookup__c = na.Area__c;   
                
                }   
            }
        
    }
    
  
         
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

public void UpdateLastTransactionDate(Account[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Account df: updatedSUs){
        SUIds.add(df.Id);
    }
    System.debug('****** SUIds.Size ******' + SUIds.Size());

    if(SUIds.isEmpty() == false){
      
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
      LastTransactionDateLookup handler = new LastTransactionDateLookup();
      handler.UpdateLastTransactionDate(SUIds[0], dtLastTransactionDate); 
      
        }
    
    }
}
