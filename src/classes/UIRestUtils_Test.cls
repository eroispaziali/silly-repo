/**

 */
@isTest
private class UIRestUtils_Test {

	/* Test the methods that generate URL strings for the action buttons on the Page layouts
   		These URLS redirect to create pages for other objects */ 
	@isTest(SeeAllData=true)    
	static void testWebServiceGetUrls() {
                   
        Contact contact = UiUtils_Test.getTestContact();           
        UI_Programme__c programme = UIUtils_Test.getTestProgramme();
        UI_Activity__c activity = UIUtils_Test.getTestActivity(programme);
        
        String s = UIRestUtils.getParticipantUrl(contact.id);
        
        UI_Participant__c participant = UiUtils_Test.getTestParticipant(contact,true);                
    	s = UIRestUtils.getParticipantParticipationUrl(participant.id);     
    	s = UIRestUtils.getActivityParticpationUrl(activity.id);
    	    	
	}	
	
}