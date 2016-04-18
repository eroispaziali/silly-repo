public with sharing class EvidenceForNeedControllerExtension {

/*
  gary.grant@conseq.co.uk 
  Mar 2013
  Controller extension supporting the Evidence for Need object  
*/

 ApexPages.StandardController ctl;
 Evidence_For_Need__c en;

 public EvidenceForNeedControllerExtension(ApexPages.StandardController controller) 
 {
    ctl=controller;
    en = (Evidence_For_Need__c)ctl.getRecord();    
 }
 
 public void cancel()
 {
     ctl.cancel();
 }
 
 public void save() 
 {
    en = (Evidence_For_Need__c)ctl.getRecord();    

    /*Set the next version number for this type of ConfigText*/
    List<Evidence_For_Need__c> lis = [select version__c from Evidence_For_Need__c where Service__c =:en.Service__c and id<>:en.id order by version__c desc limit 1];        
    if(lis!=null && lis.size()>0) {
       en.version__c = (lis[0].version__c +1);
    } else {
        en.version__c = 1;
    }

   ctl.save();
     
 }
 
 public pageReference newVersion()
 {
     Evidence_For_Need__c newEn= en.clone(false,true);
     newEn.version__c = en.version__c+1;
     newEn.isCurrent__c = false;
     insert newEn;
     
     PageReference pr=new PageReference('/'+ newEn.id);
     pr.setRedirect(true);    
     return pr;
    
 }
 
 
 public void makeCurrent()
 {    
    List<Evidence_For_Need__c> lis =[select id, isCurrent__c from Evidence_For_Need__c where Service__c =:en.Service__c and id<>:en.id and isCurrent__c=true limit 1];
    
    if(lis!=null && lis.size()>0) {    
        Evidence_For_Need__c enCurr = lis[0];        
        enCurr.isCurrent__c=false;
    }
    
    en.isCurrent__c=true;
    en.Release_Date__c = date.Today();
    lis.add(en);

    update lis;    
 }

}