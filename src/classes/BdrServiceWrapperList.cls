public class BdrServiceWrapperList
{
 /************************************************************************************************************
  * @author           gary.grant@conseq.co.uk
  * @date             July 2014. 
  * @description      A public class that wraps a set of Services associated with a BDR
  *                   with some useful utils for populdating the data using minimal SOQL queries 
  *  
  *                   The ServiceWrapper list takes a list or services and will create a list of 
  *                   service wrappers that contain related FundingRequirementWrappers 
  *
  *                   The FundRequirementWrappers are populated with the funding requirement object 
  *                   and related fund allocations 
  *  
  *                   ServiceWrapperList
  *                   contains { ServiceWrappers )
  *                   
  *                        ServiceWrapper
  *                        contains(services__c, list of FundRequirementWrappers, latest Evidence For Need)
  *                      
  *                        FundRequirementWrapper
  *                        contains(Fund_Requirement__c, list of Fund_Allocation__c)
  *                      
  *                   That enables views over a list of services, listing their funding status
  *                   in a given (or set of ) Financial Years  
  *                  
  *                     
  *                   This class can also be used for getting the list of all 
  *                   frWrappers associated with a proposal : pass in the propsal Id only   
  *                     
  *                   OR
  *                     
  *                   a random list of services : pass in the list of Service__c objects
  *                        
  *                   The frWrappers are available as a single list
  *                   and also as individual lists form within the svcWrappers   
  * 
  ****************************************************************************************************************/

public String bdrid {get;set;}

 public List<BdrServiceWrapper> svcWrappers {get;set;} 
 
 public List<Services__c> svcRecords {get;set;}
 
 public List<BdrFundReqWrapper> frWrappers {get;set;}

 public List<Fund_Allocation__c> allocations {get;set;}
 public Income_Block__c incBlock {get;set;}
 public List<String> fiscalPeriods {get;set;}
 public List<Evidence_For_Need__c> evidenceForNeeds {get;set;}
 public Location__c property {get;set;}
 
 private Map<String, Income_Block_Period__c> mapIncBlockPeriods;
 private List<Id> lisSvcId; //  List of the Service Ids
 private List<Id> lisIbpId;    
 private List<Id> lisFundReqsId;
 private List<Id> lisLocationsId;  // List of the Location Ids

// Get Service Costs
 public List<Funding_Requirement__c> freqs {
       get {
         List<Funding_Requirement__c> lis = new List<Funding_Requirement__c>();
         if (frWrappers==null) 
            return lis;
         for (BdrFundReqWrapper freqw : frWrappers ) {
             lis.add(freqw.freq);           
         }
         return lis;   
       }
       set;
   }

public List<String> svcIds {
       get {
         List<String> serviceIdsList = new List<String>();
         if (svcRecords==null) return serviceIdsList;
         for (Services__c service : svcRecords ) {
             serviceIdsList.add(service.Id);           
         }
         return serviceIdsList;   
       }
  }
  
  public List<String> getLocationIds() {
     
         List<String> locationIdsList = new List<String>();
         if (svcRecords==null) { 
            return locationIdsList;
         }
         for (Services__c svc : svcRecords ) {
             locationIdsList.add(svc.Default_Location__c);      
         }
         return locationIdsList;   
  }

   public List<String> serviceSpecList {
        get {
            List<String> lis = new List<String>();      
            for (Services__c svc : svcRecords) {
              system.debug('Getting Service Spec : ' + svc.id);                  
              if (svc.Service_Type__c!=null) { 
                system.debug('Getting Service Spec : ' + svc.Service_Type__c);
                lis.add(svc.service_type__c); 
                }   
            }
            return BdrUtils.getSpecsForTypes(lis);
        }
        set;    
    }   
    
    public String serviceSpecString {
        get {
     
             if (svcRecords==null || svcRecords.isEmpty()) { 
                system.debug('Getting Service Spec : No Services');
                return ''; 
                }             
             String rtn = '';
             integer n = 0;
             for (String s : serviceSpecList) {
                 system.debug('Getting Service Spec : Adding ' + s);        
                 if (n++>0){ rtn=rtn+', '; }
                 rtn = rtn + s;             
             } 
             system.debug('Getting Service Spec : Final String' + rtn);
             return rtn;                
        }
        set;    
    }

   public List<String> serviceTypeList {
        get {
            List<String> lis = new List<String>();      
            for (Services__c svc : svcRecords) {
              if (svc.service_type__c!=null) { lis.add(svc.service_type__c); }   
            }
            return lis;
        }
        set;    
    }   
    public String serviceTypeString {
        get {
         
             if (svcRecords==null || svcRecords.isEmpty()) { return ''; }             
             String rtn = '';
             integer n = 0;
             //return list with duplicates removed.
             Set <String> stSet = new Set <String>();
             List <String> DedupServiceType = new List<String>();
             for (String s2 : serviceTypeList) {
                 if (stSet.add(s2)){
                     DedupServiceType.add(s2);
                 }
             }
             DedupServiceType.sort();
             for (String s : DedupServiceType) {
                 if (n++>0){ rtn=rtn+', '; }
                 rtn = rtn + s;             
             } 

             return rtn; 
        }
        set;    
    }




transient public String FinanceActivityCodes {
    get;set;
}

/*
TODO
Number of periods without coverage across the relevant periods
*/

/*    A straight list of services not associated with a BDR 
        Fetches a list of serviceWrappers, with inserted FundingRequirementWrappers
*/
public BdrServiceWrapperList(List<Services__c> lisSvc, List<String> fiscalPeriods)  
{
    this.svcWrappers = new List<BdrServiceWrapper>();    
    
    this.frWrappers = new List<BdrFundReqWrapper>();
         
    this.evidenceForNeeds = new List<Evidence_For_Need__c>();
    
    this.FinanceActivityCodes = '';
    //The list of services being processed
    svcRecords=lisSvc;

    populateServicesIdList();

    //Get the list of Funding Requirements associated with the services
    //actual__c, Change the sort order of to Service/FY
    lisFundReqsId = new List<Id>();        
    
    String soql =
    
     'select Name, Service__c, Service_name__c, Fiscal_Year__c, Total_Amount__c, Actual_FCR__c, Comments__c, '+
     ' Total_Cover_Potential__c, Total_uncovered_Potential__c, Total_Cover_Potential_Percent__c, InBudget__c, SystemModStamp '+
     ' from Funding_Requirement__c where Service__c in: lisSvcId';
     
    if (fiscalPeriods!=null && !fiscalPeriods.isEmpty()) {
        soql = soql + ' and Fiscal_Year__c in :fiscalPeriods ';
    }
    
    soql = soql + ' order by Service_name__c asc, Fiscal_Year__c asc';
    
    List<Funding_Requirement__c> lisFr = Database.query(soql);
    for (Funding_Requirement__c freq : lisFr) {
              frWrappers.add(new BdrFundReqWrapper(freq));
              lisFundReqsId.add(freq.id);  
    }    

    // Get the Fund Allocations (Income Allocation) associated the Fund Requirements  (Service Costs)
    allocations = 
    [select Name, Status__c, Service_Name__c, Fiscal_Year__c, Funding_Requirement__c, Income_Block_Period__c, 
      Allocation_Amount__c, SystemModStamp from Fund_Allocation__c 
     where Status__c in ('Draft', 'Accepted', 'Proposed', 'Live') 
     and Funding_Requirement__c in :lisFundReqsId];
    
    for (Fund_Allocation__c allc : allocations) {    
      for (BdrFundReqWrapper reqW : frWrappers) {      
         if (reqW.freq.id==allc.Funding_Requirement__c) 
                {reqW.setOtherAllocation(allc);}      
      }        
    }

    populateServiceWrappers();
    populateEvidenceForNeed();
    populateFinanceActivityCodes();                
     
}

/* A list of ServiceWrappers associated with a BDR 
   This restricts the data set across all objects to those associated with a single BDR (proposal)
   Includes Income Block, Income Block Periods and Funding Requirements
   for the fiscal periods that the BDR covers

*/
public BdrServiceWrapperList(String bdrid)  
{
    
    this.frWrappers = new List<BdrFundReqWrapper>();    
    this.svcWrappers = new List<BdrServiceWrapper>();    
    this.evidenceForNeeds = new List<Evidence_For_Need__c>();
    this.fiscalPeriods = new List<String>();
    this.FinanceActivityCodes = '';

    if (bdrid==null) { return ; } 
    this.bdrid=bdrid;

    /* Get the Financial Years covered by the BDR
    */
    List<BDR__c> lisBDR = [select Id, Fiscal_Years__c from BDR__c where Id = :bdrid limit 1];
    if (lisBDR==null || lisBDR.isEmpty()) { return; }     

    BDR__c bdr = lisBdr[0];
    String sFiscalPeriods = bdr.fiscal_years__c;
    if (sFiscalPeriods!=null && sFiscalPeriods!='') {  
             fiscalPeriods = sFiscalPeriods.split(';');
    }

   // The Dementia Connect Services linked to the BDR, ordered by Service Name
   
   //   Default_Location__c is a lookup to the Property Table 

    this.svcRecords = 
    [select Name, 
                 Locality__c, 
                 last_reviewed__c, 
                 Property_Notes__c, 
                 
                 service_type__c, 
                 Sub_Type_Internal__c,
                 service_status__c,   
                 service_opendate__c, 
                 service_targetclientgroup__c, 
                 service_financeactivitycode__c, 
                 
                 Default_location__c, 
                 Default_location__r.Name, 
                 Internal_evaluation_methods__c, 
                 External_evaluation__c,  

                 Services_FrameWork_Principle__c,
                 Estimated_Break_Even__c
                 
                   
     from Services__c 
     where Id in  
                (select Service__c from BDR_Service_Link__c where BDR__c =:bdrid)
     order by Name] ;
       
    populateServicesIdList();
    populateIncomeData();

    if (!svcRecords.isEmpty()) {
        populateAllocationData();    
        populateServiceWrappers();
        populateEvidenceForNeed();
        populateFinanceActivityCodes();                
    }

 }

 /* Populate the externally avaiable list of Evidence for Needs records 
     This is a convenience method. 
   The records don't have to be retrieved individually from the service wrappers 
   outside this class
 */
 private void populateEvidenceForNeed() {

      for (BdrServiceWrapper svcW : svcWrappers) {       
          evidenceForNeeds.add(svcW.evidence);
      }       
 }

void populateFinanceActivityCodes(){
    // Get a list of Finance Activity Codes
    Set <String> FAC_set = new Set<String>();
    List <String> FAC_list = new List<String>();

    for (BdrServiceWrapper svcW : svcWrappers) {
        if ((svcW.svc.service_financeactivitycode__c!=null) && (svcW.svc.service_financeactivitycode__c!='')){
            if (FAC_set.add(svcW.svc.service_financeactivitycode__c)){
                FAC_list.add(svcW.svc.service_financeactivitycode__c);
          }
        }
    }
    if (FAC_list.size()>0){
        FAC_list.sort();
        String result = String.join(FAC_list, ', ');
        FinanceActivityCodes = result;
    } 
    else {
        FinanceActivityCodes = '';
    }
}




 private void populateServicesIdList()
 {   
    //This list is used in a query below
    this.lisSvcId = new List<Id>();
    
    for (Services__c service : svcRecords) {
             lisSvcId.add(service.Id);
        
    }
 }

 private void populateAllocationData()
 {
 
     /*Get the funding requirements associated with the services associated with the proposal 
      Only the FR's for the periods associated with the BDR are of interest */    
      
    //  actual__c, 
    //Change Sort Order of Allocations to Service/FY
    List<Funding_Requirement__c> lisFr = 
    [select Name, Service_Name__c, Fiscal_Year__c, Total_Amount__c, Total_uncovered_potential__c,  Actual_FCR__c, Funding_In_Budget__c, Comments__c, Service__r.name, SystemModStamp 
    from Funding_Requirement__c 
    where Service__c in :lisSvcId and Fiscal_Year__c in :FiscalPeriods 
    order by Service_Name__c asc, Fiscal_Year__c asc];
    
    System.Debug('svcW : lisFR: ' + lisFR.size());
    
    if (lisFR.isempty()) return;

    //This list used in a query below
    this.lisFundReqsId = new List<Id>();

    //NOTE: ibp may be null if there is no income associated with this BDR
    for (Funding_Requirement__c freq : lisFr) {    
      Income_Block_Period__c ibp = mapIncBlockPeriods.get(freq.Fiscal_Year__c);
      frWrappers.add(new BdrFundReqWrapper(freq,ibp));
      lisFundReqsId.add(freq.id);          
    }    
    
    System.debug('frWrappers:' + frWrappers.size());
    
  /*Get the fund allocations associated with the Income Block
    Add the allocations associated with the income blocks to the relevant wrapper
    Where no allocation is added, a new allocation will be created by the Wrapper Constructor
    This may end up having a 0/null allocation */    

    /* status__c in ('Draft', 'Accepted','Proposed', 'Live') and */    
    List<Fund_Allocation__c> lisAllc = [select name, Status__c, Service_Name__c, Fiscal_Year__c, 
         Funding_Requirement__c, Income_Block_Period__c, Allocation_Amount__c, SystemModStamp 
         from Fund_Allocation__c 
         where Income_Block_Period__c in :lisIbpId];
         System.debug('in FReqW Fund Allocations:' + lisAllc.size());   
     
    for (Fund_Allocation__c allc : lisAllc) {    
      for (BdrFundReqWrapper reqW : frWrappers) {      
         if (reqW.freq.id==allc.Funding_Requirement__c) {
             System.Debug('Adding Allocation:' + allc.Fiscal_Year__c);
             reqW.setAllocation(allc);
         }      
      }        
    }    
    
    /*Refresh the list of allocations to pick up any that were created by the FundReqWrapper constructor*/ 
    allocations = new List<Fund_Allocation__c>();  
    for (BdrFundReqWrapper reqW : frWrappers) {      
 //       System.Debug('Refreshing Allocations:' + reqW.allocation.Fiscal_Year__c);
        allocations.add(reqW.allocation);
    }
    

    /*Get the fund allocations associated with other Income Blocks
      This list is not accessible outside the class because it relates to other BDRs
    */    
    List<Fund_Allocation__c> lisFAO = 
    [select name, Status__c, Service_Name__c, Fiscal_Year__c, Funding_Requirement__c, Income_Block_Period__c, Allocation_Amount__c, SystemModStamp
     from Fund_Allocation__c where  
     Status__c in ('Draft', 'Accepted', 'Proposed', 'Live')
     and (Income_Block_Period__c not in :lisIbpId) 
     and (Funding_Requirement__c in :lisFundReqsId)];    
     System.debug('in FReqW Fund Allocations:' + lisFAO.size());
        
    for (Fund_Allocation__c allc : lisFAO) {    
      for (BdrFundReqWrapper reqW : frWrappers) {      
         if (reqW.freq.id==allc.Funding_Requirement__c) {reqW.setOtherAllocation(allc);}      
      }        
    }   

 }
 
 private void populateIncomeData()
 {
 
    //Init these here so they are not null if there is no income block
    mapIncBlockPeriods = new Map<String, Income_Block_Period__c>(); 
    lisIbpId = new List<Id>();            
    List<Income_Block_Period__c> lisIBP = new List<Income_Block_Period__c>();

    List<Income_Block__c> lis = [select id, name from Income_Block__c where BDR__c=:bdrid];
    if (lis.isEmpty()) return;
    
    incBlock = lis[0];    
      
    //Get the income block periods associated with the Income block Associated with the proposal
    lisIBP = [select id, name, Fiscal_Year__c, Total_Amount__c, Income_Block__r.name, Risk_factor__c, Risk_description__c, SystemModStamp 
    from Income_Block_Period__c 
    where Income_Block__c =:incBlock.id];

    //This list used in a query below
    for (Income_Block_Period__c incBlockPeriod : lisIBP ) {
      mapIncBlockPeriods.put(incBlockPeriod.Fiscal_Year__c, incBlockPeriod);
      lisIbpId.add(incBlockPeriod.id);
    }
 
 }
    
/* Returns a MAP with the Evidence For Need data for the services linked to this BDR */
 private Map<String, Evidence_For_Need__c> fetchExistingEvidenceForNeed()
 {
    Map<String, Evidence_For_Need__c> evidenceMap = new Map<String, Evidence_For_Need__c>(); 
   
    List<Evidence_For_Need__c> evidenceList = 
                [select id, Service__c, Evidence_Overview__c, Consequences_of_Closure__c,  Demography_Comments__c, Usage_Profile__c, 
                             SystemModStamp 
                from Evidence_For_Need__c 
                where Service__c in :lisSvcId and isCurrent__c=true];

    for (Evidence_For_Need__c evidence : evidenceList) {
            evidenceMap.put(evidence.Service__c, evidence);
    }
    
    return evidenceMap;
 }

 


 private void populateServiceWrappers()
 {

    Map<String, Evidence_For_Need__c> evidenceMap = fetchExistingEvidenceForNeed();
    
    
    // Loop through the list of services
    for (Services__c svc : svcRecords) {      
        
       // Add the FundReqWrappers to the Service Wrappers 
        BdrServiceWrapper serviceWrapper = new BdrServiceWrapper(svc);       
        
        // Loop through the set of Funding Requirement Wrappers adding to the service wrapper
        for (BdrFundReqWrapper freqW : frWrappers) {
           if (freqW.getServiceId() == svc.id) { 
                serviceWrapper.addFr(freqW); 
            }  
        }
        
       /*       Add the Evidence For Need to Service Wrappers 
                If none is found, call the method that puts a new empty record into the wrapper
                This avoids a null value 
       */       
        Evidence_For_Need__c evidence = (Evidence_For_Need__c)evidenceMap.get(svc.id);
        if (evidence==null) {
                serviceWrapper.newEvidenceForNeed();
        } else {
                serviceWrapper.evidence=evidence;         
        }
        
    
                
        svcWrappers.add(serviceWrapper);        
    }    

 }

}