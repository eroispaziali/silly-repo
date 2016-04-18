/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Apex Controller for ContactServiceUsage RelatedList VF page.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-11-10
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: VF Controller for ContactServiceUsageRelatedList VF Page.
 *               VF Page is shown as RelatedList on Contact Detail Page and as Seperate Page, when navigated from More Link.
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2012-02-07  MT  removed secondary service user (Secondary_Service_User__c) 
 *  2012-05-03  MT  extract only one first name so that SF does not raise irrelevant error message (Obs112)
 *  2012-09-17  MT  return surname without any quotes (O'name) 
 *                             
*******************************************************************************************/
public class  ContactServiceUsageRelatedListController
{

public ApexPages.StandardController stdController;
public Contact con;
public List<RelatedServiceUsageClass> lstRelSU {get;set;}
public Integer totalRecCnt {get;set;}
public string SUKeyPrefix {get;set;}
public string CONFirstname {get;set;}
public string CONLastname {get;set;}
private string SERVICE_EXT_RECTYPE ='External Service';

    // Standard controller constructor.
    public ContactServiceUsageRelatedListController(ApexPages.StandardController pController) {
        stdController = pController;
        con = (Contact) stdController.getRecord(); 
        system.debug('@@@@@@@@@@@@@@@'+con.id);
    }
    
    //Method is called when the page is loaded, similar to Constructor
    public PageReference AutoRunNonExternalSU(){    
        SUKeyPrefix = Schema.getGlobalDescribe().get('Service_Usage__c').getDescribe().getKeyPrefix();
        //Full URL parameter defines to limit no. of rows to 5.
        Integer qryLimit = (ApexPages.currentPage().getParameters().get('full')==null) ? 5 : 9999;
        
        Map<Id,Service_Usage__c> lstServUsage = new Map<Id,Service_Usage__c>([Select Name,Service_Field__c,Service_Field__r.Name,
            Service_Type__c,Date_of_last_Activity__c,Referral_Date__c,Closure_Date__c,Risk_Identified__c,Public_Alert_Message_Required__c,Assigned_Worker__r.Name  
            from Service_Usage__c where (Primary_Service_User__c =:con.id ) 
            and Service_Field__r.RecordType.Name !=: SERVICE_EXT_RECTYPE order by Closure_Date__c desc Limit :qryLimit]);
        
        //This is Seperate Class which run query under User privileges.
        ContactServiceUsageWithSharing clsAccessible = new ContactServiceUsageWithSharing();
        
        //Returned accessible/visible ServiceUsage records Ids.
        Set<Id> setAccessibleRecs = clsAccessible.getAccessibleRecords(lstServUsage.keyset());
        
        lstRelSU = new List<RelatedServiceUsageClass>();
        
        //Iterate to populate specail Inner Class with flag to say a ServiceUsage record is accessible to user.
        for(Service_Usage__c rec: lstServUsage.Values())
        {
            RelatedServiceUsageClass cls = new RelatedServiceUsageClass();
            cls.recSU = rec;
            
            //If record found in Accessible set then will have edit and view link of page.
            cls.isAccessible = setAccessibleRecs.contains(rec.id);
            lstRelSU.add(cls);
        }
        
        //Get the count of records, this derives whether More link on Page be shown or not.
        totalRecCnt = [Select count() from Service_Usage__c where (Primary_Service_User__c =:con.id ) and Service_Field__r.RecordType.Name !=: SERVICE_EXT_RECTYPE];
        //If First Name contains more than one name (such as Mary Ann), return only one
        string strName;
        if (con.FirstName==null)
            {
            CONFirstname = '';
            }
        else
            {
            strName = con.FirstName;
            string[] strArr= strName.split(' ');
            CONFirstname = strArr[0];
            }
        //If last name contained a quote, the screen did nothing.  
        
        if (con.LastName==null)
            {
            CONLastname = '';
            }
        else
            {
            String strLastName= String.escapeSingleQuotes(con.LastName);
            CONLastName=strLastName;
            }
        return null;
   }
   
    //Method is called when the page is loaded, similar to Constructor
    public PageReference AutoRunExternalSU(){    
        SUKeyPrefix = Schema.getGlobalDescribe().get('Service_Usage__c').getDescribe().getKeyPrefix();
        //Full URL parameter defines to limit no. of rows to 5.
        Integer qryLimit = (ApexPages.currentPage().getParameters().get('full')==null) ? 5 : 9999;
        
        Map<Id,Service_Usage__c> lstServUsage = new Map<Id,Service_Usage__c>([Select Name,Service_Field__c,Service_Field__r.Name,
            Referral_Date__c,Referring_Service__c,Referring_Service__r.Name,Referral_Type__c,Referral_Outcome__c
            from Service_Usage__c where (Primary_Service_User__c =:con.id ) 
            and Service_Field__r.RecordType.Name =: SERVICE_EXT_RECTYPE order by Referral_Date__c desc Limit :qryLimit]);
        
        //This is Seperate Class which run query under User privileges.
        ContactServiceUsageWithSharing clsAccessible = new ContactServiceUsageWithSharing();
        
        //Returned accessible/visible ServiceUsage records Ids.
        Set<Id> setAccessibleRecs = clsAccessible.getAccessibleRecords(lstServUsage.keyset());
        
        lstRelSU = new List<RelatedServiceUsageClass>();
        
        //Iterate to populate specail Inner Class with flag to say a ServiceUsage record is accessible to user.
        for(Service_Usage__c rec: lstServUsage.Values())
        {
            RelatedServiceUsageClass cls = new RelatedServiceUsageClass();
            cls.recSU = rec;
            
            //If record found in Accessible set then will have edit and view link of page.
            cls.isAccessible = setAccessibleRecs.contains(rec.id);
            lstRelSU.add(cls);
        }
        
        //Get the count of records, this derives whether More link on Page be shown or not.
        totalRecCnt = [Select count() from Service_Usage__c where (Primary_Service_User__c =:con.id ) and Service_Field__r.RecordType.Name =: SERVICE_EXT_RECTYPE];
        return null;
   }   
   
//Inner Class
public class RelatedServiceUsageClass
{
    public boolean isAccessible {get;set;}
    public Service_Usage__c recSU {get;set;}
}

//Test script for code coverage.
public testMethod static void testController()
{
    Profile prof = [Select Id from Profile where Name = 'System Administrator' limit 1];
    User usr =[Select Id from User where IsActive =true and ProfileId =: prof.id  limit 1]; 
        
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    
    Services__c serv = new Services__c(Locality__c=accRec.id,Service_Type__c='Advocacy');//Name='testControllerService');
    insert serv;
    
 
 
    Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert con1;
    
     Account acc = new Account(Name='Test Region',RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'Internal%'].id);
        insert acc; 
        Account landlord = new Account(Name='Test landlord',Category__c='Landlord',RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'External%'].id);
        insert landlord;                    
        Account landlordagent = new Account(Name='Test landlord agent',Category__c='Landlord Agent',RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'External%'].id);
        insert landlordagent;
        Location__c loc = new Location__c(Name='Test Location',RecordTypeId=[Select Id from RecordType where SObjectType='Location__c' and Name Like 'Lease/License'].id,
                             Where__c=acc.Id, Landlord__c=landlord.Id, Landlord_Agent__c=landlordagent.Id);
        insert loc;
    
    //service was 'Home facilities & services'
    //Services__c serv2 = new Services__c(Locality__c=accRec.id,Service_Type__c='Newsletter',
    //    Primary_contact__c=usr.id,Default_Location__c=loc.id);
    Services__c serv2 = new Services__c(Locality__c=accRec.id,Service_Type__c='Newsletter',
        Default_Location__c=loc.id);
    
    insert serv2;   
    
    Service_Usage__c servUsg1 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con1.id,
        Service_Type__c='Advocacy');
    insert servUsg1;
    
    Service_Usage__c servUsg2 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con1.id,
        Service_Type__c='Advocacy');
    insert servUsg2;
        
    
    // service was 'Home facilities & services'
    Service_Usage__c servUsg3 = new Service_Usage__c(Service_Field__c=serv2.id,Primary_Service_User__c=con1.id,
        Service_Type__c='Newsletter');
    insert servUsg3;
    


    System.runAs(usr)
    {
    ApexPages.currentPage().getParameters().put('Id', con1.id);        
    ContactServiceUsageRelatedListController conCls= new ContactServiceUsageRelatedListController(new ApexPages.StandardController(con1));
    conCls.AutoRunExternalSU();
    conCls.AutoRunNonExternalSU();
    }

    ApexPages.currentPage().getParameters().put('Id', con1.id);        
    ContactServiceUsageRelatedListController conCls= new ContactServiceUsageRelatedListController(new ApexPages.StandardController(con1));    
    conCls.AutoRunExternalSU();
    conCls.AutoRunNonExternalSU();
}  
}