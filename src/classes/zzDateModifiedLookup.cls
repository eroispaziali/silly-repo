public with sharing class zzDateModifiedLookup {

	/*
	
	ADD LOGIC TO UPDATE/CREATE NEW ROWS IN THE zzDateModifiedLookup__c OBJECT.
	
	*/


	public void zzDateModifiedLookupUpdate(){
		
		System.debug('****** Apex Class zzDateModifiedLookupUpdate  ******');

		List<zzDateModifiedLookup__c> zzList = [SELECT id, lastDateModified__c, objectAPIName__c FROM zzDateModifiedLookup__c WHERE objectAPIName__c = 'zzService_Usage_Copy__c'];
  		for(integer i = 0 ; i < zzList.size(); i++){
     		zzList[i].lastDateModified__c = datetime.now();
  		}
		
		update zzList;	
	}	

}