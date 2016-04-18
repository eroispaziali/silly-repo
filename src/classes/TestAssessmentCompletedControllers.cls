@isTest
private class TestAssessmentCompletedControllers {


public testMethod static void testAssessmentCompletedController()
{
    //Assessment__c 
    Assessment__c recSrvy = new Assessment__c(Assessment_Header__c='MI Test Header',Assessment_Section__c='1\tSection1\n2\tSection2',Status__c ='Active');
    insert recSrvy;
    
    //Contact 
    Contact recCon = new Contact(LastName='TestLastName',FirstName='TestFirstName', MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert recCon;

    //Account 
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c serv = new Services__c(Locality__c=accRec.id,Service_Type__c='Advocacy');//Name='testControllerService');
    insert serv;
       
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=recCon.id,
        Service_Type__c='Advocacy');
    insert recSU;
    
    List<Assessment_Question__c> lstSQ = new List<Assessment_Question__c>();
    lstSQ.add(new Assessment_Question__c(Question__c='Freetext Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section1',Type__c='Freetext',QuestionNumber__c='1'));
    lstSQ.add(new Assessment_Question__c(Question__c='Combo Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section2',Type__c='Combo',
    Choices__c='Option1\nOption2\nOption3',Sub_Question__c='SubQues1\nSubQues2\nSubQues3',QuestionNumber__c='2'));
    insert lstSQ;
    
    Completed_Assessment__c recSR = new Completed_Assessment__c(Assessment__c=recSrvy.id,Service_Usage__c=recSU.id);
    insert recSR;
    
    List<Completed_Assessment_Answer__c> lstCAA = new List<Completed_Assessment_Answer__c>();
    lstCAA.add(new Completed_Assessment_Answer__c(Assessment_Question__c=lstSQ.get(0).id,
            Completed_Assessment__c=recSR.id,
            Response_Note__c='Test Notes',ValidFromDateTime__c=system.now()));
    lstCAA.add(new Completed_Assessment_Answer__c(Assessment_Question__c=lstSQ.get(1).id,
            Completed_Assessment__c=recSR.id,   Sub_Question__c='SubQues1',
            Choice__c='Option1',ValidFromDateTime__c=system.now()));
    insert lstCAA;

    ApexPages.currentPage().getParameters().put('suid', recSU.id);   

     ApexPages.Standardcontroller con = new ApexPages.StandardController(recSR);
     system.debug('++++++++recSR++++++++++++++'+recSR);
     system.debug('++++++++con++++++++++++++'+con);    

    AssessmentCompletedController conCls= new AssessmentCompletedController(new ApexPages.StandardController(recSR));
    ApexPages.currentPage().getParameters().put('sid', recSrvy.id);
    
    AssessmentCompletedController conCls2= new AssessmentCompletedController(new ApexPages.StandardController(recSR));
    conCls2.SaveAssessment();
    ApexPages.currentPage().getParameters().put('strReturnToPage', 'false');
    ApexPages.currentPage().getParameters().put('id', recSR.id);
    
    AssessmentCompletedController conCls3= new AssessmentCompletedController(new ApexPages.StandardController(recSR));
    conCls3.lstSections.get(0).lstAssessmentQuestions.get(0).respAnsRec.Response_Note__c='Modified';
    ApexPages.currentPage().getParameters().put('strReturnToPage', 'true');


    conCls3.SaveAssessment();
    conCls3.getAuditTrail();
    
    List<Assessment_Question__c> lstSQ2 = new List<Assessment_Question__c>();
    lstSQ2.add(new Assessment_Question__c(Question__c='Freetext Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section1',Type__c='Freetext',QuestionNumber__c='1'));
    
    lstSQ2.add(new Assessment_Question__c(Id=lstSQ.get(1).id,Question__c='Combo Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section2',Type__c='Combo',
    Choices__c='Option1\nOption2\nOption3',Sub_Question__c='SubQues4',QuestionNumber__c='2'));
    
    lstSQ2.add(new Assessment_Question__c(Question__c='Combo Questionaire2',Assessment__c=recSrvy.id,Section_Header__c='Section2',Type__c='Combo',
    Choices__c='Option1\nOption2\nOption3',Sub_Question__c='SubQues1\nSubQues2\nSubQues3',QuestionNumber__c='3'));   
    
    upsert lstSQ2;
    AssessmentCompletedController conCls4= new AssessmentCompletedController(new ApexPages.StandardController(recSR));    

}



//MAT    20131213 - AssessmentCompletedAuditController
static testMethod void TestAssessmentCompletedAuditController()
{
   Assessment__c recSrvy = new Assessment__c(Assessment_Header__c='MI Test Header',Assessment_Section__c='1\tSection1\n2\tSection2',Status__c ='Active');
    insert recSrvy;
    
    Contact recCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='TestLastName',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert recCon;

    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    
    Services__c serv = new Services__c(Locality__c=accRec.id,Service_Type__c='Advocacy');//Name='testControllerService');
    insert serv;    
    
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=recCon.id,
        Service_Type__c='Advocacy');
    insert recSU;
    
