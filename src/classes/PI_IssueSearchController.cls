public with sharing class PI_IssueSearchController {


   /***********************************************************************************************************
    *
    *   @author      :    gary.grant@conseq.co.uk
    *   @date        :    April 2015
    *
    *   @description :    Search for Issues in the Projects/ Issues application 
    *   
    ************************************************************************************************************/
 
  // The soql without the order and limit
  transient private String soql {get;set;}
  
  public String project {get;set;}
  public String subProject {get;set;}
  public String owner {get;set;}

  public List<String> status_selection {get;set;}
  public List<String> priority_selection {get;set;}
  public List<String> category_selection {get;set;}

  public List<SFDC_Issue__c> searchResults {get;set;}
  
  public Integer resultCount = 0;

  public PI_IssueSearchController (){
      init();      
  }
  
  
  /* The properties below are the filters available */
  
  /* STATUS */  
  public List<SelectOption> getStatusOptions() {
    Schema.DescribeFieldResult field = SFDC_Issue__c.SFDC_Issue_Status__c.getDescribe();
    return CustomUtils.getOptions(field);          
  }
  
  /* CATEGORY */
  public List<SelectOption> getCategoryOptions() {
    Schema.DescribeFieldResult field = SFDC_Issue__c.Category__c.getDescribe();
    return CustomUtils.getOptions(field);
  }
  
  /* PRIORITY */
  public List<SelectOption> getPriorityOptions() {
    Schema.DescribeFieldResult field = SFDC_Issue__c.SFDC_Issue_Priority__c.getDescribe();
    return CustomUtils.getOptions(field);
  }
  
  /* Project */
  public List<SelectOption> getProjectOptions() {
        
    String sPrefix = SFDC_Issue__c.sObjectType.getDescribe().getKeyPrefix();    
    AggregateResult[] projects = [select SFDC_Project__r.Name, MAX(SFDC_Project__r.id) Id from SFDC_Issue__c group by SFDC_Project__r.Name];
    
    List<SelectOption> options = new List<SelectOption>();             
    options.add(new SelectOption('','')); 
    for (AggregateResult aggr : projects) {

      if ( (String)aggr.get('Id') != null ) {

          String l = (String)aggr.get('Name');
          String v = (String)aggr.get('Id');
          options.add(new SelectOption(v,l));       
       }

       
    }
    
    return options;
    
  }

  /* Sub Project */
  public List<SelectOption> getSubProjectOptions() {
      
    String sPrefix = SFDC_Sub_Project__c.sObjectType.getDescribe().getKeyPrefix();    
    AggregateResult[] items = [select SFDC_Sub_Project__r.Name, MAX(SFDC_Sub_Project__r.id) Id from SFDC_Issue__c where SFDC_Sub_Project__r.Project__c =:project group by SFDC_Sub_Project__r.Name];
    
    List<SelectOption> options = new List<SelectOption>();         
    options.add(new SelectOption('','')); 
    for (AggregateResult aggr : items) {

      if ( (String)aggr.get('Id') != null ) {

          String l = (String)aggr.get('Name');
          String v = (String)aggr.get('Id');
          options.add(new SelectOption(v,l));       
       }

       
    }
    
    return options;

  }
   
  /* Owner */
  public List<SelectOption> getOwnerOptions() {
        
    AggregateResult[] projects = [select User__r.Name, MAX(User__r.id) Id from SFDC_Issue__c group by User__r.Name];
    
    List<SelectOption> options = new List<SelectOption>();             
    options.add(new SelectOption('','')); 
    for (AggregateResult aggr : projects) {

        if ( (String)aggr.get('Id') != null ) {
             
             String l = (String)aggr.get('Name');
  		       String v = (String)aggr.get('Id');
             options.add(new SelectOption(v,l));
        }

    }
    
    return options;
    
  }

  /** The current sort direction. Defaults to desc as most people want to see the new ones first */
  public String sortDir {
    get  { 
        if (sortDir == null) {  
            sortDir = 'asc'; 
        } 
        return sortDir;  
        }
    set;
  }
 
  /** The current field to sort by. Defaults to name */
  public String sortField {
    get  { if (sortField == null) {sortField = 'Name'; } return sortField;  }
    set;
  }
 
  /** Format the soql for display on the visualforce page */
  public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir + ' limit 200'; }
    set;
  }
 
  /** Init the controller and display some sample data when the page loads */
  public void init() {
                            
    searchResults=new List<SFDC_Issue__c>();
        
    project = '';
    owner='';

    status_selection=new List<String>();
    category_selection = new List<String>();
    priority_selection = new List<String>();
        
    runQuery();
  }
 
  /** Toggles the sorting of query from asc<-->desc */
  public void toggleSort() {

    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';        
    runQuery();     // Run the query again

  }
 
  /** Run the query */
  public void runQuery() {

    resultCount=0;
    generateQueryString();
    
    searchResults=new List<SFDC_Issue__c>();
    
    try {
        
        searchResults = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 200');   
        resultCount=searchResults.size();
        
    } catch (Exception e) {

      String sMsg = e.getMessage();  
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, sMsg ));
      resultCount=0;
    
    }
    
  }
  
  /** Run the search with parameters passed as Querystring parameters */
  public PageReference runSearch() {
    
    //Map of PageParameters 
    Map<string,string> pageParams=ApexPages.currentPage().getParameters(); 
    
    // Run the query again
    runQuery();
 
    return null;
  }
  
  /** Generate the soql query string */ 
  private void generateQueryString()
  {
  
   soql = 'select Id, ' +
                'Name, ' +   
                'SFDC_Issue_Name__c, ' +
                'SFDC_Issue_Description__c,' +
                'Issue_Detail__c,' + 
                'User__c, ' +
                'Category__c, ' +
                'SFDC_Issue_Priority__c, ' +
                'SFDC_Issue_Status__c, ' +
                'SFDC_Project__c, ' +
                'SFDC_Sub_Project__c ' +
                
                'from SFDC_Issue__c where Name !=\'NulLValue\' ' ;

    
    if (!status_selection.isEmpty())  {       

        soql += ' AND SFDC_Issue_Status__c in (';    
        soql += CustomUtils.listAsString(status_selection);
        soql += ')';
    
    }  
    
    if (!priority_selection.isEmpty())  {       

        soql += ' AND SFDC_Issue_Priority__c in (';    
        soql += CustomUtils.listAsString(priority_selection);
        soql += ')';
    
    }  

    if (!category_selection.isEmpty())  {       

        soql += ' AND Category__c in (';    
        soql += CustomUtils.listAsString(category_selection);
        soql += ')';
    
    }  


    if (project!=null && project !='')  {       

        soql += ' AND SFDC_Project__c =:project';
    
    }  

    if (subProject!=null && subProject !='')  {       

        soql += ' AND SFDC_Sub_Project__c =:subProject';
    
    }

    if (owner!=null && owner != '')  {       

        soql += ' AND User__c =:owner';
    
    }  

    system.debug('Participant Search Query : ' + soql); 

  }
  
  public void clicked()
  {
      // do nothing
  }
 



}