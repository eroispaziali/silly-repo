/******************************************************************************************
 *  Alzheimer's
 *  
 *  Purpose : Apex Class serving Controller class ContactServiceUsageRelatedListController.
 *  Author  : Saaspoint - Mohammed Irfan
 *  Date    : 2011-11-10
 *  Version : 0.1 Unit Tested
 *  Project : 
 *  Copyright (c) Saaspoint 2011 as per Master Services Agreement
 *
 *  Description: This class execute ServiceUsage query under User Context to retrive accessible records.
 *
 *  Modification History
 *
 *  Date         Who    Description 
 *  yyyy-mm-dd - XX -   xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 *                             
*******************************************************************************************/
public with sharing class ContactServiceUsageWithSharing
{
    //Method accept list of ServiceUsage Ids and return list of ServiceUsage Ids having accessiblity.
    public Set<Id> getAccessibleRecords(Set<Id> setServUsage)
    {
        return (new Map<Id,Service_Usage__c>([select id from Service_Usage__c where id =: setServUsage])).keyset();
    }
}