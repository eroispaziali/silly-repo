/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Apex Controller for ContactServiceUsage a Service Referrals for Contact.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-11-11
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: VF Controller for ContactServiceUsage VF Page.
 *            User can search for a Service, based on Type,Locality and add to Service Usage. Following fields data is captured:
 *                1) Referral Date
 *                2) Service Usage Type  
 *                3) Referral Type
 *                4) Referring Service
 *                5) Referral Outcome  
 *  
 *     
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2012-02-07  MT  removed secondary service user (Secondary_Service_User__c) 
 *  2012-03-28  MT  added rudimentary error message handling to show errors, rather than do nothing with them.
 *                  removed use of Like for searching for Service Types as some have parenthesis.  
 *  2012-08-28  MT  LIMIT select statements to stop blowing limits and improve test cases so that 
 *                  limits are not exceeded.
 *                             
*******************************************************************************************/
public class ContactServiceUsageController
{
public ApexPages.StandardController stdController;
public Contact con;
public AccountLink__c searchService {get;set;}
public Service_Usage__c searchServiceUsage {get;set;}
public string strSearchKeyword {get;set;}
public List<SearchedServiceClass> lstSearchedServices {get;set;}
public List<SearchedServiceClass> lstToShowSearchedServices {get;set;}
public List<SearchedServiceClass> lstAddedServices {get;set;}
public boolean bolUnSelect {get;set;}

public boolean hasNext {get;set;}
public boolean hasPrevious {get;set;}

public string sortExpression {get;set;}
public string sortDirection {get;set;}

private string SERVICE_EXT_RECTYPE ='External Service';
private string REFERRAL_SOURCE='Internal Referral';
public string SERVUSAGE_OUTGOING_RECTYPE { get{return 'Outgoing Referral';}} 
//public string SERVUSAGE_DEFAULT_RECTYPE { get{return 'Master';}} 
public Integer PageSize {get;set;}
public Integer nextStartRowNum {get;set;}
public Integer prevStartRowNum {get;set;}
private boolean isSorting;

public List<SelectOption> lstServiceTypes {
        get{

            List<SelectOption> lstOptions= new List<SelectOption>();
            lstOptions.add(new SelectOption('','--None--'));
            
            //Prepare a list of from AttendanceStatus, to show on DataTable column header.
            for(Schema.PicklistEntry pickList : Services__c.service_type__c.getDescribe().getPickListValues())
            {
                lstOptions.add(new SelectOption(pickList.getValue(),pickList.getLabel()));
            }
            return lstOptions;
        }
}

public void emptyMethod() {
        
}

    // Standard controller constructor.
    public ContactServiceUsageController(ApexPages.StandardController pController) {
        stdController = pController;
        con = (Contact) stdController.getRecord(); 
        system.debug('@@@@@@@@@@@@@@@'+con.id);
        searchService = new AccountLink__c();
        lstSearchedServices = new List<SearchedServiceClass>();
        lstAddedServices = new List<SearchedServiceClass>();
        searchServiceUsage = new Service_Usage__c(RecordTypeId=Schema.SObjectType.Service_Usage__c.getRecordTypeInfosByName().get(SERVUSAGE_OUTGOING_RECTYPE).getRecordTypeId());
        sortDirection='ASC';
        PageSize = 10;
        //Retrieve Service Usages already added.
        for(Service_Usage__c rec:[Select Service_Field__c,Service_Field__r.Name,Service_Field__r.Locality__r.Name,recordType.Name,
                Service_Field__r.service_type__c,Referral_Date__c,Service_Type__c,Referral_Type__c,Service_Field__r.RecordType.Name,
                Referring_Service__c,Referral_Outcome__c from Service_Usage__c where Referral_Source__c =:REFERRAL_SOURCE and
                (Primary_Service_User__c=:con.Id) ])
        {
            SearchedServiceClass tmpCls = new SearchedServiceClass();
            tmpCls.recSU=rec;
            tmpCls.isNew = false;
            lstAddedServices.add(tmpCls);    
        }
        
        isSorting=false;
        system.debug('+++++++++++++++++++++++++'+lstAddedServices);
    }
    
