public with sharing class testContact {
	public string testString {get;set;}
	public Contact testContact {get;set;}
	public testContact(ApexPages.StandardController controller) {
		// Do Nothing.
		testString = 'This is a test';
		testContact = new Contact();
	}
	
	

}