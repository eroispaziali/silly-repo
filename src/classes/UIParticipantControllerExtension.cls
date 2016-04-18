public with sharing class UIParticipantControllerExtension extends BaseControllerExtension {
    
/*******************************************************************************************************************************************
@author             gary.grant@conseq.co.uk
@date               Jan 2014
@description        Controller Extension. 
  
                        A combined controller to handle creating and editing UI Participant record
  
********************************************************************************************************************************************/

 private UI_Participant__c participant;
  
 public String[] activity_types_selection {get;set;}  
 public String[] areas_of_expertise_selection{get;set;}  
 public String[] methods_of_involvement_selection {get;set;}
     
 public List<SelectOption> getActivity_Types_Options() {    
          return getOptionList(UI_Participant__c.Activity_Types__c.getDescribe());
 }  
  
 public List<SelectOption> getAreas_Of_Expertise_Options() {            
           return getOptionList(UI_Participant__c.Areas_of_Expertise__c.getDescribe());            
 }
 
  public List<SelectOption> getMethods_of_Involvement_Options() {    
         return getOptionList(UI_Participant__c.Methods_of_Involvement__c.getDescribe());    
 } 
 
 /* Generic method to get the picklist values */
 private List<SelectOption> getOptionList(Schema.DescribeFieldResult describeResult ) {    
     
          List<SelectOption> options = new List<SelectOption>();                
          
          // Get the picklist values
          List<schema.picklistentry> values = describeResult.getPickListValues();
          for (Schema.PicklistEntry entry : values) {
               options.add(new SelectOption(entry.getLabel(), entry.getValue()));
          }
          return options;  
 }  
  
 /* See the save method for how these values are set */ 
 public boolean saveResult {get;set;}
 public boolean activeRequiresApproval{
 	get {    
         return ( participant.Requires_Approval__c==true &&         
       	   		  !CustomUtils.hasUserAccess(participant.Contact__c, UserInfo.getUserId(), 'Read')); 	       			       		 	
 	}
 	set;
 }  
  
 public UIParticipantControllerExtension(ApexPages.StandardController controller) 
 {
     
        // Call the constructor of BaseControllerExtension
         super(controller);
     
         // ctl is the StandardController set in BaseControllerExtension
         participant=(UI_Participant__c)ctl.getRecord();

        // Populate the Muli-value checkbox arrays from the associated picklist values in the object data
         activity_types_selection = participant.Activity_Types__c==null ? new List<String>() : participant.Activity_Types__c.split(';');
         areas_of_expertise_selection = participant.Areas_of_Expertise__c==null ? new List<String>() : participant.Areas_Of_Expertise__c.split(';'); 
		 methods_of_involvement_selection = participant.Methods_of_Involvement__c==null ? new List<String>() : participant.Methods_Of_Involvement__c.split(';');
           
         if (participant.id==null) {
            participant.Status__c='Unconfirmed';             
         }
         
 }
 
 /* Get an Active Service Usage record for the current Participant, if on exists 
    Fetched using a without sharing sub class 
 */ 
 public Service_Usage__c su { 
 	
 	get {	 	
	 	if (su != null) { return su; }	 
	 	return UIUtils.getLatestServiceUsage(participant.Contact__c);
 	}
 	set;        
 }
 
 public boolean saveRecord()
 {     
     
  ctl.getRecord().put('Activity_Types__c',   String.join(activity_types_selection,';'));
  ctl.getRecord().put('Methods_of_Involvement__c',   String.join(methods_of_involvement_selection,';'));
  ctl.getRecord().put('Areas_of_Expertise__c',   String.join(areas_of_expertise_selection,';'));
     
   
  if   (ctl.save()==null) {
       
       /* The trigger will have set the RequiresApproval value on the record */  
	   participant=(UI_Participant__c)ctl.getRecord();
	   
	   saveResult=false;	   		
       return false;		       
  }    
    
  participant=(UI_Participant__c)ctl.getRecord();      
  saveResult=true;
    
  /* Update the time stamp to avoid erroneous contention errors */
  oSystemModStamp = (DateTime)ctl.getRecord().get('SystemModStamp');
  
  return true;

 }
 
 public pageReference clicked()
 {          
  	return null;
 }
 
 
 public pageReference save()
 {          
 	saveRecord();
  	return null;
 }
 
 /* Request Approval for setting the participant to active. 
    This is required if the user does not have sufficient access
    to set Active Status, which is the case for non-CRS users
    where the Person is an active service user
  */
 public pageReference saveAndRequestApproval()
 {
 	ctl.getRecord().put('Status__c','Pending Approval');
 	ctl.getRecord().put('OwnerId', UserInfo.getUserId());
 	if( saveRecord() ) {
 		
 			// create the new approval request to submit
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitted for approval. Please approve this Participant for Active status.');
            req.setObjectId(participant.id);
            Approval.ProcessResult result = Approval.process(req);	 		
 	} 
 	
 	return new PageReference('/' + participant.id);
 	
 }
  
 public pageReference saveAndClose()
 {          
  
  if (saveRecord()) { 
  	return new PageReference('/' + participant.id);
  } else {
  	return null;
  }

 } 
  
}