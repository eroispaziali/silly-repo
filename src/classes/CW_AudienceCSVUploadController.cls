/**
* File Name   :    CW_AudienceCSVUploadController.cls
* Description :    B-109507
*                  upload CSv with groups/group memebers
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 02/04/2014 Klea Kolaric   Initial version
* 0.2 29.04.2014 AleX Panka     Add shells Person Account support
* 0.3 25.05.2014 Alex Panka     Audience groups rewards 
* 0.4 08.08.2014 Cristina P		Upload Audience Group and Members in the same time
*
*/
//Cristina P: 25/06/14: Changing the class from "with sharing" to "without sharing" 
//so the user can create related records while cost/brief is in approval
public without sharing class CW_AudienceCSVUploadController 
{
    
    public final static List<Integer>  notAllowedChr= new List<Integer>{0,1,2,3,4,5,6,7,8,9,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31};
	public transient Blob csvFile {get; set;}
    public Id campaignId {get; set;}
	public Id selectedSchId {get;set;}
    public string filename{get;set;}
    public static String scheduleLabel{get; set;}
    public final Integer BATCH_SIZE = 2000;
    public Id batchJobId;

	public static Map<String,Id> contactsIdMap;
	public static Map<String,Id> groupsIdMap;
	public static Map<String,Id> agsIdMap;
    
    public List<Selectoption> getSheduleList(){
    	  List<Selectoption>  result = new List<Selectoption> ();
    	  result.Add( new Selectoption('','- none -'));
    	  for (CW_Schedule__c rec : [SELECT ID ,Name FROM CW_Schedule__c WHERE Marketing_Campaign__c=:campaignId] ){
    	  		result.Add( new Selectoption(rec.ID,rec.name));
    	  }
    	  return result;
    }

    public List<Selectoption> getRewardList(){
    	  List<Selectoption>  result = new List<Selectoption> ();
    	  result.Add( new Selectoption('','- none -'));
    	  for (CW_Reward_Catalogue__c rec : [SELECT ID ,Name FROM CW_Reward_Catalogue__c WHERE Library__c<>null] ){
    	  		result.Add( new Selectoption(rec.ID,rec.name));
    	  }
    	  return result;
    }
    
    public CW_AudienceCSVUploadController()
    {
        this.campaignId = Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_CAMPAIGNID);
        //recordObjectType = CSVBatchReader.FileType.AudienceGroup;
    }
    
    @future 
    public static void clearPrevRecords(){
    	DELETE [SELECT ID FROM CW_CSV_Import_Status__c WHERE createdDate <TODAY LIMIT 1000  ];
    	DELETE [SELECT ID FROM CW_CSV_Import_Status__c WHERE createdDate <TODAY LIMIT 1000  ];
    	DELETE [SELECT ID FROM CW_CSV_Import_Status__c WHERE createdDate <TODAY LIMIT 1000  ];
    	try{
    		DELETE [SELECT ID FROM CW_CSV_Import_Status__c WHERE createdDate <TODAY];
    	}catch(Exception Ex){}
    }
    
    public Pagereference uploadCSV()
    {
		if(Apexpages.getMessages().Size()>0)
			return null;
		//display error message if user doesnt choose a schedule before uploading a file
		if (selectedSchId==null || String.valueOf(selectedSchId)=='')
		{
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please select a schedule before upload.'));
			return null;
		}
       	if(filename==null || filename=='')
       	{
         	Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,System.Label.CW_Error_FileNameMissing));
			csvFile=null;
			filename=null;
	        return null;
		}
       
		CSVBatchReader batchReader;
		//Validate file context 
		try
		{
			String fileHeader=System.EncodingUtil.convertToHex(csvFile).Substring(0,12);
         	
         	//check if the file is an zip archive(propably new excell format or Open Office) or is an excel file 
			if(fileHeader.startsWithIgnoreCase('504b03') || fileHeader.startsWithIgnoreCase('d0cf11e0a1'))
			{
           		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,System.Label.CW_Error_BinaryFile));
	            csvFile=null;
	            filename=null;
	            return null;
         	}
         	
         	String fileContent=csvFile.toString();
         	List<String> lines = new List<String>();
            
         	for(Integer sp: notAllowedChr)
         	{
           		List<Integer> oneChar=new list<Integer>();
           		oneChar.Add(sp);
           		String spChar=String.fromCharArray(oneChar);
           		if(fileContent.IndexOf(spChar)>0)
           		{
             		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,System.Label.CW_Error_InvalidChar));
             		return null;
           		}
         	}       
         
           	batchReader = new CSVBatchReader(fileContent,campaignId, selectedSchId);

       	}catch(Exception Ex){
         	ApexPages.addMessages(ex);
         	csvFile=null;
         	filename=null;
         	return null;
       	}
       	
       	csvFile = null;
       	batchJobId = Database.executeBatch(batchReader,BATCH_SIZE);
       	return loadBatchJobProgressPage();
    }
    
    public Pagereference loadBatchJobProgressPage()
    {
        Pagereference progressPage = Page.CW_BatchJobProgressPage;
        progressPage.setRedirect(true);
        progressPage.getParameters().put(ConstantUtil.PAGEPARAM_BATCHJOBID,batchJobId);
        progressPage.getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,campaignId);
        
        return progressPage;
    }
 
    
    /*** static methods for processing records ***/
    
    // CSV only contains group name
    public static void processGroups(List<List<string>> csvLines, Id campaignId,Id scheduleId)
    {
        List<CW_Audience_Group__c> aGroups = new List<CW_Audience_Group__c>();
        List<Account> accounts = new List<Account>();

        Set<String> groupNames = new Set<String>();
        Set<String> accountNames = new Set<String>();
        Set<String> agsCompKey = new Set<String>();
		//get record type id from person accont
        Id personAccountRTId = [select id from RecordType where SobjectType = 'Account' AND IsPersonType = true limit 1].id;
        Schema.SObjectField agExternalField = CW_Audience_Group__c.Fields.CompositeKey__c ;
        groupsIdMap = createGroupsIdMap(campaignId); 
        //loop through the file uploaded
        for(List<String> flds : csvLines)
        {
        	//get group and account name from the file
            String groupName = flds.get(ConstantUtil.CSV_GROUP_NAME_COLUMN);
            String accountName = flds.get(ConstantUtil.CSV_ACCOUNT_PLAYER_ID_COLUMN);
			//create new group if  name is not blank or was already created
            if(groupName!='' && !groupNames.contains(groupName))
            {
            	if (!groupsIdMap.containsKey(groupName))
            	{
	                CW_Audience_Group__c aGroup = new CW_Audience_Group__c(Campaign__c = campaignId);
	                aGroup.Name = groupName;
	                aGroup.CompositeKey__c = campaignId+groupName;
	               	//add group name to the list of groups that will be upserted later
	                aGroups.add(aGroup);
            	}
            	groupNames.add(groupName);
            }
            
            //create new account if name is not blank or was already inserted 
            if (accountName!='' && !accountNames.contains(accountName))
            {
            	//create new account and add it to the set of strings so we can get the contact created by the person account
            	Account account = createAccount(accountName,personAccountRTId);
                accountNames.add(accountName);
                accounts.add(account);
            }
        } 
        
        //upsert all groups and acconts added to the file      
	    Database.UpsertResult[] agResults = Database.upsert(aGroups,agExternalField ,false);
	    
	    for(Database.UpsertResult srRecord: agResults)
        {
            if(srRecord.isSuccess())
            {
                System.debug('AGM Id is '+srRecord.getId());
            }
            else
            {
                for(Database.Error err : srRecord.getErrors()) 
                {
                    System.debug('So Error is '+err.getStatusCode() + ': ' + err.getMessage());   
                    System.debug('Fields that affected this error: ' + err.getFields()); 
                }
            }
        }
        
	    Database.UpsertResult[] accResults = Database.upsert(accounts,false);
	    
	    //create group,contacts and audience group schedule maps 
	    groupsIdMap = createGroupsIdMap(campaignId);
	    contactsIdMap = createContactsIdMap(accountNames);
	    agsIdMap = createAgsIdMap(groupNames);
    }
    
    /**/
    
    // CSV contains Account.Palyer_Id__c and CW_Audience_Group__r.Name
    public static void processGroupMembers(List<List<string>> csvLines, Id campaignId,Id scheduleId)
    {
        List<CW_Audience_Group_Member__c> aMembers = new List<CW_Audience_Group_Member__c>();
        Set<String> groupNames = new Set<String>();
        Set<String> dedup = new Set<String>();  // store combination of group and playerId for de-dup
        Schema.SObjectField agmExternalField = CW_Audience_Group_Member__c.Fields.CompositeKey__c ;
        
        for(List<String> flds : csvLines)
        {
        	if (flds.get(ConstantUtil.CSV_ACCOUNT_PLAYER_ID_COLUMN)!='')
        	{
	            CW_Audience_Group_Member__c aMember = new CW_Audience_Group_Member__c();
	            // this will need to be looked up from the database
	            aMember.Audience_Group_LU__c = groupsIdMap.get(flds.get(ConstantUtil.CSV_GROUP_NAME_COLUMN));
	            // get contact id using the accont name from the csv file
	            aMember.Contact__c = contactsIdMap.get(flds.get(ConstantUtil.CSV_ACCOUNT_PLAYER_ID_COLUMN));
	            //create audience group member composite key
	            aMember.CompositeKey__c = flds.get(ConstantUtil.CSV_ACCOUNT_PLAYER_ID_COLUMN)+flds.get(ConstantUtil.CSV_GROUP_NAME_COLUMN)+scheduleId;
	            //create ags composite key to get the id of the ags from the agsIdMap
	            String agsCompositeKey = flds.get(ConstantUtil.CSV_GROUP_NAME_COLUMN)+scheduleId;
	            aMember.Audience_Group_Schedule__c = agsIdMap.get(agsCompositeKey);
	            aMembers.add(aMember);
        	}
            
        }
        csvLines = null;
		//upsert list of members added to the csv file
        Database.UpsertResult[] sr = Database.upsert(aMembers,agmExternalField,false);        
        for(Database.UpsertResult srRecord: sr)
        {
            if(srRecord.isSuccess())
            {
                System.debug('AGM Id is '+srRecord.getId());
            }
            else
            {
                for(Database.Error err : srRecord.getErrors()) 
                {
                    System.debug('So Error is '+err.getStatusCode() + ': ' + err.getMessage());   
                    System.debug('Fields that affected this error: ' + err.getFields()); 
                }
            }
        }
    }
    
    /*** CREATE MAPS TO HELP UPLOAD GROUP MEMBERS ***/
    
    //create group map to get the group id based on the group name added to the csv file
	public static Map<String,Id> createGroupsIdMap(Id campaignId)
    {
    	groupsIdMap = new Map<String,Id>();
    	
        for(CW_Audience_Group__c ag : [select id, Name from CW_Audience_Group__c where Campaign__c = :campaignId])
        {
            groupsIdMap.put(ag.Name,ag.Id);
        }
        
        return groupsIdMap;
    }
    
    //create audience group schedule mao based on the group names added to the csv file and schedule id selected before upload
    public static Map<String,Id> createAgsIdMap(Set<String> groupNames)
    {
    	agsIdMap = new Map<String,Id>();
    	
        for(CW_Audience_Group_Schedule__c ags : [SELECT ID,CompositeKey__c,Audience_Group__r.Name FROM CW_Audience_Group_Schedule__c where Audience_Group__r.Name In :groupNames])
        {
            agsIdMap.put(ags.CompositeKey__c,ags.Id);
        }
        
        return agsIdMap;
    }
    
    //create contact map based on the account names added to the csv file 
    public static Map<String,Id> createContactsIdMap(Set<String> accNames)
    {
    	contactsIdMap = new Map<String,Id>();
        for(Contact acc : [select id, LastName from Contact where Account_Name__c IN :accNames])
        {
            contactsIdMap.put(acc.LastName,acc.Id);
        }
        return contactsIdMap;
    }
    
    //create person account based on the account Names added to the csv file and person accont recordtype id
	public static Account createAccount(String accountName, Id personAccountRTId)
	{
        Account acc = new Account();
        acc.FirstName = accountName;
        acc.LastName = accountName;
        acc.Account_Name__pc = accountName;
        acc.RecordtypeId = TestDataUtil.personAccountRTId;
        acc.Requires_Update__pc = true;
        
        return acc;       
	}

}