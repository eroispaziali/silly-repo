public abstract with sharing class DcoResourceControllerUtils
{
    
    public static void serveResource()
    {
        buildResponse(parseRequest());
    }

    public static String parseRequest ()
    {
  		RestRequest req = RestContext.request;
        RestResponse resp = RestContext.response;
        String[] a = req.requestURI.split('/');
        String name = a[a.size()-1];
		return name;        
    }

    public static void buildResponse (String name)
    {
        buildResponse(name, DcoApiUtils.NO_CACHE, false);      
    }

    public static void buildResponse (String name, String cache, boolean gzip)
    {
  		RestRequest req = RestContext.request;
      RestResponse resp = RestContext.response;
        
      StaticResource res = null;
        
      String accept = req.headers.get('Accept-Encoding');
      if (gzip && accept != null && accept.indexOf('gzip')>=0) {
          res = getGzipResource(name);
          if (res!=null) resp.headers.put('Content-Encoding', 'gzip');
      }
        
		if (res==null) res = getResource(name);

      if (res==null) {
		 resp.statusCode = 404;
		 resp.responseBody = Blob.valueOf('StaticResource '+name+ ' was not found');
       return;
      }

      DcoApiUtils.setCache(cache); 
      resp.headers.put('Content-Type', res.ContentType);
      resp.headers.put('Access-Control-Allow-Origin', '*');
      resp.responseBody = res.Body;      
    }

    public static StaticResource getResource(String name)
    {
        List<StaticResource> reslist = [select Body, ContentType from StaticResource where Name = :name];
        if (reslist.isEmpty()) return null;
        return reslist[0];
    }

    public static StaticResource getGzipResource(String name)
    {
        name = name + '_gz';
        return getResource(name);
    }
}