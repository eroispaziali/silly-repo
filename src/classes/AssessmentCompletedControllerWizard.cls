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
 *        1) AssessmentCompleted
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2012-05-09 - MT -   Add option to save and return to calling page.
 *  2012-06-28 - MT -   Fix Daylight Saving Time problem (obs 82)
 *  2014-02-06 - MT -   Change 166 default assessments to service type
 *                             
*******************************************************************************************/
public class AssessmentCompletedControllerWizard
{
public Completed_Assessment__c CompletedAssessmentRec {get;set;}
public string strNewSectionName {get;set;}
public ApexPages.StandardController stdController;
public List<SectionInnerClass> lstSections {get;set;}
public string numSectionNumber {get;set;}
public string strAssessment {get;set;}
public string strAssessmentNotes {get;set;}
public string strServiceUsage {get;set;}
public string strRetURL {get;set;}
public List<SelectOption> lstAllAssessments {get;set;}
public string strReturnToPage {get;
    set {strReturnToPage = value;}
    }
public integer pageNumber {get; set;}
private string strPageNumber {get; set;}
public Id CurrentId {get;set;}
public Id CurrentAuditId {get;set;}

//Constructor
public AssessmentCompletedControllerWizard(ApexPages.StandardController controller)
{
    this();
}

//Default Constructor
 public AssessmentCompletedControllerWizard() {
 
    List<Assessment_Question__c> lstAssessmentQuestions;
    List<Completed_Assessment_Answer__c> lstCompletedAssessmentAns = new List<Completed_Assessment_Answer__c>();
    lstAllAssessments = new List<SelectOption>();
    
    //When new Survey Response is created from Service Usage, Retrive all Active Survey to allow User to select one.
    if(ApexPages.currentPage().getParameters().get('suid')!=null && ApexPages.currentPage().getParameters().get('sid')==null)
    {
        //166 find service type to get list of relevant assesments
        Id suid= ApexPages.currentPage().getParameters().get('suid');
        service_usage__c surec =[select service_type__c from service_usage__c where id=:suid Limit 1];
        for(Assessment__c rec:[Select Id, Assessment_Header__c, Default_Service_Type__c from Assessment__c where Status__c ='Active' and (Default_Service_Type__c =:surec.service_type__c or Default_Service_Type__c ='All')])
        {
            lstAllAssessments.add(new SelectOption(rec.id,rec.Assessment_Header__c));
        }
        if (lstAllAssessments.size()==0){
            //now add on all other assessments
            for(Assessment__c rec:[Select Id, Assessment_Header__c, Default_Service_Type__c from Assessment__c where Status__c ='Active'])
            {
                lstAllAssessments.add(new SelectOption(rec.id,rec.Assessment_Header__c));
            }
        }
        return;
    }
    //Create new SurveyResponse for given Survey Id.
    if(ApexPages.currentPage().getParameters().get('sid')!=null)
    {
      lstAssessmentQuestions = [Select Id,Type__c,Choices__c,Question__c,Section_Header__c,Sub_Question__c,Assessor_Notes__c,QuestionNumber__c,
              Assessment__r.Assessment_Section__c,Assessment__r.Assessment_Header__c,Assessment__r.Assessment_Notes__c,Note_Description__c from Assessment_Question__c where Assessment__c=:ApexPages.currentPage().getParameters().get('sid') order by QuestionNumber__c];  

      strAssessment= lstAssessmentQuestions.get(0).Assessment__r.Assessment_Header__c ; 
      strAssessmentNotes = lstAssessmentQuestions.get(0).Assessment__r.Assessment_Notes__c ;
      system.debug('++++++++Inside = strAssessment++++++++++++++'+strAssessment);            
    } 
system.debug('++++++++strAssessment++++++++++++++'+strAssessment);    

    //Having SurveyResponse id, open in edit mode.
    if(ApexPages.currentPage().getParameters().get('id')!=null)
    {
      //Retrieve SurveyResponse Record when opened in edit mode.
      CompletedAssessmentRec = [Select Id,Service_Usage__c,Service_Usage__r.Primary_Service_User__r.Name,Assessment__c,Assessment__r.Assessment_Header__c, Assessment__r.Assessment_Notes__c from Completed_Assessment__c where id=:ApexPages.currentPage().getParameters().get('id')];  
      strRetURL=CompletedAssessmentRec.Service_Usage__c;
      system.debug('11111111111111111111111111111111111++++++++strRetURL++++++++++++++: '+strRetURL);    
      strServiceUsage=CompletedAssessmentRec.Service_Usage__r.Primary_Service_User__r.Name;
      
      strAssessment=CompletedAssessmentRec.Assessment__r.Assessment_Header__c;
      strAssessmentNotes=CompletedAssessmentRec.Assessment__r.Assessment_Notes__c;
      //Retrive all ResponseAnswers completed earlier.
      lstCompletedAssessmentAns=[Select Choice__c, Response_Note__c,Sub_Question_Number__c, Sub_Question__c, Assessment_Question__c, Assessment_Question__r.QuestionNumber__c,
          Completed_Assessment__c,Assessment_Question__r.Assessment__r.Assessment_Section__c,CreatedById,ValidFromDateTime__c,
          Assessment_Question__r.Assessment__r.Assessment_Header__c,Assessment_Question__r.Type__c,Assessment_Question__r.Section_Header__c,
          Assessment_Question__r.Choices__c,Assessment_Question__r.Question__c,Assessment_Question__r.Note_Description__c,Assessment_Question__r.Assessor_Notes__c
           from Completed_Assessment_Answer__c where Completed_Assessment__c=:CompletedAssessmentRec.id and Updated__c=false order by Assessment_Question__r.QuestionNumber__c,Sub_Question_Number__c];
      
      //Get latest question when SurveyResponse is in edit mode.     
      lstAssessmentQuestions = [Select Id,Type__c,Choices__c,Question__c,Section_Header__c,Sub_Question__c,QuestionNumber__c,
              Assessment__r.Assessment_Section__c,Assessment__r.Assessment_Header__c,Note_Description__c,Assessor_Notes__c from Assessment_Question__c where Assessment__c=:CompletedAssessmentRec.Assessment__c order by QuestionNumber__c];  

      CurrentId =  ApexPages.currentPage().getParameters().get('id');          
    }//Close If, User is editing Survery Response
    else //If User filling new Survey Response.
    {
        CompletedAssessmentRec = new Completed_Assessment__c(Assessment__c=ApexPages.currentPage().getParameters().get('sid'),Service_Usage__c=ApexPages.currentPage().getParameters().get('suid'));
        strRetURL=ApexPages.currentPage().getParameters().get('suid');
        system.debug('222222222222222222222222222222222222++++++++strRetURL++++++++++++++: '+strRetURL);    
        strServiceUsage=[Select Primary_Service_User__r.Name from Service_Usage__c where id=:ApexPages.currentPage().getParameters().get('suid')
                ].Primary_Service_User__r.Name;
        
    }
system.debug('++++++++strServiceUsage++++++++++++++'+strServiceUsage);  
    
    if(ApexPages.currentPage().getParameters().get('retURL')!=null){
        strRetURL=ApexPages.currentPage().getParameters().get('retURL');
        system.debug('33333333333333333333333333333333++++++++strRetURL++++++++++++++: '+strRetURL);    
    }
   system.debug('44444444444444444444444444444444444444++++++++strRetURL++++++++++++++: '+strRetURL);   
    if(ApexPages.currentPage().getParameters().get('section')!=null){
        strPageNumber=ApexPages.currentPage().getParameters().get('section');
        pageNumber = integer.ValueOf(strPageNumber);
    }
    else { pageNumber =1;}
    
    Integer rowNum=1;
    
      string[] arrSections;
      
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
      
      system.debug('###########arrSections#############'+arrSections);
      
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

system.debug('###########lstSections#############'+lstSections);
        rowNum=1;
        //If user is creating response first time.
        if(lstCompletedAssessmentAns.size()==0)
        {
            for(Assessment_Question__c recQues:lstAssessmentQuestions)
            {
               for(SectionInnerClass recSect:lstSections)
               {
                   if(recSect.strSectionName.contains(recQues.Section_Header__c))
                   {
                         //If Question type is Combo, then prepare dynamic picklist and associate to all subQuestions.
                         if(recQues.Type__c.equalsIgnoreCase('combo'))
                         {
                             //Prepare Dynamic picklist from all Choices in Question.
                             List<SelectOption> lstQuesChoices = new List<SelectOption>();
                             
                             lstQuesChoices.add(new SelectOption('','--None--'));
                             for(string strChoice:recQues.Choices__c.split('\n'))
                             {
                                 lstQuesChoices.add(new SelectOption(strChoice.trim(),strChoice.trim()));
                             }
                             
                            AssessmentQuestionInnerClass tmpCls = new AssessmentQuestionInnerClass();
                            tmpCls.lstRespAnsRecs = new List<Completed_Assessment_Answer__c>();
                            tmpCls.question=recQues.Question__c;
                            tmpCls.questionNum=Integer.valueOf(recQues.QuestionNumber__c);
                            tmpCls.assessorNotes=recQues.Assessor_Notes__c;
                            tmpCls.questionType=recQues.Type__c;
                            tmpCls.AllowNote = (recQues.Note_Description__c!=null);
                            tmpCls.NoteDescription = recQues.Note_Description__c;
                            tmpCls.lstQuesChoices=lstQuesChoices.clone();                        
                            
                            //Create seperate ResponseAnswers for each subquestion.
                            for(string subQues:recQues.Sub_Question__c.split('\n'))
                            {
                                Completed_Assessment_Answer__c tmpSRA = new Completed_Assessment_Answer__c();
                                tmpSRA.Assessment_Question__c=recQues.id;
                                tmpSRA.Sub_Question__c=subQues;
                                tmpSRA.Sub_Question_Number__c=tmpCls.lstRespAnsRecs.size()+1;
                                tmpCls.lstRespAnsRecs.add(tmpSRA);
                            }//Close For, subQues.
                            
                            recSect.lstAssessmentQuestions.add(tmpCls);
                        }//Close If, where question type is Combo.
                        else// Non-Combo question type.
                        {
system.debug('###########Non-Combo#######'+recQues);                        
                            AssessmentQuestionInnerClass tmpCls = new AssessmentQuestionInnerClass();
                            Completed_Assessment_Answer__c tmpSRA = new Completed_Assessment_Answer__c();
                            tmpSRA.Assessment_Question__c=recQues.id;
                            tmpCls.question=recQues.Question__c;
                            tmpCls.questionNum=Integer.valueOf(recQues.QuestionNumber__c);
                            tmpCls.assessorNotes=recQues.Assessor_Notes__c;
                            tmpCls.respAnsRec=tmpSRA;
                            tmpCls.lstRespAnsRecs = new List<Completed_Assessment_Answer__c>();
    
                            tmpCls.questionType=recQues.Type__c;
                            tmpCls.assessorNotes=recQues.Assessor_Notes__c;
                            tmpCls.AllowNote = (recQues.Note_Description__c!=null);
                            tmpCls.NoteDescription = recQues.Note_Description__c;
                            recSect.lstAssessmentQuestions.add(tmpCls);            
                        }//Close Else, For Non-Combo question type.
                   }//Close If, recSect.strSectionName.contains
               }//Close For, recSect
            }//Close for, recQues
        }//Close If, when lstCompletedAssessmentAns has no records, meaning new Survey Response.
        else //If User has completed Survey earlier.
        {
system.debug('##########before mapRespAns');        
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
system.debug('##########before recQues:lstUniqueSRA');
            //Iterate through unique ResponseAnswers questions
            for(Completed_Assessment_Answer__c recQues:lstUniqueSRA)
            {
               for(SectionInnerClass recSect:lstSections)
               {
                   if(recSect.strSectionName.contains(recQues.Assessment_Question__r.Section_Header__c))
                   {
                         //For question type Combo, create dynamic picklist of choices for all subquestions
                         if(recQues.Assessment_Question__r.Type__c.equalsIgnoreCase('combo'))
                         {
                             List<SelectOption> lstQuesChoices = new List<SelectOption>();
                             lstQuesChoices.add(new SelectOption('','--None--'));
                             for(string strChoice:recQues.Assessment_Question__r.Choices__c.split('\n'))
                             {
                                 lstQuesChoices.add(new SelectOption(strChoice.trim(),strChoice.trim()));
                             }

                            AssessmentQuestionInnerClass tmpCls = new AssessmentQuestionInnerClass();
                            tmpCls.lstRespAnsRecs = mapRespAns.get(recQues.Assessment_Question__c);
                            tmpCls.respAnsRec.Response_Note__c= tmpCls.lstRespAnsRecs.get(0).Response_Note__c;
                            tmpCls.question=recQues.Assessment_Question__r.Question__c;
                            tmpCls.questionNum=Integer.valueOf(recQues.Assessment_Question__r.QuestionNumber__c);
                            tmpCls.assessorNotes=recQues.Assessment_Question__r.Assessor_Notes__c;
                            tmpCls.questionType=recQues.Assessment_Question__r.Type__c;
                            tmpCls.AllowNote = (recQues.Assessment_Question__r.Note_Description__c!=null);
                            tmpCls.NoteDescription = recQues.Assessment_Question__r.Note_Description__c;                            
                            tmpCls.lstQuesChoices=lstQuesChoices.clone();
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
            
          ////////////////////////////////////////// added new question if survey was updated after filling response\\\\\\\\\\\\\\\\\\\\\\\
system.debug('###########before recQues:lstAssessmentQuestions');
            for(Assessment_Question__c recQues:lstAssessmentQuestions)
            {
               for(SectionInnerClass recSect:lstSections)
               {
                   if(recSect.strSectionName.contains(recQues.Section_Header__c))
                   {
                        boolean hasQuestionFound = false; 
                        for(AssessmentQuestionInnerClass recSQIN:recSect.lstAssessmentQuestions)
                        {
                            if(hasQuestionFound)
                                break;
                                
                            //Check for freetext/single record
                            if(recSQIN.respAnsRec.Assessment_Question__c==recQues.id)
                            {
                                hasQuestionFound=true;
                                break;
                            }    

                            //Check for Subquestions list.
                            for(Completed_Assessment_Answer__c tmpRecSRA: recSQIN.lstRespAnsRecs)
                            {
                                if(tmpRecSRA.Assessment_Question__c==recQues.id)
                                {
                                    hasQuestionFound = true; 
                                    break;
                                }
                            }
                        }                   

                         //Logic for Combo type question, as it will have subquestions.
                         if(recQues.Type__c.equalsIgnoreCase('combo'))
                         {
                             //Prepare Picklist
                             List<SelectOption> lstQuesChoices = new List<SelectOption>();
                             lstQuesChoices.add(new SelectOption('','--None--'));
                             for(string strChoice:recQues.Choices__c.split('\n'))
                             {
                                 lstQuesChoices.add(new SelectOption(strChoice,strChoice));
                             }

                             //If question is not found then create New sub-question.
                             if(!hasQuestionFound)
                                {
                                    AssessmentQuestionInnerClass tmpCls = new AssessmentQuestionInnerClass();
                                    tmpCls.lstRespAnsRecs = new List<Completed_Assessment_Answer__c>();
                                    tmpCls.question=recQues.Question__c;
                                    tmpCls.questionNum=Integer.valueOf(recQues.QuestionNumber__c);
                                    tmpCls.assessorNotes=recQues.Assessor_Notes__c;
                                    tmpCls.questionType=recQues.Type__c;
                                    tmpCls.AllowNote = (recQues.Note_Description__c!=null);
                                    tmpCls.NoteDescription = recQues.Note_Description__c;
                                    tmpCls.lstQuesChoices=lstQuesChoices.clone();  
                                
                                    for(string subQues:recQues.Sub_Question__c.split('\n'))
                                    {
                                        Completed_Assessment_Answer__c tmpSRA = new Completed_Assessment_Answer__c();
                                        tmpSRA.Assessment_Question__c=recQues.id;
                                        tmpSRA.Sub_Question__c=subQues;
                                        tmpSRA.Sub_Question_Number__c=tmpCls.lstRespAnsRecs.size()+1;
                                        tmpCls.lstRespAnsRecs.add(tmpSRA);
                                    }
                                    
                                    //Add all subquestions as new List.
                                    recSect.lstAssessmentQuestions.add(tmpCls);
                                }//Close if, !hasQuestionFound
                                else //if Question found, then check whether any sub-question is missing, if so add.
                                {
                                    boolean hasSubQuestionFound=false;
                                    //Iterate through subquestion list.
                                    for(string subQues:recQues.Sub_Question__c.split('\n'))
                                    {  
                                        for(AssessmentQuestionInnerClass recSQIN:recSect.lstAssessmentQuestions)
                                        {
                                            for(Completed_Assessment_Answer__c tmpRecSRA: recSQIN.lstRespAnsRecs)
                                            {
                                                //Check if Question Id and subquestion text matches.
                                                if(tmpRecSRA.Assessment_Question__c==recQues.id && tmpRecSRA.Sub_Question__c.trim().equalsIgnoreCase(subQues.trim()))
                                                {
                                                    hasSubQuestionFound = true; 
                                                    break;
                                                }
                                            }//Close for tmpRecSRA

                                            //If subquestion is newly added to then include in current ResponseAnswer.
                                            if(!hasSubQuestionFound && recSQIN.questionType.equalsIgnoreCase('Combo'))
                                            {
                                                Completed_Assessment_Answer__c tmpSRA = new Completed_Assessment_Answer__c();
                                                tmpSRA.Assessment_Question__c=recQues.id;
                                                tmpSRA.Sub_Question__c=subQues;
                                                tmpSRA.Sub_Question_Number__c=recSQIN.lstRespAnsRecs.size()+1;
                                                
                                                recSQIN.lstRespAnsRecs.add(tmpSRA);  
                                            }
                                            hasSubQuestionFound=false;
                                        }//Close for, recSQIN
                                    }//Close for, subQues
                                }//Close Else, hasQuestionFound
                        }//Close If, where question type is 'Combo'
                        else //Add when question type is NON Combo.
                        {
                            //Add question if not found int ResponseAnswers list.
                            if(!hasQuestionFound)
                            {
                                AssessmentQuestionInnerClass tmpCls = new AssessmentQuestionInnerClass();
                                Completed_Assessment_Answer__c tmpSRA = new Completed_Assessment_Answer__c();
                                tmpSRA.Assessment_Question__c=recQues.id;
                                tmpCls.question=recQues.Question__c;
                                tmpCls.questionNum=Integer.valueOf(recQues.QuestionNumber__c);
                                tmpCls.assessorNotes=recQues.Assessor_Notes__c;
                                tmpCls.respAnsRec=tmpSRA;
                                tmpCls.lstRespAnsRecs = new List<Completed_Assessment_Answer__c>();
        
                                tmpCls.questionType=recQues.Type__c;
                                tmpCls.AllowNote = (recQues.Note_Description__c!=null);
                                tmpCls.NoteDescription = recQues.Note_Description__c;
                                recSect.lstAssessmentQuestions.add(tmpCls); 
                            }//Close if, !hasQuestionFound           
                        }//Close else, Non-Combo               
                   }//Close if, recSect.strSectionName.contains
                }//Close for, recSect
            }//Close for, recQues
          //////////////////////////////////////////////////////End\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
        }//Close else, when User has completed Survery earlier and currently editing the same.
        
     system.debug('###################Constructor Closing................');  
     system.debug('#########Constructor lstSections############'+lstSections); 
  }//Close Constructor, AssessmentCompletedController   
 
  public String strRetURL(){
        if(strRetURL.contains('http'))
            return strRetURL;
        else
            return '/'+strRetURL;
  }
  public PageReference GoToPage()
  {
      system.debug('################### GoToPage page ' + pageNumber);
      strReturnToPage ='true';
      return SaveAssessment();
  
  }
  public PageReference NextPage()
  {
      system.debug('################### next page after page ' + pageNumber);
      pageNumber = pageNumber + 1;
      system.debug('################### pageNumber now ' + pageNumber);
      return SaveAssessment();
  }
  
  public PageReference PreviousPage()
  {
      pageNumber = pageNumber - 1;
      return SaveAssessment();
  
  
  }
  
  //Saving Surve Response, button handler.
  public PageReference SaveAssessment()
  {
     system.debug('#########lstSections############'+lstSections);
     
     //If SurveyResponse is not null
     if(CompletedAssessmentRec!=null)
     {
        // Create a savepoint because the data should not be committed to the database
        Savepoint sp = Database.setSavepoint();     
         try{
             //Upsert record.
             upsert CompletedAssessmentRec;
         }catch(Exception ex){ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while saving assessment.');
                              ApexPages.addMessage(message);
                              Database.rollback(sp);
                              return null;}
         
         DateTime tmpDt = System.DateTime.Now();
     
        DateTime createDateTime = DateTime.newInstance(tmpDt.year(),tmpDt.month(),tmpDt.day(),tmpDt.hour(),tmpDt.minute(),0);
        DateTime updatedDateTime = createDateTime;
             
         List<Completed_Assessment_Answer__c> lstResponseAnsToUpsert = new List<Completed_Assessment_Answer__c>();
         
         //Add the Responses for each question user had answered.
         for(SectionInnerClass secRec: lstSections)
         {
             for(AssessmentQuestionInnerClass clsRec: secRec.lstAssessmentQuestions)
             {
system.debug('###########clsRec.respAnsRec.Response_Note__c################'+clsRec.respAnsRec.Response_Note__c);
                //For question type 'Combo' user will get SubQuestion as seperate questions to answer
                if(clsRec.lstRespAnsRecs.size()>0)
                {
                    system.debug('###########beforeUpdate############'+clsRec.lstRespAnsRecs);
                    for(Completed_Assessment_Answer__c recRAS:clsRec.lstRespAnsRecs)
                    {
                        recRAS.Response_Note__c=clsRec.respAnsRec.Response_Note__c;
                    }
                    lstResponseAnsToUpsert.addAll(clsRec.lstRespAnsRecs);
                    system.debug('###########afterUpdate############'+clsRec.lstRespAnsRecs);
                }
                else//For freetext quesions
                {
                    lstResponseAnsToUpsert.add(clsRec.respAnsRec);
                }
             } 
         } 
         

system.debug('#############lstResponseAnsToUpsert#############'+lstResponseAnsToUpsert);
        //Retrive all Answers before update to check check ones have changed.
        Map<Id,Completed_Assessment_Answer__c> mapSRABeforeUpdate = new Map<Id,Completed_Assessment_Answer__c>([Select Choice__c, Response_Note__c
           from Completed_Assessment_Answer__c where id=:lstResponseAnsToUpsert and Updated__c=false]);
           
system.debug('#############mapSRABeforeUpdate#############'+mapSRABeforeUpdate);                   

        List<Completed_Assessment_Answer__c> lstFinalUpsertRSA = new List<Completed_Assessment_Answer__c>();

         //Set Survey response Id for every Response Answer record.
         for(Completed_Assessment_Answer__c rec:lstResponseAnsToUpsert)
         {
             //For any new Question Answers, set SurveyResponse Id.
             if(rec.Completed_Assessment__c==null)
             {
                 rec.Completed_Assessment__c=CompletedAssessmentRec.id;
                 rec.ValidFromDateTime__c=createDateTime;
             }    
             
             system.debug('################rec.id !=null################'+rec.id);
             
                         
             //If question was answered ealier by any user, then apply check whether to archive or update record.    
             if(rec.id !=null && mapSRABeforeUpdate.containsKey(rec.id))
             {
                 Completed_Assessment_Answer__c tmpRec = mapSRABeforeUpdate.get(rec.id);
                 boolean hasChoiceChanged=false;

                 system.debug('@@@@@@@tmpRec.Response_Note__c // rec.Response_Note__c@@@@@@@@'+tmpRec.Response_Note__c + ' // ' +rec.Response_Note__c);
                 
                 //Check if Question Choice has changed.
                 if((tmpRec.Choice__c==null ||  tmpRec.Choice__c=='') && (rec.Choice__c==null || rec.Choice__c==''))
                 {
                     hasChoiceChanged=false;
                 }else if(tmpRec.Choice__c!=null && rec.Choice__c==null)
                 {
                     hasChoiceChanged=true;
                 }else if(tmpRec.Choice__c==null && rec.Choice__c!=null)
                 {
                     hasChoiceChanged=true;
                 }else if(!tmpRec.Choice__c.equalsIgnoreCase(rec.Choice__c))
                 {
                     hasChoiceChanged=true;
                 }
                 
                 boolean hasNotesChanged=false;
                 system.debug('################rec.Response_Note__c################'+rec.Response_Note__c);
                 //system.debug('##########'+(tmpRec.Response_Note__c.equalsIgnoreCase(rec.Response_Note__c)));
                 
                 //Check if Question Notes has changed.
                 if((tmpRec.Response_Note__c==null || tmpRec.Response_Note__c=='') && (rec.Response_Note__c==null || rec.Response_Note__c==''))
                 {
                     hasNotesChanged=false;
                 }else if(tmpRec.Response_Note__c!=null && rec.Response_Note__c==null)
                 {
                     hasNotesChanged=true;
                 }else if(tmpRec.Response_Note__c==null && rec.Response_Note__c!=null)
                 {
                     hasNotesChanged=true;
                 }else if(!tmpRec.Response_Note__c.equalsIgnoreCase(rec.Response_Note__c))
                 {
                         hasNotesChanged=true;
                 }

                 system.debug('**************'+rec.id+ ' // ' + tmpRec.id);
                 system.debug('#########1111111111hasChoiceChanged // hasNotesChanged111111111##############'+hasChoiceChanged + ' // '+hasNotesChanged);
  
                 //If any field value is updated, Archive old/previous value for Audit Trial.
                 if(hasChoiceChanged || hasNotesChanged)
                 {
                     system.debug('#########2222222222222222##############'+rec.CreatedById +'/'+ UserInfo.getUserId());
                     
                     Date tmpCreatedDate = Date.newInstance(rec.ValidFromDateTime__c.year(),rec.ValidFromDateTime__c.month(),rec.ValidFromDateTime__c.day());
                    
                     //Clone new field values record
                     Completed_Assessment_Answer__c recSRACurrent = rec.clone();
                     
                     //Update current datetime.
                     recSRACurrent.ValidFromDateTime__c=createDateTime;

                    //Archive old Answer.
                    lstFinalUpsertRSA.add(new Completed_Assessment_Answer__c(ValidToDateTime__c=updatedDateTime,
                         Updated__c=true,id=rec.id,UpdatedBy__c=UserInfo.getUserId()));                             

                    //Add new cloned record for creation.
                    lstFinalUpsertRSA.add(recSRACurrent);                       
                 }   
             }//Close if, If question was answered earlier
             else //If answering question first time.
             {
                 lstFinalUpsertRSA.add(rec);
             }
             system.debug('#######lstFinalUpsertRSA.size()############'+lstFinalUpsertRSA.size());
         }//End for, rec (RSA)


         system.debug('###################'+lstFinalUpsertRSA);
         
         //If there is any record to Upsert.
         if(lstFinalUpsertRSA.size()>0)
         {
             try
             {
                 upsert lstFinalUpsertRSA;
             }catch(Exception ex){ ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while saving assessment.');
                              ApexPages.addMessage(message);
                              Database.rollback(sp);
                              return null;}             
         } 
     }
     system.debug('########################strReturnToPage####################: '+strReturnToPage);
     if (strReturnToPage =='true')
     {
     //Reload the page, this is required, to pick newly created/latest answer Ids.
 
     system.debug('5555555555555555555555555555++++++++strRetURL++++++++++++++: '+strRetURL);    
     PageReference pageRef =new PageReference('/apex/AssessmentCompletedWizard?id='+CompletedAssessmentRec.id+'&retURL='+strRetURL+'&section='+PageNumber);
     pageRef.setRedirect(true);
     return pageRef;
     }
     else
     {
     //Reload the page, this is required, to pick newly created/latest answer Ids.
     strRetURL=strRetURL();
     system.debug('5555555555555555555555555555++++++++strRetURL++++++++++++++: '+strRetURL);    
     PageReference pageRef =new PageReference(strRetURL);
     pageRef.setRedirect(true);
     return pageRef;

     }
 }

//Retrive Archive/Updated Answers UserNames and Dates.
public List<AuditTrailClass> getAuditTrail()
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
    return lstAuditRec;
}

//Public Inner Class to hold Audit trial information.
public class AuditTrailClass
{
    public Id recId {get;set;}
    public DateTime recDateTime {get;set;}
    public string dateTimeDisplay {get;set;}
    public string recUserName {get;set;}
    public Integer isFirstRecord {get;set;}
}


    
}