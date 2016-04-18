public class CollectorSessionController 
{
public ApexPages.StandardController stdController;
public Contact con;
public String selectLocation {get;set;}
public String selectCollection {get;set;}
public String selectDate {get;set;}
public List<SearchedSessionClass> lstToShowSearchedSessions {get;set;}
public List<SearchedSessionClass> lstSearchedSessions {get;set;}
public List<SearchedSessionClass> lstAddedSessions {get;set;}
public boolean bolUnSelect {get;set;}

public boolean hasNext {get;set;}
public boolean hasPrevious {get;set;}

public string sortExpression {get;set;}
public string sortDirection {get;set;}
public Integer PageSize {get;set;}
public Integer nextStartRowNum {get;set;}
public Integer prevStartRowNum {get;set;}
private boolean isSorting;
private Map<String, ID> MapAddedSessions {get;set;}


public CollectorSessionController (ApexPages.StandardController pController) {
    stdController = pController;
    con = (Contact) stdController.getRecord(); 
    lstAddedSessions = new List<SearchedSessionClass>();
    lstSearchedSessions  = new List<SearchedSessionClass>();
    MapAddedSessions = new Map<String, ID>();
    PageSize = 12;
    sortDirection='ASC';
    RetrieveExistingSessions();
    
}
private void RetrieveExistingSessions() { 
    List<Collector_Session__c> lstExistingSessions = new List<Collector_Session__c>([SELECT CollectionSession__c FROM Collector_Session__c WHERE Collector__c = :con.id]);
    List<Id> lstId = new List<Id>();

    if (lstExistingSessions.size()>0) {
        for (Collector_Session__c rec : lstExistingSessions)
        {
            lstId.add(rec.CollectionSession__c);
        }
        // get details of sessions
        List<Collection_Time_Slot__c> tmpListSessions = new List<Collection_Time_Slot__c>();
        tmpListSessions = [SELECT id, name, Collection_Location__c,Collection_Location__r.name,  Start_Date_Time__c, Duration_in_minutes__c, End_Date_Time__c, Count_of_Collectors__c 
                           from Collection_Time_Slot__c  WHERE id in :lstId ];
        for (Collection_Time_Slot__c  rec: tmpListSessions ){
            SearchedSessionClass tmpCls = new SearchedSessionClass();
            //CollectionSession__c tmpCS = new CollectionSession__c;
            //tmpCS = CollectionSession__c;
            
            tmpCls.recCTS = rec;
            //tmpCls.Collection_Location = Collection_Location__r.name;
            tmpCls.IsNew = false;
            //tmpCls.Collection_Location  = rec2.Collection_Location__r.Name;
            //tmpCls.recSU.Service_Field__c=rec2.id;
            //tmpCls.recServ=((Services__c)rec2);
            lstAddedSessions.add(tmpCls);
            MapAddedSessions.put(rec.id, rec.id);
        
        }
        
    }
}
//Inner Class to hold flags, Service and ServiceUsage data.
public class SearchedSessionClass
{
    public Collection_Time_Slot__c recCTS {get;set;}
    //public Services__c recServ {get;set;}
    public String Collection_Location {get;set;}
    public boolean isSelected {get;set;}
    //public boolean isSU_Rec_Outgoing {get;set;}
    public boolean isNew {get;set;}
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



public List<SelectOption> getlstAvailableDays(){
    List<SelectOption> lstTmpAvailDays = new List<SelectOption>();
    lstTmpAvailDays.add(new SelectOption('', '-- Select One --')); 
    String searchLocation = (selectLocation==null)? '%' : selectLocation;
    List<AggregateResult> datesAvailable = new List<AggregateResult>();
    if (searchLocation =='%')
    {
        datesAvailable = [select DAY_ONLY(Start_Date_Time__c) avail FROM Collection_Time_Slot__c WHERE Session_Available__c=true AND Collection_Location__r.Status__c='Open'  GROUP BY DAY_ONLY(Start_Date_Time__c) ORDER BY DAY_ONLY(Start_Date_Time__c)];
    }
    else 
    {
        datesAvailable = [select DAY_ONLY(Start_Date_Time__c) avail FROM Collection_Time_Slot__c WHERE Session_Available__c=true AND Collection_Location__r.Status__c='Open' and Collection_Location__c=:searchLocation   GROUP BY DAY_ONLY(Start_Date_Time__c) ORDER BY DAY_ONLY(Start_Date_Time__c)];
    }
    for (AggregateResult loc: datesAvailable)
    {
    
        Date dt = Date.valueof(loc.get('avail'));
        //String aaa = String.valueof(loc.get('avail'));
        String aaa = dt.format();
        lstTmpAvailDays.add (new SelectOption (aaa, aaa));
    }
    
    return lstTmpAvailDays;
}


public List<SelectOption> getlstCollectionOptions() {

    List<SelectOption> lstCollectionOptions= new List<SelectOption>();
    lstCollectionOptions.add(new SelectOption('', '-- Select One --')); 
    
    for (Collection__c loc:[select id, name from Collection__c  WHERE Status__c='Open' ORDER BY name])
    {
        //String aaa = loc.name;
        lstCollectionOptions.add (new SelectOption (loc.id, loc.name));
    }

    return lstCollectionOptions;

}
public List<SelectOption> getlstLocationOptions() {

    List<SelectOption> lstLocationOptions = new List<SelectOption>();
    lstLocationOptions.add(new SelectOption('', '-- Select One --')); 
    String searchCollection = (selectCollection==null)? '%' : selectCollection;
    for (Collection_Location__c loc:[select id, name from Collection_Location__c  WHERE Status__c='Open' AND Collection__c =:searchCollection ORDER BY name])
    {
        //String aaa = loc.name;
        lstLocationOptions.add (new SelectOption (loc.id, loc.name));
    }

    return lstLocationOptions;

}

//Clear previous search result, button handler
    public PageReference ClearResult()
    {
        //searchService.service_type__c='';
        //searchService.Locality__c=null;
        //strSearchKeyword='';
        //lstToShowSearchedSessions = new List<SearchedSessionClass>();
        
        return null;
    }
 public PageReference doSearch()
    {
    Date searchDay;
    Date searchDay_plus_1;
    LIST<LIST<SObject>> lstSearchResult = new LIST<LIST<SObject>>();
    String searchLocation = (selectLocation==null)? '%' : selectLocation;
    String searchCollection = (selectCollection==null)? '%' : selectCollection;
    System.debug('###########selectDate=' + selectDate);
    If (selectDate!=null) 
    {
        searchDay =Date.parse(selectDate);
        searchDay_plus_1 =searchDay.addDays(1);
    
    }
   
    System.debug('##########searchLocation ' + searchLocation );
    if (searchLocation!='%') 
    {
        if (selectDate!=null)
        {
        lstSearchResult.add([SELECT id, name, Collection_Location__c,Collection_Location__r.name,  Start_Date_Time__c, Duration_in_minutes__c, End_Date_Time__c, Count_of_Collectors__c , Collection_Location__r.Collection__c
        FROM Collection_Time_Slot__c 
        WHERE Session_Available__c=true AND Collection_Location__r.Status__c='Open' 
        AND Collection_Location__c = :searchLocation 
        AND Collection_Location__r.Collection__c=:searchCollection 
        AND Start_Date_Time__c >= :searchDay 
        AND Start_Date_Time__c < :searchDay_plus_1
        ORDER BY Collection_Location__r.name, Start_Date_Time__c]);
       
        }
        else
        {
        lstSearchResult.add([SELECT id, name, Collection_Location__c,Collection_Location__r.name,  Start_Date_Time__c, Duration_in_minutes__c, End_Date_Time__c, Count_of_Collectors__c, Collection_Location__r.Collection__c
        FROM Collection_Time_Slot__c 
        WHERE Session_Available__c=true AND Collection_Location__r.Status__c='Open' 
        AND Collection_Location__c = :searchLocation  
        AND Collection_Location__r.Collection__c=:searchCollection 
        ORDER BY Collection_Location__r.name, Start_Date_Time__c]);
        }
    }
    else
    {
        if (searchCollection!='%')
        {
        
        //no collection or location specified
            lstSearchResult.add([SELECT id, name, Collection_Location__c,Collection_Location__r.name,  Start_Date_Time__c, Duration_in_minutes__c, End_Date_Time__c, Count_of_Collectors__c, Collection_Location__r.Collection__c 
            FROM Collection_Time_Slot__c 
            WHERE Session_Available__c=true AND Collection_Location__r.Status__c='Open' 
            AND Start_Date_Time__c >= :searchDay 
            AND Start_Date_Time__c < :searchDay_plus_1
            
            ORDER BY Collection_Location__r.name, Start_Date_Time__c]);
        }
        else 
        {
        //no location but have a collection
        lstSearchResult.add([SELECT id, name, Collection_Location__c,Collection_Location__r.name,  Start_Date_Time__c, Duration_in_minutes__c, End_Date_Time__c, Count_of_Collectors__c , Collection_Location__r.Collection__c
            FROM Collection_Time_Slot__c 
            WHERE Session_Available__c=true AND Collection_Location__r.Status__c='Open' 
            AND Collection_Location__r.Collection__c=:searchCollection 
            AND Start_Date_Time__c >= :searchDay 
            AND Start_Date_Time__c < :searchDay_plus_1
            
            ORDER BY Collection_Location__r.name, Start_Date_Time__c]);

        
        }
    }
            
    system.debug('##########lstSearchResult.size=' + lstSearchResult.size());
    Integer rowNum=1;
    lstSearchedSessions = new List<SearchedSessionClass>();
    lstToShowSearchedSessions= new List<SearchedSessionClass>();
    for(List<SObject> rec : lstSearchResult)
        {
            for(SObject rec2: rec)
            {
                
                SearchedSessionClass tmpCls = new SearchedSessionClass();
                tmpCls.recCTS = new Collection_Time_Slot__c ();
                tmpCls.recCTS=(Collection_Time_Slot__c)rec2;
                tmpCls.isSelected=false;
                //tmpCls.Collection_Location  = rec2.Collection_Location__r.Name;
                //tmpCls.recSU.Service_Field__c=rec2.id;
                //tmpCls.recServ=((Services__c)rec2);
                //ignore record if already added
                if (!MapAddedSessions.containsKey(tmpCls.recCTS.id))
                {
                    lstSearchedSessions.add(tmpCls);
                
                    //No. of rows to show from List.
                    if(rowNum++<=PageSize){
                        lstToShowSearchedSessions.add(tmpCls);}
                }
                else
                {system.debug('###########added already' + tmpCls.recCTS.id);}
             }
        }
    //Re-arrange record pointers.
        hasNext = lstSearchedSessions.size()>PageSize;
        hasPrevious = false;
        nextStartRowNum=PageSize+1;
        prevStartRowNum =1;
        if(lstSearchedSessions.size()==0 ){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.WARNING,'No records were found based on your criteria.' );
                ApexPages.addMessage(message);
                }
        else {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, lstSearchedSessions.size() + ' Records found based on your criteria.');
                ApexPages.addMessage(message);
                }
    return null;
    }
    //No. of Records to show/Page combo change handler
    public PageReference PageReSized()
    {
        Integer rowNum=1;
        lstToShowSearchedSessions = new List<SearchedSessionClass>();
        
        //Populate subset of records to show. Always show first set of PageSize records.
        for(SearchedSessionClass rec : lstSearchedSessions)
        {
            if(rowNum++<=PageSize)
                lstToShowSearchedSessions.add(rec);
        }
        
        //Re-arranging row pointers.
        hasNext = lstSearchedSessions.size()>PageSize;
        hasPrevious = false;
        nextStartRowNum=PageSize+1;
        prevStartRowNum =1;
        return null;
    }

    //Previous link button handler
    public PageReference previous()
    {
        Integer rowNum=1;
        lstToShowSearchedSessions =  new List<SearchedSessionClass>();
        //Populate subset of records to show.
        for(SearchedSessionClass rec : lstSearchedSessions)
        {
        system.debug('###############'+rowNum+'/////'+nextStartRowNum+'/////'+(nextStartRowNum-PageSize));
            if(rowNum>=prevStartRowNum  && rowNum<(prevStartRowNum+PageSize))
                lstToShowSearchedSessions.add(rec);

          rowNum++;      
        }   
        
        //Re-arranging row pointers.
        nextStartRowNum=prevStartRowNum+PageSize;
        prevStartRowNum -= PageSize;
        hasPrevious =   (prevStartRowNum >0); 
        hasNext = (lstSearchedSessions.size()>=(nextStartRowNum));
        return null;
    }
    
    //Next link button handler
    public PageReference next()
    {
        Integer rowNum=1;
        lstToShowSearchedSessions =  new List<SearchedSessionClass>();
        //Populate subset of records to show.
        for(SearchedSessionClass rec : lstSearchedSessions)
        {
        //system.debug('###############'+rowNum+'/////'+nextStartRowNum+'/////'+rowNum+'/////'+(nextStartRowNum+PageSize));
            if(rowNum>=nextStartRowNum && rowNum<(nextStartRowNum+PageSize))
                lstToShowSearchedSessions.add(rec);

          rowNum++;      
        }   
        
        //Re-arranging row pointers.
        prevStartRowNum =nextStartRowNum-PageSize;
        nextStartRowNum+=PageSize;
        hasNext =   (lstSearchedSessions.size()>=nextStartRowNum); 
        hasPrevious = (prevStartRowNum >=1);
        return null;
    }  
    
    //InsertSelected button handler.
    public PageReference InsertSelected()
    { 
        List<SearchedSessionClass> lstTmp= new List<SearchedSessionClass>();
        //Get all SessionUsage RecordTypes.
        //Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Session_Usage__c.getRecordTypeInfosByName(); 
                  
        
        //Add the selected Sessions to AddList.
        for(SearchedSessionClass rec: lstSearchedSessions)
        {
            if(rec.isSelected)
            {
                //rec.recCTS = rec.recServ;

                rec.isNew=true;

                lstAddedSessions.add(rec);
                MapAddedSessions.put(rec.recCTS.id, rec.recCTS.id);
            }
            else
            {
                lstTmp.add(rec);
            }
        }
        
        system.debug('##########lstTmp#########'+lstTmp);

        //Refresh searched List, by removing selected Sessions.
        lstSearchedSessions=lstTmp;

        bolUnSelect=false;
        
        Integer rowNum=1;
        lstToShowSearchedSessions = new List<SearchedSessionClass>();

        //Refresh list, no. of rows to show
        for(SearchedSessionClass rec : lstSearchedSessions)
        {
                if(rowNum++<=PageSize)
                    lstToShowSearchedSessions.add(rec);
        }
        
        //Re-arrange record pointers.
        hasNext = lstSearchedSessions.size()>PageSize;
        hasPrevious = false;
        nextStartRowNum=PageSize+1;
        prevStartRowNum =1;
        
        system.debug('##########before return############');
        return null;

    }  
