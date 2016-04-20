public with sharing class PropertyTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Properties Trigger.
 *  Author  : Sri Tadikonda
 *  Date    : 27-02-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the Properties Record.
 *               
 *  Modification History
 *  Date            Who                     Description 
 *  09/01/2015      Lakshmi Rajendram        added method splitLocationAddresses
 *                             
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public PropertyTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(Location__c[] NewProperties, Map<ID, Location__c> PropertiesMap){
        System.debug('****** PropertyTriggerHandler.OnAfterInsert  ******');
        
        
        UpdateLastTransactionDate(NewProperties);
    }   
 

    
    public void OnAfterUpdate(Location__c[] oldProperties, Location__c[] updatedProperties, Map<ID, Location__c> PropertiesMap){
        System.debug('****** PropertyTriggerHandler.OnAfterUpdate  ******');
        
        UpdateLastTransactionDate(updatedProperties);
    }



    public void OnAfterDelete(Location__c[] oldProperties, Map<ID, Location__c> PropertiesMap){
    
        System.debug('****** PropertyTriggerHandler.OnAfterDelete  ******');
        
        UpdateLastTransactionDate(oldProperties);
    }
    
   public void splitLocationAddresses  (List<Location__c> updateLoc,Map<Id,Location__c> oldLoc) {
    /*
     * Written By Lakshmi Rajendram
     *
     * Split the street address
     * on the property record to 
     * Street Line 1,Street Line 2,Street Line 3
     * If there is a street address with more than 3 lines then the live 4 onward
     * will be inserted on to Street Line 3 (comma seperated)
     *
     */

    List<Location__c> propertiesToUpdate = new List<Location__c>();
    String AddressLine1 = '';
    String AddressLine2 = '';
    String AddressLine3 = '';
    String AddressLine4 = '';
    Boolean FirstAddressLineIsUsed = false;
    Boolean SecondAddressLineIsUsed = false;
    Boolean UpdateNeededOnAddress = false;


    for(Location__c s : updateLoc){
       
        if (oldLoc==null) {
            UpdateNeededOnAddress = s.Street__c != null;

        } else { // isUpdate
            Location__c olds = oldLoc.get(s.ID);

            UpdateNeededOnAddress = ((s.Street__c != olds.Street__c && s.Street__c != null)  ||  ( s.Street_Line_1__c==null &&s.Street__c!=null) || (s.Street__c==null) );
        }


        if (UpdateNeededOnAddress ) {    
            // initiate temp variables
            AddressLine1 = '';
            AddressLine2 = '';
            AddressLine3 = '';
            AddressLine4 = '';
            FirstAddressLineIsUsed = false;
            SecondAddressLineIsUsed = false;
            String streetAddress='';
            String[] sAddrList ;
            If(s.Street__c!=null){
            streetAddress=s.Street__c.replace(',','\n');
            sAddrList = streetAddress.split('\n');
            
            system.debug('split address'+sAddrList);
            
            for (Integer i = 0; i < sAddrList.size(); i++) {
                if (i == 0) { // first item work first
                    if (sAddrList[0].length() > 80) {
                        AddressLine1 = sAddrList[0].substring(0,80);
                        AddressLine2 = sAddrList[0].substring(80);
                        FirstAddressLineIsUsed = true;
                    } else {
                        AddressLine1 = sAddrList[0];
                    }
                }
                // work with the second item on the list:
                if (i ==1) {
                    if ((AddressLine2 + (AddressLine2.length()>0?', ':'') + sAddrList[1]).length()< 80) { 
                        AddressLine2 = AddressLine2 + (AddressLine2.length()>0?', ':'') + sAddrList[1];
                        SecondAddressLineIsUsed = true;
                        system.debug('address line 2'+AddressLine2);
                    } else if(sAddrList[1].length() > 80){
                        AddressLine2 = AddressLine2 + (AddressLine2.length()>0?', ':'')+sAddrList[1].substring(0,80);
                        AddressLine3 = sAddrList[1].substring(80);
                    }else if(sAddrList[1].length() < 81){
                        AddressLine2 =sAddrList[1];
                    }
                }


                 // work with the third item on the list:
                if (i==2 ){

                    if ((AddressLine3 + (AddressLine3.length()>0?', ':'') + sAddrList[2]).length() < 80) { 
                        AddressLine3 = AddressLine3 + (AddressLine3.length()>0?', ':'') + sAddrList[2];
                        system.debug('address line 3'+AddressLine3);
                    } else if(sAddrList[2].length() > 80){
                        AddressLine3 = sAddrList[2].substring(0,80);
                        AddressLine4 = sAddrList[2].substring(80);
                    }else if(sAddrList[2].length() < 81){
                        AddressLine3 =sAddrList[2];
                    }
                }
                // work with the fourth+ item on the list:
                if (i+3<sAddrList.size()){

                    if ((AddressLine4 + (AddressLine4.length()>0?', ':'') + sAddrList[i+3]).length() < 80 ) { 
                        AddressLine4 = AddressLine4 + (AddressLine4.length()>0?', ':'') + sAddrList[i+3];
                        system.debug('address line 4'+AddressLine4);
                    } else{

                        AddressLine4 = sAddrList[i+3];//.substring(0,80);


                    }

                }  

            }
            s.Street_Line_1__c = AddressLine1;
            s.Street_Line_2__c = AddressLine2;
            s.Street_Line_3__c = AddressLine3;
            s.Street_Line_4__c = AddressLine4;
            propertiesToUpdate.add(s);
            
            }else{
            
            s.Street_Line_1__c = '';
            s.Street_Line_2__c = '';
            s.Street_Line_3__c = '';
            s.Street_Line_4__c = '';
            propertiesToUpdate.add(s);
            
            }
        }
    }

  
}    
        
        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

public void UpdateLastTransactionDate(Location__c[] updatedSUs){
    System.debug('****** UpdateLastTransactionDate ******');
    List<Id> SUIds = new List<Id>();
    Datetime dtLastTransactionDate = datetime.now();
    
    for(Location__c df: updatedSUs){
        SUIds.add(df.Id);
    }
    System.debug('****** SUIds.Size ******' + SUIds.Size());

    if(SUIds.isEmpty() == false){
      
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
      LastTransactionDateLookup handler = new LastTransactionDateLookup();
      handler.UpdateLastTransactionDate(SUIds[0], dtLastTransactionDate); 
      
        }
    
    }
}