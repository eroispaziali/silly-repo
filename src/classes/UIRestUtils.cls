global without sharing class UIRestUtils {

  /*******************  USER INVOLVEMENT  *************************************
   * @author          gary.grant@conseq.co.uk
   * @date            November 2014
   * @description     A set of methods that can be called by custom buttons 
                      on Standard page layouts in the User Involvement Application
                      
                      Sample code : 
                        {!REQUIRESCRIPT("/soap/ajax/32.0/connection.js")} 
                        {!REQUIRESCRIPT("/soap/ajax/32.0/apex.js")} 
                        
                        var sUrl = "" + sforce.apex.execute(
                            "UIRestUtils",
                            "getParticpationUrl",
                            {activityId:window.sfdcPage.entityId}); 
                        
                        if (sUrl.length > 0) { 
                            alert(sUrl); 
                        } 
                        else { 
                            alert("Webservice call failed!"); 
                        }             
                      
   *     
   ***************************************************************************/  

  /** Create a new participation record */ 
  webService static String getParticipantParticipationUrl(String participantId) {
           
        UI_Participant__c p = [select Id, Name, Status__c, Valid_To_Date__c from UI_Participant__c where id =:participantId];
        if (p.Status__c !='Active' || p.Valid_To_Date__c < Date.today() ) {
            return 'Error: Participant Status must be active and review date not exceeded to create Participation';            
        } 
        
        /* This uses the URL Hack to get the fields pre-populated in the standard form. That 
           allows the user to back out of creating the record by hitting cancel.
         
           Custom fields take a CF prefix on lookup fields
           The Name field is identified by name only
        */
         
        Map<String, String> participationObjectFields = CustomUtils.getObjectFieldIds('UI_Activity_Participation__c'); 
        String sQueryString = '?' + participationObjectFields.get('UI_Participant') + '=' + p.Name;
        sQueryString = sQueryString  + '&' + participationObjectFields.get('UI_Participant') + '_lkid=' + p.id;
        sQueryString = sQueryString + '&' + participationObjectFields.get('Status') + '=Planned';
              
        PageReference pr = new PageReference('/' + UI_Activity_Participation__c.SObjectType.getDescribe().getKeyPrefix() + '/e' + sQueryString);
        pr.setRedirect(true);
        
        return pr.getUrl();
  
  }


webService static String getActivityParticpationUrl(String activityId)
    {
   
       UI_Activity__c activity = [select Id, Name, Start_Date__c, End_Date__c from UI_Activity__c where id =:activityId];
    
        /* This uses the URL Hack to get the fields pre-populated in the standard form. That 
           allows the user to back out of creating the record by hitting cancel.
         
           Custom fields take a CF prefix on lookup fields
           The Name field is identified by name only
        */
    
        Map<String, String> mapParticipationObjectFields = CustomUtils.getObjectFieldIds('UI_Activity_Participation__c'); 
                
        String sQueryString = '?' + mapParticipationObjectFields.get('UI_Activity') + '=' + activity.Name;
        sQueryString = sQueryString  + '&' + mapParticipationObjectFields.get('UI_Activity') + '_lkid=' + activity.id;
        
        DateTime dt = activity.Start_Date__c;
        String startDate = dt.format('dd/MM/yyyy');
        
        dt=activity.End_Date__c;
        String endDate = dt.format('dd/MM/yyyy');
            
        sQueryString = sQueryString + '&' + mapParticipationObjectFields.get('Start_Date') + '= ' + startDate;
        sQueryString = sQueryString + '&' + mapParticipationObjectFields.get('End_Date') + '= ' + endDate;
    
        sQueryString = sQueryString + '&' + mapParticipationObjectFields.get('Status') + '=Planned';
              
        String url = '/'+ UI_Activity_Participation__c.SObjectType.getDescribe().getKeyPrefix() + '/e' + sQueryString;
                      
        return url;     
        
}


webService static String getParticipantUrl(String contactId)
    {
   
        UI_Participant__c p = null; 
   
        try {                     
              p = [select id from UI_Participant__c where Status__c != 'Merged' and Contact__c =: contactId];                              
        
        } catch (Exception x) {
          
            // Get the contact record
            Contact contact = [select id, firstName, lastName, Name from Contact where id =: ContactId];  
          
            
            /*  The record has to be created in all cases and the user diverted to the view screen. 
            
				The New (UI_Participant__c) action has to be overriden to divert to the search screen everywhere in
                the application, to ensure no participants are created that duplicate existing contacts. It should not be possible
                to create a new Participant__c without going thru the duplicate screen, aside from directly out of the Contact form.  
                
            */
            
            p = new UI_Participant__c();
            p.Contact__c=contact.id;
            p.Name = contact.Name;
            p.Status__c = 'Unconfirmed'; 
            insert p;
              
        }
              
        PageReference pr = new PageReference('/' + p.id);                          
        pr.setRedirect(true);
                   
        return pr.getUrl();
}

    
}