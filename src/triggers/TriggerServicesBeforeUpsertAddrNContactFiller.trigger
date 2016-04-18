/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Populate Address fields from Location and Contact fields from User Objects.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2012-01-11
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *  Copyright (c) Saaspoint 2012 as per Master Services Agreement
 *
 *  Description: Apex trigger on Services before insert, before update. 
 *               If Service have Default Location then fetch Address details and populate fields.
 *               If Service have Primary Contact then fetch particulars from User and populate fields.
 *               
 *  Modification History
 *
 *  Date         Who           Description 
 *  13/01/2015 - LakshmiR -    Most of the code commented out.No DML transactions.
 *                             
*******************************************************************************************/
trigger TriggerServicesBeforeUpsertAddrNContactFiller on Services__c(before insert, before update){
If(!CustomUtils.isDisabledTriggers()){
Set<Id> setLocationIds = new Set<Id>();
Set<Id> setPrimContactIds = new Set<Id>();

//Extract Ids of Location and Primary Contact 
for (Services__c rec: Trigger.new) {
    
    try
    {
        if(rec.Default_Location__c!=null)
        {
            setLocationIds.add(rec.Default_Location__c);
        }
    
        /*if(rec.Primary_contact__c!=null)
        {
            setPrimContactIds.add(rec.Primary_contact__c);
        }*/
    }catch(Exception ex){rec.addError(ex.getMessage()+'. Contact The CRS Helpdesk.');}
}

system.debug('###########setLocationIds##############'+setLocationIds);
system.debug('###########setPrimContactIds##############'+setPrimContactIds);

//Populate Primary contact(User) Details
if(setPrimContactIds.size()>0)
{
    //Retrive User details.
    Map<Id,User> mapUserRecs = new Map<Id,User>([Select LastName,FirstName,Title,Email,Phone
        from User where Id=:setPrimContactIds]);
        
    //Iterate through service records to copy User particulars.
    for (Services__c rec: Trigger.new) {
        try
        {
            //Look for Primary contact and assign values.
            /*if(rec.Primary_contact__c!=null && mapUserRecs.containsKey(rec.Primary_contact__c))
            {
                system.debug('########### SU found and in Address Population ##########');
                User recUsr = mapUserRecs.get(rec.Primary_contact__c);
                
                //rec.Contact_salutation__c=recUsr.;
                rec.Contact_first_name__c=recUsr.FirstName;
                rec.Contact_last_name__c=recUsr.LastName;
                //rec.Job_Title__c=recUsr.Title;
                //rec.service_website__c=recUsr.;
                rec.service_email__c=recUsr.Email;
                rec.service_telephone__c=recUsr.Phone;
            }*/
        }catch(Exception ex){rec.addError('Error Updating Contact fields:'+ex.getMessage()+'. Contact The CRS Helpdesk.');}
    }
}


//Populate Location Address details.
if(setLocationIds.size()>0)
{
    //Retrive address fields from Location Object.
    Map<Id,Location__c> mapLocationRecs = new Map<Id,Location__c>([Select
    Address__c,Address_2__c,Address_3__c,Address_4__c,Addess_Town__c,County__c,
    Postcode__c,Country__c from Location__c where Id=:setLocationIds]);   
         
    //Iterate through Service records to copy address fields from Location.
    for (Services__c rec: Trigger.new) {
        try
        {
            //Look for Location and populate fields.
            if(rec.Default_Location__c!=null && mapLocationRecs.containsKey(rec.Default_Location__c))
            {
                system.debug('########### SU found and in Address Population ##########');
                Location__c recLoc = mapLocationRecs.get(rec.Default_Location__c);
 /* Change 205 do not update address for moment.               
                rec.service_street__c=recLoc.Address__c;
                rec.service_city__c=recLoc.Addess_Town__c;
                rec.service_county__c=recLoc.County__c;
                rec.service_postcode__c=recLoc.Postcode__c;
                rec.service_country__c=recLoc.Country__c;
*/
            }
        }catch(Exception ex){rec.addError('Error Updating addresss fields:'+ex.getMessage()+'. Contact The CRS Helpdesk.');}
    }
}

system.debug('########### Finished #############');
}
}