/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Select record type for Event/Task.
 *  Author  : Fujitsu - Nupoor Pandey
 *  Date    : 2012-02-06
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *
 *  Description: Class to select record type for Event/Task. 
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/
public class ServiceUsageExtension {
    
    public Service_Usage__c su {get; private set;}
    //public List<Service_Usage_Outcome__c> suo;

    /**
    Constructor to get the Service Usage Id from the page and retrieve the following:
        :Service_Usage__c
    */
    public ServiceUsageExtension(ApexPages.StandardController controller) {
        Id id = ApexPages.currentPage().getParameters().get('id');
        su = (id == null) ? new Service_Usage__c() : [Select s.Name, s.Id, s.service_type__c From Service_Usage__c s WHERE id = :id];
        assignEventRecordType();
    }   
    
    public PageReference assignEventRecordType() {
        String recordTypeName;
        RecordType rt;
        if(su.Service_Type__c=='Dementia support'){
            recordTypeName = 'CRS Individual Event';
        }else{
            recordTypeName = 'CRS Group Event';
        }
        rt = [Select Id, Name from RecordType where IsActive=true and SobjectType='Event' and Name = :recordTypeName];
        return new PageReference('/00U/e?what_id='+su.id+'&retURL=%2F'+su.id+'&RecordType='+rt.Id+'&ent=Event');
    }
//
// TEST CASE
//
  private static testMethod void testServiceUsageExtension() {
        Contact recCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),            
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
        insert recCon;

        Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
        insert accRec;
        Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
        insert serv;    

        Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id,Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');
        insert recSU;
        
            
    ApexPages.StandardController stdCon = new ApexPages.StandardController(recSU);        
    ServiceUsageExtension sue = new ServiceUsageExtension(stdCon);
    sue.su = recSU;
    
    sue.assignEventRecordType();    

    recSU.Service_Type__c='Advocacy'; //test case was Dementia support
    upsert recSU;
    ApexPages.StandardController stdCon2 = new ApexPages.StandardController(recSU);        
    ServiceUsageExtension sue2 = new ServiceUsageExtension(stdCon2);
    sue2.su = recSU;
    sue2.assignEventRecordType();    
    }
    
}