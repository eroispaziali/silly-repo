public without sharing class BdrServicesSearchController {
 
   /*****************************************************************************
   * @author       gary.grant@conseq.co.uk  
   * @date         March 2013
   *  
   * @description  This controls the creation and editing of a service via the BDR.  
   *              
   *               **** CAUTION ****
   *               The class is set to WITHOUT SHARING
   *               This is necessary to enable users without access
   *               to an existing Services__c record to create a Master-Detail to that record
   *              
   *               Users will not necessarily have access to open service records
   *         
   *               Do not put logic in this class that updates service records beyond that which is absolutely necessary    
   *              
   *******************************************************************************/   

  public static final String INTERNAL = 'Internal';
   
  // The soql without the order and limit
  private String soql {get;set;}
  private DCSearchWrapper serviceWrapperList;
  
  public String bdrid{get;set;}
  
  // 4 fields used for applying filters to the results    
  public String name {get;set;}
  public String locality {get;set;}
  public String service_type {get;set;}

  public List<String> service_status_selection {get;set;}                       
  public String service_status {get;set;}

  public Integer resultsCount  {get;set;}
  public Integer filterCount {get;set;}          /* How many filter fields have been used */
  public boolean filtersSelected  {get;set;}
  
  public String filterMessage {get;set;}
  
  public BDR__c bdr {
         get {
             List<BDR__c> lis = [select Id, Name, Bdr_Name__c, Status__c from BDR__c where Id =:bdrId limit 1];
             if(!lis.isEmpty()) return lis[0];
             return new BDR__c();
             }
         set;
  }    
             
  private String sRecordTypeName; 
 //public ConfigText__c helpText {get;set;}

 
  // Constructor.  Init the controller 
  public BdrServicesSearchController() {

            this.bdrid=ApexPages.currentPage().getParameters().get('bdrid');

            service_status_selection = new List<String>();
            
            service_status_selection.add('Draft');
            service_status_selection.add('Open');
            service_status_selection.add('Accepted');
            service_status_selection.add('Pending');
            
            generateQueryString();                  
            runQuery();

            // This is just called the first time the page loads with no filters
            // Otherwise the search is called using runApexSearch
        
  }
  
  
    /** The list of Services returned by the query */
  public List<DCSearchWrapper> serviceList
  {
    get {
           if (serviceList == null) serviceList = new List<DCSearchWrapper>();
            return serviceList;
        }
        set;
  }  
     
  // The current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
  }
 
  // The current field to sort by. defaults to name
  public String sortField {
    get  { if (sortField == null ) {sortField = 'Name'; } return sortField;  }
    set;
  }
 
  // Toggles the sorting of query from asc<-->desc
  public void toggleSort() {
   
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
   
    runQuery();
  }
 
    /** Generate the soql query string using the base query and adding clauses for the  user selected filters */ 
  private void generateQueryString()
  {
  
    sRecordTypeName = INTERNAL;
        
    soql = 'select Id, '+
               'Name, '+
               'Locality__r.name,'+
               'Operated_By__c, '+
               'Service_Status__c,'+
               'Service_Type__c, '+
               'Service_Financeactivitycode__c, '+
               'Service_OpenDate__c,'+
               'Default_Location__r.Name '+
               'from Services__c where RecordType.DeveloperName =:'+INTERNAL;
               
    if (!String.isEmpty(name))  soql += ' AND Name LIKE \'%'+escapeSQ(name)+'%\'';

    if (!String.isEmpty(locality)) soql += ' and Locality__c = \''+locality+'\'';
      
    if (!String.isEmpty(service_type))  soql += ' AND Service_Type__c = \''+  escapeSQ(service_type) + '\'';
    
    if (!service_status_selection.isEmpty())  {       

        //service_status_selection = service_status.split(',');    
        soql += ' AND Service_Status__c in (';    
        Integer c = 0;
        for (String el : service_status_selection) {
          if (c>0) {soql +=',';}
          soql += wrapApostrophe(el);
          c++;  
        }
        soql+=')';
    }    

    system.debug('BDR Services Search SOQL QUERY : ' + soql);
  
  }
  
   private String  wrapApostrophe(String text) {
        String apo = '\'';
        return (  apo + text + apo );
    }
  
 
  // Runs the search with parameters passed via Javascript
  public PageReference runApexSearch() {
            
    //Map of PageParameters 
    Map<string,string> pageParams=ApexPages.currentPage().getParameters();
     
    name = pageParams.get('name');    
    locality = pageParams.get('locality');
    service_type = pageParams.get('service_type').unescapeHtml4();

    // The checkbox values are in service_status_selection already....(that needs some investigation...)
    // service_status = pageParams.get('service_status');
    system.debug('BDR Search Services : service_status_selection ' + service_status_selection);
   
   generateQueryString();
   runQuery();
    
   if (filterCount>0) {
       filtersSelected = true;        
       filterMessage = resultsCount +' Services match your selected filters';
        
     } else {
        filterMessage = '';
   }
 
    return null;
  }

  
    // Runs the query
  private void runQuery() {
 
    // Do the search.

    try {
      List<Services__c> results = Database.query(soql + ' order by ' + sortField + ' ' + sortDir  + ' limit 800' );
      
      serviceList = new List<DCSearchWrapper>();
      
      for (Services__c service : results) {
           serviceList.add(new DCSearchWrapper(service));          
       }  
          
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));
    }
    finally { resultsCount = serviceList.size();}
 
  }
  
    private String escapeSQ(String field) {
        return String.escapeSingleQuotes(field);
  }
 
  /* Use apex describe to build the picklist values
  public List<String> service_types {
    get {
      if (service_types == null) {
 
        service_types = new List<String>();
        Schema.DescribeFieldResult field = Services__c.service_type__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues())
          service_types.add(f.getLabel());
 
      }
      return service_types;          
    }
    set;
  }*/
  
 // Get the list of Internal Organisations to populate the Locality select list
  public  List<SelectOption>  getLocalities() { 
  
      List<SelectOption> optionList = new List<SelectOption>();             
      String word = 'Locality';

      optionList.add(new SelectOption('', '')); 
    
      for (Account A : [Select Id, Name From Account where RecordType.DeveloperName = 'InternalOrganisation' And Name like :'%'+word order by Name asc limit 200]) {
           String showName = A.Name.replaceAll(word,'');
           optionList.add(new SelectOption(A.Id, showName));  
      }
      return optionList;  
  }  
  
  
  /*
   *    Get the list of DC Service Types. 
   *    Note that the services types contain characters like & and \ that need to be escaped
   */
  public List<SelectOption> getService_Types_Options() { 
      
          List<SelectOption> options = new List<SelectOption>();    
          
          sRecordTypeName = 'Internal'; 
              
          options.add(new SelectOption('','')); 
          AggregateResult[] results = [ Select  service_type__c, Count(Name) FROM  Services__c   where RecordType.DeveloperName =:sRecordTypeName And  Service_type__c !=null  group by service_type__c ];
            
          for (AggregateResult ar : results)  {
                 String val =   String.valueof( ar.get('service_type__c')) ;
                 String label = val + ' ('+String.valueof(ar.get('expr0')) + ')';
                 options.add(new SelectOption(val.escapeHTML4(), val));
          }
          return selectOptionSortByLabel(options); 
  }
  


