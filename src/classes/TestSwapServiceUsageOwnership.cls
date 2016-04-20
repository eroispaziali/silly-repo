@isTest
public class TestSwapServiceUsageOwnership{

static testMethod void mainTest(){
User U1 = [select id, name from User where Profile.Name='CRS' and UserRole.Name like 'Dementia Adviser & Dementia Support - North West London%'  and IsActive=true LIMIT 1];
User U2 = [select id, name from User where Profile.Name='CRS' and UserRole.Name like 'Dementia Adviser & Dementia Support - North West London%' and IsActive=true AND id!=:u1.id LIMIT 1];
      
System.debug ('###############u1###########'+u1.name);
System.debug ('###############u2###########'+u2.name);

Contact recCon = new Contact(FirstName = 'Albert', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
insert recCon;  

Account accRec = new Account(Name='North West London Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
insert accRec;
Services__c serv = new Services__c(Name='North West London DS test', Locality__c=accRec.id,Service_Type__c='Dementia support', National_Service__c=false);//Name='testControllerService');
insert serv;    
Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Dementia support');
    
insert recSU;
recSU.ownerid = u1.id;
recSU.closure_reason__c = null;
update recSU;

    ApexPages.currentPage().getParameters().put('id', recSU.id);  
    SwapServiceUsageOwnership conCls= new SwapServiceUsageOwnership(new ApexPages.StandardController(recSU));
Test.StartTest();
    conCls.Find();
    //this not a user id
    conCls.fromSU.ownerid=recSU.id;
    conCls.toSU.ownerid=U2.id;
    conCls.Find();
    //now find using correct id
    conCls.fromSU.ownerid=recSU.ownerid;
    conCls.Find();
    //cause error message one or more services must be selected.
    conCls.submit(); 
    //select all services and submit
    For (SwapServiceUsageOwnership.ServiceCountWrapper SWp : conCls.ServiceWp){
        SWp.isSelected=true;}
    conCls.submit();
    conCls.Cancel();
Test.StopTest();
}

}