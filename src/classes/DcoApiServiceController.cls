@RestResource(urlMapping='/api/service/*')
global with sharing class DcoApiServiceController 
{
   global static String SERVICE_FIELD_LIST = 'Id,Accessibility__c,CreatedDate,'+
      'Contact_first_name__c,Contact_last_name__c,Days_per_week__c,Description__c,Display_on_public_website__c,'+
      'Getting_There__c,Image_Doc_ID__c,Local_Authority__c,Locality__c,Location__Latitude__s,Location__Longitude__s,'+
      'Name,National_Service__c,Operated_By__r.Name,Other_Target_Client_Group__c,'+
      'Other_type__c,Parking__c,Postcode_Constituency__c,Postcode_Local_Authority__c,Postcode_Primary_Care_Trust__c,'+
      'Postcode_Ward__c,Postcodes_Covered__c,Price__c,Primary_contact__c,Record_Type_Name__c,Refreshments__c,'+
      'Registered_With_Regulator__c,Restrict_access__c,Site__c,Sub_Type__c,Toilet_Facilities__c,'+
      'service_city__c,service_code__c,service_contact_hours__c,service_country__c,service_county__c,service_description__c,'+
      'service_email__c,service_operationhours__c,service_operationhourscomment__c,service_postcode__c,service_status__c,'+
      'service_street__c,service_targetclientgroup__c,service_telephone__c,service_type__c,service_website__c, '+
      'Default_Location__r.Postcode__c, Default_Location__r.Street__c, Default_Location__r.City__c, '+
      'Default_Location__r.County__c,Default_Location__r.Address_Details__c,'+ 
      'Default_Location__r.Geographic_Location__latitude__s,Default_Location__r.Geographic_Location__longitude__s,'+
      'Referral_only__c,Funder_restriction__c,Service_Web_Name__c, Operated_By__r.Office_Contact_Hours__c,'+
      'Opening_Times_Guidebook__c,Service_Criteria__c';
    
    @HttpGet
   global static void httpGet()
   {
      RestResponse resp = RestContext.response;
      DcoApiUtils.setShortCache();
      resp.headers.put('Access-Control-Allow-Origin', '*');
      resp.headers.put('Content-Type', 'application/json;charset=UTF-8');
      
      try {
         Services__c svc = handleGet();
         resp.responseBody = Blob.valueOf(JSON.serialize(svc));       
      }
      catch (Exception e){
         resp.statusCode = 500;
         DcoRestError error = new DcoRestError(e);
         resp.responseBody = Blob.valueOf(JSON.serialize(error));       
      }
    }
    
   global static Services__c handleGet()
   {
      RestRequest req = RestContext.request;
      String id = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
      String query = buildQuery(id);
      return Database.query(query);      
    }
    
    
    private static String buildQuery(String id)
    {
       return 'select '+SERVICE_FIELD_LIST+
                ' From Services__c '+ 
                ' where Id = \''+String.escapeSingleQuotes(id)+'\'';
    }
    
}