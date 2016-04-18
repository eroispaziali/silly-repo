public class DfEventAttendeeController{
 private final DF_Event__c dfevent;
 List<DF_EventAttendee__c> lsteventattendees;
 List<DF_Contact__c> lstdfcons;
 List<Id> conids = new List<Id>();
 //DF_Event__c dfeventnew;
 public DfEventAttendeeController(ApexPages.StandardController stdController){
     this.dfevent= (DF_Event__c)stdController.getRecord();
     //system.debug('@@@@@@@@@@@'+dfevent.Id);
     Id dfeveid = dfevent.Id;
 lsteventattendees = (List<DF_EventAttendee__c>)[Select Id, Name, DF_Contact__c, DF_Event__c, 
                       DF_EventAttendee__c.DF_Contact__r.Status__c,DF_EventAttendee__c.DF_Contact__r.Email__c
                       FROM DF_EventAttendee__c Where DF_Event__c =:dfeveid];
        
  for(DF_EventAttendee__c rec:lsteventattendees){
        conids.add(rec.DF_Contact__c);
  }             
  lstdfcons = [Select Name, Status__c, Email__c, Contact_Number__c, Note__c, Eligible__c, Contacted__c, 
                              Attended__c FROM DF_Contact__c Where DF_Contact__c.Id IN:conids]; 
  lstdfcons.sort();                                                          
  }                                                          
  /* public List<DF_EventAttendee__c> getlsteventattendees(){
     return lsteventattendees;
 } */
 public List<DF_Contact__c> getlstdfcontacts(){
     return lstdfcons;
    }
  public Pagereference save(){
    update lstdfcons;
    return (new ApexPages.StandardController(dfevent)).view();
    //return null;
 }
 public testmethod static void testdfcontroller()
 {
    DF_Contact__c dfcon = new DF_Contact__c(Name='Test dfcontact',First_Name__c='Test',Last_Name__c='dfcontact',Status__c='Prospective',Email__c='test@dfcon.com',
   RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id,
                                            Contact_Number__c='12345678',Eligible__c=FALSE,Contacted__c=FALSE,
                                            Attended__c=FALSE,Note__c='Test Notes');
    insert dfcon;
    DF_Event__c dfeve = new DF_Event__c(Name='dfevent test',
       RecordTypeId=[Select Id from RecordType where SObjectType='DF_Event__c' and Name Like 'Champion Training Course'].Id);
    insert dfeve;
    DF_EventAttendee__c dfeveattnd = new DF_EventAttendee__c(DF_Contact__c=dfcon.Id,DF_Event__c=dfeve.Id);
    ApexPages.currentPage().getParameters().put('id',dfeve.Id);
    DfEventAttendeeController dfcont = new DfEventAttendeeController(new ApexPages.Standardcontroller(dfeve));  
    dfcont.getlstdfcontacts();
    dfcont.save();                                       
  }
}