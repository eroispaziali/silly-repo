@RestResource(urlMapping='/xdomain_shim_js')
global with sharing class DcoXDomainShimJsController
{
    @HttpGet 
    global static void getData ()
    {
        DcoResourceControllerUtils.buildResponse('dco_xdomain_shim_js', DcoApiUtils.SHORT_CACHE, true);
        
        String js = RestContext.response.responseBody.toString();
        String slave =  Site.getBaseSecureUrl()+'/services/apexrest/xdomain_proxy_html';
        js = 'DCO_XDOMAIN=\''+slave+'\';' + js;
        RestContext.response.responseBody = Blob.valueOf(js);
        
        
        RestContext.response.headers.put('Content-Type', 'application/javascript');
    }

}