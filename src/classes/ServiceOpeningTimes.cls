public class ServiceOpeningTimes {
    public Services__c service;
    private OpHours oh;
    
    // One session object per week day
    public Session mon   { get; set; }
    public Session tues  { get; set; }
    public Session weds  { get; set; }
    public Session thurs { get; set; }
    public Session fri   { get; set; }
    public Session sat   { get; set; }
    public Session sun   { get; set; }
    
    // Default constructor
    public ServiceOpeningTimes() {
        service = [select id, service_operationhours__c, service_operationhourscomment__c, service_street__c, service_city__c, service_postcode__c
                   from Services__c where id = :ApexPages.currentPage().getParameters().get('id')];
        
        commonConstructor();
    }
    
    // Visualforce extension constructor
    public ServiceOpeningTimes(ApexPages.StandardController controller) {
        service = (Services__c)controller.getRecord();
        
        commonConstructor();
    }
    
    public ServiceOpeningTimes(string hours) {
        oh = new OpHours();
        oh.setHours(hours);
    }
    
    // Initialise local Session variables and fill with service's opening times
    // -- used in both constructors --
    private void commonConstructor() {
        mon = new Session(); tues = new Session(); weds = new Session();
        thurs = new Session(); fri = new Session(); sat = new Session(); sun = new Session();
        
        // Get this service's existing opening hours
        oh = new OpHours();
        oh.setHours(service.service_operationhours__c);
        
        // Fill out week's sessions
        mon = oh.getSession(0);
        tues = oh.getSession(1);
        weds = oh.getSession(2);
        thurs = oh.getSession(3);
        fri = oh.getSession(4);
        sat = oh.getSession(5);
        sun = oh.getSession(6);
    }
    
    
    // Getter/setter for Service object
    public Services__c getService() {
        if (service==null) service = new Services__c();
        return service;
    }
    
    // For VF component to pass opening hours string
    public void setOpHours(string s) {
        oh = new OpHours();
        //oh.setHours(service.service_operationhours__c);
        oh.setHours(s);
    }
    
    // Return array of Sessions for the opening time component's data table
    public List<Session> getDaysOpen() {
        List<Session> returnSessions = new List<Session>();
        Map<integer, Session> sessionMap = oh.getSessionMap();
        
        // Loop over each day in map
        Set<integer> days = sessionMap.keySet();
        for (integer i : days) {
            // Add to list of sessions to return
            returnSessions.add(sessionMap.get(i));
        }
        
        return returnSessions;
    }
    
    public string getDaysOpenString() {
        Session s = new Session();
        Map<integer, Session> sessionMap = oh.getSessionMap();
        
        string retText = 'Day and session (One; Two; Three; Four)\n';
        
        // Loop over each day in map
        Set<integer> days = sessionMap.keySet();
        for (integer i : days) {
            // Add to list of sessions to return
            s = sessionMap.get(i);
            retText += s.DayOfWeek + ': ' + s.getVFSession1() + '; ' + s.getVFSession2() + '; ' + s.getVFSession3() + '; ' + s.getVFSession4() + '\n';
        }
        
        return retText;
    }
    
    // Return the opening hours in Services DB format (one long string with Xs for blanks)
    private string convertHours() {
        return mon.format() + tues.format() + weds.format() + thurs.format() + fri.format() + sat.format() + sun.format();
    }
    
    public PageReference save() {
        // Set the opening hours string and update the Service
        service.service_operationhours__c = convertHours();
        
        update service;
        
        // Send user to the Service's detail page
        PageReference servicePage = new PageReference('/' + service.id);
        servicePage.setRedirect(true);
        return servicePage;
    }
    
    // Redirect user to the Service's detail page
    public PageReference cancel() {
        PageReference servicePage = new PageReference('/' + service.id);
        servicePage.setRedirect(true);
        return servicePage;
    }

    //
    // TEST ServiceOpeningTimes
    //
    private static testMethod void testOpeningTimes() {
        Services__c service = new Services__c(Name='Test service',National_Service__c=true, Display_on_public_website__c=true );
        // Set blank opening times
        service.service_operationhours__c = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0900120014001630XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
        insert service;
        
        //create a service measure
        Service_Measures_Data__c measure = new Service_Measures_Data__c(Service__c=service.id,Year__c='2012', Month__c='January');
        insert measure;
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.Service;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the service
        ApexPages.StandardController stdCon = new ApexPages.StandardController(service);
        pageRef.getParameters().put('id', service.Id);
        
        // Test constructors
        ServiceOpeningTimes cnt = new ServiceOpeningTimes();
        cnt = new ServiceOpeningTimes(stdCon);
        
        // Test properties
        Services__c s = cnt.getService();
        Session[] sessions = cnt.getDaysOpen();
        cnt.mon.getVFsession1();
        cnt.mon.getVFsession2();
        cnt.mon.getVFsession3();
        cnt.mon.getVFsession4();
        
        service.service_operationhours__c = '09001700090017000900170009001700090017000900170009001700090017000900170009001700090017000900170009001700090017000900170009001700090017000900170009001700090017000900170009001700090017000900170009001700090017000900170009001700';
        // Test properties
        cnt.setOpHours(service.service_operationhours__c);
        sessions = cnt.getDaysOpen();
        cnt.mon.getVFsession1();
        cnt.mon.getVFsession2();
        cnt.mon.getVFsession3();
        cnt.mon.getVFsession4();
        
        // Test PageReference methods
        cnt.save();
        cnt.cancel();
    }
}