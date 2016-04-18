public with sharing class BDRServicesFundCoverageController {


   /***********************************************************************************************************
    *
    * gary.grant@conseq.co.uk
    * Jan 2013
    *  A search controller used to find Services where Costs have been defined via a BDR
    *  
    *  The 'Funding_Requirement__c' object has the label 'BDR Service Cost'
    *
    ************************************************************************************************************/
 
  private String soql {get;set;}
  
  // Fields used for applying filters to the results    
  public String name {get;set;}
  public String locality {get;set;}
  public String service_type {get;set;}
  public String fiscal_year {get;set;}
  public String funding_type {get;set;}
  public String service_status {get;set;}
  

   // The  soql without the order and limit
  public static final String QUERY =   
  
  			 ' select Id, Name, Fiscal_Year__c, Total_Cover_Potential_Percent__c, '+
  			 
			 ' Service__r.Locality__r.Name, '+
			 ' Service__r.Name, '+
		
			 ' Service__r.Operated_by__c, '+
			 ' Service__r.service_type__c, '+
			 ' Service__r.service_status__c' +
			 
			 ' from Funding_Requirement__c where Name != null';

  // The collection of Services to display  
  public List<BdrFundReqWrapper> Services 
  {
    get {
            if (Services == null) Services = new List<BdrFundReqWrapper>();
            return Services;
        }
        set;
  }      

     
  // The current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'desc'; } return sortDir;  }
    set;
  }
 
  // The field to sort by. Defaults to Service Name
  public String sortField {
    get  { if (sortField == null) {sortField = 'service__r.Name,Fiscal_Year__c'; } return sortField;  }
    set;
  }
 

  
  // Params for manipulating the dialog
  public String parent_domain{get;set;}
  public String pid{get;set;}
    
 
  // Constructor: Init the controller and display some sample data when the page loads
  public BDRServicesFundCoverageController() {

    soql = QUERY;
       runQuery();
  //  services=new List<BdrFundReqWrapper>();
    
     /* The search is now called from the document.ready so that when the user returns to the page using
     * the browser back button the same filters still apply so the user can return to the filterdd list
     */
  }
 
  // toggles the sorting of query from asc<-->desc
  public void toggleSort() {
    // Toggle the direction
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    
    // Run the query again
    runQuery();
  }
 
  // Runs the query to get the Service Cost objects  (called Funding Requirements)
  private void runQuery() {
 
    try {
      List<Funding_Requirement__c> results = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 200');
      
      services=new List<BdrFundReqWrapper>();  
      
      for (Funding_Requirement__c freq : results) {
        		services.add(new BdrFundReqWrapper(freq));
      }
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));
    }
    finally { }
 
  }
 
  // Runs the search with parameters passed via Javascript
  public PageReference runApexSearch() {
  	
  	System.debug('*****************Now in BDRServiceFundCoverageController - runSearch method');
  	
  	// Map of PageParameters 
    Map<string,string> pageParams=ApexPages.currentPage().getParameters();
 
    String name = pageParams.get('name');
    String locality =pageParams.get('locality');
    String service_type = pageParams.get('service_type');
    String fiscal_year = pageParams.get('fiscal_year');    
    String funding_type = pageParams.get('funding_type');
    String service_status = pageParams.get('service_status');
  
     
    soql = QUERY;
    
    if (!locality.equals(''))
      soql += ' and Service__r.Locality__r.Id = \''+locality+'\'';
      
      
    if (!service_type.equals(''))
      soql += ' and Service__r.service_type__c = \''+escapeSQ(service_type)+'\'';  
      
            
    if (!service_status.equals(''))
      soql += ' and Service__r.service_status__c = \''+escapeSQ(service_status)+'\'';  
      
    if (!fiscal_year.equals(''))
      soql += ' and Fiscal_year__c = \''+escapeSQ(fiscal_year)+'\'';    
      
    if (funding_type.equals('Funded'))
      soql += ' and total_cover_potential_percent__c >= 100';    
      
    if (funding_type.equals('UnFunded'))
      soql += ' and total_cover_potential_percent__c < 100';    
    
    System.debug('*********************************'+soql)  ;
     
    // Run the query again
    runQuery();
 
    return null;
  }
  
    private String escapeSQ(String field) {
  			return String.escapeSingleQuotes(field);
  }
 
  // Use Apex Describe to build the picklist values for Service Types
  public List<SelectOption> getService_Types() {
   
       List<SelectOption> optionList = new List<SelectOption>();  
       optionList.add(new SelectOption('', ''));	 
 
        Schema.DescribeFieldResult field = Services__c.service_type__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues()) {
            optionList.add(new SelectOption(f.getLabel(), f.getLabel()));  
      }
      return optionList;          
  }
  
    public List<SelectOption> getService_Status_Options() {
   
       List<SelectOption> optionList = new List<SelectOption>();  
       optionList.add(new SelectOption('', ''));	 
 
        Schema.DescribeFieldResult field = Services__c.service_status__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues()) {
            optionList.add(new SelectOption(f.getLabel(), f.getLabel()));  
      }
      return optionList;          
  }
  
    // Get the list of Internal Organisations to populate select
      public List<SelectOption>  getLocalities() { 
  	  
		  List<SelectOption> optionList = new List<SelectOption>();   		    
          String word = 'Locality';
	
    	  optionList.add(new SelectOption('', ''));	
    	
          for (Account A : [Select Id, Name From Account where RecordType.DeveloperName = 'InternalOrganisation' And Name like :'%'+word order by Name asc limit 200]) {
               String showName = A.Name.replaceAll(word,'');
               optionList.add(new SelectOption(A.Id, showName));  
          }
          return optionList;  
      }

 
  public List<SelectOption> getFunding_types() {
  	
  	 List<SelectOption> optionList = new List<SelectOption>();   
     optionList.add(new SelectOption('',''));
     optionList.add(new SelectOption('Funded','Funded'));
     optionList.add(new SelectOption('UnFunded','UnFunded'));
      return optionList;          
  }


  // Use apex describe to build the picklist values
      public List<SelectOption> getYearsOptions() { 
  	  
		  List<SelectOption> optionList = new List<SelectOption>();   
          optionList.add(new SelectOption('',''));
  	      String year = '';
  	 	  for (SObject o : [ Select Fiscal_Year__c from Funding_Requirement__c group by Fiscal_Year__c]) {
                year = String.valueOf(o.get('Fiscal_Year__c'));
      			optionList.add(new SelectOption(year, year));
     		}
	  	
  		return optionList;
  }
  


}