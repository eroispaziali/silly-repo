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
 *        1) Assessment
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *  2014-02-06   MT     Default service type added
 *                             
*******************************************************************************************/
public class AssessmentController
{
public Assessment__c AssessmentRec {get;set;}
public string strNewSectionName {get;set;}
public ApexPages.StandardController stdController;
public List<SectionInnerClass> lstSections {get;set;}
public string numSectionNumber {get;set;}
public string editQues {get;set;}
public Set<Id> setQuestionsToDel {get;set;}
public Assessment_Question__c newQuesRec {get;set;}
public QuestionInnerClass editQuesRec {get;set;}
 //Constructor
 public AssessmentController(ApexPages.StandardController controller)
 {
  this();
 }
 
 //Default Constructor
 public AssessmentController() {
 system.debug('#############Constructor begin##############');
 boolean hasFoundCompletedAssessment;
 newQuesRec = new Assessment_Question__c();
 editQuesRec = new QuestionInnerClass();
 
    //If Survey Id is found in URL then Open it in edit mode.
    if(ApexPages.currentPage().getParameters().get('id')!=null)
    {
      AssessmentRec = [Select Id,Assessment_Section__c,Assessment_Header__c,Status__c,Assessment_Notes__c, Default_Service_Type__c  from Assessment__c where id=:ApexPages.currentPage().getParameters().get('id')];  
      hasFoundCompletedAssessment=[Select Id from Completed_Assessment__c where Assessment__c=:ApexPages.currentPage().getParameters().get('id') limit 1].size()>0;
    } 
    else// If Survey Id is not found in URL then create a new Survey
    {
        AssessmentRec = new Assessment__c();
    }
    lstSections = new List<SectionInnerClass>();

    //Open Survey for editing if found in URL.
    if(AssessmentRec.id!=null)
    {
        Integer rowNum=1;
        
         List<SelectOption> lstSectOrder = new List<SelectOption>();
         
         //Read Section field and split by new line, to re-generate sections again.
         for(Integer i=1;i<=AssessmentRec.Assessment_Section__c.split('\n').size();i++)
         {
             lstSectOrder.add(new SelectOption(String.ValueOf(i),String.ValueOf(i)));
         }
         
        string[] arrSections = AssessmentRec.Assessment_Section__c.split('\n');
        //Sort the sections added to List, as they start with number, should be sorted in ascending.
        arrSections.sort();
        
        //Iterate through sections to generate Sections list according to section order number.
        for(string sectSort:arrSections)
        {
            for(string strSectName:AssessmentRec.Assessment_Section__c.split('\n'))
            {
                if(strSectName.split('\t')[0].equals(sectSort.split('\t')[0]))
                {
                 SectionInnerClass cls = new SectionInnerClass();
                 cls.lstSectOrder=lstSectOrder.clone();
                 cls.sectionNum = rowNum++;
                 cls.sectionOrderNum=Integer.valueOf(strSectName.split('\t')[0]);
                 cls.strSectionName = strSectName.split('\t')[1];
                 cls.lstQuestions = new List<QuestionInnerClass>();
                 lstSections.add(cls);    
                 break;
                } 
            }//End for, strSectName
         }//End for, sectSort
        
        
        //Retrieve Survey Question which are answered, to avoid removing from Survey.
        Set<Id> setAnsweredQues = new Set<Id>();
        for(AggregateResult rec:[Select Assessment_Question__c from Completed_Assessment_Answer__c where 
            Assessment_Question__r.Assessment__c =:AssessmentRec.id group by Assessment_Question__c])
            {
                setAnsweredQues.add((Id)rec.get('Assessment_Question__c'));
            }
            
        rowNum=1;
        Map<string,Integer> mapSectQuesCnt = new Map<string,Integer>();
        
        //Retrieve all Survey related Questions.
        for(Assessment_Question__c recQues:[Select id,Section_Header__c,Choices__c,Date_Column__c,Question__c ,
                Assessment__c,Type__c,Sub_Question__c,Note_Description__c,Assessor_Notes__c,QuestionNumber__c
                from Assessment_Question__c where Assessment__c =:AssessmentRec.id order by QuestionNumber__c ])
        {
           for(SectionInnerClass recSect:lstSections)
           {
               //If question section is found in Survey section field, then add.
               if(recSect.strSectionName.contains(recQues.Section_Header__c))
               {
                   QuestionInnerClass tmpCls;
                   //Assign question number while preparing list, to allow deletion.
                   if(mapSectQuesCnt.containsKey(recSect.strSectionName))
                   {
                       mapSectQuesCnt.put(recSect.strSectionName,mapSectQuesCnt.get(recSect.strSectionName)+1);
                       tmpCls = new QuestionInnerClass(mapSectQuesCnt.get(recSect.strSectionName));
                   }
                   else
                   {
                       mapSectQuesCnt.put(recSect.strSectionName,1);
                       tmpCls = new QuestionInnerClass(1);
                   }
                   tmpCls.quesRec=recQues;
                   
                   //If any survey is filled against this question then, should not allow to remove from survey.
                   tmpCls.hasFoundCompletedAssessment=setAnsweredQues.contains(recQues.id);
                   recSect.lstQuestions.add(tmpCls);
               }
           }//End for, recSect
        }//End for, recQues
       }//End If, opening Survey in Edit mode.

       //Populate Question number picklist.
       for(SectionInnerClass recSect:lstSections)
       {
           if(recSect.lstQuestions.size()>0)
           {
               recSect.lstQuesOrder = new List<SelectOption>();
           }
           
           for(QuestionInnerClass recQues:recSect.lstQuestions)
           {
               recSect.lstQuesOrder.add(new SelectOption(recQues.questionNum+'',recQues.questionNum+''));
           }
       }
       
    setQuestionsToDel=new Set<Id>();
    system.debug('#############Constructor End##############');
  }   
 