    //Previous link button handler
    public PageReference previous()
    {
        Integer rowNum=1;
        lstToShowSearchedServices =  new List<SearchedServiceClass>();
        //Populate subset of records to show.
        for(SearchedServiceClass rec : lstSearchedServices)
        {
        system.debug('###############'+rowNum+'/////'+nextStartRowNum+'/////'+(nextStartRowNum-PageSize));
            if(rowNum>=prevStartRowNum  && rowNum<(prevStartRowNum+PageSize))
                lstToShowSearchedServices.add(rec);

          rowNum++;      
        }   
        
        //Re-arranging row pointers.
        nextStartRowNum=prevStartRowNum+PageSize;
        prevStartRowNum -= PageSize;
        hasPrevious =   (prevStartRowNum >0); 
        hasNext = (lstSearchedServices.size()>=(nextStartRowNum));
        return null;
    }
    
    //Next link button handler
    public PageReference next()
    {
        Integer rowNum=1;
        lstToShowSearchedServices =  new List<SearchedServiceClass>();
        //Populate subset of records to show.
        for(SearchedServiceClass rec : lstSearchedServices)
        {
        //system.debug('###############'+rowNum+'/////'+nextStartRowNum+'/////'+rowNum+'/////'+(nextStartRowNum+PageSize));
            if(rowNum>=nextStartRowNum && rowNum<(nextStartRowNum+PageSize))
                lstToShowSearchedServices.add(rec);

          rowNum++;      
        }   
        
        //Re-arranging row pointers.
        prevStartRowNum =nextStartRowNum-PageSize;
        nextStartRowNum+=PageSize;
        hasNext =   (lstSearchedServices.size()>=nextStartRowNum); 
        hasPrevious = (prevStartRowNum >=1);
        return null;
    }    
    
    //No. of Records to show/Page combo change handler
    public PageReference PageReSized()
    {
        Integer rowNum=1;
        lstToShowSearchedServices = new List<SearchedServiceClass>();
        
        //Populate subset of records to show. Always show first set of PageSize records.
        for(SearchedServiceClass rec : lstSearchedServices)
        {
            if(rowNum++<=PageSize)
                lstToShowSearchedServices.add(rec);
        }
        
        //Re-arranging row pointers.
        hasNext = lstSearchedServices.size()>PageSize;
        hasPrevious = false;
        nextStartRowNum=PageSize+1;
        prevStartRowNum =1;
        return null;
    }

    //Clear previous search result, button handler
    public PageReference ClearResult()
    {
        searchService.service_type__c='';
        searchService.Locality__c=null;
        strSearchKeyword='';
        lstToShowSearchedServices = new List<SearchedServiceClass>();
        
        return null;
    }
    
