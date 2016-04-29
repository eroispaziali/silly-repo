/**
* File Name   :    RESTfulCalloutPromoAPI.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 08/05/2014 Chris Yorkston Initial version
* 0.2 28/05/2014 Chris Yorkston Functionality to call Promo API to retreive Promotion ID
*
*
*/
public class RESTfulCalloutPromoAPI {

	public String httpReqMethod;
	public String httpReqHeaderHost;
	public String httpReqHeaderEndPoint;
	public String httpReqHeaderKey;
	public Boolean isMock;
	
	// contructor - supply endpointSettingsName which holds settings for the endpoint being targeted.
	public RESTfulCalloutPromoAPI(String endpointSettingsName) {
		
		isMock = (endpointSettingsName!=''&&endpointSettingsName.toLowerCase().contains('mock')) ? true : false;
		
		// get values from custom setting
		ApexCalloutListSetting__c endpointSettings = ApexCalloutListSetting__c.getInstance(endpointSettingsName);
		if (endpointSettings!=null) {
			this.httpReqHeaderEndPoint 	= endpointSettings.HttpRequest_Header_EndPoint__c;
			this.httpReqHeaderHost 		= endpointSettings.HttpRequest_Header_Host__c;
			this.httpReqHeaderKey 		= endpointSettings.HttpRequest_Header_Key__c;
			this.httpReqMethod			= endpointSettings.HttpRequest_Method__c;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not find endpoint settings with name \''+endpointSettingsName+'\' in ApexCalloutListSetting__c'));
		}
		
		system.debug(
			'endpointSettings>>> '+endpointSettings
			+'\n'+'isMock>>> '+isMock
		);
		
	}
	
	// get FreeBet Id from supplied reward library and campaign reward objects
	public String getFreebetId(
		Id campaignId, 
		CW_Reward_Library__c rewardLibrary, 
		CW_Reward_Catalogue__c rewardCat
	) {
		CW_Campaign__c camp = [select Id, Name from CW_Campaign__c where Id = :campaignId];
		String freebetId;

		String JSONString = serialiseFreeBetCreationRequestToJSON(camp, rewardLibrary, rewardCat);
		HTTPResponse res = invokeCallout(JSONString);
		FreeBetCreationResponseClass freeBetCreationResponse = deserialiseFreeBetCreationResponseJSON(res);
		
		if (freeBetCreationResponse.freebetid=='' || (freeBetCreationResponse.errorMessage!=null && freeBetCreationResponse.errorMessage!='') ) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Freebet ID was retreived: '+freeBetCreationResponse.errorMessage));
		}
		else {
			freebetId = freeBetCreationResponse.freebetid;
		}
		
		system.debug(
			'\n'+'JSONString '+JSONString
			+'\n'+'freebetId'+freebetId
		);
		
		return freebetId;
	}
	
	public HTTPResponse invokeCallout(String JSONString) {
		
		return invokeCallout(
			this.httpReqMethod, 
			this.httpReqHeaderHost, 
			this.httpReqHeaderEndPoint, 
			this.httpReqHeaderKey,
			JSONString
		);
	}
	
	public HTTPResponse invokeCallout(
		String httpReqMethod, 
		String httpReqHeaderHost, 
		String httpReqHeaderEndPoint,
		String httpReqHeaderKey,
		String JSONString
	) {
		
		HttpRequest req = new HttpRequest();
 		
		//Set HTTPRequest Method
		req.setMethod(httpReqMethod);
		
		req.setTimeout(120000);
		
		//Set the HTTPRequest body	
		if (!isMock) req.setBody(JSONString); // todo mockable.io does not allow this to be set
	
		//Set HTTPRequest header properties
		req.setHeader('Content-Type', 'application/json');
		
		//Set HTTPRequest Endpoint 	
		req.setEndpoint(httpReqHeaderEndPoint);
		if (!Test.isRunningTest()){
	        //Adds in digest auth header and certificate
	        CW_PromoApiDigestAuth auth = new CW_PromoApiDigestAuth(httpReqMethod, httpReqHeaderEndPoint);
		    req = auth.setAuthDetails(req);
		}
        
		Http http = new Http();
		HTTPResponse res;
		
		res = http.send(req);	
		return res;
	}
	
	// convert freebet creation response JSON to freebet ceration response object: FreeBetCreationResponseClass
	public FreeBetCreationResponseClass deserialiseFreeBetCreationResponseJSON(HTTPResponse res) {
		
        if (res.getStatusCode()!=200) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Response status was not: 200 - OK'));
        
        //deserialise JSON response to instance of FreeBetCreationResponseClass
        FreeBetCreationResponseClass freeBetCreationRes = (FreeBetCreationResponseClass)JSON.deSerialize(
        	res.getBody(),
        	FreeBetCreationResponseClass.class
        );
         
		return freeBetCreationRes;
	}
	
	// generate request JSON for freebet creation
	public String serialiseFreeBetCreationRequestToJSON(
		CW_Campaign__c camp, 
		CW_Reward_Library__c rewardLibrary, 
		CW_Reward_Catalogue__c rewardCat
	) {
		// todo populate request object and then create JSON string
		FreeBetCreationRequestClass freeBetCreationReq = new FreeBetCreationRequestClass();
		freeBetCreationReq.campaignName = 		camp.Name;
		freeBetCreationReq.awardAmount 			= rewardLibrary.Amount__c;
		freeBetCreationReq.timeToClaim 			= (Integer)rewardLibrary.Days_To_Claim__c;
		freeBetCreationReq.awardCurrency		= rewardLibrary.Currency__c;
		freeBetCreationReq.customerFacingName 	= rewardLibrary.Customer_Facing_Name__c;
		freeBetCreationReq.description 			= rewardLibrary.Description__c;
		freeBetCreationReq.maxValue 			= rewardLibrary.Max_Cap__c;
		freeBetCreationReq.percentageValue 		= rewardLibrary.Percentage__c;
		freeBetCreationReq.timeToUse 			= (Integer)rewardLibrary.Days_To_Use_By__c;
		String freebetTypeName 					= StringUtil.parseFreebetType(rewardCat.Reward_Type__r.Name);
		freeBetCreationReq.freeBetType			= (freebetTypeName!=null) ? freebetTypeName : ''; 				// todo requires populating (parse name reward trigger/reward type)
		
		return JSON.serialize(freeBetCreationReq);		
	}
	
	// helpful debug messages
	public void debugMessages(HTTPResponse res) {
		System.debug(res.toString());
        System.debug(res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
	}
	
	// freebet creation request object/class
	public class FreeBetCreationRequestClass {
		
		// todo will require expanding once we know the request should look like.
		public String campaignName; 		// e.g. "test campaign"
		public String customerFacingName;	// e.g. "test freebet"
		public String description;			// e.g. "test"
		public Integer timeToClaim; 		//
		public Integer timeToUse; 			//
		public Boolean optIn;				// 
    	public String awardCurrency;		// e.g. "USD" // todo variable should be called currency
    	public Double awardAmount;			// e.g. 10
    	public String freeBetType;			// e.g. "FixedValue" or "Percentage"
    	public Double percentageValue;		// e.g. 0 (% only)
    	public Double maxValue;				// e.g. 100 (% only)
    	
    	public FreeBetCreationRequestClass() {
    		this.optIn = false;
    	}
	}
	
	// freebet creation response object/class
	public class FreeBetCreationResponseClass {
		
		// todo will require expanding once we know what the response looks like.
		public String freebetid;
		public Boolean status;
		public String errorMessage;
		public String errorCode;
		
		public FreeBetCreationResponseClass() {
			this.freebetid = '';		// e.g. "12345"
			//this.status = '';			// e.g. "SUCCESS" or "FAILED"
			this.errorMessage = '';		// e.g. "Freebet creation failed"
			this.errorCode = '';
		}
	}
	
}