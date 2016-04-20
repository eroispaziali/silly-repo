/**
 */
@isTest
private class UIParticipantControllerExtension_Test {

    @isTest (SeeAllData=true)
    static void TestUIParticipantControllerExtension()
    {
    
        User u1 = UiUtils_Test.getTestUser1();
        User u2 = UiUtils_Test.getTestUser2(u1);
        Contact contact = UiUtils_Test.getTestContact();
        Account acct = UiUtils_Test.getTestAccount();
        Services__c svc = UiUtils_Test.getTestService(acct);
    
        Service_Usage__c su = UIUtils_Test.getTestServiceUsage(u1, u2, contact, acct, svc);
        UI_Participant__c p = UiUtils_Test.getTestParticipant(contact,false);
    
        ApexPages.StandardController sc = new ApexPages.standardController(p);
        
        p.Status__c = 'Unconfirmed';
        p.Consent_Type__c = 'Written';
        p.Valid_From_Date__c = Date.Today();
        
        UIParticipantControllerExtension e = new UIParticipantControllerExtension(sc);
        
        List<SelectOption> lisOptions = e.getActivity_Types_Options();
        lisOptions = e.getAreas_Of_Expertise_Options();
        lisOptions = e.getMethods_Of_Involvement_Options();
        
        Service_Usage__c su2 = e.su;
    
        e.clicked();
        
        e.saveRecord();
        e.save();
        e.saveAndClose();
        
        p.Status__c = 'Active';
        e.saveRecord();   
        
    }
    
    @isTest (SeeAllData=true)
    static void TestUIParticipantControllerExtension2()
    {
    
        User u1 = UiUtils_Test.getTestUser1();
        User u2 = UiUtils_Test.getTestUser2(u1);
        Contact contact = UiUtils_Test.getTestContact();
        Account acct = UiUtils_Test.getTestAccount();
        Services__c svc = UiUtils_Test.getTestService(acct);
    
        Service_Usage__c su = UIUtils_Test.getTestServiceUsage(u1, u2, contact, acct, svc);
        UI_Participant__c p = UiUtils_Test.getTestParticipant(contact,false);
    
    	User u = UiUtils_Test.getTestUserInPermissionSet();
    	System.RunAs(u) { 
    
	        ApexPages.StandardController sc = new ApexPages.standardController(p);
	        
	        p.Status__c = 'Unconfirmed';
	        p.Consent_Type__c = 'Written';
	        p.Valid_From_Date__c = Date.Today();
	        
	        UIParticipantControllerExtension e = new UIParticipantControllerExtension(sc);
	        
	        p.Status__c = 'Active';
	        
	        try {
	        	 e.saveRecord();
	        } catch (Exception x) {
	        	//Do nothing;
	        }  
    	
    	} 
        
    }
    
    @isTest (SeeAllData=true)
    static void TestUIParticipantRequestApproval()
    {
    
        User u1 = UiUtils_Test.getTestUser1();
        User u2 = UiUtils_Test.getTestUser2(u1);
        Contact contact = UiUtils_Test.getTestContact();
        Account acct = UiUtils_Test.getTestAccount();
        Services__c svc = UiUtils_Test.getTestService(acct);
    
        Service_Usage__c su = UIUtils_Test.getTestServiceUsage(u1, u2, contact, acct, svc);
        UI_Participant__c p = UIUtils_Test.getTestParticipant(contact,false);
    
        ApexPages.StandardController sc = new ApexPages.standardController(p);
        
        p.Status__c = 'Unconfirmed';
        p.Consent_Type__c = 'Written';
        p.Valid_From_Date__c = Date.Today();
        
        UIParticipantControllerExtension e = new UIParticipantControllerExtension(sc);        
        e.saveAndRequestApproval();
    
    }

}