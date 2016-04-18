@isTest
public class ContactTriggerHandler_Test {
 
   
    static testMethod void testContactTriggerHandler() {
   
     Contact c1 = new Contact(FirstName='one', LastName='test',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
        rrpu__Alert_Message__c='test',
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);    
    insert c1;
    Contact c2 = new Contact(FirstName='two', LastName='test2',MailingPostalCode ='ABC123', Birthdate =Date.Today().addyears(-1),
        MailingCity='Abcd', MailingCountry='Abcd', MailingState='Abcd', MailingStreet='Abcd',
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and DeveloperName = 'Professional'].id);    
    insert c2;
     Contact c3 = new Contact(FirstName='three', LastName='test3',MailingPostalCode ='ABCD123',MailingStreet= 'test the street name long ass string first more than 80 character for testing the', Birthdate=System.today(),RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and DeveloperName = 'Person_with_dementia'].id);
        insert c3;
            
       
        c3= [SELECT AccountId,MailingStreet,Street_Line_1__c, Street_Line_2__c,Street_Line_3__c,Street_Line_4__c  FROM Contact WHERE Id =:c3.Id Limit 1];
        
        System.assertEquals(c3.Street_Line_1__c,'test the street name long ass string first more than 80 character for testing th');
        System.assertEquals(c3.Street_Line_2__c,'e');
        System.assertEquals(c3.Street_Line_3__c,null);
        System.assertEquals(c3.Street_Line_4__c,null);
       
        
        c3.MailingStreet = 'test with three\nline address this\nis street address\nthis is street address 3';
        update c3;                        
        c3.MailingStreet = 'test with two\nline address this\nis shipping address on when second line is overshot the length by 80 or more characters on the third line of the address\nfourth line';
        update c3;
        c3.MailingStreet = 'test with two\nis shipping address on when second line is overshot the length by 80 or more characters on the third line of the addressline address this\n\nfourth line';
        update c3;
        c3.MailingStreet = 'test the street name less than 80 character\n111111111122222222223333333333444444444455555555556666666666777777777788888888889\nthird line\nfourth line';
        update c3;
        c3.MailingStreet ='test the street name less than 80 character\nsecond line\nthird line 11111111112222222222333333333344444444445555555555666666666677777777778888888888\nfourth line';
        update c3;
        c3.MailingStreet ='test the street name less than 80 character\nsecond line\nthird line\nfourth line 1111111111222222222233333333334444444444555555555566666666667777777';
        update c3;
        c3.MailingStreet ='test the street name less than 80 character\nsecond line\nthird line\nfourth line' ;
        update c3;
        
      
       
    c1.Lastname='test2';
    update c1;
    c1.MailingCity='Abcd';
    c1.MailingCountry='Abcd';
    c1.MailingState='Abcd';
    c1.MailingStreet='Abcd';
    update c1;
   
    c1.Lastname='test3';
    c1.MailingStreet='Abcde';
    c1.MailingCity='Abcde';
    c1.BirthDate=Date.Today().addyears(-10);
    c1.Service_user_aware_of_diagnosis__c=true;
    c1.Specialist_Communication_Needs__c='abcde';
    c1.Diagnosis_made_by__c = c2.id;
    c1.Date_of_Diagnosis__c = Date.Today().addmonths(-9);
    c1.Diagnosis__c = 'Dementia with Lewy bodies';
    c1.Firstname='newadcd';
    c1.Consent_Status__c='Awaiting Consent';
    c1.Database_consent_Date__c=Date.Today().Addmonths(-4);
    c1.Date_of_Change_of_Living_Arrangements__c=Date.Today().Addmonths(-4);
    c1.Key_Health_Issues__c ='Hearing impairment';
    c1.Power_of_attorney_established__c=true;
    c1.Consent_Status__c='Withdrawn';
    update c1;
    c1.Consent_Status__c='Awaiting Consent';
    c1.rrpu__Alert_Message__c = '';
    c1.DoNotCall = true;
    update c1;

    
    c1.Deceased__c = true;
    c1.Deceased_Date__c = Date.Today().adddays(-3);
    update c1;
    
    delete c1;
    }
 

}