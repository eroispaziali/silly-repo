@isTest
private class DcoApiServiceHtmlController_Test 
{
    @isTest
    private static void runTest()
    {
    	Services__c svc = new Services__c();
      svc.Name = 'Test Service 1';
      svc.service_description__c = 'Test Service 1';
      svc.service_postcode__c = 'SW18 4DU';
      svc.service_street__c = '241 Garratt lane Wandsworth';
      svc.service_city__c = 'London';
      svc.service_status__c = 'Open';
      svc.Location__Latitude__s = 52;
      svc.Location__Longitude__s = 0;
      svc.National_Service__c = true;
      insert svc;
      
      System.RestContext.request = new RestRequest();
      System.RestContext.response = new RestResponse();
      
      DcoApiServiceHtmlController.httpGet();
      
      RestContext.request.requestURI = 'https://test.com/'+svc.Id;  
      DcoApiServiceHtmlController.httpGet();
    }

}