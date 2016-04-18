@isTest
private class TestBDRControllers {

/********************************************************************************************* 
 *   @author          gary.grant@conseq.co.uk
 *   @date            March 2013
 * 
 *   @description     A set of test methods for various BDR Controllers    
 *                    Update: May 2014: Addition of tests for refreshing Fiscal Years  
 *                    Use TestBdrUtils.getTestData() to generate a full set of test data
 *                    That method generates a Map of Maps with full sets of data
 *
**********************************************************************************************/



static testMethod void TestServicesSearchController()
{
    /* Search for a Service*/

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   

    ApexPages.currentPage().getParameters().put('bdr',bdr.id); 
    ApexPages.currentPage().getParameters().put('Name','TestService1'); 
    Apexpages.currentPage().getParameters().put('locality','xxx Locality');
    Apexpages.currentPage().getParameters().put('service_type','Advocacy');   
    Apexpages.currentPage().getParameters().put('service_status','Draft');

    BdrServicesSearchController e = new BdrServicesSearchController();    

    Test.startTest();

    String s= e.sortDir;
    s= e.sortField;

    e.toggleSort();
        
    e.runApexSearch();
  
    List<SelectOption> lisOptions = e.getLocalities();
    lisOptions = e.getService_Types_Options();
    lisOptions = e.getLocality_Options();
    lisOptions = e.getService_status_options();
  
    List<BDRServicesSearchController.DCSearchWrapper> lisSvcW = e.serviceList;    
    BDRServicesSearchController.DCSearchWrapper svcW = lisSvcW[0];
    svcW.isSelected=true;
    lisSvcW.add(svcW);
    
    e.add(); 
    e.cancel();
    
}

static testMethod void TestBdrThinControllerExtension()
{
 
    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);
    BdrThinControllerExtension e = new BdrThinControllerExtension(sc);        
	BdrWrapper bdrW = e.bdrWrapper;
}

static testMethod void TestServiceAddUpdateExtensionAdd ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    BdrWrapper bdrW = new BdrWrapper(bdr);
 
    Services__c svc1 = bdrW.services.svcWrappers[0].svc;

    ApexPages.currentPage().getParameters().put('bdrid', bdr.id);    
    ApexPages.StandardController sc = new ApexPages.standardController(svc1);

    Test.startTest();
    BdrServiceAddUpdateExtension e = new BdrServiceAddUpdateExtension(sc);        
    
    List<SelectOption> lisOptions = e.getServiceLocalities();
    
    // Use a random Account to populate the OperatedBy
    // This should really be a locality, so the query 
    // returns Services Offices
    Account acct = [select id from Account limit 1];
    
    e.selectedLocality = acct.id;
    lisOptions = e.getOperatedByOptions();
    lisOptions = e.Internal_Evaluation_Methods_options;
    
    e.save();  
    e.saveAndClose();
    e.cancel();  

}

static testMethod void TestServiceAddUpdateExtensionUpdateExtend ()
{

    /* Emulates editing an existing record that does not have FR or Efn already in place
       this is the legacy data use case
    */

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    BdrWrapper bdrW = new BdrWrapper(bdr);

    Services__c svc1 = bdrW.services.svcWrappers[0].svc;

    ApexPages.currentPage().getParameters().put('bdrid', bdr.id);    

    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.standardController(svc1);
    BdrServiceAddUpdateExtension e = new BdrServiceAddUpdateExtension(sc);        
    
    e.save();    

}

static testMethod void TestServiceAddUpdateExtensionUpdate ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    BdrWrapper bdrW = new BdrWrapper(bdr);
    
    List<BdrServiceWrapper> lis = bdrW.services.svcWrappers;
    BdrServiceWrapper svcW = lis[0];
    Services__c svc = svcW.svc;

    ApexPages.currentPage().getParameters().put('bdrid', bdr.id);        
    ApexPages.StandardController sc = new ApexPages.standardController(svc);

    Test.startTest();
    BdrServiceAddUpdateExtension e = new BdrServiceAddUpdateExtension(sc);  
    boolean b = e.allowServiceEdit; 
    
    List<Enhanced_Lookup__c> lisEL = e.ServicesFrameworkList;     
    
    e.save();    

}

static testMethod void TestServiceAdd ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    BdrWrapper bdrW = new BdrWrapper(bdr);
    
    Services__c svc = new Services__c();

    ApexPages.currentPage().getParameters().put('bdrid', bdr.id);    
    ApexPages.StandardController sc = new ApexPages.standardController(svc);

    Test.startTest();
    BdrServiceAddUpdateExtension e = new BdrServiceAddUpdateExtension(sc);  
    List<Enhanced_Lookup__c> lis = e.ServicesFrameworkList;     
    boolean b = e.allowServiceEdit; 
    e.save();
    e.saveAndClose();
    
}


