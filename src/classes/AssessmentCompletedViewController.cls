/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Provide methods to be called from Visual Force Pages.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-12-07
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: VF Controller with Various method handlers for a VF page.
 *        1) AssessmentCompletedAudit 
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/
public class AssessmentCompletedViewController
{
public Completed_Assessment__c CompletedAssessmentRec {get;set;}
public string strNewSectionName {get;set;}
public ApexPages.StandardController stdController;
public List<SectionInnerClass> lstSections {get;set;}
public string numSectionNumber {get;set;}
public string strAssessment {get;set;}
public string updatedDateTime {get;set;}
public string updatedByUser {get;set;}
public string strServiceUser {get;set;}
public string retid {get;set;}
private Id CurrentAuditId {get;set;}
private Id Service_Usage_id {get;set;}
//Constructor
public AssessmentCompletedViewController(ApexPages.StandardController controller)
{
    this();
}

//Default Constructor
 public AssessmentCompletedViewController() {

    List<Assessment_Question__c> lstAssessmentQuestions;
    List<Completed_Assessment_Answer__c> lstCompletedAssessmentAns = new List<Completed_Assessment_Answer__c>();

    //Open SurveyResponse on id.
    if(ApexPages.currentPage().getParameters().get('id')!=null)
    {
      //Retrieve SurveyResponse Record.
      CompletedAssessmentRec = [Select Id,Assessment__c,Assessment__r.Assessment_Header__c, Service_Usage__c
                                ,Service_Usage__r.Primary_Service_User__r.Name 
                                from Completed_Assessment__c 
          where id=:ApexPages.currentPage().getParameters().get('id')];

      if(ApexPages.currentPage().getParameters().get('retid')!=null) {
          retid=ApexPages.currentPage().getParameters().get('retid');}
      else { 
          retid = null;
          Service_Usage_id =CompletedAssessmentRec.Service_Usage__c;}
      
          
     //get lastest answer id
     getAuditTrail();
      //Retrive SurveyResponseAnswer DateTime.
      Completed_Assessment_Answer__c recSRA = [Select id,ValidFromDateTime__c,ValidToDateTime__c,Completed_Assessment__c,
          CreatedBy.Name,UpdatedBy__r.Name from Completed_Assessment_Answer__c where 
          id=:CurrentAuditId];
      
      
      //Set Survey Header to Public Property.
      strAssessment=CompletedAssessmentRec.Assessment__r.Assessment_Header__c;
      strServiceUser = CompletedAssessmentRec.Service_Usage__r.Primary_Service_User__r.Name;
      
      //Retrive all First time created ResponseAnswers.
      if(ApexPages.currentPage().getParameters().get('isFirstRecord')!=null)
      {
      lstCompletedAssessmentAns=[Select Choice__c, Response_Note__c, Sub_Question__c, Assessment_Question__c, Assessment_Question__r.QuestionNumber__c,
          Completed_Assessment__c,Assessment_Question__r.Assessment__r.Assessment_Section__c,CreatedById,ValidFromDateTime__c,
          Assessment_Question__r.Assessment__r.Assessment_Header__c,Assessment_Question__r.Type__c,Assessment_Question__r.Section_Header__c,
          Assessment_Question__r.Choices__c,Assessment_Question__r.Question__c,Assessment_Question__r.Note_Description__c,Assessment_Question__r.Assessor_Notes__c
           from Completed_Assessment_Answer__c where Completed_Assessment__c=:CompletedAssessmentRec.id and 
            (ValidFromDateTime__c =:recSRA.ValidFromDateTime__c) order by Assessment_Question__r.QuestionNumber__c,Sub_Question_Number__c];   
      
      //Set Public Properties.
      updatedDateTime=recSRA.ValidFromDateTime__c.format('MMM d yyyy,  HH:mm');
      updatedByUser='Created By: '+ recSRA.CreatedBy.Name;
      }
      else //Retrive all Updated ResponseAnswers.
      {
      lstCompletedAssessmentAns=[Select Choice__c, Response_Note__c, Sub_Question__c, Assessment_Question__c, Assessment_Question__r.QuestionNumber__c,
          Completed_Assessment__c,Assessment_Question__r.Assessment__r.Assessment_Section__c,CreatedById,ValidFromDateTime__c,
          Assessment_Question__r.Assessment__r.Assessment_Header__c,Assessment_Question__r.Type__c,Assessment_Question__r.Section_Header__c,
          Assessment_Question__r.Choices__c,Assessment_Question__r.Question__c,Assessment_Question__r.Note_Description__c,Assessment_Question__r.Assessor_Notes__c
           from Completed_Assessment_Answer__c where Completed_Assessment__c=:CompletedAssessmentRec.id and 
            ((ValidFromDateTime__c <=:recSRA.ValidToDateTime__c and ValidToDateTime__c=null)  or 
            (ValidFromDateTime__c <=:recSRA.ValidToDateTime__c and ValidToDateTime__c>:recSRA.ValidToDateTime__c and ValidToDateTime__c!=null)
            ) order by Assessment_Question__r.QuestionNumber__c, Sub_Question_Number__c];
      
      //Set Public Properties.
      if (recSRA.ValidToDateTime__c!=null){
          updatedDateTime=recSRA.ValidToDateTime__c.format('MMM d yyyy,  HH:mm');
          updatedByUser='Updated By: '+ recSRA.UpdatedBy__r.Name;
          }
      }
      
      //Get latest question, which User might not have answered.     
      lstAssessmentQuestions = [Select Id,Type__c,Choices__c,Question__c,Section_Header__c,Sub_Question__c,QuestionNumber__c,
              Assessment__r.Assessment_Section__c,Assessment__r.Assessment_Header__c,Note_Description__c,Assessor_Notes__c from Assessment_Question__c where Assessment__c=:CompletedAssessmentRec.Assessment__c order by QuestionNumber__c];  
           
    }//Close If, 
    

    system.debug('#####CompletedAssessmentRec ########'+CompletedAssessmentRec );
    
    Integer rowNum=1;
    
      string[] arrSections;
      
      system.debug('#####lstAssessmentQuestions##############'+lstAssessmentQuestions);
      
      system.debug('#####lstCompletedAssessmentAns##############'+lstCompletedAssessmentAns);
      
      
      //As all question will have all Section Heading and Order Numbers, select from first in List.
      //If SurveyResponse is in Edit Mode.
      if(lstCompletedAssessmentAns.size()==0)
      {
          arrSections= lstAssessmentQuestions.get(0).Assessment__r.Assessment_Section__c.split('\n');
      }
      else //User is creating new SurveyResponse.
      {
           arrSections= lstCompletedAssessmentAns.get(0).Assessment_Question__r.Assessment__r.Assessment_Section__c.split('\n');
      }
      
      //Sort the string array list, this will sort based on section order number. 
      arrSections.sort();
      
     lstSections = new List<SectionInnerClass>();
       
      //Create Sections List, with Order Number and Heading
      for(string sectSort:arrSections)
      {          
            for(string strSectName:arrSections) //lstAssessmentQuestions.get(0).Assessment__r.Assessment_Section__c.split('\n'))
            {
                //This check is to show sections in sorted by Order/sequence, 
                //because this sorting is not maintained in question; section Header field.
                if(strSectName.split('\t')[0].equals(sectSort.split('\t')[0]))
                {
                 SectionInnerClass cls = new SectionInnerClass();
                 cls.sectionNum = rowNum++;
                 cls.sectionOrderNum=Integer.valueOf(strSectName.split('\t')[0]);
                 cls.strSectionName = strSectName.split('\t')[1];
                 cls.lstAssessmentQuestions = new List<AssessmentQuestionInnerClass>();
                 lstSections.add(cls);  
                 break;
                 }
            }//Close For, strSectName
     }//Close For, sectSort


    rowNum=1;

    Map<Id,List<Completed_Assessment_Answer__c>> mapRespAns = new Map<Id,List<Completed_Assessment_Answer__c>>();
    List<Completed_Assessment_Answer__c> lstUniqueSRA = new List<Completed_Assessment_Answer__c>();
    
    //Prepare a Map of unique Question list from  ResponseAnswers.
    for(Completed_Assessment_Answer__c recQues:lstCompletedAssessmentAns)
    {
        if(mapRespAns.containskey(recQues.Assessment_Question__c))
        {
            mapRespAns.get(recQues.Assessment_Question__c).add(recQues);
        }
        else
        {
            List<Completed_Assessment_Answer__c> lstSRA = new List<Completed_Assessment_Answer__c>();
            lstSRA.add(recQues);
            mapRespAns.put(recQues.Assessment_Question__c,lstSRA);
            lstUniqueSRA.add(recQues);
        }
    }//Close for, recQues

    //Iterate through unique ResponseAnswers questions
    for(Completed_Assessment_Answer__c recQues:lstUniqueSRA)
    {
       for(SectionInnerClass recSect:lstSections)
       {
           if(recSect.strSectionName.contains(recQues.Assessment_Question__r.Section_Header__c))
           {
                 //For question type Combo type subquestions.
                 if(recQues.Assessment_Question__r.Type__c.equalsIgnoreCase('combo'))
                 {
                    AssessmentQuestionInnerClass tmpCls = new AssessmentQuestionInnerClass();
                    tmpCls.lstRespAnsRecs = mapRespAns.get(recQues.Assessment_Question__c);
                    tmpCls.respAnsRec.Response_Note__c= tmpCls.lstRespAnsRecs.get(0).Response_Note__c;
                    tmpCls.question=recQues.Assessment_Question__r.Question__c;
                    tmpCls.questionNum=Integer.valueOf(recQues.Assessment_Question__r.QuestionNumber__c);
                    tmpCls.assessorNotes=recQues.Assessment_Question__r.Assessor_Notes__c;
                    tmpCls.questionType=recQues.Assessment_Question__r.Type__c;
                    tmpCls.AllowNote = (recQues.Assessment_Question__r.Note_Description__c!=null);
                    tmpCls.NoteDescription = recQues.Assessment_Question__r.Note_Description__c;                            
                    recSect.lstAssessmentQuestions.add(tmpCls);
                }//Close If, where question type is Combo
                else //Non-Combo type question.
                {
                    AssessmentQuestionInnerClass tmpCls = new AssessmentQuestionInnerClass();
                    Completed_Assessment_Answer__c tmpSRA = mapRespAns.get(recQues.Assessment_Question__c).get(0);
                    tmpCls.question=recQues.Assessment_Question__r.Question__c;
                    tmpCls.questionNum=Integer.valueOf(recQues.Assessment_Question__r.QuestionNumber__c);
                    tmpCls.assessorNotes=recQues.Assessment_Question__r.Assessor_Notes__c;
                    tmpCls.respAnsRec=tmpSRA;
                    tmpCls.lstRespAnsRecs = new List<Completed_Assessment_Answer__c>();

                    tmpCls.questionType=recQues.Assessment_Question__r.Type__c;
                    tmpCls.assessorNotes=recQues.Assessment_Question__r.Assessor_Notes__c;
                    tmpCls.AllowNote = (recQues.Assessment_Question__r.Note_Description__c!=null);
                    tmpCls.NoteDescription = recQues.Assessment_Question__r.Note_Description__c;     
                    recSect.lstAssessmentQuestions.add(tmpCls); 
                }//Close Else, of Non-Combo type questions.
           }//Close if, recSect.strSectionName.contains
       }//Close for, recSect
    }//Close for, recQues

     system.debug('###################Constructor Closing................');   
  }//Close Constructor, CompletedSurveyController   
  public PageReference cancel()
  {
      String url;
      if (retid !=null){
          url = '/apex/AssessmentCompletedWizard?id='+retid;
       } else { 
          url = '/'+ Service_Usage_id ;
          }
          
     PageReference pageRef =new PageReference(url ); 
    
     //+'&retURL='+strRetURL+'&section='+PageNumber);
     pageRef.setRedirect(true);
     return pageRef;
  }
//Retrive Archive/Updated Answers UserNames and Dates.
public void getAuditTrail()
{
    List<AuditTrailClass> lstAuditRec = new List<AuditTrailClass>();
    if(ApexPages.currentPage().getParameters().get('id')!=null)
    {
        Map<DateTime,Completed_Assessment_Answer__c> mapAuditHistory = new Map<DateTime,Completed_Assessment_Answer__c>();
        
        //Retrive First Answered DateTime.
        Completed_Assessment_Answer__c tmpSRA=[Select ValidFromDateTime__c,CreatedBy.Name,Updated__c
            from  Completed_Assessment_Answer__c where Completed_Assessment__c=:ApexPages.currentPage().getParameters().get('id')
             order by ValidFromDateTime__c limit 1];
        
        List<DateTime> lstSortingDateTimes = new List<DateTime>();
        

        //Retrive all Updated Answers DateTime.
        for(Completed_Assessment_Answer__c rec: [Select ValidToDateTime__c,UpdatedBy__c,UpdatedBy__r.Name,ValidFromDateTime__c  
            from  Completed_Assessment_Answer__c where Completed_Assessment__c=:ApexPages.currentPage().getParameters().get('id')
             and Updated__c=true  order by ValidToDateTime__c])
        {
             //Prepare distinct DateTime records Map.
             if(!mapAuditHistory.containsKey(rec.ValidToDateTime__c))
             {
                mapAuditHistory.put(rec.ValidToDateTime__c,rec);
                lstSortingDateTimes.add(rec.ValidToDateTime__c);
             }
        }

        //Add first creation DateTime to list.
        if(tmpSRA!=null)
        {
            AuditTrailClass tmpCls =new AuditTrailClass();
            tmpCls.recId=tmpSRA.id;
            tmpCls.recUserName=tmpSRA.CreatedBy.Name;
            tmpCls.recDateTime=tmpSRA.ValidFromDateTime__c;
            tmpCls.dateTimeDisplay = tmpSRA.ValidFromDateTime__c.format('E, MMM d yyyy,  HH:mm');
            tmpCls.isFirstRecord = 1;
            lstAuditRec.add(tmpCls);
        }         
        
        lstSortingDateTimes.sort();

        //Iterate through sorted List
        for(DateTime sortDt: lstSortingDateTimes)
        {
            for(Completed_Assessment_Answer__c rec:mapAuditHistory.values())
            {
              if(sortDt==rec.ValidToDateTime__c)
              {
                  AuditTrailClass tmpCls =new AuditTrailClass();
                  tmpCls.recId=rec.id;
                  tmpCls.recUserName=rec.UpdatedBy__r.Name;
                  tmpCls.recDateTime=rec.ValidToDateTime__c;
                  tmpCls.dateTimeDisplay = rec.ValidToDateTime__c.format('E, MMM d yyyy,  HH:mm');
                  tmpCls.isFirstRecord = 0;
                  lstAuditRec.add(tmpCls);
               }
            }//End For, rec
        }//End For, sortDt.
        //get id of lastest audit record
        if (lstAuditRec.size()>0) {
            CurrentAuditId = lstAuditRec[lstAuditRec.size()-1].RecId;}
            
    }//End If, query string id is not null
    //return lstAuditRec;
}
//Public Inner Class to hold Audit trial information.
private class AuditTrailClass
{
    public Id recId {get;set;}
    public DateTime recDateTime {get;set;}
    public string dateTimeDisplay {get;set;}
    public string recUserName {get;set;}
    public Integer isFirstRecord {get;set;}
}
  
/*
//public inner claas to hold list of Object and status
public class SectionInnerClass
{
    public string strSectionName {get;set;}
    public Integer sectionNum {get;set;}
    public Integer sectionOrderNum {get;set;}
    public List<AssessmentQuestionInnerClass> lstAssessmentQuestions {get;set;}
}  

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
*/

}