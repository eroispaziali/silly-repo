public without sharing class BdrServiceWrapperUtils
{
   /***************************************************************************
   * @author       gary.grant@conseq.co.uk
   * @date         April 2013
   *    
   *  
   *               **** CAUTION ****
   *               A without sharing class used in the BDCS application that enables 
   *               any user to create records associated with Services, even if they 
   *               do not normally have access to edit the actual service
   *  
   *               This is necessary because in most cases BDC profile users wil not have
   *               sufficient rights over services
   *    
   *****************************************************************************/
   
   public static Evidence_For_Need__c createEfn(String id)
   {   
       system.debug('Creating a new EvidenceForNeed:' + id); 
       Evidence_For_Need__c en = new Evidence_For_Need__c();
       en.service__c = id;
       en.isCurrent__c=true;
       en.Release_Date__c = date.today();
       return en;
    }
    
   public static boolean updateEvidence(Evidence_For_Need__c evidence, Services__c svc)
   { 
    
    /*    If the efn has not been saved before, make sure it gets the latest 
          svc id.
          
          In the case where a save attempt on a new bdr_service_add_update page failed validation, the database transaction will 
          have been rolled back. In that case a new Service database record would be created when the user attempted to save
          again after correcting the error. The efn in-memory-object may still carry the original svc record id, which would
          now have been disgarded and replaced (after the roll-back).  
       */
    
     try {    
      
          if (evidence.id==null || evidence.service__c==null) { evidence.service__c=svc.id; }
          
          upsert evidence;
          System.debug('Efn Save Success:' + evidence.Service__c);
      }
      
      catch (DmlException e) {

        String msg=e.getMessage();
        System.debug('Efn Save Failure:' + evidence.Service__c); 
        svc.addError('Efn Save Failure:' + e.getDmlMessage(0)); 
        return false;
              
      }
        
      return true;
   } 

   public static boolean updateFundingRequirements(List<Funding_Requirement__c> fundingData, Services__c svc)
   {
        
       /* If the fr has not been saved before, make sure it gets the latest 
          svc id.
          
          In the case where a save attempt on a new bdr_service_add_update page failed validation, the database transaction will 
          have been rolled back. In that case a new Service database record would be created when the user attempted to save
          again after correcting the error. The fr in-memory-object may still carry the original svc record id, which would
          now have been disgarded and replaced (after the roll-back).  
       */       
       for  (Funding_requirement__c fr : fundingData) {
         if(fr.id==null || fr.service__c==null) { fr.service__c=svc.id; }
       }
    
        try {
            if (!fundingData.isEmpty()) {
                upsert fundingData;
            }
        }
        catch (DmlException e) {
    
              String msg=e.getMessage();
    
              System.debug('Insert Funding Requirements:');
              for (Funding_Requirement__c c : fundingData) {
                System.debug('-- Year:' + c.Fiscal_Year__c + '; Funding Requirement:' + c.Service__c); 
              }
              
              /* Catch duplicate values in fiscal year */
              System.Debug('Error Message :' + msg);               
              svc.addError('Funding Requirement Error: ' + e.getDmlMessage(0)); 
    
              return false;
              
        }
        
        // Return to new service contract page
        return true;
   } 

}