static testMethod void TestServiceEdit ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    BdrWrapper bdrW = new BdrWrapper(bdr);
    
    List<BdrServiceWrapper> lis = bdrW.services.svcWrappers;
    BdrServiceWrapper svcW = lis[0];
    Services__c svc = svcW.svc;

    ApexPages.currentPage().getParameters().put('bdrid', bdr.id);    
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);

    Test.startTest();
    BdrControllerExtension e = new BdrControllerExtension(sc);
    e.serviceId = svc.id;
    e.editService();
    
    e.rid=null;
    e.removeService();
    e.deleteService();
    
}


static testMethod void TestCustomUtils ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    
    Map<String, User> mapUser = (Map<String,User>)mapTestData.get('users');
    User userBDM = mapUser.get('userBDM');
    User userAM = mapUser.get('userAM');
    
    // Create an approval request for the JIS     
    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    req1.setComments('Submitting request for approval.');
    req1.setObjectId(bdr.Id);

    // Submit the approval request 
    try {    
          Approval.ProcessResult result1 = Approval.process(req1);               
        // Verify the results  
        System.assert(result1.isSuccess());
        System.assertEquals('Pending', result1.getInstanceStatus(), 'Instance Status'+result1.getInstanceStatus());
        
    } catch (Exception x) {
        //There may be no approval process defined in this org..         
       System.debug('Approval processing failed');     
   }
    
    Test.startTest();

    system.runas(userAM) {
       boolean b = CustomUtils.isCurrentApprovalActor(bdr.id, userAm.id);
       b = CustomUtils.hasUserAccess(bdr.id, userAm.id, 'Edit');
       b = CustomUtils.hasUserAccess(bdr.id, userAm.id, 'Read');
       b = CustomUtils.hasUserAccess(bdr.id, userAm.id, 'All');
       b = CustomUtils.hasUserAccess(bdr.id, userAm.id, 'Delete');
       
       b = CustomUtils.isModifyAllData(userAm.id);       
       
       b=CustomUtils.isApprovalInProcess(bdr.id);
       
     }

}

static testMethod void TestAddFiscalYears ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    
    // Append two fiscal years to the end of the data and check the record counts have changed
    Test.startTest();
    bdr.Fiscal_Years__c = '2012/13;2013/14;2014/15;2015/16';
    update bdr;
    
}

static testMethod void TestReleaseServicesForEdit ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    
    // Append two fiscal years to the end of the data and check the record counts have changed
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);
    BdrControllerExtension e = new BdrControllerExtension(sc);
    
    boolean b = e.showReleaseServicesForEditAction;
    e.doReleaseServicesForEdit();
    
}


static testMethod void BdrPrintPDF()
{
      
    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');
    BDRWrapper bdrW = new BDRWrapper(bdr); 
      
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);

    bdr.Partnership_Status__c='Lead Provider';
    bdr.Partnership_Detail__c='Blah Blah';
    bdr.Tender__c='Yes';
    bdr.Bid_Feedback__c='Price';

    Test.startTest();
    BdrControllerExtension e = new BdrControllerExtension(sc);
    BdrPdfBuilder p = new BdrPdfBuilder(bdrW);
    p.run();


}

static testMethod void BdrAttachPDF()
{
      
    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');
      
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);

    bdr.Partnership_Status__c='Lead Provider';
    bdr.Partnership_Detail__c='Blah Blah';
    bdr.Tender__c='Yes';
    bdr.Bid_Feedback__c='Price';

    Test.startTest();
    BdrControllerExtension e = new BdrControllerExtension(sc);

    BdrPdfUtils pdfUtil = new BdrPdfUtils();
    BdrPdfUtils.storeHtmlAttachment('SomeFile.pdf', 'Some File in a Test Method', bdr);

}

static testMethod void BdrControllerExtensionAddComponents()
{
      
    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
  
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);

    Test.startTest();
    BdrControllerExtension e = new BdrControllerExtension(sc);

    e.clicked();

    /* Test the code where these already exist
       There is another Test method where they do not */ 
    e.addIncomeBlock();    
    e.addContract();       
    
    e.save();
    
    e.cancel();
    e.cancelUpdateEvidence();
    e.updateEvidence();

    boolean b = e.showSuccessActions;   
    b = e.showDeclinedAction;    
    b = e.showAddServicesAction;
    
  }


/* Add Income and Add Contract */
static testMethod void TestAddIncomeAddContract()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr3');   
    
    Test.startTest();   
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);    
    BdrControllerExtension e = new BdrControllerExtension(sc);
    e.addIncomeBlock();
    e.addContract();
    
}
    
