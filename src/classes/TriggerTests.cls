@isTest
private class TriggerTests {
// DEBATE TRIGGER TESTS
    // Positive tests
     static testMethod void debatePositiveTest() {
        // strings for inserting debate and testing score creation
        String activity;
        String debateName = 'Test debate';
        
        // insert a test campaign and two test contacts to work with
        EA_Campaign__c campaign = new EA_Campaign__c(Name='Test campaign');
        Contact personA = new Contact(Birthdate=System.today(),firstName='Person A',lastName = 'Person A');
        Contact personB = new Contact(Birthdate=System.today(),firstName='Person B',lastName = 'Person B');
        insert campaign; insert personA; insert personB;
        
        
        // INSERT TRIGGER
        System.debug('Inserting debate');
        Debate__c debate = new Debate__c(Campaign__c = campaign.Id, Organiser__c = personA.Id, Name = debateName);
        insert debate;
        
        activity = 'Organised Debate: ' + debate.Name;
        
        System.debug('Testing score was created');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personA.Id limit 1].Activity__c);
                         
                                       
        // UPDATE TRIGGER
        System.debug('Updating debate');
        debate.Organiser__c = personB.Id;
        update debate;
        
        System.debug('Testing score was updated');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personB.Id limit 1].Activity__c);
                                       
                                       
        // DELETE TRIGGER
        System.debug('Deleting debate');
        delete debate;
        
        System.debug('Testing score was deleted');
        List<MP_Score_per_Object__c> mps = new List<MP_Score_per_Object__c>();
        mps = [select id from MP_Score_per_Object__c where Campaign__c = :campaign.Id];
        //System.assert(mps.isEmpty());
    }
    
       
 // DEBATE ATTENDEE TRIGGER TESTS
    // Positive tests
    static testMethod void debateAttendPositiveTest() {
        // strings for inserting debate and testing score creation
        String activity;
        String debateName = 'Test debate 2';
        
        // insert a test campaign and two test contacts to work with
        EA_Campaign__c campaign = new EA_Campaign__c(Name='Test campaign');
        Contact personA = new Contact(Birthdate=System.today(),firstName='Person A',lastName = 'Person A');
        Contact personB = new Contact(Birthdate=System.today(),firstName='Person B',lastName = 'Person B');
        insert campaign; insert personA; insert personB;
        
        
        // INSERT TRIGGER
        System.debug('Inserting debate attendee');
        Debate__c debate = new Debate__c(Campaign__c = campaign.Id, Name = debateName);
        insert debate;
        MP_Debate_Association__c attendee = new MP_Debate_Association__c(MP__c = personA.id, Debate__c = debate.id);
        insert attendee;
        
        activity = 'Attended Debate: ' + debate.Name;
        
        System.debug('Testing score was created');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personA.Id limit 1].Activity__c);
                         
                                       
        // UPDATE TRIGGER
        System.debug('Updating debate attendee');
        attendee.MP__c = personB.Id;
        update attendee;
        
        System.debug('Testing score was updated');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personB.Id limit 1].Activity__c);
                                       
                                       
        // DELETE TRIGGER
        System.debug('Deleting debate attendee');
        delete attendee;
        
        System.debug('Testing score was deleted');
        List<MP_Score_per_Object__c> mps = new List<MP_Score_per_Object__c>();
        mps = [select id from MP_Score_per_Object__c
               where  Campaign__c = :campaign.Id
               and    MP__c = :personB.Id];
        System.assert(mps.isEmpty());
    }
    
    
 // PQ TRIGGER TESTS
    // Positive tests
    static testMethod void pqPositiveTest() {
        // strings for inserting debate and testing score creation
        String activity;
        String pqName = 'Test PQ';
        
        // insert a test campaign and two test contacts to work with
        EA_Campaign__c campaign = new EA_Campaign__c(Name='Test campaign');
        Contact personA = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person A');
        Contact personB = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person B');
        insert campaign; insert personA; insert personB;
        
        
        // INSERT TRIGGER
        System.debug('Inserting PQ');
        PQ__c pq = new PQ__c(Campaign__c = campaign.Id, Contact__c = personA.Id, Subject__c = pqName, Question__c = 'Hello?');
        insert pq;
        
        activity = 'Asked PQ: ' + pq.Subject__c;
        
        System.debug('Testing score was created');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personA.Id limit 1].Activity__c);
                         
                                       
        // UPDATE TRIGGER
        System.debug('Updating PQ');
        pq.Contact__c = personB.Id;
        update pq;
        
        System.debug('Testing score was updated');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personB.Id limit 1].Activity__c);
                                       
                                       
        // DELETE TRIGGER
        System.debug('Deleting PQ');
        delete pq;
        
        System.debug('Testing score was deleted');
        List<MP_Score_per_Object__c> mps = new List<MP_Score_per_Object__c>();
        mps = [select id from MP_Score_per_Object__c where Campaign__c = :campaign.Id];
        System.assert(mps.isEmpty());
    }
    
    
  // EDM TRIGGER TESTS
    // Positive tests
    static testMethod void edmPositiveTest() {
        // strings for inserting debate and testing score creation
        String activity;
        String edmName = 'Test EDM';
        
        // insert a test campaign and two test contacts to work with
        EA_Campaign__c campaign = new EA_Campaign__c(Name='Test campaign');
        Contact personA = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person A');
        Contact personB = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person B');
        insert campaign; insert personA; insert personB;
        
        
        // INSERT TRIGGER
        System.debug('Inserting EDM');
        EDM__c edm = new EDM__c(Campaign__c = campaign.Id, Author__c = personA.Id, Name = edmName);
        insert edm;
        
        activity = 'Authored EDM: ' + edm.Name;
        
        System.debug('Testing score was created');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personA.Id limit 1].Activity__c);
                         
                                       
        // UPDATE TRIGGER
        System.debug('Updating EDM');
        edm.Author__c = personB.Id;
        update edm;
        
        System.debug('Testing score was updated');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personB.Id limit 1].Activity__c);
                                       
                                       
        // DELETE TRIGGER
        System.debug('Deleting EDM');
        delete edm;
        
        System.debug('Testing score was deleted');
        List<MP_Score_per_Object__c> mps = new List<MP_Score_per_Object__c>();
        mps = [select id from MP_Score_per_Object__c where Campaign__c = :campaign.Id];
        System.assert(mps.isEmpty());
    }
    

