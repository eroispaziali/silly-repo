@isTest
 /***********************************************************************************************
     * @author          Lakshmi Rajendram 
     * @date            02-03-2015
     * @description     A set of utility methods that creates a full set of Test Data for testing 
                        Dementia Connect application components. The method returns a Map of Maps
                        with a full set of records for each component of the application
***********************************************************************************************/


public class TestDataFactory_Services {
    static testMethod void TestDataCreation()
    {
        
        Map<String, Object> mapTestData= TestDataFactory_Services.getTestData();
        DF_Contact__c DFc = (DF_Contact__c)mapTestData.get('DFc');
        //DF_Contact__c DFc = (DF_Contact__c)mapDFc.get('DFc');  
        
     
    }
    
    
    public static map<String,Object> getTestData(){
        
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Account exAcc = new Account(Name='Test External',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id);
    insert exAcc;
    Contact c = new Contact();
        c.firstname = 'Test';
        c.LastName = 'TestContact';
        c.AccountId = exAcc.Id;
        c.Email = 'test.testcontact@myemail.com';
        c.title='Mr';
        c.RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and DeveloperName ='Other'].Id;
    insert c;      
         
    Services__c sInt = new Services__c(Display_on_public_website__c=True,Name='Midlands Central Advocacy', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false,RecordTypeId=[Select Id from RecordType where SObjectType='Services__c' and DeveloperName ='Internal'].Id);//Name='testControllerService');
    insert sInt;
    Services__c sExt = new Services__c(Name='Midlands Central Advocacy',service_street__c= 'test the street name long ass string first more than 80 character for testing the', Locality__c=accRec.id,Service_Type__c='Advocacy', National_Service__c=false,RecordTypeId=[Select Id from RecordType where SObjectType='Services__c' and DeveloperName ='External'].Id);
    insert sExt;
    External_Contacts__c  exContact= new External_Contacts__c(Contact_Type__c='Public Contact',External_Service__c=sExt.id,Related_Contact__c=c.id);
    insert exContact;
    
      Map<String, Object> mapMisc = new Map<String,Object>();    
        
        
        
        
        mapMisc.put('sInt',sInt);
        mapMisc.put('sExt',sExt);
        mapMisc.put('Contact',c);
        mapMisc.put('exContact',exContact);
        return mapMisc;   
   }
   
   }