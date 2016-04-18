@isTest
public with sharing class TEST_zzServiceUsageCopyTriggerHandler  {

    static testMethod void testzzServiceUsageCopyTriggerHandler(){
              
        zzService_Usage_Copy__c[] suToCreate = new zzService_Usage_Copy__c[]{};
        
        for(Integer i=0; i< 100; i++){
            zzService_Usage_Copy__c s = new zzService_Usage_Copy__c(Assessed_for_benefits__c = false,
										Benefits_received__c = 'Blue badge',
										Closure_Date__c = Date.today(),
										Closure_Reason__c = 'Temporary Suspension',
										Date_Assessment_Commenced__c = Date.today(),
										Referral_Assessment_Date__c = Date.today(),
										Date_of_last_Activity__c = Date.today(),
										Date_Referral_Acknowledged__c = Date.today(),
										Date_Service_User_Contacted__c = Date.today(),
										Referral_Acknowledged__c = false,
										Funding_Arrangement__c = 'Self Funder',
										Has_Cognitive_Enhancer_been_Prescribed__c = 'Yes',
										How_Referrer_Heard_of_the_Service__c = 'Other',
										If_yes_which_Enhancer__c = 'Test',
										Known_Risks__c = 'Test',
										Location_of_Paper_File__c = 'Test',
										Next_Review_Date__c = Date.today(),
										Other_How_referrer_heard_of_the_service__c = 'Test',
										Other_benefits__c = 'Test',
										Other_Type_of_Referrer__c = 'Test',
										Priority__c = 'High',
										Public_Alert_Message_Required__c = false,
										Reason_for_Referral__c = 'Test',
										Referral_Date__c = Date.today(),
										Referral_Outcome__c = 'Case Opened',
										Referral_Source__c = 'Internal Referral',
										Referral_Type__c = 'Phonecall',
										Residence_Access_Details__c = 'Test',
										Risk_Identified__c = true,
										Service_Type__c = 'Activity group',
										Service_Usage_Notes__c = 'Test',
										Service_User_Aware_of_Referral__c = 'Yes',
										Service_User_Deceased__c = 'Test',
										Share_with_colleagues__c = false,
										Type_of_Paper_File__c = 'Active',
										Updated__c = true                       
                                        );
            suToCreate.add(s);
        }
        
        //Now insert data causing the zzService_Usage_Copy trigger to fire. 
        Test.startTest();
        insert suToCreate;
        Test.stopTest();        
    }   

}