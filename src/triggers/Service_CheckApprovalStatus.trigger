/*********************************************************************************
* Service approval
*Update changes needs approval tick box
* Object: Services__c
* Mike Tinson
*      *  Modification History
*
*  Date         Who                      Description 
  
* 2014-11-07    Lakshmi Rajendram       Added line 35-54 to update Change_Needs_Approval__c when service details change    
*2015-01-13     Lakshmi Rajendram       Included in the servicetriggerhandler class

********************************************************************************/
trigger Service_CheckApprovalStatus on Services__c (before insert, before update) {

Id InternalServiceType;
InternalServiceType = [select Id from RecordType where sObjecttype = 'Services__c' and DeveloperName ='Internal'].Id;
List<user> updatedby = [select id, name, IgnoreValidationRules__c from User where id =:UserInfo.getUserId()];
    // set record status to needs approval if displyed on website and key fields change.

    for (Services__c s : Trigger.new) {
    if ((s.RecordTypeId == InternalServiceType)&&(updatedBy[0].IgnoreValidationRules__c ==false)){
        if (System.Trigger.isInsert  && !CustomUtils.isDisabledTriggers()){
            //s.Display_on_public_website__c = false; 
            s.Change_Needs_Approval__c = true;
            s.Approval_Stage__c='Changes Needs Approval';
            if (s.Service_Data_Manager__c ==null) {
                                                    s.Service_Data_Manager__c = updatedBy[0].id;}
            }
        else {  if(Trigger.isUpdate && !CustomUtils.isDisabledTriggers()){
                Services__c olds = Trigger.oldMap.get(s.ID); 
                     if ((s.Display_on_public_website__c != olds.Display_on_public_website__c) ||
                         (s.Name != olds.Name) || 
                         (s.service_description__c != olds.service_description__c) ||
                         (s.service_type__c != olds.service_type__c) ||
                         (s.service_status__c!= olds.service_status__c)||
                         (s.service_closedate__c!= olds.service_closedate__c)||
                         (s.Default_Location__c!= olds.Default_Location__c)||
                         (s.service_email__c!= olds.service_email__c)||
                         (s.service_telephone__c!= olds.service_telephone__c)||
                         (s.service_targetclientgroup__c!= olds.service_targetclientgroup__c)||
                         (s.Other_Target_Client_Group__c!= olds.Other_Target_Client_Group__c)||
                         (s.Funder_restriction__c!= olds.Funder_restriction__c)||
                         (s.Opening_Times_Guidebook__c!= olds.Opening_Times_Guidebook__c)||
                         (s.Accessibility__c!= olds.Accessibility__c)||
                         (s.Parking__c!= olds.Parking__c)||
                         (s.Toilet_Facilities__c!= olds.Toilet_Facilities__c)||
                         (s.Price__c!= olds.Price__c)||
                         (s.Refreshments__c!= olds.Refreshments__c)||
                         (s.Known_As__c!=olds.Known_As__c)
                        
                        ) {
                    s.Change_Needs_Approval__c = true;
                    s.Approval_Stage__c='Changes Needs Approval';
                    //s.Display_on_public_website__c = false;
                    if (s.Service_Data_Manager__c ==null) {
                                                            s.Service_Data_Manager__c = updatedBy[0].id;}
                    }
                }
            }
        }
    }
}