    //Search records. Invoked from button click or actionfunction on VF.
    public PageReference doSearch()
    {
        LIST<LIST<SObject>> lstSearchResult = new LIST<LIST<SObject>>();
        
        //Replace all astrick if user has input with blank space.
        string strSrcKeyword = strSearchKeyword.replaceAll('\\*','') + '*';
 
        //If User has not selected Service Type then select all records.
        //some services have parentheses in which SOQL interprete as an optional string.  
        //Therefore if service has been selected, use the full string, otherwise use Like
        string strServType = (searchService.service_type__c==null)? '%' : searchService.service_type__c ; 
        
        //If the method is called when User is trying to sort result by Service Name
        if(!isSorting)
        {
            //If user entered a keyword to search.
            if(strSrcKeyword.length()>2)
            {
                if(sortDirection.equalsIgnoreCase('ASC'))
                {
                    if(searchService.Locality__c==null)
                    {
                    if (searchService.service_type__c==null) {
                        lstSearchResult = [FIND :strSrcKeyword IN Name FIELDS RETURNING Services__c (Id,service_Status__c,service_type__c,
                            Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c,Service_Criteria__c
                            where service_Status__c='Open' and service_type__c Like :strServType order by Name Asc  LIMIT 200)];
                         }
                    else {
                    lstSearchResult = [FIND :strSrcKeyword IN Name FIELDS RETURNING Services__c (Id,service_Status__c,service_type__c,
                            Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c,Service_Criteria__c
                            where service_Status__c='Open' and service_type__c = :strServType order by Name Asc  LIMIT 200)];
                        }
                    }
                    else//If locality is not NULL
                    {
                    if (searchService.service_type__c==null) {
                        lstSearchResult = [FIND :strSrcKeyword IN Name FIELDS RETURNING Services__c (Id,service_Status__c,service_type__c,
                        Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c,Service_Criteria__c
                         where (Locality__c =:searchService.Locality__c or National_Service__c =true)  and  service_Status__c='Open' and service_type__c Like :strServType 
                         order by Name Asc LIMIT 200)]; 
                        }
                    else {
                    lstSearchResult = [FIND :strSrcKeyword IN Name FIELDS RETURNING Services__c (Id,service_Status__c,service_type__c,
                        Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c,Service_Criteria__c
                         where (Locality__c =:searchService.Locality__c or National_Service__c =true)  and  service_Status__c='Open' and service_type__c = :strServType 
                         order by Name Asc  LIMIT 200)];                    
                         }
                    }

                }
                else//Query Desc
                {
                    if(searchService.Locality__c==null)
                    {
                    if (searchService.service_type__c==null) {
                        lstSearchResult = [FIND :strSrcKeyword IN NAME FIELDS RETURNING Services__c (Id,service_Status__c,service_type__c,
                            Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c,Service_Criteria__c 
                            where service_Status__c='Open' and service_type__c Like :strServType 
                            order by Name Desc LIMIT 200)];                    
                        }
                    else {
                        lstSearchResult = [FIND :strSrcKeyword IN NAME FIELDS RETURNING Services__c (Id,service_Status__c,service_type__c,
                            Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c,Service_Criteria__c 
                            where service_Status__c='Open' and service_type__c = :strServType 
                            order by Name Desc LIMIT 200)]; 
                        }
                    }
                    else//If locality is not NULL
                    {
                    if (searchService.service_type__c==null) {
                        lstSearchResult = [FIND :strSrcKeyword IN NAME FIELDS RETURNING Services__c (Id,service_Status__c,service_type__c,
                            Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c,Service_Criteria__c 
                            where (Locality__c =:searchService.Locality__c  or National_Service__c =true) and  service_Status__c='Open' and service_type__c Like :strServType 
                            order by Name Desc LIMIT 200)];                 
                        }
                    else {
                        lstSearchResult = [FIND :strSrcKeyword IN NAME FIELDS RETURNING Services__c (Id,service_Status__c,service_type__c,
                            Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c,Service_Criteria__c 
                            where (Locality__c =:searchService.Locality__c  or National_Service__c =true) and  service_Status__c='Open' and service_type__c = :strServType 
                            order by Name Desc LIMIT 200)];                 
                        }
                    }
                }
            }
            else //Keyword is blank then search all Services.
            {
                strSrcKeyword = '%' + strSrcKeyword.replaceAll('\\*','') + '%';
                 if(sortDirection.equalsIgnoreCase('ASC'))
                 {
                    if(searchService.Locality__c==null)
                    {
                        if (searchService.service_type__c==null) {
                            lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,
                            RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c  from Services__c where 
                            service_Status__c='Open' and Name like :strSrcKeyword and 
                            service_type__c like :strServType order by Name ASC LIMIT 200]);                    
                        }
                    else {
                        lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,
                            RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c  from Services__c where 
                            service_Status__c='Open' and Name like :strSrcKeyword and 
                            service_type__c = :strServType order by Name ASC LIMIT 200]); 
                        }
                    }
                    else//If locality is not NULL
                    {
                    if (searchService.service_type__c==null) {
                        lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,
                            RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c  from Services__c where 
                            (Locality__c =:searchService.Locality__c  or National_Service__c =true) and service_Status__c='Open' and Name like :strSrcKeyword and 
                            service_type__c like :strServType order by Name ASC LIMIT 200]);                    

                        }
                    else
                        {
                        lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,
                            RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c  from Services__c where 
                            (Locality__c =:searchService.Locality__c  or National_Service__c =true) and service_Status__c='Open' and Name like :strSrcKeyword and 
                            service_type__c = :strServType order by Name ASC LIMIT 200]);                    
                        }
                    }

                }
                else//Query Desc
                {
                    if(searchService.Locality__c==null)
                    {
                    if (searchService.service_type__c==null) {
                        lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,
                            RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c from Services__c where 
                            service_Status__c='Open'  and Name like :strSrcKeyword and 
                            service_type__c like :strServType order by Name DESC LIMIT 200]);                                
                        }
                    else {
                        lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,
                            RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c from Services__c where 
                            service_Status__c='Open'  and Name like :strSrcKeyword and 
                            service_type__c = :strServType order by Name DESC LIMIT 200]);                                
                        }
                    }
                    else//If locality is not NULL
                    {
                    if (searchService.service_type__c==null) {
                        lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,
                            RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c from Services__c where 
                            (Locality__c =:searchService.Locality__c  or National_Service__c =true) and service_Status__c='Open'  and Name like :strSrcKeyword and 
                            service_type__c like :strServType order by Name DESC LIMIT 200]);                                
                        }
                    else {
                        lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,
                            RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c from Services__c where 
                            (Locality__c =:searchService.Locality__c  or National_Service__c =true) and service_Status__c='Open'  and Name like :strSrcKeyword and 
                            service_type__c = :strServType order by Name DESC LIMIT 200]);                                
                        }
                    }
                }
            }
        }
        else//Sort the list.
        {
            //Sort only list which user is seeing, but not re-run full query again, as user might have added few services.
            Set<Id> setSortServIds = new Set<Id>();
            
            //Retrive ServiceIds from searchedList.
            for(SearchedServiceClass rec:lstSearchedServices)
            {
                setSortServIds.add(rec.recSU.Service_Field__c);
            }
            
            //Execute query based on Sorting order.
            if(sortDirection.equalsIgnoreCase('ASC'))
             {
                lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c from Services__c where Id=:setSortServIds order by Name ASC LIMIT 200]);
            }
            else
            {
                lstSearchResult.add([Select service_Status__c,Service_Criteria__c,service_type__c,Name,RecordTypeId,RecordType.Name,service_areaservedtext__c,service_city__c,service_county__c from Services__c where Id=:setSortServIds order by Name DESC LIMIT 200]);            
            }            
            
        }
        
        Integer rowNum=1;
        lstToShowSearchedServices =  new List<SearchedServiceClass>();
        lstSearchedServices = new List<SearchedServiceClass>();
        
        //Refresh searchResult list
        for(List<SObject> rec : lstSearchResult)
        {
            for(SObject rec2: rec)
            {
                SearchedServiceClass tmpCls = new SearchedServiceClass();
                tmpCls.recSU = new Service_Usage__c();
                tmpCls.isSelected=false;
                tmpCls.recSU.Service_Field__c=rec2.id;
                tmpCls.recServ=((Services__c)rec2);
                lstSearchedServices.add(tmpCls);
                
                //No. of rows to show from List.
                if(rowNum++<=PageSize)
                    lstToShowSearchedServices.add(tmpCls);
            }
        }
        
        //Re-arrange record pointers.
        hasNext = lstSearchedServices.size()>PageSize;
        hasPrevious = false;
        nextStartRowNum=PageSize+1;
        prevStartRowNum =1;
        if(lstSearchedServices.size()==0 ){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.WARNING,'No records were found based on your criteria.' );
                ApexPages.addMessage(message);
                }
        else {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, lstSearchedServices.size() + ' Records found based on your criteria.');
                ApexPages.addMessage(message);
                }
        return null;
    }
    
    //InsertSelected button handler.
    public PageReference InsertSelected()
    {   
        List<SearchedServiceClass> lstTmp= new List<SearchedServiceClass>();
        //Get all ServiceUsage RecordTypes.
        //Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Service_Usage__c.getRecordTypeInfosByName(); 
                  
        
        //Add the selected services to AddList.
        for(SearchedServiceClass rec: lstSearchedServices)
        {
            if(rec.isSelected)
            {
                rec.recSU.Service_Field__c = rec.recServ.id;
                rec.recSU.Referral_Date__c=searchServiceUsage.Referral_Date__c;
                rec.recSU.Referring_Service__c=searchServiceUsage.Referring_Service__c;
                rec.recSU.Referral_Type__c=searchServiceUsage.Referral_Type__c;

                rec.isNew=true;
                system.debug('#############rec.recServ.service_type__c###############'+rec.recServ.service_type__c);
                try
                  {
                      
                      //If Selected Service RecordType is External then, SU RecType will be Outgoing Referral
                      if(rec.recServ.RecordType.Name.equalsIgnoreCase(SERVICE_EXT_RECTYPE))
                      {
                          rec.recSU.RecordTypeId=Schema.SObjectType.Service_Usage__c.getRecordTypeInfosByName().get(SERVUSAGE_OUTGOING_RECTYPE).getRecordTypeId();
                          rec.isSU_Rec_Outgoing=true;
                      }
                      else//If Service RecType is not External, then User default RecordType will be set and WF will assign appropriate.
                      {
                          //rec.recSU.RecordTypeId=rtMapByName.get(rec.recServ.service_type__c).getRecordTypeId();
                          rec.recSU.service_type__c=rec.recServ.service_type__c;
                      }
                      //rec.recSU.RecordTypeId=rtMapByName.get(SERVUSAGE_DEFAULT_RECTYPE).getRecordTypeId();
                      
                  }catch(exception ex){system.debug('########exception###'+ex);throw ex;}                
               lstAddedServices.add(rec);
               system.debug('########rec.recSU.RecordTypeId###'+rec.recSU.RecordTypeId);
            }
            else
            {
                lstTmp.add(rec);
            }
        }
        
        system.debug('##########lstTmp#########'+lstTmp);

        //Refresh searched List, by removing selected services.
        lstSearchedServices=lstTmp;

        bolUnSelect=false;
        
        Integer rowNum=1;
        lstToShowSearchedServices = new List<SearchedServiceClass>();

        //Refresh list, no. of rows to show
        for(SearchedServiceClass rec : lstSearchedServices)
        {
                if(rowNum++<=PageSize)
                    lstToShowSearchedServices.add(rec);
        }
        
        //Re-arrange record pointers.
        hasNext = lstSearchedServices.size()>PageSize;
        hasPrevious = false;
        nextStartRowNum=PageSize+1;
        prevStartRowNum =1;
        
        system.debug('##########before return############');
        return null;
    }
    
