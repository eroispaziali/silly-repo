/**
* File Name   :    CW_RoadmapTriggerHandler.cls
* Description :    B-108373
*                  trigger to copy Approval Status from Roadmap to all Child Campaigns when it changes.
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 29/04/2014 Alex Panka     Initial version
*
*
*/
//Cristina P: 08/07/14: Changing the class from "with sharing" to "without sharing" 
//so the user can create related records while cost/brief is in approval
public without sharing class CW_RoadmapTriggerHandler {	
	
	public static void  copyApprovalStatusToCampaigns(List<CW_Roadmap__c> oldlst, Map<Id,CW_Roadmap__c>newMap){
		Set<Id> ChngRoadmap= new Set<Id>();
		
		for( CW_Roadmap__c oldrec : oldLst){
			CW_Roadmap__c Rec=newMap.get(oldrec.Id);
			if(oldRec==null) continue;
			if(oldRec.Approval_Status__c!=rec.Approval_Status__c ){
				ChngRoadmap.Add(rec.Id);
			}
		}
		if(ChngRoadmap.Size()>0){
			List <CW_Campaign__c> campLst= [SELECT id,Roadmap_Approval_Status__c,Roadmap__r.Approval_Status__c FROM CW_Campaign__c WHERE Roadmap__c=:ChngRoadmap ];
			for(CW_Campaign__c campRec : campLst){
				campRec.Roadmap_Approval_Status__c= campRec.Roadmap__r.Approval_Status__c;
			}
			upsert campLst;
		}
	}
}