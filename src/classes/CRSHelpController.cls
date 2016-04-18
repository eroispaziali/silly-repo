public without sharing class CRSHelpController {

    public CRSHelpController() {

    }

    
  public String controllerValue;
  public String HelpType;
    
  public void setControllerValue (String s) {
    controllerValue = s;
  }
    
  public String getControllerValue() {
    return controllerValue;
  }
  public String getHelpType(){
      return HelpType;
  }
  public void setHelpType(String s){
      HelpType = s;
  }
  public Boolean ShowQuestion;
  public Boolean getShowQuestion() {
      return ShowQuestion;
  }
  public void setShowQuestion(Boolean b) {
      ShowQuestion = b;
  }
  
  
  private List<Enhanced_Lookup__c> lstPvtHelp{get;set;} 
  
  public List<Enhanced_Lookup__c> lstHelp{
     get { fetchHelpDetails();
           return lstPvtHelp;}
     set;
  
 } 
  public CRSHelpController(ApexPages.StandardController controller) {
  fetchHelpDetails();
  
  }
  private void fetchHelpDetails(){
         lstPvtHelp= new List<Enhanced_Lookup__c>(); 
         lstPvtHelp= [SELECT  Name, Lookup_Description__c, lookup_field__c, Lookup_Value__c 
                             FROM Enhanced_Lookup__c 
                             WHERE lookup_field__c = :controllerValue 
                             AND Active__c=true order by Order__c];
   }
  
  
  
}