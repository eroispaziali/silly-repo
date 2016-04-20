/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Update/Align Service Usage 'Date of Last Activity' field.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2012-01-12
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *  Copyright (c) Saaspoint 2012 as per Master Services Agreement
 *
 *  Description: Apex trigger on Event after insert, after update. 
 *               For Events scheduled for Service Usage, will update 'Date of Last Activity' field on SU.
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/
trigger TriggerEventAfterUpsertSUDateOfLastActivity on Event (after insert, after update){

//get the SU prefixKey to check Event is scheduled against SU.
string SUKeyPrefix = Schema.getGlobalDescribe().get('Service_Usage__c').getDescribe().getKeyPrefix();
Set<Id> setSUIds = new Set<Id>();

//Extract all SU Ids from Events
//For Update Trigger
if(Trigger.isUpdate)
{
    for (Event e : Trigger.old) {
        
        //If Event's WhatId is null then continue with another Event record.
        if(e.whatId==null) continue;
        
        string strSUId = String.valueOf(e.whatId);
        
        //If Event is scheduled against SU then add SU Id to List.
        if(!setSUIds.contains(strSUId) && strSUId.startsWith(SUKeyPrefix))
        {
            system.debug('########### Is related to SU and Meeting Type#######');
            setSUIds.add(strSUId);
        }
    }
}

//For Both Insert/Update to Align update Old and new SU record with appropriate Last Activity date.
for (Event e : Trigger.new) {
    
    //If Event's WhatId is null then continue with another Event record.
    if(e.whatId==null) continue;
    
    string strSUId = String.valueOf(e.whatId);
    
    //If Event is scheduled against SU then add SU Id to List.
    if(!setSUIds.contains(strSUId) && strSUId.startsWith(SUKeyPrefix))// && e.Format__c!=null) && e.Format__c.equalsIgnoreCase('Meeting'))
    {
        system.debug('########### Is related to SU and Meeting Type#######');
        setSUIds.add(strSUId);
    }
}

system.debug('###########setSUIds##############'+setSUIds);

//If any SU Ids are added to List; means they need to be updated with appropriate Last Activity dates
if(setSUIds.size()>0)
{
    //Invoke Static method which returns Last Activity date for given list of SU Ids.
    Map<Id,Date> mapSUActivityDates = ServiceUsageDateOfLastActivity.getDateOfLastActivity(setSUIds);
    
    List<Service_Usage__c> lstSUToUpdate = new List<Service_Usage__c>();
    
    //If static method returned with SU dates to update.
    if(mapSUActivityDates!=null)
    {
        //Create List of SU records to update with Last Activity Dates.
        for(Id SUId:mapSUActivityDates.keySet())
        {
            lstSUToUpdate.add(new Service_Usage__c(Id=SUId,Date_of_last_Activity__c=mapSUActivityDates.get(SUId)));
        }
        
      try
      {
        //Make DML.
        Database.SaveResult[] lsr = Database.Update(lstSUToUpdate);
        
        //Iterate through each Updated DML record and find for any failurs, if so then add Error message.
        for(Database.SaveResult sr:lsr)
        {
            //If Update was unsuccessful.
            if(!sr.isSuccess())
            {
                for (Event e : Trigger.new) 
                {
                    //Retrieve the Event Id to add Error message.
                    if(e.WhatId==sr.getId())
                    {
                        e.addError('Error updating Service Usage Date of Last Activity: '+sr.getErrors()+'. Contact The CRS Helpdesk.');
                    }
                }
            }    
        }          
      }catch(Exception ex){system.debug('TriggerEventAfterUpsertSUDateOfLastActivity: Runtime Exception');}
    }
}
}