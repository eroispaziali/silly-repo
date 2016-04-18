@RestResource(urlMapping='/xdomain_proxy_html')
global with sharing class DcoXDomainProxyController 
{
    @HttpGet 
    global static void getData ()
    {
        String src = Site.getBaseSecureUrl()+'/services/apexrest/xdomain_js';
        String html =  '<!DOCTYPE HTML><script src="'+src+'" master="*"></script>';
        RestContext.response.responseBody = Blob.valueOf(html);
        RestContext.response.headers.put('Content-Type', 'text/html');
    }

}