/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Copy Address details from Service/Activity or Contact to Event for created against Service Usage.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-12-16
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: Apex trigger on Event before insert and update, If user has not filled address.
 *               details for Event created against Service Usage, Trigger will populate depending value from
 *                Location Type, if 'Office' picks from Service, if 'Service User Home' then from Primary Contact.
 *                Also contatenate all Address fields and populate Event Location file, to show on Calender. 
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2014-11-24   MT		Use address on Property not old address on Service (IM178522)
 *                             
*******************************************************************************************/
trigger TriggerEventBeforeUpsertLocationFiller on Event (before insert, before update){

//get the SU prefixKey to check Event is scheduled against SU.
string SUKeyPrefix = Schema.getGlobalDescribe().get('Service_Usage__c').getDescribe().getKeyPrefix();
Set<Id> setSUIds = new Set<Id>();

//Extract all SU Ids from Events
for (Event e : Trigger.new) {

    //Incase Event What Id is null then skip and continue with next Event record.
    if(e.whatId==null) continue;
    
    string strSUId = String.valueOf(e.whatId);
    
    if(!setSUIds.contains(strSUId) && strSUId.startsWith(SUKeyPrefix))
    {
        system.debug('########### Is related to SU and Meeting Type#######');
        setSUIds.add(strSUId);
    }
}

system.debug('###########setSUIds##############'+setSUIds);
//If any of the Event(s) is scheduled against SU then SOQL Service and Primary User address.
if(setSUIds.size()>0)
{
    //Retrive Service/Activity and Primary User Address.
    Map<Id,Service_Usage__c> mapSURecs = new Map<Id,Service_Usage__c>([select Id, 
        Service_Field__r.Operated_By__r.BillingStreet, Service_Field__r.Operated_By__r.BillingCity,
        Service_Field__r.Operated_By__r.BillingPostalCode,Service_Field__r.Operated_By__r.BillingState,
        Primary_Service_User__r.MailingStreet,Primary_Service_User__r.MailingCity,
        Primary_Service_User__r.MailingState,Primary_Service_User__r.MailingPostalcode
        from Service_Usage__c where Id=:setSUIds]);
        
        //Iterate through all Event(s) records to set/populate address from Service/Contact on Event record.
        for (Event e : Trigger.new) {
            
            try
            {
                //If Event meeting is at Office or User Home and No field is pre-filled.
                if(mapSURecs.containsKey(e.WhatId) && e.Location_Type_Event__c!=null && 
                    (e.Location_Type_Event__c.equalsIgnoreCase('Office')
                     || e.Location_Type_Event__c.equalsIgnoreCase('Service User Home')) &&
                     (e.Street__c == null && e.City__c == null && e.County__c == null && e.Postcode__c ==null)
                     )
                {
                    system.debug('########### SU found and in Address Population ##########');
                    Service_Usage__c recSU = mapSURecs.get(e.WhatId);
                    if(e.Location_Type_Event__c.equalsIgnoreCase('Office'))
                    {
                        e.Street__c = recSU.Service_Field__r.Operated_By__r.BillingStreet;
                        e.City__c = recSU.Service_Field__r.Operated_By__r.BillingCity;
                        e.County__c = recSU.Service_Field__r.Operated_By__r.BillingState;
                        e.Postcode__c = recSU.Service_Field__r.Operated_By__r.BillingPostalCode;
                    }
                    
                    if(e.Location_Type_Event__c.equalsIgnoreCase('Service User Home'))
                    {
                        e.Street__c = recSU.Primary_Service_User__r.MailingStreet;
                        e.City__c = recSU.Primary_Service_User__r.MailingCity;
                        e.County__c = recSU.Primary_Service_User__r.MailingState;
                        e.Postcode__c = recSU.Primary_Service_User__r.MailingPostalCode;
                    
                    }

                    //Finally contatenate all address field to populate Location field.
                    e.Location=(e.Street__c!=null?e.Street__c :'')+ (e.City__c!=null?', '+e.City__c :'')+ 
                        (e.County__c!=null?', '+e.County__c :'')+(e.Postcode__c!=null?', '+e.Postcode__c:'');
                }
            }catch(Exception ex){e.addError('Error Updating addresss fields: '+ex.getMessage()+'. Contact The CRS Helpdesk.');}

        }
}
system.debug('########### Finished #############');
}