@isTest
private class DcoApiSearchController_Test {

    @isTest
    private static void runTest()
    {
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        DcoApiSearchController.httpGet();

        System.RestContext.request.params.put('lat', '0');
        System.RestContext.request.params.put('lng', '0');
        DcoApiSearchController.httpGet();

        System.RestContext.request.params.put('types', 'website');
        System.RestContext.request.params.put('global', 'true');
        System.RestContext.request.params.put('page', '0');
        System.RestContext.request.params.put('radius', '25');
        DcoApiSearchController.httpGet();
    }
    
}