public with sharing class BDRSearchController {
 
   /***********************************************************************************************************
    *
    *   @author      :    valerie.dunphy@conseq.co.uk
    *   @date        :     June 2014
    *
    *   @description :  Find BDRs using a set of filter fields for BDR_Search.page
    *   
    ************************************************************************************************************/
 
  // The soql without the order and limit
  transient private String soql {get;set;}
  
  // List of BDR Ids for BDRs pending approval by a selected user
   private List<String> lisObjectIds {get;set;}
  

  // Fields used for applying filters to the results    
  public String ref {get;set;}
  public String bdr_name {get;set;}

  public String locality {get;set;}
  public String income_source {get;set;}
  public String bdm_name {get;set;}
  public String owner {get;set;}

  public String status {get;set;}
  public String approver_name {get;set;}
  public String area {get;set;}

  public Integer resultsCount  {get;set;}
  public Integer filterCount {get;set;}          /* How many filter fields have been used */
  public boolean filtersSelected  {get;set;}
  
  public String filterMessage {get;set;}
  
  /*
   *  Get the number of BDRs Pending Approval by the current user if any
   */
  public Integer getPendingApprovalCount() {     
            return CustomUtils.getObjectIdsPendingApprovalbyUserId(UserInfo.getUserId(), 'BDR__c').size();      
  }
  

  
  /** Generate the URL for creating a new BDR__c object */ 
  public String getCreateUrl() {   
              Schema.DescribeSObjectResult o = BDR__c.SObjectType.getDescribe();
              PageReference pr = new PageReference('/' + o.getKeyPrefix() + '/e');         
              return pr.getUrl();
   }
  
  /** The list of BDR Search Wrapper objects returned by the query */
  public List<BdrSearchWrapper> lisBDR
  {
    get {
            if (lisBDR == null) lisBDR = new List<BDRSearchWrapper>();
            return lisBDR;
        }
        set;
  }      
  
    
  /** The current sort direction. Defaults to desc as most people want to see the new ones first */
  public String sortDir {
    get  { 
        if (sortDir == null) {  
            sortDir = 'desc'; 
        } 
        return sortDir;  
        }
    set;
  }
 
  /** The current field to sort by. Defaults to Created Date */
  public String sortField {
    get  { if (sortField == null) {sortField = 'CreatedDate'; } return sortField;  }
    set;
  }
 

 
  /** Constructor.  */
  public BDRSearchController() {
    
    // This is just called the first time the page loads with no filters
    // Otherwise the search is called using runApexSearch
       	runQuery();
  }
  
    
  private void sendDebugMail(String subject, String body) {
  	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

	// Strings to hold the email addresses to which you are sending the email.
	String[] toAddresses = new String[] {'valerie.dunphy@conseq.net'}; 
	mail.setToAddresses(toAddresses);
	mail.setSenderDisplayName('Salesforce Testing');
	mail.setSubject('Searching for '+subject);
	
	mail.setUseSignature(false);
	mail.setPlainTextBody(body);
	
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
 
  /** Toggles the sorting of query from asc<-->desc */
  public void toggleSort() {

    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';        
    runQuery();     // Run the query again

  }

  
  private String escapeSQ(String field) {
  	return String.escapeSingleQuotes(field);
  }
 
  /** Run the query */
  private void runQuery() {

    generateQueryString();
    lisBDR = new List<BDRSearchWrapper>(); 
    
    try {
        List<BDR__c> lisResults = Database.query(soql);   
        for (BDR__c bdr : lisResults) {
        	lisBdr.add(new BdrSearchWrapper(bdr));        	
        }  
        
    } catch (Exception e) {

      String sMsg = e.getMessage();  
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, sMsg ));
    }
    finally { resultsCount = lisBdr.size();
    	 }
 
  }
  
    
    /** Generate the soql query string using the base query and adding clauses for the  user selected filters */ 
  private void generateQueryString()
  {
  
   soql = 'select Id, ' +
                'Name, ' +
                'Bdr_Name__c,' + 
                'Status__c, ' +
                'A2D_Locality__r.Name,' + 
                'Owner.Name, ' +
                'BDM__c, ' +
                'BDM__r.Name,' +
                'Total_Value__c,' +           // Actual_Value__c
                'Actual_Value__c,' +    
                'Intended_Start_Date__c,'+
                'CreatedDate,'+
                'Component_List__c, ' +
                'HR_Implications__c '+
                
                'from BDR__c where Name != null';
                


    if (!String.isEmpty(ref))  soql += ' and Name LIKE \'%'+escapeSQ(ref)+'%\'';

    if (!String.isEmpty(bdr_name))  soql += ' and BDR_name__c LIKE \'%'+escapeSQ(bdr_name)+'%\'';

    if (!String.isEmpty(bdm_name))  soql += ' and BDM__c = \''+escapeSQ(bdm_name)+'\'';
      
    if (!String.isEmpty(owner))  soql += ' and OwnerId = \''+ owner +'\'';

    if (!String.isEmpty(locality)) soql += ' and A2D_Locality__c = \''+locality+'\'';
         
    if (!String.isEmpty(income_source)) soql += ' and Income_Source__c = \''+income_source+'\'';

    if (!String.isEmpty(status)) soql += ' and Status__c = \''+escapeSQ(status)+'\'';  
    
    if (!String.isEmpty(approver_name)) {
        lisObjectIds = CustomUtils.getObjectIdsPendingApprovalbyUserId(approver_name, 'BDR__c');      
        soql += ' and Id in : lisObjectIds';
    } 
    
    soql += ' order by ' + sortField + ' ' + sortDir + ' limit 200';

  }
 

  
   public List<SelectOption> getBDMs() { 
  	  
		  List<SelectOption> options = new List<SelectOption>();
		  
		  String sLabel, sLastName = '';   		    

		  List<User> BDMs =
		  [ Select  Id, FirstName, LastName, (select Name from BDRs__r) FROM User WHERE Id in (select BDM__c FROM BDR__c ) order by LastName];
    
    	  options.add(new SelectOption('',''));	
          for (User U : BDMs) {
               sLastName = U.LastName.replaceAll('\\(BDM\\)', '').trim();
               sLabel = sLastName + ', ' +U.FirstName + '  (' + U.BDRs__r.size() +')';
               options.add(new SelectOption(U.Id, sLabel));
          }
          return options; 
  }
  

     public List<SelectOption>  getStatusOptions() { 
  	  
		  List<SelectOption> options = new List<SelectOption>();   		
		      
		  options.add(new SelectOption('','')); 
		  AggregateResult[] results = [ Select  Status__c, Count(Name) FROM  BDR__c  group by Status__c ];
			
      		for (AggregateResult ar : results)  {
      			 String val =   String.valueof( ar.get('Status__c'));
      			 String label = val + ' ('+String.valueof(ar.get('expr0')) + ')';
      			 options.add(new SelectOption(val, label));
		}
          return options; 
  }
  
  public List<SelectOption>  getLocalities() { 
  	  
		  List<SelectOption> optionList = new List<SelectOption>();   		    

		  List<BDR_Organisation__c> localities =
		  [ Select  Id, Name, (select Name from BDRs__r) FROM BDR_Organisation__c WHERE Id in (select A2D_Locality__c FROM BDR__c ) order by Name];
    
    	  optionList.add(new SelectOption('',''));	
    	  
          for (BDR_Organisation__c O : localities) {
               String sLabel = O.Name + ' (' + O.BDRs__r.size() +')';
               optionList.add(new SelectOption(O.Id, sLabel));
          }
          return optionList; 
  }
  
  
    public List<SelectOption>  getAreas() { 
  	  
		  List<SelectOption> options = new List<SelectOption>();   		  
		  List<BDR__c> lisAreas = [select Area__c FROM BDR__c];
		  
		  Set<String> stAreaNames= new Set<String>();
		  for (BDR__c org : lisAreas) {
		  	stAreaNames.add(org.Area__c);		  	
		  }
		  
		  List<String> lisAreaNames = new List<String>();
		  lisAreaNames.addAll(stAreaNames);
		  
		  List<BDR_Organisation__c> areas =
		  [ Select  Id, Name, (select Name from BDRs__r) FROM BDR_Organisation__c 
		  WHERE Name in :lisAreaNames order by Name];
    
    	  options.add(new SelectOption('',''));	
    	  
          for (BDR_Organisation__c O : areas) {
               String sLabel = O.Name + ' (' + O.Bdrs__r.size() +')';
               options.add(new SelectOption(O.Name, sLabel));
          }
          return options; 

  }
  

  
  
  public Integer getBDRCount() {
  	return [ SELECT COUNT() FROM BDR__c ];
  	
  }
  
  public Integer getSearchResultsCount() {
  	return lisBDR.size();
  }
  
  public List<SelectOption>  getIncomeSources() { 
  	  
		  List<SelectOption> options = new List<SelectOption>();   		    

		  List<Account> income_sources =[ Select  Id, Name, (select Name from Business_Development_Records__r)  FROM Account WHERE Id in (select income_Source__c FROM BDR__c ) order by Name];
    
    	  options.add(new SelectOption('',''));	
    	  
          for (Account A : income_sources) {
          	   String sourceName = A.Name;
          	   
          	   if (sourceName.length()>40) {
          	   	   sourceName = sourceName.subString(0,40);
          	   }
               String sLabel = sourceName + ' (' + A.Business_Development_Records__r.size() +')';
               options.add(new SelectOption(A.Id, sLabel));
          }
          return options; 

  }
  

  
  public List<SelectOption>  getApprovers() { 
  	  
		  return CustomUtils.getPendingApproversForObjectType('BDR__c'); 
  }
  
  
    public List<SelectOption>  getOwners() { 
      
      List<SelectOption> options = new List<SelectOption>();   
        
      List<User> Owners =[ Select  Id, Name, FirstName, LastName FROM User WHERE Id in (select OwnerId FROM BDR__c ) order by LastName];
        List<AggregateResult> BDRs = [select count(BDR__c.Name), BDR__c.OwnerId from BDR__c group by BDR__c.OwnerId];  
    
        Map<String, String> mapBDRs = new Map<String, String>();  
        for (AggregateResult ar : BDRs) {
            mapBDRs.put(String.valueOf(ar.get('OwnerId')), String.valueOf(ar.get('expr0'))); 
        }  
    
        options.add(new SelectOption('',''));  
          for (User U : Owners) {
        
          String sLastName = U.LastName.replaceAll('\\(BDM\\)', '').trim();
          String sLabel = sLastName + ', '+U.FirstName + ' (' + mapBDRs.get(U.Id) + ')';   
            options.add(new SelectOption(U.Id, sLabel));
          }
          return options; 

  }   
 
  /** Run the search with parameters passed as Querystring parameters */
  public PageReference runApexSearch() { 
  	
  	//Map of PageParameters 
    Map<string,string> pageParams=ApexPages.currentPage().getParameters();
    
    ref = pageParams.get('ref');
    bdr_name = pageParams.get('bdr_name');  
    locality = pageParams.get('locality');
    bdm_name = pageParams.get('bdm_name');
    income_source = pageParams.get('income_source');
    owner = pageParams.get('owner');
    approver_name = pageParams.get('approver_name');
    status = pageParams.get('status');

     filterCount = 0;
    
     if (!String.isEmpty(ref)) { filterCount++; } 
     
     if (!String.isEmpty(bdr_name)) filterCount++; 
     if (!String.isEmpty(bdm_name)) filterCount++; 
     if (!String.isEmpty(owner)) filterCount++; 
     if (!String.isEmpty(locality)) filterCount++; 
     if (!String.isEmpty(income_source)) filterCount++; 
     if (!String.isEmpty(status)) filterCount++; 
     if (!String.isEmpty(approver_name)) filterCount++; 
     
    // Run the query again
    runQuery();
    
    if (filterCount>0) {
     	 filtersSelected = true;
     	 
     	 filterMessage = resultsCount +' BDRs match your selected filters';
     	
     } else
         filterMessage = '';
 
    return null;
  }
  

  /* The search returns a list of BDRs wrapped in a BDRSearchWrapper 
  
  	 Not Used : The wrapper property isSelected enables BDRs to be selected in the list view
     using a checkbox and have some action applied them from a button on the search page
  */   
  public class BdrSearchWrapper
  {
  	
			   public BDR__c bdr {get; set;}
			
			   public String getHR() {
			   	   if (bdr.HR_Implications__c !=null && bdr.HR_Implications__c!='') {
			   	   		return ('&#10004;');
			   	   }
			   	   else return '';
			   }	
			//  	public boolean isSelected {get;set;}
			  	
			 
			  	
			  	public BdrSearchWrapper(BDR__c bdr)
			  	{
			  		this.bdr=bdr;
			 // 		isSelected=false;
			  	}
  	
  }    
  
}