//Save and Return Button handler.
public PageReference saveNReturn() {
      ///Saving or Creation logic
      Id contactId = ApexPages.currentPage().getParameters().get('id');
      List<Collector_Session__c> lstCollectorSessionToCreate = new List<Collector_Session__c>();
    
    
      //Iterate through all Added Sessions List to set default values;    
      for(SearchedSessionClass rec:lstAddedSessions)
      {
          try
          {
          //Set default values only if record is New/To be created and not for Update.
          if(rec.isNew ==true)
          {
            Collector_Session__c CSinstance = new Collector_Session__c();
            CSinstance.Collector__c = con.id;
            CSinstance.CollectionSession__c = rec.recCTS.id;
            lstCollectorSessionToCreate.add(CSinstance);
          }
          
          }catch(Exception ex){
          //throw ex;}
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while creating Sessions.');
                    ApexPages.addMessage(message);
                    return null;      }
      }
      
      system.debug('###########lstAddedSessions#############'+lstAddedSessions);
      if(lstCollectorSessionToCreate.size()>0)
      {
          // Create a savepoint because the data should not be committed to the database
          Savepoint sp = Database.setSavepoint();
    
          try
          {
              //Insert or Update SessionUsage records.
              upsert lstCollectorSessionToCreate;
          }catch(Exception ex){Database.rollback(sp);
                               ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while updating Sessions.');
                               ApexPages.addMessage(message);
                               return null;}
      }
      //Navigate back to Contact Detail Page.
      return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
     }    
}