static testMethod void TestBdrControllerExtensionProperties ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');  
    BdrWrapper bdrW = new BdrWrapper(bdr);
    
    List<BdrServiceWrapper> lis = bdrW.services.svcWrappers;
    BdrServiceWrapper svcW = lis[0];
    Services__c svc = svcW.svc; 
    
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);    
    
    Test.startTest();   
    BdrControllerExtension e = new BdrControllerExtension(sc);

    boolean b = e.allowEditBDRTimeSpan; 
    String s = e.hasContract;
    s = e.hasAllocation;
    
    e.serviceId=svc.Id;
    
    // Checkbox Option Lists
    List<SelectOption> lisOptions = e.getRequired_Signatures_Options();
    lisOptions = e.getHighlighted_Contract_Items_Options();
    lisOptions = e.getHr_Implications_Options();
    lisOptions = e.getReasons_Declined_Options();
    lisOptions = e.getLocalities();
    
    
    String approverId = e.currentApproverName;
      
    Decimal d = e.openServicesCount;
    
    lisOptions = e.notificationOptions;
    
    b = e.show_Initial_Acceptance_Action;
    b = e.showDeleteAction;
    b = e.showCloneAction;
    b = e.show_Request_Approval_Final_Proposal_Action;
    b = e.showRequestFinalApprovalAction;
    b = e.showAdminSuccessfulAction;
    b = e.canCurrentUserEdit;
    b = e.currentApprovalActor;
    b = e.userSysAdmin;
    
    String id = e.bdrWrapper.bdrid;

    id = e.bdrWrapper.contractId15;
    
    List<BDR__c> lisBDrDependent = e.bdrWrapper.dependentBdrs;
    String[] sMsg = e.bdrWrapper.validationMessages;
    
    e.bdrWrapper.syncOwner();
    
    /* Messages are different when the BDR is not in Draft mode */
    e.bdrWrapper.bdr.Status__c='Live'; 
    sMsg = e.bdrWrapper.validationMessages;

}


static testMethod void TestBdrControllerExtensionCreateContractExtension ()
{ 
    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    
    /* Extension is only allowed on Current BDRs */
    bdr.Status__c='Live';
    
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);    
    
    Test.startTest();   
    BdrControllerExtension e = new BdrControllerExtension(sc);
    
    System.assert(e.dummyContract.Start_Date__c == e.bdrWrapper.contract.End_Date__c.addDays(1));
    
    /* Put data into the dummyBDR that would be entered by the user into the dialog
       The contract start and end dates will be computed based on the existing data */
    e.dummyBdr.Total_Value__c=20000;    
    
    /* This would normally only be called on a current BDR */
    PageReference pr = e.createBdrExtension();
        
}

 
static testMethod void TestBdrControllerExtensionActions ()
{ 
    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);    
    
    Test.startTest();   
    BdrControllerExtension e = new BdrControllerExtension(sc);
    
    PageReference pr = e.contractAttachmentPage;
    pr = e.submitForApproval();
    e.refreshData();
    
    pr=e.returnToEdit('Services');
        
    pr = e.addNewService(); 
    pr = e.addExistingServices();
    pr = e.setSuccessful();
        
}
    
static testMethod void TestSave ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);

    Test.startTest();   
    BdrControllerExtension e = new BdrControllerExtension(sc);
    PageReference ref = e.save();
    
     
}     
 
static testMethod void TestSaveAndClose ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);
    
    Test.startTest();   
    BdrControllerExtension e = new BdrControllerExtension(sc);
    PageReference ref = e.saveAndClose();
     
}

static testMethod void TestCloneBdr ()
{

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   
    
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);

    Test.startTest();       
    BdrControllerExtension e = new BdrControllerExtension(sc);

    e.dummyBdr.Intended_Start_Date__c = bdr.Intended_Start_Date__c.addMonths(1);    
    e.dummyBdr.Estimated_Duration__c=12;
    e.dummyBdr.Total_Value__c = 20000;

    PageReference ref = e.cloneBdr();
    //BDR__c bdr2 = BdrUtils.cloneBdr(bdr.id, Date.today(),12, 20000);    
     
}    

static testMethod void TestContentionError()
{
    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');  
    
    String id = bdr.id;
    String sQuery = 'select SystemModStamp, LastModifiedDate, LastModifiedById from ' + bdr.getSObjectType().getDescribe().getName() + ' where id =:id for Update';
    List<sObject> lis = database.query(sQuery);
    
    ApexPages.StandardController sc = new ApexPages.standardController(bdr);

    Test.startTest();       
    BdrControllerExtension e = new BdrControllerExtension(sc);
    e.putContentionErrorMessage(lis, bdr);
    system.assert(e.save()==null);
    
}

         
    
}