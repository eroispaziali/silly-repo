public class UIParticipantRLController {

  public List<UIParticipantRelationshipWrapper> relationships { get;set; }
  public UI_Participant__c participant { get; set; }  

  public String getNewRelationshipUrl()
  {
    
    Map<String, String> relationshipObjectFields = CustomUtils.getObjectFieldIds('UI_Participant_Relationship__c'); 
    String sQueryString = '?' + relationshipObjectFields.get('Primary_Participant') + '=' + this.participant.Name;
    sQueryString = sQueryString  + '&' + relationshipObjectFields.get('Primary_Participant') + '_lkid=' + this.participant.id;
    sQueryString = sQueryString + '&retURL=%2F' + this.participant.id; 
       
    return '/' + UI_Participant_Relationship__c.SObjectType.getDescribe().getKeyPrefix() + '/e' + sQueryString;           
      
  }
  

  public UIParticipantRLController (ApexPages.StandardController controller) {

        participant = (UI_Participant__c)controller.getRecord();
        relationships = new List<UIParticipantRelationshipWrapper>();
        
        
        if ( participant.id != null ) {
           List<UI_Participant_Relationship__c> lisRelationships = [select id, Name, Primary_Participant__c, Primary_Participant__r.Name, Related_Participant__c, Related_Participant__r.Name
                                                                    from UI_Participant_Relationship__c
                                                                    where 
                                                                    Primary_Participant__c =: participant.id OR 
                                                                    Related_Participant__c =: participant.id];


            for ( UI_Participant_Relationship__c relationship : lisRelationships ) {
            
                  relationships.add(new UIParticipantRelationshipWrapper(participant.id, relationship));              
            
            }

        }
        
        
                                                                    
  }


  public class UIParticipantRelationshipWrapper
  {

     public String primaryId { get; set; } 

     public UI_Participant_Relationship__c relationship { get; set; }

     public boolean isPrimary {
     
         get { return this.primaryId == relationship.Primary_Participant__c; }
         set;
     }
     
     public String participantName {
     
         get { return this.isPrimary ? this.relationship.Related_Participant__r.Name : this.relationship.Primary_Participant__r.Name; }
         set;
     
     }
     
     public String participantId {
     
         get { return this.isPrimary ? this.relationship.Related_Participant__c : this.relationship.Primary_Participant__c; }
         set;
     
     }


     public UIParticipantRelationshipWrapper(String id, UI_Participant_Relationship__c relationship){
         
         this.primaryId = id;
         this.relationship = relationship;
     
     }
     
     
  }
  

}