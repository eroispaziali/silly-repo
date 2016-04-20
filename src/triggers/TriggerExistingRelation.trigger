trigger TriggerExistingRelation on SFDC_Contact_Connector__c (before insert) {
 string str1,str2;
 for(SFDC_Contact_Connector__c cl: Trigger.new)
 {
     str1=cl.Contact__c;
     str2=cl.Related_Contact__c;
 }
 List<SFDC_Contact_Connector__c> relrecs = [Select Contact__c, Related_Contact__c from SFDC_Contact_Connector__c 
                                             where Contact__c=:str1 and Related_Contact__c=:str2];
 List<SFDC_Contact_Connector__c> relrecs123 = [Select Contact__c, Related_Contact__c from SFDC_Contact_Connector__c 
                                             where Contact__c=:str2 and Related_Contact__c=:str1];
                                             
  if(str1==str2)
  {
  Trigger.New[0].addError('Relationship with Self can not be created');
  }
  if(relrecs.size()>0 || relrecs123.size()>0)
  {
      Trigger.New[0].addError('A Relationship already exists with the same person');
  }
}