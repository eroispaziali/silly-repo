/**
* File Name   :    CW_WizardRewardUtil .cls
* Description :    Select rewards and triggers
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 30/04/2014 Cristina P.    Initial
* 0.3 20/07/2014 Cristina P.	B-122940 Campaign Reward - Many Rewards per Trigger
*
*/

//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing" 
//so the user can create related records while cost/brief is in approval
public without sharing class CW_WizardRewardUtil 
{   
    public Id       					campaignId;
    public Id							offerId {get; set;}
    public Id      	 					offerTypeId {get; set;}
    public Id       					rewardTypeId {get; set;}
    public String   					fieldsetName {get;set;} 
    public Boolean  					hasLibrary  {get; set;}
    
    public Boolean						hasReward {get; set;}
    public Boolean						editMode {get;set;}

    public List<CW_Campaign_Offer__c> 	campOffers {get;set;}
    public CW_Campaign_Reward__c    	campReward {get; set;}
    public CW_Reward_Library__c     	rewardLibrary {get; set;}
    public CW_Reward_Catalogue__c   	rewardCat {get; set;}
    public CW_Task__c               	task {get; set;}
    public CW_Campaign_Offer__c			campOffer {get;set;}
    public CW_Campaign__c				camp {get;set;}
    
    public CW_WizardRewardUtil(ApexPages.standardController stdCtrl)
	{
		campaignId = stdCtrl.getId();
		hasReward = true;
        if (campaignId!=null) 
        {
        	camp = getCampaignInfo();
        	campOffer = new CW_Campaign_Offer__c(Campaign__c = campaignId);
        	campOffers = getCampOffers(campaignId);
        }
	}
    
    public CW_WizardRewardUtil()
    {
        campaignId = Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_ID);
        hasReward = true;
        if (campaignId!=null) 
        {
        	camp = getCampaignInfo();
        	campOffer = new CW_Campaign_Offer__c(Campaign__c = campaignId);
        	campOffers = getCampOffers(campaignId);
        }
    }
    
    // get offer type options
    public List<selectOption> getOfferTypeOptions()
    {
        List<selectOption> options = new List<selectOption>{new selectOption('','')};
        
        for(CW_Offer_Type__c curr : [SELECT Id, Name FROM CW_Offer_Type__c])
        {
            options.add(new selectOption(curr.Id,curr.Name));
        }
        return options;
    }
    
    //get campaign offer fields from fieldset depending on selected offer type
    public List<Schema.FieldSetMember> getCampOfferFields()
    {
    	if (offerTypeId!=null)
    	{
	        getFieldsetName(offerTypeId);
	        Map<String,Schema.FieldSet> fieldSets = SObjectType.CW_Campaign_Offer__c.FieldSets.getMap();

	        if(fieldSets.containsKey(fieldsetName))
	            return SObjectType.CW_Campaign_Offer__c.FieldSets.getMap().get(fieldSetName).getFields();
	        else
	           return SObjectType.CW_Campaign_Offer__c.FieldSets.Default_Fields.getFields();
    	}
	    else return SObjectType.CW_Campaign_Offer__c.FieldSets.Default_Fields.getFields();
    }
    
    //return fieldset name based on trigger type and reward type
    public String getFieldsetName(Id offerTypeId)
    {
    	hasReward = campOfferHasReward(offerTypeId);
       	CW_Offer_Type__c offerType = new CW_Offer_Type__c();
        offerType   = [SELECT Id, Name
                       FROM CW_Offer_Type__c 
                       WHERE Id =: offerTypeId];
                        
        fieldSetName = offerType.Name + ConstantUtil.CAMPAIGN_OFFER_FS_SUFFIX;
        fieldSetName = fieldSetName.replaceAll( '\\s+', '');

        return fieldSetName;
    }
    
    //get campaign information in order to display the main fieldset on the reward page
    public CW_Campaign__c getCampaignInfo() {
        String queryString = 'SELECT ';
        for (Schema.SObjectField f : Schema.SObjectType.CW_Campaign__c.fields.getMap().values())
        {
            queryString += f.getDescribe().getName() + ', ';
        }
        queryString = queryString.removeEnd(', ');
        queryString += ', Owner.Name FROM CW_Campaign__c WHERE Id =\'' + campaignId + '\'';
        return Database.query(queryString);
    }
    
    //get available offers for selected campaign
    public List<CW_Campaign_Offer__c> getCampOffers(Id campaignId)
    {
    	campOffers = new List<CW_Campaign_Offer__c>();
    	
    	for (CW_Campaign_Offer__c curr: [SELECT Name, Offer_Type__c, Campaign__c, Composite_Key__c, Offer_Code__c, Offer_Id__c 
    									 FROM CW_Campaign_Offer__c WHERE Campaign__c=: campaignId])
    	{
    		campOffers.add(curr);
    	}
    	return campOffers;
    }
    
    //add new offer functionality
    public void addOffer()
    {
    	try 
        {
        	if (campaignId!=null && offerTypeId!=null)
        	{
	        	campOffer = new CW_Campaign_Offer__c();
	    		campOffer.Campaign__c = campaignId;
	    		campOffer.Offer_Type__c = offerTypeId;
	    		insert campOffer;
	    		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,ConstantUtil.CAMP_OFFER_SAVED_SUCCESSFULL));
				getCampOffers(campaignId);
				offerTypeId = null;
        	}	
			else
				Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ConstantUtil.CAMP_OFFER_SAVE_ERROR));
        }
        catch(exception e) {
            ApexPages.addMessages(e);
        }
    }   
    
    //update campaign offer
   	public void saveChangesCampOffer()
   	{
   		try 
        {
   			update campOffers;
   			editMode=false;
        }catch(exception e) {
            ApexPages.addMessages(e);
        }
   	} 
    
    //delete selected offer
    public void deleteCampOffer()
    {
    	try 
        {
        	delete [SELECT Id,Name FROM CW_Campaign_Offer__c WHERE Id=: offerId];
        	Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,ConstantUtil.CAMP_OFFER_DELETED_SUCCESSFULL));
			getCampOffers(campaignId);
        }
         catch(exception e) {
            ApexPages.addMessages(e);
        }
    }
    
    //check if campaign offer has reward so the reward table is displayed only if needed
    public Boolean campOfferHasReward(Id offerTypeId)
    {
    	List<CW_Reward_Catalogue__c> rewardCat = [SELECT Id, Name, Offer_Type__c FROM CW_Reward_Catalogue__c WHERE Offer_Type__c =: offerTypeId];

    	if (!rewardCat.isEmpty())
    		return true;
    	else return false;
    }
    
    public void enableCampOfferFields()
    {
    	editMode=true;
    }
    
    //function used for accordion buttons
    public void emptyAction() {}
}