// -- REMOVED BECAUSE NO LONGER A TRIGGER ON SYSTEM
// EDM SPONSOR TRIGGER TESTS
/*
    // Positive tests
    static testMethod void edmSponsorPositiveTest() {
        // strings for inserting debate and testing score creation
        String activity;
        String edmName = 'Test EDM';
        
        // insert a test campaign and two test contacts to work with
        EA_Campaign__c campaign = new EA_Campaign__c(Name='Test campaign');
        Contact personA = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person A');
        Contact personB = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person B');
        insert campaign; insert personA; insert personB;
        
        
        // INSERT TRIGGER
        System.debug('Inserting EDM Sponsor');
        EDM__c edm = new EDM__c(Campaign__c = campaign.Id, Name = edmName);
        insert edm;
        EDM_Sponsor__c edmSponsor = new EDM_Sponsor__c(EDM__c = edm.id, MP__c = personA.id);
        insert edmSponsor;
        
        activity = 'Sponsored EDM: ' + edm.Name;
        
        System.debug('Testing score was created');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personA.Id limit 1].Activity__c);
                         
                                       
        // UPDATE TRIGGER
        System.debug('Updating EDM Sponsor');
        edmSponsor.MP__c = personB.Id;
        update edmSponsor;
        
        System.debug('Testing score was updated');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personB.Id limit 1].Activity__c);
                                       
                                       
        // DELETE TRIGGER
        System.debug('Deleting EDM Sponsor');
        delete edmSponsor;
        
        System.debug('Testing score was deleted');
        List<MP_Score_per_Object__c> mps = new List<MP_Score_per_Object__c>();
        mps = [select id from MP_Score_per_Object__c
               where  Campaign__c = :campaign.Id
               and    MP__c = :personB.Id];
        System.assert(mps.isEmpty());
    }
*/
    
 // EDM SIGNATORY TRIGGER TESTS
    // Positive tests
    static testMethod void edmSigPositiveTest() {
        // strings for inserting EDM and testing score creation
        String activity;
        String edmName = 'Test EDM';
        
        // insert a test campaign and two test contacts to work with
        EA_Campaign__c campaign = new EA_Campaign__c(Name='Test campaign');
        Contact personA = new Contact(Birthdate=System.today(), firstName='First',lastName = 'Person A');
        Contact personB = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person B');
        insert campaign; insert personA; insert personB;
        
        
        // INSERT TRIGGER
        System.debug('Inserting EDM Signatory');
        EDM__c edm = new EDM__c(Campaign__c = campaign.Id, Name = edmName);
        insert edm;
        MP_EDM_Association__c edmSig = new MP_EDM_Association__c(EDM__c = edm.id, Contact__c = personA.id);
        insert edmSig;
        
        activity = 'Signed EDM: ' + edm.Name;
        
        System.debug('Testing score was created');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personA.Id limit 1].Activity__c);
                         
                                       
        // UPDATE TRIGGER
        System.debug('Updating EDM Signatory');
        edmSig.Contact__c = personB.Id;
        update edmSig;
        
        System.debug('Testing score was updated');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personB.Id limit 1].Activity__c);
                                       
                                       
        // DELETE TRIGGER
        System.debug('Deleting EDM Signatory');
        delete edmSig;
        
        System.debug('Testing score was deleted');
        List<MP_Score_per_Object__c> mps = new List<MP_Score_per_Object__c>();
        mps = [select id from MP_Score_per_Object__c
               where  Campaign__c = :campaign.Id
               and    MP__c = :personB.Id];
        System.assert(mps.isEmpty());
    }
    
    
