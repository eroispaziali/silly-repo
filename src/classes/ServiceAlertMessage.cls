public with Sharing Class ServiceAlertMessage 
{
public Services__c recServ {get; set;}

public ServiceAlertMessage(ApexPages.StandardController controller) {
    this();
    
}
public ServiceAlertMessage() {
    if(ApexPages.currentPage().getParameters().get('id')!=null)
    {
        system.debug('@@@@@@@@@@@@@@@'+ApexPages.currentPage().getParameters().get('id'));
        getServiceDetails();
        system.debug('@@@@@@@@@@@@@@@'+recServ.Needs_Approval__c);
    }
}
public Services__c  getServiceDetails() {
    //recServ = (Services__c)controller.getRecord();
    recServ = [select id, Needs_Approval__c from Services__c where id=:ApexPages.currentPage().getParameters().get('id')];
    return recServ;



}


}