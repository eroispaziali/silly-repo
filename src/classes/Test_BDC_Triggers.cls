/**
 * Test methods for BDC triggers on Bids and Proposals
 */
@isTest
private class Test_BDC_Triggers {
    /*
     * Test Bid sharing with BDM user
     */
    static testMethod void TestBidTrigger() {
        // find BDM user
        UserRole role = [select id from UserRole where Name = 'BDM - North' limit 1]; 
        User u = [select id from User where isActive = true and UserRoleId = :role.Id limit 1];
        
        Bid__c bid = new Bid__c();
        bid.Name = 'Test Bid';
        bid.BDM__c = u.Id;
        bid.Bid_value__c = 12;
        
        insert bid;
    }
    
    
    /*
     * Test Proposal sharing with BDM user
     */
     
    static testMethod void TestProposalTrigger() {
        // find BDM user account
        UserRole role = [select id from UserRole where Name = 'BDM - North' limit 1]; 
        User u = [select id from User where isActive = true and UserRoleId = :role.Id limit 1];
        
        Proposal__c proposal = new Proposal__c();
        proposal.Name = 'Test Proposal';
        proposal.BDM__c = u.Id;
        proposal.Service_definition__c = 'Advocacy';
        
        insert proposal;
    }
}