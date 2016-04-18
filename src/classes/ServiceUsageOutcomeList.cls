/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Provide a screen with a list of all the Service Usage Outcomes related to a Service Usage.
 *  Author  : Fujitsu - Nupoor Pandey
 *  Date    : 2012-02-02
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *
 *  Description: Class with public method to retrive list of Service_Usage_Outcome__c for a Service_Usage__c. 
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  08/09/2014 - Lakshmi Rajendram-   Included completed outcomes 
 *                             
*******************************************************************************************/
public with sharing class ServiceUsageOutcomeList {

    public Service_Usage__c su {get; set;}
    public List<Service_Usage_Outcome__c> suo;
     public List<Service_Usage_Outcome__c> suoo;
    public Contact person {get; set;}

    /**
    Constructor to get the Service Usage Id from the page and retrieve the following:
        :Service_Usage__c
        :Service_Usage_Outcome__c
    */
    public ServiceUsageOutcomeList(ApexPages.StandardController controller) {
        su = (Service_Usage__c)controller.getRecord();
        su = (su == null) ? new Service_Usage__c() : [Select s.Name, s.Id, s.Primary_Service_User__c From Service_Usage__c s WHERE id = :su.id];
        suo = (su == null) ? new List<Service_Usage_Outcome__c>() : [Select Name, s.Outcome_No__c, s.Service_Usage__c, s.Person_Identified_Outcome__c, 
                                                                    s.Outcome_Status__c, s.Date_Outcome_Met__c, s.Date_Identified__c, s.Action__c 
                                                                    From Service_Usage_Outcome__c s where s.Service_Usage__c = :su.Id 
                                                                    ORDER BY Outcome_No__c ASC ];
        suoo =(su == null)?new List<Service_Usage_Outcome__c>():     [Select Name, s.Outcome_No__c, s.Service_Usage__c, s.Person_Identified_Outcome__c, 
                                                                    s.Outcome_Status__c, s.Date_Outcome_Met__c, s.Date_Identified__c, s.Action__c 
                                                                    From Service_Usage_Outcome__c s where s.Service_Usage__c = :su.Id AND s.Outcome_Status__c='Ongoing'
                                                                    ORDER BY Outcome_No__c ASC ];  
                                                           
        if(su.Primary_Service_User__c!=null) person = [select id, Client_reference_number__c from Contact where id=:su.Primary_Service_User__c];
    }       

    public List<Service_Usage_Outcome__c> getSuo() {
        return suo;
    }
      public List<Service_Usage_Outcome__c> getSuoo() {
        return suoo;
    }
    
/**    
    public void setSuo(List<Service_Usage_Outcome__c> s) {
        suo = s;
    }
**/
/**    
    public PageReference cancel() {
        return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
    }
**/    
    /**
    Do Not Delete: Code for mass upload of Service_Usage_Outcome__c  
    */
      /**public List<WrapperQueAns> lstQueAns = new List<WrapperQueAns>{};
      public List<WrapperQueAns> propLstQuesAns { get { return lstQueAns; } set { lstQueAns = value; } }
                                                  
      Public ServiceUsageOutcomeList(){
           WrapperQueAns wqa = new WrapperQueAns();
           //wqa.propAns = '';
           wqa.suo = new Service_Usage_Outcome__c ();
           lstQueAns.add(wqa);
      }

      public void DynamicRow(){
           for(Integer i=0;i<1;i++){
                WrapperQueAns wqa = new WrapperQueAns();
                //wqa.propAns    = '';
                wqa.suo = new Service_Usage_Outcome__c ();
                lstQueAns.add(wqa);
           }
      }
      public class WrapperQueAns{
           //public String propAns { get; set; }
           public Service_Usage_Outcome__c suo {get; set; } 
      }//End Class WrapperQueAns
      
      public void saveList(){
           List<Service_Usage_Outcome__c> suoList = new List<Service_Usage_Outcome__c>();
           //System.debug('here is the propLstQuesAns list:' + propLstQuesAns);
           //System.debug('here is the lstQueAns list:' + lstQueAns);
           for(WrapperQueAns wq:propLstQuesAns){
                System.debug('here is the wq.suo:' + wq.suo);
                suoList.add(wq.suo);
           }
           System.debug('here is the suoList list:' + suoList);
           upsert suoList;
      }**/
      
      /**
      Test case coverage = 100%
      */
      public testMethod static void testController(){
            //Initialise
            Contact recCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
            insert recCon;        
            Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
            insert accRec;
            Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
            insert serv;    
            Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    
            insert recSU;
            Service_Usage_Outcome__c recSUO = new Service_Usage_Outcome__c(Person_Identified_Outcome__c='some text1', Service_Usage__c=recSU.id, Date_Identified__c=Date.Today());    
            //List<Service_Usage_Outcome__c> outcomeList = new List<Service_Usage_Outcome__c>();
            //outcomeList.add(recSUO);
            //insert outcomeList;
            insert recSUO;
            recSUO.Person_Identified_Outcome__c='some updated text1';
            recSUO.Action__c = 'new text';
            recSUO.Date_Outcome_Met__c = Date.Today();
            recSUO.Date_Identified__c = Date.Today().addDays(-7);
            update recSUO;
            
            //Create instance of the class to test and initialise the list
            //CreateRelationshipController cnt = new CreateRelationshipController();
            //ServiceUsageOutcomeList SUOList= new ServiceUsageOutcomeList(recSU);
            //SUOList.setSuo(outcomeList);
            //ApexPages.StandardController stdCon = new ApexPages.StandardController(SUOList);
            //ServiceUsageOutcomeList cnt = new QuickEntryTaskPersonController(stdCon);
            PageReference pageRef = Page.ServiceUsageOutcomeListView;
            test.setCurrentPage(pageRef);
            // Now create the standard controller for the SU
            ApexPages.StandardController stdCon = new ApexPages.StandardController(recSU);
            ServiceUsageOutcomeList  suol = new ServiceUsageOutcomeList(stdCon );
            suol.getSUo();

            /**ApexPages.currentPage().getParameters().put('id', recSU.id);  
            ServiceUsageOutcomeList SUOList= new ServiceUsageOutcomeList(recSU);
            SUOList.setSuo(outcomeList);
            
            //test case
            System.assertNotEquals(SUOList.getSuo(), null);
            System.assertNotEquals(SUOList.cancel(), null);**/
      }
}