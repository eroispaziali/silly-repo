public with sharing class DcoGeocodeUtils 
{
   public static String GOOGLE_API_KEY = 'AIzaSyDNBKAAbaCG9ZGEvReL6psQtHtcVeENFRg';
   //public static String GOOGLE_API_KEY = 'AIzaSyDrDsaOEIDKnHd4JJp7JqeX1-igP5Ch7w8';
   
   public static Integer ACCURACY_MANUAL = -1;
   public static Integer ACCURACY_FROM_PROPERTY = -2;
   public static Integer ACCURACY_ROOFTOP  = 1;
   public static Integer ACCURACY_APPROXIMATE  = 3;
   
   public static LocationData geocode(String address, String postcode)
   {
      LocationData loc = geocode(address+' '+postcode);
      if(loc.accuracy==ACCURACY_ROOFTOP && loc.postcode==postcode) return loc;
      return geocodePostcode(postcode);
  }

   public static LocationData geocode(String address)
   {
      GeocodeResponse resp = geocodeRequest(address);
      if (resp.status!='OK') return new LocationData('Geocode error::'+resp.status+':'+address);
      if (resp.results.size()>1) return new LocationData('Geocode response is ambiguous');
      return new LocationData(resp.results[0]);
   }
  
   public static void geocode(Services__c svc)
   {
      if (svc.Default_Location__r.Postcode__c!=null && svc.Default_Location__r.Geographic_location__latitude__s!=null) {
         svc.Location_Accuracy__c = ACCURACY_FROM_PROPERTY;
         svc.Location_Status__c = 'OK';
         svc.Location__latitude__s = svc.Default_Location__r.Geographic_location__latitude__s;        
         svc.Location__longitude__s = svc.Default_Location__r.Geographic_location__longitude__s;
         return;
      }
      
      String address = svc.service_street__c + ' '+svc.service_city__c ;
      DcoGeocodeUtils.LocationData loc = DcoGeocodeUtils.geocode(address, svc.service_postcode__c);

      svc.Location_Accuracy__c = loc.accuracy;
      svc.Location_Status__c = loc.status;

      if (loc.location!=null) {         
         svc.Location__latitude__s = loc.location.lat;        
         svc.Location__longitude__s = loc.location.lng;
      }        

  }
  
   public static LocationData geocodePostcode(String code)
   {
      GeocodeResponse resp = geocodeRequest(code);
      if (resp.status!='OK') return new LocationData('Geocode error::'+resp.status+':'+code);
      if (resp.results.size()>1) return new LocationData('Geocode response is ambiguous for '+code);
      GeocodeResult res = resp.results[0];
      if (!res.hasType('postal_code')||res.getPostcode().replace(' ','')!=code.replace(' ','')) 
         return new LocationData('Postcode '+code+' not found');
      return new LocationData(res);
   }
   
   public static GeocodeResponse geocodeRequest(String address)
   {
       address = EncodingUtil.urlEncode(address, 'UTF-8');
       
       Http http = new Http();
       HttpRequest req = new HttpRequest();
       req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?key='+GOOGLE_API_KEY+'&region=uk&address='+address);
       req.setMethod('GET');
       req.setTimeout(5000);
     
       HttpResponse res;
     
       if (Test.isRunningTest()) {
          res = new HttpResponse();
          res.setStatusCode(200);
          res.setBody( address == 'X' ? '{"status" : "ZERO_RESULTS" }' : '{ "results" : [ { "address_components" : [ { "long_name" : "SW18 4DU", "short_name" : "SW18 4DU", "types" : [ "postal_code" ] }, { "long_name" : "London", "short_name" : "London", "types" : [ "locality", "political" ] }, { "long_name" : "London", "short_name" : "London", "types" : [ "postal_town" ] }, { "long_name" : "Greater London", "short_name" : "Gt Lon", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "United Kingdom", "short_name" : "GB", "types" : [ "country", "political" ] } ], "formatted_address" : "London SW18 4DU, UK", "geometry" : { "bounds" : { "northeast" : { "lat" : 51.449104, "lng" : -0.1885404 }, "southwest" : { "lat" : 51.4483452, "lng" : -0.1894113 } }, "location" : { "lat" : 51.4485979, "lng" : -0.189122 }, "location_type" : "APPROXIMATE", "viewport" : { "northeast" : { "lat" : 51.45007358029149, "lng" : -0.187626869708498 }, "southwest" : { "lat" : 51.4473756197085, "lng" : -0.190324830291502 } } }, "types" : [ "postal_code" ] } ], "status" : "OK" }');
       }
       else {
	       res = http.send(req);
       }         
        
       if (res.getStatusCode()!=200) {
         throw new GeocodeException('Error from geocode request: '+res.getStatusCode()+' '+res.getStatus());
       }
   
       GeocodeResponse resp = (GeocodeResponse)JSON.deserialize(res.getBody(), GeocodeResponse.class);
       if (resp.status!='OK') return resp; 
        
       resp.results = filterResults(resp.results);
       if (resp.results.size()==0) resp.status = 'ZERO_FILTERED_RESULTS';
        
       return resp;
  }
  
   
  private static GeocodeResult[] filterResults(GeocodeResult[] res)
  {
      GeocodeResult[] res2 = new GeocodeResult[]{};
      for (GeocodeResult gr : res) {
         String c = gr.getCountryCode();
         if (c=='GB'||c=='UK'||c=='IM'||c=='GG'||c=='JE') res2.add(gr);       
      }
      return res2;
  }
  
	public class LocationData
	{
	   public integer accuracy;
	   public LatLng location;
	   public Bounds bounds;
	   public String postcode;
	   public String status; 
	   
	   public LocationData(GeocodeResult res)
	   {
	      accuracy = res.geometry.location_type == 'ROOFTOP' ? ACCURACY_ROOFTOP : ACCURACY_APPROXIMATE;
	      location = res.geometry.location;
	      bounds = res.geometry.bounds;
	      postcode = res.getPostcode();
	      status = 'OK';
	   }
	   public LocationData(String err)
	   {
	      accuracy = 0;
	      location = null;
	      bounds = null;
	      status = err;
	   }
	}  

	public class LatLng
	{
	   public Double lat;
	   public Double lng;
	   
	   public LatLng(Double lat, Double lng)
	   {
	      this.lat = lat;
	      this.lng = lng;
	   }
	}
	
	public class Bounds
	{
	   public LatLng northeast;
	   public LatLng southwest;
	}
	
	public class AddressComponent
	{
	    public String long_name;
	    public String short_name;
	    public String[] types;
	    
	    public boolean hasType(String t)
	    {
	      for (String s : types) {
	         if (s==t) return true;
	      }     
	      return false;
	    } 
	}
	
	public class Geometry
	{
	    public LatLng location;
	    public Bounds bounds; 
	    public String location_type;
	}

	public class GeocodeResult
	{
	   public AddressComponent[] address_components;
	   public Geometry geometry;
	   public String formatted_address;
	   public boolean partial_match;
	   public String[] types;
	   
	   public String getPostcode()
	   {
	      for (AddressComponent ac : address_components) {
	         if (ac.hasType('postal_code')) return ac.long_name;
	      }
	      return null;
	   }
	   
	   public String getCountryCode()
	   {
	      for (AddressComponent ac : address_components) {
	         if (ac.hasType('country')) return ac.short_name;
	      }
	      return null;
	   }
	   
	   public boolean hasType(String t)
	   {
	      for (String s : types) {
	         if (s==t) return true;
	      }     
	      return false;
	   } 
	}

	public class GeocodeResponse
	{
	   public GeocodeResult[] results;
	   public String status;
	}
	
	
	public class GeocodeException extends Exception
	{
	
	}
}