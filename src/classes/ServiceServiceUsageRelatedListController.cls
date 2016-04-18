/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Apex Controller for ServiceServiceUsage RelatedList VF page.
 *  Author  : Mike Tinson
 *  Date    : 27 November 2012
 *                             
*******************************************************************************************/
public class  ServiceServiceUsageRelatedListController
{

public ApexPages.StandardController stdController;
public Services__c serv;
public List<RelatedServiceUsageClass> lstRelSU {get;set;}
public Integer totalRecCnt {get;set;}
public string SUKeyPrefix {get;set;}
public string CONFirstname {get;set;}
public string CONLastname {get;set;}
private string SERVICE_EXT_RECTYPE ='External Service';

    // Standard controller constructor.
    public ServiceServiceUsageRelatedListController(ApexPages.StandardController pController) {
        stdController = pController;
        serv = (Services__c) stdController.getRecord(); 
        system.debug('@@@@@@@@@@@@@@@'+serv.id);
    }
    
    //Method is called when the page is loaded, similar to Constructor
    public PageReference AutoRunNonExternalSU(){    
        SUKeyPrefix = Schema.getGlobalDescribe().get('Service_Usage__c').getDescribe().getKeyPrefix();
        //Full URL parameter defines to limit no. of rows to 5.
        Integer qryLimit = (ApexPages.currentPage().getParameters().get('full')==null) ? 5 : 9999;
        
        Map<Id,Service_Usage__c> lstServUsage = new Map<Id,Service_Usage__c>([Select Name,Referral_Outcome__c,Service_Field__c,Service_Field__r.Name,
            Service_Type__c,Date_of_last_Activity__c,Referral_Date__c,Closure_Date__c,Risk_Identified__c,Public_Alert_Message_Required__c,Assigned_Worker__r.Name  
            from Service_Usage__c where (Service_Field__c =:serv.id ) 
            and Service_Field__r.RecordType.Name !=: SERVICE_EXT_RECTYPE order by Closure_Date__c desc Limit :qryLimit]);
        
        //This is Seperate Class which run query under User privileges.
        ContactServiceUsageWithSharing clsAccessible = new ContactServiceUsageWithSharing();
        
        //Returned accessible/visible ServiceUsage records Ids.
        Set<Id> setAccessibleRecs = clsAccessible.getAccessibleRecords(lstServUsage.keyset());
        
        lstRelSU = new List<RelatedServiceUsageClass>();
        
        //Iterate to populate specail Inner Class with flag to say a ServiceUsage record is accessible to user.
        for(Service_Usage__c rec: lstServUsage.Values())
        {
            RelatedServiceUsageClass cls = new RelatedServiceUsageClass();
            cls.recSU = rec;
            
            //If record found in Accessible set then will have edit and view link of page.
            cls.isAccessible = setAccessibleRecs.contains(rec.id);
            lstRelSU.add(cls);
        }
        
        //Get the count of records, this derives whether More link on Page be shown or not.
        totalRecCnt = [Select count() from Service_Usage__c where (Service_Field__c =:serv.id ) and Service_Field__r.RecordType.Name !=: SERVICE_EXT_RECTYPE];
        //If First Name contains more than one name (such as Mary Ann), return only one
//        string strName;
//        if (serv.FirstName==null)
//            {
//            CONFirstname = '';
//            }
//        else
//            {
//            strName = serv.FirstName;
//            string[] strArr= strName.split(' ');
//            CONFirstname = strArr[0];
//            }
//        //If last name contained a quote, the screen did nothing.  
//        
//        if (serv.LastName==null)
//            {
//            CONLastname = '';
//            }
//        else
//            {
//            String strLastName= String.escapeSingleQuotes(serv.LastName);
//            CONLastName=strLastName;
//            }
      return null;
   }
 
   
//Inner Class
public class RelatedServiceUsageClass
{
    public boolean isAccessible {get;set;}
    public Service_Usage__c recSU {get;set;}
}


}