//Handle column sorting click.
public PageReference sortNSearch()
{
    //Toggle sorting order.
    sortDirection = (sortDirection.equalsIgnoreCase('ASC'))? 'DESC' : 'ASC';
    
    isSorting=true;
    //Invoke search method.
    doSearch();
    isSorting=false;
    return null;
}

//Save and Return Button handler.
public PageReference saveNReturn() {
  ///Saving or Creation logic
  Id contactId = ApexPages.currentPage().getParameters().get('id');
  List<Service_Usage__c> lstSUToCreate = new List<Service_Usage__c>();
  
  //Iterate through all Added Services List to set default values;    
  for(SearchedServiceClass rec:lstAddedServices)
  {
      try
      {
      //Set default values only if record is New/To be created and not for Update.
      if(rec.recSU.id==null)
      {
          rec.recSU.Primary_Service_User__c=contactId;
          rec.recSU.Referral_Source__c=REFERRAL_SOURCE;
          //Default recordtyp 'Master' will be set based on default set for User Profile.
          //rec.recSU.RecordTypeId=Schema.SObjectType.Service_Usage__c.getRecordTypeInfosByName().get(SERVUSAGE_DEFAULT_RECTYPE).getRecordTypeId();
      }
      lstSUToCreate.add(rec.recSU);
      }catch(Exception ex){
      //throw ex;}
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while creating Referral.');
                ApexPages.addMessage(message);
                return null;      }
  }
  
system.debug('###########lstAddedServices#############'+lstAddedServices);
  if(lstSUToCreate.size()>0)
  {
      // Create a savepoint because the data should not be committed to the database
      Savepoint sp = Database.setSavepoint();

      try
      {
          //Insert or Update ServiceUsage records.
          upsert lstSUToCreate;
      }catch(Exception ex){Database.rollback(sp);
                           ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while updating Referral.');
                           ApexPages.addMessage(message);
                           return null;}
  }
  //Navigate back to Contact Detail Page.
  return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
 }

