public with sharing class siteHome {
    
    public boolean isAuth {get;set;}
    public string lin {get;set;}
    public string pw {get;set;}
    
    public siteHome(){
        if(!SiteSettings__c.getValues('Global').isProtected__c){
            isAuth = false;
        }else{
            isAuth = true;
        }  
    }
    
    public pageReference login(){
        if(lin=='tempuser' && pw=='temp'){
            isAuth =true;
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Username password combination are incorrect');
            apexpages.addMessage(myMsg);
        }
        return null;
    }
}