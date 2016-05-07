public with sharing class CW_PromoAPIController {
	
	public CW_Campaign__c camp {get;set;}
	public CW_PromoAPIBatchClass.PromoCreationResponseClass promoCreationResponse {get;set;}
	public Boolean isRequestFullyPopulated {get;set;}
	public Boolean isMockAPI {get;set;}

	public CW_PromoAPIController(ApexPages.StandardController stdController) {
		
		Id campaignId = stdController.getId();
		isRequestFullyPopulated = false;
		if (campaignId!=null) { 
			this.camp = [select Id, Name from CW_Campaign__c where Id = :campaignId];
			if (this.camp==null) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No associated campaign could be found with the provided campaign Id'));
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No associated campaign Id has been provided in the URL'));
			this.camp = new CW_Campaign__c();
		}
		
		String mockParam = ApexPages.currentPage().getParameters().get('mock');
		isMockAPI = (mockParam!=null&&mockParam=='true') ? true : false;
	}

	public void callPromotionCreation() {
		String apiSettingName = (isMockAPI) ? ConstantUtil.APEX_CALLOUT_PROMO_API_PROMOTION_CREATION_QA : ConstantUtil.APEX_CALLOUT_PROMO_API_PROMOTION_CREATION_QA;
		CW_PromoAPIBatchClass promoAPI = new CW_PromoAPIBatchClass(apiSettingName);
		promoAPI.updatePromoID();
		promoCreationResponse = promoAPI.promoCreationResponse;
		
		system.debug(
			'this.camp>>> '+this.camp
			+'\n'+'promoCreationResponse>>> '+promoCreationResponse
		);
	}
	
	 
}