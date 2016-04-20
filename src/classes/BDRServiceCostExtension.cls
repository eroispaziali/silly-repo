public without sharing class BDRServiceCostExtension {

/*******************************************************************************************************************************************
 *            @author             gary.grant@conseq.co.uk
 *            @date               Sept 2014
 *            @description        Controller Extension for BDR Service Cost Page inserted into DC page to show overview of service funding
 *  
 ********************************************************************************************************************************************/


 public List<Fund_Allocation__c> allocations {get;set;}   
 public List<BDRFundReqWrapper> fundReqWrappers {get;set;}

 public BDRServiceCostExtension(ApexPages.StandardController controller) 
 {
    Services__c svc =(Services__c)controller.getRecord();
    
    fundReqWrappers = new List<BDRFundReqWrapper>();

    /* Get all Allocations that are either Draft, Accepted, Proposed or Live */
    allocations = [select id, 

                   Income_Block_Period__r.Income_Block__r.Contract__r.name,  
                   Income_Block_Period__r.Income_Block__r.Contract__r.id,  
                   Income_Block_Period__r.Income_Block__r.Contract__r.Status__c,
                   Income_Block_Period__r.Income_Block__r.Contract__r.End_Date__c,
                   Income_Block_Period__r.Income_Block__r.Contract__r.Renewal_Risk__c,
        
                   Income_Block_Period__r.Income_Block__r.BDR__r.Status__c,
                   Income_Block_Period__r.Income_Block__r.BDR__r.Name,
                   Income_Block_Period__r.Income_Block__r.BDR__r.BDR_Name__c,
                   Income_Block_Period__r.Income_Block__r.BDR__r.Id,

                   Income_Block_Period__r.Income_Block__r.BDR__r.Income_Source__r.Name,
        
                   Funding_Requirement__c,
        
                   Allocation_Amount__c
                   
                   from fund_allocation__c where Funding_Requirement__c in (select id from Funding_Requirement__c where Service__c  =: svc.id ) 
                   and Income_Block_Period__r.Income_Block__r.BDR__r.Status__c in ('Draft', 'Accepted', 'Proposed', 'Live')
                   order by Fiscal_Year__c desc
                   
                   ];

    system.debug('BDR Service Cost Summary Allocations: ' + allocations.size());
 
    List<Funding_Requirement__c> lisFR = [select id, name, Fiscal_Year__c, Total_Amount__c , Total_Cover_Potential__c, Total_Cover_Potential_Percent__c from Funding_Requirement__c where Service__c =:svc.id order by Fiscal_Year__c desc];

    system.debug('BDR Service Cost Summary Funding Requirements: ' + lisFr.size());

    for (Funding_Requirement__c fr : lisFr) {
    
        BdrFundReqWrapper frW = new BdrFundReqWrapper(fr);
        for (Fund_Allocation__c fa : allocations) {
        
            if (fa.Funding_Requirement__c == fr.id) {
                frW.addAllocationToList(fa); 
                system.debug('BDR Service Cost Summary Adding Fa to Fr: ' + fa.id + ':' + fr.id);
            }
        
        }
        fundReqWrappers.add(frW);
        system.debug('BDR Service Cost Summary Add FundReqWrapper: ' + fundReqWrappers.size());    
    
    }    

 }

}