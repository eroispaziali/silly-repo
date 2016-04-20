@isTest
public class UIUtils_Test {

    public static Service_Usage__c getTestServiceUsage(User u1, User u2, Contact contact, Account acct, Services__c svc) {
            
        Service_Usage__c su = 
                    new Service_Usage__c(
                            Service_Field__c= svc.id, 
                            Primary_Service_User__c=contact.id,
                            Service_Type__c='Dementia support', 
                            ownerid=u1.id,                          
                            RecordTypeId=[select id from RecordType where SobjectType = 'Service_usage__c' and DeveloperName='Dementia_Support_Service_Usage'].id,
                            Referral_Outcome__c = 'Service Required');    
        
        insert su;
        return su;
    
    }
    
    public static User getTestUserInPermissionSet()
    {
        User adminUser = [ select Id from User where Profile.Name = 'System Administrator' and isActive = true limit 1];
        User u = null;
        System.runAs ( adminUser ) {
        
            // Get the Permission Set
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'User_Involvement_Users'];        
            
            // Get a sample user that is not a CRS user (in this case External Affiars)
            u = [select id, name from User where (Profile.Name like '%External%') and IsActive=true LIMIT 1];           
            
            // Get the current members of the Permission Set
            List<PermissionSetAssignment> lisPsa = [select AssigneeId from PermissionSetAssignment where PermissionSetId =: ps.Id and AssigneeId =:u.id];
            
            // Add the user if they are not already there
            if (lisPsa.isEmpty()) {
                PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
                insert psa;
            }
        }
        
        return u;
    }
    
    
    public static User getTestUser1()
    {
        User u1 = [select id, name from User where Profile.Name='CRS' and UserRole.Name like 'Dementia Adviser & Dementia Support - North West London%'  and IsActive=true LIMIT 1];
        return u1;
    }
    
    public static User getTestSSMUser()
    {
        User u1 = [select id, name from 
                    User where 
                    Profile.Name='CRS and BDC' and 
                    Title like '%Services Manager%'  
                    and IsActive=true LIMIT 1];
        return u1;
    }
    
    public static User getTestUser2(User u1)
    {
        User u2 = [select id, name from User where Profile.Name='CRS' and UserRole.Name like 'Dementia Adviser & Dementia Support - North West London%' and IsActive=true AND id!=:u1.id LIMIT 1];
        return u2;
    
    }
    
    public static Contact getTestContact()
    {
        Contact contact = new Contact(FirstName = 'Albert', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
        
        insert contact;
        return contact;
    }

    public static Contact getTestContact2()
    {
        Contact contact = new Contact(FirstName = 'Joan', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
        
        insert contact;
        return contact;
    }
    
    
    public static Account getTestAccount()
    {
        Account acct = new Account(Name='North West London Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
        
        insert acct;
        return acct;
    }
    
    public static Services__c getTestService(Account acct)
    {
        
        User uSsm = getTestSSMUser();

        Services__c svc = new Services__c(
                          Name='North West London DS test', 
                          Locality__c=acct.id,
                          Service_Type__c='Dementia support',
                          SSM__c = uSSm.id, 
                          National_Service__c=false);
        
        insert svc;
        return svc;   
    }
    
    public static UI_Participant__c getTestParticipant(Contact contact, boolean bActive)
    {
        UI_Participant__c p = new UI_Participant__c();
        p.Contact__c = contact.id;
        p.Status__c = 'Unconfirmed';
        insert p;
        
        if ( bActive ) {
          p.Status__c = 'Active';
          p.Valid_From_Date__c = Date.Today().addMonths(-4);
          p.Consent_Type__c = 'Verbal';
          update p;
        }
        
        return p;
    
    }

    public static UI_Participant_Relationship__c getTestRelationship(UI_Participant__c p1, UI_Participant__c p2)
    {
    
        UI_Participant_Relationship__c relationship = new UI_Participant_Relationship__c();
        relationship.Primary_Participant__c = p1.id;
        relationship.Related_Participant__c = p2.id;
        
        insert relationship;
        return relationship;
    
    }

    
    /* Get a Test UI Programme */
    public static UI_Programme__c getTestProgramme()
    {
        UI_Programme__c prog = new UI_Programme__c(
                        Name='A Test Project / Programme'
                        );
    
        insert prog;
        return prog;
    }


    /* Get a Test UI_Activity__c */
    public static UI_Activity__c getTestActivity(UI_Programme__c programme)
    {
        UI_Activity__c activity = new UI_Activity__c(
                       Name='A Test Activity',
                       UI_Programme__c = programme.id,
                       Start_Date__c = Date.Today(),
                       End_Date__c = Date.Today()
                       );    
    
        insert activity;
        return activity;
    }
    
    /* Test UIUtils without local data access to test for the lack of 
       a public group having been created. These methods 
       are run with local database access by methods that create Participants
       because the trigger fires them on save;
    */
    static testMethod void testUIUtilsWithNoData() {

        Contact contact = getTestContact();
        List<String> lis = new List<String>();
        lis.add(contact.id);
        
        Boolean b = UIUtils.doSharePersonRecords(lis);
        b = UIUtils.doUnsharePersonRecords(lis);    

    }
    
    /* Something in the Service_Usage__c trigger requires access
       to all data. 
       
       Otherwise there is an error about a Role not being found
       TODO!! That should be fixed at some point
    */      
    @isTest (SeeAllData=true)    
    public static void testGetLatestServiceUsage()
    {
        Contact contact = getTestContact();
        Account acct = getTestAccount();
        Services__c svc = getTestService(acct);     
            
        User u1 = getTestUser1();
        User u2 = getTestUser2(u1); 
            
        Service_Usage__c su = getTestServiceUsage(u1,u2,contact, acct, svc);
        system.assert(su!=null);    
    
        su = UIUtils.getLatestServiceUsage(contact.id);    

    }
    
    @isTest (SeeAllData=true)    
    public static void testSetParticipantDeceased()
    {
    
        Contact contact = getTestContact();
        Account acct = getTestAccount();
        Services__c svc = getTestService(acct);     
            
        User u1 = getTestUser1();
        User u2 = getTestUser2(u1); 
            
        Service_Usage__c su = getTestServiceUsage(u1,u2,contact, acct, svc);    
    
        UI_Participant__c p = getTestParticipant(contact, true);
        
        p.Status__c = 'Unconfirmed';
        p.Consent_Type__c = 'Written';
        p.Valid_From_Date__c = Date.Today();
        
        update p;
        
        ApexPages.StandardController sc = new ApexPages.standardController(p);      
        UIParticipantControllerExtension e = new UIParticipantControllerExtension(sc);        
        e.saveAndRequestApproval();
        
        /* Set the contact deceased, then call the action to make the Participant deceased */
        contact.deceased__c=true;
        update contact;
        
        UIUtils.setParticipantDeceased(contact);
    
    }
    
    /* Fire the Trigger on the UI_Participation__c object */
    static testMethod void testCreateParticipationTrigger() {
    
        Contact contact = UiUtils_Test.getTestContact();
        UI_Participant__c p = UiUtils_Test.getTestParticipant(contact, true);                     
        UI_Programme__c prog = UiUtils_Test.getTestProgramme();
        UI_Activity__c activity = UiUtils_Test.getTestActivity(prog);
        
        UI_Activity_Participation__c participation = new UI_Activity_Participation__c();
        participation.UI_Activity__c = activity.id;
        participation.UI_Participant__c = p.id;
        participation.Specific_Consent__c = 'Verbal';
        insert participation;
    
    }
    
    
}