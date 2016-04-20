@isTest
public class TestBDRComponents {

    /***********************************************************************************************
     * @author          gary.grant@conseq.co.uk   
     * @date            June 2013 
     * @description     A set of test methods for BDR Application components
    ***********************************************************************************************/

static testMethod void TestAddServices()
{
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
	BdrWrapper bdrW = new BdrWrapper(bdr);
	
	Services__c svc = bdrW.services.svcRecords[0];
	
	bdrW.removeService(svc.id, false);
	BdrUtils.addService(bdr.id, svc.id);
	
	bdrW.removeService(svc.id, false);
	List<String> lisSvcIds = new List<String>();
	lisSvcIds.add(svc.id);
	BdrUtils.addServices(bdr.id, lisSvcIds);
	
}


static testMethod void TestDeleteService()
{
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
	BdrWrapper bdrW = new BdrWrapper(bdr);
	
	BDR__c bdr2 = (BDR__c)mapBdr.get('bdr2');
	
	List<BdrServiceWrapper> lis = bdrW.services.svcWrappers;
    BdrServiceWrapper svcW1 = lis[0];
    BdrServiceWrapper svcW2 = lis[1];
    
    Services__c svc1 = svcW1.svc;
    Services__c svc2 = svcW2.svc;
    
    /* True means delete as well as remove. 
       This will not actually do the deletion because the service is still linked to the orther BDR 
    */
    bdrW.removeService(svc1.id, true);
    bdrW.removeService(svc2.id, false);
	
	Test.startTest();
	ApexPages.StandardController sc = new ApexPages.standardController(bdr2);           
    BdrControllerExtension e = new BdrControllerExtension(sc); 
	
	/*Use the second BDR linked to the service. Deletion would fail if the Service was still connected to the first BDR 
	  in which case it would just be removed and not deleted. 	
	*/
	e.rid=(svc1.id);
	e.removeService();
	
	/*This deletion will succeed because the service is no longer linked to any other BDRs */  
	e.rid=(svc2.id);
	e.deleteService();
	
}





/*
static  testMethod void TestUpdateStatusUnsuccessful()
  {
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
	BdrWrapper bdrW = new BdrWrapper(bdr);
    
    Test.StartTest();
    
    Schema.DescribeFieldResult field = BDR__c.Bid_Feedback__c.getDescribe();
    Schema.PicklistEntry PickEntry = field.getPicklistValues()[0]; 
    String s = PickEntry.getLabel();    
    bdr.Bid_Feedback__c = s; 
  //  bdr.Bid_Feedback_Detail__c='This is a reason for unsuccessful';
    
    bdrW.updateStatus('Unsuccessful');
        
  // Service status will have rem,ained unaffected
    List<Services__c> lis = bdrW.services.svcRecords;
    for (Services__c svc : lis) {    
        System.assert(svc.service_status__c=='Draft');
    }

    ShowActionsTest(bdr);    
    
}*/

static void ShowActionsTest(BDR__c bdr){

    ApexPages.StandardController sc = new ApexPages.standardController(bdr);
    BdrControllerExtension e = new BdrControllerExtension(sc);
    
    boolean b = e.hasFiscalYears;    
    b = e.showSuccessActions;    
    b = e.showDeclinedAction;                      
    b = e.showAddServicesAction;

}

static testMethod void BdrControllerExtensionNewBdrTest()
{
   BDR__c bdr = new BDR__c();
   ApexPages.StandardController sc = new ApexPages.standardController(bdr);
   BdrControllerExtension e = new BdrControllerExtension(sc);
   
    boolean b = e.showSuccessActions;  
    b = e.showDeclinedAction;    
    b = e.showAddServicesAction;
   
}


static testMethod void BdrControllerExtensionSubmitTest()
{
      
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
  
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);
   
    Test.startTest();    
    BdrControllerExtension e = new BdrControllerExtension(sc);

    List<BdrServiceWrapper> lis = e.bdrWrapper.services.svcWrappers;
    BdrServiceWrapper svcW = lis[0];
    Services__c svc = svcW.svc;
    Evidence_For_Need__c efn = svcW.evidence;
    
    e.evid=efn.id;
    e.updateEvidence();
    
    e.validateSubmit();
    
    e.cancel();
    e.cancelUpdateEvidence();

}

static testMethod void BdrControllerExtensionAddRemoveService()
{
      
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1'); 
	BdrWrapper bdrW = new BdrWrapper(bdr);  	
  
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);

    List<BdrServiceWrapper> lis = bdrW.services.svcWrappers;
    BdrServiceWrapper svcW = lis[0];
    Services__c svc = svcW.svc;
    
    Test.startTest();
    BdrControllerExtension e = new BdrControllerExtension(sc);

    e.rid=svc.id;
    e.removeService();    
    e.addServices();        
    Decimal d = e.servicesCount;        
    
}

