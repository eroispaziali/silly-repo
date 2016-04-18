@isTest
private class Test_addPeople {
    static testMethod void testAddDebateAttendees() {    
        // Add 10 new contacts that we can search for and transfer
        string UniqueKey = 'AbcDefGhi12345';
        list<Contact> c = New List<Contact>();
        Id [] fixedSearchResults = new Id[10];
        for (Integer i = 0; i < 10; i++) {
            Contact cnew = new Contact(Birthdate=System.today(),LastName = 'Test Contact ' + i, FirstName = UniqueKey);
            insert cnew;
            c.add(cnew);
            fixedSearchResults[i] = cnew.Id;
        }
        
        Debate__c debate = new Debate__c(Name = 'Test Debate');
        insert debate;
        
        // Get the current user and some other user
        // NOTE: There must be at least one other active user in the system!
        user anotheruserid = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id <> :UserInfo.getUserID() LIMIT 1];
        user currentuser = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id = :UserInfo.getUserID() LIMIT 1];
        
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.AddDebateAttendees;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the Debate
        ApexPages.StandardController stdCon = new ApexPages.StandardController(debate);
        
        // Create an instance of the page controller to test its methods
        //addContacts cntrlr = new addDebateAttendees();    // default constructor
        addDebateAttendees cntrlr = new addDebateAttendees(stdCon);     // visualforce extension constructor

        // Call the various Get/Set methods to test these
        // nothing to check for, just want to run the code 
        cntrlr.setSetDebugModeFALSE(true);
        cntrlr.setSetDebugModeTRUE(true);
        cntrlr.getSetDebugModeFALSE();
        cntrlr.getSetDebugModeTRUE();
        cntrlr.getShowBlockIfResults();
        cntrlr.setSearchText('Test Contact');
            
        // Run the Search against this criteria
        Test.setFixedSearchResults(fixedSearchResults);
        PageReference cntrlrResult = cntrlr.doSearch();
        
        // Confirm that the results match the number of contacts added above
        System.assertEquals(null, cntrlrResult);
        //System.assertEquals(c.size(), cntrlr.searchResults.size());
        
        // Enum the searchResult to test some of the code in this class
        // Nothing to test for here
        for (addContacts.TransferContactSearchResults sr : cntrlr.searchResults) {
            sr.getcontact();
            sr.getselected();
            sr.setselected(true);
            //sr.getCreatedDate();
            //sr.getLastModifiedDate();  
        }
        
        // Click the transfer button
        cntrlrResult = cntrlr.doSave();   
        cntrlr.cancel();
    }
    
    //
    //  TEST CAMPAIGN EVENTS
    //
    static testMethod void testCampaignEvents() {    
        // Add 10 new contacts that we can search for and transfer
        string UniqueKey = 'AbcDefGhi12345';
        list<Contact> c = New List<Contact>();
        Id [] fixedSearchResults = new Id[10];
        for (Integer i = 0; i < 10; i++) {
            Contact cnew = new Contact(Birthdate=System.today(),LastName = 'Test Contact ' + i, FirstName = UniqueKey);
            insert cnew;
            c.add(cnew);
            fixedSearchResults[i] = cnew.Id;
        }
        
        Campaign_Event__c event = new Campaign_Event__c(Name = 'Test Event');
        insert event;
        
        // Get the current user and some other user
        // NOTE: There must be at least one other active user in the system!
        user anotheruserid = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id <> :UserInfo.getUserID() LIMIT 1];
        user currentuser = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id = :UserInfo.getUserID() LIMIT 1];
        
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.AddAttendees;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the Debate
        ApexPages.StandardController stdCon = new ApexPages.StandardController(event);
        
        // Create an instance of the page controller to test its methods
        //addContacts cntrlr = new addDebateAttendees();    // default constructor
        addAttendees cntrlr = new addAttendees(stdCon);     // visualforce extension constructor

        // Call the various Get/Set methods to test these
        // nothing to check for, just want to run the code 
        cntrlr.setSetDebugModeFALSE(true);
        cntrlr.setSetDebugModeTRUE(true);
        cntrlr.getSetDebugModeFALSE();
        cntrlr.getSetDebugModeTRUE();
        cntrlr.getShowBlockIfResults();
        
        cntrlr.setAttendeeStatus('status');
        cntrlr.getAttendeeStatus();
        cntrlr.getAttendenceStatuses();
        
        // Run the Search against this criteria
        Test.setFixedSearchResults(fixedSearchResults);
        PageReference cntrlrResult = cntrlr.doSearch();
        
        // Confirm that the results match the number of contacts added above
        System.assertEquals(null, cntrlrResult);
        //System.assertEquals(c.size(), cntrlr.searchResults.size());
        
        // Enum the searchResult to test some of the code in this class
        // Nothing to test for here
        for (addContacts.TransferContactSearchResults sr : cntrlr.searchResults) {
            sr.getcontact();
            sr.getselected();
            sr.setselected(true);
            //sr.getCreatedDate();
            //sr.getLastModifiedDate();  
        }
        
        // Click the transfer button
        cntrlrResult = cntrlr.doSave();   
        cntrlr.cancel();
    }
    
    //
    // TEST EDM SPONSORS
    //
    static testMethod void testAddEDMSponsors() {    
        // Add 10 new contacts that we can search for and transfer
        string UniqueKey = 'AbcDefGhi12345';
        list<Contact> c = New List<Contact>();
        Id [] fixedSearchResults = new Id[10];
        for (Integer i = 0; i < 10; i++) {
            Contact cnew = new Contact(Birthdate=System.today(),LastName = 'Test Contact ' + i, FirstName = UniqueKey);
            insert cnew;
            c.add(cnew);
            fixedSearchResults[i] = cnew.Id;
        }
        
        EDM__c debate = new EDM__c(Name = 'Test EDM');
        insert debate;
        
        // Get the current user and some other user
        // NOTE: There must be at least one other active user in the system!
        user anotheruserid = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id <> :UserInfo.getUserID() LIMIT 1];
        user currentuser = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id = :UserInfo.getUserID() LIMIT 1];
        
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.AddEDMSponsors;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the Debate
        ApexPages.StandardController stdCon = new ApexPages.StandardController(debate);
        
        // Create an instance of the page controller to test its methods
        //addContacts cntrlr = new addDebateAttendees();    // default constructor
        addEDMSponsors cntrlr = new addEDMSponsors(stdCon);     // visualforce extension constructor

        // Call the various Get/Set methods to test these
        // nothing to check for, just want to run the code 
        cntrlr.setSetDebugModeFALSE(true);
        cntrlr.setSetDebugModeTRUE(true);
        cntrlr.getSetDebugModeFALSE();
        cntrlr.getSetDebugModeTRUE();
        cntrlr.getShowBlockIfResults();
        
        // Run the Search against this criteria
        Test.setFixedSearchResults(fixedSearchResults);
        PageReference cntrlrResult = cntrlr.doSearch();
        
        // Confirm that the results match the number of contacts added above
        System.assertEquals(null, cntrlrResult);
        //System.assertEquals(c.size(), cntrlr.searchResults.size());
        
        // Enum the searchResult to test some of the code in this class
        // Nothing to test for here
        for (addContacts.TransferContactSearchResults sr : cntrlr.searchResults) {
            sr.getcontact();
            sr.getselected();
            sr.setselected(true);
            //sr.getCreatedDate();
            //sr.getLastModifiedDate();  
        }
        
        // Click the transfer button
        cntrlrResult = cntrlr.doSave();   
        cntrlr.cancel();
    }
    
    //
    // TEST EDM SIGNATORIES
    //
    static testMethod void testAddEDMSignatories() {    
        // Add 10 new contacts that we can search for and transfer
        string UniqueKey = 'AbcDefGhi12345';
        list<Contact> c = New List<Contact>();
        Id [] fixedSearchResults = new Id[10];
        for (Integer i = 0; i < 10; i++) {
            Contact cnew = new Contact(Birthdate=System.today(),LastName = 'Test Contact ' + i, FirstName = UniqueKey);
            insert cnew;
            c.add(cnew);
            fixedSearchResults[i] = cnew.Id;
        }
        
        EDM__c debate = new EDM__c(Name = 'Test EDM');
        insert debate;
        
        // Get the current user and some other user
        // NOTE: There must be at least one other active user in the system!
        user anotheruserid = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id <> :UserInfo.getUserID() LIMIT 1];
        user currentuser = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id = :UserInfo.getUserID() LIMIT 1];
        
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.AddEDMSignatories;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the Debate
        ApexPages.StandardController stdCon = new ApexPages.StandardController(debate);
        
        // Create an instance of the page controller to test its methods
        //addContacts cntrlr = new addDebateAttendees();    // default constructor
        addEDMSignatories cntrlr = new addEDMSignatories(stdCon);       // visualforce extension constructor

        // Call the various Get/Set methods to test these
        // nothing to check for, just want to run the code 
        cntrlr.setSetDebugModeFALSE(true);
        cntrlr.setSetDebugModeTRUE(true);
        cntrlr.getSetDebugModeFALSE();
        cntrlr.getSetDebugModeTRUE();
        cntrlr.getShowBlockIfResults();
        
        // Run the Search against this criteria
        Test.setFixedSearchResults(fixedSearchResults);
        PageReference cntrlrResult = cntrlr.doSearch();
        
        // Confirm that the results match the number of contacts added above
        System.assertEquals(null, cntrlrResult);
        //System.assertEquals(c.size(), cntrlr.searchResults.size());
        
        // Enum the searchResult to test some of the code in this class
        // Nothing to test for here
        for (addContacts.TransferContactSearchResults sr : cntrlr.searchResults) {
            sr.getcontact();
            sr.getselected();
            sr.setselected(true);
            //sr.getCreatedDate();
            //sr.getLastModifiedDate();  
        }
        
        // Click the transfer button
        cntrlrResult = cntrlr.doSave();   
        cntrlr.cancel();
    }
    
        //
    //  TEST CAMPAIGN EVENTS
    //
    static testMethod void testAPPGMeetings() {    
        // Add 10 new contacts that we can search for and transfer
        string UniqueKey = 'AbcDefGhi12345';
        list<Contact> c = New List<Contact>();
        Id [] fixedSearchResults = new Id[10];
        for (Integer i = 0; i < 10; i++) {
            Contact cnew = new Contact(Birthdate=System.today(),LastName = 'Test Contact ' + i, FirstName = UniqueKey);
            insert cnew;
            c.add(cnew);
            fixedSearchResults[i] = cnew.Id;
        }
        
        APPG_Meeting__c event = new APPG_Meeting__c(Name = 'Test Event');
        insert event;
        
        // Get the current user and some other user
        // NOTE: There must be at least one other active user in the system!
        user anotheruserid = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id <> :UserInfo.getUserID() LIMIT 1];
        user currentuser = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id = :UserInfo.getUserID() LIMIT 1];
        
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.AddAPPGAttendees;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the Debate
        ApexPages.StandardController stdCon = new ApexPages.StandardController(event);
        
        // Create an instance of the page controller to test its methods
        //addContacts cntrlr = new addDebateAttendees();    // default constructor
        addAPPGAttendees cntrlr = new addAPPGAttendees(stdCon);     // visualforce extension constructor

        // Call the various Get/Set methods to test these
        // nothing to check for, just want to run the code 
        cntrlr.setSetDebugModeFALSE(true);
        cntrlr.setSetDebugModeTRUE(true);
        cntrlr.getSetDebugModeFALSE();
        cntrlr.getSetDebugModeTRUE();
        cntrlr.getShowBlockIfResults();
        
        //cntrlr.setAttendeeStatus('status');
        //cntrlr.getAttendeeStatus();
        //cntrlr.getAttendenceStatuses();
        
        // Run the Search against this criteria
        Test.setFixedSearchResults(fixedSearchResults);
        PageReference cntrlrResult = cntrlr.doSearch();
        
        // Confirm that the results match the number of contacts added above
        System.assertEquals(null, cntrlrResult);
        //System.assertEquals(c.size(), cntrlr.searchResults.size());
        
        // Enum the searchResult to test some of the code in this class
        // Nothing to test for here
        for (addContacts.TransferContactSearchResults sr : cntrlr.searchResults) {
            sr.getcontact();
            sr.getselected();
            sr.setselected(true);
            //sr.getCreatedDate();
            //sr.getLastModifiedDate();  
        }
        
        // Click the transfer button
        cntrlrResult = cntrlr.doSave();
        cntrlr.cancel();
    }
}