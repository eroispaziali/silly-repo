public with sharing class CustomUtils
{

    /***********************************************************************************************************
    *
    *   @author        :  gary.grant@conseq.co.uk  valerie.dunphy@conseq.co.uk
    *   @date           :  April 2013
    *   @description  :  A collection of generic static utility methods 
    
    
    *  Modification History
    *  Date            Who                   Description 
    *  25-11-2014      Lakshmi Rajendram     included a new method to disable all triggers
       12-Jan-2015	   Gary					 GetOptions, ListAsString			
    *                                        
    ************************************************************************************************************/

   /*
    *     Returns true if there is an open approval process step for this object id 
    *     ProcessInstance represents an instance of a single, end-to-end approval process
    *     Updated 
    */
  

   public static boolean isApprovalInProcess(String id)
   {
       //  If there is a ProcessInstanceWorkitem, the object has approvals pending 
       List<ProcessInstanceWorkItem> lis =
                [SELECT Id from ProcessInstanceWorkItem where 
                        ProcessInstanceId in (select id from ProcessInstance where TargetObjectId = :id)];
        
       return !(lis.isEmpty());              
   }
   
   public static String getCurrentUserProfileName() {
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            String pName = PROFILE[0].Name;
            return pName;
   }



   /* Test if the user is the next approval actor on this item
      Includes a test for the System Administration role 
   */   
   public static boolean isCurrentApprovalActor(String id, String userId)
   {
       if (isModifyAllData(userId)) return true;

       List<ProcessInstanceWorkItem> workItemList = 
               [SELECT ActorId from ProcessInstanceWorkitem where 
               ProcessInstanceId in (select id from ProcessInstance where TargetObjectId = :id)];
       
       
       if (workItemList.isEmpty()) 
            return false;
       
       /* Check if the user is explicitly listed */
       for(ProcessInstanceWorkItem item : workItemList) {
            if (item.ActorId == userId) { return true; }                            
       } 
       
       /* Check if the user is listed via a Queue*/
       List<Group> lisGroups = getGroupsForUser(userId);
       for(ProcessInstanceWorkItem item : workItemList) {
          for(Group grp : lisGroups) {
            if (item.ActorId==grp.id) { return true; }                 
          }
       }
             
       return false;

   }

    /* @description    Get the name of the next approver for an item aiwaintg approval. 
      *                            Gets only the first name. This does not support parallel approvals.      
      *  @param          id the id of the Target Object
     */   
   public static String getCurrentApprovalActorName(String id)
   {
       List<ProcessInstanceWorkItem> lisPiwi = 
       [SELECT actorId, actor.Type from ProcessInstanceWorkitem where 
                       ProcessInstance.targetObjectid=:id];             
    
       if (lisPiwi==null || lisPiwi.isEmpty()) return null; 
       String itemId = lisPiwi[0].actorId;
       
       if (lisPiwi[0].Actor.Type=='Queue') {
           Group grp = [select name from Group where type='Queue' and id =:itemId]; 
           return grp.Name; 
       } 
       
       if (lisPiwi[0].Actor.Type == 'User') {
          User u = [select name from user where id =:itemId];
          return u.Name;    
       }
              
       return null;                            
   }


   /* Test for an access level for this user (edit or read access etc)
      This does not take account of record locking in approvals 
   */   
   public static boolean hasUserAccess(String id, String UserId, String accessType)
   {              
       List<UserRecordAccess> lis =
                    [SELECT RecordId, HasReadAccess, HasAllAccess, HasEditAccess, HasDeleteAccess
                     FROM UserRecordAccess 
                     WHERE UserId=:userId 
                     AND RecordId =:id];
         
       if (lis.isEmpty()) return false; 
       
       UserRecordAccess ura = (UserRecordAccess)lis[0];
       if (accessType=='Edit') return ura.hasEditAccess;
       if (accessType=='Read') return ura.hasReadAccess;
       if (accessType=='All') return ura.hasAllAccess;
       if (accessType=='Delete') return ura.hasDeleteAccess;
       
       return false;
       
   }

   /* Check for modifyAllData permissions */
   public static boolean isModifyAllData(String userId)
   {
       Profile prof = [select Name, PermissionsModifyAllData from Profile 
                            where id in (select ProfileId from user where id=:userId)];
                            
       return prof.PermissionsModifyAllData;            
   } 
 
   /* Get a Config Text Item for a given type*/  
   public static ConfigText__c getConfigText(String sType)
   {
     List<ConfigText__c> lis=[select id, Body__c, Type__c from ConfigText__c
                                            where isCurrent__c = true and Type__c =:sType];
     if (lis.isEmpty()) { 
         ConfigText__c cfg = new ConfigText__c();
         return cfg;
     }
     return lis[0];     

   }
   
   /* Test if a user is in a Permission Set */
   public static boolean isUserInPermissionSet(String userId, String setName)
   {
      List<PermissionSetAssignment> lis =
       [SELECT PermissionSetId FROM PermissionSetAssignment 
        WHERE AssigneeId= :UserId AND PermissionSet.Name =: setName];
        
      if (lis.isEmpty()) { 
        return false; 
        }
      return true;                  
   }


    public static Boolean isUserInOrAboveRole(String userId, String strRoleName) {
 
    // Get requested user's role
    Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
    
    // Get all of the roles underneath the user
    Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
    allSubRoleIds.add(roleId);
    
    // Get role name 
    Map<Id,UserRole> roles= new Map<Id, UserRole>([Select Id, Name From UserRole where  Id IN :allSubRoleIds AND Name LIKE :strRoleName+'%' ]);
      
    // return the ids as a set so you can do what you want with them
    return (roles.size()>0);
 
  }


   private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
 
    Set<ID> currentRoleIds = new Set<ID>();
 
    // Get all of the roles underneath the passed roles
    for (UserRole userRole :[select Id from UserRole where ParentRoleId  IN :roleIds AND ParentRoleID != null])
    currentRoleIds.add(userRole.Id);
 
    // Go fetch some more roles
    if (currentRoleIds.size() > 0)
      currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
 
    return currentRoleIds;
 
  }
  
  /**
      @description  Fetch an instance of an object where sField = sId,  with all available fields.
      @param        sId The id of the object to retrieve
      @param        sField The field that contains the related link id
      @param        oDescribe The DescribeSObjectResult for the relevant sObject Type (e.g. Schema.sObjectType.BDR__c)     
  */    
  public static sObject objectWithAllFields(String sField, String sId, Schema.DescribeSObjectResult oDescribe)
  {
    
    /*
     //Put the field names into a List      
     Map<String, sObjectField> mapFields = oDescribe.fields.getMap(); 
     List<Schema.Sobjectfield> lisFields = mapFields.values();  
        
     // A string for the field names in the query   
     String sFields = '';   
 
     // Build the query string 
     String soql = 'select ';
     for(Schema.sObjectField f : lisFields ) {      
        if (sFields!='') { sFields = sFields + ','; }
        sFields = sFields + f.getDescribe().getName();      
     }

     soql = soql + sFields; 
     soql = soql + ' from ' + oDescribe.getName();
     soql = soql + ' where ' + sField + '=:sId';        
    
     List<sObject> lis = new List<sObject>();       
     lis= Database.query(soql);
     if (lis.isEmpty()) { return null ; }   
    
     // Return the sObject.     
     return lis[0];
     */
     
     List<String> lisIds = new List<String>();
     lisIds.add(sId);
     List<sObject> lisReturn = objectListWithAllFields(sField, lisIds, oDescribe);
     return lisReturn.isEmpty() ? null : lisReturn[0];      
        
  } 
 
  /**
      @description  Fetch a Map of instances of a single object type, where the value of sField is in a list, with all available fields.
                    Key the map on the value of sField
      
      @param        sIds The list of ids to retrieve
      @param        sField The field that contains the related link id
      @param        oDescribe The DescribeSObjectResult for the relevant sObject Type (e.g. Schema.sObjectType.BDR__c)     
  */    
  public static Map<String, sObject> objectMapWithAllFields(String sField, List<String> sIds, Schema.DescribeSObjectResult oDescribe)
  {
    
     List<sObject> lisReturn = objectListWithAllFields(sField, sIds, oDescribe);
     system.debug ('Map of Object with all Fields - list count : ' + lisReturn.size());
     
     Map<String, sObject> mapReturn = new Map<String, sObject>();
     for (sObject o : lisReturn) {
        system.debug('Put Object with all fields in map with key : ' + (String)o.get(sField));
        mapReturn.put((String)o.get(sField), o);
     }
     
     return mapReturn;      
    
  }
 
  
  /**
      @description  Fetch a list of instances of a single object type where the value of sField is in a list, with all available fields.
      @param        sIds The list of ids to retrieve
      @param        sField The field that contains the related link id
      @param        oDescribe The DescribeSObjectResult for the relevant sObject Type (e.g. Schema.sObjectType.BDR__c)     
  */    
  public static List<sObject> objectListWithAllFields(String sField, List<String> sIds, Schema.DescribeSObjectResult oDescribe)
  {
    
     //Put the field names into a List      
     Map<String, sObjectField> mapFields = oDescribe.fields.getMap();
     List<Schema.Sobjectfield> lisFields = mapFields.values();  
        
     // A string for the field names in the query   
     String sFields = '';   
 
     // Build the query string 
     String soql = 'select ';
     for(Schema.sObjectField f : lisFields ) {      
        if (sFields!='') { sFields = sFields + ','; }
        sFields = sFields + f.getDescribe().getName();      
     }

     soql = soql + sFields; 
     soql = soql + ' from ' + oDescribe.getName();
     soql = soql + ' where ' + sField + ' in: sIds';        
    
     system.debug('Object List with all Fields : ' + soql); 
    
     List<sObject> lis = new List<sObject>();       
     lis= Database.query(soql);      
     
     // Return the list of sObjects     
     return lis; 
        
  } 
  
  
  
  /** 
        @description    Get the list of specific sObject types that are pending approval by a selected user 
        @param          sUserId The name of the user who is to do the approval
        @param          sObjectType The type of the sObject  
   
  */
  public static List<String> getObjectIdsPendingApprovalbyUserId(String sUserId, String sObjectType)
  {
    
    List<String> lisIds = new List<String>();
    try {
            List<ProcessInstance> lisProcessInstance = 
                            [SELECT targetObjectId from ProcessInstance 
                                WHERE TargetObject.type =: sObjectType 
                                AND Id in 
                                    (SELECT processinstanceId 
                                        FROM processinstanceworkitem 
                                        WHERE actorId =: sUserId)];
    
    for (ProcessInstance p : lisProcessInstance) {
        lisIds.add(p.targetObjectId);
    }
    
    } catch(Exception x) {
        return lisIds;
    }
                   
    return lisIds;
    
  }


  /** 
        @description    Get the list of Pending Approver names for a specific sObject type 
        @param          sObjectType The type of the sObject  
   
   */
  public static List<SelectOption> getPendingApproversForObjectType(String sObjectType)
  {
   
    List<SelectOption> options=new List<SelectOption>();
    options.add(new SelectOption('',''));

    // ProcessInstanceWorkItems store Pending Requests
    try {
                        
        AggregateResult[] workItems =          
                    [SELECT Count(ActorId), Actor.Id
                     FROM ProcessInstanceWorkItem                                 
                     WHERE ProcessInstance.TargetObject.type =: sObjectType 
                     GROUP BY Actor.Id
                    ];   
                    
         Set<ID> actorIds = new Set<ID>();
         for (AggregateResult ar : workItems)  {
                actorIds.add( String.valueof( ar.get('Id')));
            
         }
         
         Map<Id,User> usersMap= new Map<Id, User>([Select Id, FirstName, LastName From User where  Id IN :actorIds  ]);             

       String sFirstName, sLastName, sShowName = '';
       
       Group grp = new Group();      
       for (AggregateResult ar : workItems)  {
                 String actorCount = String.valueof(ar.get('expr0'));
                 String actorId = String.valueof( ar.get('Id'));
                 User actor =  usersMap.get(actorId);
                 
                 if (actor==null) {
                          grp = [   select Name from Group where Id = :actorId and Type = 'Queue' ];
                 } else {
                           sFirstName = actor.FirstName;
                           sLastName = actor.LastName.replaceAll('\\(BDM\\)', '').trim();
                           sShowName = sLastName + ', '+sFirstName;
                 }
            
                 String label = (actor!=null ? sShowName : (grp==null ? '??': grp.Name)) + ' ('+actorCount + ')';
                 
                 options.add(new SelectOption(actorId, label));
        }
        
    
} catch(QueryException qe) {
    System.debug('The following exception has occurred: ' + qe.getMessage());    
}
                   
    return options;
    
  } 

  /** 
   *   @description  Get a ProcessInstance containing the list of ProcessInstanceHistory records, 
   *                        which is in the StepsAndWorkitems child relationship of ProcessInstance
   *
   *  The ProcessIstance an instance of a single, end-to-end approval process 
   *  
   *   @param        id the id of the sObject that is the subject of the workflow approval
   *
              
   **/     
   public static List<ProcessInstance> getApprovalHistories(String id)
   {    
    
    
    // ProcessDefinition.Name is the Approval Process Name, e.g. "BDR Acceptance 06-14:
    
    //    StepsAndWorkItems is the childRelationshipName for ProcessInstanceHistory
    
        List<ProcessInstance> lis = [SELECT Id, ProcessDefinition.Name,  ProcessDefinition.DeveloperName,
                                        (SELECT Id, ProcessInstance.ProcessDefinition.Name, Actor.Title, Actor.Name, CreatedDate, StepStatus, Comments 
                                          FROM StepsAndWorkitems order by CreatedDate asc) 
                                     FROM ProcessInstance 
                                     where targetObjectId=:id 
                                     order by ProcessInstance.ProcessDefinition.DeveloperName asc] ;        
        
        return (lis.isEmpty() ? null : lis);
   }
   
   /** @description     Get the list of group ( which includes Queues) where the User is a member 
       @param           userId The user id
   
   */
   public static boolean isUserInGroupName(String userId, String groupName)
   {
       List<GroupMember> lis = [SELECT Id from GroupMember where UserOrGroupId =:userId and Group.Name =: groupName ];
       return !lis.isEmpty();  
   }
   
   /** @description     Test to see if a user is in a group 
       @param           userId The user id
       @param			groupId The group id
   
   */
   public static List<Group> getGroupsForUser(String userId)
   {
       List<Group> lis = [SELECT Id from Group where id in (select Groupid FROM GroupMember where UserOrGroupId=:userId)];
       if (lis==null) { return new List<Group>(); }
       return lis;  
   }
   
   
 /**
    * @description return the unique values for a given field in a list of 
    *  records. Null is not included.
    * @param objects the list of records
    * @param field values from this field will be returned
    * @return set of values; no null
 */
