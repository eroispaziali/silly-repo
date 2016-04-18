global with sharing class DeDuperComponentController {
    
    public boolean ShowResults {get;set;}
    
    public List<ResultItem> searchResults {get;set;}
    
    public string LastName;
    public string PostCode; 
    public string DoB; 
    
    public string getDoB() {
        return this.DoB;
    }
    
    public void setDoB(string pDoB) {
        this.DoB = pDoB;
        EvaluateResultsVisibility(); 
    }
    
    public void setLastName(string pLastName) {
        this.LastName = pLastName;
        EvaluateResultsVisibility(); 
    }
    
    public string getLastName() {
        return this.LastName;       
    }
    
    public void setPostCode(string pPostCode) {
        this.PostCode = pPostCode;
        EvaluateResultsVisibility(); 
    }
    
    public string getPostCode() {
        return this.PostCode;
    }
    
    // Constructor.
    public DeDuperComponentController() {
        ShowResults = false;
    }
    
    private void EvaluateResultsVisibility() {
        
        if((LastName == '' || LastName == null) && (DoB == '' || DoB == null) && (PostCode == '' || PostCode == null)) {
            ShowResults = false;
        } else {
            ShowResults = true;
        }
    } 

    class ResultItem {
        public String name {get;set;}
        public String dob {get;set;}
        public String postcode {get;set;}
    }
//
// TEST CASE
//
  private static testMethod void testDeDuperComponentController() {
  
    DeDuperComponentController ddc = new DeDuperComponentController();
  
    ddc.LastName='test';
    ddc.PostCode='ABC';
    ddc.DoB='1/1/1940';
    ddc.setDoB('2/1/1940');
    
    ddc.ShowResults = true;
    ddc.ShowResults = false;
    
    string sDob = ddc.getDoB();
  
    ddc.setLastName('test2');
    string sLastName = ddc.getLastName();
    
    ddc.setPostCode('EFG');
    string sPostCode = ddc.getPostCode();
    
    
    ddc.EvaluateResultsVisibility();
  
    }  

}