@isTest
private class DcoXDomainShimJsController_Test {

    @isTest
    private static void runTest()
    {
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        DcoXDomainShimJsController.getData();
    }
    
}