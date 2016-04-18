@RestResource(urlMapping='/img/*')
global with sharing class DcoImgController
{
    @HttpGet 
    global static void getData ()
    {
        String name = DcoResourceControllerUtils.parseRequest();
        name = 'dco_'+name;
        DcoResourceControllerUtils.buildResponse(name, DcoApiUtils.LONG_CACHE, false);
    }

}