public with sharing class NewLeadController{
    public String FirstName{get;set;}
    public String LastName{get;set;}
    public String Company{get;set;}
    public id recordTypeId{get;set;}
    public String postalcode{get;set;}
    public String city{get;set;}
    public String street{get;set;}
    public String state{get;set;}
    public Boolean ShowAllRecordTypes {get;set;}
    public Integer CountOfAvailableRecordTypes {get; private set;}
    public Lead relLead{get;set;}
    public List<Lead> lstMatchingLeads{get;set;}
    public Boolean searchDone{get;set;}
    public Map<id,string> mapofRecordTypes;
    public String recId {get;set;}
    public String selectedRelLeadId {get;set;}
    public String selectedRelLeadName {get;set;}
    public Boolean ignoreAndCreate {get;set;}
    static final Integer SEARCHLIMIT =100;
 
    //Constructor
 public NewLeadController(ApexPages.StandardController stdCon){
     RecordType rt;
     relLead = (Lead)stdcon.getRecord();
     if(relLead == null) relLead = new Lead();
     lstMatchingLeads = new list<Lead>();
     recId = ApexPages.currentPage().getParameters().get('recId');
     
     if(recId!=null){
      relLead.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='Lead' and Id=:recId].id;   
         System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ recId: '+recId);
         System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ relAccount.RecordTypeId: '+relLead.RecordTypeId);   
     }
     //get default record type - Alz Trading Record Type        
     rt = [Select id,name, developername from Recordtype where sObjecttype='Lead' and Developername = 'Alzheimer_s_Trading_Lead_Record_Type'];
     recordtypeId = rt.Id;
     mapofRecordTypes = new Map<Id,String>();
     getLeadRecordTypes();
     searchDone = false;
        }
    //Returns Recordtypes of Lead Available to current User.
    public List<SelectOption> getLeadRecordTypes(){
    List<SelectOption> lstRecordTypes = new List<SelectOption>();    
    //Retrieve All Lead RecordTypes    
        for(RecordTypeInfo rec: Lead.SObjectType.getDescribe().getRecordTypeInfosById().values()){
         //check if recrodtype is visible/available for cureent user.
             if(rec.isAvailable() && rec.getName()!='Master'){
              mapOfRecordTypes.put(rec.getRecordTypeId(), rec.getName());
              lstRecordTypes.add(new SelectOption(rec.getRecordTypeId(),rec.getName()));
          }            
        }
     CountOfAvailableRecordTypes = lstRecordTypes.size();
     return lstRecordTypes;       
    }
     public PageReference selectLead(){
        system.debug('>>>>>>>>>>>>>> createLead' ); 
        if(selectedrelLeadId!=null){
            try{
                //get the details of the selected dupe contact
                Lead dupeLead = [Select id, Name, Street, City, PostalCode, State, Phone, Owner.Alias From Lead c where id = :selectedrelLeadId];

                return new Pagereference('/'+dupeLead.Id+'/e?retURL=%2F'+dupeLead.Id);  //return to Lead details page
            }catch(Exception ex){ 
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while selecting existing Lead.');
                ApexPages.addMessage(message);
                return null;
            }
        }
        return new Pagereference('/apex/NewLead?id='+relLead.Id+'/e?retURL=%2F'+relLead.Id);
    } 
     public PageReference ignoreCreateLead(){
        // create account
        try{
            //set variables captured as inputtext on page
            relLead.FirstName=FirstName;
            relLead.LastName=LastName;
            relLead.Company=Company;
            relLead.Status='Open - Not Contacted';
            relLead.PostalCode = postalcode;
            relLead.Street = street;
            relLead.City = City;
            relLead.State = State;
            relLead.RecordTypeId = recordTypeId;
            insert relLead; 
            return new Pagereference('/'+relLead.Id+'/e?retURL=%2F'+relLead.Id); //return to new account details page
            }
        catch(Exception ex){ 
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage());
            ApexPages.addMessage(message);
            return null;
            }       
    }
    
    public PageReference doSearch(){
        Boolean isError = false;
        String LeadlikeName;
        List<String> LeadNameParts;
        List<Lead> ListofMatches = new List<Lead>();
        List<Lead> ListofAdditonalMatches = new List<Lead>();
        lstMatchingLeads.clear();
          //validation
        if ((FirstName==null||FirstName=='')||(LastName==null||LastName=='') ){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must enter the First Name and Last Name of the Lead');
            ApexPages.addMessage(message);
            isError = true;
        }
        if (isError){
        searchDone = false;
        return null;
        }
        searchDone = true;
       // Perform Search
       LeadDeduper objLeadDedupe = new LeadDeduper();
       lstMatchingLeads = objLeadDedupe.SearchLead(relLead, Company,LastName, postalcode, City, 
                                                  recordTypeId, ShowAllRecordTypes, SEARCHLIMIT); 
       //Finish Search, return message about what we have found
       //Found Duplicates, return warning
       
        if(lstMatchingLeads.size()>0)
        {
           ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Matching Leads have been found, please use one of the two buttons at the bottom of the screen to continue.');
           ApexPages.addMessage(message); 
           
           ignoreAndCreate = true;
           searchDone = false; 
        } else {
           ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'No matches found');
           ApexPages.addMessage(message);
           ignoreAndCreate = false;
           searchDone=true; 
        }
        return null;
    }
    private static testMethod void testNewLeadController(){
         
      Lead leadRec = new Lead(FirstName='Test',LastName='One1',PostalCode='SW1A 2AA',company = 'Test Company', Status = 'Open - Not Contacted',
                             RecordTypeId=[Select Id from RecordType Where SObjectType='Lead' and Name like 'Alzheimer_s_Trading_Lead_Record_Type%'].id);                                 
      insert leadRec;
      
      // Set up the VF page  
     ApexPages.StandardController stdCon = new ApexPages.StandardController(leadRec ); 
     NewLeadController cnt = new NewLeadController(stdCon);
     
     cnt.getLeadRecordTypes();
     
     cnt.recordTypeId=cnt.getLeadRecordTypes().get(0).getValue();
     
     // Without First Name and Last Name - Invalid
     
     cnt.doSearch();
     
     cnt.FirstName = 'Test';
     cnt.LastName = 'One1';
     cnt.ShowAllRecordTypes = true;
     cnt.doSearch();
     cnt.ShowAllRecordTypes = false;
     cnt.city = 'aaaaaa';
     cnt.doSearch();
     cnt.postalcode = 'SW1A 2AA';
     cnt.street = 'aaaaaa';
     cnt.state = 'UK';
     cnt.doSearch();
     
     cnt.ignoreCreateLead();
     
     cnt.selectedRelLeadId = leadRec.Id;
     cnt.selectLead();
   
   
        
    }   
 }