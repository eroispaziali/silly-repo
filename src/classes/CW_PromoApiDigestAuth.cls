public class CW_PromoApiDigestAuth {

    private String username;
    private String password;
    private String certificateName;
    private String method;
    private String endpoint;
    private String uri;
    private Http http = new Http();
    private String headerKey = 'WWW-Authenticate';
    private String resHeader;
    private String authHeader;
    
    String returnString = 'Digest ';
    
    //Constructor
    //When password and username are set get the values in here from custom setting
    public CW_PromoApiDigestAuth(String reqMethod, String reqEndpoint){
    	Map<String,PromoAPIAuthSettings__c> authSettings = PromoAPIAuthSettings__c.getAll();

        username = authSettings.get('Username').Value__c;
        password = authSettings.get('Password').Value__c;
        certificateName = authSettings.get('certificateName').Value__c;
        method = reqMethod;
        endpoint = reqEndpoint; 
        uri = getUri(reqEndpoint);
    }
	
	//Method attaches digest auth header to httprequest object    
    public HttpRequest setAuthDetails(HttpRequest req){
        
        //Callout to get initial information from web service
        resHeader = getAuthRequestHeader();
        
        //creates string to be added to header for digest auth
        authHeader = createResponseHeader();
        
        //Adds cert
        req.setClientCertificateName(certificateName);
        //Adds auth header and returns request
        req.setHeader('Authorization', authHeader);  
        
        return req;
    
    }
    
    //Does initial callout then returns auth header value from response
    private String getAuthRequestHeader(){
        
        //Build callout
        HttpRequest newReq = new HttpRequest();
        newReq.setEndpoint(endpoint);
        newReq.setMethod(method);
        newReq.setClientCertificateName(certificateName);
        
        //If test generates mock data instead to allow testing of code
        if(!Test.isRunningTest()){
            HttpResponse newRes = http.send(newReq);
            return newRes.getHeader(headerKey);
        }else{
            //returns mock data for testing purposes
            return 'Digest realm="bwin.party crm service", nonce="WUjVVn4DBQA=ed3355ad728245a357bdab97e0690c3f39e13f35", algorithm=MD5, qop="auth"';
        }
        
    }
    
    private String createResponseHeader(){
        
        String nonce;
        String realm;
        String algorithm;
        String qop;
        String ncvalue='00000001';
		String retString = 'Digest ';
        
        //Header is in a standard format, gets the key pieces of information from it
        for(String s : resHeader.replace('Digest ','').split(',')){
            if(s.trim().startsWith('nonce')) nonce = s.trim().substring(7,s.trim().length()-1);
            if(s.trim().startsWith('realm')) realm = s.trim().substring(7,s.trim().length()-1);
            if(s.trim().startsWith('algorithm')) algorithm = s.trim().substring(10,s.trim().length());
            if(s.trim().startsWith('qop')) qop = s.trim().substring(5,s.trim().length()-1);
        }
        
        //Build vars for hashing
        String A1 = username+':'+realm+':'+password;
		String A2 = method+':'+uri;
        
        //Vars for response part of header
        String HA1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5',Blob.valueOf(A1)));
		String HA2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5',Blob.valueOf(A2)));
        String cnonce = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(String.valueOf(System.now()))));
        
        //Build response part of header
        String response = EncodingUtil.convertToHex(Crypto.generateDigest('MD5',Blob.valueOf(HA1+':'
                                                                            +nonce+':'
                                                                            +ncvalue+':'
                                                                            +cnonce+':'
                                                                            +'auth'+':'
                                                                            +HA2)));
        
        //Finalise header content
        retString += 'username="'+username+'",';
        retString += 'realm="'+realm+'",';
        retString += 'nonce="'+nonce+'",';
        retString += 'uri="'+uri+'",';
        retString += 'algorithm='+algorithm+',';
        retString += 'qop='+qop+',';
        retString += 'nc='+ncvalue+',';
        retString += 'response="'+response+'",';
        retString += 'cnonce="'+cnonce+'"';
        
        return retString;
    }
    
    //Gets the uri from the endpoint
    private String getUri(String ep){
        uri = ep.replace('https://', '');
        uri = uri.substring(uri.indexOf('/'), uri.length());
        return uri;
    }

}