public class ContactEventWizardController {
	public Contact_Event__c contactEvent;
	public Contact_Event_Contact_Connector__c person;
	
	//
    // Constructor
    //
	public ContactEventWizardController(ApexPages.StandardController controller) {
		contactEvent = new Contact_Event__c();
		person = new Contact_Event_Contact_Connector__c();
	}
	
	//
    // Properties
    //
    public Contact_Event__c getContactEvent() {
        if(contactEvent == null)
            contactEvent = new Contact_Event__c();
        return contactEvent;
    }
    
    public Contact_Event_Contact_Connector__c getPerson() {
    	if (person == null)
    		person = new Contact_Event_Contact_Connector__c();
    	return person;
    }
    
    // 
    // Navigation methods
    //
    // Return the user to the Contact Events/Interactions tab
    public PageReference cancel() {
        PageReference contPage = new PageReference('/a0t/o');
        contPage.setRedirect(true);
        return contPage;
    }
    
    //
    // Save record methods
    //
    private void saveEvent() {
    	upsert contactEvent;
    	
    	// Link person to contact event/interaction and upsert
    	Contact_Event_Contact_Connector__c p = new Contact_Event_Contact_Connector__c(
    													 Contact_Event__c = contactEvent.Id
    													,Contact__c = person.Contact__c);
    	upsert p;
    }
    
    public PageReference save() {
    	saveEvent();
    	
    	// Send user to the detail page for the contact
        PageReference opptyPage = new PageReference('/' + contactEvent.id);
        opptyPage.setRedirect(true);
        return opptyPage;
    }
    
    public PageReference saveAdd() {
    	saveEvent();
    	
    	// Send user to add people to Contact Event/Interaction
        PageReference newCont = new PageReference('/apex/AddContactEventAttendees?id=' + contactEvent.Id);
        newCont.setRedirect(true);
        return newCont;
    }
    
    //
	// TEST ContactWizardController
	//
	private static testMethod void testContactEventWiz () {
		User currentuser = [Select ID, LocaleSidKey, Alias From User WHERE IsActive = True AND Id = :UserInfo.getUserID() LIMIT 1];
		
		Contact_Event__c ce = new Contact_Event__c(name = 'test', ownerId = currentuser.Id);
		
		// Create test contact
		Contact contact = new Contact(FirstName = 'test', LastName='Test', ownerId = currentuser.Id);
        insert contact;
        
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.NewContactInteraction;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the contact event
        ApexPages.StandardController stdCon = new ApexPages.StandardController(ce);
        
        // Test constructors
        ContactEventWizardController cnt = new ContactEventWizardController(stdCon);
        
        // Test properties
        cnt.getContactEvent();
        cnt.getPerson();
        
        // Set fields
        cnt.contactEvent.Name = 'test event';
        cnt.contactEvent.Duration__c = 2;
        cnt.contactEvent.Contact_Date_Time__c = Date.today();
        cnt.contactEvent.Format__c = 'Email';
        cnt.contactEvent.OwnerId = currentuser.Id;
        
        cnt.person.Contact__c = contact.Id;
		
        // Test save methods
        cnt.save();
        cnt.saveAdd();
        cnt.cancel();
	}
}