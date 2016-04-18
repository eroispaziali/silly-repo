trigger EventAttendanceDetails_AfterInsertUpdate on Event_Attendance_Details__c (after update) {

	List <Event_Attendance_Details__c> eadDeleteList = new List<Event_Attendance_Details__c>();
	List <Event_Attendance_Details__c> eadDeleteListTemp = new List<Event_Attendance_Details__c>();
	List<Id> suId = new List<Id>();
	List<Id> eventId = new List<Id>();
	for(Event_Attendance_Details__c ead : trigger.new){
		suId.add(ead.Service_Usage__c);
		eventId.add(ead.EventId__c);
	}
	eadDeleteList = [Select e.Service_Usage__c, e.LastModifiedDate, e.Id, e.EventId__c From Event_Attendance_Details__c e 
							where Service_Usage__c in :suId and EventId__c in :eventId
							order by LastModifiedDate desc];
	
							
	Event_Attendance_Details__c eadToRetain = new Event_Attendance_Details__c();
	if(eadDeleteList!=null && eadDeleteList.size()>1){
		System.debug('1111111111111111111111111111111 list size: '+eadDeleteList.size());
		System.debug('2222222222222222222222222222222 list : '+eadDeleteList);
		for(Integer i=1; i<eadDeleteList.size(); i++){
			eadDeleteListTemp.add(eadDeleteList[i]);
		}
		eadToRetain = eadDeleteList[0]; //retain the latest Event_Attendance_Details__c
	}
	System.debug('33333333333333333333333333333333 eadToRetain : '+eadToRetain);
	System.debug('44444444444444444444444444444444444444 eadDeleteList:  '+eadDeleteList);
	System.debug('44444444444444444444444444444444444444 eadDeleteList.size:  '+eadDeleteList.size());
	System.debug('55555555555555555555555555555555555555 eadDeleteListTemp: '+eadDeleteListTemp);
	System.debug('55555555555555555555555555555555555555 eadDeleteListTemp.size: '+eadDeleteListTemp.size());
		
	delete eadDeleteListTemp;
	upsert eadToRetain;
	System.debug('66666666666666666666666666666666666666 eadToRetain: '+eadToRetain);
	/**for(Event_Attendance_Details__c ed : eadDeleteList){
		for(Event_Attendance_Details__c ead : trigger.new){
			if(ed.Service_Usage__c==ead.Service_Usage__c && ed.EventId__c==ead.EventId__c)
		}
	}*/
}