 //Removing Question from Section, Linkbutton handler.
 public PageReference RemoveQuestion()
 {
     //Question to remove will be set as argument at link, representing Section Number and Question No.
     string str = ApexPages.currentPage().getParameters().get('removeQues');
     Integer sectNum =Integer.valueOf(str.split(':')[0])-1;
     Integer quesNum = Integer.valueOf(str.split(':')[1])-1;
     
     //If removing question is saved to Db, then finally when Survey is saved this question need tobe physically deleted.
     if(lstSections.get(sectNum).lstQuestions.get(quesNum).quesRec.id!=null)
     {
         setQuestionsToDel.add(lstSections.get(sectNum).lstQuestions.get(quesNum).quesRec.id);
     }

     //Remove the question from Section.
     lstSections.get(sectNum).lstQuestions.remove(quesNum );
     
     Integer rowNum=1;
     
     //if(lstSections.get(Integer.valueOf(str.split(':')[0])-1).lstQuestions.size()>0)
     //{
         //Clear the Question Number List.
         lstSections.get(Integer.valueOf(str.split(':')[0])-1).lstQuesOrder = new List<SelectOption>();
     //}
     
     //Align the question number, Because removed question could be any in the list.
     for(QuestionInnerClass rec:lstSections.get(Integer.valueOf(str.split(':')[0])-1).lstQuestions)
     {
         rec.questionNum = rowNum++;
         rec.quesRec.QuestionNumber__c=rec.questionNum+'';
         lstSections.get(Integer.valueOf(str.split(':')[0])-1).lstQuesOrder.add(new SelectOption(rec.questionNum+'',rec.questionNum+''));
     }
     return null;
 }

 //Edit Question, Linkbutton handler.
 public PageReference EditQuestion()
 {
     //Read editing Question number from query string
     string str = ApexPages.currentPage().getParameters().get('editQues');
     //Store editing editing question pointers in List, when user have saved then we have to update back the list.
     editQues=str;
     system.debug('#########editQues############'+str);
     Integer sectNum =Integer.valueOf(str.split(':')[0])-1;
     Integer quesNum = Integer.valueOf(str.split(':')[1])-1;

     //Extract question from List and set for Editing.
     editQuesRec=new QuestionInnerClass();
     editQuesRec=lstSections.get(sectNum).lstQuestions.get(quesNum);
     system.debug('#########editQuesRec############'+editQuesRec);

     return null;
 }
 
 
 //Add New Section handler.
 public PageReference AddNewSection()
 {
     //Increment the SectionNumber and Order Number.
     SectionInnerClass cls = new SectionInnerClass();
     cls.strSectionName = strNewSectionName;
     cls.sectionNum = lstSections.size()+1;
     cls.sectionOrderNum = lstSections.size()+1;
     cls.lstQuestions = new List<QuestionInnerClass>();

     lstSections.add(cls);

     List<SelectOption> lstSectOrder = new List<SelectOption>();
     
     //Generate picklist of section numbers.
     for(Integer i=1;i<=lstSections.size();i++)
     {
         lstSectOrder.add(new SelectOption(String.ValueOf(i),String.ValueOf(i)));
     }
     
     //Add new Section number to picklist against every section, as user can change the Order before saving Survey.
     for(SectionInnerClass rec:lstSections)
     {
         rec.lstSectOrder=lstSectOrder.clone();
     }
     
     return null;
 } 

