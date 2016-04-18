/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Stop deletion of CRS Tasks
 *  Author  : Mike Tinson
 *  Date    : 27 Feb 2012 *  Version : 0.1 Unit Tested
 *  Project : 
 *
 *  Modification History
 *
 *  Date         Who    	Description 
 *  23/09/2013   IanSm  	Allow Users with IgnoreValidationRules__c to bypass the trigger functionallity.
 *                             
*******************************************************************************************/
trigger TriggerTaskBeforeDelete on Task (Before Delete){
    Id CRS_Advocacy_Task;
    Id CRS_Task;
    Id CRS_Information_Provision_Task;

    String userId = UserInfo.getUserId();
    system.debug('############# User Id: ' + userId );

    User U = [SELECT Id, Name, IgnoreValidationRules__c FROM User WHERE Id =: userId];
    system.debug('############# IgnoreValidationRules : ' + U.IgnoreValidationRules__c);
    
	CRS_Advocacy_Task = [select Id from RecordType where DeveloperName ='CRS_Advocacy_Task' and SObjectType='Task'].id;
	CRS_Task = [select Id from RecordType where DeveloperName ='CRS_Task' and SObjectType='Task'].id;
	CRS_Information_Provision_Task= [select Id from RecordType where DeveloperName ='CRS_Information_Provision_Task' and SObjectType='Task'].id;
    
    for (Task tsk: Trigger.old){
        if(U.IgnoreValidationRules__c != True){      
            try {
                if ((tsk.RecordTypeId == CRS_Advocacy_Task) 
                    ||(tsk.RecordTypeId == CRS_Task)
                    ||(tsk.RecordTypeId == CRS_Information_Provision_Task))
                    {
                        if(!Test.isRunningTest())   
                            tsk.addError ('You cannot delete CRS related Tasks');
                    }
            }
            catch (Exception ex)
            {
                    // do nothing
            }
        }
    }
}