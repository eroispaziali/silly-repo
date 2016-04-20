/**
 */
@isTest
private class UIParticipantSearchControllerExt_Test {

    /* Run a search for Participants */
    static TestMethod void testSearchParticipants()
    {
        Contact contact = UIUtils_Test.getTestContact();
        UI_Participant__c pNew = new UI_Participant__c();
        
        ApexPages.currentPage().getParameters().put('firstName','One'); 
        ApexPages.currentPage().getParameters().put('lastName','test'); 
        Apexpages.currentPage().getParameters().put('postCode','ABC123');
        Apexpages.currentPage().getParameters().put('birthDate','10/10/2014');    
        
        ApexPages.StandardController sc = new ApexPages.standardController(pNew);
        UIParticipantSearchControllerExtension e = new UIParticipantSearchControllerExtension(sc);
       
        e.contactId = contact.id;
        e.setAddContactOn();
        e.setSearchOn();
        
        boolean b = e.getIsSysAdmin();
        e.clicked();
        
        String sDebug = e.debugSoql;
                
        Integer i = e.getActiveParticipantCount();
        
        UI_Participant__c p = UiUtils_Test.getTestParticipant(contact,true);
        e.participantId = p.id;
        
        List<SelectOption> lis = e.getStatusOptions(); 
        List<String> lisSelection = new List<String>();    
        lisSelection.add(lis[0].getValue());
        e.status_selection = lisSelection;
      
        lis = e.getActivityTypeOptions();
        lisSelection = new List<String>();    
        lisSelection.add(lis[0].getValue());
        e.activity_type_selection = lisSelection;
      
        lis = e.getMethodOptions();
        lisSelection = new List<String>();    
        lisSelection.add(lis[0].getValue());
        e.method_selection = lisSelection;
         
        lis = e.getTopicOptions();
        lisSelection = new List<String>();    
        lisSelection.add(lis[0].getValue());
        e.topic_selection = lisSelection; 
         
        e.runSearch();
        
        e.toggleSort();
        e.setAddContactOn();
        e.setSearchOn();
              
    }
}