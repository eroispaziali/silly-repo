trigger UI_Init_Participant on UI_Participant__c (before insert, before update, after update, after insert) {
        
    /***********************************************************************************************************
    *
    *   @author        :  gary.grant@conseq.co.uk
    *   @date          :  November 2014
    *   @description   :  Update related records for User Involvement Participants                  
    *     
    ************************************************************************************************************/    
        
        
    Map<String, Contact> mapContacts =  new Map<String,Contact>();        
    List<String> lisContactIds = new List<String>();
  
    /* Get all the participant Contact Ids */        
    for (UI_Participant__c p : trigger.new) {    
        lisContactIds.add(p.Contact__c);        
    }
        
    /* Get the contacts and put them in a map */    
    List<Contact> lisContacts = [select id, Name from Contact where id in:lisContactIds];        

    for (Contact c : lisContacts) {    
       mapContacts.put(c.id, c);               
    }    
    
    
    if (Trigger.isBefore) {     
        
        /* Refresh the flag that indicates whether the Participant would 
           need approval when marking Active Status
        */
        Map<String, Service_Usage__c> mapServiceManagers = UIUtils.getSuServiceManagers(lisContactIds);           
        
        for (UI_Participant__c p : trigger.new) {               
            
            Contact contact = mapContacts.get(p.Contact__c);
            p.Name = contact.Name;
            
            if (p.Valid_To_Date__c ==null && p.Valid_From_Date__c !=null) {
            	p.Valid_To_Date__c = p.Valid_From_Date__c.addMonths(6);
            }
            
            Service_Usage__c su = (Service_Usage__c)mapServiceManagers.get(p.Contact__c);
            UIUtils.setParticipantRequiresApproval(p, su);
            
            /* Test if the User can set the record to Active. If not, send an error, and tell the user
               to set the status to Pending Confirmation and save again */
           if ( p.Status__c=='Active' 
                && Trigger.oldMap.get(p.id).Status__c!='Active' 
                && !CustomUtils.hasUserAccess(contact.id, UserInfo.getUserId(), 'Read')) {            
                
                /* If there is no Service Manager then there is no one to notify. 
                   In that case, the Engagement and Participation Officer should be notified                                
                   This indicates there is no active service usage, or no service manager to ask for
                   approval.
                */    
                if ( su !=null && su.Service_Field__r.SSM__c !=null ) {
                    p.addError('This person is an active Service User. You do not have privileges to set Status to Active. Submit the Participant for Approval and the Services Manager ( ' + su.Service_Field__r.SSM__r.Name + ' ) will be asked to approve the request.');         
                }    
                 
           }      
        } 
                
    }
    
    /* Share the Contact record is required */   
      
    if (Trigger.isAfter) {
               
        List<String> lisContactIdSharesRemove = new List<String>();     
        List<String> lisContactIdSharesAdd = new List<String>();        
    
        List<ContactShare> lisContactSharesAdd = new List<ContactShare>();      
        Map<String, ContactShare> mapContactShares = new Map<String, ContactShare>();
        
        /* Insert the contact Name from the map and create sharing rule */
        for (UI_Participant__c p : trigger.new) {    
            
            Contact contact = mapContacts.get(p.Contact__c);
        
            if (Trigger.isUpdate) {
                if (p.Status__c=='Active' && Trigger.oldMap.get(p.id).Status__c!='Active') {
                   lisContactIdSharesAdd.add(contact.id);                   
                } 
            
                if (p.Status__c!='Active' && Trigger.oldMap.get(p.id).Status__c=='Active') {
                    lisContactIdSharesRemove.add(contact.id);   
                }
            }
            
            if (Trigger.isInsert && p.Status__c=='Active') {
                   lisContactIdSharesAdd.add(contact.id);                   
            }
            
        }   
    
        /* Share or Unshare Person records for the User Involvement users based on the Status of the Participant */     
        UIUtils.doSharePersonRecords(lisContactIdSharesAdd);
        UIUtils.doUnsharePersonRecords(lisContactIdSharesRemove);        
            
    }        
                
}