    List<Assessment_Question__c> lstSQ = new List<Assessment_Question__c>();
    lstSQ.add(new Assessment_Question__c(Question__c='Freetext Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section1',Type__c='Freetext',QuestionNumber__c='1'));
    lstSQ.add(new Assessment_Question__c(Question__c='Combo Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section2',Type__c='Combo',
    Choices__c='Option1\nOption2\nOption3',Sub_Question__c='SubQues1\nSubQues2\nSubQues3',QuestionNumber__c='2'));
    insert lstSQ;
    
    Completed_Assessment__c recSR = new Completed_Assessment__c(Assessment__c=recSrvy.id,Service_Usage__c=recSU.id);
    insert recSR;
    
    List<Completed_Assessment_Answer__c> lstCAA = new List<Completed_Assessment_Answer__c>();
    lstCAA.add(new Completed_Assessment_Answer__c(Assessment_Question__c=lstSQ.get(0).id,
            Completed_Assessment__c=recSR.id,
            Response_Note__c='Test Notes',ValidFromDateTime__c=system.now().addMinutes(-1)));
    lstCAA.add(new Completed_Assessment_Answer__c(Assessment_Question__c=lstSQ.get(1).id,
            Completed_Assessment__c=recSR.id,   Sub_Question__c='SubQues1',
            Choice__c='Option1',ValidFromDateTime__c=system.now().addMinutes(-1)));
    insert lstCAA;

     
    Completed_Assessment_Answer__c recCAA = new Completed_Assessment_Answer__c(
        Completed_Assessment__c=recSR.id,
        Assessment_Question__c=lstSQ.get(1).id,ValidToDateTime__c=system.now(),ValidFromDateTime__c=system.now());
    
    insert recCAA;
            

    ApexPages.currentPage().getParameters().put('id', recCAA.id);
    AssessmentCompletedAuditController conCls= new AssessmentCompletedAuditController(
        new ApexPages.StandardController(recSR));
        
