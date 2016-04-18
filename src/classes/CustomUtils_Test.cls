/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Test Class for SelectObjectForInitConfigController.
 *  Author  : Lakshmi Rajendram
 *  Date    : 25-11-2014
 *  Version : 0.1 Unit Test
 *
 *               
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ????                           
*******************************************************************************************/
@isTest                    
public class CustomUtils_Test {


	   static TestMethod void test_isApprovalInProcess()
	   {	   	 
		 boolean b = CustomUtils.isApprovalInProcess('RandomIdText');	   		                     
	   }
	   


	   public static TestMethod void test_ApprovalMethods()
	   {
	   	
	   	   Map<String, Object> mapTestData= TestBdrUtils.getTestData();
	  	   Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
	  	   BDR__c bdr = (BDR__c)mapBdr.get('bdr1');   	   
	  
	  	   /* Submit for approval */	
	       Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
	       req.setComments('Submitted for approval. Please approve this Participant for Active status.');
	       req.setObjectId(bdr.id);
	       Approval.ProcessResult result = Approval.process(req);	 	
	   	
	       String s = CustomUtils.getCurrentApprovalActorName(bdr.id);
	       
	       User u1 = [select id from User where isActive = true limit 1];
	       boolean b = CustomUtils.isCurrentApprovalActor(bdr.id, u1.id);                            
	       
	       List<String> lis = CustomUtils.getObjectIdsPendingApprovalbyUserId(bdr.BDM__c, 'BDR__c');                            
	       List<SelectOption> lisOptions = CustomUtils.getPendingApproversForObjectType('BDR__c');                            
	                                   
	       List<ProcessInstance> LisPi = CustomUtils.getApprovalHistories(bdr.id);
	       
	       List<Group> lisGrp = CustomUtils.getGroupsForUser(bdr.BDM__c); 
	                                   
	   }
	   
	   
	   static TestMethod void test_getCurrentUserProfileName() {
	   
	     String s = CustomUtils.getCurrentUserProfileName();
	   }
	
	   static TestMethod void test_hasUserAccess()
	   {              
	       
	       User u1 = [select id from User where isActive = true limit 1];
	       ConfigText__c cfg = new ConfigText__c(Type__c = 'TestType', OwnerId = u1.id);	       
	       insert cfg;
	    	       
	       CustomUtils.hasUserAccess(cfg.id, u1.id, 'Edit');
	       CustomUtils.hasUserAccess(cfg.id, u1.id, 'Read');
	       CustomUtils.hasUserAccess(cfg.id, u1.id, 'All');
	       CustomUtils.hasUserAccess(cfg.id, u1.id, 'Update');
	       
	       
	   }
	
	   /* Check for modifyAllData permissions */
	   public static TestMethod void test_isModifyAllData()
	   {
	   	   User u1 = [select id from User where isActive=true limit 1];
	   	   CustomUtils.isModifyAllData(u1.id);
	   	               
	   } 
	 
	   /* Get a Config Text Item for a given type*/  
	   public static TestMethod void test_getConfigText()
	   {
	     
	     ConfigText__c cfg = new ConfigText__c(Type__c = 'TestType');
	     insert cfg;
	     
	     ConfigText__c cfg1 = CustomUtils.getConfigText('TestType');
	     cfg1 = CustomUtils.getConfigText('OtherType');
	          
	
	   }
	   
	   /* Test if a user is in a Permission Set */
	   public static TestMethod void test_isUserInPermissionSet()
	   {	   	
	   	   PermissionSetAssignment psa = [select AssigneeId, PermissionSet.Name from PermissionSetAssignment limit 1];         			
	   	   Boolean b = CustomUtils.isUserInPermissionSet(psa.AssigneeId, psa.PermissionSet.Name);
	   	   system.assert(b);
	   }
	
	
	    public static TestMethod void test_isUserInOrAboveRole() {
	 	    
	     User u1 = [select id, UserRole.Name from User where isActive=true and UserRole.Name!= null limit 1];
	     Boolean b = CustomUtils.isUserInOrAboveRole(u1.id, u1.UserRole.Name); 
	    
	  }
		      
