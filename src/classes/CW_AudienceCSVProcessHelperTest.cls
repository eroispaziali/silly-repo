/**
* File Name   :	CW_AudienceCSVProcessHelperTest.cls
* Description :	tests CW_AudienceCSVProcessHelper and CSVBatchProess
*
* Modification Log
* ============================================================================
* Ver Date	   Author		 Modification
* --- ---------- -------------- --------------------------
* 0.1 20/05/2014 Alex Panka     Initial version

*
*/
@isTest
private class CW_AudienceCSVProcessHelperTest {
	
	 public static String csvFile='Group Name,Account Name \nC2,1\nC2,2\nT3,3\nT3,4\nT4,5\nT4,6';
	
	
	static testMethod void UploadBatchOnly()
	{
		//Nothibg to test just for build. Then we make rarl tests
		CW_Campaign__c CampRec=TestDataUtil.getCampaign();
		insert CampRec;
		CW_Schedule__c sch = TestDataUtil.createSchedule(CampRec);
		insert sch;
		CW_CSV_Import_Status__c statRec = new CW_CSV_Import_Status__c(Marketing_Campaign__c= CampRec.ID);
		insert statRec;
		// Now import records - All a rejected s there no schedule/ rewards
		//==============================================================
		CSVBatchReader batchJobRead = new CSVBatchReader(csvFile, CampRec.Id,sch.Id);
    	Test.StartTest();
      	Database.executeBatch(batchJobRead);
  		Test.StopTest();
	}
	

	static testMethod void ProcessBatchOnly()
	{
		//Nothibg to test just for build. Then we make rarl tests
		CW_Campaign__c CampRec=TestDataUtil.getCampaign();
		insert CampRec;
		CW_CSV_Import_Status__c statRec = new CW_CSV_Import_Status__c(Marketing_Campaign__c= CampRec.ID);
		insert statRec;
		// Now import records - All a rejected s there no schedule/ rewards
		//==============================================================
		//CW_AudienceCSVProcessHelper ProcHelper= new CW_AudienceCSVProcessHelper(statRec.Id);
		List<CW_CSV_Stage_AudienceMembers__c> csvLst=new List<CW_CSV_Stage_AudienceMembers__c>();
		
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p1',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p2',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p3',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p4',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g3',PlayerId__c='p2',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g3',PlayerId__c='p4',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ) );
		// Rows that thont afect process ( duplicates )
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p2',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p3',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p4',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ) );
		// NO Free Bet no upload
		
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p3',FreeBetId__c='fb2',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p4',FreeBetId__c='fb2',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p1',FreeBetId__c='fb3',CSV_Import_Status__c =statRec.Id ) );
		
		insert csvLst;
		
		
    	Test.StartTest();
		CSVBatchProcess batchJobProcess = new CSVBatchProcess(statRec.ID,CSVBatchProcess.ProcesTypes.CreateAccounts);
		Database.executeBatch(batchJobProcess);

      	Test.StopTest();

	}
  
  
  	static testMethod void ProcessImport()
	{
		//Nothibg to test just for build. Then we make rarl tests
		CW_Campaign__c CampRec=TestDataUtil.getCampaign();
		insert CampRec;
		CW_Schedule__c shedRec=TestDataUtil.createSchedule(CampRec);
		insert shedRec;
		CW_Offer_Type__c  trgRec= TestDataUtil.createOfferType('Trigger');
		insert trgRec;
	
		CW_Reward_Type__c  rewTypRec=TestDataUtil.createRewardType('Reward');
		insert rewTypRec;

		CW_Reward_Catalogue__c rewCatRec=TestDataUtil.createRewardCatalogue(trgRec.Id, rewTypRec.Id);
		insert rewCatRec;
	
		CW_Reward_Library__c librec=TestDataUtil.createRewardLibrary(rewTypRec.Id);
		librec.FreeBet_Id__c='fb1';
		insert librec;
		
		CW_CSV_Import_Status__c statRec = new CW_CSV_Import_Status__c(Marketing_Campaign__c= CampRec.ID,Schedule__c=shedRec.Id,Reward_Catalogue__c=rewCatRec.id);
		insert statRec;
		// Now import records - All a rejected s there no schedule/ rewards
		//==============================================================
		//CW_AudienceCSVProcessHelper ProcHelper= new CW_AudienceCSVProcessHelper(statRec.Id);
		List<CW_CSV_Stage_AudienceMembers__c> csvLst=new List<CW_CSV_Stage_AudienceMembers__c>();
		
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p1',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id,Reward_Library__c=librec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p2',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id,Reward_Library__c=librec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p3',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id,Reward_Library__c=librec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p4',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id,Reward_Library__c=librec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g3',PlayerId__c='p2',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id,Reward_Library__c=librec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g3',PlayerId__c='p4',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id,Reward_Library__c=librec.Id ) );
		
		
		// Rows that thont afect process ( duplicates )
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p2',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ,Reward_Library__c=librec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p3',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ,Reward_Library__c=librec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p4',FreeBetId__c='fb1',CSV_Import_Status__c =statRec.Id ,Reward_Library__c=librec.Id ) );
		// NO Free Bet no upload
		
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p3',FreeBetId__c='fb2',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g1',PlayerId__c='p4',FreeBetId__c='fb2',CSV_Import_Status__c =statRec.Id ) );
		csvLst.Add(new CW_CSV_Stage_AudienceMembers__c(Group_Name__c ='g2',PlayerId__c='p1',FreeBetId__c='fb3',CSV_Import_Status__c =statRec.Id ) );
		insert csvLst;
		
		//ProcHelper.processCreateSheildAccounts(csvLst);
		//ProcHelper.processCreateAudienceGroups(csvLst);
		/*System.AssertEquals(12, database.countquery('SELECT COUNT()  FROM CW_CSV_Stage_AudienceMembers__c WHERE Contact_ref__c<>null')); 
		System.AssertEquals(12, database.countquery('SELECT COUNT()  FROM CW_CSV_Stage_AudienceMembers__c WHERE Audience_Group_ref__c<>null'));
		System.AssertEquals(9, database.countquery('SELECT COUNT()  FROM CW_CSV_Stage_AudienceMembers__c WHERE Reward_Library__c<>null'));

		System.AssertEquals(3, database.countquery('SELECT COUNT()  FROM CW_Audience_Group__c ')); 
		System.AssertEquals(4, database.countquery('SELECT COUNT()  FROM Contact '));
		
    	Test.StartTest();
		CSVBatchProcess batchJobProcess = new CSVBatchProcess(statRec.ID,CSVBatchProcess.ProcesTypes.ImportRecords);
		Database.executeBatch(batchJobProcess);


      Test.StopTest();
      
      //System.AssertEquals(3, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Schedule_Reward__c ')); 
		System.AssertEquals(6, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Member__c '));
		System.AssertEquals(6, database.countquery('SELECT COUNT()  FROM CW_Audience_Group_Member_Reward__c '));*/
		
		
	}
}