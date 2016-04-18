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
public class SectionInnerClass
{
    public string strSectionName {get;set;}
    public Integer sectionNum {get;set;}
    public Integer sectionOrderNum {get;set;}
    public List<AssessmentQuestionInnerClass> lstAssessmentQuestions {get;set;}
}