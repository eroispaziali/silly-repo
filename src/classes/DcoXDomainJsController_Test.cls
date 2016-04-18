@isTest
private class DcoXDomainJsController_Test {

    @isTest
    private static void runTest()
    {
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        RestContext.request.requestURI = 'https://test.com/name';  
        DcoXDomainJsController.getData();
    }
    
}