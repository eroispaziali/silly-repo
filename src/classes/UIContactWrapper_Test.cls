@isTest
public class UIContactWrapper_Test {

	static testMethod void testUIContactWrapper()
	{
	    Contact contact = UIUtils_Test.getTestContact();
	    UIContactWrapper uiCW = new UIContactWrapper(contact);
	    uiCW = new UIContactWrapper(contact, null, null);    
	}

}