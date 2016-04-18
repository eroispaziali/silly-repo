@isTest
private class DcoApiUtils_Test {

    @isTest
    private static void runTest()
    {
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        DcoApiUtils.setNoCache();
        DcoApiUtils.setLongCache();
        DcoApiUtils.setshortCache();
        DcoApiUtils.sendText('','');
        DcoApiUtils.sendJson(new DcoException());
        DcoApiUtils.sendError(new DcoException());
    }
    
}