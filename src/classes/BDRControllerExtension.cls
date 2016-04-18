public without sharing class BDRControllerExtension extends BaseControllerExtension {
    
/*******************************************************************************************************************************************
@author             gary.grant@conseq.co.uk
@date               Jan 2013
@description      Controller Extension. 
  
                        A combined controller to handle creating and editing a BDR__c and associated database records
                            
                        The BDRWrapper  contains (where relevant) the 
  
                        BDR__c, 
                        bd_contract__c 
                        Income_block__c
                        IncomeData (collection of Income_Block_Period__c, Fund_Allocation__c)
                        BdrServiceWrapperList (a container class for 
                                 - Services__c, 
                                 - Funding_Requirement__c, 
                                 - Evidence_For_Need__c)
                    
                             
                       This class is set to WITHOUT SHARING. 
                       Access to records is controlled via Sharing Rules and access to the UI components.
                                
                       Funding Requirements, Evidence For Needs and Allocations are 
                       retrieved and held in both separate lists and inside their respective wrappers
                              
                       This avoids the need for multiple queries inside each wrapper and also 
                       enables the set of records to be updated in a single operation
  
********************************************************************************************************************************************/

 private BDR__c BDR;
 
 public BDRWrapper bdrWrapper {get; set;}

 public String bdrid;

 private List<String> fiscalYears;
 
 public static final Set<String> DRAFT_ACCEPTED_PROPOSED = new Set<String>{'Draft', 'Accepted', 'Proposed'};  
 public static final Set<String> ACCEPTED_PROPOSED = new Set<String>{'Accepted', 'Proposed'};
 
 public static final String BDR_STATUS_DRAFT = 'Draft';
 public static final String BDR_STATUS_LIVE = 'Live';
 public static final String BDR_STATUS_PROPOSED = 'Proposed';
 public static final String BDR_STATUS_ACCEPTED = 'Accepted';
 public static final String BDR_STATUS_DECLINED = 'Declined';
 public static final String BDR_STATUS_UNSUCCESSFUL = 'Unsuccessful';


 public BD_Contract__c dummyContract {get;set;}  // Used in creating Contract Extension
 public BDR__c dummyBdr {get;set;}                     // Used in creating Contract Extension
    
 
  /** Used for the Service Edit action. The Service Id to edit from the button 'Edit Service' */
 public String serviceId { 
        get;   
        set {  serviceId = value; }
 }
 
 public String hasContract {    
         get { return bdrWrapper.hasContract; }  
         set;
 }
    
 public String hasIncomeBlock {
         get { return bdrWrapper.hasIncomeBlock;   }  
         set;
 } 
    
 public String hasServices{ 
          get { return bdrWrapper.hasServices; }  
          set;
 }
            
 public String hasPartner{ 
             get { return bdrWrapper.hasPartner; }  
             set;
 }

 public String hasBid{
             get { return bdrWrapper.hasBid; }  
             set;
 }
 
 public Boolean isContractUpdate {get; set;}      
 public void enableContractUpdate()
 {
    isContractUpdate=true;
    system.debug('Setting value of isContractUpdate' + isContractUpdate);
 }
 
  
 /* String arrays to store the checkbox data submitted from the form.  Each of these has a corresponding field on the object  */
 
 // BDR checkboxes
 public String[] hr_implications_selection {get;set;}                       /**    The selection of HR Implications  - BDR.HR_Implications__c*/
 public String[] notifications_selection{get;set;}                              /**    The selection of users to notify when the BDR is approved -  BDR.Notifications_Pending__c*/
 public String[] reasons_declined_selection {get;set;}                      /**    The selection of Reasons Declined   - BDR.Reasons_Declined__c */
 
 // Contract checkboxes
 public String[] required_signatures_selection {get;set;}                   /**    The selection of Contract Required Signatures  - Required_Signatures__c */
 public String[] highlighted_contract_items_selection {get;set;}        /**    The selection of Contract highlighted_contract_items   */


  
  /* Get picklist values for use in checkbox selections */
  
 public List<SelectOption> getHR_Implications_Options() {    
          return getOptionList(BDR__c.HR_Implications__c.getDescribe());
 }  
  
 public List<SelectOption> getReasons_Declined_Options() {            
           return getOptionList(BDR__c.Reasons_Declined__c.getDescribe());            
 }
 
  public List<SelectOption> getRequired_Signatures_Options() {    
         return getOptionList(BD_Contract__c.Required_Signatures__c.getDescribe());    
 } 
 
 public List<SelectOption> getHighlighted_Contract_Items_Options() {    
           return getOptionList(BD_Contract__c.Highlighted_Contract_Items__c.getDescribe());            
 }
 
 
 /* Generic method to get the picklist values */
 private List<SelectOption> getOptionList(Schema.DescribeFieldResult describeResult ) {    
     
          List<SelectOption> options = new List<SelectOption>();                
          
          // Get the picklist values
          List<schema.picklistentry> values = describeResult.getPickListValues();
          for (Schema.PicklistEntry entry : values) {
               options.add(new SelectOption(entry.getLabel(), entry.getValue()));
          }
          return options;  
 }  
  

/**
     @description   Get the current approver if BDR currently pending Approval
 */
 public String currentApproverName {
get  {
        return CustomUtils.getCurrentApprovalActorName(bdr.id);  
 } set;
}

/**

    @param           controller BDR__c Standard Controller
    @description    The constructor.  Called any time the page is loaded in read or edit mode                              Initialises a bdrWrapper
                            
*/
 public BDRControllerExtension(ApexPages.StandardController controller) 
 {
     
      
     
        // Call the constructor of BaseControllerExtension
         super(controller);
        // ctl.addFields(new List<String>{'Reasons_Declined__c'});

         // ctl is the StandardController set in BaseControllerExtension
         BDR=(BDR__c)ctl.getRecord();

         // Set the class variable so that the id is available to all methods              
         bdrid = BDR.id;
    
        // Populate the Muli-value checkbox arrays from the associated picklist values in the object data
         hr_implications_selection = BDR.HR_Implications__c==null ? new List<String>() : BDR.HR_implications__c.split(';');
         reasons_declined_selection = BDR.Reasons_Declined__c==null ? new List<String>() : BDR.Reasons_Declined__c.split(';'); 
           
         /*
          *   Copy the value of the Fiscal_Years__c column to a comma separated list
         */
         if (BDR.Fiscal_Years__c!=null) {
            fiscalYears = BDR.Fiscal_Years__c.split(';');
         } 
         
         //Set 2 defaults on a new BDR record, Owner Id and Status
         if (bdrid==null) {

                   bdrWrapper = new bdrWrapper();
                   bdr.OwnerId=UserInfo.getUserId();
                   bdr.Status__c=BDR_STATUS_DRAFT;  
                   
                   /* These properties need to be initialised */
                   required_signatures_selection = new List<String>();
                   highlighted_contract_items_selection = new List<String>();
                                       
           
         } else {
                   // Here we are editing an existing BDR. 
                   bdrWrapper = new bdrWrapper(BDR);
        
                   /*A disposable BDR__c object used to capture dialog fields
                   used in the clone action */ 
                   dummyBdr=new BDR__c();
        
                   /* Initialise values for the notification selection dialog based on the data*/     
                   notifications_selection = BdrUtils.getMandatoryNotifications(bdr, bdrWrapper.Contract);
                   
                   /* Use a dummy contract object to capture extension dates */
                   /* Use a dummy bdr object to capture amount in contract extension dialog  */
         
                   if (bdrWrapper.Contract!=null) { 
                       // These used for the check boxes. This sets the values from the BDR so the correct boxes are checked
                       required_signatures_selection = bdrWrapper.Contract.Required_Signatures__c==null ? new List<String>() : bdrWrapper.Contract.Required_Signatures__c.split(';');
                       highlighted_contract_items_selection = bdrWrapper.Contract.Highlighted_Contract_Items__c==null ? new List<String>() : bdrWrapper.Contract.Highlighted_Contract_Items__c.split(';');  

                   } else {
                       /* These properties need to be initialised */
                       required_signatures_selection = new List<String>();
                       highlighted_contract_items_selection = new List<String>();                   

                   }
                   
                   if (bdrWrapper.Contract!=null) {                     
                        isContractUpdate=false;                     
                   }                   
            
                   if (bdrWrapper.Contract!=null && isBdrLive()) {
                    
                         /* This is a disposable BD_Contract object to capture values that should be passed to new objects */                       
                        dummyContract = new BD_Contract__c();
                        
                        Date startDate=bdrWrapper.Contract.Start_Date__c;
                        Date endDate=bdrWrapper.Contract.End_Date__c;
                        
                        // The normal thing is that the contract extension starts the day after the old contract ends
                        if (endDate!=null) {            
                           dummyContract.Start_Date__c=endDate.addDays(1);      
                        }
                     
                        if (endDate!=null) {
                            dummyContract.End_Date__c=endDate.addMonths(12);
                        }     

            }        

         }  
         
 }
 
  public List<SelectOption>  getLocalities() { 
      
          List<SelectOption> options = new List<SelectOption>();            
          List<BDR_Organisation__c> localities =[ Select  Id, Name FROM BDR_Organisation__c  where RecordType.DeveloperName = 'Locality' order by Name limit 200];
    
          options.add(new SelectOption('','')); 
          
          for (BDR_Organisation__c O : localities) {
               options.add(new SelectOption(O.Id, O.Name));
          }
          return options; 

  }
 
 
  /** @description  Get the current page name (returns lower case only) 
   */ 
  public string getPageName()
  {
                
     // If this method is called by a test then default the current page            
     if (Test.isRunningTest()){ return 'bdr_edit_tabbed' ;}
    
      // Get the current page being displayed   
      String pageName = ApexPages.CurrentPage().getUrl();    
      pageName = pageName.replaceFirst('/apex/','');       
      pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');   
      string[] pageNameExtra = pageName.split('%3F',0);  
                                                             
      pageName = pageNameExtra[0].toLowerCase();                    
                                                 
      return pageName;    
  }
      
 /*
  *  The 'Financial Years' data is derived from the BDR Estimated Start date and number of months
  *
  */      
 public boolean allowEditBDRTimeSpan { 
    get{
        if (userHasAdminRights) { return true; }
        return (DRAFT_ACCEPTED_PROPOSED.contains(bdr.Status__c));
    
    }
    set;
 }


    
 public Boolean hasFiscalYears { 
        get { return fiscalyears!=null && !fiscalYears.isEmpty(); }
        set; 
 }

 public String hasAllocation { 
        get { return bdrWrapper.hasAllocation; }        
        set; 
 }
 

 
 /** Used for the remove action. The service id to remove from the button 'Remove Service' */
 public String rid{
        get;
        set {
            rid = value;
        }
 }

 /** Used for the edit evidence action. The ID of the Evidence For Needs to edit */
 public String evid{
        get;
        set { evid = value; }
 }


 
 public PageReference contractAttachmentPage {
        get {              
             PageReference pr = Page.BDR_Contract_Attachments;
             if (bdrWrapper.contract!=null) {
                    pr.getParameters().put('id', bdrWrapper.contract.id);
             }             
             return pr;
                     
        }        
        set;
 }

 public Decimal servicesCount { 
        get { 
              if (bdrWrapper.services.svcRecords==null) {
                 return 0;
                 }  
              return bdrWrapper.services.svcRecords.size(); 
            }
        set; 
 }
 
 public Decimal openServicesCount {
        get { 
              if (bdrWrapper.services.svcRecords==null) {
                 return 0;
                 } 
              
              Decimal d=0;   
              for (Services__c svc : bdrWrapper.services.svcRecords ) {   
                  if (svc.Service_Status__c == 'Open') { d++; }                        
              }
              
              return d;
            }
        set;    
 }
 



 /** @description       
         Returns the list of email recipients that will be displayed in the approval dialog 
         giving the user manual control over additional notifications  
         

 
 */    
 public List<SelectOption> notificationOptions {
    
        get {           
              List<SelectOption> options = new List<SelectOption>();                
              Map<String, String> mapOptions = new Map<String,String>();
              
              
              if (bdr.HR_Advisor__c!=null) {
                mapOptions.put('HR (' + bdr.HR_Advisor__r.name + ')', 'HR_Advisor');
              }
              
              mapOptions.put('Legal ('+ system.Label.Legal_Notification_Name +')', 'Legal');
              mapOptions.put('Property ('+ system.Label.Property_Notification_Name +')', 'Property');
              mapOptions.put('IT ('+ system.Label.IT_Notification_Name +')', 'IT');
              mapOptions.put('Information Governance ('+ system.Label.IG_Notification_Name +')', 'IG');
              mapOptions.put('Operations ('+ system.Label.Operations_Notification_Name +')', 'Operations');  
              if (bdr.Regional_Accountant__c!=null) {
                mapOptions.put('Finance (' + bdr.Regional_Accountant__r.name + ')', 'Finance');
              } 
                          
              String[] aNotifications = BdrUtils.getMandatoryNotifications(bdr, bdrWrapper.contract);
              String sNotifications='';
              for (String s : aNotifications) {
                 if (sNotifications!='') { 
                    sNotifications = sNotifications + ' '; 
                 } 
                 sNotifications=sNotifications + s;
              }
              
              for (String label : mapOptions.keySet()) 
                      {            
                        String value = mapOptions.get(label);
                        
                        boolean bSelected = false;
                        if (sNotifications!='') {      
                            bSelected = (sNotifications.indexOf(value.trim())>-1);
                  
                        }        
                        SelectOption option = new SelectOption(value, label, bSelected);
                        options.add(option);
                      }
              return options;                       
        }
        set;        
 }
  
 
 /**

 @Description   Update requested notifications and submit the BDR for approval. 
                Includes logic o initiate conditional notifications that are dependent on data or user selection.
 */
 public pageReference submitForApproval()
 {
    /* There are two types of notification
    
       1) Hardcoded in the workflow approval process
       2) Conditional. Only initiated where the data requires it (e.g. Tupe) or the user requests it, IT, HR, Legal
          
       The conditional workflow rules should use criteria that make them activate when 
        
        - Notification_Action=='Y' 
        - Notifications_Pending__c contains xxx 
        
        where xxx is the reference for the notification (set in the code below).   (HR, IT, Legal, Property)
        
        There is a workflow rule for each of the above
          
       The workflow rules have two components:
       
       - the Email Alert
       
       - a Field Update that clears the relevant reference from the Notifications_Pending__c field
         using a SUBSTITUTE formula to extract the indivual reference.
           
       As each defined workflow rule runs, the value in Notifications_Pending__c will be cleared. 
       A trigger on BDR__c will clear the field Notification_Action__c when 
       Notifications_Pending__c is blank (all conditional notification rules have run).
       
       BDR_BeforeUpdate.trigger
       
   */    
    
    /* Don't submit twice. This does not appear to trap a double click submit */
    if (CustomUtils.isApprovalInProcess(bdr.id)) { 
        system.debug('Error: Already in Approval'); 
        return null;
    }
    
    system.debug('Approval Proceeding');
    
    /* 
       Get the list of non-optional email notifications.
        
       These are not available from the dialog because disabled check boxes do not submit a value.
        
       It's important this action can only be called from read mode so that there is certainty this value is the same at load time
       and when the action is pressed. 
    */
    
    String[] notificationsArray = BdrUtils.getMandatoryNotifications(bdr, bdrWrapper.contract);
    String sNotifications='';
    for (String sN : notificationsArray) {
        if (sNotifications!='') { 
            sNotifications=sNotifications+' '; 
            }
    
            // ensure there is a space on the end here
            sNotifications = sNotifications + sN + ' ';
    }
    
    // Add the user selected additional notifications into the list of pending notifications  
    if (notifications_selection!=null && notifications_selection.size()>0) {
       
        // Add the selected notifications to the String of pending notifications
        for (String element : notifications_selection) {
                  if (sNotifications.indexOf(element) < 0 ) {
                    sNotifications = sNotifications + element + ' ';
                  }
        }   
    }
    
    // Update the selected notifictions pending into the BDR 
    bdr.Notifications_Pending__c = sNotifications;
    
    System.debug('BDR Submit for Approval - Pending Notifications: ' + bdr.Notifications_Pending__c);
    
    update bdr;
    
    // Submit into workflow approval
    Approval.ProcessSubmitRequest asr = new Approval.ProcessSubmitRequest();
    asr.setObjectId(bdr.id);
    
    //  Need to handle the case where the user record for the user doing the approval is Inactive
    //  Process failed. First exception on row 0; first error: MANAGER_NOT_DEFINED, Manager undefined.: []
    try {
    Approval.ProcessResult result = Approval.process(asr);
 
    } catch (Exception ex) {
        system.debug('ERROR SUBMITTING APPROVAL: ' + ex);
    }
  
         
    // return to the same page
    return null;     
         
 }
 
 /**
  * @description   Init all the enhanced lookups with a single soql query
  *                to avoid going over the SOQL query limit 
  **/ 


 public void refreshData() {    
    bdrWrapper.refreshData();
    bdr=(BDR__c)ctl.getRecord();
 } 


  
 public pageReference returnToEdit(String tabName)
 {   
  String url = '/apex/BDR_Edit_Tabbed?id='+ bdrid;
  if (tabName!=null) { 
    url = url + '&tab=' + tabName; 
  }  
  PageReference pr=new PageReference(url);
  pr.setRedirect(true);


  return pr;
 }
  
  /*
   *  This method is called when the user clicks the "Add New Service" button
   */
 public PageReference addNewService()
 {
    
       
   if (getPageName().equals('bdr_edit_tabbed')) {
           /* Save the BDR and it's associated records before moving to the the "Add Service" page */  
           if (!saveRecords()) {
                return null;
            }
   }
  
   PageReference pr = new PageReference('/apex/bdr_service_add_update?bdrid=' + BDR.id);  
   pr.setRedirect(true);
   return pr;     
 
 } 
  
    /*
   *  This method is called when the user clicks the "Add  Existing Services" button
   */
 public PageReference addExistingServices()
 {
  /* Save the BDR and it's associated recors before moving off the the Add Service page */  
  
   // Save the BDR if we are in Edit mode
   
   if (getPageName().equals('bdr_edit_tabbed')) {
           if (!saveRecords()) {
                return null;
            }
   }
 
   PageReference pr = new PageReference('/apex/bdr_search_services?bdrid=' + BDR.id);  
   pr.setRedirect(true);
   return pr;
 } 
  
 private pageReference returnToView()
 { 
  PageReference pr=new PageReference('/'+ bdrid);
  pr.setRedirect(true);

  return pr;
 }
 
 public pageReference cloneBdr()
 { 
     
          BDR__c cloneBdr = bdrUtils.cloneBdr(BDR.id, dummyBdr.Intended_Start_Date__c, dummyBdr.Estimated_Duration__c.intValue(), dummyBdr.Total_Value__c.intValue());
          PageReference pr=new PageReference('/'+ cloneBdr.id);
          pr.setRedirect(true);
        
          return pr;
 }
 
 /**
 * @description Create a new BDR with dates captured from a dialog presented to the user
                This is a contract extension, with dates starting from the end date of the previous contract
 *              Income should be allocated across the years based on the dates
 *                           
 **/
 public pageReference createBdrExtension()
 { 
     
          BDR__c Bdr2= BdrUtils.createBdrExtension(bdr.id, dummyContract.Start_date__c, dummyContract.End_date__c, dummyBdr.Total_value__c);
          
          PageReference pr=new PageReference('/'+ Bdr2.id);
          pr.setRedirect(true);
          System.debug('Bdr Extension : ' + pr.getUrl());
        
          return pr;
 }

/** 
 *   @description   Save the BDR and all related records,
                            then close the page and return to the BDR_View 
 */
 public pagereference saveAndClose() 
 {
    
    /* If a trigger that runs when save() is called results in an error
     then save() will return null. No error is thrown as such. 
     
     To trap that case, test for save() returning null and return null instead of a pageReference.
     That will leave the user on the edit page. Any errors will be displayed by <apex:pageMessages> in the VF page
  
    */ 
    
   SavePoint sp=Database.setSavePoint();     
   if (saveRecords()) {          
         system.debug('BDR Save succeeded');         
         return returnToView(); 
   }
         
   system.debug('BDR Save failed');
   Database.rollback(sp);
   return null;
 }

/** 
 * @description   Save BDR and all records and leave
 *                the user  on the page to continue editing.
 *                All the data is refresheds to ensure the page can be updated to reflect
 *                conditionally displayed items
 **/ 
 public pageReference save() 
 {  

    SavePoint sp=Database.setSavePoint();    
     
    if (saveRecords()) { 
                ApexPages.Message message = 
                new ApexPages.message(ApexPages.severity.Info,'BDR saved at ' + system.now().format() +
                 '.   Please save updates frequently.');
                ApexPages.addMessage(message);
                
                /* Refresh all the variables dependent on data in the records so that UI items with conditional display are properly refreshed*/
                bdrWrapper= new bdrWrapper(BDR);
               
                notifications_selection = BdrUtils.getMandatoryNotifications(BDR, bdrWrapper.contract);    
                                
                return null;    
    
    }
   

    system.debug('BDR Save failed');
    Database.rollback(sp);
    return null;
 }

 /** 
  *  @description   Save the BDR and all related records
  *                 Note that some data may be updated by the BDR Triggers    
  *
  **/
 private boolean saveRecords()
 { 

  if  ( contentionCheck()) { 
      system.debug('***** CONTENTION');
      return false; 
    }

  system.debug('Getting into Save All Records');    

  // Do this before the BDR save so that changes in the triggers are not overwritten
  // Some of the child records are updated in the BDR save triggers
  try {  
        
      doSaveContract();
      doSaveServices();
      doSaveFundRequirements();
      doSaveIncome();
      doSaveAllocations();      
      doSaveEvidenceForNeeds();
            
  } catch (DmlException x) {
    ctl.getRecord().addError(x.getDmlMessage(0));    
    return false;
  } 
   
  system.debug('*****  Now in saveRecords');
  BdrUtils.setBdrActors((BDR__c)ctl.getRecord()); 
  
  ctl.getRecord().put('HR_Implications__c',   String.join(hr_implications_selection,';'));
  ctl.getRecord().put('Reasons_Declined__c',   String.join(reasons_declined_selection,';'));
   
  /*Put in the string for list views that shows components */
  ctl.getRecord().put('Component_List__c', getComponentList()); 
   
  // Compute in two Strings related to Service Types and Specs
  // These use a hard coded map of codes that map Service Types to Specs    
  
  if (bdrWrapper.services !=null) {
  
    String sSpecs = bdrWrapper.services.serviceSpecString;
    system.debug('Setting Service Spec : ' + sSpecs);
    bdr.Service_Specifications__c = sSpecs;  
    bdr.Service_Types__c = bdrWrapper.services.serviceTypeString; 
  
  }
     
   
  if   (ctl.save()==null) { 
       return false; 
  }    
  bdr=(BDR__c)ctl.getRecord();
  bdrid=ctl.getRecord().id;      
  
  /* Update the time stamp to avoid erroneous contention errors */
  oSystemModStamp = (DateTime)ctl.getRecord().get('SystemModStamp');
  return true;

 }   
 
 /* Update an existing contract on a Live BDR. This will be a limited set of fields */ 
 public void updateContract()
 {
 
  System.debug('Updating Contract');  
  if (bdrWrapper.contract==null) { 
    return ; 
  }  
  
  update bdrWrapper.contract;
  isContractUpdate=false;  
 
 }
 
 private void doSaveContract()
 {
  system.debug('Saving Contract');  
  if (bdrWrapper.contract==null) { 
    return ; 
    }
        
     /* The contract carries the id of the income block. 
        Logicaly however, the Income Block should carry the id of the contract. 
        
        In fact, both records carry each other's Ids 
        so that data from each can be computed back and forth. 
        
        It is likely that the requirement for the Contract to carry 
        the Income Block's id is not required and could be removed
        
        In fact, both records really are the same thing (a contract is a set of fields
        on an income block). But, in early development they were implemented as separate records
        and re-factoring is not viable. 
        
        In this model it would be feasible for a contract to have more than one
        income block, and visa versa. The interface will not allow this, 
        but there is no database validation preventing it happening.                                         
     */           

     bdrWrapper.Contract.Income_Source__c = BDR.Income_Source__c;  
     
     /*The income block must exist before the contract is created, so this test is a little redundant.
       The user interface should ensure contracts can not be created before an Income Block is created */
     if (bdrWrapper.hasIncomeBlock=='Yes') {
         bdrWrapper.Contract.Income_Block__c = bdrWrapper.incBlock.id;
         bdrWrapper.incBlock.Contract__c = bdrWrapper.Contract.id;
     }

     if (bdrWrapper.Contract.Fiscal_Years__c==null || bdrWrapper.Contract.Fiscal_Years__c=='') {
         bdrWrapper.Contract.Fiscal_Years__c = bdr.Fiscal_Years__c;  
     }

     if (bdrWrapper.Contract.Status__c==null || bdrWrapper.Contract.Status__c=='') {
         bdrWrapper.contract.Status__c = bdr.Status__c;  
     }

     if ( bdrWrapper.Contract.End_Date__c<>null && bdrWrapper.Contract.Review_date__c == null ) {
        
       /* Set the review date to 6 months prior to contract end */  
       if ( Date.Today().monthsBetween(bdrWrapper.Contract.End_Date__c) < 6 ) {
            bdrWrapper.Contract.Review_date__c = bdrWrapper.Contract.Start_Date__c;
       } else {
       
            Date dt = (Date)bdrWrapper.contract.End_Date__c;
            dt = dt.addMonths(-6);
            bdrWrapper.Contract.Review_date__c = dt;    
       }    
        
     } else {
        system.debug('Setting Contract Start Date is Null');
     }
   

     bdrWrapper.Contract.Required_Signatures__c = String.join(required_signatures_selection,';');
     bdrWrapper.Contract.Highlighted_Contract_Items__c = String.join(highlighted_contract_items_selection,';');

     update bdrWrapper.Contract;
     update bdrWrapper.incBlock;
  
 }

 private void doSaveIncome()
 {
    
  system.debug('Saving Income');        
  if  (bdrWrapper.hasIncomeBlock=='Yes') {
            bdrWrapper.incBlock.Income_Source__c = bdr.Income_Source__c;  
            update bdrWrapper.incBlock;  
            doSaveIncomeBlockPeriods();  
  }  
 } 

 public void doSaveAllocations()
 {
    /* A change to FiscalYear Scope may have resulted
       in some Fiscal Years moving out of scope
       in which case those Income_Block_Periods and Allocations
       will have been deleted by the BDR afterUpdate Trigger
       
       Ensure those records are removed before issuing
       an update here (see the comment below). 
       
       NOTE: the BDRWrapper is not updated.
       
       The calling Save process should  refresh the bdrWrapper data 
       by retrieving the current set of data after all the saves
       are completed. 
    */
    
    
    system.debug('Start Save Allocations');
    if (bdrWrapper.hasIncomeBlock!='Yes') { 
        system.debug('Save Allocations - hasIncomeBlock!=Yes');
        return;
    } 
    if (BdrWrapper.hasServices!='Yes') {
        system.debug('Save Allocations - hasServices !=Yes');
        return;
    }
    
    if (BdrWrapper.services.allocations == null) {
        system.debug('Save Allocations - allocations==null');
        return;
    }
    
    if (BdrWrapper.services.allocations.isEmpty()) {
        system.debug('Save Allocations - allocations.isEmpty');
        return;    
    }

    system.debug('Fiscal Years for Allocation Save:' + bdr.Fiscal_Years__c);

    system.debug('Doing save allocations');
    if (BdrWrapper.services.frWrappers != null) {
     
        system.debug('Save Allocations - frWrappers!=null');   
        List<Fund_Allocation__c> faToUpdate = new List<Fund_Allocation__c>();
        Set<String> stFiscalYears = new Set<String>(bdr.Fiscal_Years__c.split(';'));    
                 
        for (BDRFundReqWrapper fr : BdrWrapper.services.frWrappers) {              
             system.debug('Fund Allocation Being Saved: ' + fr.allocation.id);
             system.debug('Fund Allocation Amount: ' + fr.allocation.Allocation_Amount__c);
             system.debug('Fund Freq Fiscal Year: ' + fr.freq.Fiscal_Year__c);
             system.debug('Fund Allocation IBP Id: ' + fr.allocation.Income_Block_Period__c);
             system.debug('Fund Allocation FR Id: ' + fr.allocation.Funding_Requirement__c);
             
             
             /* Check the Fiscal Year of the funding requirement (don't check the allocation, Fiscal Year there is a formula field, which 
                are not avaiable before insert so the value will be null) to ensure that only the relevant fiscal years are inserted/updated
                This avoids an attempt to update data for years where data in the bdrWrapper in memory object has been deleted by a change in fiscal year scope
             */
             if (stFiscalYears.contains(fr.freq.Fiscal_Year__c)){                
                system.debug('Updating/Adding allocation within FY Scope: ' + fr.freq.Fiscal_Year__c);                
                faToUpdate.add(fr.allocation);    
             }  
                        
        }
        upsert faToUpdate;
    }
 } 
 

 /* 

 March 2015
 This Method disabled. Causing conflicts with saves to Services from out side the system
 Services will not be edited independently and individually, which will reduce the chances
 of a save conflict

 At some point it may be worth exploring making the process more sophisticated to 
 save services independently or only if there has been update. Only if required by the UI. 

 */
 private void doSaveServices()
 {
 
  return; // SAVE DISABLED

  /*
  system.debug('Saving Services');     
 
  if (BdrWrapper==null) { return; }
  if (BdrWrapper.hasServices=='No') { return; }       
    
  if (!BdrWrapper.services.svcRecords.isEmpty()){ 
  
      List<Services__c> lis = new List<Services__c>();
      for(Services__c svc : BdrWrapper.services.svcRecords) {
          lis.add(svc);
      }
      upsert lis;
  } 
  */   

 }
 
 
 private void doSaveFundRequirements()
 {
 
  system.debug('Saving Fund Requirements');     
 
  if (BdrWrapper==null) { return; }
  if (BdrWrapper.hasServices=='No') { return; }       
    
  if (!BdrWrapper.services.frWrappers.isEmpty()){ 
  
      List<Funding_Requirement__c> lis = new List<Funding_Requirement__c>();
      for(BdrFundReqWrapper frw : BdrWrapper.services.frWrappers) {
          lis.add(frw.freq);
      }
      upsert lis; 
  }    
 }
 

 private void doSaveIncomeBlockPeriods() { 
    
    system.debug('Saving Income Block Periods');
    
    if (bdrWrapper.incomeData.isEmpty()) { 
        
        System.debug('IncomeData is Empty');
        return; 
        
        } 
    
    /* A change to FiscalYear Scope may have resulted in some Fiscal Years moving out of scope
       in which case those Income_Block_Periods will have been deleted by the BDR afterUpdate Trigger
       
       Ensure those records are removed before issuing an update here. 
       
       NOTE: the BDRWrapper is not updated.
       
       The calling Save process should  refresh the bdrWrapper data by retrieving the current set of data after all the saves
       are completed. 
    */  
  
    System.debug('Fiscal Years for IBP Save:' + bdr.Fiscal_Years__c);
    List<Income_Block_Period__c> incomeBPList = new List<Income_Block_Period__c>();
    Set<String> stFiscalYears = new Set<String>(bdr.Fiscal_Years__c.split(';')); 
    for (Income_Block_Period__c ibp : bdrWrapper.incomeData) {
 
        if (stFiscalYears.contains(ibp.Fiscal_Year__c)) {
 
 //           System.debug('Adding ibp for Fiscal Year:' + ibp.Fiscal_Year__c);
             incomeBPList.add(ibp);
        }   
 
    }
    
    upsert  incomeBPList;   
 
 }
 
 public pageReference addContract()
 {  
    if (hasContract=='Yes') { return null; }

    bdrWrapper.addContract(null);
    
    
   /* The BDR__c will be saved in this process. Update the ContentionCheck date in the 
      ViewState to reflect that update otherwise subsequent saves will show an
      erroneous contention error.
   */                
   oSystemModStamp = [select SystemModStamp from BDR__c where id =:bdrid].systemModStamp;
    
   return null;
 }
 
 public pageReference addIncomeBlock()
 {

   /* This action should not add more than one Income Block */
   if (bdrWrapper.hasIncomeBlock=='Yes') { 
    return null; 
    }
   bdrWrapper.addIncome();
   System.debug('Income Added');
  
  
   /* The BDR__c will be saved in this process. Update the ContentionCheck date in the 
      ViewState to reflect that update otherwise subsequent saves will show an
      erroneous contention error.
   */                
   oSystemModStamp = [select SystemModStamp from BDR__c where id =:bdrid].systemModStamp;
   return null;

   // This option is a full page reload, but shows the correct tab 
   //return returnToEdit('tabIncome');
                 
 }

 public pageReference cancel()
 {
   if (bdr.id==null) {
     return ctl.cancel(); 
     }
    
   PageReference pr=new PageReference('/'+ bdr.id);
   pr.setRedirect(true);

   return pr; 
 }

/*
  *  For every service linked to the BDR, there is an associated Evidence For Needs record
  *  with information why the service is needed 
  */
 private Integer doSaveEvidenceForNeeds() {
 
    if (BdrWrapper==null) { return 0; }
    if (BdrWrapper.hasServices=='No') { return 0; }
    
    Integer i = 0;        
    try {    
        if (!BdrWrapper.services.evidenceForNeeds.isEmpty())
            system.debug('Evidence For Needs Size:' + BdrWrapper.services.evidenceForNeeds.size());        
            upsert BdrWrapper.services.evidenceForNeeds;
    }
    catch (Exception e) {
          System.debug('Upsert Evidence For Needs');          
    }

    return 0;
  }

/*
 *    This method is called when the user clicks the 'Edit Service' button on the Services Tab in BDR_Edit_Tabbed
 */
public PageReference editService()
{   
    
    System.debug('**********************************  NOW IN editService method'+ serviceId); 

    if (serviceId==null) { 
        System.debug('Edit Service - ServiceId is null');
        return null; 
    }
    
    // Save the BDR and all associated records before editing a linked Service
    Boolean saveSuccessful = false;
    saveSuccessful = saveRecords();
    
    if (saveSuccessful) {
        System.debug('Records saved for Edit Service action'); 
        PageReference pr = new PageReference('/apex/BDR_Service_Add_Update?id=' + serviceId + '&bdrid='+bdrid);
        pr.setRedirect(true);   
        return pr;
    
    }  else {
        System.debug('Records NOT  Saved for Edit Service action');
    
    }
    
    return null;  
        
}



 /* Remove a service. rid is the id of the services__c 
    This action will also remove any allocation records associated with the bdr
 */   
 public void removeService()    
 {      
    system.debug('Removing Service from BDR:' + rid);   
    
    if (rid==null) {
        system.debug('Rid is Null');
        return;
    }
    
    // Save the BDR and all associated records before editing a linked Service
    Boolean saveSuccessful = false;
    saveSuccessful = saveRecords();
    
    if (saveSuccessful) {
        System.debug('Records saved for Remove Service action'); 
        bdrWrapper.removeService(rid,false);        
    }  else {
        System.debug('Records NOT  Saved for Remove Service action');
    
    }
    
    return;
     
 }
 
 public void deleteService()
 { 
    system.debug('Removing Service from BDR:' + rid);   
    
    if (rid==null) {
        system.debug('Rid is Null');
        return;
    }
    
    // Save the BDR and all associated records before editing a linked Service
    Boolean saveSuccessful = false;
    saveSuccessful = saveRecords();
    
    if (saveSuccessful) {
        System.debug('Records saved for Delete Service action'); 
        bdrWrapper.removeService(rid,true);        
    }  else {
        System.debug('Records NOT  Saved for Delete Service action');
    
    }
    return;
 
 }
 
 //Cancel an update on an individual Evidence for Needs record
 public void cancelUpdateEvidence() {
    
    evid=null;

    /*Refresh the services data, so that any updates are removed from the session
      The services panel should be reloaded as well */
    bdrWrapper.fetchServices();
 }


 //Update an individual Evidence for Needs record
 public void updateEvidence()
 {
 
    System.debug('Updating Evidence :' + evid); 
    for (Evidence_For_Need__c e : BdrWrapper.services.evidenceForNeeds)
    {
          if (e.id==evid) {update e;}      
    }  
    evid=null;
    
 }       

 public void addServices()
 {
   /* Refresh the BDRWRapper services */
   bdrWrapper.fetchServices();
 }   


    

 /*A null action that does nothing. Useful for Javascript action functions that do a re-render in the page*/   
 public pageReference clicked()
 {
     return null;
 }  
     
 public pageReference doDelete()
 {
 
    /*Check the user has access to do this. That is necessary because
      BdrUtils runs without sharing 
      
      The action should not be visible. This is a second level test.    
      The update will throw a nasty error if they user does not have access
      rather than returning a silent fail using accessObj.hasDeleteAccess()
      
      */
    update bdr;
 
    BdrUtils.deleteBdr(bdrid);         
    
    //Schema.DescribeSObjectResult dsr = BDR__c.SObjectType.getDescribe();
    //PageReference pr = new PageReference('/' + dsr.getKeyPrefix());

    //TODO how to highlight the correct tab ?
    PageReference pr = new PageReference('/apex/BDR_Search');
    pr.setRedirect(true);
    return pr;     
 
 }   
 
 public void validateSubmit()
 { 
     bdrWrapper.validateBDR();         
 }
    
  /*
   *   Returns true if the 'Request Initial Acceptance' button should be displayed
   */  
  public Boolean show_Initial_Acceptance_Action {
        get { 
             if (isApprovalInProcess()) {return false;}
             if (bdr.Status__c != BDR_STATUS_DRAFT) {return false;} 
             if (userHasAdminRights) { return true; }
             return (bdr.OwnerId == UserInfo.getUserId());
        }
        set; 
        }  

 public Boolean showDeleteAction {
        get { 
             if (isApprovalInProcess()) {return false;}
             if (userHasAdminRights) { return true; }
             if (bdr.Status__c != BDR_STATUS_DRAFT) {return false;} 
             return (bdr.OwnerId == UserInfo.getUserId());
           }
        set; 
        }  

 public Boolean showCloneAction {
    
    get {
        return CustomUtils.hasUserAccess(bdr.id, UserInfo.getUserId(), 'Edit');
    }
    
 }
         

  /*
   *   Returns true if the 'Request Approval of Final Proposal'' button should be displayed
   */     
 public Boolean show_Request_Approval_Final_Proposal_Action {
        get { 
             if (isApprovalInProcess()) {return false;}
             if (bdr.Status__c != BDR_STATUS_ACCEPTED) {return false;} 
             if (userHasAdminRights) { return true; }
             return (bdr.OwnerId == UserInfo.getUserId()); 
             }
        set; 
        }




       
 public boolean InApprovalWorkflow{
     get { return isApprovalInProcess();  }
 }            
 
/*          This button will push the BDR through the final workflow and then 
            mark it successful when all approvals are granted.             
 */                                   
 public boolean showRequestFinalApprovalAction {
        get { 
              if (isApprovalInProcess()) {return false;}
              if (bdr.Status__c != BDR_STATUS_PROPOSED) {return false;} 
              if (userHasAdminRights) { return true; }
              return (bdr.OwnerId == UserInfo.getUserId());
                 
             }
      
       }
    

/*          This button will change the owner of linked Services that are Draft or Accepted
            to enable the local services team to edit them.              
 */                                   
 public boolean showReleaseServicesForEditAction {
        get { 
              if (isApprovalInProcess()) {return false;}
              if (userHasAdminRights) { return true; }
              return (bdr.OwnerId == UserInfo.getUserId());
                 
             }
      
       }

 public pageReference doReleaseServicesForEdit()
 {
    if (BdrUtils.setServiceAdminOwners(bdr)>0) {
        
        String s = bdr.Notifications_Pending__c;
        if (s==null) {
             s = 'SVC_ACCESS '; 
        }
        else {    
        
           if (!s.contains('SVC_ACCESS ')) { s =+ 'SVC_ACCESS ' ; }  
        
        }

        bdr.Notifications_Pending__c = s;
        bdr.Notification_Action__c='Y';
        update bdr;         

    }
    return null;
 }      


    
     /*          BDR's can only be marked successful from the proposed status
            An approval in Acceptance is part of a tender, so cannot be marked
            successful unless the tender response has been approved
 */        
        public boolean showSuccessActions {
        get { 
              if (isApprovalInProcess()) {return false;}
              if (bdr.Status__c != BDR_STATUS_PROPOSED) {return false;} 
              if (userHasAdminRights) { return true; }
              if (bdr.BDM__c == UserInfo.getUserId()) { return true; }
              return (bdr.OwnerId == UserInfo.getUserId()); 
              }
       }

                              


 /*         BDR's can be marked successful from Draft status by Sys Admins
            This supports migration from the old BDC system
 */                                   
 public boolean showAdminSuccessfulAction {
        get { 
              if (isApprovalInProcess()) {return false;}
              if (!userHasAdminRights) {return false;}
              if (bdr.Status__c == BDR_STATUS_DRAFT || bdr.Status__c == BDR_STATUS_ACCEPTED) {return true;} 
              return false;
             }
       }

 public boolean showDeclinedAction {
        get { 
              
              if (isApprovalInProcess()) {return false;}
              if (!DRAFT_ACCEPTED_PROPOSED.contains(bdr.Status__c)) {return false;} 
              if (bdr.post_approval_changes__c=='Yes') return false;
              if (userHasAdminRights) { return true; }
              
              // BDM's shoudld be able to decline BDRs in Draft (which they may have rejected) 
              // Also check they have edit access to the BDR.
              if (currentUserCanEdit() &&               
                            bdr.Status__c == BDR_STATUS_DRAFT && 
                            bdr.BDM__c == UserInfo.getUserId()) { return true; }
              
              return (bdr.OwnerId == UserInfo.getUserId());
              
              }  
       }
 

 public boolean showAddServicesAction {
       get { 
                          
              if (isApprovalInProcess()) {return false;}
              if (!DRAFT_ACCEPTED_PROPOSED.contains(bdr.Status__c)) { return false; } 
              if (bdr.post_approval_changes__c=='Yes') return false;
              if (userHasAdminRights) { return true; }
              return (bdr.OwnerId == UserInfo.getUserId());
             
           }
       set;      
       }
  
    public boolean canCurrentUserEdit {
        get {             
             if (isApprovalInProcess()) {
                 return (currentApprovalActor); 
             }
                          
             return (currentUserCanEdit()) ;
           }
       set;      
       }
  
  
   /*
    *  Returns true if the 'Create Contract Extension' button should be displayed
    *  Contract must have Start and End Dates
    */
    public boolean showCreateExtensionAction {
       
       get {
            if (hasContract!='Yes' || 
                isBdrLive()==false ||
                bdrWrapper.contract.Start_Date__c ==null ||
                bdrWrapper.contract.End_Date__c ==null
                ) {
                    return false; 
            }
            
            /* If the contract has already been extended, subsequent extensions should be on the 
               BDR that is the Extension, so that dates are applied correctly  */
            
            if (!bdr.linked_BDRS__r.isEmpty() || isApprovalInProcess()) { 
                return false ; 
            }
            
            return true;
       }
       set;
              
 }

  /*
    *  Returns true if the 'Update Contract' button should be displayed
    *  Only available in status 'Live'
    */
    public boolean showUpdateContractAction {
       
       get {
             if ( isBdrLive()==false || hasContract=='No' ) { return false; }   
             if ( userHasAdminRights ) { return true; }    
            return CustomUtils.hasUserAccess(bdr.id, UserInfo.getUserId(), 'Edit');            
       }
       set;
              
 }  

 
  private boolean isBdrLive() {

        return bdr.Status__c == BDR_STATUS_LIVE;
      }
  
 
  private PageReference updateStatus(String status)
  {

         bdrWrapper.updateStatus(status);
         PageReference pr=new PageReference('/'+ bdr.id);
         pr.setRedirect(true);
    
         return pr;  
 } 
 
 public PageReference setDeclined()
 {
    
   String sReasonsString = '';
   
    if (reasons_declined_selection!=null && reasons_declined_selection.size()>0) {
       
        // Add the selected notifications to the String of pending notifications
        for (String element : reasons_declined_selection) {
                  if (sReasonsString.indexOf(element) < 0 ) {
                        sReasonsString = sReasonsString + element + ' ';
                  }
        }   
    }
    
    // Update the selected notifictions pending into the BDR 
    bdr.Reasons_Declined__c = sReasonsString;
    
    
        return updateStatus(BDR_STATUS_DECLINED);
 } 
 
 public PageReference setUnsuccessful()
 { 
        return updateStatus(BDR_STATUS_UNSUCCESSFUL);
 } 


 /**  If post_approval_changes is set to 'Yes' submit into workflow  approval. Otherwise mark the BDR Live
  *    This is a bit confusing as the button is called 'Set Successful' but the status name is 'Live'
 */
 public PageReference setSuccessful()
 {
       if (bdr.Post_Approval_Changes__c=='Yes') {        
          
          return submitForApproval();
       
       } else {         
            
          return updateStatus(BDR_STATUS_LIVE);
       }
 } 
 
  /** @description   Set the BDR Successful without approval
                     This action is only available to admins
 */
 public PageReference setSuccessfulAdmin()
 {           
       return updateStatus(BDR_STATUS_LIVE);
 } 
 
private String getComponentList() {
    
    String s = '';
    try {
                if (hasServices=='Yes') s=s+'S ';
                if (hasPartner=='Yes') s=s+'P ';
                if (hasIncomeBlock=='Yes') s=s+'I ';
                if (bdr.Tender__c=='Yes') s=s+'T ';
                if (hasBid=='Yes') s=s+'B ';
                if (hasContract=='Yes') s=s+'C ';
    } catch (Exception x) {
        return s;
    }
    
    return s;
    
 }
 
    // Test if there is an open approval process step for this object id 
   private boolean isApprovalInProcess()
   {
      return CustomUtils.isApprovalInProcess(bdrid);            
   }
   
   // Test if the current user is an Approval Actor
   public boolean currentApprovalActor {
        get {
                if (!CustomUtils.isApprovalInProcess(bdrid)) { return false ;}
                return CustomUtils.isCurrentApprovalActor(BDR.id, UserInfo.getUserId());
        }
        set;
   }
   
   private boolean currentUserCanEdit() {
    
         /*Sys Admins should be able to edit all records in all Status'*/
         if (userHasAdminRights) { 
                return true; 
         }
    
         /* Normal users should not be able to edit BDRs in these Status's */
         if ( bdr.Status__c ==BDR_STATUS_DECLINED ||
              bdr.Status__c ==BDR_STATUS_UNSUCCESSFUL ||
              bdr.Status__c ==BDR_STATUS_LIVE)  
              { return false; }
    
         return CustomUtils.hasUserAccess(bdr.id, UserInfo.getUserId(), 'Edit');
   }
  
   /* App Admins have global access to make edits at all points in the BDR lifecycle */
   public boolean userHasAdminRights {
    
        get {
                if ( userSysAdmin ) { return true; }
                boolean b = CustomUtils.isUserInGroupName(UserInfo.getUserId(), 'BDR Administrators');
                system.debug('BDRControllerExtension : User is AdminRights :' + b); 
                return (b);
        }
        private set;            
   }
  
  
   public boolean userSysAdmin {
          get { 
                return CustomUtils.isModifyAllData(UserInfo.getUserId());
          }
          private set;   
   }     
  
}