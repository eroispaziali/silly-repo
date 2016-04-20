/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : To hold different instance variable state, used as List in Assessment VF Pages.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-12-07
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/

//public inner claas to hold list of Object and status
public class AssessmentQuestionInnerClass
{
    public Completed_Assessment_Answer__c respAnsRec {get;set;}
    public List<Completed_Assessment_Answer__c> lstRespAnsRecs {get;set;}
    public Integer questionNum {get;set;}
    public string questionType {get;set;}
    public string noteDescription {get;set;}
    public boolean AllowNote {get;set;}
    public string question {get;set;}
    public string assessorNotes {get;set;}
    public string selectedChoice {get;set;}
    public List<SelectOption> lstQuesChoices {get;set;}
    public AssessmentQuestionInnerClass(){respAnsRec=new Completed_Assessment_Answer__c();this.questionNum=1;}
    public AssessmentQuestionInnerClass(Integer questionNum){this();this.questionNum=questionNum;}
}