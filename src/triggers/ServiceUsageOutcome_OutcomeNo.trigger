/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Populates outcome number.
 *  Author  : Fujitsu - Nupoor Pandey
 *  Date    : 2012-02-16
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *
 *  Description: Apex trigger on Service usage Outcome before insert. 
 *               Generates Outcome number starting from 1
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/
/**trigger ServiceUsageOutcome_OutcomeNo on Service_Usage_Outcome__c (after insert) {

	Set<Id> suoIds = new Set<Id>();
	Set<Id> suIds = new Set<Id>();
	List<Service_Usage_Outcome__c> suoList = new List<Service_Usage_Outcome__c>();
	List<Service_Usage__c> suList = new List<Service_Usage__c>();
	//Select s.Service_Usage__c, s.Outcome_No__c, s.Id From Service_Usage_Outcome__c s where s.Service_Usage__c =
	
	for (Service_Usage_Outcome__c rec: Trigger.new) {
		suoIds.add(rec.id);
		suIds.add(rec.Service_Usage__c);
	}
	
	suoList = [Select s.Service_Usage__c, s.Outcome_No__c, s.Id From Service_Usage_Outcome__c s where s.Service_Usage__c in :suIds];
	suList = [Select s.Id, (Select Id, Outcome_No__c From Service_Usage_Outcomes__r) From Service_Usage__c s where s.id in :suIds];
	
	Integer count;
	List<Service_Usage_Outcome__c> suoToUpdate = new List<Service_Usage_Outcome__c>();
	for (Service_Usage_Outcome__c suOutcome: Trigger.new) {
	    count = 1;
	    try{
	    	//for every new outcome, check in the list of all outcomes whether the SU ids match. if yes, increase count
	      	for(Service_Usage_Outcome__c suo : suoList){
	      		if(suOutcome.Service_Usage__c==suo.Service_Usage__c){
		      		//for(Service_Usage__c su : suList){
		      			//if(suOutcome.Service_Usage__c==su.Id){
		      				count++;
		      			//}
					//}
	      		}  
			} 
			suOutcome.Outcome_No__c = count; 
			suoToUpdate.add(suOutcome);
	    }catch(Exception ex){suOutcome.addError(ex.getMessage()+'. Contact The CRS Helpdesk.');}
	}
	update suoToUpdate;
}**/


trigger ServiceUsageOutcome_OutcomeNo on Service_Usage_Outcome__c (before insert) {

	Set<Id> suoIds = new Set<Id>();
	Set<Id> suIds = new Set<Id>();
	List<Service_Usage_Outcome__c> suoList = new List<Service_Usage_Outcome__c>();
	List<Service_Usage__c> suList = new List<Service_Usage__c>();
	//Select s.Service_Usage__c, s.Outcome_No__c, s.Id From Service_Usage_Outcome__c s where s.Service_Usage__c =
	
	for (Service_Usage_Outcome__c rec: Trigger.new) {
		//suoIds.add(rec.id);
		suIds.add(rec.Service_Usage__c);
	}
	
	suoList = [Select s.Service_Usage__c, s.Outcome_No__c, s.Id From Service_Usage_Outcome__c s where s.Service_Usage__c in :suIds];
	//suList = [Select s.Id, (Select Id, Outcome_No__c From Service_Usage_Outcomes__r) From Service_Usage__c s where s.id in :suIds];
	
	Integer count;
	//List<Service_Usage_Outcome__c> suoToUpdate = new List<Service_Usage_Outcome__c>();
	for (Service_Usage_Outcome__c suOutcome: Trigger.new) {
	    count = 1;
	    try{
	    	//for every new outcome, check in the list of all outcomes whether the SU ids match. if yes, increase count
	      	for(Service_Usage_Outcome__c suo : suoList){
	      		if(suOutcome.Service_Usage__c==suo.Service_Usage__c){
		      		//for(Service_Usage__c su : suList){
		      			//if(suOutcome.Service_Usage__c==su.Id){
		      				count++;
		      			//}
					//}
	      		}  
			} 
			suOutcome.Outcome_No__c = count; 
			//suoToUpdate.add(suOutcome);
	    }catch(Exception ex){suOutcome.addError(ex.getMessage()+'. Contact The CRS Helpdesk.');}
	}
	//update suoToUpdate;
}