//Inner Class to hold flags, Service and ServiceUsage data.
public class SearchedServiceClass
{
    public Service_Usage__c recSU {get;set;}
    public Services__c recServ {get;set;}
    public boolean isSelected {get;set;}
    public boolean isSU_Rec_Outgoing {get;set;}
    public boolean isNew {get;set;}
}    

//Test script for code coverage.
public testMethod static void testController()
{
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    
    Services__c serv = new Services__c(Locality__c=accRec.id,Service_Type__c='Advocacy');//Name='testControllerService');
    insert serv;
    
    Contact con1 = new Contact(Salutation='Mr',FirstName='Abc',LastName='Test1',mailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert con1;
    
    Service_Usage__c servUsg1 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con1.id,
        Service_Type__c='Advocacy');
    insert servUsg1;
    
    Service_Usage__c servUsg2 = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=con1.id,
        Service_Type__c='Advocacy');
    insert servUsg2;
    
    Profile prof = [Select Id from Profile where Name = 'System Administrator' limit 1];
    User usr =[Select Id from User where IsActive =true and ProfileId !=: prof.id  limit 1]; 
/*
    System.runAs(usr)
    {
    ApexPages.currentPage().getParameters().put('Id', con1.id);        
    ContactServiceUsageController conCls= new ContactServiceUsageController(new ApexPages.StandardController(con1));
    }
*/
    ApexPages.currentPage().getParameters().put('Id', con1.id);        
    ContactServiceUsageController conCls= new ContactServiceUsageController(new ApexPages.StandardController(con1));  
    conCls.strSearchKeyword='con';
    conCls.doSearch();   
    conCls.sortNSearch(); 
    conCls.doSearch();
    conCls.sortNSearch();      
    conCls.strSearchKeyword='';
    conCls.doSearch();
    conCls.sortNSearch(); 
    conCls.doSearch();
    conCls.sortNSearch();        
    conCls.previous();
    conCls.next();
    conCls.PageReSized();  
    conCls.sortNSearch();
    List<SelectOption> lstSel =conCls.lstServiceTypes;
    if(conCls.lstSearchedServices.size()>0) 
    {
        conCls.lstSearchedServices.get(0).isSelected=true;
        conCls.lstSearchedServices.get(0).recServ.service_type__c='Advocacy';
    }    

    conCls.InsertSelected();
    conCls.saveNReturn();
    conCls.ClearResult();
    
    conCls.searchService.Locality__c=accRec.id;
    conCls.strSearchKeyword='con';
    conCls.doSearch();   
    conCls.sortNSearch(); 
    conCls.doSearch();
    conCls.sortNSearch();      
    conCls.strSearchKeyword='';
    conCls.doSearch();
    conCls.sortNSearch(); 
    conCls.doSearch();
    conCls.sortNSearch(); 
    
    
    // Delete Service Usage.
    delete servUsg1;
    delete servUsg2;
}  

}
