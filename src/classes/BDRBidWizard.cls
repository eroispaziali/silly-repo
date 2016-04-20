public without sharing class BDRBidWizard {
/*

  *************** CAUTION ****************
  This class set to WITHOUT SHARING to enable all records to be updated
  by any user. Access to certain records is controlled via the 
  sharing rules and access to the UI components
    
  gary.grant@conseq.co.uk 
  Jan 2013
  A combined controller to handle creating and editing a bdr package
  The package contains the bdr header, the contract, any related services (with Evidence for Needs), related income blocks
  
  Funding Requirements, Evidence For Needs and Allocations are 
  retrieved and held in both separate lists and inside their respective wrappers
  This avoids the need for multiple queries inside each wrapper and also 
  enables the set of records to be updated in a single operation
  
  This is odd (having the same object accessible via a wrapper and 
  as a consolidated standalone list), but it's a Salesforce thing....   


  TODO !! Remove actions : Contract, BID, Partner, Income
  
*/

public ApexPages.StandardController stdController;
public BDR__c bdr  {get;set;} 
public string BDRName  {get;set;}
public string BDRReference {get;set;}
public id BDRid  {get;set;}
public Boolean inWizard {get;set;}
public Boolean bHasBid  {get;set;}


//constructor

public BDRBidWizard (ApexPages.StandardController pController) {
    stdController = pController;
    bdr = [select id, Name, BDR_Name__c, 
                            Bid_Status__c, 
                            Clarification_Questions_Deadline__c,
                            Bid_Sign_Off_Deadline__c,
                            Bid_Submission_Deadline__c,
                            Fixed_Tender_Amount__c,
                            Tupe__c,
                            Tupe_Detail__c,
                            Recruitment_Required__c,
                            Any_Redundancies__c,
                            Volunteer_Recruitment__c
             from BDR__c where id=:ApexPages.currentPage().getParameters().get('id')]; 
    BDRid  =bdr.id;
    BDRName = bdr.BDR_Name__c;
    BDRReference = bdr.Name;
    String strWizard;
    strWizard=ApexPages.currentPage().getParameters().get('BDRwizard');
    if (strWizard==null) {inWizard = false;}
    if (strWizard=='1') {inWizard = true;} else {inWizard=false;}
    
    if ((bdr.Bid_Status__c==null)||(bdr.bid_status__c=='')){
        bHasBid=false;}
    else {        bHasBid=true;}

}

    public PageReference cancel(){
        return new PageReference('/apex/BDRView?id='+ bdrid );
    } 
    public PageReference nextPage(){
        if (inWizard){
            return new PageReference('/apex/BDRAddContractWizard?id='+ bdrid +'&BDRWizard=1');
        }
        else {
            return new PageReference('/apex/BDRView?id='+ bdrid );
        }
    }

 public PageReference AddBid(){
     bHasBid=true;
     return null;
 }
 public PageReference saveBidAndContinue(){
      update bdr;
      return null;
 }
  public PageReference saveBid(){
      update bdr;
      return nextPage();
 }
}