/*
  public List<SelectOption> getService_status_options() {
    
          List<SelectOption> options = new List<SelectOption>();        
              
          AggregateResult[] results =
           [ Select  service_status__c, Count(Name) FROM  Services__c   where Service_status__c !=null And (RecordType.Name = 'Internal Service') group by service_status__c ];
            
            for (AggregateResult ar : results)  {
                 String val =   '' +ar.get('Service_Status__c');
                 String label = val + ' ('+ar.get('expr0') + ')';
        
                 options.add(new SelectOption(val, val));
        }
          return options;
   } */
   

 public List<SelectOption> getLocality_Options() {

    List<SelectOption> options = new List<SelectOption>();          
          
    options.add(new SelectOption('','')); 

    List<AggregateResult>  counts = [select count(Id) Total, Locality__r.Name name, Locality__r.Id id
    from Services__c where (RecordType.Name = 'Internal Service') And  Locality__c !=null  
    group by Locality__r.Id,  Locality__r.Name order by Locality__r.Name];
    
     for (AggregateResult o : counts) {
           String sLabel =  o.get('name') + ' (' + o.get('total') + ')';
           options.add(new SelectOption(''+o.get('id'), sLabel));
      }
        
      return options;
  } 
    
  public List<SelectOption> getService_status_options() {
    
          List<SelectOption> options = new List<SelectOption>();        

        /*  Schema.DescribeFieldResult field = Services__c.Service_Status__c.getDescribe();
          
          String label, val = '';
         
          for (Schema.PicklistEntry f : field.getPicklistValues()) {
                        val = f.getLabel();
                        
                   
                        options.add(new SelectOption( f.getLabel(), l f.getLabel()));
                }
                
          return selectOptionSortByLabel(options)   ;  */
          
          
         options.add(new SelectOption('Draft', 'Draft')); 
         options.add(new SelectOption('Accepted', 'Accepted')); 
         options.add(new SelectOption('Pending', 'Pending')); 
         options.add(new SelectOption('Open', 'Open')); 
         options.add(new SelectOption('Declined', 'Declined')); 
         options.add(new SelectOption('Suspended', 'Suspended')); 
         options.add(new SelectOption('Replaced', 'Replaced')); 
         options.add(new SelectOption('Closed', 'Closed')); 
         return (options)   ;
             
   }


  public pagereference cancel() {
       return new PageReference('/apex/BDR_Edit_Tabbed?id='+ bdrid + '&tab=tabServices');
  }
  
  /**
   *    @description Take the selected service ids from the list view and add BDR_Service_Link__c to the active BDR 
  */
  public pagereference add() {
                                  
    /* May 2014. This is now handled with a batch process that creates fund requirements and allocation records for the relevant Financial Years */  

    List<String> lisSvcIds = new List<String>();
    for (DCSearchWrapper svcW : serviceList) {
                  if (svcW.isSelected) { 
                             lisSvcIds.add(svcW.svc.id);
                  }
    }
    BdrUtils.addServices(bdrid, lisSvcIds);
    
    PageReference pr = new PageReference('/apex/BDR_Edit_Tabbed?id=' + bdrid +'&tab=tabServices');
    pr.setRedirect(true);
    return pr;
    
  }
  
  public class DCSearchWrapper
  {     
    public Services__c svc {get; set;}
    public boolean isSelected {get;set;}

    public DCSearchWrapper(Services__c svc)
    {
        this.svc=svc;
        isSelected=false;
    }
  }  
  
   /*
        @Param:List of selectOption to be sort.
        @Return: Sorted list of selectOptions by Label
    */
    public static List<selectOption> selectOptionSortByLabel(List<selectOption>
                                                            selectOptionsToSort) {
        if (selectOptionsToSort == null || selectOptionsToSort.size() <= 1) {
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;
        
        //Save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];
        selectOptionsToSort.remove(pivot);
        for(selectOption SO : selectOptionsToSort){
            if (SO.getLabel() <= pivotValue.getLabel()){
                lessSelectOption.add(SO);
            }else if (SO.getLabel() > pivotValue.getLabel()){
                greaterSelectOption.add(SO);   
            }
        }
        list<selectOption> sortedSelectOptions = new list<selectOption>(); 
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return SortedSelectOptions;
    }
 
  
}