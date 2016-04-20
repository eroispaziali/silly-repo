@RestResource(urlMapping='/dco_css')
global with sharing class DcoCssController
{
    @HttpGet 
    global static void getData ()
    {
        DcoResourceControllerUtils.buildResponse('dco_css', DcoApiUtils.SHORT_CACHE, False);
        RestContext.response.headers.put('Content-Type', 'text/css');
    }

}