	  public static TestMethod void test_objectWithAllFields()
	  {
	    
	     ConfigText__c cfg = new ConfigText__c(Type__c = 'TestType');
	     insert cfg;
	     
	     SObject o = CustomUtils.objectWithAllFields('id', cfg.id, Schema.sObjectType.ConfigText__c);	    
	        
	  } 
	 
	      
   public static TestMethod void  test_objectMapWithAllFields()
	  {
	    
	       ConfigText__c cfg = new ConfigText__c(Type__c = 'TestType');
	       insert cfg;
	       
	       List<String> lis = new List<String>();
	       lis.add(cfg.id);
	       
	       Map<String, sObject> mapO = CustomUtils.objectMapWithAllFields('id', lis, Schema.sObjectType.ConfigText__c);
	  }
	   
   public static TestMethod void  test_getGroupsForUser()
	   {
	   	   User u1 = [select id from User where isActive = true limit 1];
	   	   List<Group> lisGroup = CustomUtils.getGroupsForUser(u1.id);
	   }
	   
	public static TestMethod void  test_getFieldValues() {
	  
	       ConfigText__c cfg = new ConfigText__c(Type__c = 'TestType');
	       insert cfg;
	       
	       sObject[] v = new sObject[1];	     
	       v[0] = cfg;  
	         
	       Schema.DescribeFieldResult F = ConfigText__c.Type__c.getDescribe();
		   Schema.sObjectField T = F.getSObjectField();  
	       Set<String> setV = CustomUtils.getFieldValues(v,T); 
	} 
	

	public static TestMethod void test_getObjectFieldIds() 
	  {
	   
	   	ConfigText__c cfg = new ConfigText__c(Type__c = 'TestType', Body__c = 'F1:V1;F2:V2', Name = 'ConfigText_fields');
	    insert cfg;
	    
	    Map<String, String> mapO = CustomUtils.getObjectFieldIds('ConfigText');	      
	    mapO = CustomUtils.getObjectFieldIds('NoSuchObject');
	  
	  } 
	  
	public static TestMethod void test_initObjectFieldConfigTexts()
	{
		
		List<String> lis = new List<String>();
		lis.add('ConfigText__c');
		CustomUtils.initObjectFieldConfigTexts(lis);
		
	}  
	
	
    public static TestMethod void test_wrapApostrophe() {
	       
	    String s = CustomUtils.wrapApostrophe('RandomText');
	} 

	public  testMethod static void TestDisableTriggers() {
	 
	 Disable_Rules__c dr = new  Disable_Rules__c(Disable_Triggers__c=true,SetupOwnerId = UserInfo.getprofileId());
	 insert dr;
	
	 boolean b = CustomUtils.isDisabledTriggers();	
	 
	 Account acc1 = new Account(Name='Midlands Central Locality',RecordTypeId=[Select Id from RecordType where SObjectType='Account' and Name like 'External%'].id);
	 insert acc1;
	              
	 System.debug('Account: [' + acc1.AccountNumber+ '] has inserted into system.');
	 Services__c s = new Services__c(Name='Midlands Central Advocacy',service_street__c= 'test the street name long ass string first more than 80 character for testing the',Service_Type__c='Advocacy', National_Service__c=True,RecordTypeId=[Select Id from RecordType where SObjectType='Services__c' and Name like 'External%'].id);
	 insert s;
	            
	 delete dr;
	        
	 s.service_street__c = 'test with three\nline address this\nis street address\nthis is street address 3';
	 update s;
	 
	 
	}
		 
	public static TestMethod void test_getOptions() 
	 {	
	    List<SelectOption> options = CustomUtils.getOptions(ConfigText__c.Type__c.getDescribe());	    			
	 }
	 
	 public static TestMethod void test_listAsString() {		 
	 	
	 	List<String> lis = new List<String>();
	 	lis.add('one');
	 	lis.add('two');
	 	
	 	String s = CustomUtils.listAsString(lis);
	 
	 }
	 
	 public static TestMethod void test_isUserInGroupName() {		 
	 		 	
		User u1 = [select id from User where isActive = true limit 1];
	 	boolean b = CustomUtils.isUserInGroupName(u1.id, 'A Random Group');
	 
	 }  
    
 }