@isTest
private class TestBDRSearchController {

/********************************************************************************************* 
 *   @author          gary.grant@conseq.co.uk
 *   @date            March 2013
 * 
 *   @description    TestBDRSearchController
 *
**********************************************************************************************/

static testMethod void TestBDRSearchController() 
{
    /* Search for a BDR and search for it */

    BDRSearchController e = new BDRSearchController();    
    String s = e.getCreateUrl();        
    s= e.sortDir;
    s= e.sortField;
    e.toggleSort();
    
    Integer i = e.getPendingApprovalCount();
    i = e.getBDRCount();
    
    ApexPages.currentPage().getParameters().put('Name','Gary Grant'); 
    Apexpages.currentPage().getParameters().put('owner','Gary Grant');
    Apexpages.currentPage().getParameters().put('locality','Cardiff');
    Apexpages.currentPage().getParameters().put('status','Accepted');
    Apexpages.currentPage().getParameters().put('ref','XXXX');
    Apexpages.currentPage().getParameters().put('bdr_name','XXXXX');
    Apexpages.currentPage().getParameters().put('bdm_name','XXXXX');
    Apexpages.currentPage().getParameters().put('approver_name','XXXXX');
    Apexpages.currentPage().getParameters().put('income_source','Cardiff');
       
    e.runApexSearch();

    
    List<BDRSearchController.BdrSearchWrapper> lis = e.lisBdr;
    List<SelectOption> lisOptions = e.getBDMs();
    lisOptions = e.getStatusOptions();
    lisOptions = e.getLocalities();
    lisOptions = e.getAreas();
    lisOptions = e.getIncomeSources();
    lisOptions = e.getApprovers();
    lisOptions = e.getOwners();
    
    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1'); 
    BDRSearchController.BdrSearchWrapper sw = new BDRSearchController.BdrSearchWrapper(bdr);
    
}


}