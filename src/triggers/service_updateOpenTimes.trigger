trigger service_updateOpenTimes on Services__c (before insert, before update) {
    for (Services__c s : Trigger.new) {
        if ((s.service_operationhours__c != null ) && (s.Opening_Times_Guidebook__c == null || s.Opening_Times_Guidebook__c == '')) {
            ServiceOpeningTimes ot = new ServiceOpeningTimes(s.service_operationhours__c);
            //ot.setOpHours(s.service_operationhours__c);
            
            s.Opening_Times_Guidebook__c = ot.getDaysOpenString();
        }
        
        if (s.service_operationhourscomment__c != null && s.service_operationhourscomment__c != ''){
            if (s.Opening_Times_Guidebook__c.endswith(s.service_operationhourscomment__c)){
            //ignore
            }
            else {    
            
            s.Opening_Times_Guidebook__c += '\n' + s.service_operationhourscomment__c;
            }
        }
    }
}