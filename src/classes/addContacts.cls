/* -------------------------------------------------------------------------------------
* TransferContact Class: Controller for the TransferContacts page
* M.Smith 8 April 2009
* http://www.force2b.net
*
* Modified by:
* Matthew Thomas: 18th February 2011
* - converted doSearch() to free-text search rather than boolean search
* - stripped out other unnecessary code as a result of this
*
* Matthew Thomas: 21st Sept 2009
* - base class for adding searched-for contacts to a junction object
* - other junction objects should extend this class and override the doSave function
* - this class adds the contacts to ONEN_Household__c
* - Works with the searchCriteria class
*
* Notes on extending the class:
* 1. Override the constructor, calling 'commonContstructor();' at the end
* 2. Override doSave() to perform whatever modifications you require 
*  ------------------------------------------------------------------------------------- */
public With Sharing virtual class addContacts {

    // The campaign event MPs will be attending
    //public ONEN_Household__c household;
    
    // If this is set to TRUE (by an InputHidden tag on the page) then show SOQL and other debug messages
    public boolean DebugMode = false;
    
    // Collection of search results for displaying
    public List<transferContactSearchResults> searchResults = new List<transferContactSearchResults>();
    
    // Flag to identify when a transfer was just completed and running the query a second time for additional records
    protected Boolean transferJustCompleted = false;
    
    // List of record type Ids. Set in constructor
    protected List<String> recordTypeList = new List<String>();
    
    // What the user is searching for
    public string searchText = '';
    
    // ------------------------------------------------
    // Constructor Methods
    // ------------------------------------------------
    // Default constructor
    public addContacts() {
        // Do nothing in implicit constructor
    }
    
    // Visualforce extension constructor
    public addContacts(ApexPages.StandardController controller) {
        //household = (ONEN_Household__c)controller.getRecord();
        
        //recordTypeList.add('012700000009b4B'); // Person with dementia
        //recordTypeList.add('012700000009b49'); // Carer / family member / friend
    }

// ------------------------------------------------
   
    // Get/Set methods to enable or disable DebugMode on the page.
    // This is called by an InputHidden tag on the page
    public boolean getSetDebugModeTRUE()    { this.DebugMode = true; return TRUE; }
    public boolean getSetDebugModeFALSE()   { this.DebugMode = false; return FALSE; }
    public void setSetDebugModeTRUE(boolean x)  { this.DebugMode = true; }
    public void setSetDebugModeFALSE(boolean x) { this.DebugMode = false; }
    
    public string getSearchText()         { return searchText; }
    public void setSearchText(string str) { searchText = str; }
    
// ------------------------------------------------

    // -------------------------------------------------------------------------------------
    // SEARCH BUTTON:
    // Builds SOQL Statement based on selection criteria
    // Fills searchResults[] list
    // -------------------------------------------------------------------------------------
    public pageReference doSearch() {
        searchText += '*';

        // SOSL Query
        List<List<SObject>> searchList = [FIND :searchText IN ALL FIELDS
                                          RETURNING Contact (Id, Name, homephone, mailingpostalcode, APPG__c
                                                             WHERE RecordTypeId IN :recordTypeList)];
        
        // Run the database query and place results into the TransferContactSearchResults class 
        try {
            searchResults.clear();
            List<Contact> results = ((List<Contact>)searchList[0]);
            
            List<Contact> results2 = [select Id, Name, homephone, mailingpostalcode, APPG__c, RecordType.Name, Party__r.Name, Constituency__r.Name
                                      from Contact where Contact.Id in :results];
            
            // If zero or more than 250 records returned, display a message 
            //if (results.size() == 250) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'NOTE: Only the first 250 rows are displayed.'));
            //if (results.size() == 0 && !transferJustCompleted) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'NO RECORDS FOUND.'));
            
            // Build the searchResults[] list used by the Apex:DataTable tag on the page
            for (Contact c : results2) {
                searchResults.add( new transferContactSearchResults(c) ) ;
            }
            
        } catch (Exception ex) {
            // ERROR! Display message on screen
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Query Error: ' + ex.getMessage() )); //+ '\nQuery string: ' + cSOQL));
        }
        
        transferJustCompleted = false;     // Reset the flag used to track when a transfer was completed versus a new query
        return null;
        
    }
 
    // Return searchResults to the DATAGRID
    public list<transferContactSearchResults> getSearchResults() {
        return this.searchResults;
    }
    
    // Used with the Style attribute on the OutputPanel tag show the search results if there are any
    public string getShowBlockIfResults() {
        if (this.searchResults.size() > 0) {
            return 'display: block;' ;
        } else {
            return 'display: none;' ;
        }
    }
    
    // ----------------------------------------------------------------------
    // Save Button:
    // - Query the selected contacts
    // - Change the household
    // - Call database.update()
    // - Check for errors
    // - Rerun the query to display any remaining contacts -- commented out
    // - Go to the household record
    // ----------------------------------------------------------------------
    public virtual pageReference doSave() {
        
        // Build a list of Contact ID's to add to the household
        List<string> IDs = New List<string>();
        for (transferContactSearchResults c : searchResults) {
            if (c.selected) IDs.add(c.contact.ID) ;
        }
        if (DebugMode) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selected Count: ' + IDs.size()));
        
        // Query the contacts being transferred
        List<Contact> contacts = [SELECT ID, OwnerID, Name, Account.Name, Title, Owner.Alias FROM Contact WHERE ID IN :IDs];
        for (Contact c : contacts) {
            //c.ONEN_Household__c = household.Id;
        }
        if (DebugMode) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Query Size: ' + contacts.size()));

        // Process Errors and Count the Number of Records Transferred
        Integer transferCount = 0;
        List<database.saveresult> srs = database.update(contacts);
        for (database.saveresult sr : srs) {
            if (!sr.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL, sr.getId() + '/' + sr.getErrors()[0].getMessage() ));
            } else {
                transferCount++; 
            }
        }

        // Display the Transfer Count
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, transferCount + ' Records Successfully Transfered' ));
        
        // Set the flag that this just finished
        transferJustCompleted = true;       

        // Re-run the [Search] button functionality.
        //doSearch();
        
        // Send the user to the detail page for the household
        //PageReference page = new PageReference('/' + household.id);
        //page.setRedirect(true);
        //return page;
        return null;
    }
    
    // Send user back to household
    public virtual PageReference cancel() {
    //    PageReference page = new PageReference('/' + household.id);
    //    page.setRedirect(true);
    //    return page;
          return null;
    }
    
    
    // Simple function to convert NULL to ''
    private string null2String(string s) { if (s == null) return ''; else return s; }

    /* -------------------------------------------------------------------------------------
    * TransferContactSearchResults: Mass Transfer Search Results Wrapper Class
    * - Used by the TransferContacts Class and Page 
    * - Main purpose is to return a LIST of Contacts along with a custom checkbox that can 
    *   be used to let the user select which rows to transfer and which to ignore.
    *  ------------------------------------------------------------------------------------- */
    Public Class transferContactSearchResults{
    
        public boolean selected = false;
        public Contact contact = null;
        
        public transferContactSearchResults() { }
        public transferContactSearchResults(Contact c) { contact = c; }
        
        public Contact getcontact()         { return this.contact ; }
        public void setcontact(Contact c)   { this.contact = c; } 
    
        public boolean getselected()        { return this.selected; }
        public void setselected(boolean s)  { this.selected = s; } 
        
        // Returns these DateTime fields as Date types formatted based on the current users Locale setting in SalesForce 
        //public string getCreatedDate()      { return date.newInstance(this.contact.CreatedDate.year(), this.contact.CreatedDate.month(), this.contact.CreatedDate.day()).format() ; }
        //public string getLastModifiedDate() { return date.newInstance(this.contact.LastModifiedDate.year(), this.contact.LastModifiedDate.month(), this.contact.LastModifiedDate.day()).format() ; }
    }
    
    //
    // TEST HOUSEHOLD CONTACTS
    //
    private static testMethod void testAddHouseholdContacts() {    
        // Add 10 new contacts that we can search for and transfer
        string UniqueKey = 'AbcDefGhi12345';
        list<Contact> c = New List<Contact>();
        Id [] fixedSearchResults = new Id[10];
        for (Integer i = 0; i < 10; i++) {
            Contact cnew = new Contact(Salutation='Mr',Birthdate =Date.Today(), LastName = 'Test Contact ' + i, FirstName = UniqueKey);
            insert cnew;
            c.add(cnew);
            fixedSearchResults[i] = cnew.Id;
        }
        
        //ONEN_Household__c household = new ONEN_Household__c(Name = 'Test Household');
        //insert household;
        
        // Get the current user and some other user
        // NOTE: There must be at least one other active user in the system!
        user anotheruserid = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id <> :UserInfo.getUserID() LIMIT 1];
        user currentuser = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id = :UserInfo.getUserID() LIMIT 1];
        
        // Create a PageReference to the VF page being tested       
        //PageReference pageRef = Page.AddHouseholdContact;
        //test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the Debate
        //ApexPages.StandardController stdCon = new ApexPages.StandardController(household);
        
        // Create an instance of the page controller to test its methods
        //addContacts cntrlr = new addContacts(); // default constructor
        //cntrlr = new addContacts(stdCon);       // visualforce extension constructor

        // Call the various Get/Set methods to test these
        // nothing to check for, just want to run the code 
        //cntrlr.setSetDebugModeFALSE(true);
        //cntrlr.setSetDebugModeTRUE(true);
        //cntrlr.getSetDebugModeFALSE();
        //cntrlr.getSetDebugModeTRUE();
        //cntrlr.getShowBlockIfResults();
        //cntrlr.getSearchText();
        //cntrlr.setSearchText('hello');
        
        // Run the Search against this criteria
        //Test.setFixedSearchResults(fixedSearchResults);
        //PageReference cntrlrResult = cntrlr.doSearch();
        
        // Confirm that the results match the number of contacts added above
        //System.assertEquals(null, cntrlrResult);
        //System.assertEquals(c.size(), cntrlr.searchResults.size());
        
        // Enum the searchResult to test some of the code in this class
        // Nothing to test for here
        //for (addContacts.TransferContactSearchResults sr : cntrlr.searchResults) {
        //    sr.getcontact();
        //    sr.getselected();
        //    sr.setselected(true);
            //sr.getCreatedDate();
            //sr.getLastModifiedDate();  
        //}
        
        // Click the transfer button
        //cntrlrResult = cntrlr.doSave();   
        //cntrlr.cancel();
    }
}