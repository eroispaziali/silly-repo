@RestResource(urlMapping='/template/*')
global with sharing class DcoTemplateController
{
    @HttpGet 
    global static void getData ()
    {
        String name = DcoResourceControllerUtils.parseRequest();
        name = 'dco_'+name;
        DcoResourceControllerUtils.buildResponse(name,DcoApiUtils.SHORT_CACHE, false);
    }

}