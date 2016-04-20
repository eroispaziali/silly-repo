trigger RelationshipUpdateReverseRelationship on SFDC_Contact_Connector__c (before Update) {
// if forward relationship has been changed, change the reverse relationship.
if (Trigger.isUpdate && !Trigger.isInsert){
    for (SFDC_Contact_Connector__c nrel : Trigger.new) {
        try {
            SFDC_Contact_Connector__c orel = Trigger.oldMap.get(nrel.ID);
            System.debug('############## nrel: ' + nrel);
            System.debug('############## orel: ' + orel);
            if(orel!=null & nrel!=null){
                if (orel.Type__c!=nrel.Type__c){
                    System.debug('############## nrel.Type__c: ' + nrel.Type__c);
                    System.debug('############## orel.Type__c: ' + orel.Type__c);
                    // ANY CHANGES HERE NEED TO BE REPRODUCED IN CreateRelationshipController
                    if(nrel.Type__c=='Consultant of')
                        nrel.Reverse_Relationship_Type__c='Patient of (Consultant)';
                    else if(nrel.Type__c=='Social care worker of')
                        nrel.Reverse_Relationship_Type__c='Client of (Social care worker)';
                    else if(nrel.Type__c=='Social worker of')
                        nrel.Reverse_Relationship_Type__c='Client of (Social worker)';
                    else if(nrel.Type__c=='Care manager of')
                        nrel.Reverse_Relationship_Type__c='Patient of (Care Manager)';
                    else if(nrel.Type__c=='Community psychiatric nurse of')
                        nrel.Reverse_Relationship_Type__c='Patient of (CPN)';
                    else if(nrel.Type__c=='Admiral nurse of')
                        nrel.Reverse_Relationship_Type__c='Patient of (Admiral nurse)';
                    else if(nrel.Type__c=='Patient of (GP)') 
                        nrel.Reverse_Relationship_Type__c='GP of';
                    else if(nrel.Type__c=='Patient of (Consultant)')
                        nrel.Reverse_Relationship_Type__c='Consultant of';
                    else if(nrel.Type__c=='Patient of (Care Manager)')
                        nrel.Reverse_Relationship_Type__c='Client of (Care Manager)';
                    else if(nrel.Type__c=='Patient of (CPN)')
                        nrel.Reverse_Relationship_Type__c='Community psychiatric nurse of';
                    else if(nrel.Type__c=='Patient of (Admiral nurse)')
                        nrel.Reverse_Relationship_Type__c='Admiral nurse of';
                    else if(nrel.Type__c=='Client of (Social care worker)')
                        nrel.Reverse_Relationship_Type__c='Social care worker of';
                    else if(nrel.Type__c=='Client of (Social worker)')
                        nrel.Reverse_Relationship_Type__c='Social worker of';
                    else if(nrel.Type__c=='Client of (Care manager)')
                        nrel.Reverse_Relationship_Type__c='Care manager of';
                    else if(nrel.Type__c=='Neighbour of')
                        nrel.Reverse_Relationship_Type__c='Neighbour of';
                    else if(nrel.Type__c=='Partner of')
                        nrel.Reverse_Relationship_Type__c='Partner of';
                    else if(nrel.Type__c=='Spouse of')
                        nrel.Reverse_Relationship_Type__c='Spouse of';
                    else if(nrel.Type__c=='Parent of')
                        nrel.Reverse_Relationship_Type__c='Son/daughter of';
                    else if(nrel.Type__c=='Son/daughter of')
                        nrel.Reverse_Relationship_Type__c='Parent of';
                    else if(nrel.Type__c=='Sibling of')
                        nrel.Reverse_Relationship_Type__c='Sibling of';
                    else if(nrel.Type__c=='Cousin of')
                        nrel.Reverse_Relationship_Type__c='Cousin of';
                    else if(nrel.Type__c=='Nephew/niece of')
                        nrel.Reverse_Relationship_Type__c='Uncle/aunt of';
                    else if(nrel.Type__c=='Uncle/aunt of')
                        nrel.Reverse_Relationship_Type__c='Nephew/niece of';
                    else if(nrel.Type__c=='Grandparent of')
                        nrel.Reverse_Relationship_Type__c='Grandson/daughter of';
                    else if(nrel.Type__c=='Grandson/daughter of')
                        nrel.Reverse_Relationship_Type__c='Grandparent of';
                    else if(nrel.Type__c=='Parent in-law of')
                        nrel.Reverse_Relationship_Type__c='Son/daughter-in-law of';
                    else if(nrel.Type__c=='Son/daughter-in-law of')
                        nrel.Reverse_Relationship_Type__c='Parent in-law of';
                    else if(nrel.Type__c=='Sibling in-law of')
                        nrel.Reverse_Relationship_Type__c='Sibling in-law of';
                    else if(nrel.Type__c=='Step-parent of')
                        nrel.Reverse_Relationship_Type__c='Step-child of';
                    else if(nrel.Type__c=='Step-child of')
                        nrel.Reverse_Relationship_Type__c='Step-parent of';
                    else if(nrel.Type__c=='Step-sibling of')
                        nrel.Reverse_Relationship_Type__c='Step-sibling of';
                    else if(nrel.Type__c=='Half-sibling of')
                        nrel.Reverse_Relationship_Type__c='Half-sibling of';
                    else if(nrel.Type__c=='Friend of')
                        nrel.Reverse_Relationship_Type__c='Friend of';
                    else if(nrel.Type__c=='GP of')
                        nrel.Reverse_Relationship_Type__c='Patient of (GP)';
                    else if(nrel.Type__c=='Other')    
                        nrel.Reverse_Relationship_Type__c='Other';  
                    else if(nrel.Type__c=='Client of (paid carer)')    
                        nrel.Reverse_Relationship_Type__c='Paid carer of';               
                    else if(nrel.Type__c=='Paid carer of')    
                        nrel.Reverse_Relationship_Type__c='Client of (paid carer)';
                  }
            }
        }
        catch (Exception e) {
          /* Do nothing */
          
        }
      }
    }
}