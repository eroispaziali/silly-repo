/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Capture Lead from public sites and store in Site_Lead__c.
 *  Author  : Fujitsu - Nupoor Pandey
 *  Date    : 2012-10-08
 *  Version : 0.1 Unit Tested
 *  Project : Dementia Friends Initiative - Sites
 *
 *  Description: Class to anonymise a contact. 
 *               
 *               
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/
public class sitesLeadCapture {
        
    public Site_Lead__c lead {get;set;}
    public String firstname {get;set;}
    public String lastname {get;set;}
    public String email {get;set;}
    public boolean consent {get;set;}
    
    public sitesLeadCapture(){
    }
    
    public sitesLeadCapture(ApexPages.StandardController stdCon){
        lead = new Site_Lead__c();
    }
    
    public Pagereference createSiteLead(){
        
        if(!consent){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, 'You must agree to be contacted to register');
            ApexPages.addMessage(message);
            return null;
        }
        if(email=='' || email==null){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, 'You must type an email address to register');
            ApexPages.addMessage(message);
            return null;
        }
        try{
                lead = new Site_Lead__c();
                lead.Email__c = email;
                lead.FirstName__c = firstname;
                lead.LastName__c = lastname;
                lead.Consent_To_Contact__c = consent;
                insert lead;
        }catch(DmlException e){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, 'Following email address is already registered: '+email);
                ApexPages.addMessage(message);
                return null;  
        }
       
        pageReference newpr = page.siteCompletionPage;
        newpr.getParameters().put('id',lead.Id);
        newpr.setRedirect(true);
        return newpr;
    }
    
    //Test script for code coverage.
	public testMethod static void testController(){
	    Site_Lead__c sLead = new Site_Lead__c();
	    sLead.Consent_To_Contact__c = true;
	    sLead.FirstName__c = 'Test';
	    sLead.LastName__c = 'test';
	    sLead.Email__c = 'test@test.com';
	    sLead.Email_address__c = 'test@test.com';
	    insert sLead;
	    sitesLeadCapture conCls= new sitesLeadCapture(new ApexPages.StandardController(sLead)); 
	    conCls.consent = true;
	    conCls.createSiteLead();
	    conCls.email =  'test1@test.com';
	    conCls.createSiteLead();
	    conCls.firstname = 'test';
	    conCls.lastname = 'test';
	    conCls.createSiteLead();
	    conCls.consent = false;
	    conCls.createSiteLead();
	}  
}