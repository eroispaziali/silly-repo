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
 *  Description: Apex trigger on Task after insert, after update. 
 *               For Tasks scheduled for Service Usage, will update 'Date of Last Activity' field on SU.
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  2012-02-27    MT    Add check for null Id
 *                             
*******************************************************************************************/
trigger TriggerTaskAfterUpsertSUDateOfLastActivity on Task(after insert, after update){

//get the SU prefixKey to check Event is scheduled against SU.
string SUKeyPrefix = Schema.getGlobalDescribe().get('Service_Usage__c').getDescribe().getKeyPrefix();
Set<Id> setSUIds = new Set<Id>();

//Extract all SU Ids from Events
if(Trigger.isUpdate)
{
    for (Task t: Trigger.old) {
        //If Tasks's WhatId is null then continue with another Task record.    
         if(t.whatId==null) continue;

        string strSUId = String.valueOf(t.whatId);
        
        if(!setSUIds.contains(strSUId) && strSUId.startsWith(SUKeyPrefix))
        {
            system.debug('########### Is related to SU and Meeting Type#######');
            setSUIds.add(strSUId);
        }
    }
}

//Get SU Ids to update/align SUs with appropriate Date of Last Activity.
for (Task t : Trigger.new) {
    //If Tasks's WhatId is null then continue with another Task record.    
     if(t.whatId==null) continue;
 
    string strSUId = String.valueOf(t.whatId);
    
    if(!setSUIds.contains(strSUId) && strSUId.startsWith(SUKeyPrefix))
    {
        system.debug('########### Is related to SU and Meeting Type#######');
        setSUIds.add(strSUId);
    }
}

system.debug('###########setSUIds##############'+setSUIds);

//If any SU records to update
if(setSUIds.size()>0)
{
    //Invoke Static method to return SU and their Last Activity Date for given SU Ids.
    Map<Id,Date> mapSUActivityDates = ServiceUsageDateOfLastActivity.getDateOfLastActivity(setSUIds);
    
    List<Service_Usage__c> lstSUToUpdate = new List<Service_Usage__c>();
    
    //If any SU record to update with date.
    if(mapSUActivityDates!=null)
    {
        //Iterrate and create list of SU records to Update with date.
        for(Id SUId:mapSUActivityDates.keySet())
        {
            lstSUToUpdate.add(new Service_Usage__c(Id=SUId,Date_of_last_Activity__c=mapSUActivityDates.get(SUId)));
        }
        
      try
      {
        //Make DML call
        Database.SaveResult[] lsr = Database.Update(lstSUToUpdate);
        //Iterage through DML result, to add error message to Task when failing to updat SU.
        for(Database.SaveResult sr:lsr)
        {
            //If update failes.
            if(!sr.isSuccess())
            {
                for (Task t : Trigger.new) 
                {
                    //Add error message to Task for related SU upated.
                    if(t.WhatId==sr.getId())
                    {
                        t.addError('Error updating Service Usage Date of Last Activity: '+sr.getErrors()+'. Contact The CRS Helpdesk.');
                    }
                }
            }    
        }          
      }catch(Exception ex){system.debug('TriggerEventAfterUpsertSUDateOfLastActivity: Runtime Exception');}
    }
}
}