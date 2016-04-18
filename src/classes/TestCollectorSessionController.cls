@isTest
public with sharing class TestCollectorSessionController{

/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for LastTransactionDateLookup Class.
 *  Author  : Mike Tinson
 *  Date    : 08-10-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class to test CollectorSessionController Class. 
 *               
 *  Modification History
 *
 *  Date            Who     Description 
 *  dd-mm-yyyy      ??      ??
 *                             
*******************************************************************************************/
   static testMethod void TestCollectorSessionController(){
     
    //Add Contact RecordTypes to a Map Collection. 
        Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
        for (RecordType rt : [SELECT rt.Id, rt.DeveloperName FROM RecordType rt WHERE rt.IsActive = true and rt.SObjectType = 'Contact']){
            contactRTMap.put(rt.DeveloperName, rt);
        }             
     Contact ContactToSave = new Contact();    
    Contact recCon = new Contact(FirstName = 'Albert', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Collector'].id);
    insert recCon;  
    datetime dt= datetime.now();
    dt = dt.AddDays(1);
    datetime dt2 = dt.AddDays(10);
        
    Account accRec = new Account(Name='North West London Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id);
    insert accRec;
    Collection__c CollectRec = new Collection__c (Name='TestCollection', Start_Date__c = dt.date(), End_Date__c = dt2.date());
    insert CollectRec;
    
    Collection_Location__c collLocRec = new Collection_Location__c(Name='TestLocation', Account__c=accRec.id, Collection__c = CollectRec.id, Collection_Activity__c = 'Bucket collection', Maximum_Number_of_Volunteers__c= 20,Minimum_Number_of_Volunteers__c=10, Number_of_volunteers_per_session__c = 5, Status__c ='Open'); 

    insert collLocRec;
    Collection_Time_Slot__c CTSrec = new Collection_Time_Slot__c(Collection_Location__c = collLocRec.id, Duration_in_minutes__c = 60, Start_Date_Time__c = dt);
    insert CTSrec;
    //second collection one day later.
    Collection_Time_Slot__c CTSrec2 = new Collection_Time_Slot__c(Collection_Location__c = collLocRec.id, Duration_in_minutes__c = 60, Start_Date_Time__c = dt.AddDays(1));
    insert CTSrec2;
    //third collection one day later.
    Collection_Time_Slot__c CTSrec3 = new Collection_Time_Slot__c(Collection_Location__c = collLocRec.id, Duration_in_minutes__c = 60, Start_Date_Time__c = dt.AddDays(1));
    insert CTSrec3;
    //insert one session
    Collector_Session__c sessrec = new Collector_Session__c(Collector__c=recCon.Id, CollectionSession__c= CTSrec3.id);
    Insert sessrec;
       //Now insert data causing the DF_Contact__c trigger to fire. 
       
     Test.startTest();
     ApexPages.currentPage().getParameters().put('id', recCon.id);  
     CollectorSessionController conCls= new CollectorSessionController (new ApexPages.StandardController(recCon));       
     List<SelectOption> availDays = conCls.getlstAvailableDays();
     List<SelectOption> availCollections=conCls.getlstCollectionOptions();
     List<SelectOption> availLocations=conCls.getlstLocationOptions();
     conCls.PageSize=1;
     conCls.ClearResult();
     conCls.PageReSized();
     conCls.doSearch();
     
      
     System.debug('.......SearchedSessions size' + conCls.lstSearchedSessions.size()); 
     
     String selectedLocation ='TestLocation';
     conCls.selectLocation=selectedLocation;
     //If (availLocations.size()>0)
     //    {selectedLocation=availLocations.getValue();}
     String selectDate;
     Date tmpDt = date.today().AddDays(1);
     selectDate = tmpDt.format();
     conCls.selectDate = selectDate;
     conCls.doSearch();
     
     //conCls.RetrieveExistingSessions();
     conCls.sortNSearch();
     conCls.next();
     conCls.previous();
    /**
    find a session and select it
    **/ 
    conCls.selectDate=null;
    conCls.selectLocation=null;
    conCls.doSearch();      
    if(conCls.lstSearchedSessions.size()>0) 
    {
        conCls.lstSearchedSessions.get(0).isSelected=true;
        
    }    
    System.debug('.......searchedsessions size' + conCls.lstSearchedSessions.size()); 
    conCls.InsertSelected();
    conCls.doSearch();  
    conCls.saveNReturn();    
    if(conCls.lstSearchedSessions.size()>0) 
    {
        conCls.lstSearchedSessions.get(0).isSelected=true;
        
    }    
    System.debug('.......searchedsessions size' + conCls.lstSearchedSessions.size()); 
    conCls.InsertSelected();
    conCls.saveNReturn();
    
     
       
/**
public  System.PageReference ClearResult()
public  System.PageReference InsertSelected()
public  System.PageReference PageReSized()
private void RetrieveExistingSessions()
public  ANY clone()
public  System.PageReference doSearch()
public  LIST getlstAvailableDays()
public  LIST getlstLocationOptions()
public  System.PageReference next()
public  System.PageReference previous()
public  System.PageReference saveNReturn()
public  System.PageReference sortNSearch()
**/
        Test.stopTest();
                     
    }  
 
}