static testMethod void BdrDeleteTest()
{

	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   

    ApexPages.StandardController sc = new ApexPages.standardController(bdr);
   
    Test.startTest();   
    BdrControllerExtension e = new BdrControllerExtension(sc);  
    e.doDelete();

}
/* Run thru the error trapping code in BdrServiceWrapperListUtils */  
static testMethod void BdrServiceWrapperListTest()
{
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BdrServiceWrapperList> mapSwl = (Map<String, BdrServiceWrapperList>)mapTestData.get('swl');
	BdrServiceWrapperList svcWL = (BdrServiceWrapperList)mapSwl.get('swl1');   
	BdrServiceWrapper svcW = svcWL.svcWrappers[0];
	
    Evidence_for_Need__c efn = svcW.evidence;
    /* This is too big for the field size, so should throw an error and run the method thru the failed save code*/
    efn.Version__c=500000;
     
    boolean b = BdrServiceWrapperUtils.updateEvidence(efn, svcW.svc);
    System.assert(b==false);	
	
	List<BdrFundReqWrapper> lisFrW = svcW.fundReqWrappers;
	BdrFundReqWrapper frW = lisFrW[0];
	BdrFundReqWrapper frW2 = lisFrW[1];
	
	Funding_Requirement__c fr = frW.freq;
	Funding_Requirement__c fr2 = frW2.freq;
	
	/* This will throw an error on the uniqueFiscalService Field because of the duplicate fiscal year-service combo*/
	fr2.Fiscal_Year__c = fr.Fiscal_Year__c;
	
	List<Funding_Requirement__c> lisFr = new List<Funding_Requirement__c>();
	lisFr.add(fr);
	lisFr.add(fr2);
	
	b = BdrServiceWrapperUtils.updateFundingRequirements(lisFr, svcW.svc);
	system.assert(b==false);
	
}



static testMethod void BdrControllerExtensionSetDeclinedTest()
{
      
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
  
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);
    
    Schema.DescribeFieldResult field = BDR__c.Bid_Feedback__c.getDescribe();
    Schema.PicklistEntry PickEntry = field.getPicklistValues()[0]; 
    String s = PickEntry.getLabel();    
    bdr.Bid_Feedback__c = s; 
    bdr.Bid_Feedback_Detail__c='This is a reason for unsuccessful';
    
    Test.startTest();

    BdrControllerExtension e = new BdrControllerExtension(sc);
    e.setDeclined();
}

static testMethod void BdrControllerExtensionSetUnSuccessfulTest()
{
      
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
  
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);
    
    Schema.DescribeFieldResult field = BDR__c.Bid_Feedback__c.getDescribe();
    Schema.PicklistEntry PickEntry = field.getPicklistValues()[0]; 
    String s = PickEntry.getLabel();    
    bdr.Bid_Feedback__c = s; 
   bdr.Bid_Feedback_Detail__c='This is a reason for unsuccessful';
    
    Test.startTest();

    BdrControllerExtension e = new BdrControllerExtension(sc);
    e.setUnsuccessful();
}

static testMethod void BdrDependentTest()
{
      
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
	BdrWrapper bdrW = new BdrWrapper(bdr);
    
    Test.startTest();
    List<BDR__c> lisBdr = BdrUtils.getDependentBdrs(bdrW);      

}

static testMethod void bdrWrapperAllocationCalcTest()
{

	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
	BdrWrapper bdrW = new BdrWrapper(bdr);
    
    Test.startTest();
    String s='';
    s=bdrW.hasPartner;
    boolean b = bdrW.hasFiscalYears;
            
    Decimal d = 0;
    d=bdrW.totalAllocation;
    d=bdrW.totalFundingRequirement;
    d=bdrW.totalOtherSecureAllocation;
    d=bdrW.totalOtherProposedAllocation;
    
}

static testMethod void TestValidateBdr()
{

	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
	BdrWrapper bdrW = new BdrWrapper(bdr);

	List<String> lis = bdrW.validateBDR();

}

static testMethod void TestCustomUtils()
{
	Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	Map<String, User> mapUser = (Map<String,User>)mapTestData.get('users');
	User u = (User)mapUser.get('userBDM');   
	
	List<Group> lis = CustomUtils.getGroupsForUser(u.id);
	boolean b = CustomUtils.isUserInPermissionSet(u.id, 'Dummy Set');

	/* Get a random role name */
	UserRole role = [select name from UserRole limit 1];	
	b = CustomUtils.isUserInOrAboveRole(u.id, role.Name);
	
}


}