 //Saving edited question, button handler
 public PageReference SaveQuestion()
 {
     system.debug('##############SaveQuestion##########'+editQuesRec);

     //Read list pointers to re-link the edited and saved question.
     string str = editQues;
     system.debug('#########editQues############'+str);
     Integer sectNum =Integer.valueOf(str.split(':')[0])-1;
     Integer quesNum = Integer.valueOf(str.split(':')[1])-1;

     //Update back list with latest answer updates.
     lstSections.get(sectNum).lstQuestions.set(quesNum,editQuesRec);

     return null;
 }


 //New Question button handler.
 public PageReference AddNewQuestion()
 {
     newQuesRec = new Assessment_Question__c();
     return null;
 }

 //Adding new question to List, button handler.
 public PageReference SaveNewQuestion()
 {
    //Create new QuestionResponse and copy field values.
    QuestionInnerClass cls= new QuestionInnerClass(lstSections.get(Integer.valueOf(numSectionNumber)-1).lstQuestions.size()+1);
    cls.quesRec.Question__c=newQuesRec.question__c;
    cls.quesRec.Type__c=newQuesRec.Type__c;
    cls.quesRec.Sub_Question__c=newQuesRec.Sub_question__c;
    cls.quesRec.Choices__c=newQuesRec.Choices__c;
    cls.quesRec.Note_Description__c=newQuesRec.Note_Description__c;
    cls.quesRec.Assessor_Notes__c=newQuesRec.Assessor_Notes__c;

    //Add new question to respective section list.
    lstSections.get(Integer.valueOf(numSectionNumber)-1).lstQuestions.add(cls);
    lstSections.get(Integer.valueOf(numSectionNumber)-1).lstQuesOrder.add(new SelectOption(lstSections.get(Integer.valueOf(numSectionNumber)-1).lstQuestions.size()+'',lstSections.get(Integer.valueOf(numSectionNumber)-1).lstQuestions.size()+''));
  
     return null;
 }
 
 //Saving Survey, Finally committing changes, button handler.
 public PageReference SaveAssessment()
 {
     AssessmentRec.Assessment_Section__c='';
     //Format Survey Sections, with Tab delimeter between order and Name and Line break between sections.
     for(SectionInnerClass cls: lstSections)
     {
         AssessmentRec.Assessment_Section__c+=cls.sectionOrderNum+'\t'+cls.strSectionName+'\n';    
     }
     
     //If AssessmentRec is not null then save section and questions.
     if(AssessmentRec!=null)
     {
         
         // Create a savepoint because the data should not be committed to the database
        Savepoint sp = Database.setSavepoint();
        
        try{
         //Insert/Update Survey with Header and Section data.
         upsert AssessmentRec;
         }catch(Exception ex){ Database.rollback(sp); return null;}
         
         List<Assessment_Question__c> lstQuestionsToUpsert = new List<Assessment_Question__c>();
         //Iterate through Survey question and set Section Name for each one.
         for(SectionInnerClass clsSec: lstSections)
         {
            for(QuestionInnerClass clsQues: clsSec.lstQuestions)
             {
                 clsQues.quesRec.Section_Header__c = clsSec.strSectionName;
                 
                 //As the Suvey and Question is Master relationship, we cannot set Survey id more than onces, so the check.
                 if(clsQues.quesRec.Assessment__c==null)
                 { 
                     clsQues.quesRec.Assessment__c = AssessmentRec.id;
                 }    
                 lstQuestionsToUpsert.add(clsQues.quesRec);
             }
         }  
         
         //If there are any records to Upsert.
         if(lstQuestionsToUpsert.size()>0)
         {
             try
             {
             upsert lstQuestionsToUpsert;
             }catch(Exception ex){ Database.rollback(sp); return null;}
         } 
         
         //If User has removed questions from list, which need physical deletion.
         if(setQuestionsToDel.size()>0)
         {
             List<Assessment_Question__c> lstToDel = new List<Assessment_Question__c>();
             for(Id recId: setQuestionsToDel)
             {
                 Assessment_Question__c cls = new Assessment_Question__c(id=recId);
                 lstToDel.add(cls);
             }
             try
             {
             delete lstToDel;
             }catch(Exception ex){ Database.rollback(sp); return null;}
             setQuestionsToDel=new Set<Id>();
         }  
     }
     return new PageReference('/'+Schema.SObjectType.Assessment__c.getKeyPrefix()+'/o');
 }

//public Inner Class to hold List of different objects and statuses. 
public class SectionInnerClass
{
    public string strSectionName {get;set;}
    public Integer sectionNum {get;set;}
    public Integer sectionOrderNum {get;set;}
    public List<SelectOption> lstSectOrder {get;set;}
    public List<SelectOption> lstQuesOrder {get;set;}
    
