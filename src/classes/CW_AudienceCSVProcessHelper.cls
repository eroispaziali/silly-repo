/**
* File Name :   CW_AudienceCSVProcessHelper.cls
* Description : Helper Class for processing iported CSV file in batches
*               
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 20/05/2014 Alex PAnka     Initial version
*
*
*/
public with sharing class CW_AudienceCSVProcessHelper {
	
	private Id CampaignID ;
	private CW_CSV_Import_Status__c CsvStatus;
	private List<CW_CSV_Stage_AudienceMembers__c> CsvStageList;
	private Map<ID,CW_Campaign_Reward__c> campRewardMap;  //Reference by Reward Library
	private Map<Id,CW_Audience_Group_Schedule__c> grupSheduleMap; //Reference by group ID.
	private map<string,id> audSchedRewMap;//Reference by group ID+Library_id
	private map<string,id> audMemberMap;//Reference by group ID COntactId
	
	public CW_AudienceCSVProcessHelper(Id StatusID){
		
		CsvStatus= [SELECT ID ,Marketing_Campaign__c,Schedule__c,Reward_Catalogue__c,Reward_Catalogue__r.Name FROM CW_CSV_Import_Status__c WHERE Id=:StatusID];
		CampaignID=CsvStatus.Marketing_Campaign__c;
	}
	
	private String getFldValue(List<String> flds , integer Idx){
		if(flds.Size()<=Idx)
			return null;
		String sVal=flds.get(Idx);
		if(sVal==null)
			return null;
		if(!String.isNotBlank(sVal.trim()))
			return null;
		return sVal.trim();
	}
	
	private String ToUpper(String sVal){
		if(sVal==null) return '';
		return sVal.ToUpperCase();
	}
	     // CSV contains Account.Palyer_Id__c and CW_Audience_Group__r.Name,FreeBet ID, Ammount, currency
    public void processGroupMemberRewards(List<List<string>> csvLines)
    {
        map<String,CW_CSV_Stage_AudienceMembers__c> MembrRewardsMap = new map<String,CW_CSV_Stage_AudienceMembers__c>();
        map<string,id> GroupsIdmap=new map<string,id>();
        map<string,id> PlayerIdmap=new map<string,id>();
        map<string,id> FreeBetIdmap=new map<string,id>();
        for(List<String> flds : csvLines)
        {
            CW_CSV_Stage_AudienceMembers__c CsvRec = new CW_CSV_Stage_AudienceMembers__c(CSV_Import_Status__c =csvStatus.Id);
            CsvRec.Group_Name__c =getFldValue(flds,ConstantUtil.CSV_GROUP_NAME_COLUMN);
            CsvRec.PlayerId__c   =getFldValue(flds,ConstantUtil.CSV_ACCOUNT_PLAYER_ID_COLUMN);
				
				if(CsvStatus.Reward_Catalogue__c!=null){// If is null there no need to load this column.
					CsvRec.FreeBetId__c  =getFldValue(flds,ConstantUtil.CSV_FREEBET_ID_COLUMN);
					if(getFldValue(flds,ConstantUtil.CSV_AMOUNT_COLUMN)!=null )
						CsvRec.Amount__c     =Double.valueOf(getFldValue(flds,ConstantUtil.CSV_AMOUNT_COLUMN));
					CsvRec.Currency__c   =getFldValue(flds,ConstantUtil.CSV_CURRENCY_COLUMN);
				}
				if(CsvRec.Group_Name__c==null || CsvRec.PlayerId__c==null) //Not upload if names a null
					continue;
            if(!String.isNotBlank(CsvRec.Group_Name__c))//Emty group name skip record
            	continue;
            if(!String.isNotBlank(CsvRec.PlayerId__c))//Emty group name skip record
            	continue;
            CsvRec.Name=CsvRec.Group_Name__c+'|'+CsvRec.PlayerId__c+'|'+CsvRec.FreeBetId__c;
            MembrRewardsMap.Put(CsvRec.Name,csvRec); //Uniqu records -> Group_PlayerId
            GroupsIdmap.Put(ToUpper(CsvRec.Group_Name__c),null);
            PlayerIdmap.Put(ToUpper(CsvRec.PlayerId__c),null);
            FreeBetIdmap.Put(ToUpper(CsvRec.FreeBetId__c),null);
        }
        //Find Players
        for(Contact cntRec: [Select ID,Account_Name__c FROM Contact WHERE Account_Name__c=:PlayerIdmap.KeySet() ]){
        		//Contact.Account_Name__c
        		PlayerIdmap.Put(ToUpper(cntRec.Account_Name__c),cntRec.ID);
        }
        //Find groups
        for(CW_Audience_Group__c grpRec: [Select ID,Name FROM CW_Audience_Group__c WHERE Name=:GroupsIdmap.KeySet() AND Campaign__c =:CsvStatus.Marketing_Campaign__c]){
        		//CW_Audience_Group__c.NAme
        		GroupsIdmap.Put(ToUpper(grpRec.Name),grpRec.ID);
        }
        
        //Find FreebetID Select c.Reward_Catalogue__c, c.FreeBet_Id__c From CW_Reward_Library__c c
        //for(CW_Reward_Library__c fbRec: [SELECT ID,FreeBet_Id__c FROM CW_Reward_Library__c WHERE FreeBet_Id__c=:FreeBetIdmap.KeySet() AND Reward_Catalogue__c= :CsvStatus.Reward_Catalogue__c ]){
        //		FreeBetIdmap.Put(ToUpper(fbRec.FreeBet_Id__c),fbRec.ID);
        //}
        
        for(CW_CSV_Stage_AudienceMembers__c rec:MembrRewardsMap.Values()){
        		rec.Audience_Group_ref__c =GroupsIdmap.get(ToUpper(rec.Group_Name__c));
        		rec.Contact_ref__c        =PlayerIdmap.get(ToUpper(rec.PlayerId__c));
        		rec.Reward_Library__c     =FreeBetIdmap.get(ToUpper(rec.FreeBetId__c));
        }
        Database.insert(MembrRewardsMap.Values());
    }
    
    
   public void processCreateSheildAccounts( List<CW_CSV_Stage_AudienceMembers__c> scope){
   	CsvStageList=scope;
   	map<string,string> PlayrsMap= new map<string,string>();
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		PlayrsMap.Put(rec.PlayerId__c.ToUpperCase(),rec.PlayerId__c);
   	}
   	map<string,Id> PlayrsIdMap=CreateSheildAccounts(new Set<string>(PlayrsMap.values()));
   	
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		rec.Contact_ref__c=PlayrsIdMap.get(rec.PlayerId__c.ToUpperCase());
   	}
   	update CsvStageList;
   }
   
   //Step 2  - create Accounts and groups.
   
   public void processCreateAudienceGroups(List<CW_CSV_Stage_AudienceMembers__c> scope){
   	CsvStageList=scope;
   	map<string,string> groupMap= new map<string,string>();
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		groupMap.Put(rec.Group_Name__c.ToUpperCase(),rec.Group_Name__c);
   	}
   	map<string,Id> groupIdMap=CreateAudienceGroups(new Set<string>(groupMap.values()));
   	
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		rec.Audience_Group_ref__c=groupIdMap.get(rec.Group_Name__c.ToUpperCase());
   	}
   	update CsvStageList;
   }
    
    
   public void processImportDataToCamp(List<CW_CSV_Stage_AudienceMembers__c> scope){
   	//We have set groups , Members adn freeBets. So we can impotr all with seted reference others records a ignored.
   	CsvStageList=scope;
   	//firts step crate non exited camping rewards and load existings
   	loadCreateCampaignReward();
   	
   	//Next step is  CreateAudiece sschedule
   	createLoadAudienceGroupSchdule();
   	
   	createAudinceGroupScheduleReward();
   	
   	//And olmost FInala Step Is  
   	createAudinceMember();
   	//And Final step
 		createAudinceMemberReward();
   } 
    
    
   //Private methods for step 2 
   private map<string,Id> CreateSheildAccounts(Set<String> ContactNameList){

  // Rigth now crate Scheiled Account.
    	List<Account> newContacs= new List<Account>();
      if(ContactNameList.Size()>0 ){
      	Id personAccountRTId = [select id from RecordType where SobjectType = 'Account' AND IsPersonType = true limit 1].id;
         for(String playerId:ContactNameList ){
         	Account acc = new Account();
            acc.FirstName = playerId;
            acc.LastName = playerId;
            acc.Account_Name__pc = playerId;
            acc.RecordtypeId = TestDataUtil.personAccountRTId;
            acc.Requires_Update__pc = true;
            newContacs.Add(acc);
         }
        	Insert newContacs; 
      }
      map<string,Id> reslt= new map<string,Id>();
      for(Contact rec: [SELECT id, Account_Name__c FROM Contact WHERE Account_Name__c=:ContactNameList]){
      	reslt.put(rec.Account_Name__c.ToUpperCase(),rec.id);
      }
      return reslt;
   }
   
    private map<string,Id> CreateAudienceGroups(Set<String> GroupNameList ){
   	list<CW_Audience_Group__c> grpList= new list<CW_Audience_Group__c>();
      for(String grpName:GroupNameList ){
     		CW_Audience_Group__c grp = new CW_Audience_Group__c(Campaign__c = CampaignID);
      	grp.Name=grpName;
         grp.Is_Control_Group__c = false;
         grp.Description__c = grpName;
         grpList.Add(grp);
      }
      Insert grpList;
      map<string,Id> reslt= new map<string,Id>();
      for(CW_Audience_Group__c rec:grpList ){
      	reslt.put(rec.Name.ToUpperCase(),rec.id);
      }
		return reslt;
   } 
   
   
   //End OF step 2 - Step 3
   
   //Create Campiang Rewards - WORKING OK
   //Add Error chcking on Insert Records
   private void loadCreateCampaignReward(){
   	campRewardMap= new Map<ID,CW_Campaign_Reward__c>();
   	Map<String,CW_Campaign_Reward__c> campFreeBetdMap= new Map<String,CW_Campaign_Reward__c>();
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		campFreeBetdMap.Put(rec.FreeBetId__c.ToUpperCase(),null);
   	}
   	for(CW_Campaign_Reward__c rec: [SELECT Id,Reward_Library__c, Reward_Library__r.FreeBet_Id__c,Reward_Library__r.Amount__c,Reward_Library__r.Currency__c FROM CW_Campaign_Reward__c
   												 WHERE Reward_Library__r.FreeBet_Id__c=: campFreeBetdMap.keySet()]){ //Campaign__Offer__r.Campaign__c=:CampaignID AND 
   		campRewardMap.put(rec.Reward_Library__c,rec);								 	
   		campFreeBetdMap.put(rec.Reward_Library__r.FreeBet_Id__c.ToUpperCase(),rec);
   												 	
   	}
   	List<CW_Campaign_Reward__c> CampRewList= new List<CW_Campaign_Reward__c>();
   	//For percent we takie cuurency from file
   	
   	
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		String FreeBet=rec.FreeBetId__c.ToUpperCase();
   		CW_Campaign_Reward__c rewRec= campFreeBetdMap.get(FreeBet);
   		if(rewRec==null){
	   		//rewRec=new CW_Campaign_Reward__c(Campaign_Offer__r.Campaign__c = CampaignID);
	   		rewRec.Reward_Library__c=rec.Reward_Library__c;
	   		//rewRec.Reward_Catalogue__c=rec.Reward_Library__r.Reward_Catalogue__c;
	   		//rewRec.Reward_Curency__c=rec.Reward_Library__r.Currency__c;
	   		CampRewList.Add(rewRec);
	   		campFreeBetdMap.put(FreeBet,rewRec);
   		}
   	}
   	insert CampRewList;
   	for(CW_Campaign_Reward__c rec : CampRewList){
   		campRewardMap.put(rec.Reward_Library__c,rec);
   	}
   }
   
   
   private void  createLoadAudienceGroupSchdule(){
   	
   	grupSheduleMap = new Map<ID,CW_Audience_Group_Schedule__c>();//Reference by group ID.
   	Map<Id,CW_Audience_Group__c> grupMap= new Map<Id,CW_Audience_Group__c>();
   	CW_Audience_Group_Schedule__c c = new  CW_Audience_Group_Schedule__c();
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		if(!grupSheduleMap.containskey(rec.Audience_Group_ref__c)){
   			grupSheduleMap.Put(rec.Audience_Group_ref__c,null);
   			grupMap.put(rec.Audience_Group_ref__c, new CW_Audience_Group__c(id=rec.Audience_Group_ref__c,
   											is_control_group__c=rec.Audience_Group_ref__r.Is_control_group__c,
   											control_group__c=rec.Audience_Group_ref__r.control_group__c));
   		}
   	}
   	for (CW_Audience_Group_Schedule__c rec: [SELECT ID,Audience_Group__c FROM CW_Audience_Group_Schedule__c
   													WHERE Schedule__c=:CsvStatus.Schedule__c ]){ //Audience_Group__c=:grupSheduleMap.KeySet()  AND  load  all group schedule to set ref to control grouo sched.
   		grupSheduleMap.put(rec.Audience_Group__c,rec);
   														
   	}
   	list<CW_Audience_Group_Schedule__c> ListToIns=new list<CW_Audience_Group_Schedule__c>();
   	for(Id grpId:grupMap.KeySet()){
   		CW_Audience_Group_Schedule__c rec=grupSheduleMap.get(grpId);
   		if(rec==null){
   			rec=new CW_Audience_Group_Schedule__c();
   			CW_Audience_Group__c grpRec=grupMap.get(grpId);
   	 		rec.Schedule__c=CsvStatus.Schedule__c;
   	 		rec.Is_Control_Group__c=grpRec.Is_Control_Group__c;
   	 		rec.Audience_Group__c=grpId;
   	 		rec.Exclude_From_RollUp__c=false;
   	 		rec.Control_Group_Schedule__c=grprec.Control_Group__c;
   	 		if(rec.Control_Group_Schedule__c!=null){
   	 			CW_Audience_Group_Schedule__c CtrSched=grupSheduleMap.get(grprec.Control_Group__c);
   	 			if(CtrSched!=null){
   	 				rec.Control_Group_Schedule__c=CtrSched.Id;
   	 			}
   	 		}
   	 		grupSheduleMap.put(grpId,rec);
   	 		ListToIns.Add(rec);
   		}
   	}
   	insert ListToIns;
   }
  
   //This is complicated so we must process both to not make to much of shcedureRewards
   //We have one shedule so we must find grup and reward(freebet)
   private void createAudinceGroupScheduleReward(){
 
   	//There a many so we must have coposit key grupId _FreeBetId (Campaign Reward)
   	audSchedRewMap= new map<string,id>();
   	for(CW_Audience_Group_Schedule_Reward__c rec :[SELECT Id,Audience_Group_Schedule__r.Audience_Group__c,Campaign_Reward__c FROM CW_Audience_Group_Schedule_Reward__c 
   					WHERE Audience_Group_Schedule__r.Schedule__c =:CsvStatus.Schedule__c]){
   		 audSchedRewMap.put(''+rec.Audience_Group_Schedule__r.Audience_Group__c+rec.Campaign_Reward__c,rec.ID);		
   	}
   	//GO for AllRecords and chek if we have all Keys
   	List<CW_Audience_Group_Schedule_Reward__c> ToInsert= new List<CW_Audience_Group_Schedule_Reward__c>();
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		CW_Campaign_Reward__c campRew=campRewardMap.get(rec.Reward_Library__c);
   		if(campRew==null){
   				continue; // we propably should rise error as somthing wrong has hepen  -> we dont created sscheduled group in prev step !!!
   			}
   		String Key=''+rec.Audience_Group_ref__c+campRew.ID;
   		//Regarding 27-05-2014 sprint 07  for control groups we can have rewards 
   		//if(rec.Audience_Group_ref__r.Is_Control_group__c){
   		//	continue ;// There no rewords for control groups.
   		//}
   		if(!audSchedRewMap.containskey(key)){
   			CW_Audience_Group_Schedule_Reward__c newShedRew=new  CW_Audience_Group_Schedule_Reward__c();
   			CW_Audience_Group_Schedule__c shedRec=grupSheduleMap.get(rec.Audience_Group_ref__c);
   			
   			if(shedRec==null){
   				continue; // we propably should rise error as somthing wrong has hepen  -> we dont created sscheduled group in prev step !!!
   			}
   			
   			newShedRew.Audience_Group_Schedule__c=shedRec.ID;
   			newShedRew.Campaign_Reward__c=campRew.ID;
   			ToInsert.Add(newShedRew);
   			audSchedRewMap.put(key,null);//To not add twice
   		}
   		
   	}
  		insert ToInsert;
  		//becouse we use fields from releted object we need to requery. mayby beter option will be ser __r=xxx and use upsert
  		for(CW_Audience_Group_Schedule_Reward__c rec :[SELECT Id,Audience_Group_Schedule__r.Audience_Group__c,Campaign_Reward__c FROM CW_Audience_Group_Schedule_Reward__c 
   					WHERE Audience_Group_Schedule__r.Schedule__c =:CsvStatus.Schedule__c]){
   		 audSchedRewMap.put(''+rec.Audience_Group_Schedule__r.Audience_Group__c+rec.Campaign_Reward__c,rec.ID);		
   	}
 
   }
   
   
   	
   private void createAudinceMember(){
 		//  This is last stap we dont kreate globals  
   	audMemberMap= new map<string,id>();
   	for(CW_Audience_Group_Member__c rec :[SELECT Id,Audience_Group_LU__c,Contact__c FROM CW_Audience_Group_Member__c 
   					WHERE Audience_Group_Schedule__r.Schedule__c =:CsvStatus.Schedule__c]){
   		 audMemberMap.put(''+rec.Audience_Group_LU__c+rec.Contact__c,rec.ID);		
   	}
   	
   	//GO for AllRecords and chek if we have all Keys
   	List<CW_Audience_Group_Member__c> ToInsert= new List<CW_Audience_Group_Member__c>();
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		String Key=''+rec.Audience_Group_ref__c+rec.Contact_ref__c;
   		//Regarding 27-05-2014 sprint 07  for control groups we can have rewards 
   		//if(rec.Audience_Group_ref__r.Is_Control_group__c){
   		//	continue ;// There no rewords for control groups.
   		//}
   		if(!audMemberMap.containskey(key)){
   			CW_Audience_Group_Member__c newMember=new  CW_Audience_Group_Member__c();
   			CW_Audience_Group_Schedule__c shedRec=grupSheduleMap.get(rec.Audience_Group_ref__c);
   			if(shedRec==null){
   				continue; // we propably should rise error as somthing wrong has hepen  -> we dont created sscheduled group in prev step !!!
   			}		
   			newMember.Audience_Group_Schedule__c=shedRec.ID;
   			newMember.Contact__c=rec.Contact_ref__c;
   			newMember.Audience_Group_LU__c=rec.Audience_Group_ref__c;
   			ToInsert.Add(newMember);
   			//De dup
   			audMemberMap.put(key,null);
   		}
   	}
  		insert ToInsert;
  		//becouse we use fields from releted object we need to requery. mayby beter option will be ser __r=xxx and use upsert
	   for(CW_Audience_Group_Member__c rec :[SELECT Id,Audience_Group_LU__c,Contact__c FROM CW_Audience_Group_Member__c 
   					WHERE Audience_Group_Schedule__r.Schedule__c =:CsvStatus.Schedule__c]){
   		 audMemberMap.put(''+rec.Audience_Group_LU__c+rec.Contact__c,rec.ID);		
   	}
   	
 
   }  
   
   private void createAudinceMemberReward(){
 		//  This is last stap we dont kreate globals  
   	map<string,id> audMemberRewrdMap= new map<string,id>();
   	//Audience_Group_Member__c ,Audience_Group_Schedule_Reward__c
   	for(CW_Audience_Group_Member_Reward__c rec :[SELECT Id,Audience_Group_Member__c,Audience_Group_Schedule_Reward__r.Campaign_Reward__c FROM CW_Audience_Group_Member_Reward__c 
   					WHERE Audience_Group_Schedule_Reward__c =:audSchedRewMap.Values()]){
   		 audMemberRewrdMap.put(''+rec.Audience_Group_Member__c+rec.Audience_Group_Schedule_Reward__r.Campaign_Reward__c,rec.ID);		
   	}
   	//GO for AllRecords and chek if we have all Keys
   	List<CW_Audience_Group_Member_Reward__c> ToInsert= new List<CW_Audience_Group_Member_Reward__c>();
   	for(CW_CSV_Stage_AudienceMembers__c rec:CsvStageList ){
   		//Regarding 27-05-2014 sprint 07  for control groups we can have rewards 
   		//if(rec.Audience_Group_ref__r.Is_Control_group__c){
   		//	continue ;// There no rewords for control groups.
   		//}
   		ID audMemId=audMemberMap.get(''+rec.Audience_Group_ref__c+rec.Contact_ref__c);
   		CW_Campaign_Reward__c campRew=campRewardMap.get(rec.Reward_Library__c);   		
   		ID  shedRewId=audSchedRewMap.get(''+rec.Audience_Group_ref__c+campRew.Id);
   		if( audMemId==null ||campRew ==null || shedRewId==null ){
   			continue; // we dont find som values .......skiping. should be addet check for error raising
   		}
   		
   		String Key=''+audMemId +campRew.ID;
   		if(!audMemberRewrdMap.containskey(key)){
   			CW_Audience_Group_Member_Reward__c newMemRew=new  CW_Audience_Group_Member_Reward__c();
   			newMemRew.Audience_Group_Member__c=audMemId;
   			newMemRew.Audience_Group_Schedule_Reward__c=shedRewId;
   			//DO not upload Amount if its free beet ammunt
   			if(CsvStatus.Reward_Catalogue__r.Name.toLowerCase().contains('amount')){
	   			newMemRew.Amount__c  =campRew.Reward_Library__r.Amount__c;
	   			newMemRew.Currency__c=campRew.Reward_Library__r.Currency__c;
	   		}else{
	   			newMemRew.Amount__c=rec.Amount__c;
	   			newMemRew.Currency__c=rec.Currency__c;
	   		}
   			ToInsert.Add(newMemRew);
   			//De dup
   			audMemberRewrdMap.put(key,null);
   		}
   	}
  		insert ToInsert;
  		//becouse we use fields from releted object we need to requery. mayby beter option will be ser __r=xxx and use upsert

 
   }   
}