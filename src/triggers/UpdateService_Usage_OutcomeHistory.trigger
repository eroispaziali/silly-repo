trigger UpdateService_Usage_OutcomeHistory on Service_Usage_Outcome__c (after insert, before update) {

List<Service_Usage_Outcome__c> ListtoUpdate = new List<Service_Usage_Outcome__c>();
if(Trigger.isUpdate && !Trigger.isInsert){
    Service_Usage_Outcome_History__c history = new Service_Usage_Outcome_History__c();
    boolean isChanged;
    for (Service_Usage_Outcome__c  newOutcome: Trigger.new)
    {
    isChanged = false;
    Service_Usage_Outcome__c  oldOutcome = Trigger.oldMap.get(newOutcome.ID);
    system.debug('111111111111111111 outcome: '+oldOutcome);
    system.debug('111111111111111111 outcome: '+newOutcome);
    if (newOutcome.Action__c !=oldOutcome.Action__c) {
        history.Changed_Action__c = true;
        history.OldAction__c = oldOutcome.Action__c;
        history.NewAction__c = newOutcome.Action__c;
        isChanged = true;
        }
    if (newOutcome.Person_Identified_Outcome__c !=oldOutcome.Person_Identified_Outcome__c) {
        history.Changed_Person_Identified_Outcome__c = true;
        history.OldPerson_Identified_Outcome__c = oldOutcome.Person_Identified_Outcome__c;
        history.NewPerson_Identified_Outcome__c = newOutcome.Person_Identified_Outcome__c;
        isChanged = true;
        }
    if (newOutcome.Date_Identified__c != oldOutcome.Date_Identified__c) {
        history.Changed_Date_Identified__c = true;
        history.OldDate_Identified__c = oldOutcome.Date_Identified__c;
        history.NewDate_Identified__c = newOutcome.Date_Identified__c;
        isChanged = true;
        }
    if (newOutcome.Date_Outcome_Met__c != oldOutcome.Date_Outcome_Met__c) {
        history.Changed_Date_Outcome_Met__c = true;
        history.OldDate_Outcome_Met__c = oldOutcome.Date_Outcome_Met__c;
        history.NewDate_Outcome_Met__c = newOutcome.Date_Outcome_Met__c;
        isChanged = true;
        }
    if (String.ValueOf(newOutcome.Outcome_Category__c)!=String.ValueOf(oldOutcome.Outcome_Category__c)) {
        history.Changed_Outcome_Category__c = true;
        history.OldOutcome_Category__c = String.ValueOf(OldOutcome.Outcome_Category__c);
        history.NewOutcome_Category__c = String.ValueOf(NewOutcome.Outcome_Category__c);
        isChanged = true;
        }
    if (String.ValueOf(newOutcome.Outcome_Status__c)!=String.ValueOf(oldOutcome.Outcome_Status__c)) {
        history.Changed_Outcome_Status__c = true;
        history.OldOutcome_Status__c = String.ValueOf(OldOutcome.Outcome_Status__c);
        history.NewOutcome_Status__c = String.ValueOf(NewOutcome.Outcome_Status__c);
        isChanged = true;
        }
    if (isChanged) {
       if (oldOutcome.Version__c==null) {
           newOutcome.Version__c = 1;}
       else
       {newOutcome.Version__c=oldOutcome.Version__c + 1;
       }
       history.Outcome_No__c = newOutcome.Outcome_No__c;
       history.Version__c = newOutcome.Version__c;
       history.Service_Usage_Outcome__c = newOutcome.Id;
       history.Date__c = datetime.now();
       List<user> updatedBy = [select id, name from User where id = :UserInfo.getUserId()];
       history.User__c = updatedBy[0].Name;
       insert history;
    
    }    
    }
 }
if(Trigger.isInsert && !Trigger.isUpdate){
    Service_Usage_Outcome_History__c history = new Service_Usage_Outcome_History__c();
    for (Service_Usage_Outcome__c  newOutcome: Trigger.new)
    {
        system.debug('111111111111111111 outcome: '+newOutcome);

        history.Changed_Action__c = true;
        history.NewAction__c = newOutcome.Action__c;
        history.OldAction__c = '';
        history.Changed_Person_Identified_Outcome__c = true;
        history.NewPerson_Identified_Outcome__c = newOutcome.Person_Identified_Outcome__c;
        history.OldPerson_Identified_Outcome__c = '';
        history.Changed_Date_Identified__c = true;
        history.NewDate_Identified__c = newOutcome.Date_Identified__c;
        history.OldDate_Identified__c =null;
        history.Changed_Date_Outcome_Met__c = true;
        history.NewDate_Outcome_Met__c = newOutcome.Date_Outcome_Met__c;
        history.OldDate_Outcome_Met__c = null;
        history.Changed_Outcome_Category__c = true;
        history.NewOutcome_Category__c = String.ValueOf(NewOutcome.Outcome_Category__c);
        history.OldOutcome_Category__c ='';
        history.Changed_Outcome_Status__c = true;
        history.NewOutcome_Status__c = String.ValueOf(NewOutcome.Outcome_Status__c);
        history.OldOutcome_Status__c = '';
        history.Outcome_No__c = newOutcome.Outcome_No__c;
        history.Version__c = newOutcome.Version__c;
        history.Service_Usage_Outcome__c = newOutcome.Id;
        history.Date__c = datetime.now().addHours(1);
        List<user> updatedBy = [select id, name from User where id = :UserInfo.getUserId()];
        history.User__c = updatedBy[0].Name;
        insert history;
        
    }    
 }

}