    ApexPages.currentPage().getParameters().put('isFirstRecord', '1');    
    AssessmentCompletedAuditController conCls2= new AssessmentCompletedAuditController(
        new ApexPages.StandardController(recSR));
  
}
public testMethod static void TestAssessmentCompletedViewController()
{
   Assessment__c recSrvy = new Assessment__c(Assessment_Header__c='MI Test Header',Assessment_Section__c='1\tSection1\n2\tSection2',Status__c ='Active');
    insert recSrvy;
    
    Contact recCon = new Contact(Salutation='Mr',FirstName='Abc',LastName='TestLastName',MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert recCon;

    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    
    Services__c serv = new Services__c(Locality__c=accRec.id,Service_Type__c='Advocacy');//Name='testControllerService');
    insert serv;    
    
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=recCon.id,
        Service_Type__c='Advocacy');
    insert recSU;
    
    List<Assessment_Question__c> lstSQ = new List<Assessment_Question__c>();
    lstSQ.add(new Assessment_Question__c(Question__c='Freetext Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section1',Type__c='Freetext',QuestionNumber__c='1'));
    lstSQ.add(new Assessment_Question__c(Question__c='Combo Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section2',Type__c='Combo',
    Choices__c='Option1\nOption2\nOption3',Sub_Question__c='SubQues1\nSubQues2\nSubQues3',QuestionNumber__c='2'));
    insert lstSQ;
    
    Completed_Assessment__c recSR = new Completed_Assessment__c(Assessment__c=recSrvy.id,Service_Usage__c=recSU.id);
    insert recSR;
    
    List<Completed_Assessment_Answer__c> lstCAA = new List<Completed_Assessment_Answer__c>();
    lstCAA.add(new Completed_Assessment_Answer__c(Assessment_Question__c=lstSQ.get(0).id,
            Completed_Assessment__c=recSR.id,
            Response_Note__c='Test Notes',ValidFromDateTime__c=system.now().addMinutes(-1)));
    lstCAA.add(new Completed_Assessment_Answer__c(Assessment_Question__c=lstSQ.get(1).id,
            Completed_Assessment__c=recSR.id,   Sub_Question__c='SubQues1',
            Choice__c='Option1',ValidFromDateTime__c=system.now().addMinutes(-1)));
    insert lstCAA;

     
    Completed_Assessment_Answer__c recCAA = new Completed_Assessment_Answer__c(
        Completed_Assessment__c=recSR.id,
        Assessment_Question__c=lstSQ.get(1).id,ValidToDateTime__c=system.now(),ValidFromDateTime__c=system.now());
    
    insert recCAA;
            

    ApexPages.currentPage().getParameters().put('id', recSR.id);
    ApexPages.currentPage().getParameters().put('isFirstRecord', '1');  
    AssessmentCompletedViewController conCls= new AssessmentCompletedViewController(
        new ApexPages.StandardController(recSR));
        
    //  
    //AssessmentCompletedViewController conCls2= new AssessmentCompletedViewController(
    //    new ApexPages.StandardController(recSR));
    conCls.getAuditTrail();
    conCls.cancel();
}
public TestMethod static void TestAssessmentCompletedControllerWizard(){
    //Assessment__c 
    Assessment__c recSrvy = new Assessment__c(Assessment_Header__c='MI Test Header',Assessment_Section__c='1\tSection1\n2\tSection2',Status__c ='Active');
    insert recSrvy;
    
    //Contact 
    Contact recCon = new Contact(LastName='TestLastName',FirstName='TestFirstName', MailingPostalCode ='ABC123', Birthdate =Date.Today(),
        RecordTypeId=[Select Id from RecordType where SObjectType='Contact' and name like 'Person with dementia%'].id);
    insert recCon;

    //Account 
    Account accRec = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'Internal%'].id);
    insert accRec;
    Services__c serv = new Services__c(Locality__c=accRec.id,Service_Type__c='Advocacy');//Name='testControllerService');
    insert serv;
       
    Service_Usage__c recSU = new Service_Usage__c(Service_Field__c=serv.id,Primary_Service_User__c=recCon.id,
        Service_Type__c='Advocacy');
    insert recSU;
    
    List<Assessment_Question__c> lstSQ = new List<Assessment_Question__c>();
    lstSQ.add(new Assessment_Question__c(Question__c='Freetext Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section1',Type__c='Freetext',QuestionNumber__c='1'));
    lstSQ.add(new Assessment_Question__c(Question__c='Combo Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section2',Type__c='Combo',
    Choices__c='Option1\nOption2\nOption3',Sub_Question__c='SubQues1\nSubQues2\nSubQues3',QuestionNumber__c='2'));
    insert lstSQ;
    
    Completed_Assessment__c recSR = new Completed_Assessment__c(Assessment__c=recSrvy.id,Service_Usage__c=recSU.id);
    insert recSR;
    
    List<Completed_Assessment_Answer__c> lstCAA = new List<Completed_Assessment_Answer__c>();
    lstCAA.add(new Completed_Assessment_Answer__c(Assessment_Question__c=lstSQ.get(0).id,
            Completed_Assessment__c=recSR.id,
            Response_Note__c='Test Notes',ValidFromDateTime__c=system.now()));
    lstCAA.add(new Completed_Assessment_Answer__c(Assessment_Question__c=lstSQ.get(1).id,
            Completed_Assessment__c=recSR.id,   Sub_Question__c='SubQues1',
            Choice__c='Option1',ValidFromDateTime__c=system.now()));
    insert lstCAA;

    //New survey
    ApexPages.currentPage().getParameters().put('sid', null);
    ApexPages.currentPage().getParameters().put('suid', recSU.id);
    ApexPages.currentPage().getParameters().put('id', null);
    ApexPages.Standardcontroller con = new ApexPages.StandardController(recSR);
    
    AssessmentCompletedControllerWizard conCls= new AssessmentCompletedControllerWizard(new ApexPages.StandardController(recSR));
    ApexPages.currentPage().getParameters().put('sid', recSrvy.id);
    conCls= new AssessmentCompletedControllerWizard(new ApexPages.StandardController(recSR));
 
    //ApexPages.currentPage().getParameters().put('suid', recSU.id);   
    //ApexPages.currentPage().getParameters().put('sid', recSrvy.id);
    //ApexPages.currentPage().getParameters().put('suid', recSU.id);
    ApexPages.currentPage().getParameters().put('id', recSR.id);
    ApexPages.currentPage().getParameters().put('retURL', recSU.id);
    ApexPages.currentPage().getParameters().put('section', '1');
    AssessmentCompletedControllerWizard conCls2= new AssessmentCompletedControllerWizard(new ApexPages.StandardController(recSR));
    conCls2.lstSections.get(0).lstAssessmentQuestions.get(0).respAnsRec.Response_Note__c='Modified';
    conCls2.strReturnToPage ='true';
    conCls2.SaveAssessment();
    conCls2.getAuditTrail();
    conCls2.NextPage();
    conCls2.PreviousPage();
    conCls2.pageNumber = 1;
    conCls2.GoToPage();
    String retStr;
    conCls2.strRetURL = 'http:/test';
    retStr=  conCls2.strRetURL();
    conCls2.strRetURL = recSU.id;
    retStr=  conCls2.strRetURL();
    
    List<Assessment_Question__c> lstSQ2 = new List<Assessment_Question__c>();
    lstSQ2.add(new Assessment_Question__c(Question__c='Freetext Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section1',Type__c='Freetext',QuestionNumber__c='1'));
    
    lstSQ2.add(new Assessment_Question__c(Id=lstSQ.get(1).id,Question__c='Combo Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section2',Type__c='Combo',
    Choices__c='Option1\nOption2\nOption3',Sub_Question__c='SubQues4',QuestionNumber__c='2'));
    
    lstSQ2.add(new Assessment_Question__c(Question__c='Combo Questionaire2',Assessment__c=recSrvy.id,Section_Header__c='Section2',Type__c='Combo',
    Choices__c='Option1\nOption2\nOption3',Sub_Question__c='SubQues1\nSubQues2\nSubQues3',QuestionNumber__c='3'));   
    
    upsert lstSQ2;
    AssessmentCompletedControllerWizard conCls3= new AssessmentCompletedControllerWizard(new ApexPages.StandardController(recSR));
    
}


}