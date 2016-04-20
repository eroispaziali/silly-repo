@RestResource(urlMapping='/api/tst/*')
global with sharing class DcoServiceTest
{
    @HttpGet 
    global static List<Services__c> getData ()
    {
      Double lat = Double.valueOf(RestContext.request.params.get('lat'));
      Double lng = Double.valueOf(RestContext.request.params.get('lng'));
      Integer radius = Integer.valueOf(RestContext.request.params.get('radius'));
      Integer pageSize = Integer.valueOf(RestContext.request.params.get('s'));
      Integer pageNumber = Integer.valueOf(RestContext.request.params.get('p'));

      String tps =  RestContext.request.params.get('tps');
      String[] types = tps==null ? new String[]{} : tps.split('~');
      
      return runSearch(lat, lng, radius, types, pageSize, pageNumber);      
    }
    
    
    //Default_Property__c,Regulatory_Body__c,
 private static String SERVICE_FIELD_LIST = 'Id,Accessibility__c,Branch_email__c,Branch_name__c,Branch_telephone__c,'+
'Contact_first_name__c,Contact_last_name__c,DA_Site__c,Days_per_week__c,Description__c,Display_on_public_website__c,'+
'Getting_There__c,Image_Doc_ID__c,Local_Authority__c,Locality__c,Location__Latitude__s,Location__Longitude__s,'+
'Name,National_Service__c,Opening_Times_Guidebook__c,Operated_By__c,Other_Target_Client_Group__c,'+
'Other_type__c,Parking__c,Postcode_Constituency__c,Postcode_Local_Authority__c,Postcode_Primary_Care_Trust__c,'+
'Postcode_Ward__c,Postcodes_Covered__c,Price__c,Primary_contact__c,Record_Type_Name__c,Refreshments__c,'+
'Registered_With_Regulator__c,Restrict_access__c,Site__c,Sub_Type__c,Toilet_Facilities__c,'+
'service_city__c,service_code__c,service_contact_hours__c,service_country__c,service_county__c,service_description__c,'+
'service_email__c,service_operationhours__c,service_operationhourscomment__c,service_postcode__c,service_status__c,'+
'service_street__c,service_targetclientgroup__c,service_telephone__c,service_type__c,service_website__c ';
    
  
  public static List<Services__c> runSearch(Double lat, Double lng, integer radius, String[] types, integer pageSize, integer pageNumber)
  {
        String type = 'Internal';
        
        String query = 'select '+SERVICE_FIELD_LIST+
                        ' From Services__c '+ 
                        ' where Display_on_public_website__c = true '+
                        ' and Service_Status__c = \'Open\' '+
                         buildTypeClause(types)+
                        ' and DISTANCE(Location__c, GEOLOCATION('+lat+','+lng+'),\'mi\') < '+radius+
                        ' ORDER BY DISTANCE(Location__c, GEOLOCATION('+lat+','+lng+'),\'mi\')'+
                        ' LIMIT '+pageSize+' OFFSET '+pageSize*pageNumber; 

        List<Services__c> searchList = Database.query(query);
        
        
        return searchList;
        
    }
    
    private static String buildTypeClause(String[] types)
    {
    	String clause = '';
    	
    	for (String s : types) {
         if (clause!='') clause += ',';
         clause += '\''+s+'\'';    		
    	}
    	
    	return clause == '' ? '' : ' and service_type__c in ('+clause+') ';
    }


}