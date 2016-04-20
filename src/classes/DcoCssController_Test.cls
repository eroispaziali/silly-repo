@isTest
private class DcoCssController_Test {

    @isTest
    private static void runTest()
    {
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.headers.put('Accept-Encoding', 'gzip');
        DcoCssController.getData();
    }
    
}