trigger BDR_InitBdrData on BDR__c (before insert, before update) {

  /************************************************************************************************ 
     @author            gary.grant@conseq.co.uk   
     @date              June 2014
     @description       Set Fiscal Years and Update Notifications
     
  **************************************************************************************************/  

  for(BDR__c bdr : trigger.new) {
    

        /* July 2014
            
            Fiscal Years are now computed based on Intended Start Date and Estimated Duration in Months
            They are no longer input on the form
            
            This code is in the trigger because any action that changes the Start Date and Number of Months should 
            update the fiscal years -  that should happen in all cases.
            
            Note that post update associated BDR records may be updated/created/deleted when the change to Fiscal Years is
            noticed (Fiscal Years cannot be computed at the same time because the BDR itself cannot be updated in the PostUpdate
            trigger).
            
        */
        
         List<String> lisFiscalYears=BdrUtils.computeFiscalYearSpan(bdr.Intended_Start_Date__c , bdr.Estimated_Duration__c);       
         String sFiscalYears = (lisFiscalYears.isEmpty() ? null : String.join(lisFiscalYears,';'));     
       
         system.debug('BDR_InitBdrData   Trigger computed BDR Fiscal Years: ' + sFiscalYears);
       
       /* For insert processing */  
       if (trigger.isInsert) {
           system.debug('BDR_InitBdrData inserting computed BDR Fiscal Years: ' + sFiscalYears);
           bdr.Fiscal_Years__c=sFiscalYears;
       }    
   
    
       /* For update processing */           
           if (trigger.isUpdate) {
           system.debug('BDR_InitBdrData update processing');
        
                BDR__c bdrBeforeUpdate = trigger.oldMap.get(bdr.id);
            
                if (sFiscalYears != bdrBeforeUpdate.Fiscal_Years__c) {
                    system.debug('BDR_InitBdrData Updating BDR Fiscal Years: ' + sFiscalYears);
                    bdr.Fiscal_Years__c=sFiscalYears;
                }
           }            

           /* For both update and insert */        
       // Clear the notification action flag if there are no more pending notifications
        if (bdr.Notification_Action__c=='Y' && 
            (bdr.Notifications_Pending__c==null || bdr.Notifications_Pending__c.trim()=='')
            ) 
        {                  
            system.debug('BDR_InitBdrData setting Notification Action to null');
            bdr.Notification_Action__c=null;
        } 
 }

}