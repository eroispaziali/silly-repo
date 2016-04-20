@isTest
public with sharing class DcoBatchGeocoder_Test 
{
	
	 @isTest
    private static void runTest()
    {
      Account locality = new Account();
      locality.Name = 'Test Locality';
      locality.RecordTypeId = [select Id from RecordType where Name = 'Internal Organisation' and SobjectType = 'Account'].Id;
	  insert locality;
        
      Services__c svc = new Services__c();
      svc.Name = 'Test Service 1';
      svc.service_description__c = 'Test Service 1';
      svc.service_postcode__c = 'SW18 4DU';
      svc.service_street__c = '241 Garratt lane Wandsworth';
      svc.service_city__c = 'London';
      svc.service_status__c = 'Open';
      svc.National_Service__c = false;
      svc.Locality__c = locality.Id;
      insert svc;
      
      svc = new Services__c();
      svc.Name = 'Test Service 2';
      svc.service_description__c = 'Test Service 2';
      svc.service_postcode__c = 'X';
      svc.service_street__c = 'X';
      svc.service_city__c = 'London';
      svc.service_status__c = 'Open';
      svc.National_Service__c = false;
      svc.Locality__c = locality.Id;
      insert svc;
	
      DcoBatchGeocoder geocoder = new DcoBatchGeocoder();
      Database.executeBatch(geocoder,4);
    }

}