    public List<QuestionInnerClass> lstQuestions {get;set;}
    
    public SectionInnerClass()
    {
        this.lstSectOrder = new List<SelectOption>();
        this.lstQuesOrder = new List<SelectOption>();
    }
}  

//public Inner Class to hold List of different objects and statuses. 
public class QuestionInnerClass
{
    public Assessment_Question__c quesRec {get;set;}
    public Integer questionNum {get;set;}
    public boolean hasFoundCompletedAssessment {get;set;}
    public string[] SubQuestions {
        //Public Property to return Array of SubQuestions entered, delimited by carriage return.
        get{return (quesRec.Sub_Question__c!=null)?quesRec.Sub_Question__c.SPLIT('\n'):null;}
        }
        
    public string[] Choices {set{}
        //Public Property to return Array of Choices entered, delimited by carriage return.
        get{
        return  (quesRec.Choices__c!=null)?quesRec.Choices__c.SPLIT('\n'):null;
        }
        }

    public QuestionInnerClass(){quesRec=new Assessment_Question__c();quesRec.QuestionNumber__c='1';this.questionNum=1;}
    public QuestionInnerClass(Integer questionNum){this();quesRec.QuestionNumber__c=questionNum+'';this.questionNum=questionNum;}
} 

//Updating Section Title, linkButton handler
public PageReference UpdateSectionTitle()
{
    return null;
}

//Testmethod to cover the code.
public testMethod static void testController()
{
    Assessment__c recSrvy = new Assessment__c(Assessment_Section__c='1\tSection1\n2\tSection2',Assessment_Header__c='Test Header',Status__c='Active');
    insert recSrvy;

    List<Assessment_Question__c> lstSQ = new List<Assessment_Question__c>();
    lstSQ.add(new Assessment_Question__c(Question__c='Freetext Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section1',Type__c='Freetext',QuestionNumber__c='1'));
    lstSQ.add(new Assessment_Question__c(Question__c='Combo Questionaire',Assessment__c=recSrvy.id,Section_Header__c='Section2',Type__c='Combo',QuestionNumber__c='2',
    Choices__c='Option1\nOption2\nOption3',Sub_Question__c='SubQues1\nSubQues2\nSubQues3'));
    insert lstSQ;
        
    AssessmentController conCls0= new AssessmentController(new ApexPages.StandardController(recSrvy));
    
    ApexPages.currentPage().getParameters().put('id', recSrvy.id);        
    AssessmentController conCls= new AssessmentController(new ApexPages.StandardController(recSrvy));
    conCls.strNewSectionName='MI Test New Section';
    
    conCls.AddNewSection();
    conCls.numSectionNumber='1';
    conCls.AddNewQuestion();
    conCls.SaveNewQuestion();
    conCls.SaveAssessment();
    conCls.UpdateSectionTitle();
    
    
    AssessmentController conCls2= new AssessmentController(new ApexPages.StandardController(recSrvy));
    ApexPages.currentPage().getParameters().put('removeQues', '1:1'); 
    ApexPages.currentPage().getParameters().put('editQues', '1:1'); 
    conCls2.EditQuestion();
    conCls2.SaveQuestion();
    conCls2.RemoveQuestion();
    conCls2.SaveAssessment();
}    
}