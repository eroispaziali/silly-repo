@RestResource(urlMapping='/api/seo/service/*')
global with sharing class DcoApiServiceHtmlController 
{

   @HttpGet
   global static void httpGet()
   {
      RestResponse resp = RestContext.response;
      DcoApiUtils.setShortCache();
      resp.headers.put('Access-Control-Allow-Origin', '*');
      resp.headers.put('Content-Type', 'text/html');
      
      try {
         Services__c svc = getService();
         DcoServiceHtmlBuilder builder = new DcoServiceHtmlBuilder();
         resp.responseBody = Blob.valueOf(builder.buildHtml(svc));
      }
      catch (Exception e){
         resp.statusCode = 500;
         DcoRestError error = new DcoRestError(e);
         resp.responseBody = Blob.valueOf('<html><body><p>'+JSON.serialize(error)+'</p></body></html>');     
      }
    }
   
   global static Services__c getService()
   {
      RestRequest req = RestContext.request;
      String id = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
      String query = ' select '+DcoApiServiceController.SERVICE_FIELD_LIST+
                     ' from Services__c '+
                     ' where Display_on_public_website__c = true '+
                     ' and Service_Status__c = \'Open\' '+
                     ' and Id = \''+String.escapeSingleQuotes(id)+'\'';
      return Database.query(query);      
    }
 
}