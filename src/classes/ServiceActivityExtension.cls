public class ServiceActivityExtension {

/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Select record type for Event/Task.
 *  Author  : Fujitsu - Nupoor Pandey
 *  Date    : 2012-02-07
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
    
    public Services__c sa {get; private set;}
    //public List<Service_Usage_Outcome__c> suo;

    /**
        Constructor to get the Service Activity Id from the page and retrieve the following:
        :Services__c
    */
    public ServiceActivityExtension(ApexPages.StandardController controller) {
        Id id = ApexPages.currentPage().getParameters().get('id');
        sa = (id == null) ? new Services__c() : [Select s.Name, s.Id, s.service_type__c From Services__c s WHERE id = :id];
    }   
    
    /**public PageReference assignEventRecordType() {
        String recordTypeName;
        RecordType rt;
        if(sa.Service_Type__c=='Awareness raising'){
            recordTypeName = 'Awareness Raising Event';
        }else if(sa.Service_Type__c=='Activity group'){
            recordTypeName = 'CRS Group Event';
        }else{
            return new PageReference('/apex/Event_Error');
        }
        rt = [Select Id, Name from RecordType where IsActive=true and SobjectType='Event' and Name = :recordTypeName];
        return new PageReference('/00U/e?what_id='+sa.id+'&retURL=%2F'+sa.id+'&RecordType='+rt.Id+'&ent=Event');
    }*/
    
    public PageReference cancel() {
        return new PageReference('/'+sa.Id);

}
//
// TEST CASE
//
  private static testMethod void testServiceActivityExtension() {
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c service = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
    insert service;    
    
    //Services__c service = new Services__c(Name='Test service');
    
    ApexPages.StandardController stdCon = new ApexPages.StandardController(service);        
    
        
    ServiceActivityExtension sae = new ServiceActivityExtension(stdCon);
    sae.sa = service;
        
    sae.cancel();    
    }
}