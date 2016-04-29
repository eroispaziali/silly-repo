/**
* File Name   :    CW_PromoAPIBatchClass.cls
* Description :    Batch Class that returns the promoId
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 17/10/2014 Cristina P.	Initial version
*
*
*/
public with sharing class CW_PromoAPIBatchClass {

    map<Id,CW_Audience_Group_Schedule__c> agsMap;
    map<Id,list<CW_Audience_Group_Member_Reward__c>> agmrByAGSIdMap;
    public String httpReqMethod;
	public String httpReqHeaderEndPoint;
	public Boolean isMock;
	public PromoCreationResponseClass promoCreationResponse;
	
	// contructor - supply endpointSettingsName which holds settings for the endpoint being targeted.
	public CW_PromoAPIBatchClass(String endpointSettingsName) {
		
		isMock = (endpointSettingsName!=''&&endpointSettingsName.toLowerCase().contains('mock')) ? true : false;
		
		// get values from custom setting
		ApexCalloutListSetting__c endpointSettings = ApexCalloutListSetting__c.getInstance(endpointSettingsName);
		if (endpointSettings!=null) {
			this.httpReqHeaderEndPoint 	= endpointSettings.HttpRequest_Header_EndPoint__c;
			this.httpReqMethod			= endpointSettings.HttpRequest_Method__c;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not find endpoint settings with name \''+endpointSettingsName+'\' in ApexCalloutListSetting__c'));
		}
		
		system.debug(
			'endpointSettings>>> '+endpointSettings
			+'\n'+'isMock>>> '+isMock
		);
		
	}
	
    public void updatePromoID(){
    	Date selectedDate = System.today().addDays(1);
    	list<CW_Audience_Group_Schedule_Reward__c> agsrToUpdate = new list<CW_Audience_Group_Schedule_Reward__c>();
    	for (CW_Audience_Group_Schedule_Reward__c agsr : [SELECT id,Audience_Group_Schedule__c, PromoId__c,Campaign_Reward__r.Campaign_Offer__r.Campaign__r.Id,Audience_Group_Schedule__r.Id 
    													  FROM CW_Audience_Group_Schedule_Reward__c 
    													  WHERE Campaign_Reward__r.Campaign_Offer__r.Campaign__r.Campaign_Start_Date__c =:selectedDate
    													  AND Campaign_Reward__r.Campaign_Offer__r.Campaign__r.Cost_Approval_Status__c =: ConstantUtil.APPROVAL_PROCESS_APPROVED
    													  AND PromoId__c =: ''])
    	{
    		agsr.PromoId__c = getPromotion(agsr.Campaign_Reward__r.Campaign_Offer__r.Campaign__r).get(agsr.Audience_Group_Schedule__r.Id);
    		agsrToUpdate.add(agsr);
    	}

    	if (agsrToUpdate.size()>0)
    		update agsrToUpdate;
    }
    
    //Get all schedules with start date of today + modifier
    public map<Id,CW_Audience_Group_Schedule__c> getAudienceGroupSchedules(CW_Campaign__c camp){
        
        Date startDate = system.today().addDays(1);
        
        agsMap = new map<Id,CW_Audience_Group_Schedule__c>();
        
        list<CW_Audience_Group_Schedule__c> ags = [select Id, CreatedById, Start_Date_search__c, End_Date_search__c,
        												  Audience_Group__r.Unica_Id__c,Audience_Group__r.Campaign__r.Name,
        												  Schedule__r.Start_Date__c, Schedule__r.End_Date__c
                                                   from CW_Audience_Group_Schedule__c 
                                                   where Start_Date_search__c <= :startDate
                                                   and Audience_Group__r.Campaign__c = :camp.Id];
        
        agsMap.putAll(ags);
        return agsMap;
    }
    
    //Get Audience Group Schedule Reward records
    public map<Id,list<CW_Audience_Group_Member_Reward__c>> getAudienceGroupMemberRewards(){
        
        agmrByAGSIdMap = new map<Id,list<CW_Audience_Group_Member_Reward__c>>();
        
        List<CW_Audience_Group_Member_Reward__c> agmrs = [select Id, Audience_Group_Schedule_Reward__r.Audience_Group_Schedule__c, 
                                                         			Audience_Group_Schedule_Reward__r.Campaign_Reward__r.Amount__c, 
                                                         			Audience_Group_Schedule_Reward__r.Campaign_Reward__r.Currency__c, 
                                                         			Audience_Group_Schedule_Reward__r.Campaign_reward__r.Bonus_Id__c,
                                                         			Audience_Group_Member__r.Contact__r.Account.Name
                                                         from CW_Audience_Group_Member_Reward__c 
                                                         where Audience_Group_Schedule_Reward__r.Audience_Group_Schedule__c  IN :agsMap.keySet()];
                                                         //and Audience_Group_Schedule_Reward__r.Campaign_Reward__r.Bonus_Id__c != ''
        
        for(CW_Audience_Group_Member_Reward__c agmr : agmrs){
            if(!agmrByAGSIdMap.containsKey(agmr.Audience_Group_Schedule_Reward__r.Audience_Group_Schedule__c)) agmrByAGSIdMap.put(agmr.Audience_Group_Schedule_Reward__r.Audience_Group_Schedule__c, new List<CW_Audience_Group_Member_Reward__c>());
            agmrByAGSIdMap.get(agmr.Audience_Group_Schedule_Reward__r.Audience_Group_Schedule__c).add(agmr);
        }
        return agmrByAGSIdMap;
    }

    // get promotion object from supplied campaign
	public Map<Id,String> getPromotion(CW_Campaign__c camp) 
	{
		Map<Id,String> agsPromoIdMap = new Map<Id,String>();
		getAudienceGroupSchedules(camp);
		getAudienceGroupMemberRewards(); 
		
		promoCreationResponse = new PromoCreationResponseClass();
		String JSONString = serialisePromoCreationRequestToJSON(camp);
		HTTPResponse res = invokeCallout(JSONString);
		promoCreationResponse = deserialisePromotionCreationResponseJSON(res);

		for (PromoCreationResponsePromotionsClass curr: promoCreationResponse.promoResponseList)
		{
			agsPromoIdMap.put(Id.valueOf(curr.internalId), String.valueOf(curr.PromoId));
		}
		return agsPromoIdMap;
	}
	
	public HTTPResponse invokeCallout(String JSONString) {
		
		return invokeCallout(
			this.httpReqMethod, 
			this.httpReqHeaderEndPoint, 
			JSONString
		);
	}
	
	public HTTPResponse invokeCallout(
		String httpReqMethod, 
		String httpReqHeaderEndPoint,
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
		
		//Execute web service call here		
		res = http.send(req);	
		return res;
	}
    
    // convert promotion creation response JSON to promotion creation response response object: FreeBetCreationResponseClass
	public PromoCreationResponseClass deserialisePromotionCreationResponseJSON(HTTPResponse res) {
		
		if (res.getStatusCode()!=200) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Response status was not: 200 - OK'));
		//deserialise JSON response to instance of PromoCreationResponseClass
		PromoCreationResponseClass promoCreationRes = (PromoCreationResponseClass)JSON.deSerialize(
        	res.getBody(),
        	PromoCreationResponseClass.class
        );
		return promoCreationRes;
	}
	
	// generate request JSON for promotion creation
	public String serialisePromoCreationRequestToJSON(CW_Campaign__c camp) {
		
		String unicaId;
		PromoCreationRequestClass promoCreationRequest = new PromoCreationRequestClass();
		List<PromoCreationRequestPromotionClass> promotions = new List<PromoCreationRequestPromotionClass>();
		
		List<CW_Audience_Group_Schedule__c> agsList = agsMap.Values();
		List<CW_Audience_Group_Schedule_Reward__c> agsrList = [ select Id, Name, Campaign_Reward__r.Reward_Type__r.Name,
																	Campaign_Reward__r.Reward_Library__r.FreeBet_Id__c
																from CW_Audience_Group_Schedule_Reward__c
																where Audience_Group_Schedule__c IN : agsMap.keySet()];
		if (agsList==null || agsList.isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Campaign does not have any associated CW_Audience_Group_Schedule__c records'));
			return null;
		}
		if (agsrList==null || agsrList.isEmpty()) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Campaign does not have any assoicated CW_Audience_Group_Schedule_Reward__c records'));
				return null;
			}
		
		// each ags will be mapped to a Promotion object
		for (CW_Audience_Group_Schedule__c ags :agsList) {
			unicaId = ags.Audience_Group__r.Unica_Id__c;
			PromoCreationRequestPromotionClass promotion = new PromoCreationRequestPromotionClass();
			List<PromoCreationRequestPlayerAwardClass> playerAwards = new List<PromoCreationRequestPlayerAwardClass>();
			
			// each ags has 1 or more agsr; each ags will be mapped to a PlayerReward object
			for (CW_Audience_Group_Schedule_Reward__c agsr :agsrList) {
				PromoCreationRequestPlayerAwardClass playerAward = new PromoCreationRequestPlayerAwardClass();
				List<PromoCreationRequestPlayerClass> players = new List<PromoCreationRequestPlayerClass>();
				
				// if we have a unicaId, there is no need to provide a list of players
				if (agsr.Campaign_Reward__r.Reward_Type__r.Name == ConstantUtil.REWARD_LIBRARY_PERCENTAGE_TYPE) {
					if (unicaId==null||unicaId=='')
					{
						//available for percentage
						List<CW_Audience_Group_Member_Reward__c> agmrList = agmrByAGSIdMap.get(ags.Id);
						// each agsr has 1 or more agmr
						for (CW_Audience_Group_Member_Reward__c agmr :agmrList) {
							// populate Player bean
							PromoCreationRequestPlayerClass player = new PromoCreationRequestPlayerClass();
							player.accountName = agmr.Audience_Group_Member__r.Contact__r.Account_Name__c;
	                    	player.awardValue = Integer.valueOf(agmr.Audience_Group_Schedule_Reward__r.Campaign_Reward__r.Amount__c);
	                    	player.awardCurrency = agmr.Audience_Group_Schedule_Reward__r.Campaign_Reward__r.Currency__c;
							players.add(player);
						}
					}
					else{
						system.debug('Error: Freebet Precentage cannot have unicaId');
					}
				} else if(agsr.Campaign_Reward__r.Reward_Type__r.Name == ConstantUtil.REWARD_LIBRARY_AMOUNT_TYPE){
					//available for amount
					players = new List<PromoCreationRequestPlayerClass>();
					PromoCreationRequestPlayerClass player = new PromoCreationRequestPlayerClass();
					player.accountName = 'Test';//ags.Audience_Group_Member__r.Contact__r.Account.Name;
                	player.awardValue = 0;
                	player.awardCurrency = 'USD';
					players.add(player);
				}
				
				// error if playersList and unicaId are null
				/*if ( (unicaId==null||unicaId=='') && (players==null||players.isEmpty()) ) {
					ApexPages.addMessage(
						new ApexPages.Message(
							ApexPages.Severity.ERROR, 
							'CW_Audience_Group__c record ('+ags.Audience_Group__c+') does not have a UnicaId'
							+'<br/>'+'AND' 
							+'<br/>'+'no members (CW_Audience_Group_Member_Reward__c records) exist where Audience_Group_Schedule_Reward__c = '+agsr.Id 
							+'<br/><br/>'+'The Promo API call requires a UnicaId or list of players.'
						)
					);
					return null;
				}*/
				
				// populate PlayerAward bean
				
				// List of players to support account name list targeting in PAT, 
				// When Unica Id is provided, player list would be null. Unica Id represents the list of players targeted for this Promotion
				playerAward.playerList = (unicaId!=null&&unicaId!='') ? null : players;
				playerAward.freeBetId = agsr.Campaign_Reward__r.Reward_Library__r.FreeBet_Id__c; // todo AGSReward.CamapignReward.RewardId 
				
				playerAwards.add(playerAward);
			}
			
			// populate PromoBrandProduct bean
			List<PromoCreationRequestBrandProductClass> promoBrandProducts = new List<PromoCreationRequestBrandProductClass>();
			Set<PromoCreationRequestBrandProductClass> promoBrandProductSet = new Set<PromoCreationRequestBrandProductClass>();
			Set<String> blpSet = new Set<String>();
			List<CW_Campaign_Sites__c> campSites = [
				select Id, 
				Site_Catalogue__r.Label__r.Code__c, Site_Catalogue__r.Label__r.Brand__r.Name, Site_Catalogue__r.Product__r.Name 
				from CW_Campaign_Sites__c 
				where Campaign__c = :camp.Id
			];
			
			for (CW_Campaign_Sites__c cs :campSites) {
				
				if (!blpSet.contains(cs.Site_Catalogue__r.Label__r.Code__c.toUpperCase())){
					blpSet.add(cs.Site_Catalogue__r.Label__r.Code__c.toUpperCase());
					PromoCreationRequestBrandProductClass promoBrandProduct = new PromoCreationRequestBrandProductClass();
					promoBrandProduct.frontEnd = cs.Site_Catalogue__r.Label__r.Code__c.toUpperCase();
					promoBrandProduct.brand = cs.Site_Catalogue__r.Label__r.Brand__r.Name.toUpperCase();
					promoBrandProduct.product = cs.Site_Catalogue__r.Product__r.Name.toUpperCase();
					promoBrandProductSet.add(promoBrandProduct);
				}
			}
			
			promoBrandProducts.addAll(promoBrandProductSet);
			
			// populate Promotion bean
			promotion.internalId 			= ags.Id;
			promotion.promotionName 		= 'Test ' + ags.Audience_Group__r.Campaign__r.Name;
			promotion.promoStartDate 		= null;
			promotion.promoEndDate 			= null;
			promotion.promoBrandProduct		= promoBrandProducts;
			promotion.playerAwardList		= playerAwards; // This holds information about the players list and free bet IDs to be awarded.
			promotion.promoCurrency			= 'GBP'; // todo USD,GBP, etc.,
			String awardDesc 				= (UnicaId!=null&&UnicaId!='') ? 'Unica targeted' : 'Player List targeted';
			promotion.awardDescription 		= ags.Audience_Group__r.Campaign__r.Name+':'+awardDesc; // todo
			promotion.unicaId 				= unicaId;
			
			promotions.add(promotion);
		}
		
		promoCreationRequest.campaignId = camp.Id;
		promoCreationRequest.promotionList = promotions;
		
		return JSON.serialize(promoCreationRequest);
	}
	
	// promo creation request object/class
	public class PromoCreationRequestClass {
		public String campaignId; // Id of the campaign for logging purposes
		public List<PromoCreationRequestPromotionClass> promotionList; // List of promotion objects
	}
	
	// Promotion bean
	public class PromoCreationRequestPromotionClass {
		
		public PromoCreationRequestPromotionClass() {
			this.promoTypeCode 		= 'OPERATIONAL_TOOL';
			List<Integer> intList = new List<Integer>();
			intList.add(1);
			this.playerStatusList	= intList; // Real, play, pseudo players (1,0,2)
			this.creationComments 	= Userinfo.getUserEmail() ;
			this.createdBy 			= Userinfo.getName();
			this.promoTimeZone 		= 'GMT'; // ET,CET,GMT etc.
			this.awardType 			= 'FREEBET'; // FREEBET
		}
		
		public String internalId; 		// Unique ID for each of the promotion Objects received from caller
		public String promotionName; 	// Descriptive name of the promotion
		public String promoTypeCode; 	// Type of the Promotion. As of now only Operation tool is supported - Ext_Operational_tool
		public String promoStartDate; 	// todo linux date time stamp, Promo Start Date as Long integer. This should always a future Date.
		public String promoEndDate;		// Promo End Date as Long integer. This is not required for Operational Tool Promo. 
		public List<Integer> playerStatusList; // Real, play, pseudo players (1,0,2)
		public String creationComments;	// Comments to be added during creation of Promotion
		public String createdBy;
		public List<PromoCreationRequestBrandProductClass> promoBrandProduct; // List objects which contains fe, brand product combination. pp-party-poker
		public List<PromoCreationRequestPlayerAwardClass> playerAwardList; // This holds information about the players list and free bet IDs to be awarded.
		
		public String promoTimeZone; // ET,CET,GMT etc.,
		public String promoCurrency; // USD,GBP, etc.,
		public String awardType; // FREEBET
		public String awardDescription;
		public String unicaId; // UNICA ID to target a specific set of players
	}
	
	// PromoBrandProduct bean
	public class PromoCreationRequestBrandProductClass {
		public String frontEnd; // e.g. pp
		public String brand; 	// e.g. Party
		public String product; 	// e.g. Poker
	}
	
	// PlayerAward bean
	public class PromoCreationRequestPlayerAwardClass {
		public String freeBetId; // todo possibly Integer
		public List<PromoCreationRequestPlayerClass> playerList; // List of players to support account name list targeting in PAT
	}
	
	// Player bean
	public class PromoCreationRequestPlayerClass {
		public String accountName;
		public Integer awardValue; 		// To specify the value on which to calculate % for % freebet
		public String awardCurrency; 	// Currency of the value above, todo change spelling of reserved work currency.
	}
	
	// promo creation response object/class
	public class PromoCreationResponseClass {
		public String campaignId; // ID received from the caller
		public Boolean campaignStatus; // Status would be failed if any of the promotion beans in the request fail during creation
		public String responseMessage; // Possible high level description of the errors during creation
		public List<PromoCreationResponsePromotionsClass> promoResponseList; // todo check spelling, List of responses for all the promotion objects passed in the request
	}
	
	// promoResponse bean
	public class PromoCreationResponsePromotionsClass {
		public String internalId; 	// ID received from the caller. This is unique per promotion object
		public Boolean promoStatus; // Status would be failed if any of the promotion beans in the request fail during creation
		public Integer promoId; 	// Promo ID of the created promotion in case the status is SUCCESS. If FAILED it will be 0
		public String errorCode; 	// We will publish the possible list of error codes beforehand. Will be populated only for FAILED status.
		public String errorMessage; // Error returned from the promotions application during promo creation. Will be populated only for FAILED status.
	}
    
}