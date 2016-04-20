@isTest
public with sharing class TestUserTriggerHandler{
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for DF_EventTriggerHandler Trigger.
 *  Author  : Mike Tinson
 *  Date    : 13-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class to test UserTriggerHandler trigger on the User object. 
 *               
 *  Modification History
 *
 *  Date            Who     Description 
 *  dd-mm-yyyy      ??      ??
 *                             
*******************************************************************************************/

    static testMethod void testInsert(){
        Profile AdminProfile=[select id from Profile where name ='System Administrator' LIMIT 1];
        User SystemAdmin  = [select id, ProfileId, name from User where ProfileId =:AdminProfile.Id and isActive=true LIMIT 1];
        System.debug('****** SystemAdmin ****' + SystemAdmin.Name);
        System.RunAs(SystemAdmin){
            Profile  UProfile=[select id from Profile where name='CRS - One App User' Limit 1];
            UserRole URole = [select id from UserRole where name = 'IT' Limit 1];
            User existingUser = [select id, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey,UserRoleId, ProfileId, LanguageLocaleKey 
                                    from User where isactive=true LIMIT 1];
            User u1 = new User(
                                UserRoleId = existingUser.UserRoleId,
                                ProfileId= existingUser.ProfileId,
                                TimeZoneSidKey= existingUser.TimeZoneSidKey,
                                LocaleSidKey= existingUser.LocaleSidKey,
                                EmailEncodingKey= existingUser.EmailEncodingKey,
                                LanguageLocaleKey = existingUser.LanguageLocaleKey, 
                                FirstName='Test', 
                                LastName='Test', 
                                Username='test.apextest@alzheimers.org.uk',
                                email='test.apextest@alzheimers.org.uk',
                                alias='tstApx',
                                CommunityNickname='test.apextest');
            Test.startTest();
            insert u1;
            u1.LastName='Test2';
            update u1;
            Test.stopTest(); 
        }
    } 
}