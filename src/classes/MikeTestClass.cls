public class MikeTestClass {
// test class
public MikeTestClass(){
Set<String> s1 = new Set<String>{'a', 'b + c'};
Set<String> setEventNumbers = new Set<String>{'E-0000124606', 'E-0000124570'};

String sqlStr = 'Select Service_Usage__c,EventAttendeeId__c, Contact__c,EventNumber__c,EventId__c from Event_Attendance_Details__c where EventNumber__c IN :setEventNumbers ';
system.debug('#############sqlStr##############'+sqlStr);
List<Event_Attendance_Details__c> mtest = Database.query(sqlStr);
system.debug('#############sqlStr##############'+mtest.size());
}
//    
// TEST CASE    
//    
private static testMethod void testMikeTestClass() 
{
// Create the standard controller for the service
//   Contact c1 = new Contact(FirstName='one', LastName='related');    
//    insert c1; 
    
//    Services__c service = new Services__c(Name='Test service');
//    insert service;      
}
}