public without sharing class BdrUtils
{
     /*******************************************************************************************************************
     @author         gary.grant@conseq.co.uk 
        
     @date            April 2013
     
     @description  Utility class, defined Without Sharing, that has methods for managing records associated with BDRs. 
                   The class is defined as Without Sharing so that users who would not normally have access to edit 
                   the records can create and update all records associated with a BDR. BDC profile users do not 
                   normally have rights over certain parts of the BDR data. That prevents, for example, a 
                   BDR_Service_Link__c being deleted when accessing the record through the standard Dementia Connect 
                   application (which would result in a corrupted BDR data set). 
       
     ********************************************************************************************************************/   


    /**
                 @param          id  ID of the BDR to be deleted   
                 @description   Deletes a BDR and all associated records     
                                        (Contract, Income Blocks, Income Block Periods, Fund_Allocations)
    */
    
    
    public static final String BDR_STATUS_DRAFT = 'Draft';
    public static final String BDR_STATUS_LIVE = 'Live';
    public static final String BDR_STATUS_PROPOSED = 'Proposed';
    public static final String BDR_STATUS_ACCEPTED = 'Accepted';
    public static final String BDR_STATUS_DECLINED = 'Declined';
    public static final String BDR_STATUS_UNSUCCESSFUL = 'Unsuccessful';
    
    
    public static boolean deleteBdr(String id)
    {
     List<BDR__c> bdrList = [select id from BDR__c where id = :id limit 1];
     if (bdrList.isempty()) 
        return true;

     BDR__c bdr = bdrList[0];     

     List<Income_Block__c> incomeBlockList = [select id from Income_Block__c where BDR__c =:bdr.id];
     
     if ( !incomeBlockList.isEmpty() ) {
        
                List<Income_Block_Period__c> incomeBlockPeriodList = new List<Income_Block_Period__c>();
                
                Income_Block__c ib = incomeBlockList[0];
                 incomeBlockPeriodList = [select id from Income_Block_Period__c where Income_Block__c =:ib.id]; 
                
                List<Id> ibpIds = new List<id>();
                for (Income_Block_Period__c ibp : incomeBlockPeriodList) {
                    ibpIds.add(ibp.id);
                 }
        
        List<Fund_Allocation__c> fundAllocationList = [select id from Fund_Allocation__c where Income_Block_Period__c in:ibpIds];          

        delete fundAllocationList;
        delete incomeBlockPeriodList;
        delete incomeBlockList ;
     
     }

    List<BD_Contract__c> contractList =  [select id from BD_Contract__c where BDR__c =:bdr.id];   
    delete contractList;
    
    List<BDR_Service_link__c> serviceLinkList = [select id from BDR_Service_Link__c where BDR__c = :bdr.id];
    delete serviceLinkList;
    
    delete bdr;
    
    return true;

    }
    

    /* @description  Straight clone of the BDR.     
                            Retains Service links (with no income allocations). 
                            All other data is NOT copied 
                            
       @param        id the id of the BDR to be cloned
       @param        startDate the intended start date of the new BDR
       @param        estimatedDuration the duration in months of the new BDR
       @param        incomeAmount the Income for the new BDR. May be zero.               
   */
   
    public static BDR__c cloneBdr(String id, Date startDate, Integer estimatedDuration, Integer incomeAmount)
    {

     BDR__c bdr = (BDR__c)CustomUtils.objectWithAllFields('id', id, Schema.sObjectType.BDR__c);
     
     BDR__c bdr2= new BDR__c();
     bdr2.Status__c = BDR_STATUS_DRAFT;
     
     /* This line of code may generate an error in the Eclispe local parser
        will be resolved once the calss is saved to the server */  
     bdr2.A2D_Locality__c = bdr.A2D_Locality__c;  
     
     bdr2.Locality__c = bdr.Locality__c;

     bdr2.Bdm__c = bdr.Bdm__c;

     bdr2.Income_Source__c = bdr.Income_Source__c;
     bdr2.Summary__c = bdr.Summary__c;
     bdr2.Delivery_Risks__c = bdr.Delivery_Risks__c;
     bdr2.Sustainability__c = bdr.Sustainability__c;
     bdr2.Recruitment_Required__c = bdr.Recruitment_Required__c;
     bdr2.Any_Redundancies__c = bdr.Any_redundancies__c;
     bdr2.Exit_Strategy__c = bdr.Exit_Strategy__c;
     bdr2.Development_Type__c = bdr.Development_Type__c;
     bdr2.Strategic_objectives_met__c = bdr.Strategic_objectives_met__c;
     bdr2.HR_Implications__c = bdr.HR_Implications__c;
     bdr2.Intended_Start_Date__c = startDate;
     bdr2.Estimated_Duration__c= estimatedDuration;
     bdr2.Total_Value__c=incomeAmount;     

     String sName = bdr.Bdr_Name__c;                  
     sName=sName.left(35);
     integer i = sName.indexOf('Clone of');
     if (i>-1 ) {
        sName='Another Clone of ' + sName;    
     } else {
        sName='Clone of ' + sName;
     }
                     
     bdr2.Bdr_Name__c = sName;     
     setBdrActors(bdr2);
     
     insert bdr2;          

     // Work out the dates and fiscal years      
     Date endDate = startDate.addMonths(estimatedDuration); 
     
     /* Compute the income split across the financial years.*/
     Map<String, Integer> mapFiscalYears = BdrUtils.computeFiscalSplit(startDate, endDate, incomeAmount);
     Integer m = BdrUtils.computeDurationMonths(startDate, endDate);
     
     List<String> lisFiscalYears = new List<String>();
     for(String sF : mapFiscalYears.keySet()) { 
            lisFiscalYears.add(sF); 
     }
     lisFiscalYears.sort();    
     
     System.debug('In Clone BDR - fy Size:' + lisFiscalYears.size());   
     
     //Create a String of the new fiscal years
     String sFiscalYears = '';
     for (String f : lisFiscalYears) {
        if (sFiscalYears!='') { sFiscalYears = sFiscalYears + ';'; }
        sFiscalYears = sFiscalYears + f;        
     }
    
     // Create Service Links for all linked Services  
     List<BDR_Service_link__c> lisBsl = [select id, Service__c from BDR_Service_link__c where BDR__c = :bdr.id];
     List<BDR_Service_link__c> lisBslToInsert = new List<BDR_Service_link__c>();        
     List<String> lisSvcIds = new List<String>();

     for(BDR_Service_link__c link : lisBsl) {                 
         
         lisSvcIds.add(link.Service__c);
         
         BDR_Service_link__c link2 = new BDR_Service_link__c();
         link2.BDR__c = bdr2.id;
         link2.Service__c = link.Service__c;
         lisBslToInsert.add(link2);
     }

     if (!lisBslToInsert.isEmpty()) { insert lisBslToInsert; }   

     /* Create "Funding Requirement" objects for the Fiscal Years if they don't exist. 
        This returns all relevant Funding Requirements not just those newly created
     */        
     List<Funding_Requirement__c> lisFr = createFundingRequirements(lisSvcIds, lisFiscalYears, false);     

      /*  Create one "Income Block" object  and one "Income Block Period"  per year
         There will only be one Income_Block
         
         If no income was entered, return here.                  
      */    
      if (incomeAmount==0) { return bdr2;} 
 
      Income_Block__c ib2 = new Income_Block__c();        
      ib2.BDR__c = bdr2.id;
      ib2.Status__c=BDR_STATUS_DRAFT; 
      insert ib2;
            
      List<Income_Block_Period__c> lisIbpToInsert =  createIncomeBlockPeriods(ib2, mapFiscalYears);
      system.debug('Adding Income - IBPs :' + lisIbpToInsert.size());
     
      if (!lisIbpToInsert.isEmpty()) {          

           system.debug('Adding Income - Inserting IBPs :');
           insert lisIbpToInsert ; 
           createFundAllocations(bdr2.id, BDR_STATUS_DRAFT, lisIbpToInsert, lisFr, false);         
      }
             
      return bdr2;

}
    
    /* @param           ib the income block     
       @param           fiscalYears the list of Fiscal Years
       @description     create a list of Income_Block_Period__c records
       
    */
    
    private static List<Income_Block_Period__c> createIncomeBlockPeriods(Income_Block__c ib, Map<String, Integer> mapFiscalYears)
    {
        
      system.debug('Start Creating IBP');   
        
      List<String> lisFiscalYears = new List<String>();
      for(String sF : mapFiscalYears.keySet()) { 
          lisFiscalYears.add(sF); 
      }
      lisFiscalYears.sort();        

        
      // Pass in the List to ensure correct sorting. The Map of income amounts may or may not be null           
      List<Income_Block_Period__c> lis= new List<Income_Block_Period__c>();     
    
      if (ib==null || lisFiscalYears==null || lisFiscalYears.isEmpty()) { 
            system.debug('Creating IBP : Got Fiscal Years : IB or Fiscal Years are null');
            return lis; 
      } 
        
      Integer c = 1;  
      for (String f : lisFiscalYears) {
        
          Income_Block_Period__c ibp = new Income_Block_Period__c();
          ibp.Income_Block__c=ib.id;
          ibp.Fiscal_Year__c=f;
          
          // The map should contain the income amount for the relevant fiscal year
          if (mapFiscalYears!=null) {
            Integer v = mapFiscalYears.get(f);              
            ibp.Total_Amount__c = (v==null ? 0 : v);
          } else {
            ibp.Total_Amount__c=0;
          }
          
          ibp.Year_Sequence__c=c++;
          lis.add(ibp);   
          system.debug('Creating IBP : Added IBP for ' + f);
      
      }
    
      return lis;    
    
    }
        
    
    /** 
      @param        id The ID of the BDR
      @param        startDate The start date
      @param        endDate The end date
      @description  Create a new BDR that represents a contract extension. 
                    Create a new BDR with all the same data, including BDR detail, Service links, Income and Contract.
                    Financial Years may overlap with the BDR being extended.       
    */
    public static BDR__c createBDRExtension(String bdrid, Date startDate, Date endDate, Decimal estimatedValue)
    {
             
     // Get the full BDR
     BDR__c bdr = (BDR__c)CustomUtils.objectWithAllFields('id', bdrid, Schema.sObjectType.BDR__c);
     
     Map<String, Integer> mapFiscalYears = BdrUtils.computeFiscalSplit(startDate, endDate, estimatedValue);
     Integer m = BdrUtils.computeDurationMonths(startDate, endDate);
     
     List<String> lisFiscalYears = new List<String>();
     for(String sF : mapFiscalYears.keySet()) { 
            lisFiscalYears.add(sF); 
     }
     lisFiscalYears.sort();    
     
     System.debug('In Extension Create - fy Size:' + lisFiscalYears.size());   
          
     // If no fiscal years are found, append a single year to the existing Fiscal Year scope from the BDR       
     if (lisFiscalYears.isEmpty()) {       
         
         List<String> fiscalYearsOrg = bdr.Fiscal_Years__c.split(';');
            
         List<Schema.PicklistEntry> lisPle = BDR__c.Fiscal_Years__c.getDescribe().getPicklistValues();
         String sLast = fiscalYearsOrg[fiscalYearsOrg.size()-1];
         Schema.Picklistentry peWanted = null;
         boolean nextOne=false;
         for (Schema.PicklistEntry e : lisPle) {
             if (nextOne) {
               peWanted=e;
               nextOne=false;                 
             }
             if (e.getLabel()==sLast){ nextOne=true; }                                
         }
              
         lisFiscalYears.add(peWanted.getLabel());
     }
     
     // Create a String of the new fiscal years
     String sFiscalYears = '';
     for (String f : lisFiscalYears) {
        if (sFiscalYears!='') { sFiscalYears = sFiscalYears + ';'; }
        sFiscalYears = sFiscalYears + f;        
     }
     
     // Clone the BDR, with new id, deep clone, update timestamps, new auto number          
     BDR__c bdr2 = bdr.clone(false, true, false, false);

     // Set values on the new BDR relevant for a Contract Extension 
     bdr2.Status__c = BDR_STATUS_DRAFT;
     bdr2.Total_Value__c = estimatedValue;     
     bdr2.Fiscal_Years__c = sFiscalYears;
     bdr2.Development_Type__c='Extension on existing';
     bdr2.Estimated_Duration__c = m;
     bdr2.Intended_Start_Date__c = startDate;
     
     // Append [Extension] to the name, taking the max length of bdr_name__c into account
     String sName = bdr.BDR_Name__c;
     String longDate = System.now().format('yyyy-MM-dd hh:mm'); 
     integer i = sName.indexOf('[Extension ');
     
     if (i>-1 ) {
       sName=sName.left(i);  
     } else {
       sName=sName.left(30);
     }
     /* Adding the Date makes the name too long... so don't do that. */
     sName=sName+' [Extension]';                     
     bdr2.Bdr_Name__c = sName;
     
     // Establish the links between the two BDRs and Contracts. Put the old BDR id into the new BDR to indicate that 
     // the new BDR is linked to the old one.  This allows a contract to be extended multiple times.
     //Same for Contracts.
     bdr2.linked_BDR__c = bdr.id;
     
     // Insert the BDR so that it gets an id 
     insert bdr2;          
    
     // Create Service Links for all linked Services  
     List<BDR_Service_link__c> lisBsl = [select id, Service__c from BDR_Service_link__c where BDR__c = :bdr.id];
     List<BDR_Service_link__c> lisBslToInsert = new List<BDR_Service_link__c>();        
     List<String> lisSvcIds = new List<String>();

     for(BDR_Service_link__c link : lisBsl) {                 
         
         lisSvcIds.add(link.Service__c);
         
         BDR_Service_link__c link2 = new BDR_Service_link__c();
         link2.BDR__c = bdr2.id;
         link2.Service__c = link.Service__c;
         lisBslToInsert.add(link2);
     }

     if (!lisBslToInsert.isEmpty()) { insert lisBslToInsert; }   

     /* Create Funding Requirements for the selected Fiscal Years. This will return all relevant
        Funding Requirements not just those newly created
     */        
     List<Funding_Requirement__c> lisFr = createFundingRequirements(lisSvcIds, lisFiscalYears, false);     

     /* Create Income Block and Income Block Periods
         Copy the income figures from the existing income block periods
         Update the estimated value of the BDR based on the number of years selected
         Allocate income as per the current BDR
        
         There will only be one Income_Block
        
      */ 
      Income_Block__c ib = (Income_Block__c)CustomUtils.objectWithAllFields('BDR__c', bdrid, Schema.SObjectType.Income_Block__c);   
      Income_Block__c ib2 = null;   
      
      if (ib!=null) {
         
         ib2=ib.clone(false, true, false, false);
         ib2.BDR__c = bdr2.id;
         ib2.Status__c=BDR_STATUS_DRAFT; 
         insert ib2;
            
         //Decimal nAnnual = 0;
         //if (estimatedValue!=null && estimatedValue>0) {             
         //    nAnnual = estimatedValue.divide(lisFiscalYears.size(),0);                 
         //}   
            
         List<Income_Block_Period__c> lisIbpToInsert = new List<Income_Block_Period__c>();  
         lisIbpToInsert = createIncomeBlockPeriods(ib2, mapFiscalYears);    
    
         if (!lisIbpToInsert.isEmpty()) { 
            
         insert lisIbpToInsert ; 
         createFundAllocations(bdr2.id, BDR_STATUS_DRAFT, lisIbpToInsert, lisFr, false);
         
         }  
         
      }

      /* Copy the contract and contract terms. Do not copy attachments 
         The Income Block carries the Contract Id as well, so that needs to be updated      
      */
      BD_Contract__c contract2 = null;
      BD_Contract__c contract = (BD_Contract__c)CustomUtils.objectWithAllFields('BDR__c', bdrid,Schema.SObjectType.BD_Contract__c);
      
      if (contract!=null) { 
        
        contract2 = contract.clone(false, true, false, false);
        
        /* These fields are specific to the instance of the contract and should be set back to defaults */        
        contract2.Contract_Paperwork_Attached__c=false;
        contract2.Contract_Paperwork_Checked_by__c=null;
        contract2.Extension_Terms__c=null;
        contract2.Location_of_Original_Signed_Contract__c = null;
        contract2.Option_To_extend_to__c = null;
        contract2.Renewal_Risk__c = null;
        contract2.Review_date__c = null;
        contract2.Contract_Paperwork_Received__c = false;
        contract2.Term__c = null;     
        
        contract2.Income_Block__c = ib2.id;
        contract2.BDR__c=bdr2.id;        
        contract2.Start_Date__c=startDate;
        contract2.End_Date__c=endDate;
        contract2.Fiscal_Years__c= sFiscalyears;
        contract2.Income_Block__c = ib2.id;
        
        /* Establish a link from the old contract to the new contract */ 
        contract2.Linked_bdr_Contract__c = contract.id;
        
        insert contract2;
        
        /* For reporting, contract and ib carry each other's IDs */
        if (ib2!=null) {
            ib2.Contract__c= contract2.id;
            update ib2;
        }
        
      } 
     
     return bdr2;

    }
    
    /**
    * @param          lisSvcId List of Ids for Services__c
    * @param          bdrid ID of the BDR
    * @description    Add a list of services to a BDR. Create Funding Requirements that do not already exist for the relevant fiscal years 
    *                 Create fund allocations if income is associated with the BDR
    */
    public static boolean addServices(String bdrid, List<String> lisSvcIds) 
    {

        // Fetch the BDR
        List<BDR__c> lisBdr = Database.query('select Id, Fiscal_years__c, Status__c from BDR__c where id = :bdrid');
        if (lisBdr.isEmpty()) { return false; }
        BDR__c bdr = lisBdr[0];

        /* Set up a fiscal years var */
        List<String> fiscalYears = new List<String>();
        if (bdr.Fiscal_Years__c !=null && bdr.Fiscal_Years__c!='') {
          fiscalYears = bdr.Fiscal_Years__c.split(';');
        }        

        /* Get all the Service Links that exist now, and put them in a map */
        String soql = 'select id, Service__c from BDR_Service_Link__c where Service__c in:lisSvcIds and BDR__c =:bdrid';
        List<BDR_Service_Link__c> lisSL = Database.query(soql);
        Map<String, BDR_Service_Link__c> mapSL = new Map<String, BDR_Service_Link__c>();
        for(BDR_Service_Link__c sl : lisSL) {
          mapSL.put(sl.Service__c, sl);
        }

        /* Create any link records that do not already exist */
        List<BDR_Service_Link__c> lisSlToAdd = new List<BDR_Service_Link__c>();
        for(String svcid : lisSvcIds) {
        
          if (mapSl.get(svcid)==null) {
            BDR_Service_Link__c jnc = new BDR_Service_Link__c();    
            jnc.Service__c=svcid;    
            jnc.BDR__c=bdrid;  
            lisSlToAdd.add(jnc);
          }
        }
        if (!lisSlToAdd.isempty()) { insert lisSlToAdd; }

        // No fiscal years defined so exit here 
        if (fiscalYears.isEmpty()) { return true ; }  

        /* Check that all the Funding Requirements exist */
        List<Funding_Requirement__c> lisFr= createFundingRequirements(lisSvcIds, fiscalYears, false);
        
        /* Create any Fund Allocations required for the new services */
        List<Income_Block_Period__c> lisIbp = Database.query('select Id, Fiscal_year__c from Income_Block_Period__c where Income_Block__c in (select id from Income_Block__c where BDR__c = :bdrid)');
        if (lisIbp.isempty()) { return true;}
        List<Fund_Allocation__c> lisFa = new List<Fund_Allocation__c>();
        lisFa=createFundAllocations(bdrid, bdr.Status__c, lisIbp, lisFr, false);

        return true;

    }

    /**
     *  @param          bdrid The id of the BDR
     *  @param          svcid The id of the service to be added  
     *  @description    Add a service link record that links a service to a BDR. If the bdr already have income, add
                         allocation records
    */    
    public static boolean addService(String bdrid, String svcid)
    {
      try {  
        
        // Test to see if the link already exists and if so, then exit with a true (it's OK, the record is there)
        String soql = 'select id from BDR_Service_Link__c where Service__c =:svcid and BDR__c =:bdrid';
        List<BDR_Service_Link__c> lisSL = Database.query(soql);
        if (!lisSL.isEmpty()) { return true; }

        BDR_Service_Link__c jnc = new BDR_Service_Link__c();    
        jnc.Service__c=svcid;    
        jnc.BDR__c=bdrid;   
        insert jnc;

  
        return true;
          
      } catch (DmlException x) {      
          System.Debug('Failed record add attempt - bdr : ' + bdrid + ' svc : ' + svcid);
          return false;
      }                        
    
    }
    
    public static boolean removeService(String bdrid, String incBlockId, String svcId, boolean bDelete)
    {
    
        System.debug('Removing Service' + svcId);
        System.Debug('bdrid :' + bdrid);

        List<BDR_Service_Link__c> linkData = [select id from BDR_Service_Link__c where Service__c = :svcId and BDR__c =:bdrid];
        if (linkData.isEmpty()) return true;
        BDR_Service_Link__c link = linkData[0];
         
        if (incBlockId!=null) { 

            List<Income_Block_Period__c> incomeData = [select id  from Income_Block_Period__c where Income_Block__c = :incBlockId];

            List<id> lisIbpId = new List<id>();
            if (incomeData!=null) {
             for(Income_Block_Period__c ibp : incomeData) {
               lisIbpId.add(ibp.id);
             }    
            }    

            List<Funding_Requirement__c> lisFr = [select id from Funding_Requirement__c where Service__c = :svcId];
    
            List<id> lisFRId = new List<id>();     
            for(Funding_Requirement__c fr : lisFr ) {
              lisFRId.add(fr.id);
            }   
             
            /*Get all the allocation records that are associated with this service and the 
              income block associated with this bdr */
              
            List<Fund_Allocation__c> lisFA = [select id from Fund_Allocation__c where Income_Block_Period__c in: lisIbpId and Funding_Requirement__c in: lisFrId];
        
            delete lisFA;             
            
        }
            
        delete link; 
        
        /*Also delete the service and it's associated records
        */
        
        if (bDelete) {
           deleteService(svcId, bdrid);      
        }        
        return true;    
    }

    private static void deleteService(String svcId, String bdrid)
    {
    
      /*Don't delete a service if there are other linked BDR's  */
      List<BDR_Service_Link__c> lisBdrDependents = [Select id from BDR_Service_Link__c where Service__c = :svcId and BDR__c !=:bdrid];  
      if (!lisBdrDependents.isEmpty()) {
          System.debug('Not deleting service ' + svcid + ' from ' + bdrid + ' because it is linked to other BDRs ');
          return;              
      }
    
      List<Services__c> svcLis = [Select id, Service_Status__c from Services__c where id = :svcId limit 1];

      if (!svcLis.isEmpty()) {
         Services__c svc = svcLis[0];
         if (svc.Service_Status__c==BDR_STATUS_DRAFT || 
             svc.Service_Status__c==BDR_STATUS_ACCEPTED) { 
                delete svc; 
                }                    
      }    

      return;      
    }

    public static BD_Contract__c addContract(BDR__c bdr, Income_Block__c incBlock, String ContractHelpTextId)
    {    

       BD_Contract__c contract=new BD_Contract__c();
       contract.BDR__c=bdr.id;
       contract.Income_source__c = bdr.Income_Source__c;
       contract.Income_block__c = incBlock.id;
       contract.fiscal_years__c = bdr.Fiscal_years__c;
       contract.Status__c = bdr.Status__c;        
  //     contract.Risk_Index_Version__c = ContractHelpTextId; 
       contract.ownerId=bdr.ownerId;

       insert contract;     

       /*Put the contract id into the Income Block
         It is possible that the contract does not need to carry the income block id 
         
         But it's there in case required for reporting. 

         The contract and the Income Block are in some ways a single record... it is a one to one relationship
         (a contract will only every have one income block and and an income block only ever one contract)

         However, an Income Block may exist with no contract (Legacy, Grant etc)
         
         There is currently not validation to enforce this rule.                          
         */ 
       
       incBlock.contract__c=contract.id;
       update incBlock;
       
       return contract;        
    }

    /**
    @param          contoller BDR__c Standard Controller
    @description    Add an IncomeBlock to the BDR. Create Income Block periods for selected Fiscal Years. Create
    Allocations for Services linked to the BDR.
    */
    public static Map<String, Object> addIncomeBlock(String bdrid, String incSourceId, List<String> lisFiscalYears)
    {        
    
       // Create the Income Block Period 
       Income_Block__c incBlock=new Income_Block__c();
       incBlock.BDR__c=bdrid;
       incBlock.Income_source__c = incSourceId;
       incBlock.Status__c=BDR_STATUS_DRAFT;
       insert incBlock;
     
     
       Map<String, Integer> mapFiscalYears = new Map<String, Integer>();
       for (String f : lisFiscalYears) {
         mapFiscalYears.put(f,0);
       }    
     
      // Create Income Block Periods for each fiscal year  
      List<Income_Block_Period__c> lisIbpToInsert = createIncomeBlockPeriods(incBlock, mapFiscalYears);         
      insert lisIbpToInsert;
      System.debug('Added Income Block Periods: ' + lisIbpToInsert.size());
      
      // Fetch all the Funding Requirements for the BDR
      List<Funding_Requirement__c> lisFr = BdrUtils.fetchFundingRequirementsforBdr(bdrid, lisFiscalYears);
      List<Fund_Allocation__c> lisFa = new List<Fund_Allocation__c>();

      // For each newly created ibp and linked service, add an allocation record
      for (Income_Block_Period__c ibp : lisIbpToInsert) {
     
         for(Funding_Requirement__c freq : lisFr) { 
         System.debug('Looping Funding Requirements : ' + freq.id);
          if (ibp.Fiscal_Year__c == freq.Fiscal_Year__c) {    
              
         
              Fund_Allocation__c fa = BdrUtils.addAllocationRecord(freq.id, ibp.id);                          
              lisFa.add(fa);                  
          }
             
         }
       
       }
       
      if (!lisFa.isEmpty()) { 
        System.debug('Looping Inserting FAs: ' + lisFa.size());
        insert lisFa; 
        }

      Map<String, Object> mapRtn = new Map<String, Object>();           
      mapRtn.put('incBlock', incBlock);
      mapRtn.put('ibp', lisIbpToInsert);
      mapRtn.put('fa', lisFa);  
        
      return mapRtn;          
        
   }

   /**
    @param          bdrid id of the BDR
    @param          fiscalYears list of fiscalYear strings
    @description    Return a list of funding requirements for all fiscal years for all services linked to the BDR. 
                    Passing in the fiscal years saves an extra soql query to retrieve the fiscal years 
    */
   private static List<Funding_Requirement__c> fetchFundingRequirementsforBdr(String bdrid, List<String> fiscalYears)
   {
      String soql = 'select Id, Name, Fiscal_year__c from Funding_Requirement__c '+
      ' where Fiscal_year__c in:fiscalYears and Service__c in (select Service__c from BDR_Service_link__c where BDR__c = :bdrid)';
      
      List<Funding_Requirement__c> lisFr = new List<Funding_Requirement__c>();
      lisFr = Database.query(soql);
      return lisFr;
   }



   /* May 2014. Clear all Income Block Periods */
   public static boolean clearAllIncomeBlockPeriods(String incBlockId)
   {

     List<Income_Block_Period__c> lisIbp = new List<Income_Block_Period__c>();
     List<Fund_Allocation__c> lisFa = new List<Fund_Allocation__c>();
     List<String> lisIbpIds = new List<String>(); 

     lisIbp = [select id from Income_Block_Period__c where Income_Block__c =:incBlockId];
      
     if (lisIbp.isEmpty()) { return true; }
     
     for(Income_Block_Period__c ibp : lisIbp) {
        lisIbpIds.add(ibp.id);                
     }
                      
     lisFa = [select id from Fund_Allocation__c where Income_Block_Period__c in :lisIbpIds];                       
              
     delete lisFa;
     delete lisIbp;    
     
     return true;  

   }

   /* May 2014 Sync all the data for a BDR based on a change to Financial Years 
      This will be called from the BDR Trigger after update if the Fiscal years have changed
   
      Note, the BDRWrapper is not refreshed.

   */
   public static boolean syncForUpdatedFiscalPeriods(BDRWrapper bdrWrapper)
   {

     BDR__c bdr = bdrWrapper.bdr;
     String bdrid = bdr.id; 

     /* Get the Income Block */      
     Income_Block__c incBlock = bdrWrapper.incBlock;
     BD_Contract__c contract=bdrWrapper.contract;

     /* Handle an empty set of Fiscal Years, in which case the income should be removed 
        Perhaps we should throw an error here. That needs confirmation.
     */  
     if (bdr.Fiscal_Years__c==null || bdr.Fiscal_Years__c=='') { 

                    // Clear any Income Block periods and Fund Allocations 
            
                    if (incBlock!=null) { clearAllIncomeBlockPeriods(incBlock.id); }  
            
                    // Sync the contract dates  
                    if (contract!=null) {
                        contract.Fiscal_Years__c=null;
                        update contract;
                    }
            
                    return true;  

     } //End Null Fiscal Years
     
     /*******  Handle a change in Fiscal years ********/     

       /* Sync the Contract */
     if (contract!=null) {
        contract.Fiscal_Years__c=bdr.Fiscal_Years__c;
        update contract;
      }

     /* Sets have a handy method called contains */
     Set<String> stFiscalYears = new Set<String>();
     for(String f : bdrWrapper.fiscalYears) {
        stFiscalYears.add(f);
     }

     /* Services. Create any funding requirements not already in place */
     List<Funding_Requirement__c> lisFr = new List<Funding_Requirement__c>();
     List<Services__c> lisServices = new List<Services__c>(); 

     if (bdrWrapper.services!=null && bdrWrapper.services.svcRecords!=null) {
        lisServices = bdrWrapper.services.svcRecords;     
        lisFr = bdrWrapper.services.freqs;
      }

     if (!lisServices.isEmpty()) {
     
       /* Put the list into a map using ServiceId + Fiscal Year as a key */
       Map<String, Funding_Requirement__c> mapFr= new Map<String, Funding_Requirement__c>();
       for (Funding_Requirement__c freq : lisFr) {
        mapFr.put(freq.Service__c + freq.Fiscal_Year__c, freq);
       }

       /* Loop thru the Fiscal Years and inner loop the service, checking for availability of Funding Requirement records
          for each fiscal year */
       List<Funding_Requirement__c> lisFrToInsert = new List<Funding_Requirement__c>();
       for (String f : bdrWrapper.fiscalYears) {
        for (Services__c svc : lisServices) {

          Funding_Requirement__c freq = mapFr.get(svc.id + f);
          if (freq==null) {
            
            // Create a new Funding Req and add to the insert list 
            freq=new Funding_Requirement__c();
            freq.Fiscal_year__c=f;
            freq.Service__c=svc.Id;
            lisFrToInsert.add(freq);

            //Add the new FA to the list for later processing with fund allocations
            lisFr.add(freq);

          }
        }

       }

       if (!lisFrToInsert.isEmpty()) { insert lisFrToInsert; }

     } // End Services

     /* Sync Income Blocks and Allocations */ 
     List<Income_Block_Period__c> lisIbp = new List<Income_Block_Period__c>();
  
     if (incBlock!=null) {
     system.debug('BDR Wrapper Sync Update Income Block');

       List<String> lisIbpIds = new List<String>(); 
       List<Income_Block_Period__c> lisIbpToInsert = new List<Income_Block_Period__c>();
       List<Income_Block_Period__c> lisIbpToRemove = new List<Income_Block_Period__c>();
       List<Fund_Allocation__c> lisFaToRemove = new List<Fund_Allocation__c>();
       List<Fund_Allocation__c> lisFaToInsert = new List<Fund_Allocation__c>();
       List<String> lisIbpToRemoveIds = new List<String>();

       lisIbp = bdrWrapper.incomeData;

       Set<String> stIbpFiscalYears = new Set<String>();
       for (Income_Block_Period__c ibp : lisIbp) {
          stIbpFiscalYears.add(ibp.Fiscal_Year__c);
       }
      
       /* Loop thru the Fiscal Years adding Income Block Periods where there are none */
       system.debug('BDR Wrapper Sync - update IBP');
       for(String f : bdrWrapper.fiscalYears) {          
          
          if (!stIbpFiscalYears.contains(f)) {          
            /* Add a new Income Block Period */ 
            Income_Block_Period__c ibp = new Income_Block_Period__c();               
            ibp.Fiscal_Year__c = f;           
            ibp.Income_block__c = incBlock.id;
            ibp.Total_Amount__c=0;         
            lisIbpToInsert.add(ibp);           
          }
       
       }

       /* Loop thru the Income Block Periods removing any that are not relevant for the fiscal years selected */           
       for (Income_Block_Period__c ibp : lisIbp) {
       
         if (!stFiscalYears.contains(ibp.Fiscal_Year__c)) {
            lisIbpToRemove.add(ibp);
            lisIbpToRemoveIds.add(ibp.id);
            system.debug('BDR Wrapper Sync Removing IBP for fiscal years:' + ibp.id);
         }     
       
       }

       /* The fund allocations for the removed Income Block Periods need to be removed */                      
       lisFaToRemove = [select Id, Fiscal_year__c from Fund_Allocation__c where Income_Block_Period__c in :lisIbpToRemoveIds];                       
       for(Fund_Allocation__c fa : lisFaToRemove) {
           system.debug('BDR Wrapper Sync Fund Allocation to Remove for Fiscal Years:' + fa.id + ':' + fa.Fiscal_Year__c);   
       }         
                
       if (!lisFaToRemove.isEmpty()) { delete lisFaToRemove; }
       if (!lisIbpToRemove.isEmpty()) { delete lisIbpToRemove; }    
       
       if (!lisIbpToInsert.isempty()) { 
       
           insert lisIbpToInsert; 
  
           /* For each new Income Block Period, add a fund allocation for all the services for the relevant fiscal years*/
           for (Income_Block_Period__c ibp : lisIbpToInsert) { 

             /* This is the list of all Funding Requirements - not just the relevant fiscal years */    
             for(Funding_Requirement__c freq : lisFr) 
             {
                
              /* Only create for the relevant fiscal year */    
              if (ibp.Fiscal_Year__c == freq.Fiscal_Year__c) {          
                Fund_Allocation__c fa = addAllocationRecord(freq.id, ibp.id);                          
                lisFaToInsert.add(fa);                  
              }
             
             }
       
            }
       
            if (!lisFaToInsert.isEmpty()) { insert lisFaToInsert; }
        }


      // Finally, loop thru the Income Block Periods resetting the year sequence number
      lisIbp = [select id, Year_Sequence__c, Fiscal_Year__c from Income_Block_Period__c where Income_Block__c =: incBlock.id order by Fiscal_Year__c];  
      Integer c=1;
      for (Income_Block_Period__c ibp : lisIbp) {
           ibp.Year_Sequence__c=c++;
      }
      
      update lisIbp;      

      } // End Income Block  

      return true;
    
   }

   /* @description Update the Owner of a list of BDRs. This will update
                   the owner of the Income Block and Contract
                   All other elements inherit their owner 
                   in Master Detail relationships    
      @param       bdrIds the list of BDRs to be updated
      @param       userId the id of the new User 
  
      public void updateOwner(List<String>bdrIds, String userId)
      {
      
                   Query for BDRs;
                   Query for Income Blocks;
                   Query for Contracts;
                   
                   Update Owner, add to update lis;
                   
                   update lis;
  
                   Not yet developed. Multiple BDR Owner updates
                   will fire the code in the trigger that updates the owner
                   which would be duplication and inevitably exceed the 
                   soql query limit. 
                   
                   This action has to be handled in a way that does not fire the trigger
  
      } 
   
   
   */

   /**
    * @param           freqId The id of the Funding_Requirement__c
    * @param           ibpId  The id of the Income_block_Period__c
    * @description     Create a new fund_allocation__c record
  */
   private static Fund_Allocation__c addAllocationRecord(String freqId, String ibpId)
   {
    
      system.debug('Adding Allocation Record :' + freqId + ' | ' + ibpid);  
      Fund_Allocation__c fa = new Fund_Allocation__c();
      fa.Funding_Requirement__c = freqId;
      fa.Income_Block_Period__c = ibpId; 
      fa.Status__c='Draft';
      fa.allocation_amount__c=0;
      return fa;
   }

   /*Get a list of BDRs that are linked to the same services in the same fiscal years */
   private static List<BDR__c> getDependentBdrs(BdrWrapper bdrW, boolean bDraftOnly )
   {        

    List<String> lisFiscalYears = bdrW.fiscalYears;
    List<String> lisSvcIds = bdrW.services.svcIds;

    Map<Id, BDR__c> mapBdrOther = new Map<Id, BDR__c>();
    if (lisSvcIds.isEmpty()) return new List<BDR__c>();
    if (lisFiscalYears.isEmpty()) return new List<BDR__c>();

    /*Get the list of BDRs linked to those services*/
    List<BDR__c> lisBdrOther1 = [select Id, Fiscal_years__c, Status__c, bdr_name__c, Income_source__c, Income_source__r.name, Actual_value__c  from BDR__c where  id !=: BdrW.bdr.id and id in (select BDR__c from BDR_Service_Link__c where Service__c in:lisSvcIds)];    

    /*Compare the lists of fiscal years and add only other BDRs where they fiscal periods over lap by at least one year */
    for(BDR__c bdrO : lisBdrOther1) {    
    
    System.debug('In Other BDR loop : ' + bdrO.id);
    System.debug('In Other BDR loop : ' + bdrO.fiscal_years__c);    
    
     /*Check that the other BDR has fiscal period set */
     if (bdrO.fiscal_years__c<>Null) {
         List<String> lisFiscalYears1 = bdrO.fiscal_years__c.split(';');
          for (String s1 : lisFiscalYears1) {                   
           for (String s : lisFiscalYears) {     
            if (s==s1) { 
                if (bDraftOnly) {               
                           if (bdrO.Status__c == BDR_STATUS_DRAFT) { mapBdrOther.put(bdrO.id, bdrO); }
                           if (bdrO.Status__c == BDR_STATUS_ACCEPTED) { mapBdrOther.put(bdrO.id, bdrO); }    
                           if (bdrO.Status__c == BDR_STATUS_PROPOSED) { mapBdrOther.put(bdrO.id, bdrO); }              
                } else { mapBdrOther.put(bdrO.id, bdrO); }
            }          
           }
          }
      }        
    }
        
    return mapBdrOther.values();
   
   }

   
   /*Get a list of BDRs that are linked to the same services in the same fiscal years
   */
   public static List<BDR__c> getDependentBdrs(BdrWrapper bdrW)
   {        
      return getDependentBdrs(bdrW, false);
   }
   
   
  /*    
         Get a list of BDRs that are linked to the same services in the same fiscal years
         Select on those that are Draft, Accepted or Proposed
  */
   public static List<BDR__c> getDraftDependentBdrs(BdrWrapper bdrW)
   {        
      return getDependentBdrs(bdrW, true);   
   }

   
   /*
    *   Called when a BDR is saved by a user - (as opposed to saved by an automated process)
    *   If the BDR is not in draft return
    *   Use the Locality field to look up and refresh the following 7 people values  on the BDR
    * 
    *   Locality
    *   ----------------------------
    *   - Operations Manager
    *  
    *   Area
    *   ----------------------------
    *  - Regional Operations Manager
    *  
    *  Region
    *   ----------------------------
    * -  BDM
    *  - HR Advisor
    *  - SIM
    *  - Operations Director
    *  - Regional Accountant
    * 
    *   Updates values 7 User Lookup field values on the BDR based on selected 'Locality'
    * 
    */
   public static void setBdrActors(BDR__c BDR)
   {

      
     if ( BDR.A2D_Locality__c!=null) {
  
                  // When referencing from child to parent, use fieldname__r
                  
        List<Bdr_Organisation__c> orgList = [Select Id,           
                            Operations_Manager__c,                                             // Operations Manager - One per Locality
                            Area__r.ROM__c,                                                       //  Regional Operations Manager - One per Area 
                            Region__r.BDM__c,                                                    //  BDM - One per Region 
                            Area__r.HR_Advisor__c,                                        //  HR Advisor - One per Region
                            Region__r.SIM__c,                                                     //  SIM - One per Region
                            Region__r.Operations_Director__c,                             //  Operations Director  One per Region
                            Region__r.Regional_Accountant__c                             //  Regional Accountant - One per Region
                            
                            from Bdr_Organisation__c 
                            // 
                            where Id =:BDR.A2D_Locality__c  limit 1]; 
                                        
                               
            
                 // No Organisation found for the Locality Id
                 if (orgList.isEmpty()) { 
                        // System.debug('Now in setBdrActor and unable to find A2D Locality =  ' + BDR.A2D_Locality__c);
                        clearActors(bdr); 
                        return;
                  } 
            
                 // Copy the names of the  7 'Actors' for this Locality to the BDR record
                 BDR_Organisation__c loc = orgList[0];    
                
                /* These lines update the names with every save, in case the locality has changed.
                    If the users require that the names of the approvers
                   should be editable ( to enable handling people not being available ), then these fields should
                   be wrapped in null tests and not updated if they already have a value
                   
                   That might also require the implementation of a new action to force a full refresh in the UI
                */
                
                // Workflow Approvers
                BDR.Operations_Manager__c = loc.Operations_Manager__c;              // Operations Manager - One per Locality
                BDR.Area_Manager__c = loc.Area__r.ROM__c;                        // Regional Operations Manager - One per Area
                BDR.Operations_Director__c = loc.Region__r.Operations_Director__c; 
                BDR.BDM__c = loc.Region__r.BDM__c;                                     //  BDM One per Region
               
               // Users to notify
                BDR.SIM__c = loc.Region__r.SIM__c; 
                BDR.Regional_Accountant__c = loc.Region__r.Regional_Accountant__c; 
                BDR.HR_Advisor__c = loc.Area__r.HR_Advisor__c;
     }        
        
   }   
     
  /*
   *  Set the 7 workflow actor values to null
   */   
  private static void clearActors(BDR__c bdr)
  {
        bdr.Locality_Manager__c = null;                        // Operations Manager - One per Locality
        bdr.Area_Manager__c = null;                                // Regional Operations Manager - One per Area
        bdr.HR_Advisor__c = null;                                 //  HR Advisor - One per Region
        bdr.SIM__c = null;                                          //  SIM - One per Region
        bdr.Operations_Director__c = null;                   // Operations Director
        bdr.Regional_Accountant__c = null;                   // BDM - Regional Accountant
        bdr.BDM__c = null;                                          //  BDM - One per Region
  }
  
  private static Map<String,String> getSpecForTypeMap()
  {

    Map<String,String> mapValues = new Map<String,String>();
    mapValues.put('advocacy','Advocacy');
    mapValues.put('day care and support (establishment based)','Day Care and Support');
    mapValues.put('dementia adviser','Dementia Adviser');
    mapValues.put('dementia cafe','Dementia Cafe');
    mapValues.put('dementia support','Dementia Support');
    mapValues.put('registered home care and support','Home Care and Support');
    mapValues.put('information programme','CrISP');
    mapValues.put('information provision','Information Provision');
    mapValues.put('newsletter','Newsletter');
    mapValues.put('peer support group','Peer Support');
    mapValues.put('singing for the brain','Singing for the Brain');
    mapValues.put('activity group','Activity Groups operational framework');
    mapValues.put('community support service','Community Support');
    mapValues.put('telephone helpline','Telephone Helpline');
    mapValues.put('befriending','Befriending');
    //these were missing
    //mapValues.put('awareness raising','Awareness Raising');
    //mapValues.put('other (one to one)','Other (one to one)');
    
    return mapValues;
    
  }
  
  public static List<String> getSpecsForTypes(List<String> sTypes)
  {
    map<String,String> mapValues=getSpecForTypeMap();
    map<String,String> mapSpecs = new map<String,String>();
    
    for(String s : sTypes){         
      if (mapValues.containsKey(s.toLowerCase())) {
        mapSpecs.put(mapValues.get(s.toLowerCase()),s);
      }     
    }   
    
    List<String> lis = new List<String>();
    for(String sKey : mapSpecs.keySet()) { lis.add(sKey); }
    return lis;
  }  
  
    /**
     * @param        lisSvcIds The list of Services__c ids      
     * @param        fiscalYears The list of fiscalYears as strings
     * @param        bReturnNewOnly A boolean to determine which list is returned
     * @description  Create funding requirements for a list of services and a list of fiscal years> 
     *                      Can return either the list of newly created records or the complete list including both new and existing records 
    */
    private static List<Funding_Requirement__c> createFundingRequirements(List<String> lisSvcIds, List<String> fiscalYears, boolean bReturnNewOnly)
    {

        /* Fetch existing funding requirements */
        String soql = 'select id, Service__c, fiscal_year__c from Funding_Requirement__c where Service__c in:lisSvcIds and Fiscal_Year__c in:fiscalYears';
        List<Funding_Requirement__c> lisFr = new List<Funding_Requirement__c>();
        lisFr = Database.query(soql);

        Map<String, Funding_Requirement__c> mapFr = new Map<String, Funding_Requirement__c>();
        for (Funding_Requirement__c fr : lisFr) {
          mapFr.put(fr.Service__c + fr.Fiscal_Year__c, fr);
        }

        List<Funding_Requirement__c> lisFrToInsert = new List<Funding_Requirement__c>();  
        for (String svcId : lisSvcIds) {
          for(String f : fiscalYears) {
            Funding_Requirement__c fr=mapFr.get(svcId + f);

            if (fr==null) {

              fr = new Funding_Requirement__c();
              fr.Service__c = svcid;
              fr.Fiscal_Year__c = f;
              fr.Total_Amount__c=0;
              lisFrToInsert.add(fr);  
            }
          }
        }

        if (!lisFrToInsert.isempty()) { 

          insert lisFrToInsert; 

          // Add the new Fr records into the list   
          for (Funding_Requirement__c fr : lisFrToInsert) {
            lisFr.add(fr);
          }  

        }

        return (bReturnNewOnly ? lisFrToInsert : lisFr);

    }
    /**
     * @param        bdrid The id of the BDR
     * @param        The status to which the new Allocations should be set
     * @param        lisIbp The list of Income_Block_Periods      
     * @param        lisFr The list of Funding_Requirement__c
     * @param        bReturnNewOnly A boolean to determine which list is returned
     * @description  Create fund allocations for a list of Income_block_periods and funding requirements. 
     *               Can return either the list of newly created records 
     *               or the complete list including both new and existing records 
    */
    private static List<Fund_Allocation__c> createFundAllocations(String bdrid, String sStatus, List<Income_Block_Period__c> lisIbp, List<Funding_Requirement__c> lisFr, boolean bReturnNewOnly)
    {
        
        system.debug('Start Creating Fund Allocations');
        
        // Get a list of the Ids
        List<String> lisIbpIds = new List<String>();
        for (Income_Block_Period__c ibp : lisIbp) {
          lisIbpIds.add(ibp.id);
        }
        system.debug('Creating Fund Allocations - IbpIds:' + lisIbpIds.size());

        /* Get all the existing Fund_Allocation__c records linked to this Income Block Period */
        String soql = 'select id, Funding_requirement__c, Income_block_period__c from Fund_Allocation__c where Income_Block_Period__c in: lisIbpIds';
        List<Fund_Allocation__c> lisFa = new List<Fund_Allocation__c>();
        lisFa = Database.query(soql);
        
        system.debug('Start Creating Fund Allocations : Existing FAs ' + lisFa.size());

        Map<String, Fund_Allocation__c> mapFa = new Map<String, Fund_Allocation__c>();
        for (Fund_Allocation__c fa : lisFa) {
          mapFa.put(fa.Income_Block_Period__c + '-' + fa.Funding_Requirement__c, fa);
        }

        /* Check fund allocations exist for each combination of Income_Block_Period__c and Funding_Requirement__c 
           where the Fiscal Years match
        */
        List<Fund_Allocation__c> lisFaToInsert = new List<Fund_Allocation__c>();  
        for (Income_Block_Period__c ibp : lisIbp) {
          for(Funding_Requirement__c fr : lisFr) {
            
           // Only create allocations where the fiscal years match  
           if (ibp.Fiscal_Year__c==fr.Fiscal_Year__c) {     
            
            Fund_Allocation__c fa=mapFa.get(ibp.id + '-' + fr.id);
                                    
            if (fa==null) {
                
                 system.debug('Start Creating Fund Allocations - Adding new Record :' + fr.id + ' | ' + ibp.id );
                
                 fa = addAllocationRecord(fr.id, ibp.id);
                 fa.Status__c = sStatus;
                 lisFaToInsert.add(fa);  
            }
            
           }
          }
        }        
        
        if (!lisFaToInsert.isEmpty()) { 
        
            insert lisFaToInsert;             
            for(Fund_Allocation__c fa : lisFaToInsert) {
                system.debug('Start Creating Fund Allocations - new FA created: ' + fa.id );
                lisFa.add(fa);
            }            
        }   
        
        return (bReturnNewOnly ? lisFaToInsert : lisFa);
    }
    

 /**
  *   @param         bdr The BDR__c object
  *   @description   Compute the list of email notifications that should be mandatory when the BDR is next approved
 */
 public static String[] getMandatoryNotifications(BDR__c bdr, BD_Contract__c contract)
 {
    // Use of a Map prevents adding the same value to the list twice
    Map<String, String> mapNotifications = new Map<String,String>();
    
    String bdrid = bdr.id;
    
    // There are no mandatory notifications for Initial Acceptance (Draft)     
    
    // Moving from Accepted to Proposed or Declined 
    if (bdr.Status__c==BDR_STATUS_ACCEPTED || bdr.Status__c==BDR_STATUS_PROPOSED) {
    
       if (bdr.HR_Implications__c!=null && bdr.HR_Implications__c!=''){      
            mapNotifications.put('HR_Advisor', 'ok');            
       }
       
       if (bdr.Tupe__c!=null && bdr.Tupe__c!=''){      
            mapNotifications.put('HR_Advisor', 'ok');            
       }
       
       if (bdr.IT_Implications__c==true) {      
            mapNotifications.put('IT', 'ok');            

       }
       if (bdr.Reporting_Implications__c==true){      
            mapNotifications.put('Operations', 'ok');            
       }
       
       if (bdr.Actual_Value__c > 150000 || bdr.Total_Value__c > 150000) {
        MapNotifications.put('Legal', 'OK');
       }
       
       if (contract!=null) {
       
           if (contract.Risk_Index_Applies__c!=null && contract.Risk_Index_Applies__c=='Yes') {      
                mapNotifications.put('Legal', 'ok');            
           }
           
           if (contract.Highlighted_Contract_Items__c!=null) {
                Set<String> stHighlights = new Set<String>(contract.Highlighted_Contract_Items__c.split(';'));
                if (stHighlights.contains('Data Sharing Agreement')) {mapNotifications.put('IG','OK'); }
                if (stHighlights.contains('Standard NHS Contract Terms')) {mapNotifications.put('IG','OK'); }
           }
           
       }    
        
    }

    
    String[] sReturn = new String[]{};
    for(String s : mapNotifications.keySet()) {
        sReturn.add(s);
    }
 
    return sReturn;
 }
 
 /** @description   Compute the financial years a BDR will span based on a start date and number of months
        @param      startDate the Start Date
        @param      months the number of months
  */     
 public static List<String> computeFiscalYearSpan(Date startDate, Decimal months)
 {
    
    if (startDate==null) return new List<String>();
    if (months==null) return new List<String>();
    
    Set<String> stFiscalYears = new Set<String>();
        
    Integer m = startDate.month();
    Integer y = startDate.year();
    
    if (m<4) {y=y-1;} 
    String s = String.valueOf(y) + '/' + String.valueOf(y+1).substring(2,4);    
    
    Date d = startDate;
    
    for (Integer n=0; n<months;n++) {
                        
        System.debug('Date being Processed: ' + d);                                          
        if (!stFiscalYears.contains(s)) { stFiscalYears.add(s); }
    
        d=d.addMonths(1);    
        m = d.month();
        y = d.year();        
        
        if (m<4) {y=y-1;}            
        s=String.valueOf(y) + '/' + String.valueOf(y+1).substring(2,4);
     
    } 
    
    List<String>lisFiscalYears = new List<String>(stFiscalYears);
    lisFiscalYears.sort();
    
    
    return lisFiscalYears;
 }
 
 
 
 public static List<String> computeFiscalYears(DateTime startDate, DateTime endDate)
 {
    List<String> lisFiscalYears= new List<String>();
    
    String startPeriod='';
    String endPeriod='';
    
    Integer startMonth=startDate.month();
    Integer startYear=startDate.year();
    
    Integer endMonth=endDate.month();
    Integer endYear=endDate.year();
    
    if (startMonth<4) { startYear= startYear-1 ; }
    if (endMonth<4) { endYear= endYear-1 ; }
    
    startPeriod=String.valueOf(startYear) + '/' + String.valueOf(startYear+1).substring(2,4);
    endPeriod=String.valueOf(endYear) + '/' + String.valueOf(endYear+1).substring(2,4);
    
    System.debug('StartPeriod =' + startPeriod);
    System.debug('EndPeriod =' + endPeriod);
    
    Boolean bInRange=false;
    List<Schema.PicklistEntry> lis = BDR__c.Fiscal_Years__c.getDescribe().getPicklistValues();
    for(Schema.PicklistEntry e : lis) { 
        if (e.getLabel()==startPeriod) { bInRange=true; }
        if (bInRange) {
          lisFiscalYears.add(e.getLabel());
          if (e.getLabel()==endPeriod) { break; }                
        }
    }
    
    return lisFiscalYears;
    
    
 }
 
 /** @Description   Compute the Financial Year span and the money amount 
                    for each year, based on an April fiscal year start
  */                
 public static Map<String, Integer> computeFiscalSplit(Date startDate, Date endDate, Decimal totalAmount)
 {
    Map<String, Integer> mapData = new Map<String, Integer>();
    
    Integer m = startDate.month();
    Integer y = startDate.year();
    
    if (m<4) {y=y-1;} 
    String s = String.valueOf(y) + '/' + String.valueOf(y+1).substring(2,4);
    
    Integer c = 0;
    Date d = startDate;
    
    
    /* Compute the start and end Financial years, and all those in between */     
    boolean atStart=true;
    boolean atEnd=false;
    while(atEnd==false) {
                        
        System.debug('Date being Processed: ' + d);
    
        
        /* If we hit the April, start a new year */
        if (!atStart && d.month()==4) {          
            mapData.put(s,c);                   
            System.debug('Putting Year in:' + s + ':' + c) ;    
    
            c=0;
            s=String.valueOf(d.year()) + '/' + String.valueOf(d.year()+1).substring(2,4);
        } 
       
        /* If at the end of the period.. */
        if (d.month() == endDate.month() && d.Year() == endDate.year()) 
        {
         
         if (endDate.Month()!=startDate.month()) {          
             c++;              
         } else {
             d=d.addMonths(-1);
         }
         
         if (d.month()<4) {
             s=String.valueOf(d.year()-1) + '/' + String.valueOf(d.year()).substring(2,4);   
         } else {
             s=String.valueOf(d.year()) + '/' + String.valueOf(d.year()+1).substring(2,4);  
         }
         
         /* If there are no months in the year, don't put it in */ 
         if ( c > 0 ) {         
            mapData.put(s,c);
            System.debug('Putting Last Year in:' + s + ':' + c) ;
         }                 
           
         atEnd=true;
         break;
        }               
        
        atStart=false;
        c++;
        d=d.addMonths(1);
    } 
    
    /* Get the total number of months across all Financial Years in this data range */
    Integer totalMonths = 0;
    for(Integer v : mapData.values()) {totalMonths = totalMonths + v;}
    
    system.Debug('Total Months: ' + totalMonths);
    
    /* Compute the monthly amount, base on the total amount and total number of months */
    Decimal mv = totalAmount/totalMonths;
    System.debug('Monthly Amount: ' + mv); 
    
    /* The function returns a map with keys for each Financial Year, 
       and Value for the amount of income for that year
    */       
    Map<String, Integer> mapFinal = new Map<String, Integer>();
    String lastYear = '';
    for(String sFY : mapData.keySet()) {
        Decimal dec = (mapData.get(sFy) * mv);
        
        /* This does some rounding */
        Integer iAnnualTot = dec.round(RoundingMode.DOWN).intValue();
        System.debug('Putting Annual Total: ' + iAnnualTot);
        
        mapFinal.put(sFy, iAnnualTot);
        lastYear = sFy;
    }
    
    /* Correct for rounding by adding the remainder to the final year */
    Integer tRounded =0;
    for (Integer i : mapFinal.values()) {
         tRounded = tRounded + i;
    }
    Integer iCorrected = mapFinal.get(lastYear);
    iCorrected = iCorrected + (TotalAmount.round(RoundingMode.DOWN).intValue() - tRounded);
    mapFinal.put(lastYear,iCorrected);
    
    return mapFinal;
    
 }
 
  public static Integer computeDurationMonths(Date startDate, Date endDate)
 {
    Integer m = startDate.month();
    Integer y = startDate.year();
    
    Integer c = 1;
    Date d = startDate;
    
    boolean atEnd=false;
    while (atEnd==false) {
 
        if (d.month() == endDate.month() && 
             d.Year() == endDate.year()) 
        {
            atEnd=true;
            break;
    
        } else {                       
            c++;
            d=d.addMonths(1);
    
        }
    }
    
    return c; 
    
 }
 
 
 
 /* There are a set of dummy User records in the database - one for each Locality - that can be 
    used as the owner of a service. That will provide access to the Locality Management team to edit Services
    based on the sharing rules in use. This is because it's not clear who in the locality management team should be 
    the owner of a given record.    
    
    For Draft and Accepted Services only, set these names into the owner field
    
 */ 
 
 public static Integer setServiceAdminOwners(BDR__c bdr)
 {
    
    List<Services__c> lisSvcToUpdate = new List<Services__c>();
    
    // Get the list of users and put them in a map keyed on Locality Name 
    List<User> lisUsers = [select id, Name, Locality__c from User where LastName = 'ServiceAdmin<No CRS>'];     
    Map<String, User> mapUsers = new Map<String,User>();
    for (User user : lisUsers) {
        mapUsers.put(user.locality__c, user);
    }
    
    List<Services__c> lisSvc = [select id, name, Locality__r.Name, OwnerId from Services__c where Service_Status__c in ('Draft','Accepted') and Id in (select Service__c from BDR_Service_Link__c where BDR__c =:bdr.id)];
    system.debug('Updating Services to insert Local Admin : ' + lisSvc.size() + ' Services retrieved');
    for (Services__c svc : lisSvc) {
        
        User user = (User)mapUsers.get(svc.Locality__r.Name); 
        if (user!=null && (svc.OwnerId != User.id)) {
            svc.OwnerId = User.id;
            lisSvcToUpdate.add(svc);
        }
        
    }
    
    if (!lisSvcToUpdate.isEmpty()) { update lisSvcToUpdate; }
    return lisSvcToUpdate.size();   
  
 }
 
 
}