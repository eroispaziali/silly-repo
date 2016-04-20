/**
 */
@isTest
private class UIParticipantRLController_Test {

    @isTest (SeeAllData=true)
    static void TestUIParticipantRLController()
    {
    
        Contact contact = UiUtils_Test.getTestContact();
        Contact contact2 = UiUtils_Test.getTestContact2(); 

        UI_Participant__c p = UiUtils_Test.getTestParticipant(contact,false);
        UI_Participant__c p2 = UiUtils_Test.getTestParticipant(contact2,false);
        
        UI_Participant_Relationship__c relationship = UiUtils_Test.getTestRelationship(p, p2); 
    
        ApexPages.StandardController sc = new ApexPages.standardController(p);
                
        UIParticipantRLController e = new UIParticipantRLController(sc);
        
        List<UIParticipantRLController.UIParticipantRelationshipWrapper> lisWrappers = e.relationships;
        for ( UIParticipantRLController.UIParticipantRelationshipWrapper wrapper : lisWrappers ) {
        
            string s = wrapper.participantName;
            s = wrapper.participantId;
            boolean b = wrapper.isPrimary;        
            
        }
        
        String sUrl = e.getNewRelationshipUrl();
        
    }
    
}