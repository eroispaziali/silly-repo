@isTest
private class ServiceAlertMessageTest
{
static testMethod void ServiceAlertMessageTest1(){

    Services__c service = new Services__c(Name='Test service', National_Service__c = true);
    insert service;
    
    PageReference pageRef = Page.ServiceAlertMessage;
    test.setCurrentPage(pageRef);
    
    ApexPages.StandardController stdCon = new ApexPages.StandardController(service );
    pageRef.getParameters().put('id', service.Id);
    ServiceAlertMessage cnt = new ServiceAlertMessage(stdCon);
    
    
    }
}