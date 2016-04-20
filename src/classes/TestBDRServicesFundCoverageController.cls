@isTest
private class TestBDRServicesFundCoverageController {

/********************************************************************************************* 
 *   @author          gary.grant@conseq.co.uk
 *   @date            March 2013
 * 
 *   @description    TestBDRSearchController
 *
**********************************************************************************************/

static testMethod void TestServicesFundCoverageController()
{
    /* Search Fund Coverage */

    Map<String, Object> mapTestData= TestBdrUtils.getTestData();
    Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
    BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   

    String name = Apexpages.currentPage().getParameters().get('name');
    String locality = Apexpages.currentPage().getParameters().get('locality');
    String service_type = Apexpages.currentPage().getParameters().get('service_type');
    String fiscal_year = Apexpages.currentPage().getParameters().get('fiscal_year');    
    String funding_type = Apexpages.currentPage().getParameters().get('funding_type');
    String service_status = Apexpages.currentPage().getParameters().get('service_status');


    ApexPages.currentPage().getParameters().put('name','TestService1'); 
    Apexpages.currentPage().getParameters().put('locality','xxx Locality');
    Apexpages.currentPage().getParameters().put('service_type','Advocacy');   
    Apexpages.currentPage().getParameters().put('fiscal_year','2013/14');   
    ApexPages.currentPage().getParameters().put('funding_type','Funded'); 
    ApexPages.currentPage().getParameters().put('service_status','Open'); 
   
    BdrServicesFundCoverageController  e = new BdrServicesFundCoverageController ();    
        
    String s= e.sortDir;
    s= e.sortField;

    e.toggleSort();
    
   List<SelectOption> lisOptions = e.getLocalities();
    lisOptions = e.getFunding_Types();
    lisOptions = e.getService_Types();
    lisOptions = e.getYearsOptions();
    lisOptions = e.getService_Status_Options();
    
    e.runApexSearch();
    


    
    
  //  List<BdrFundReqWrapper> lisFrW = e.services;    

    //TODO this needs looking into.. the search is returning a null value
    //FundReqWrapper frW = lisFrW[0];    
    
}


}