// CAMPAIGN EVENT ATTENDEE TRIGGER TESTS
    // Positive tests
    static testMethod void campaignEventAttendeePositiveTest() {
        // strings for inserting debate and testing score creation
        String activity;
        String campaignEventName = 'Test Campaign Event';
        
        // insert a test campaign and two test contacts to work with
        EA_Campaign__c campaign = new EA_Campaign__c(Name='Test campaign');
        Contact personA = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person A');
        Contact personB = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person B');
        insert campaign; insert personA; insert personB;
        
        // create a test campaign event
        Campaign_Event__c ce = new Campaign_Event__c(Name = campaignEventName, Campaign__c = campaign.id);
        insert ce;
        
        // INSERT TRIGGER
        System.debug('Inserting campaign event attendee');
        Attendence__c attendence = new attendence__c(Campaign_Event__c = ce.Id,
                                                     Contact__c = personA.id,
                                                     Status__c = 'Attended');
        insert attendence;
        
        activity = 'Attended Event: ' + ce.Name;
        
        System.debug('Testing score was created');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personA.Id limit 1].Activity__c);
                         
                                       
        // UPDATE TRIGGER
        System.debug('Updating campaign event attendee');
        attendence.Contact__c = personB.Id;
        update attendence;
        
        System.debug('Testing score was updated');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personB.Id limit 1].Activity__c);
                                       
                                       
        // DELETE TRIGGER
        System.debug('Deleting debate attendee');
        delete attendence;
        
        System.debug('Testing score was deleted');
        List<MP_Score_per_Object__c> mps = new List<MP_Score_per_Object__c>();
        mps = [select id from MP_Score_per_Object__c where Campaign__c = :campaign.Id];
        System.assert(mps.isEmpty());
    }
    
// APPG MEETING ATTENDEE TRIGGER TESTS
    // Positive tests
    static testMethod void APPGAttendeePositiveTest() {
        // strings for inserting debate and testing score creation
        String activity;
        String APPGName = 'Test APPG Meeting';
        
        // insert a test campaign and two test contacts to work with
        EA_Campaign__c campaign = new EA_Campaign__c(Name='Test campaign');
        Contact personA = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person A');
        Contact personB = new Contact(Birthdate=System.today(),firstName='First',lastName = 'Person B');
        insert campaign; insert personA; insert personB;
        
        // create a test campaign event
        APPG_Meeting__c ce = new APPG_Meeting__c(Name = APPGName, Campaign__c = campaign.id);
        insert ce;
        
        // INSERT TRIGGER
        System.debug('Inserting APPG attendee');
        APPG_Meeting_Attendee__c attendence = new APPG_Meeting_Attendee__c(APPG_Meeting__c = ce.Id,
                                                     Contact__c = personA.id);
        insert attendence;
        
        activity = 'Attended APPG Meeting: ' + ce.Name;
        
        System.debug('Testing score was created');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personA.Id limit 1].Activity__c);
                         
                                       
        // UPDATE TRIGGER
        System.debug('Updating APPG Meeting attendee');
        attendence.Contact__c = personB.Id;
        update attendence;
        
        System.debug('Testing score was updated');
        System.assertEquals(activity, [select Activity__c from MP_Score_per_Object__c
                                       where  Campaign__c = :campaign.Id
                                       and    MP__c = :personB.Id limit 1].Activity__c);
                                       
                                       
        // DELETE TRIGGER
        System.debug('Deleting appg meeting attendee');
        delete attendence;
        
        System.debug('Testing score was deleted');
        List<MP_Score_per_Object__c> mps = new List<MP_Score_per_Object__c>();
        mps = [select id from MP_Score_per_Object__c where Campaign__c = :campaign.Id];
        System.assert(mps.isEmpty());
    }
    
    // CONTACT TRIGGER TESTS
    // Positive tests
    static testMethod void ContactPositiveTest() {
        // insert two test contacts to work with
        Contact personA = new Contact(firstName='First',lastName = 'Person A', Birthdate=System.today());
        //Contact personA = new Contact(firstName='First',lastName = 'Person A', Consent_Status__c='Withdrawn', Birthdate=System.today());
        Contact personB = new Contact(firstName='First',lastName = 'Person B', DoNotCall=true, Birthdate=System.today());
        
        // INSERT TRIGGER
        System.debug('Inserting contact');
        insert personA; insert personB;
        
        System.debug('Testing score was created');
        //System.assertNotEquals(null, [Select c.rrpu__Alert_Message__c, c.Id, c.DoNotCall, c.Consent_Status__c From Contact c
        //                               where  id = :personA.id].rrpu__Alert_Message__c);
                                       
    }
    
    static testMethod void testServiceUsageDelete() {
    
    }
}