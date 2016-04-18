trigger BDR_SyncChildRecords on BDR__c (after update) {

    /******************************************************************************************************** 
     @author 				gary.grant@conseq.co.uk   
     @date 					April 2013   
     @description 		Trigger for the BDR Object that runs after update. Updates related objects to reflect a change in status on a BDR
     
     The process creates a BDRWrapper for each object in trigger.new, so may generate a number of queries if used against a list of BDR__c objects.     
     
     Implemented as a Trigger because the update of BDR status may be initated by a workflow action, in which case it is not possible to manually 
     call the sync method from the save action of a Controller Extension.       
    **********************************************************************************************************/  

    for (BDR__c bdr : trigger.new) {
    
       BDR__c beforeUpdate = trigger.oldMap.get(bdr.id);
     
       /* Only create the BDRWrapper where necessary - using the boolean selections from below */
       BDRWrapper bdrWrapper = null;
       
       if (bdr.Status__c != beforeUpdate.Status__c || 
	          	bdr.OwnerId != beforeUpdate.OwnerId ||
	          	bdr.Fiscal_Years__c != beforeUpdate.Fiscal_Years__c ) 
        {
    	  system.debug('BDR_SyncChildRecords creating BDR Wrapper');
          bdrWrapper = new BdrWrapper(bdr);
        }

       // If the Status__c value has changed, update the Contract status, Income Block Status, Fund Allocation Status, Service Status as appropriate     
     
       if (bdr.Status__c != beforeUpdate.Status__c) {
       		system.debug('BDR_SyncChildRecords Syncing Status');
          	bdrWrapper.syncAssociatedStatus(bdr.Status__c);
        }    

       /* Sync the owners of the related objects */ 
       if (bdr.OwnerId != beforeUpdate.OwnerId) {
			system.debug('BDR_SyncChildRecords Syncing Owner');
          	bdrWrapper.syncOwner();
        }    

      /* 
        Render the current state of the BDR as an html attachment at certain workflow milestones.
        if ((bdr.Status__c=='Accepted'||bdr.Status__c=='Proposed') && bdr.Status__c!=beforeUpdate.status__c) {
          String attName = bdr.Name + ' '+ bdr.Status__c +  '.html';
          String attDescription = bdr.Name + '  snapshot at ' + bdr.Status__c ;
          BdrPdfUtils.storeHtmlAttachment(attName, attDescription, bdr); 
       }
      */
        
     /*
       Sync the Fiscal Year related data if the fiscal years have changed 
       This will remove or create related objects based on the change to the selection of Fiscal Years.         
    */
    
    system.debug('BDR_SyncChildRecords this BDR Fiscal Years: ' + bdr.Fiscal_Years__c);
    system.debug('BDR_SyncChildRecords old  BDR Fiscal Years: ' + beforeUpdate.Fiscal_Years__c);
    
    if (bdr.Fiscal_Years__c != beforeUpdate.Fiscal_Years__c) {
		system.debug('BDR_SyncChildRecords Syncing Fiscal Years');
      	bdrWrapper.syncFiscalYears(false);
    }

    //BDRUtils.refreshBdrDependenceLinks(bdr.id); 
    }

}