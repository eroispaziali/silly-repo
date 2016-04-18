Public class ExternalContactsTriggerHandler{
    
    /******************************************************************************************
*  Alzheimer's Society
*  
*  Purpose : APEX Handler Class contains the execution logic of the External_Contacts__c Trigger.
*  Author  : Lakshmi Rajendram
*  Date    : 29-01-2015
*  Version : 0.1 Unit Test
*
*  Description:    Runs the ExternalContactTrigger logic.
*               
*  Modification History
*  Date            Who         Description 

*******************************************************************************************/
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public ExternalContactsTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    
    
    public void OnAfterInsert(External_Contacts__c[] newContact, Map<ID, External_Contacts__c> ContactMap){
        System.debug('****** ExternalContactTriggerHandler.OnAfterInsert  ******');
        
        
        OnAfterInsertUpdateExContact(newContact);
    }   
    
    
    
    public void OnAfterUpdate(External_Contacts__c[] oldContact, External_Contacts__c[] updatedContact, Map<ID, External_Contacts__c> ContactMap){
        System.debug('****** ExternalContactTriggerHandler.OnAfterUpdate  ******');
        OnAfterInsertUpdateExContact(oldContact);
        
        
    }
    public void OnAfterInsertUpdateExContact(List<External_Contacts__c> exList){
        Map<ID, Services__c> parent = new Map<ID, Services__c> ();
        List <External_Contacts__c> lisContact = new List<External_Contacts__c>();
        set <id> listParent = new set<id>();
        Boolean isPublicContact=False;
        
        for(External_Contacts__c ec:exList){
            if(ec.Contact_Type__c.contains('Public Contact')){
                listParent.add(ec.External_Service__c);
            }
        }
        if(listParent.size()>0)
        {
            
            parent = new Map<Id, Services__c>([Select id,Primary_Contact_External__c ,(SELECT id,Related_Contact__r.name FROM External_Contacts__r)from Services__c where id in:listParent]);
            
            for(External_Contacts__c ecc:exList){
                Services__c myParentServ = parent.get(ecc.External_Service__c);
                
                myParentServ.Primary_Contact_External__c=ecc.Contact_Name_Formula__c;
                
            }
            update parent.values();
            
        }
        
    }
}