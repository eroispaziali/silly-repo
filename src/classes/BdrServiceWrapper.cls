public class BdrServiceWrapper {

/***************************************************************************************
 *   @author        gary.grant@conseq.co.uk
 *   @date          july 2014
 *   @description   A wrapper for a Services__c class that contains associated records for 
 *                  funding and income related to a proposal
 *   
 *                  The service wrapper should be used  with a ServiceWrapperList
 
 *                  The ServiceWrapper list takes a list or services and will create a list of 
 *                  service wrappers that contain both the related FundingRequirementWrappers 
 *                  The FundRequirementWrappers are populated with the funding requirement object 
 *                  and related fund allocations 
 *  
 *                  ServiceWrapperList
 *                  contains { BdrServiceWrappers )
 *
 *                  ServiceWrapper
 *                  contains(services__c, list of BdrFundReqWrappers, latest Evidence For Need)
 *   
 *                  BdrFundReqWrapper
 *                  contains(Fund_Requirement__c, list of Fund_Allocation__c)
 *   
 *                  That enables views over a list of services, listing their funding status
 *                  in a given (or set of ) fiscal period(s)    
 *   
 *****************************************************************************************/
  
  
  public Services__c svc {get;set;}    /* A single Service - despite the misleading plural name */
  public List<BdrFundReqWrapper> fundReqWrappers {get;set;}       
  public Evidence_For_Need__c evidence {get;set;}
  
  public Location__c location {get;set;}
  
  public Boolean isSelected {get; set;}

  public BdrServiceWrapper(Services__c svc)
  {
    this.svc=svc;    

    //Don't call this on the constructor. Too many SOQL queries
    //this.evidence = getLatestEvidenceForNeed();

    isSelected = false;
    fundReqWrappers = new List<BdrFundReqWrapper>();
  }
  
  public void addFr(BdrFundReqWrapper freq)
  {
     fundReqWrappers.add(freq);
  }

  public void newEvidenceForNeed()  
  {
     String sid = svc.id; 
     this.evidence=BdrServiceWrapperUtils.createEfn(sid);
  }
  
}