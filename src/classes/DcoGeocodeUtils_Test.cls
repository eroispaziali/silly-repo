@isTest
private class DcoGeocodeUtils_Test {

   static {
      DcoGeocodeUtils x =new DcoGeocodeUtils();
   }

    @isTest
    private static void runTest()
    {
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        DcoGeocodeUtils.geocodePostcode('Y');
        DcoGeocodeUtils.geocode('Y');
        DcoGeocodeUtils.GeocodeResponse res =DcoGeocodeUtils.geocodeRequest('Y'); 
        res.results[0].getPostcode();
        res.results[0].getCountryCode();
        res.results[0].hasType('');
    }
    
}