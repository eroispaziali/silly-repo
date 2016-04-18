public class BDCBidOutcome {
    public Bid__c bid;
    private final ApexPages.StandardController cnt;
    
    public BDCBidOutcome() {
        // Get bid object from page parameters
        bid = [select id, OwnerId, Outcome__c from Bid__c
               where id = :ApexPages.currentPage().getParameters().get('id')];
    }
    
    // Visualforce extension constructor
    public BDCBidOutcome(ApexPages.StandardController controller) {
        bid = (Bid__c)controller.getRecord();
        cnt = controller;
    }
    
    public string getOwnerId() {
        return bid.OwnerId;
    }
    
    public PageReference setSuccessful() {
        boolean err;
        
        for (Bid__c b : [select id, OwnerId, BDM__c, Outcome__c from Bid__c where id =:cnt.getId()]) {
            // only the owner or BDM can update the bid's outcome
            if (UserInfo.getUserId() == b.OwnerId || UserInfo.getUserId() == b.BDM__c) {
                b.Outcome__c = 'Successful';
                update b;
                err = false;
            } else {
                err = true;
            }
        }
        
        if (err == true){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                'You cannot update this bid\'s outcome because you are not the record owner or its BDM.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        // Redirect back to the bid
        return cnt.view().setRedirect(true);
    }
    
    public PageReference setUnsuccessful() {
        boolean err;
        for (Bid__c b : [select id, OwnerId, BDM__c, Outcome__c from Bid__c where id =:cnt.getId()]) {
            // only the owner or BDM can update the bid's outcome
            if (UserInfo.getUserId() == b.OwnerId || UserInfo.getUserId() == b.BDM__c) {
                b.Outcome__c = 'Unsuccessful';
                update b;
                err = false;
            } else {
                err = true;
            }
        }
        
        if (err == true){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                'You cannot update this bid\'s outcome because you are not the record owner or its BDM.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        /* Redirect back to the bid
        return cnt.view().setRedirect(true);*/
        //Redirect the page to update the Reason for outcome field for the current record
        PageReference pageRef = Page.Bid_reasonforoutcome;
        pageRef.getParameters().put('Id', bid.Id);
        return pageRef.setRedirect(true);
    }
    
    //
    // TEST CASE
    //
    private static testMethod void testBidOutcome() {
        // Find BDM user
        
        UserRole role = [select id from UserRole where Name = 'BDM - North' limit 1]; 
        User u = [select id from User where isActive = true and UserRoleId = :role.Id limit 1];        
        
        
        Bid__c b;
        
        system.runAs(u) {
            // Create the standard controller for the bid
            b = new Bid__c(Name='testbid', Bid_Value__c=0.0, BDM__c=u.Id);
            b.OwnerId = u.Id;
            insert b;
            
            // Set up the VF pages
            PageReference pageRef = Page.BidSuccessful;
            test.setCurrentPage(pageRef);
            pageRef = Page.BidUnsuccessful;
            test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', b.Id);
            
            // create this class
            BDCBidOutcome bo = new BDCBidOutcome();
            ApexPages.StandardController stdCon = new ApexPages.StandardController(b);
            bo = new BDCBidOutcome(stdCon);
            
            // test methods
            PageReference p = bo.setSuccessful();
            //System.assertEquals(b.Outcome__c, null);
            p = bo.setUnsuccessful();
            //System.assertEquals(b.Outcome__c, null);
        }
        
        role = [select id from UserRole where Name = 'BDM - South' limit 1];
        u = [select id from User where isActive = true and UserRoleId = :Role.Id limit 1];
        
        system.runAs(u) {
            // Set up the VF pages
            PageReference pageRef = Page.BidSuccessful;
            test.setCurrentPage(pageRef);
            pageRef = Page.BidUnsuccessful;
            test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', b.Id);
            
            // create this class
            BDCBidOutcome bo = new BDCBidOutcome();
            ApexPages.StandardController stdCon = new ApexPages.StandardController(b);
            bo = new BDCBidOutcome(stdCon);
            
            // test methods
            PageReference p = bo.setSuccessful();
            //System.assertEquals(b.Outcome__c, null);
            p = bo.setUnsuccessful();
            //System.assertEquals(b.Outcome__c, null);
        }
    }
}