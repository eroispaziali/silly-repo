global class DcoBatchGeocoder implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable 
{

   global Database.QueryLocator start(Database.BatchableContext BC)
   {
      String query = 'select Name, service_description__c, service_postcode__c, '+
                         'service_street__c, service_city__c, '+
                         'Default_Location__r.Postcode__c, '+
                         'Default_Location__r.Geographic_location__latitude__s,'+ 
                         'Default_Location__r.Geographic_location__longitude__s '+
                         'from Services__c '+
                         'where Location__latitude__s = null '+
                         'and service_status__c = \'Open\' '+
                         'and National_Service__c = false '+
                         'and (Service_Postcode__c <> null or (Default_Location__r.Postcode__c <> null and Default_Location__r.Geographic_location__latitude__s <> null))';
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
     for(sobject svc : scope){
      DcoGeocodeUtils.geocode((Services__c)svc);
     }
     update scope;
   } 
   
   global void finish(Database.BatchableContext BC)
   {
   }

  global void execute(SchedulableContext SC) 
  {
      DcoBatchGeocoder geocoder = new DcoBatchGeocoder();
      Database.executeBatch(geocoder,4);
  }

}