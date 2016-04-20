public class BDRWrapper
{
    /***********************************************************************************************************
    *
    *   @author        :  gary.grant@conseq.co.uk
    *   @date           :  March 2013
    *   @description :  A wrapper class for the BDR
    *                          Contains all the objects related to the BDR.
    *                          A collection of utility methods for making updates across the record sets. 
    *   
    ************************************************************************************************************/
   

    public static final Set<String> ACCEPTED_PROPOSED = new Set<String>{'Accepted', 'Proposed'};
 
    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_ACCEPTED = 'Accepted';
    public static final String STATUS_PROPOSED = 'Proposed';
  
    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_LIVE = 'Live';
    public static final String STATUS_UNSUCCESSFUL = 'Unsuccessful';
    public static final String STATUS_DECLINED = 'Declined';
   
    public String bdrid;                          /* The id of the primary BDR */

    public String getBdrid() {
         return bdrid;
     }     
    
     /* 
     
        The setter method will initialise the wrapper with content related to the wrapper. 

        This is used in the Workflow Rules that send BDRs with PDF attachments  
        It's a setter because the AssignTo var on the Component used to generate 
        PDFs expects a setter method to assign the bdrid
        
     */   
     public void setBdrId(String bdrid) 
     {
         this.bdrid = bdrid;
         this.bdr= (BDR__c)CustomUtils.objectWithAllFields('id', bdrid, Schema.sObjectType.BDR__c);   
         
         if (this.bdr!=null) {
            initFinancialYearsList();
            fetchServices();
            fetchIncomeData();
            fetchContract();
          }         
     }   

     /* The primary BDR*/
     public BDR__c bdr {get;set;}
     


     /* Semi colon delimited list of Fiscal Years that define the calendar scope of the proposal In the format 2013/14,2014/15
        The field is a standard Picklist, so addtional years must be added manually and previous years should not be removed
     */
     public List<String> fiscalYears {get;set;}
        
     public BD_Contract__c contract {get;set;}         /* A contract linked to the BDR. May be null */   
     
     public String hasContract {get;set;}

     /* The 15 Chr version of the id is used in the url in BDR_Contract_Read.component */
     public String contractId15 {
         get { if (contract==null) { return null; }             
               String cid = contract.id;
               return cid.left(15); }
         set; 
         }

     /* A Block of Income that will fund the BDR. There is only one Income Block per BDR. 
         The IB represents the total amount of Income available from the Income Source */
     public Income_Block__c incBlock {get;set;}
     /* 
      * An Income Block covers multiple Financial Years.  Each Year is represented by an Income Block Period 
      *
      */
     public List<Income_Block_Period__c> incomeData {get;set;}
     public String hasIncomeBlock {get;set;} 

     /* A Utility class that wraps a list of Dementia Connect Services */
     public BdrServiceWrapperList services {get; set;}
     
     public String hasServices{ 
            get {
                if (services==null) return 'No';
                if (services.svcRecords==null) return 'No';
                if (services.svcRecords.isEmpty()) return 'No';
                return 'Yes';     
            }     
            set;
      }
     

     /* The list of BDRs that are linked to the same Services and span one or more of the same Financial Years */
     public List<BDR__c> dependentBdrs {
            get { 
                return BdrUtils.getDependentBdrs(this);
            }
            set;
            }     
     
     /* Shows if the BDR has a partner organisation defined. 
        A partner is an organisation sharing in the delivery of the services, and potentiallyassisting with securing funds */
     public String hasPartner {
            get { 
                if (bdr.Partnership_Status__c == null) return 'No';
                return 'Yes';
            }
            set;
            }

     /* Is a bid involved in securing the Income Block */       
     public String hasBid {
            get { 
                if (bdr.Bid_Status__c == null) return 'No';
                return 'Yes';
            }
            set;
            }

     /* Shows whether any of the funds from the Income Block Periods
        have been allocated to any of the Funding Requirements linked to the Services
        Funds from the Income Block can only be allocated to Funding Requirements
        within the Fiscal Periods scope of the BDR */        
     public String hasAllocation {
            get {
            
            /* No Services, so therefore no allocation */
            if (hasServices=='No') return 'No';
            
            /* Check for any Allocation records in the Services wrapper */
            Decimal i = 0;
            if (services.allocations==null) return 'No';
            
            /* Allocations exist, check for total greater than 0 */
            for ( Fund_Allocation__c fa : services.allocations ) {            
                        i=i+(fa.Allocation_Amount__c!=null ? fa.Allocation_Amount__c : 0);            
            }
            if (i>0) { return 'Yes'; }
            
            /* Allocations exist, but total to 0 */
            return 'No';             

            }
            set ;
            }            
          
     /* Container for form validation messages */
     public String[] validationMessages {
         get { return validateBDR(); }             
         set;             
     }
     
     /* Boolean defining if Fiscal Years are defined */
     public Boolean hasFiscalYears { 
        get { return fiscalYears.isEmpty(); }
        set; 
     }               

     /* Refresh the Financial Years and update associated data  */
     public Boolean syncFiscalYears(boolean bRefresh) {        
        
                BDRUtils.syncForUpdatedFiscalPeriods(this);     
                if ( bRefresh) refreshData();       
                return true;
     } 
     
     /* Empty Constructor. If this class is defined as the controller
        for a component, the constructor will be called
        before the getters and setters, so no data
        will be available to set the objects up

        Put the code for setting the wrapper up in one of the setters
        (see set BdrId)
      */
      public BDRWrapper()
      {
        // Nothing to do. The wrapper is empty on construction....
      }

     
     /* Constructor, takes a BDR as a parameter */
     public BDRWrapper(BDR__c bdr)
     {
         this.bdr = bdr;
         this.bdrid = bdr.id;         
         initFinancialYearsList();
         refreshData(); 
     }
     
     /* Refresh the Services, Income Data and Contract */
     public void refreshData()
     {
        fetchServices();
        fetchIncomeData();
        fetchContract();        
     }
     
     /* Get the Fiscal Years string and convert to a List<String> */
     private void initFinancialYearsList()
     {    
       if (bdr.Fiscal_Years__c!=null) {
            fiscalYears = bdr.Fiscal_Years__c.split(';');
       } else { 
            fiscalYears = new List<String>(); }    
     }   

     
     /* Create a new Income Block for this BDR */
     public boolean addIncome()
     {
       initFinancialYearsList();  
       if (fiscalYears.isEmpty()) return false;
       if (incBlock!=null) return false;

       String incSourceId=bdr.Income_Source__c;
       Map<String, Object> mapInc = BdrUtils.addIncomeBlock(bdrid, incSourceId, fiscalYears);


       /* Fetch the records back out of the database and refresh them into the BDR
          Not doing this means they fail to initialise properly on the first time edit
       */ 
       fetchIncomeData();         
       fetchServices();     
       return true;
     }
     
     /* Get the Income Block and Income Block Periods from the database */ 
     public void fetchIncomeData()
     {
       incBlock=(Income_Block__c)CustomUtils.objectWithAllFields('BDR__c', bdr.id, Schema.SObjectType.Income_Block__c); 
       if (incBlock==null) {    
           hasIncomeBlock='No';
           return; 
       }

       hasIncomeBlock='Yes';     
    
       // Initialise the Income Block object array
       incomeData = new List<Income_Block_Period__c>();    
       incomeData = [select Total_Amount__c, Fiscal_Year__c, Year_Sequence__c, Risk_factor__c, Risk_description__c, Essential_Support_amount__c, Local_Support_amount__c  
                 from Income_Block_Period__c where Income_Block__c = :incBlock.Id
                 order by Fiscal_Year__c];
     
     }
     
    /* Get the contract from the database */ 
    private void fetchContract()
     { 
       contract = (BD_Contract__c)CustomUtils.objectWithAllFields('BDR__c', bdr.id, Schema.sObjectType.BD_Contract__c);    
       hasContract = (contract==null ? 'No':'Yes');
     }
         
     /* Remove a Service from the BDR 
        This will also remove and delete any Fund Allocations already defined */
     public boolean removeService(String svcId, boolean bDelete)
     {
        /* Removal of a service can only be done via the
           VF page interface. Profiles do not allow deletion of the records by other UI mechanisms
           bDelete will delete the service (unless it is in Status 'Open', in which case the
           flag is ignored          
        */ 
        
        String incBlockId=null;
        if (incBlock!=null) { incBlockId = incBlock.Id; }
        boolean b = BdrUtils.removeService(bdrid, incBlockId, svcId, bDelete);
        
        /* Refresh the Services and IncomeData */    
        fetchServices();
        fetchIncomeData();
      
        return b;
          
     }    
         
     /* Get all the Services associated with the BDR 
         Services are wrapped in a ServiceWrapperList which contains ServiceWrappers
         
        Those include the Service, Income Allocations and Evidence for Needs
     */    
     public void fetchServices()
     {         
     
       // Initialise the Services and Evidence for Needs arrays
       services = new BdrServiceWrapperList(bdrid);
       
       hasServices=((services.svcRecords==null || services.svcRecords.isEmpty()) ? 'No' : 'Yes');  
     }        
     
    /* Update the Status of the BDR */
    public void updateStatus(String sStatus)
    {                
       /* The call to update the BDR will fire the trigger that syncs the rest of the records
           That update code is in a Trigger because in certain cases the Status of the 
           BDR will be updated by a Workflow Rule and not through this code.  
       */ 
       bdr.Status__c = sStatus;    
       update bdr;
       
       /* Refresh all the data */
       fetchServices();
       fetchIncomeData();
       fetchContract();
    }
    
    /* Ensure the owner of the Contract matches the owner of BDR */
    public boolean syncOwner()
    {       
        
      if (contract!=null) {
         contract.ownerId=bdr.ownerId;  
         update contract;
      }                    
      return true;
    }
    
    /*   This method is called by the Trigger on BDR__c. 
     *   This is  public method because  that allows workflow actions to update the BDR and fire the sync
     *   Update the Status__c field on the Contract, Income Block and Service records associated with the BDR
     * 
     *  There's no "Proposed" status for Services__c. 
     *   The Status's are Draft / Pending / Open / Closed / Replaced / Suspended / Accepted / Declined             
     */      
    public boolean syncAssociatedStatus(String newStatus)
    {
        
        system.debug('Now in BDRWrapper syncAssociatedStatus and newStatus ='+newStatus);

         /* To reduce the number of database updates, records are put in a list of SObjects and updated in a single operation at the end of the process */
        List<SObject> recordList = new List<SObject>();
        
        // Update the Contract status
        if (contract!=null) { 
                   system.debug('Now in BDRWrapper syncAssociatedStatus updating the contract');
                   contract.Status__c=newStatus; 
                   recordList.add(contract);
         }
         
       /* Why do the Income Block and Fund Allocation records need to have a Status value   
        * So that the calculation of cost coverage fields on the service cost (Funding_Requirement__c) 
        * record can distinguish between linked income that is confirmed and linked income that is still only potential.  
        * That is shown in the columns on the allocation screen of the BDR as well.  */

        // Update the Income Block status
       if (incBlock!=null) {
            System.debug('Now in BDRWrapper syncAssociatedStatus Updating the income block ');
            incBlock.Status__c=newStatus; 
            recordList.add(incBlock);            
       }
      
      
      /* Update the status of the Fund Allocations (Income Allocations)
         There may be Income Alloction records created in the 
         BDRServiceWrapperList construction (specifically in the BDRFundReqWrapper constructor)
         
         These records ensure the in-memory data model for the BdrServiceWrappers are complete
         but are not relevant if there is no income, so should not be saved to the database 
         if there is no income.         
         */
      
      if (services.allocations!=null && incBlock!=null) {         
        System.debug('Now in BDRWrapper syncAssociatedStatus updating the Fund Allocation records');
        for (Fund_Allocation__c fa : services.allocations) {
           fa.Status__c=newStatus;
           recordList.add(fa);
        }            
      }    
       
       // Action if the new status is PROPOSED or ACCEPTED
       if (newStatus.equalsIgnoreCase(STATUS_PROPOSED) || 
             newStatus.equalsIgnoreCase(STATUS_ACCEPTED))  {
            
                System.debug('BDRWrapper Service Update syncAssociatedStatus CHECKPOINT 1');
            
                if (services.svcRecords!=null) {
                        if (newStatus.equals(STATUS_PROPOSED)) {
                                System.debug('BDRWrapper Service Update syncAssociatedStatus CHECKPOINT 2');
                                newStatus = STATUS_ACCEPTED;                     // The 'Proposed' status does not apply to Services
                         }
                        
                         for (Services__c svc : services.svcRecords) {
                                    System.debug('BDRWrapper Service Update syncAssociatedStatus CHECKPOINT 3');
                                    if (svc.service_status__c==STATUS_DRAFT) { 
                                           svc.service_status__c=newStatus;
                                            System.debug('BDRWrapper Service Update syncAssociatedStatus CHECKPOINT 4');
                                           recordList.add(svc);
                                    }
                         } 
                   }        
       }
       
       //Action if the new Status is Declined
       if (newStatus.equalsIgnoreCase(STATUS_DECLINED))  {
       
           /* Only set services to Declined if no other BDR's are open */                  
           List<BDR__c> deps = BdrUtils.getDraftDependentBdrs(this);    
           if (deps.isEmpty()) {
            
                if (services.svcRecords!=null) {
                       
                    for (Services__c svc : services.svcRecords) {
                        if (svc.service_status__c==STATUS_DRAFT) { 
                            svc.service_status__c=newStatus;
                              recordList.add(svc);
                        }
                    } 
                }       
           }
       }
                 
       System.debug('BDRWrapper Service Update syncAssociatedStatus CHECKPOINT 5');
        
       //This is useful debug code that shows the records being updated 
       for (sObject obj : recordList) {
            System.debug('BDRWrapper record update ' + obj.getSObjectType());
            if (obj.id!=null) {
                System.debug('BDRWrapper record update ' + obj.get('Id'));
            } else {
                System.debug('BDRWrapper record update, record id IS NULL' );
            }
       }
       
       System.debug('BDRWrapper record update List size is ' + recordList.size());
       if (recordList.size()>0) {
           update recordList;   
       }            
       
       return true;

    }
       
/* Add a Service to the list of Services */    
public static boolean addService(String bdrid, String svcId)
    {
      /*
        Create a new link record that links there referenced Service to the BDR            
        This method will trap and NOT throw an error if a duplicate is found
        allowing the user to add multiple times, without causing a UI error            
      
        This is a Static method so it can be called without instantiating the object

        BDC profiles cannot add create this record type. Call out to the Utils method
        which is without sharing. 
         
        This ensures that services can only be added through this interface, and not 
        through the standard interface
      
      */      
      return BdrUtils.addService(bdrid, svcid);

    }
    
    /* Add a contract to the BDR 
         
    */
    public boolean addContract(String ContractHelpTextId)
    {
      contract = BdrUtils.addContract(bdr, incBlock, ContractHelpTextId);        
      
      if (contract!=null) {
            hasContract='Yes';
            return true;
      }
      
      return false;
    
    }
      
     /*  Validate the BDR 
      *
      * Ensure there is sufficient data filled in to allow Submssion For Approval 
      * Ensure that the selected "Required Approval Level" is in line with the Income
      */ 
     public String[] validateBDR()
     {
       String[] e = new String[]{};   
       if(BDR.Reporting_Implications__c==True && BDR.Please_specify__c==null){
        
           e.add('You must enter reporting implications in detail.');
    
    
        }
       
       if (bdr.A2D_Locality__c == null ) {
             e.add('Please select the Locality');             
        }    
    
        /* Some of these options are only relevant  for full approval */
        
       /* Add an error to the BDR if it fails validate */
       if (bdr.Status__c !=STATUS_DRAFT && isSelectedApprovalLevelCorrect()==false) {
           e.add('The Required Approval Level you have selected is not high enough for the level of income you have entered, based on the greater of Actual Income and Estimated Income Required.');             
       }
       
       if (bdr.Status__c !=STATUS_DRAFT && getApprovalLevel()>2 && bdr.Operations_Director__c==null) {
          e.add('Please specify the Operations Director ');                    
       }       

       if (bdr.BDM__c==null) {
          e.add('Please specify the BDM');                    
       }      
       
       if (bdr.Status__c !=STATUS_DRAFT && bdr.HR_Advisor__c==null) {
          e.add('There is no HR Advisor for the selected Area, ' + bdr.Area__c + ', set up in the BDR Organisations list.');                    
       }     

       if (bdr.Operations_Manager__c==null) {
          e.add('Please specify the Operations Manager. (The Operations Manager will be notified when you submit for Initial Acceptance)');                    
       }       

       
       if (bdr.Area_Manager__c==null) {
          e.add('Please specify the Regional Operations Manager');                    
       }       

       if (bdr.Total_Value__c==null) {
          e.add('Please enter the Estimated Income Required');                    
       }       

       if (bdr.Summary__c==null) {
          e.add('The Proposal Summary is not specified');                    
       }       

       if (bdr.Strategic_Objectives_met__c==null) {
          e.add('Stategic Ambitions Met is not specified');                    
       }       

       //Check income 
       if (bdr.Actual_Value__c > 0) {

          for (Income_Block_Period__c ibp : incomeData) {
           if (ibp.Total_Amount__c==null) { 
                e.add('Income (at least 0) must be specified in each financial year'); }                   
          }
          
          if (bdr.Income_Source__c==null) 
            { 
                e.add('Income source must be specified for BDRs with income'); 
            }

       }
       
       if (hasServices=='No' && bdr.Status__c !=STATUS_DRAFT) {
        
            /* There is no sense in processing a BDR beyond Initial Acceptance if there are no services */
            e.add('Please add the services you are proposing.');
        
       }
       
       //Check services
       if (hasServices=='Yes') {
          

          /* Calculate the total number of records required Services * Number of Years 
             There should be that number of Funding Requirement records (one for each Service for each Year) 
          */
          Integer i = services.svcRecords.size() * fiscalYears.size();

           if (services.frWrappers==null || services.frWrappers.size() <> i) { e.add('Null value alert! All Services must have a funding requirement of at least 0 for all relevant financial years'); }         


           /* Fund Allocations must exist for each Service for each period */  
           if (bdr.Actual_Value__c>0) {
               if (services.allocations ==null || services.allocations.size() <> i) 
                        { e.add('Null value alert! All Services must have a fund allocation of at least 0 for all relevant financial years'); 
                }                                      
               if (services.allocations!=null) {                
                   for (Fund_Allocation__c fa : services.allocations) {
                       if (fa.Allocation_Amount__c==null) { 
                            e.add('Fund Allocation (of at least 0) must be specified in each financial year for all included services'); 
                            }                   
                       if (fa.id==null) { e.add('Not all records have been saved to the database. Please re-save the BDR and try again'); }                   
                   }   
               }
           }
       }

       if (bdr.Partnership_Status__c!=null && bdr.Partnership_Status__c!= '' & bdr.Partnership_Status__c!='None') {
          if (bdr.PartnerType__c==null){ e.add('Partner not specified'); }        
       }
       
       if (bdr.Status__c !=STATUS_DRAFT && bdr.Tender__c=='Yes' && hasContract!='Yes') {            
            e.add('You have specified this is a tender. Please enter contract details.');           
       }
       
       if (hasContract=='Yes') {
        
           // Only check the contract after Initial Acceptance. The BDM may approve without this detail. 
           if (bdr.Status__c!=STATUS_DRAFT) {    
           
                if (contract.Start_date__c==null || contract.End_date__c==null) {
                    e.add('Please enter dates for the Contract');
                }
                
                if (contract.Start_date__c > contract.End_Date__c) {
                    e.add('Contract start date cannot be after Contract end date');
                }         
           }            
       }
       
       

       return e;     
     }
 
     /* 
      * Get the index value as a number for the Required Approval Level selected
      *
      * The 'Required Approval Level' has 7 picklist values with different approval levels
      * This generally depends on the Income but can also be mandated by the Commissioners
      * 
      * */
     private integer getApprovalLevel()
     {
     
       String selectedApprovalLevel = bdr.Required_Approval_Level__c;
    
       List<Schema.PicklistEntry> lis = BDR__c.Required_Approval_Level__c.getDescribe().getPicklistValues();
       Map<String,integer> mapEntries = new Map<String,integer>();
       Integer n =0;
       for (Schema.PicklistEntry e : lis) {
           n++;
           mapEntries.put(e.getValue(),n);
       }  
     
       if (mapEntries.containsKey(selectedApprovalLevel)) 
            { return mapEntries.get(selectedApprovalLevel); }
       return 0;     
     
     }



 
     /* 
     
        Returns true if validation is passed
        Returns fails if 'Required Approval level' is too low for the income

        
        These need to be kept in sync with the "Approved Alzheimer's Society Schedule of Delegated Authoriies" 
        for Service Contract Income on Arena
        
        Estimated Income is included in the validation to ensure users do not enter 
        a large estimate and forget to put the income itself in, or in the case
        where this is a speculative BDR with no confirmed income at this point.  
         
        28-06-2014 If there is no contract, does the BDR need to go through the Required Approval Level at all ?
        Once there is an actual Income Value, the estimate should be updated or removed.
         
     */
     private boolean isSelectedApprovalLevelCorrect()
     {
        
      /* Take the larger of the two figures. One (BDR.Total_Value__c) is an estimate and one is the 
         actual (incBlock.Total_Amount__c). The estimate may also represent the contract including 
         any potential extensions that are at the discretion of the Commissioner
      */   
        
      if ( bdr.Required_Approval_Level__c == null ) { return false; }  
      Decimal tIncome = bdr.Total_Value__c;
                 
      // The Income Block object is created when you add income to the BDR
      if (incBlock!=null && incBlock.Total_Amount__c > tIncome) { 
          tIncome = incBlock.Total_Amount__c;
      }       

      if (tIncome==null) { return true; }   

      // Get the selected 'Required Approval Level' as an integer  (1 - 7)
      Integer level = getApprovalLevel();
      System.debug('Now in validateRequiredApprovalLevel and level is' + level);
       
      // 1. Operations Manager can approve up to ?50,000
      if (tIncome<50001 && level>0) {
          return true;                       
      }
       
      // 2. Regional Operations Manager can approve up to ?100,000  
      if (tIncome<100001 && level>1) { 
           return true;                
      }
     
      // 3. Operations Director  can approve up to ?200,000  (There is one for each Region)
      if (tIncome<200001 && level>2) {
            return true;                       
      }

      // 4. Director of Operations (Kathryn Smith)          can approve up to ?350,000
      //    (( Director of Corporate Resource (Matt Sellen) can approve up to ?350,000 but we're ignoring that)
      if (tIncome<350001 && level>3) { 
           return true;                       
      }

      // 5. CEO (Jeremy Hughes) can approve up to ?450,000
      if (tIncome<450001 && level>4) { 
           return true;                       
      }     
      
      // 6. Joint CEO and Director of Corporate Resources can approve up to ?600,000
      if (tIncome<600001 && level>5) { 
         return true;                       
      }
       
      // 7. Board Member over ?600,000
      if (tIncome>600000 && level>6) { 
         return true;                       
      } 
       
       
      return false;
     
     }
 
    /*      Compute the totals for all the associated services and fund requirements.
            The FundReqWrappers compute the "other allocations"
    */  
    public Decimal totalFundingRequirement {
        get {
            Decimal d = 0;          
            for (BdrFundReqWrapper frw : services.frWrappers) {
                if (frw.freq!=null && frw.freq.total_amount__c !=null) {
                    d= d+ frw.freq.total_amount__c;
                }
            }
            return d;
        }
        set;
    }
    
    public Decimal totalAllocation {
        get {
            Decimal d = 0;      
            for (BdrFundReqWrapper frw : services.frWrappers) {
               d= d+ (frw.allocation.Allocation_Amount__c!=null ? frw.allocation.Allocation_Amount__c : 0);
            }
            return d;
        }
        set;
    }
    
    public Decimal totalOtherSecureAllocation {
        get {
            Decimal d = 0;      
            for (BdrFundReqWrapper frw : services.frWrappers) {
               d= d+ frw.getOtherAllocationAmount();
            }
            return d;
        } 
        set;
    }
    
    public Decimal totalOtherProposedAllocation {
        get {
            Decimal d = 0;      
            for (BdrFundReqWrapper frw : services.frWrappers) {
               d= d+ frw.getOtherAllocationAmountProposed();    
            }
            return d;
        }
        set;    
    }
 
     public String getPdfHtml()
     {
        return bdr==null ? 'null' : BdrPdfUtils.generatePdfHtml(this);
     }
     
     
         /* Bring the Income Block in line with the BDR 
    private boolean syncIncomeBlock(String sStatus, List<sObject> lis)    
    {
      if (incBlock==null) return false;
      incBlock.Status__c=sStatus; 
      lis.add(incBlock);            
      
      if (services.allocations!=null) {         
        for (Fund_Allocation__c fa : services.allocations) {
           fa.Status__c=sStatus;
           lis.add(fa);
        }            
      }        
      return true;      
    
    } */
        
    /* Update the Status of associated records to bring them in line with the BDR
    
        The Contract status is changed to "Live"
        The Income Block status is changed to "Live"
        The Fund Allocation status is changed to "Live"
        The Service records status is not changed to Live as this now happens manually
        
        Live means the BDR has been succesfully completed and should now be made live 
      
    private boolean syncAssociatedLive()
    {
        List<SObject> lis = new List<SObject>();
            
        if (contract!=null) { 
            contract.status__c=STATUS_LIVE; 
            lis.add(contract);
            }
        

        syncIncomeBlock(STATUS_LIVE, lis);
                  
                
        List<BDR__c> deps = BdrUtils.getDraftDependentBdrs(this);
        if (deps.isEmpty()) {
          
        
            for (Services__c svc : services.svcRecords) {             
                if (svc.service_status__c==STATUS_DRAFT ) { 
                          svc.service_status__c = STATUS_ACCEPTED;
                          lis.add(svc);
                }          
            }
          
  

        } else {
           
           for (Services__c svc : services.svcRecords) {
                    if (svc.service_status__c==STATUS_DRAFT) { 
                      svc.service_status__c=STATUS_ACCEPTED;
                      lis.add(svc);
                    }           
          }         
        
        }
        

       update lis;               
       return true;
       
    }

 */  


    /* Set asscociated records to relevant Status where the BDR is set to Accepted 
     *  Update the Contract Status to Accepted
     *  Update the IncomeBlock Status to Accepted
     *  Update the Service Status to Accepted

    private boolean syncAssociatedAccepted()
    {
        List<SObject> lis = new List<SObject>();
        
        if (contract!=null) { 
           contract.status__c=STATUS_ACCEPTED; 
           lis.add(contract);
         }

        syncIncomeBlock(STATUS_ACCEPTED, lis);        
         
        if (services.svcRecords!=null) {
           for (Services__c svc : services.svcRecords) {
                    if (svc.service_status__c==STATUS_DRAFT) { 
                           svc.service_status__c=STATUS_ACCEPTED;
                           lis.add(svc);
                    }
           } 
         }          

       update lis;               
       return true;
       
    }    */ 
    
    /*
     *  Update the Status__c field on the Contract, Income Block and Service records associated with the BDR
     * 
     *  There's no "Proposed" status for Services__c. 
     *   The Status's are Draft / Pending / Open / Closed / Replaced / Suspended / Accepted / Declined  
     */

    
    

    /* Set asscociated records to relevant Status where the BDR is set to Proposed 
    
    There's no "Proposed" status for Services__c. 
    The Status's are Draft / Pending / Open / Closed / Replaced / Suspended / Accepted / Declined
    
  
    private boolean syncAssociatedProposed()
    {
        List<SObject> lis = new List<SObject>();
        
        if (contract!=null) { 
            contract.status__c=STATUS_PROPOSED; 
            lis.add(contract);
            }

        syncIncomeBlock(STATUS_PROPOSED, lis);        
         
       if (services.svcRecords!=null) {
             for (Services__c svc : services.svcRecords) {
                      if (svc.service_status__c==STATUS_DRAFT) { 
                             svc.service_status__c=STATUS_ACCEPTED;
                             lis.add(svc);
                      }
            } 
       }    

       update lis;               
       return true;
       
    }    */

    /* Set associated records to relevant Status if the BDR is set to Declined 
     *     If there is a Contract, set the Contract status to Declined
  
    private boolean syncAssociatedDeclined()
    {

        List<SObject> lis = new List<SObject>();
            
        if (contract!=null) { 
            contract.status__c=STATUS_DECLINED; 
            lis.add(contract);
            }
        
        syncIncomeBlock(STATUS_DECLINED, lis);        
         
       Only set services to Declined if no other BDR's are open                   
       List<BDR__c> deps = BdrUtils.getDraftDependentBdrs(this);
       if (deps.isEmpty()) {                  
         for (Services__c svc : services.svcRecords) {
          if (svc.service_status__c==STATUS_DRAFT || svc.service_status__c==STATUS_ACCEPTED) { 
              svc.service_status__c=STATUS_DECLINED; 
              lis.add(svc);
          }
         } 
       }
       
       update lis;               
       return true;
       
    }   */ 


    /* Set asscoiated records to relevant Status where the BDR is set to Unsuccessful  
    private boolean syncAssociatedUnsuccessful()
    {

        List<SObject> lis = new List<SObject>();
                        
        if (contract!=null) { 
            contract.status__c=STATUS_UNSUCCESSFUL; 
            lis.add(contract);
            }

        syncIncomeBlock(STATUS_UNSUCCESSFUL, lis);                
         
          

       update lis;               
       return true;
       
    }*/
       
    /*TODO 
      How to handle withdrawn ? 
      Previous periods may not be affected   
    */
    
}