public with sharing class BDRThinControllerExtension {
    
/*******************************************************************************************************************************************
@author             gary.grant@conseq.co.uk
@date               Jan 2013
@description        Controller Extension. 
  
                     A thin controller to handle viewing a BDR__c and associated database records
  
********************************************************************************************************************************************/

 public BdrWrapper bdrWrapper {get;set;}  
 public BDRThinControllerExtension(ApexPages.StandardController controller)
 {
 	bdrWrapper = new bdrWrapper((BDR__c)controller.getRecord()); 
 }
     
}