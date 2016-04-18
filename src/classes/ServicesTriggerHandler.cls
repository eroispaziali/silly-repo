public with sharing class ServicesTriggerHandler {
    /******************************************************************************************
     *  Alzheimer's Society
     *  
     *  Purpose : APEX Handler Class contains the execution logic of the Services__c Trigger.
     *  Author  : Ian Smith
     *  Date    : 24-01-2014
     *  Version : 0.1 Unit Test
     *
     *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
     *                  lastTransactionDate__c field for the Services__c Record.
     *               
     *  Modification History
     *  Date            Who         Description 
     *  24-01-2014      MTinson     Added Call to UpdateLastTransactionDate Class.
     *  12-01-2015      LR          Added methods OnBeforeServiceInsertAndUpdate                                
     *******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public ServicesTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(Services__c[] newServices, Map < ID, Services__c > ServiceMap) {
        System.debug('****** ServicesTriggerHandler.OnAfterInsert  ******');

        UpdateLastTransactionDate(newServices);

    }



    public void OnAfterUpdate(Services__c[] oldService, Services__c[] updatedService, Map < ID, Services__c > oldServiceMap) {
        System.debug('****** ServicesTriggerHandler.OnAfterUpdate  ******');

        UpdateLastTransactionDate(updatedService);



    }



    public void OnAfterDelete(Services__c[] oldService, Map < ID, Services__c > ServiceMap) {

        System.debug('****** ServicesTriggerHandler.OnAfterDelete  ******');

        UpdateLastTransactionDate(oldService);

    }

    Public void OnBeforeUpdate(List < Services__c > updatedSUs, Map < ID, Services__c > oldService) {

        OnBeforeServiceInsertAndUpdate(updatedSUs, oldService);

    }
    Public void OnBeforeInsert(List < Services__c > newSUs) {

        OnBeforeServiceInsertAndUpdate(newSUs, null);

    }




    public boolean IsTriggerContext {
        get {
            return m_isExecuting;
        }
    }




    public void UpdateLastTransactionDate(Services__c[] updatedSUs) {
        System.debug('****** UpdateLastTransactionDate ******');
        List < Id > SUIds = new List < Id > ();
        Datetime dtLastTransactionDate = datetime.now();

        for (Services__c df: updatedSUs) {
            SUIds.add(df.Id);
        }
        System.debug('****** SUIds.Size ******' + SUIds.Size());

        if (SUIds.isEmpty() == false) {

            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
            LastTransactionDateLookup handler = new LastTransactionDateLookup();
            handler.UpdateLastTransactionDate(SUIds[0], dtLastTransactionDate);

        }

    }


    public void OnBeforeServiceInsertAndUpdate(List < Services__c > updatedService, Map < ID, Services__c > OldMap) {
        Id internalST;
        Id externalST;
        List < Services__c > servicesToUpdate = new List < Services__c > ();
        
        internalST = [select Id from RecordType where sObjecttype = 'Services__c'
        and DeveloperName = 'Internal'].Id;
        externalST = [select Id from RecordType where sObjecttype = 'Services__c'
        and DeveloperName = 'External'].Id;
        List < user > updatedby = [select id, name, IgnoreValidationRules__c from User where id = : UserInfo.getUserId()];
        String AddressLine1 = '';
        String AddressLine2 = '';
        String AddressLine3 = '';
        String AddressLine4 = '';
        Boolean FirstAddressLineIsUsed = false;
        Boolean SecondAddressLineIsUsed = false;
        Boolean UpdateNeededOnAddress = false;
        // set record status to needs approval if displayed on website and key fields change.

        for (Services__c s: updatedService) {

            if (OldMap == null) {
                UpdateNeededOnAddress = s.service_street__c != null;
                s.Change_Needs_Approval__c = true;
                s.Approval_Stage__c = 'Changes Needs Approval';
                if (s.Service_Data_Manager__c == null) {
                    s.Service_Data_Manager__c = updatedBy[0].id;
                    servicesToUpdate.add(s);
                }

                if (s.Related_Service_Description__c == null && s.RecordTypeId == internalST) {

                    Sobject[] servdesc = [select Service_Description__c from Service_Types__c where service_sub_type__c = : s.Sub_Type_Internal__c and Service_Type__c = : s.Service_Type__c limit 1];
                    if (servdesc.size() != 0) {
                        s.Related_Service_Description__c = servdesc[0].id;
                        s.Service_description__c = ((Service_Types__c) servdesc[0]).Service_Description__c;
                        servicesToUpdate.add(s);
                    }
                }

            } else {

                Services__c olds = OldMap.get(s.ID);
                if (s.Service_Postcode__c != olds.Service_Postcode__c) {
                    s.Location__Latitude__s = null;
                    s.Location__Longitude__s = null;
                    s.Is_Address_Updated__c = true;
                    servicesToUpdate.add(s);
                }
                if (s.RecordTypeId == externalST) {
                    UpdateNeededOnAddress = ((s.service_street__c != olds.service_street__c && s.service_street__c != null) || (s.Street_Line_1__c == null && s.service_street__c != null) || (s.service_street__c == null));
                }

                if (s.RecordTypeId == internalST) {

                    If( (updatedBy[0].IgnoreValidationRules__c ==false) &&
                       (
                        (s.Display_on_public_website__c != olds.Display_on_public_website__c) || 
                        (s.Name != olds.Name) || 
                        (s.service_description__c != olds.service_description__c) || 
                        (s.service_type__c != olds.service_type__c) || 
                        (s.service_status__c != olds.service_status__c) || 
                        (s.service_closedate__c != olds.service_closedate__c) || 
                        (s.Default_Location__c != olds.Default_Location__c) || 
                        (s.service_email__c != olds.service_email__c) || 
                        (s.service_telephone__c != olds.service_telephone__c) || 
                        (s.service_targetclientgroup__c != olds.service_targetclientgroup__c) || 
                        (s.Other_Target_Client_Group__c != olds.Other_Target_Client_Group__c) || 
                        (s.Funder_restriction__c != olds.Funder_restriction__c) || 
                        (s.Opening_Times_Guidebook__c != olds.Opening_Times_Guidebook__c) || 
                        (s.Accessibility__c != olds.Accessibility__c) || 
                        (s.Parking__c != olds.Parking__c) || 
                        (s.Toilet_Facilities__c != olds.Toilet_Facilities__c) || 
                        (s.Price__c != olds.Price__c) || 
                        (s.Refreshments__c != olds.Refreshments__c) || 
                        (s.Known_As__c != olds.Known_As__c)
                       )
                        
                      )




                    {
                        s.Change_Needs_Approval__c = true;
                        s.Approval_Stage__c = 'Changes Needs Approval';
                        s.Is_Updated__c = True;
                        servicesToUpdate.add(s);
                        
                        if (s.Service_Data_Manager__c == null) {
                            s.Service_Data_Manager__c = updatedBy[0].id;
                            servicesToUpdate.add(s);
                        }

                    }
                    if (s.Related_Service_Description__c == null && s.RecordTypeId == internalST) {

                        Sobject[] servdesc = [select Service_Description__c from Service_Types__c where service_sub_type__c = : s.Sub_Type_Internal__c and Service_Type__c = : s.Service_Type__c limit 1];
                        if (servdesc.size() != 0) {
                            s.Related_Service_Description__c = servdesc[0].id;
                            s.Service_description__c = ((Service_Types__c) servdesc[0]).Service_Description__c;
                            servicesToUpdate.add(s);
                        }
                    }
                    if ((s.Related_Service_Description__c != null && s.service_type__c != olds.service_type__c & s.RecordTypeId == internalST) || (s.Related_Service_Description__c != null && s.service_type__c == olds.service_type__c && s.Sub_Type_Internal__c != olds.Sub_Type_Internal__c && s.RecordTypeId == internalST)) {

                        Sobject[] servdesc = [select Service_Description__c from Service_Types__c where service_sub_type__c = : s.Sub_Type_Internal__c and Service_Type__c = : s.Service_Type__c limit 1];
                        system.debug('service type ' + servdesc.size());
                        if (servdesc.size() != 0) {
                            s.Related_Service_Description__c = servdesc[0].id;
                            s.Service_description__c = ((Service_Types__c) servdesc[0]).Service_Description__c;
                            servicesToUpdate.add(s);
                        }
                    }




                }

            }
            if (UpdateNeededOnAddress) {
                // initiate temp variables
                AddressLine1 = '';
                AddressLine2 = '';
                AddressLine3 = '';
                AddressLine4 = '';
                FirstAddressLineIsUsed = false;
                SecondAddressLineIsUsed = false;
                String[] sAddrList;
                String streetAddress = '';
                if (s.service_street__c != null) {
                    streetAddress = s.service_street__c.replace(',', '\n');
                    sAddrList = streetAddress.split('\n');


                    system.debug('split address' + sAddrList);
                    for (Integer i = 0; i < sAddrList.size(); i++) {
                        if (i == 0) { // first item work first
                            if (sAddrList[0].length() > 80) {
                                AddressLine1 = sAddrList[0].substring(0, 80);
                                AddressLine2 = sAddrList[0].substring(80);
                                FirstAddressLineIsUsed = true;
                            } else {
                                AddressLine1 = sAddrList[0];
                            }
                        }
                        // work with the next item on the list:
                        if (i == 1) {
                            if ((AddressLine2 + (AddressLine2.length() > 0 ? ', ' : '') + sAddrList[1]).length() < 80) {
                                AddressLine2 = AddressLine2 + (AddressLine2.length() > 0 ? ', ' : '') + sAddrList[1];
                                SecondAddressLineIsUsed = true;
                                system.debug('address line 2' + AddressLine2);
                            } else if (sAddrList[1].length() > 80) {
                                AddressLine2 = AddressLine2 + (AddressLine2.length() > 0 ? ', ' : '') + sAddrList[1].substring(0, 80);
                                AddressLine3 = sAddrList[1].substring(80);
                            } else if (sAddrList[1].length() < 81) {
                                AddressLine2 = sAddrList[1];
                            }
                        }



                        if (i == 2) {

                            if ((AddressLine3 + (AddressLine3.length() > 0 ? ', ' : '') + sAddrList[2]).length() < 80) {
                                AddressLine3 = AddressLine3 + (AddressLine3.length() > 0 ? ', ' : '') + sAddrList[2];
                                system.debug('address line 3' + AddressLine3);
                            } else if (sAddrList[2].length() > 80) {
                                AddressLine3 = sAddrList[2].substring(0, 80);
                                AddressLine4 = sAddrList[2].substring(80);
                            } else if (sAddrList[2].length() < 81) {
                                AddressLine3 = sAddrList[2];
                            }
                        }
                        if (i + 3 < sAddrList.size()) {

                            if ((AddressLine4 + (AddressLine4.length() > 0 ? ', ' : '') + sAddrList[i + 3]).length() < 80) {
                                AddressLine4 = AddressLine4 + (AddressLine4.length() > 0 ? ', ' : '') + sAddrList[i + 3];
                                system.debug('address line 4' + AddressLine4);
                            } else {


                                AddressLine4 = sAddrList[i + 3].substring(0, 80);


                            }
                        }

                    }


                    s.Street_Line_1__c = AddressLine1;
                    s.Street_Line_2__c = AddressLine2;
                    s.Street_Line_3__c = AddressLine3;
                    s.Street_Line_4__c = AddressLine4;


                    servicesToUpdate.add(s);

                } else {

                    s.Street_Line_1__c = '';
                    s.Street_Line_2__c = '';
                    s.Street_Line_3__c = '';
                    s.Street_Line_4__c = '';

                    servicesToUpdate.add(s);


                }

            }
        }


    }
}