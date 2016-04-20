@isTest
public class TestServiceUsageOwnerReassignment {

static testMethod void mainTest(){
User U1 = [select id, name from User where Profile.Name='CRS' and UserRole.Name like 'Dementia Adviser & Dementia Support - North West London%'  and IsActive=true LIMIT 1];
User U2 = [select id, name from User where Profile.Name='CRS' and UserRole.Name like 'Dementia Adviser & Dementia Support - North West London%' and IsActive=true AND id!=:u1.id LIMIT 1];
      

Contact recCon = new Contact(FirstName = 'Albert', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
insert recCon;  

Account accRec = new Account(Name='North West London Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
insert accRec;
Services__c serv = new Services__c(Name='North West London DS test', Locality__c=accRec.id,Service_Type__c='Dementia support', National_Service__c=false);//Name='testControllerService');
insert serv;    
Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Dementia support', ownerid=u1.id, RecordTypeId=[
        select id from RecordType where SobjectType = 'Service_usage__c' and DeveloperName='Dementia_Support_Service_Usage'].id);    
    
insert recSU;

Test.StartTest();

String query = 'select  id, name, ownerid, Assigned_Worker__c from Service_usage__c where service_field__c = \'' + recSU.id+ '\' and ownerid = \'' + u1.id + '\'' + ' and closure_reason__c =null  and Service_User_Deceased__c = \'FALSE\'';
ServiceUsageOwnerReassignment reassign = new ServiceUsageOwnerReassignment();
reassign.query= query;
reassign.email='crssupport@alzheimers.org.uk';
reassign.fromUserId = u1.id;
reassign.toUserId = u2.id;
ID batchprocessid = Database.executeBatch(reassign);
Test.StopTest();

//System.AssertEquals(
//           database.countquery('SELECT COUNT()'
//              +' FROM Service_Usage__c WHERE OwnerId=\'' + u2.Id + '\' and id=\''+recSU.id + '\''),
//           1);  
}           


}