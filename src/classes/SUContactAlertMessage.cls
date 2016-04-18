public class SUContactAlertMessage
{
public Service_Usage__c recSU {get;set;}
public Contact person {get; set;}


public SUContactAlertMessage(ApexPages.StandardController controller) {
    this();
}
public SUContactAlertMessage()
{
    if(ApexPages.currentPage().getParameters().get('id')!=null)
    {
    //recSU = (Service_Usage__c)controller.getRecord();
    getPersonDetails();
    
    }
}
public Contact getPersonDetails(){
        //get the person Id
        Service_Usage__c tempSU = [select id, Primary_Service_User__c from Service_Usage__c where id=:ApexPages.currentPage().getParameters().get('id')];
        if(tempSU.Primary_Service_User__c!=null) person = [select id, rrpu__Alert_Message__c from Contact where id=:tempSU.Primary_Service_User__c];
        return person;
    }

public testMethod static void testController()
{
    Contact recCon = new Contact(FirstName = 'Albert', LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
    insert recCon;
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
    insert serv;    
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    
    insert recSU;
    ApexPages.currentPage().getParameters().put('id', recSU.id);  
    SUContactAlertMessage conCls= new SUContactAlertMessage(new ApexPages.StandardController(recSU));

}
}