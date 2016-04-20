@RestResource(urlMapping='/xdomain_js')
global with sharing class DcoXDomainJsController
{
    @HttpGet 
    global static void getData ()
    {
        DcoResourceControllerUtils.buildResponse('dco_xdomain_js', DcoApiUtils.SHORT_CACHE, true);
        RestContext.response.headers.put('Content-Type', 'application/javascript');
    }

}