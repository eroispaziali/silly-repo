public without sharing class UIParticipantSearchControllerExtension {

   /***********************************************************************************************************
    *
    *   @author      :    gary.grant@conseq.co.uk
    *   @date        :    August 2014
    *
    *   @description :    Supports creating new User Involvement General Consents, with search for existing users
                                                  
                          The Class has to be Without Sharing so that users who do not have 
                          Contact access can see headline details for Contacts 
                          
                          !! IMPORTANT !!
                          No sensitive personal data should be exposed in the results columns                          
    *   
    ************************************************************************************************************/
 
  // The soql without the order and limit
  transient private String soql {get;set;}
  
  // Fields used for applying filters to the results    
  public String firstName {get;set;}
  public String lastName {get;set;}
  public String postCode {get;set;}
  public String birthDate {get;set;}
  public String gender {get;set;}
  public Integer resultCount {get;set;}
  public Boolean contactIsNotFound {get;set;}
  
  private Map<String, String> participantObjectFields;
  private Map<String, String> participationObjectFields;  
  
  public List<String> topic_selection {get;set;}
  public List<String> status_selection {get;set;}
  public List<String> activity_type_selection {get;set;}
  public List<String> method_selection {get;set;}
     
  public Contact contact {get;set;} // a Contact object for when a new contact is added
  public Demographic_Information__c dgdata {get;set;} // a Demographic Information object for when a new contact is created
    
  public String mainPanelContent {get;set;} // SEARCH or FORM

  /* Destination for a page reload. This is required
     because VF components may be in an IFrame. When returning a reference 
     to a standard page from a VF page, the iframe will refuse to load
     a page from a different host (VF pages and Standard pages
     are rendered from different hosts).       
  */     
  public String targetPageUrl {get;set;}  
  
  public UIParticipantSearchControllerExtension (ApexPages.StandardController ctl){
      
      /* Making this class a controller extension allows the VF page that uses it to be 
         linked to the UI_Participant__c object, which in turn means it can be 
         used to override the New action on that object. That's important
         because no new participants should be created without going thru the
         search screen.
      */     
      init();      
  }
  
  
  /* The properties below are the filters available */
  
  /* STATUS */  
  public List<SelectOption> getStatusOptions() {
    Schema.DescribeFieldResult field = UI_Participant__c.Status__c.getDescribe();
    return CustomUtils.getOptions(field);          
  }
  
  /* ACTIVITY TYPE */
  public List<SelectOption> getActivityTypeOptions() {
    Schema.DescribeFieldResult field = UI_Participant__c.Activity_Types__c.getDescribe();
    return CustomUtils.getOptions(field);
  }
  
  /* METHOD OF INVOLVEMENT */
  public List<SelectOption> getMethodOptions() {
    Schema.DescribeFieldResult field = UI_Participant__c.Methods_of_Involvement__c.getDescribe();
    return CustomUtils.getOptions(field);
  }
  
  /* TOPIC */
  public List<SelectOption> getTopicOptions() {
    
    /*Get the Entity Prefix, then get the topics that are linked to that prefix 
      !!! NOTE : The API version must be 32.0 otherwise EntityKeyPrefix is not available !!!!       
    */
    String sPrefix = UI_Participant__c.sObjectType.getDescribe().getKeyPrefix();    
    AggregateResult[] topics = [select topic.Name from TopicAssignment where EntityKeyPrefix =:sPrefix  group by topic.Name];
    
    List<SelectOption> options = new List<SelectOption>();             
    options.add(new SelectOption('','')); 
    for (AggregateResult aggr : topics) {
        String s = (String)aggr.get('Name');
       options.add(new SelectOption(s,s));
    }
    
    return options;
    
  }
      
  public void setAddContactOn()
  {
     mainPanelContent='FORM';   
  }
  
  public void setSearchOn()
  {
     mainPanelContent='SEARCH'; 
  }
  
  /** Used for the Confirm Consent action to create a new Participant */
  public String contactId{
        get;
        set {
            contactId = value;
        }
  }

  /** Used for the create participation action to create a new Participation record */
  public String participantId{
        get;
        set {
            participantId = value;
        }
  }
  
  public Integer getActiveParticipantCount() {
    Integer total = [ SELECT COUNT() FROM UI_Participant__c where Status__c='Active' ];
    return total;
  }

  /** The list of UIContactWrapper returned by the query */
  public List<UIContactWrapper> lisUICWrapper
  {
    get {
            if (lisUICWrapper == null) lisUICWrapper = new List<UIContactWrapper>();
            return lisUICWrapper;
        }
        set;
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
                            
    lisUICWrapper=new List<UIContactWrapper>();
    //contact = new Contact();
        
    firstName = '';
    lastName ='';
    postCode='';
    birthDate='';

    status_selection=new List<String>();
    activity_type_selection = new List<String>();
    method_selection = new List<String>();
    topic_selection = new List<String>();
    
    /* A variable to store the target URL of the links called the buttons. This 
       will be inserted into a JS var in the page and called by a page refresh */
    targetPageUrl = '#';
      
    /* Set the page up to have the main content as the search form */ 
    mainPanelContent='SEARCH';
    
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
    
    lisUICWrapper = new List<UIContactWrapper>(); 
    try {
        List<Contact> lisResults = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 200');   


        /* Get the all the contacts for the search */
        List<String> lisContactIds = new List<String>();
        for (Contact c : lisResults) {
            lisContactIds.add(c.id);  
        }

        /* Get the participant data for returned contacts 
           It's not possible to use CustomUtils.objectMapWithAllFields in this case because
           participants with Merged status need to be excluded. 
           
           If the CustomUtils method is expanded to include query clauses, replace this code                                 
        */
        //Map<String, sObject> mapParticipants = CustomUtils.objectMapWithAllFields('Contact__c', lisContactIds, Schema.sObjectType.UI_Participant__c);
        
        Map<String, UI_Participant__c> mapParticipants = new Map<String, UI_Participant__c>();
        List<UI_Participant__c> lisParticipants = [select Id, Contact__c, Name, Status__c, Participation_Count__c 
                                                        from UI_Participant__c 
                                                        where Status__c !='Merged' and Contact__c in :lisContactIds];       
                
        for (UI_Participant__c p : lisParticipants) {
            mapParticipants.put(p.Contact__c, p);   
        }      
     
        for (Contact c : lisResults) {            
        
            /* Create a wrapper with the composite data included */
            UI_Participant__c participant = (UI_Participant__c)mapParticipants.get(c.id);        
            lisUICWrapper.add(new UIContactWrapper(c, participant));                               
        
        }  
        
        resultCount=lisResults.size();
        
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
 
    firstName = pageParams.get('firstName');
    lastName  = pageParams.get('lastName');
    postCode  = pageParams.get('postCode');
    birthDate = pageParams.get('birthDate');    
    
    // Run the query again
    runQuery();
 
    return null;
  }
  
  /** Generate the soql query string */ 
  private void generateQueryString()
  {
  
   soql = 'select Id, ' +
                'FirstName, ' +
                'LastName,' + 
                'MailingPostalCode, ' +
                'BirthDate, ' +
                'Name, ' +
                'OwnerId, ' +
                'DoNotCall,' +
                'Deceased__c,' +  
                'Client_Reference_Number__c ' +
                
                'from Contact where LastName != \'*****\'';

    if (!firstName.equals('')) {  
      soql += ' and FirstName LIKE \'%'+String.escapeSingleQuotes(firstName)+'%\'';
    }

    if (!lastName.equals('')) {  
      soql += ' and LastName LIKE \'%'+String.escapeSingleQuotes(lastName)+'%\'';
    }

    if (!postCode.equals('')) {  
      soql += ' and MailingPostalCode = \''+String.escapeSingleQuotes(postCode) +'\'';
    }
    
    if (!birthDate.equals('')) {        
     Date dt = Date.parse(birthDate);
     String sDate = String.valueOf(dt);       
     soql += ' and birthDate = '+ sDate;
    }
    
    if (!status_selection.isEmpty())  {       

        soql += ' AND id in (select Contact__c from UI_Participant__c where Status__c in (';    
        soql += CustomUtils.listAsString(status_selection);
        soql += '))';
    
    }  
    
    // Special SOQL syntax that works for multi-value picklists
    if (!activity_type_selection.isEmpty())  {       

        soql += ' AND id in (select Contact__c from UI_Participant__c where Status__c != \'Merged\' and Activity_Types__c includes (';    
        soql += CustomUtils.listAsString(activity_type_selection);
        soql += '))';
    }
    
    // Special SOQL syntax that works for multi-value picklists
    if (!method_selection.isEmpty())  {       

        soql += ' AND id in (select Contact__c from UI_Participant__c where Status__c != \'Merged\' and Methods_of_Involvement__c includes (';    
        soql += CustomUtils.listAsString(method_selection);
        soql += '))';
    }         
    
    if (!topic_selection.isEmpty())  {       
        
        
        /* Get the list of participants that match the Topics */ 
        String sPrefix = UI_Participant__c.sObjectType.getDescribe().getKeyPrefix();
        String soql2 = 'select Contact__c from UI_Participant__c where Status__c != \'Merged\' and id in (';
        
        soql2 += 'select EntityId from TopicAssignment where EntityKeyPrefix = \'' + sPrefix + '\' and topic.Name in (';    
        soql2 += CustomUtils.listAsString(topic_selection);
        soql2 += '))';
        
        /* Put the list of Contact Ids from the Participants into a list */
        List<UI_Participant__c> lisParticipants = database.query(soql2);
        List<String> contactIds = new List<String>();
        for (UI_Participant__c p : lisParticipants) {        
            contactIds.add(p.Contact__c);        
        }
        
        /* Add the clause to the main query */
        soql += ' AND id in (';
        soql += CustomUtils.listAsString(contactIds);        
        soql += ')';                 
    
    }

    system.debug('Participant Search Query : ' + soql); 

  }
  
  public void clicked()
  {
      // do nothing
  }
 

  public boolean getIsSysAdmin()
  { 
    return CustomUtils.isModifyAllData(UserInfo.getUserId());
  }     
    
}