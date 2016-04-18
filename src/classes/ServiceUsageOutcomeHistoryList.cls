/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Provide history of changes to Service Usage Outcomes related to a Service Usage.
 *  Author  : Mike Tinson
 *  Date    : 31-12-2012
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/
public with sharing class ServiceUsageOutcomeHistoryList {

    public Service_Usage__c su {get; set;}
    public List<Service_Usage_Outcome__c> suo;
    public Contact person {get; set;}
    public List<Service_Usage_Outcome_History__c> suoh;
    /**
    Constructor to get the Service Usage Id from the page and retrieve the following:
        :Service_Usage__c
        :Service_Usage_Outcome__c
    */
    public ServiceUsageOutcomeHistoryList(ApexPages.StandardController controller) {
        su = (Service_Usage__c)controller.getRecord();
        su = (su == null) ? new Service_Usage__c() : [Select s.Name, s.Id, s.Primary_Service_User__c From Service_Usage__c s WHERE id = :su.id];
        suo = (su == null) ? new List<Service_Usage_Outcome__c>() : [Select Name, s.Outcome_No__c, s.Service_Usage__c, 
                                                                    s.Person_Identified_Outcome__c, 
                                                                    s.Outcome_Status__c, s.Date_Outcome_Met__c, s.Date_Identified__c, s.Action__c 
                                                                    From Service_Usage_Outcome__c s where s.Service_Usage__c = :su.Id 
                                                                   ORDER BY Outcome_No__c ASC ];
        suoh  = new List<Service_Usage_Outcome_History__c> (); 
        if (su!= null) {
            
            for (Service_Usage_Outcome__c rec: suo) {
                System.Debug('1111111111111111111111 rec:' + rec.id);
                for (Service_Usage_Outcome_History__c  historyItem : [Select Name, h.Changed_Action__c
                                                                    ,h.Changed_Date_Identified__c
                                                                    ,h.Changed_Date_Outcome_Met__c
                                                                    ,h.Changed_Outcome_Category__c
                                                                    ,h.Changed_Outcome_Status__c
                                                                    ,h.Changed_Person_Identified_Outcome__c
                                                                    ,h.Date__c
                                                                    ,h.NewAction__c
                                                                    ,h.NewDate_Identified__c
                                                                    ,h.NewDate_Outcome_Met__c
                                                                    ,h.NewOutcome_Category__c
                                                                    ,h.NewOutcome_Status__c
                                                                    ,h.NewPerson_Identified_Outcome__c
                                                                    ,h.OldAction__c
                                                                    ,h.OldDate_Identified__c
                                                                    ,h.OldDate_Outcome_Met__c
                                                                    ,h.OldOutcome_Category__c
                                                                    ,h.OldOutcome_Status__c
                                                                    ,h.OldPerson_Identified_Outcome__c
                                                                    ,h.Outcome_No__c
                                                                    ,h.Service_Usage_Outcome__c
                                                                    ,h.User__c
                                                                    ,h.Version__c
                                                                    From Service_Usage_Outcome_History__c h 
                                                                    Where h.Service_Usage_Outcome__c = :rec.id
                                                                    
                                                                    ORDER BY Outcome_No__c, Version__c DESC ]){
                System.Debug('1111111111111111111111 historyItem:' + historyItem.id);
                suoh.add(historyItem); 
            
                }
            }
        }
        
        System.Debug('1111111111111111111111 suoh:' + suoh.size()); 
                                                           
        if(su.Primary_Service_User__c!=null) person = [select id, Client_reference_number__c from Contact where id=:su.Primary_Service_User__c];
    }       

    public List<Service_Usage_Outcome__c> getSuo() {
        return suo;
    }
    
/**    
    public void setSuo(List<Service_Usage_Outcome__c> s) {
        suo = s;
    }
**/
    public List<Service_Usage_Outcome_History__c> getSuoh() {
        return suoh;
    }
    
    public PageReference cancel() {
        return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
    }
    
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
            Contact recCon = new Contact(LastName='TestLastName',FirstName = 'Name1', Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
            insert recCon;        
            Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
            insert accRec;
            Services__c serv = new Services__c(Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false);//Name='testControllerService');
            insert serv;    

            Service_Usage__c recSU = new Service_Usage__c(Service_Field__c= serv.id, Primary_Service_User__c=recCon.id,Service_Type__c='Advocacy');    
            insert recSU;
            Service_Usage_Outcome__c recSUO = new Service_Usage_Outcome__c(Person_Identified_Outcome__c='some text1', Service_Usage__c=recSU.id, Date_Identified__c=Date.Today());    
            List<Service_Usage_Outcome__c> outcomeList = new List<Service_Usage_Outcome__c>();
            outcomeList.add(recSUO);
            insert outcomeList;
            
            //Create instance of the class to test and initialise the list 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(recSU);
            ServiceUsageOutcomeHistoryList suol = new ServiceUsageOutcomeHistoryList(stdCon );
            suol.getSUo();
            
            //test case
            System.assertNotEquals(suol.getSuo(), null);
            System.assertNotEquals(suol.getSUoH(),null);
            System.assertNotEquals(suol.cancel(), null);
      }
}