public static Set<String> getFieldValues(SObject[] objects, SObjectField field) {
  Set<String> result = new Set<String>();
  if (null != objects) {
    final String fieldName = field.getDescribe().getName();
    for (SObject o : objects) {
      result.add(String.valueOf(o.get(fieldName)));
    }
    result.remove(null);
  }
 
  return result;
}

/** Get the Config Text that contains the field IDs for anObject. This should 
    be created in advance as part of the application roll out 
    by a user with Admin access. That process uses the ToolingAPI, which only 
    Admins are able to use (call outs are allowed for non-admin users).
**/    
public static Map<String, String> getObjectFieldIds(String objectName) 
  {
   
    String sName = objectName + '_fields';
    Map<String, String> mapFields = new Map<String, String>();
    ConfigText__c cfg = null;    
        
    try {       
        cfg = [select Body__c from ConfigText__c where Name =:sName];           
    } catch (Exception x) {  
        // TODO - Throw a sensible Error and/or check the user is admin
        // and create a config object
        system.debug('ConfigText _fields for ' + objectName + ' not found'); 
		return mapFields;             
    }
        
    String[] vFields = cfg.Body__c.split(';');
    for (String s : vFields) {          
        String[] vOption = s.split(':');
        mapFields.put(vOption[0], vOption[1]);          
    }
  
    return mapFields;  
  
  } 

 public static void initObjectFieldConfigTexts(List<String> lisObjects)
 {
    
    // DML operations are not allowed while looping thru multiple calls to the Tooling API
    List<ConfigText__c> lisCfg = new List<ConfigText__c>();
    

    for (String sObjectName : lisObjects) {
            
        system.debug('Getting Object Description from Tool Api: ' + sObjectName);           
    
        // do all the call outs before doing any DML operations 
        String sBody = getObjectDescriptionText(sObjectName);       
        String sName = sObjectName + '_fields';                     
        lisCfg.add(getUpdatedConfigText(sName, sBody));
    }
    
    upsert(lisCfg);
    
 }  

  private static ConfigText__c getUpdatedConfigText(String sName, String sBody)
  {

    // Put this below the call out because DML operations cannot be mid-flight 
    // when a call out is initiated 
    ConfigText__c cfg = null;    
        
    try {       
        cfg = [select Body__c from ConfigText__c where Name =:sName];           
    } catch (Exception x) {
  
        // Create a ConfigText Item and record the list of fields and Ids
        //Ensure this record is refreshed when there are database changes    
        cfg = new ConfigText__c();
        cfg.Type__c = 'System: Field Id List';
        cfg.isCurrent__c = true;
        cfg.Name = sName;
                   
    }

    cfg.Body__c = sBody;
    return cfg;
    
  } 

 /* Fetch the names and IDs of the fields for a custom object
    This can be inserted into a ConfigText for easy retrieval and use in URL Hacking strings. 
 	
 	This code has some get arounds for running tests, which are not able to make
    calls the Tooling API because Test cannot make HTTP calls...)
  */ 	
  private static String getObjectDescriptionText(String objectName) 
  {
        
    System.debug('Getting Object Fields for : ' + objectName);     
    String mapAsString = '';    
  
    // Constructs the Tooling API wrapper (default constructor uses user session Id)
    ToolingAPI toolingAPI = new ToolingAPI();

    // Query CustomObject object by DeveloperName (note no __c suffix required)
    String sObjectName = objectName.replace('__c', '');
    List<ToolingAPI.CustomObject> customObjects = null;
    if ( !Test.isRunningTest() ) { 
    	customObjects = (List<ToolingAPI.CustomObject>)toolingAPI.query('Select Id, DeveloperName, NamespacePrefix From CustomObject Where DeveloperName = \''+ sObjectName +'\'').records;
    } else {
    	customObjects  = new List<ToolingAPI.CustomObject>();
        ToolingAPI.customObject co = new ToolingAPI.CustomObject();
        co.id = '01IG00000021cXoMAI';  
        customObjects.add(co);                          	    
    }
        
    // Query CustomField object by TableEnumOrId (use CustomObject Id not name for Custom Objects)
    ToolingAPI.CustomObject customObject = customObjects[0];
    Id customObjectId = customObject.Id;
    
    system.debug('Got ObjectId from ToolingAPI : ' +customObjectId);
    
    // Use Describe to get only the current fields as previously deleted fields may cause issues with the API call. 
    // It would be good if Describe included the ID of course... then all this would not be necessary    
    String sFields = '';
    Integer c = 0;
                                    
    Schema.DescribeSobjectResult[] vDescribes = Schema.describeSObjects(new String[]{objectName});
    for(Schema.DescribeSobjectResult oDescribe : vDescribes) {
                
      for (Schema.sObjectField oField : oDescribe.fields.getMap().values()) {
            
        String sField = oField.getDescribe().getName();
        
        if (sField.endsWith('__c')) {                                       
            
            if (c++ > 0) { sFields = sFields + ',';}
            
            String sShort = sField.replace('__c', '');
            sFields = sFields + wrapApostrophe(sShort);
        
        }                   
      }
    }
        
    // Get the field data for each field    
    String sApiQuery = 'Select Id, DeveloperName, NamespacePrefix, TableEnumOrId, MetaData From CustomField Where TableEnumOrId = \'' + customObjectId + '\' and DeveloperName in (' + sFields + ')';           
    system.debug('Query sent to the Tooling Api : ' + sApiQuery);
    List<ToolingAPI.CustomField> customFields = null;
    if (!Test.isRunningTest()) {
    	customFields = (List<ToolingAPI.CustomField>)toolingAPI.query(sApiQuery).records;
    } else {
    	customFields = new List<ToolingAPI.CustomField>();
    	ToolingAPI.CustomField cf = new ToolingAPI.CustomField();
    	cf.id = '00NG0000009Y0I9MAK';
    	cf.fullName = 'Type__c';
        cf.developerName = 'Type__c';
        cf.tableEnumOrId = '01IG00000021cXoMAI';
        customFields.add(cf);
    }
        
    // Plug the field data into a string in the format Name:Id;Name:id    
    for(ToolingAPI.CustomField customField : customFields) {

       String s = customField.id; 
       s = s.substring(0,15);
               
       if (customField.MetaData!=null && customField.MetaData.referenceTo!=null) {
          s = 'CF' + s;  
       }
                      
       //mapFields.put(customField.DeveloperName,s);
       mapAsString += customField.DeveloperName + ':' + s + ';';               
               
       System.Debug('Field Name : ' + customField.DeveloperName + ':' + customField.id);
       if ( customField.MetaData!=null ) { 
       	System.Debug('Field Meta Data : ' + customField.MetaData.referenceTo);
       }

    }

    return mapAsString;
    
  }

  public static String  wrapApostrophe(String text) {
       String apo = '\'';
       return (  apo + text + apo );
  } 

 public static boolean  isDisabledTriggers()
 {
    Disable_Rules__c DisabledRules = Disable_Rules__c.getInstance();
    return  DisabledRules.Disable_Triggers__c;
 }
    
  /* Get the list of options from a field */ 
 public static List<SelectOption> getOptions(Schema.DescribeFieldResult field) 
 {

    List<SelectOption> options = new List<SelectOption>();
    for (Schema.PicklistEntry f : field.getPicklistValues()) {
      options.add(new SelectOption(f.getLabel(), f.getLabel())); 
    }
   	return options;
		
 }
 
 /* Get a comma delimited list of Strings */
 public static String listAsString(List<String> lis) {		 
 	
 	Integer c = 0;
 	String sReturn = '';
 	
    for (String s : lis) {
       if (c>0) {sReturn +=',';}
       sReturn += wrapApostrophe(s);
       c++;  
    }
    
    return sReturn;
 
 }  
    
    
 
}