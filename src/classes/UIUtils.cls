/*******************  USER INVOLVEMENT  *************************************
   * @author          gary.grant@conseq.co.uk
   * @date            November 2014
   * @description     A set of utility methods for User Involvement
                      
   *     
   ***************************************************************************/  

public without sharing class UIUtils {

	
	public static void setParticipantDeceased(Contact contact)
	{
		List<Contact> lis = new List<Contact>();
		if (contact != null) lis.add(Contact);
		setParticipantsDeceased(lis); 
	}


    /* For a deceased Contact, find the Participant and set them deceased 
       This can be used from a Trigger
    */
	public static void setParticipantsDeceased(List<Contact> lisContacts)
	{
			     
		List<String> lisContactIds = new List<String>();	
		for (Contact c : lisContacts) {		
			if ( c.Deceased__c == true ) {
			    lisContactIds.add(c.id);
			}		
		}	
			  		
		List<UI_Participant__c> lisParticipants = [select id, Name, Status__c from UI_Participant__c where Contact__c in:lisContactIds and Status__c !='Merged'];
		List<UI_Participant__c> lisParticipantsToUpdate = new List<UI_Participant__c>();
		
		List<String> lisParticipantIds = new List<String>();		
		for (UI_Participant__c p : lisParticipants) {			
							
			if (p.Status__c != 'Deceased') { 
				p.Status__c = 'Deceased';
				lisParticipantsToUpdate.add(p);
			}
		}		
				  
		update lisParticipantsToUpdate;		  
		
		List<ProcessInstanceWorkitem> lisWorkItems =  [Select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in: lisParticipantsToUpdate];		
		for (ProcessInstanceWorkitem piwi : lisWorkItems) {
		
			try {
		            
				system.debug('*^*^* : In Participant Trigger for Deceased Contact: Processing Piwi ' + piwi.id);
													    
		    	Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
		    	req2.setComments('Rejected because the Person is deceased.');
		    	req2.setAction('Reject');        		        
		    	req2.setWorkitemId(piwi.id);        
		    	Approval.ProcessResult result2 =  Approval.process(req2);	    		
	
			}
							
			catch (Exception x) {
				system.debug('Auto Workflow approval on deceased Participant failed ' + piwi.id);
				system.debug(x.getMessage());
			}
		
		}
				
		
	}

    /* Create manual sharing records for the Person. This will share the Person record to
       users in the User Involvement User public group
    */   
    public static Boolean doSharePersonRecords(List<String> lisContactIds)
    {
    
        if (lisContactIds== null || lisContactIds.isEmpty()) { return true; }
    
        //Get the id of the User Involvement Public Group
        Group grp = [select id from Group where DeveloperName = 'User_Involvement_Users'];
        if (grp==null) {            
            return false;
        }
        
        String userOrGroupId = grp.id;
                
        List<ContactShare> lisContactShares = [SELECT Id, ContactId FROM ContactShare WHERE ContactId IN :lisContactIds AND UserOrGroupId =: userOrGroupId and RowCause='Manual'];
        
        Map<String, ContactShare> mapContactShares = new Map<String, ContactShare>();
        for (ContactShare share : lisContactShares) {
            mapContactShares.put(share.ContactId, share);
        }
                
        List<ContactShare> lisContactSharesAdd = new List<ContactShare>();        
        for (String id : lisContactIds) {

            ContactShare sh = mapContactShares.get(id);
            system.debug(sh==null);         
            
                
            if ( sh == null ) {
                
                system.debug('UI_Participant : Creating Sharing Rule : ' + id);
                    
                ContactShare share = new ContactShare();
                share.ContactId = id;
                share.ContactAccessLevel ='Read';
                share.RowCause = 'Manual';
                share.UserOrGroupId = grp.id;
                
                lisContactSharesAdd.add(share);                             
            }
    
        }
        
        insert lisContactSharesAdd;
        return true;
    
    }

    /* Remove manual sharing records for the Person. This will remove share records for the Person record for
       users in the User Involvement User public group
    */
    public static Boolean doUnsharePersonRecords(List<String> lisContactIds)
    {
        
        if (lisContactIds== null || lisContactIds.isEmpty()) {  return true; } 
        
        //Get the id of the User Involvement Public Group
        Group grp = [select id from Group where DeveloperName = 'User_Involvement_Users'];
        if (grp==null) {        
            return false;
        }
        
        String userOrGroupId = grp.id;
        
        List<ContactShare> lisContactSharesRemove = [SELECT Id FROM ContactShare WHERE ContactId IN :lisContactIds AND UserOrGroupId =: userOrGroupId and RowCause = 'Manual'];
        if (lisContactSharesRemove.size()>0) {          
            delete lisContactSharesRemove;          
        }
        
        return true;
    }

	/* If the Person is an active service user, get the name of the Service Managers 
       Supports bulk updates by returning a Map keyed on Person Id      
    */        
    public static Map<String, Service_Usage__c> getSuServiceManagers(List<String> lisContactIds)
    {
        
        Map<String, Service_Usage__c> mapSu = new Map<String, Service_Usage__c>();
            
        List<Service_Usage__c> lisSu = 
                            [select id, Primary_Service_User__c, Service_Field__c, Service_Field__r.SSM__c, Service_Field__r.SSM__r.Name, Service_Field__r.SSM__r.IsActive from Service_Usage__c 
                                where 
                                Primary_Service_User__c in :lisContactIds and
                                Referral_Outcome__c in ('Service Required', 'Case Opened', 'Active User') and 
                                Closure_Date__c = null and 
                                Service_Field__r.SSM__c <> null and 
                                Service_Field__r.SSM__r.isActive = true
                                order by Primary_Service_User__c, LastModifiedDate asc];

        if ( lisSu.isEmpty() ) { return mapSu; }
        
        /* The sort order of the query ensures that the most recent SU will get into the map for each user
           since the map can only have one entry per user
        */
        for (Service_Usage__c su : lisSu) {                 
             mapSu.put(su.Primary_Service_User__c, su);
        }                                   
        
        return mapSu;
        
    }



    
    /* Prepare for submission into approval
       Note : the function does not call update on the Participant
       
       Approval is only actually required for users who do not normally 
       have access to the Person record. This value is ignored for all other users          
    */
    public static boolean setParticipantRequiresApproval(UI_Participant__c p, Service_Usage__c su)
    {
        boolean bActive = false;
        boolean bSSM = true;
        
        system.debug('Setting Participant SU Details');
        
        if ( p.Status__c == 'Active' ) {            
            bActive=true;                        
            system.debug('Setting Participant SU Details - Active is True');
        }


        /* If there is no service manager or the service manager is no longer with the Society
           Then this process should mail the Engagement and Participation Officer
           for the relevant region
           NOTE : EPO's are not in Salesforce at the moment, so cannot be identified                      
            */         
        if ( su==null || su.Service_Field__c==null || su.Service_Field__r.SSM__c==null || su.Service_Field__r.SSM__r.isActive==false ) {           
            
            system.debug('Setting Participant SU Details - SU_SSM is null or other');
            
            p.SU_SSM__c = null;
            bSSM = false;

        } else { 

			//!!! TODO Engagement and Participation Officers need to be plugged in here
			//    and asked to do the approval if there is no Service Manager available. 

			system.debug('Setting Participant SU Details - SU_SSM is being Set to ' + su.Service_Field__r.SSM__c);

            p.SU_SSM__c = su.Service_Field__r.SSM__c;
            bSSM = true;

        }

        if ( (bActive == false) && (bSSM == true)) {
            p.Requires_Approval__c = true;
            
            system.debug('Setting Participant SU Details - Requires Approval is set to True');
            
            return true;
        }
        
        return false;    
        
    }
    
    
    public static Service_Usage__c getLatestServiceUsage(String contactId) {
    
    			 
		   List<Service_Usage__c> lisSu =   
		         [select id, Primary_Service_User__c, Service_Field__c, Service_Field__r.Name, Service_Field__r.SSM__c, Service_Field__r.SSM__r.Name, Service_Field__r.SSM__r.IsActive from Service_Usage__c 
		          where 
		          Primary_Service_User__c =:contactId and
		          Referral_Outcome__c in ('Service Required', 'Case Opened', 'Active User') and 
		          Closure_Date__c = null and
		          Service_Field__r.SSM__c <> null and 
		          Service_Field__r.SSM__r.isActive = true
		          order by LastModifiedDate desc];
		        	             
		    if (!lisSu.isEmpty()) {
		    	
		    	 Service_Usage__c su = lisSu[0];
		    	 system.debug('Fetching Service Usage: ' + su.id + ':' + su.Service_Field__r.SSM__r.Name); 
		       	 return su;
	    	}
	         
	        return null;
    }
    
 }