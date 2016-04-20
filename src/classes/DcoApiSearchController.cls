@RestResource(urlMapping='/api/search')
global with sharing class DcoApiSearchController 
{
    private static Integer MAX_DISTANCE = 50;
    private static Integer OPTIMAL_RESULTS = 20;
    private static Integer MAX_PAGE_SIZE = 60;
    
   @HttpGet 
   global static void httpGet()
   {
      RestResponse resp = RestContext.response;
      DcoApiUtils.setShortCache();
      resp.headers.put('Access-Control-Allow-Origin', '*');
      resp.headers.put('Content-Type', 'application/json;charset=UTF-8');
      
      try {
         PageHolder holder = handleGet();
         resp.responseBody = Blob.valueOf(JSON.serialize(holder));       
      }
      catch (Exception e){
         resp.statusCode = 500;
        DcoRestError error = new DcoRestError(e);
         resp.responseBody = Blob.valueOf(JSON.serialize(error));       
      }
    }
    
   global static PageHolder handleGet()
   {
      String xp = RestContext.request.params.get('lat');
      Double lat = Double.valueOf(xp);
      
      xp = RestContext.request.params.get('lng');
      Double lng = Double.valueOf(xp);
      
      xp = RestContext.request.params.get('radius');
      Integer radius = xp==null ? 0 : Integer.valueOf(xp);
      radius = Math.min(radius, MAX_DISTANCE);
      
      xp = RestContext.request.params.get('global');
      Boolean includeExternal = xp == 'true' ;
      
      xp = RestContext.request.params.get('homePage');
      Boolean homePage = xp == 'false' ;
      
      xp = RestContext.request.params.get('size');
      Integer pageSize = xp==null ? 5 : Integer.valueOf(xp);
      pageSize = Math.min(pageSize, MAX_PAGE_SIZE);
      
      xp = RestContext.request.params.get('page');
      Integer pageNumber = xp==null ? 0 : Integer.valueOf(xp);
      
      String tps = RestContext.request.params.get('types');
      String[] types = tps==null ? new String[]{} : tps.split('~');
      
      return runSearch(lat, lng, radius, includeExternal, types, pageSize, pageNumber, homePage);      
    }
    
  public static PageHolder runSearch(Double lat, Double lng, integer radius, Boolean includeExternal, String[] types, integer pageSize, integer pageNumber, Boolean homePage)
  {
      PageHolder holder = new PageHolder();
        
      RadiusTotal rt = optimiseRadius(lat, lng, radius, includeExternal, types);

      String query = buildPageQuery(lat, lng, rt.radius, includeExternal, types, pageSize, pageNumber); 
             
      List<Services__c> content = Database.query(query);     
      List<Services__c> previous = new List<Services__c>();
      
      // Get the previous page results if the current page returns no values
      if (pageNumber > 0 && content.Size() == 0)
      {
        query = buildPageQuery(lat, lng, rt.radius, includeExternal, types, pageSize, pageNumber - 1); 
        previous = Database.query(query);
      }
                
      // Include national services if the results return less than 4 rows, but only if its the first page
      // Include the remaining national services if the page size restricts the results.
      if ((content.Size() < 4 && pageNumber == 0) || (pageNumber > 0 && content.Size() == 0))
      {        
      
         // skip some of the national services if the page number isn't 1
         integer skip = 0;       
         if (pageNumber > 0 && content.Size() == 0)
         {          
            skip = pageSize - previous.Size();
         }
         
         List<Services__c> national = Database.query(buildNational(homePage));
         rt.total = rt.total + national.Size();
         
         for(Services__c s : national)
         {      
            if (skip > 0) 
            {
                skip = skip - 1;
                continue;
            }
            
            if(content.Size() == pageSize) 
            {
                break;
            }
            
            s.Location__Latitude__s = 51.5060;   
            s.Location__Longitude__s = -0.07143339999993259; 
            s.National_Service__c = true;
            content.add(s);
         }
      }
        
      holder.pageSize = pageSize;
      holder.pageNumber = pageNumber;
      holder.totalElements = rt.total;
      holder.content = content;
      holder.origin = new DcoGeocodeUtils.LatLng(lat, lng);
      holder.distance = rt.radius;
      
      return holder;
    }
    
    private static string buildNational(Boolean homePage)
    {
        string homeWebpage = homePage ? 'Don\'t Show Website' : 'Alzheimer\'s Society Website';
        return 'select '+ DcoApiServiceController.SERVICE_FIELD_LIST +
               ' From Services__c '+ 
               ' where (Name = \'' + String.escapeSingleQuotes('Talking Point') + '\'' +
               ' or Name = \'' + String.escapeSingleQuotes(homeWebpage) + '\'' +
               ' or Name = \'' + String.escapeSingleQuotes('Alzheimer’s Society National Dementia Helpline') + '\')' +
               ' and Record_Type_Name__c = \'Internal\' and National_Service__c = true';    
    }
    
    private static String buildCoreQuery(String selectList, Double lat, Double lng, integer radius, Boolean includeExternal, String[] types)
    {
       return 'select '+selectList+
                ' From Services__c '+ 
                ' where Display_on_public_website__c = true '+
                ' and Service_Status__c = \'Open\' '+
                 buildServiceTypeClause(types)+
                 buildRecordTypeClause(includeExternal)+
                ' and DISTANCE(Location__c, GEOLOCATION('+Decimal.valueOf(lat)+','+Decimal.valueOf(lng)+'),\'mi\') < '+radius;
    }

    private static String buildCountQuery(Double lat, Double lng, integer radius, Boolean includeExternal, String[] types)
    {
       return buildCoreQuery('count()', lat, lng, radius, includeExternal, types);
    } 

    private static String buildPageQuery(Double lat, Double lng, integer radius, Boolean includeExternal, String[] types, integer pageSize, integer pageNumber)
    {
       return buildCoreQuery(DcoApiServiceController.SERVICE_FIELD_LIST, lat, lng, radius, includeExternal, types)+
                        ' ORDER BY DISTANCE(Location__c, GEOLOCATION('+Decimal.valueOf(lat)+','+Decimal.valueOf(lng)+'),\'mi\'), Service_Web_Name__c'+
                        ' LIMIT '+pageSize+' OFFSET '+pageSize*pageNumber; 
    }

    private static String buildRecordTypeClause(Boolean includeExternal)
    {
      return  includeExternal ? '' : ' and Record_Type_Name__c = \'Internal\' ';
    }

    private static String buildServiceTypeClause(String[] types)
    {
      String clause = '';
      
      for (String s : types) {
         if (clause!='') clause += ',';
         clause += '\''+String.escapeSingleQuotes(s)+'\'';        
      }
      
      return clause == '' ? '' : ' and service_type__c in ('+clause+') ';
    }

   private static Integer getCount(Double lat, Double lng, integer radius, Boolean includeExternal, String[] types)
   {
    String query = buildCountQuery(lat, lng, radius, includeExternal, types);
      return Database.countQuery(query);
   }

   private static RadiusTotal optimiseRadius(Double lat, Double lng, integer radius, Boolean includeExternal, String[] types)
   {
    RadiusTotal rt = new RadiusTotal();
    
    if (radius!=0) {
         rt.radius = radius;
         rt.total = getCount(lat, lng, radius, includeExternal, types);
        return rt; 
    }
    
    for (Integer n : new Integer[]{ 5, 10, 15, 20, 25, 30, 40 }) { 
         rt.radius = n;
         rt.total = getCount(lat, lng, rt.radius, includeExternal, types);
         if (rt.total>=OPTIMAL_RESULTS) break;                  
        }
    
    return rt;
   }

   global class PageHolder extends DcoPageHolder
   {
      Integer distance;
      DcoGeocodeUtils.LatLng origin; 
    }

   private class RadiusTotal
   {
    Integer radius;
    Integer total;
   }


}