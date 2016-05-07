/**
* File Name   :    CW_AssociateAudienceRewardHelper.cls
* Description :    B-114504 - Create Audience Group Schedule Reward records
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 28/05/2014 Alex Panka	  Intial version 
*/
//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing" 
//so the user can create related records while cost/brief is in approval
public without sharing class CW_AssociateAudienceRewardHelper 
{
	/* set controller variables */
	public String 							contextItem {get;set;}
		
	public list<CW_Audience_Group__c>       agList{get;set;}
	public list<CW_Schedule__c>             schList{get;set;}
	public list<CW_Campaign_Reward__c>      rewList{get;set;}
	public set<String>                      agsSet=new Set<String>();//agsMap=new map<String,List<Id>>();
	public map<String,Id>                   agsMapId=new map<String,Id>();
	public map<String,Id>                   agsrMap=new map<String,Id>();
	 
	private set<String>                     newagsset=new set<string>();
	private set<Id>                         delagsset=new set<Id>();  	
	private set<String>                     newagsrset=new set<string>();
	private set<Id>                         delagsrset=new set<Id>();  	
	private Id                              CampId;
	
	public CW_AssociateAudienceRewardHelper(Id CampaignId)
	{
		CampId=CampaignId;
		init();		
	}
	
	public map<String,Boolean> getCheckkAgs()
	{
		map<String,Boolean> result=new map<String,Boolean>();
		for(CW_Campaign_Reward__c rrec:rewList)
		{
			for(CW_Audience_Group__c arec:agList)
			{
				result.put(''+arec.id+rrec.ID,false);
			}
		}
		for(String key:newagsset){
			result.put(key,true);
		}
		for(String key:agsSet){
			result.put(key,true);
		}
		return result;
	}
	
	public map<String,Boolean> getCheckkAgsr()
	{
		map<String,Boolean> result=new map<String,Boolean>();
		for(CW_Schedule__c srec : schList)
		{
			for(CW_Audience_Group__c arec:agList)
			{
				for(CW_Campaign_Reward__c rrec:rewList){
					result.put(''+srec.id+arec.id+rrec.id,false);
				}
			}
		}		
		for(String key:newagsrset){
			result.put(key,true);
		}
		for(String key:agsrMap.KeySet()){
			Id recId=agsrMap.get(key);
			if(!delagsrset.contains(recId))
				result.put(key,true);
		}
		return result;
	}
	
	public void init()
	{
		agsMapId=new map<String,Id>();
		agsrMap=new map<String,Id>();
			 
		//Records To create/delete	 
		newagsset=new set<string>();
		delagsset=new set<Id>();  	
		newagsrset=new set<string>();
		delagsrset=new set<Id>();  	
		
		//set the data display mode
		agList=  [SELECT Id,Name FROM CW_Audience_Group__c  WHERE Campaign__c=:campId AND Is_Control_Group__c=false];
		schList= [SELECT Id,Name ,Start_Date__c,End_Date__c  FROM CW_Schedule__c WHERE Marketing_Campaign__c=:campId ];
		rewList= [SELECT Id,Name,Reward_Catalogue__r.Offer_Type__r.Name,Reward_Type__r.Name FROM CW_Campaign_Reward__c WHERE Campaign_Offer__r.Campaign__c=:campId ];
		
		for(CW_Audience_Group_Schedule__c rec: [SELECT Id,name,Audience_Group__c,Schedule__c FROM CW_Audience_Group_Schedule__c])
		{
			agsMapId.put(''+rec.Schedule__c+rec.Audience_Group__c,rec.Id);
		}
		
		for(CW_Audience_Group_Schedule_Reward__c rec:[Select Id,name,Audience_Group_Schedule__r.Schedule__c,Audience_Group_Schedule__r.Audience_Group__c,Campaign_Reward__c FROM CW_Audience_Group_Schedule_Reward__c])
		{  
			agsrMap.put(''+rec.Audience_Group_Schedule__r.Schedule__c+rec.Audience_Group_Schedule__r.Audience_Group__c+rec.Campaign_Reward__c,rec.id);
			agsSet.Add(''+rec.Audience_Group_Schedule__r.Audience_Group__c+rec.Campaign_Reward__c);
		}
	}
 
	/*										*/
	/*   SELECT & DESELECT FUNCTIONALITY  	*/
	/*										*/

	//handle item selected
	private void doSelectGroupScheduleInternal(String item)
	{
		newagsset.Add(item);
	}
	
	private void doDeSelectGroupScheduleInternal(String item)
	{
		newagsset.remove(item);
	}
	
	public void doSelectGroupSchedule()
	{
		doSelectGroupScheduleInternal(this.contextItem);

		String GrpId=this.contextItem;
		for(CW_Schedule__c shr:schList)
		{
			doSelectGroupRewardInternal(''+shr.Id+GrpId);
		}
	}

	//handle item deselected
	public void doDeSelectGroupSchedule()
	{
		doDeSelectGroupScheduleInternal(this.contextItem);	
		String GrpId=this.contextItem;
		for(CW_Schedule__c shr:schList)
		{
				doDeSelectGroupRewardInternal(''+shr.Id+GrpId);
		}
	}
	
	private void doSelectGroupRewardInternal(String item)
	{
		id agsrId= agsrMap.get(item);
		if(agsrId!=null)
			// rec uncheked - remove from delete
			delagsrset.Remove(agsrId);
		else
			newagsrset.Add(item);
	}

	//handle item deselected
	private void doDeSelectGroupRewardInternal(String item)
	{
		id agsrId= agsrMap.get(Item);
		if(agsrId!=null)
			delagsrset.Add(agsrId);
		else
			newagsrset.remove(Item);
	}
	
	
	public void doSelectGroupReward()
	{
		doSelectGroupRewardInternal(this.contextItem);
		doSelectGroupScheduleInternal(this.contextItem.substring(18));
	}

	//handle item deselected
	public void doDeSelectGroupReward()
	{
		doDeSelectGroupRewardInternal(this.contextItem);
	}
	
	private void deleteSetOfIds(Set<id> toDel,string sType){
		List<sobject> lst= new List<sobject>();
		
		for(Id recid:toDel){
			Sobject delobj= Schema.getGlobalDescribe().get(sType).newSObject();
			delobj.Id=recid;
			lst.Add( delobj);
		}
		delete lst;
	}
	
	public void PresistChages()
	{
		try{
			deleteSetOfIds( delagsrset,'CW_Audience_Group_Schedule_Reward__c');

			List<CW_Audience_Group_Schedule__c> agsToIns= new List<CW_Audience_Group_Schedule__c>();
			for( String Key :newagsset)
			{	
				for(CW_Schedule__c sch:   schList)
				{	
					//check if we can create orrow already exists
					if(! agsMapId.containsKey(''+sch.Id+Key.substring(0,18)))
					{	
						CW_Audience_Group_Schedule__c rec= new CW_Audience_Group_Schedule__c();
						rec.Schedule__c=sch.Id;
						rec.Audience_Group__c=key.substring(0,18);
						agsToIns.Add(rec);
					}
				}
			}
			insert agsToIns;
			
			for(CW_Audience_Group_Schedule__c rec :agsToIns)
			{	
				agsMapId.Put(''+rec.Schedule__c+rec.Audience_Group__c,rec.Id);
			}
			
			List<CW_Audience_Group_Schedule_Reward__c> agsrToIns= new List<CW_Audience_Group_Schedule_Reward__c>();
			for( String Key :newagsrset){
				CW_Audience_Group_Schedule_Reward__c rec= new CW_Audience_Group_Schedule_Reward__c();
				if(agsrMap.containsKey(key))// Some errors in procesing we must skip this records as its already present
					continue;
				Id agsId=agsMapId.get(key.substring(0,36));
				if(agsId==null)
					continue;

				rec.Audience_Group_Schedule__c=agsId;
				rec.Campaign_Reward__c=key.substring(36);
				agsrToIns.Add(rec);
			}
			insert agsrToIns;
			
			//reload all data
			init();
		}catch(exception Ex){
			ApexPages.AddMessages(ex);
		}
	}
}