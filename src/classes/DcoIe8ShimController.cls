@RestResource(urlMapping='/ie8shim_js')
global with sharing class DcoIe8ShimController
{
    @HttpGet 
    global static void getData ()
    {
        DcoResourceControllerUtils.buildResponse('dco_ie8shim_js', DcoApiUtils.SHORT_CACHE, true);
        RestContext.response.headers.put('Content-Type', 'application/javascript');
    }

}