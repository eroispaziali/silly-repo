@isTest
private class DcoApiServiceController_Test {

    @isTest
    private static void runTest()
    {
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        DcoApiServiceController.httpGet();

        RestContext.request.requestURI = 'https://test.com/id';  
        DcoApiServiceController.httpGet();
    }
    
}