public class SiteSurveyController {
    public Site_Survey__c survey;
    
    public SiteSurveyController (ApexPages.StandardController controller) {
        //Contact c = (Contact)controller.getRecord();
        survey = new Site_Survey__c();
    }
    
    //
    // Properties
    //
    public Site_Survey__c getSurvey() {
        if(survey == null)
            survey = new Site_Survey__c();
        return survey;
    }
    
    public PageReference section1() {
        return Page.SiteSurvey1;
    }
    
    public PageReference section2() {
        return Page.SiteSurvey2;
    }
    
    public PageReference section3() {
        return Page.SiteSurvey3;
    }
    
    public PageReference section4() {
        return Page.SiteSurvey4;
    }
    
    public PageReference section5() {
        return Page.SiteSurvey5;
    }
    
    public PageReference section6() {
        return Page.SiteSurvey6;
    }
    
    public PageReference section7() {
        return Page.SiteSurvey7;
    }
    
    public PageReference section8() {
        return Page.SiteSurvey8;
    }
    
    public PageReference section9() {
        return Page.SiteSurvey9;
    }
    
    public PageReference section10() {
        return Page.SiteSurvey10;
    }
    
    public PageReference save() {
        upsert survey;
        
        PageReference contPage = new PageReference('/' + survey.Id);
        contPage.setRedirect(true);
        return contPage;
    }
    
    // Return the user to the Site Survey tab
    public PageReference cancel() {
        PageReference contPage = new PageReference('/a0C/o');
        contPage.setRedirect(true);
        return contPage;
    }
    
    //
    // TEST METHOD
    //
    private static testMethod void testSiteSurvey() {
        Site_Survey__c survey = new Site_Survey__c();
        
        Account acc = new Account(Name='Test Region',RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'Internal%'].id);
        insert acc; 
        Account landlord = new Account(Name='Test landlord',Category__c='Landlord',RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'External%'].id);
        insert landlord;                    
        Account landlordagent = new Account(Name='Test landlord agent',Category__c='Landlord Agent',RecordTypeId=[Select Id from RecordType where
                             SObjectType='Account' and Name like 'External%'].id);
        insert landlordagent;
        Location__c loc = new Location__c(Name='Test Location',RecordTypeId=[Select Id from RecordType where SObjectType='Location__c' and Name Like 'Lease/License'].id,
                             Where__c=acc.Id, Landlord__c=landlord.Id, Landlord_Agent__c=landlordagent.Id);
        insert loc;
        
        PageReference pageRef = Page.SiteSurvey1;
        test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(survey);
        SiteSurveyController cont = new SiteSurveyController(stdCon);
        
        cont.cancel();
        cont.getSurvey();
        
        cont.section1();
        cont.section2();
        cont.section3();
        cont.section4();
        cont.section5();
        cont.section6();
        cont.section7();
        cont.section8();
        cont.section9();
        cont.section10();
        
        cont.survey.Location__c = loc.Id;
        cont.save(); 
    }
}