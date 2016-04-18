@isTest
private class DcoIe8ShimController_Test {

    @isTest
    private static void runTest()
    {
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        DcoIe8ShimController.getData();
    }
    
}