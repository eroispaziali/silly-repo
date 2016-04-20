public class BdrFundReqWrapper
 {

  /*************************************************************************
   * @author          gary.grant@conseq.co.uk
   * @date            July 2014
   * @description     A generic wrapper class with some useful utility  functions for managing 
   *                  and displaying Service Costs (previously called "Funding Requirements")
   *
   *                  The Class may be used with a focus on a specific BDR, in which case
   *                  there is a primary Income Allocation and Others. 
   *                   
   *                  Where the Class is instantiated without focus on a specific BDR
   *                  the 'Other' properties will include all related objects  
   *
   *     
   ***************************************************************************/  
 
  public Funding_Requirement__c freq {get;set;}

  /* Primary Objects where focus is on a specific BDR */
  public Fund_Allocation__c allocation {get;set;}
  public Income_Block_Period__c incomeBlockPeriod {get;set;}

  /* Used mainly in the case focus is on a specific BDR */
  public Map<id,Fund_Allocation__c> otherAllocations {get;set;}

  /* Used in the case where focus is on a Service, not a specific BDR */
  public List<Fund_Allocation__c> allocations {get;set;}  

  public Decimal OtherAllocationAmount;
  public Decimal OtherAllocationAmountPotential;
  public Decimal OtherAllocationAmountProposed;  
  
  public Boolean isSelected {get; set;}
  
  /* Use this constructor where focus is on a specific BDR */
  public BdrFundReqWrapper(Funding_Requirement__c freq, Income_Block_Period__c incBlockPeriod)
  {

    this.freq=freq;    
    isSelected = false;
        
    /*  This allocation may be replaced by an existing one as part of the init process */
    
    allocation = new Fund_Allocation__c();
    allocation.Funding_Requirement__c = freq.id;
    allocation.Status__c='Draft';
    allocation.Allocation_Amount__c=0;
    
    if ((incBlockPeriod!=null)) {
       incomeBlockPeriod=incBlockPeriod;    
       allocation.Income_Block_Period__c=incBlockPeriod.Id;
    }

    /*These are allocations from other income blocks */
    otherAllocations = new Map<id,Fund_Allocation__c>();
    OtherAllocationAmount=null;
    OtherAllocationAmountPotential=null;
    OtherAllocationAmountProposed=null;

  }

  /* Use this Constructor for non specific BDR focus 
     i.e where the focus is on the Service, rather than the BDR
  */  
  public BdrFundReqWrapper(Funding_Requirement__c freq)
  {

    this.freq=freq;    
    isSelected = false;

    allocations=new List<Fund_Allocation__c>();
    otherAllocations = new Map<id,Fund_Allocation__c>();
    OtherAllocationAmount=null;
    OtherAllocationAmountPotential=null;
    OtherAllocationAmountProposed=null;

  }


 /* The id of the parent service */
 public String getServiceId()
 {
   return freq.Service__c;
 }

 /* Insert an existing funding allocation record */
 public void setAllocation(Fund_Allocation__c allc) 
 {
      this.allocation=allc;
 }

 /* Add a funding allocation from another income block 
    Use a map to ensure there is no duplication    
 */
 public void setOtherAllocation(Fund_Allocation__c allc) 
 {  
      this.otherAllocations.put(allc.id, allc);
      system.debug('Other Allocation : ' + allc.id); 
 }

 public Decimal getOtherAllocationAmountPotential()
 {
    
    OtherAllocationAmountPotential=0.0;
    for(Fund_Allocation__c allc : otherAllocations.values()) {
    
       Decimal d = (allc.Allocation_Amount__c !=null ? allc.Allocation_Amount__c : 0);         
       OtherAllocationAmountPotential = OtherAllocationAmountPotential + d;
       system.debug('Other Allocation Potential : ' + allc.id + ' | ' + d ); 
    }
    
    return OtherAllocationAmountPotential;
    
 }   
 
 public Decimal getOtherAllocationAmountProposed()
 {
    
    OtherAllocationAmountProposed=0;
    for(Fund_Allocation__c allc : otherAllocations.values()) {
 
       Decimal d = (allc.Allocation_Amount__c!=null ? allc.Allocation_Amount__c : 0);       
       if(allc.Status__c=='Draft' || 
          allc.Status__c=='Accepted' ||
          allc.Status__c=='Proposed') { 
                OtherAllocationAmountProposed = OtherAllocationAmountProposed + d; 
                system.debug('Other Allocation Proposed Loop : ' + allc.id + ' | ' + allc.Status__c + ' | ' + d );  
       }
       
    }
 
    return OtherAllocationAmountProposed;
 
 }
 
 public Decimal getOtherAllocationAmount()
 {

    OtherAllocationAmount=0;
    for(Fund_Allocation__c allc : otherAllocations.values()) {
        
       Decimal d =  (allc.Allocation_Amount__c != null ? allc.Allocation_Amount__c : 0);       
       if(allc.Status__c=='Live') { 
            OtherAllocationAmount = OtherAllocationAmount + d;        
            system.debug('Other Allocation Live : ' + allc.id + ' | ' + allc.Status__c + ' | ' + d ); 
       }
    }
    
    return OtherAllocationAmount;
  
 }
 
 /* This is a simple list, can be used where we are interested in all allocations
    not just those related to a specific BDR */
 public void addAllocationToList(Fund_Allocation__c allc)
 {  
     allocations.add(allc);     
 }
 
 
}