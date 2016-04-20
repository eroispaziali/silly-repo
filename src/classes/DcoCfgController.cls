@RestResource(urlMapping='/cfg_js')
global with sharing class DcoCfgController
{
    @HttpGet 
    global static void getData ()
    {
      RestResponse resp = RestContext.response;
        
      String js = 'CSQ.constant(\'NAME_SEP\', \'_\');';
      js = js + 'CSQ.constant(\'API_ROOT\', \''+ Site.getBaseSecureUrl()+'/services/apexrest/\');';
      js = js + 'CSQ.constant(\'CODEBASE_ROOT\', \''+ Site.getBaseSecureUrl()+'/services/apexrest/\');';
      js = js + 'CSQ.constant(\'ANALYTICS\', \'UA-2332956-17\');'; 
      DcoApiUtils.setShortCache();
      resp.headers.put('Access-Control-Allow-Origin', '*');
      resp.headers.put('Content-Type', 'application/javascript');

      resp.responseBody = Blob.valueOf(js);
    }

}