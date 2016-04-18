/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Controller class for SelectObjectForInitConfig .
 *  Author  : Lakshmi Rajendram
 *  Date    : 25/11/2014
 *  
 *
 *  Description:    Apex Class create field names and ids for any object on the configtext object.This can be
 *                  invoke by the initConfig  init custom tab button on the configtext tab.
 *                  
 *               
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ????                           
*******************************************************************************************/


public with sharing class SelectObjectForInitConfigController
{

 public List<String> lisObjects  {get;set;} 
 Public List<String> result;

 public SelectObjectForInitConfigController(ApexPages.StandardController controller) {
       lisObjects=new List<String> (); 
 }
    
public boolean getIsSysAdmin()
  { 
    return CustomUtils.isModifyAllData(UserInfo.getUserId());
  }   

  
  
 public List<SelectOption> getObjectNameOptions()
   
  {

    List<Schema.SObjectType> gd = ProcessInstance.TargetObjectId.getDescribe().getReferenceTo();

    List<SelectOption> options = new List<SelectOption>();

     

    for(Schema.SObjectType f : gd)

    {
    if(!f.getDescribe().CustomSetting)   
            {

       options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
     }
    }
//selectedobjectLabel = options[0].getLabel();

    return options;

   }

  
  public void doAction() {  
  
     system.debug('>>>>>>>>>>>>>>>>>>>>' + lisObjects); 
  
    CustomUtils.initObjectFieldConfigTexts(lisObjects);    
  }
}