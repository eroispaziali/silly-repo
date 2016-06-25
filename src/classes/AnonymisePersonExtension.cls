/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Anonymise a person. Delete Contact History.
 *  Author  : Fujitsu - Nupoor Pandey
 *  Date    : 2012-02-07
 *  Version : 0.1 Unit Tested
 *  Project : CRSProto
 *
 *  Description: Class to anonymise a contact. 
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  20130403    MT    Check that all service usages are not active.
 *                             
*******************************************************************************************/
public with sharing class Anonymise_PersonExtension {
    
    public Contact person {get; private set;}
    public boolean consent {get; private set;}
    private List<Contact_History__c> contactHistory; 
    public String diagnosis {get; private set;}
    public boolean isError {get; private set;}
    private boolean ActiveServiceUsage;
    private List<Service_Usage__c> lstServUsage;
    /**
    Constructor to get the Contact Id from the page and retrieve the following:
        :Contact
    */
    public AnonymisePersonExtension() {
        Id id = ApexPages.currentPage().getParameters().get('id');
        person = (id == null) ? new Contact() : 
            [Select c.Specialist_Communication_Needs__c, c.Social_Service_Ref_No__c, c.Service_user_aware_of_diagnosis__c, 
            c.Salutation, c.Preferred_means_of_contact__c, c.PoA_Notes__c, c.Other_Demographic_Details__c, c.OtherStreet, 
            c.OtherState, c.OtherPhone, c.OtherCountry, c.OtherCity, c.MobilePhone, c.Means_of_first_contact__c, c.Diagnosis__c, 
            c.MailingStreet, c.MailingState, c.MailingCountry, c.MailingCity, c.LastName, c.Known_as__c, c.Id, c.HomePhone, 
            c.First_language__c, c.FirstName, c.Email, c.Key_Health_Issues__c,  
            c.Diagnosis_made_by__c, c.Diagnosis_Details__c, 
            c.Date_of_diagnosis__c, c.Consent_Status__c, c.Brief_Outline_of_Personal_History__c, c.Approximate_date_of_diagnosis__c, 
            c.Advance_Directives__c, c.Additional_Health_Information__c, c.rrpu__Alert_Message__c, c.Phone From Contact c WHERE id = :id];
            
            contactHistory = new List<Contact_History__c>();
            System.debug('111111111111111111111111111111111 person.Consent_Status__c: '+person.Consent_Status__c);
            isError=false;
    }
    public PageReference AutoRunAnonymisePerson(){            
            //for page rendering
            if ((person==null || person.Consent_Status__c=='Awaiting Consent' || person.Consent_Status__c=='None' || 
                        person.Consent_Status__c=='' || person.Consent_Status__c==null)==false){
                        
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'This person cannot be anonymised as the consent status is not \'Awaiting Consent\' or \'None\'');
                ApexPages.addMessage(message);
                isError = true;  
                return null;             
                }
           //check for ALL Service Usages with a referral outcome of either "service declined" or "service inappropriate" or "person ineligible for service"
           List<Service_Usage__c> lstServUsage = [Select Id, Name,Referral_Outcome__c from Service_Usage__c where Primary_Service_User__c=:person.id];
           for(Service_Usage__c rec: lstServUsage){
               System.debug('#############id:'+rec.id + ' ' + rec.name);
               System.debug('#############outcome:' + rec.Referral_Outcome__c);
               if ((rec.Referral_Outcome__c ==null || rec.Referral_Outcome__c =='' ||
                   rec.Referral_Outcome__c =='Not Eligible (Referred on)' ||
                   rec.Referral_Outcome__c =='Not Eligible (No further action)' || 
                   rec.Referral_Outcome__c =='Service Declined (Referred on)' || 
                   rec.Referral_Outcome__c =='Service Declined (No further action)' || 
                   rec.Referral_Outcome__c =='Not Interested')==false) { 
                   ActiveServiceUsage= true;
                   if (ActiveServiceUsage==true){
                          ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'This person cannot be anonymised.  There are service usages that have a Referral Outcome that is not  \'Service Declined...\', \'Not Eligible...\', \'Not Interested...\'.');
                          ApexPages.addMessage(message);
                          isError = true;
                          return null;  
               }
            }
        }
    return null;  
    }
    
    public void emptyMethod() {}
    
    /**
        Method to delete the details of the contact record.
    */
    public PageReference AnonymisePerson() {
        Id thisUserId;
        Integer count;
        thisUserId = UserInfo.getUserId();

        //delete contact details
        if(person.Consent_Status__c!='Awaiting Consent' && person.Consent_Status__c!='None' && person.Consent_Status__c!=null){
            System.debug('222222222222222222222222222222222 person.Consent_Status__c: '+person.Consent_Status__c);
            return new PageReference('/'+person.Id);
        }
        // Create a savepoint because the data should not be committed to the database
        Savepoint sp = Database.setSavepoint();
        boolean hasDMLExceptionRaised=false;
        Exception exToPass;

        try{
            person.Specialist_Communication_Needs__c = '';
            person.Social_Service_Ref_No__c = '';
            person.Service_user_aware_of_diagnosis__c = false;
            person.Salutation = '';
            person.Preferred_means_of_contact__c = '';
            person.PoA_Notes__c = '';
            person.Other_Demographic_Details__c = '';
            person.OtherStreet = '';
            person.OtherState = '';
            person.OtherPhone = '';
            person.OtherCountry = '';
            person.OtherCity = '';
            person.OtherPostalCode='';
            person.MobilePhone = '';
            person.Means_of_first_contact__c = '';
            person.MailingStreet = '';
            person.MailingState = '';
            person.MailingCountry = '';
            person.MailingCity = '';
            person.MailingPostalCode='';
            person.LastName = '*****';
            person.Known_as__c = '';
            person.HomePhone = '';
            person.First_language__c = '';
            person.FirstName = '*****';
            person.Email = '';
            person.Key_Health_Issues__c = '';
            person.Diagnosis_made_by__c = null;
            diagnosis = person.Diagnosis__c;
            if (diagnosis!=null && diagnosis!='' && diagnosis.contains('Other')) 
                person.Diagnosis_Details__c = '*****';
            else 
                person.Diagnosis_Details__c = '';   
            person.Date_of_diagnosis__c = Date.today();
            person.Consent_Status__c = '';
            person.Brief_Outline_of_Personal_History__c = '';
            person.Approximate_date_of_diagnosis__c = false;
            person.Advance_Directives__c = '';
            person.Additional_Health_Information__c = '';
            person.Phone = '';
            if(person.DoNotCall) person.rrpu__Alert_Message__c = '******'; else person.rrpu__Alert_Message__c = '';
            
            update person;
            
            //remove the contact details from contct history as well
            contactHistory = [Select c.OwnerId, c.Specialist_Communication_Needs__c, c.Service_User_aware_of_diagnosis__c, c.Name, c.Mailing_Address__c, 
                                c.Lastname__c, c.Id, c.Firstname__c, c.Diagnosis_made_by__c, c.Diagnosis__c, c.Date_of_Diagnosis__c, 
                                c.Contact_History__c, c.Alert_Message__c From Contact_History__c c 
                                where Contact_History__c = :person.Id];
            //update owner of contact history records
            count = 0;
            List<Contact_History__c> chToUpdate = new List<Contact_History__c>();
            for(Contact_History__c ch : contactHistory ){
                if(ch.OwnerId!= thisUserId){
                     ch.OwnerId = thisUserId;
                     chToUpdate.add(ch);
                     count++;
                                          }   
            
            }
            if (count>0){
                system.debug('##########records to be updated ##########' + count);
                update chToUpdate;
                }
            delete contactHistory;
            
        }catch(Exception ex){exToPass=ex;hasDMLExceptionRaised=true;}
      // Revert the database to the original state on Exception
      if(hasDMLExceptionRaised)
      {
        Database.rollback(sp);      
        ApexPages.addMessages(exToPass);

        ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, 'Contact The CRS Helpdesk.');
        ApexPages.addMessage(message);
        return null;  
      }  
      return new PageReference('/'+person.Id);
    }
    
    public PageReference cancel() {
        return new PageReference('/'+person.Id);
    }
    
    /**
      Test case coverage = 100%
      */
      public testMethod static void testController(){
            //Initialise
            Contact recCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='TestLastName',Deceased__c=false,MailingPostalCode ='ABC123', Birthdate =Date.Today(),
            RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and Name Like 'Person with dementia'].id);
            insert recCon;        
            
            //Create instance of the class to test and initialise the list 
            ApexPages.currentPage().getParameters().put('id', recCon.id);  
            AnonymisePersonExtension ext= new AnonymisePersonExtension();
            ext.AutoRunAnonymisePerson();
            //ext.setSuo(outcomeList);
            
            //test case
            System.assertNotEquals(ext.AnonymisePerson(), null);
            System.assertNotEquals(ext.cancel(), null);
      }
}
