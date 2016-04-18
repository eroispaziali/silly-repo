/**
 */
@isTest
private class UIDemographicInfoRLController_Test {

    /* This page is inserted into the UI_Participant__c Object Layout */
	static testMethod void testUIDemographicInfoRLController()
	{   
		Contact contact = UIUtils_Test.getTestContact();
	    UI_Participant__c p = UIUtils_Test.getTestParticipant(contact,true);
	    
	    ApexPages.currentPage().getParameters().put('Id',p.id);
	    ApexPages.StandardController sc = new ApexPages.standardController(p);
	    UIDemographicInfoRLController e = new UIDemographicInfoRLController(sc);
	    
	    e.create();
	    
	}
}