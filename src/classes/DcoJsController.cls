@RestResource(urlMapping='/dco_js')
global with sharing class DcoJsController
{
    @HttpGet 
    global static void getData ()
    {
        DcoResourceControllerUtils.buildResponse('dco_js', DcoApiUtils.SHORT_CACHE, False);
        RestContext.response.headers.put('Content-Type', 'application/javascript');
    }

}