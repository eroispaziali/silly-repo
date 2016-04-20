public with sharing class mergeServices {
// copies referrals and service users to master record and closes child service  (does not delete it)
public  Services__c master{get;set;}
public  Services__c child{get;set;}
public String masterOrgLocality {get;set;}
public String childOrgLocality {get;set;}
public String masterOrgOperatedBy {get;set;}
public String childOrgOperatedBy {get;set;}

public Boolean canMerge {get;set;}
public Boolean mergeRequested {get;set;}

private List<Account> masterOrg;
private List<Account> childOrg;
// Standard controller constructor.
    public mergeServices () {
        mergeRequested = false;
        
        master=  [select id, Name,Locality__c ,Operated_By__c ,service_status__c ,service_type__c ,Record_Type_Name__c from Services__c where id = :ApexPages.currentPage().getParameters().get('masterid') LIMIT 1];
        system.debug('@@@@@@@@@@@@@@@'+master.id);
        
        child= [select id, Name,Locality__c ,Operated_By__c ,service_status__c ,service_type__c ,Record_Type_Name__c from Services__c  where id = :ApexPages.currentPage().getParameters().get('childid') LIMIT 1];
        system.debug('@@@@@@@@@@@@@@@'+child.id);
        
        List<Account> masterOrg = [select id, name from Account where id =:master.Locality__c LIMIT 1];
        if (masterOrg.size()==0){
            masterOrgLocality = '';}
        else {
            masterOrgLocality = masterOrg[0].name;}
            
        List<Account> childOrg= [select id, name from Account where id =:child.Locality__c LIMIT 1];
        if (childOrg.size()==0){
            childOrgLocality = '';}
        else {
        	childOrgLocality = childOrg[0].name;}
        	
        //get operated by
        masterOrg = [select id, name from Account where id =:master.Operated_By__c LIMIT 1];
        if (masterOrg.size()==0){
            masterOrgOperatedBy = '';}
        else {
            masterOrgOperatedBy = masterOrg[0].name;}
            
        childOrg= [select id, name from Account where id =:child.Operated_By__c LIMIT 1];
        if (childOrg.size()==0){
            childOrgOperatedBy = '';}
        else {childOrgOperatedBy = childOrg[0].name;}

        
        //check to see if user can delete contacts.  If they cannot they they will have to contact CRS support.
        Boolean canDelete = Services__c.sObjectType.getDescribe().isDeletable();
        if (canDelete==true) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Please check that records should be merged together. Before merging, please copy any data you need to keep from the service record to be merged. (Attached records such as Service Usages  will be copied over.) Once you have checked the records, please click the "Merge Service" button. ');
            ApexPages.addMessage(message);
        
            canMerge=true;}
        else {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Please check that records should be merged together. Before merging, please copy any data you need to keep from the service record to be merged. (Attached records such as Service Usages will be copied over.) Once you have checked the records, please click the "Request Merge Service" button. ');
            ApexPages.addMessage(message);
            canMerge=false;}
    
    }
    
    
    public PageReference mergeService(){
        List<Service_Usage__c> lstSUToUpdate = new List<Service_Usage__c>();
        List<Service_Usage__c> lstSURefToUpdate = new List<Service_Usage__c>();
        try {
             List<Service_Usage__c> lstSU = new List<Service_Usage__c>();
             lstSU= [Select Id, Name,Service_Field__c, Referring_Service__c from Service_Usage__c where (Service_Field__c =:child.id ) ];
             if (lstSU.size() > 0){
             
                 for (Service_Usage__c rec: lstSU ){
                     System.debug('>>>>>>>>>>>Name:' + rec.Name);
                     System.debug('>>>>>>>>>>>Id:  ' + rec.id);
                     rec.Service_Field__c = master.id;
                     lstSUToUpdate.add(rec);
                 }
                 
                 if (lstSUToUpdate.size() > 0){
                     Savepoint sp = Database.setSavepoint();
                    try
                      {
                      //Update ServiceUsage records.
                      upsert lstSUToUpdate;
                      }catch(Exception ex){Database.rollback(sp);
                           ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while updating Service Usages.');
                           ApexPages.addMessage(message);
                           return null;}
                 
                 }
              }
              
             //now do referrals
             lstSU= [Select Id, Name,Service_Field__c, Referring_Service__c from Service_Usage__c where (Referring_Service__c =:child.id ) ];
             if (lstSU.size() > 0){
             
                 for (Service_Usage__c rec: lstSU ){
                     System.debug('>>>>>>>>>refName:' + rec.Name);
                     System.debug('>>>>>>>>>refId:  ' + rec.id);
                     rec.Referring_Service__c = master.id;
                     lstSURefToUpdate.add(rec);
                 }
                 if (lstSURefToUpdate.size() > 0){
                     Savepoint sp = Database.setSavepoint();
                    try
                      {
                      //Update ServiceUsage records.
                      upsert lstSURefToUpdate;
                      }catch(Exception ex){Database.rollback(sp);
                           ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while updating Service Usages.');
                           ApexPages.addMessage(message);
                           return null;}
                 
                 }
             
             }
        } catch (DmlException e) {
    // Process exception here
        }
     return new Pagereference('/'+master.Id);
    }

//Test script for code coverage.
public testMethod static void testController(){
	Id servRT;
	servRT = [select Id from RecordType where DeveloperName ='External' and SObjectType='Services__c'].id;
	
	Id servUseageRT;
	servUseageRT = [select Id from RecordType where DeveloperName ='Outgoing_Referral' and SObjectType='Service_Usage__c'].id;
	
    Account accRec = new Account(Name='Essex Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name ='Internal Organisation'].id);
    insert accRec;
    
    Services__c serv1 = new Services__c(Locality__c=accRec.id, RecordTypeId=servRT ,Service_Type__c='Befriending', Name='testControllerService');
    insert serv1;
    Services__c serv2 = new Services__c(Locality__c=accRec.id, RecordTypeId=servRT, Service_Type__c='Befriending', Name='testControllerService2');
    insert serv2;

	Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',mailingPostalCode ='ABC123', Birthdate =Date.Today(),
				RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert con1;
    
    Service_Usage__c servUsg1 = new Service_Usage__c(Service_Field__c=serv2.id,Primary_Service_User__c=con1.id,
        		Service_Type__c='Befriending', RecordTypeId= servUseageRT);
    insert servUsg1;
    
    Service_Usage__c servUsg2 = new Service_Usage__c(Service_Field__c=serv1.id,Primary_Service_User__c=con1.id,
        		Service_Type__c='Befriending', Referring_Service__c=serv2.id, RecordTypeId= servUseageRT);
    insert servUsg2;
    
    //Create instance of the class to test and initialise the list 
    ApexPages.currentPage().getParameters().put('masterid', serv1.id); 
    ApexPages.currentPage().getParameters().put('childid', serv2.id);
    mergeServices conCls= new mergeServices(); 
    conCls.mergeService();
    //conCls.requestMergeService();
    }    
}