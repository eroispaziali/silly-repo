/**
* File Name   :	CW_AudienceCSVUploadControllerTest.cls
* Description :	tests CW_AudienceCSVUploadController.cls, CSVIterable.cls, CSVBatchReader,cls
*
* Modification Log
* ============================================================================
* Ver Date	   Author		 Modification
* --- ---------- -------------- --------------------------
* 0.1 02/04/2014 Klea Kolaric	Initial version
* 0.2 15/04/2014 Klea Kolaric	Changes due to Audience Group Schedule
*
*
*/
@isTest
private class CW_AudienceCSVUploadControllerTest 
{
	static testMethod void quickScheduleTest()
	{
		// test that closest schedule is picked up by default
		
		Account acc = TestDataUtil.createPersonAccount();
		insert acc;
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
		// insert default schedule
		CW_Schedule__c sch1 = TestDataUtil.createSchedule(camp);
		insert sch1;
		// insert later schedule
		CW_Schedule__c sch2 = TestDataUtil.createSchedule(camp);
		sch2.Start_Date__c = sch1.Start_Date__c.addDays(+2);
		sch2.End_Date__c = sch1.End_Date__c.addDays(-2);
		sch2.Evaluation_Start_Date__c = sch2.Start_Date__c;
		sch2.Evaluation_End_Date__c = sch2.End_Date__c;
		insert sch2;
		
		// insert group
		CW_Audience_Group__c audGr1 = TestDataUtil.createAudienceGroup(camp.Id);
		audGr1.Name = group1;
		audGr1.Is_Control_Group__c = false;
		insert audGr1;
		
		CW_Audience_Group_Schedule__c ags1 = [Select Id from CW_Audience_Group_Schedule__c where Audience_Group__c =: audGr1.id and Schedule__c =:sch1.Id];
		
		Test.startTest();
		CW_Audience_Group_Member__c agm = new CW_Audience_Group_Member__c();
		agm.Audience_Group_LU__c = audGr1.Id;
		agm.Contact__c = [select id from Contact where AccountId = :acc.Id limit 1].Id;
		agm.Audience_Group_Schedule__c = ags1.Id;
		insert agm;
		Test.stopTest();
		
		System.assertEquals(1,[select count() from CW_Audience_Group_Member__c where id = :agm.Id and Audience_Group_Schedule__c = :ags1.Id]);
	}

	static testMethod void parseGroupsAndMembers()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		Test.startTest();
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.id;
		uc.csvFile = Blob.valueOf(groupCSVString);
		uc.filename='Somefile.csv';
		uc.uploadCSV();
		//uc.returnToAudiencePage();
		Test.stopTest();
		
		// 6 new accounts were added
		system.assertEquals(6,[select count() from Contact where Account_Name__c != :null]);
		// 5 new groupss were added
		system.assertEquals(5,[select count() from CW_Audience_Group__c where Campaign__c = :camp.Id]);
		// 2 members where added to group1
		system.assertEquals(2,[select count() from CW_Audience_Group_Member__c where Audience_Group_LU__r.Name = :group1]);
		// 1 members where added to group2
		system.assertEquals(1,[select count() from CW_Audience_Group_Member__c where Audience_Group_LU__r.Name = :group2]);
		// 1 members where added to group3
		system.assertEquals(1,[select count() from CW_Audience_Group_Member__c where Audience_Group_LU__r.Name = :group3]);
		// 1 members where added to group4
		system.assertEquals(1,[select count() from CW_Audience_Group_Member__c where Audience_Group_LU__r.Name = :group4]);
		// 1 members where added to group5
		system.assertEquals(1,[select count() from CW_Audience_Group_Member__c where Audience_Group_LU__r.Name = :group5]);
		
	}
	
	static testMethod void parseGroupsAndMembersBatch()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		String memebrsCSVString = 'Group Name,Account Name' + CSVReader.lineTerminator;
		
		for(Integer i=1; i<=1000; i++)
		{
			
			String playerId = 'shl' + i;
			memebrsCSVString += (i <= 500 ? group1 : group2) + ',' + playerId + CSVReader.lineTerminator;
		}
		memebrsCSVString = memebrsCSVString.removeEnd(CSVReader.lineTerminator);
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		Test.startTest();
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.Id;
		uc.csvFile = Blob.valueOf(memebrsCSVString);
		uc.filename='Somefile.csv';
		uc.uploadCSV();
		uc.loadBatchJobProgressPage();
		Test.stopTest();
		system.assertEquals(1000,[select count() from Contact where Account_Name__c != :null]);
		// 2 new groups were added
		system.assertEquals(2,[select count() from CW_Audience_Group__c where Campaign__c = :camp.Id]);
		system.assertEquals(500,[select count() from CW_Audience_Group_Member__c where Audience_Group_LU__r.Name = :group1]);
		system.assertEquals(500,[select count() from CW_Audience_Group_Member__c where Audience_Group_LU__r.Name = :group2]);
	}
	
	static testMethod void parseFaultyGroups()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		CW_Audience_Group__c audGr5 = TestDataUtil.createAudienceGroup(camp.Id);
		audGr5.Name = group5;
		audGr5.Is_Control_Group__c = true;
		insert audGr5;
		
		CW_Audience_Group__c audGr1 = TestDataUtil.createAudienceGroup(camp.Id);
		audGr1.Name = group1;
		audGr1.Is_Control_Group__c = false;
		audGr1.Control_Group__c = audGr5.id;
		insert audGr1;
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		Boolean exceptionHappend = false;
		
		String faultyCSVString = 'group name,account name' + CSVReader.lineTerminator;
		
		faultyCSVString += 'group3,' + CSVReader.lineTerminator;
		faultyCSVString += group2 + ',333333';
		
		Test.startTest();
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.Id;
		//try to upload the file with blank fields
		try{
			uc.csvFile = Blob.valueOf(faultyCSVString);
			uc.filename='FaultyFile.csv';
			List<List<string>> csvLines = CSVReader.readCSVFile(faultyCSVString);
		}
		catch(Exception e)
        {
        	exceptionHappend = true;
        }
		Test.stopTest();
		
		// none of the groups or members gets uploaded if file contains null values
		system.assertEquals(2,[select count() from CW_Audience_Group__c where Campaign__c = :camp.Id]);
		// assert no empty name group
		system.assertEquals(0,[select count() from CW_Audience_Group__c where (not Name like 'Group%')]);
		// assert skip of duplicate group
		system.assertEquals(0,[select count() from CW_Audience_Group__c 
								where Campaign__c = :camp.Id and Name = :group2]);
		
	}
	
	static testMethod void parseFaultyMembers()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		List<Account> accs = new List<Account>();
		for (Integer i=0;i<5;i++)
		{
			Account acc = TestDataUtil.createPersonAccount();
			acc.Account_Name__pc = 'TestAccountName' + i;
			accs.add(acc);
		}
		insert accs;
		
		
		CW_Audience_Group__c audGr1 = TestDataUtil.createAudienceGroup(camp.Id);
		audGr1.Name = group1;
		audGr1.Is_Control_Group__c = false;
		insert audGr1;
		
		CW_Audience_Group_Schedule__c ags = [SELECT Id, Audience_Group__c 
											 FROM CW_Audience_Group_Schedule__c 
											 WHERE Audience_Group__c=: audGr1.Id
											 AND Schedule__c =: sch.Id];
		
		String memebrsCSVString = 'Group Name,Account Name' + CSVReader.lineTerminator;
		
		// create existing member for account 1
		insert new CW_Audience_Group_Member__c(Audience_Group_LU__c = audGr1.Id, 
					Contact__r = new Contact(Account_Name__c = accs[0].Account_Name__pc),
					Audience_Group_Schedule__c = ags.Id);
					
		// add duplicate to CSV for account 2
		memebrsCSVString += audGr1.Name + ',' + accs[1].Account_Name__pc + CSVReader.lineTerminator;
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		Test.startTest();
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.Id;
		uc.csvFile = Blob.valueOf(memebrsCSVString);
		uc.filename='Somefile.csv';
		uc.uploadCSV();
		uc.loadBatchJobProgressPage();
		Test.stopTest();
		
		system.assertEquals(1,[select count() from CW_Audience_Group_Member__c where Audience_Group_LU__c = :audGr1.Id]);
		// assert there are no duplicates
		system.assertEquals(1,[select count() from CW_Audience_Group_Member__c 
			where Contact__r.Account_Name__c = :accs.get(0).Account_Name__pc]);
	}
	
	static testMethod void parseLFLineTerminator()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		system.assertNotEquals(ConstantUtil.LF,CSVReader.lineTerminator);
		String stringLFCSV = groupCSVString.replace(CSVReader.lineTerminator,ConstantUtil.LF);
		
		Test.startTest();
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.Id;
		uc.csvFile = Blob.valueOf(stringLFCSV);
		uc.filename='Somefile.csv';
		uc.uploadCSV();
		Test.stopTest();
		
		system.assertEquals(5,[select count() from CW_Audience_Group__c where Campaign__c = :camp.Id]);
	}
	
	static testMethod void parseCFLineTerminator()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		system.assertNotEquals(ConstantUtil.CR,CSVReader.lineTerminator);
		String stringCRCSV = groupCSVString.replace(CSVReader.lineTerminator,ConstantUtil.CR);
		
		Test.startTest();
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.Id;
		uc.csvFile = Blob.valueOf(stringCRCSV);
		uc.filename='Somefile.csv';
		uc.uploadCSV();
		Test.stopTest();
		
		system.assertEquals(5,[select count() from CW_Audience_Group__c where Campaign__c = :camp.Id]);
	}
	
	static testMethod void parseColonSeparatedGroups()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		CW_Audience_Group__c audGr2 = TestDataUtil.createAudienceGroup(camp.Id);
		audGr2.Name = group2;
		audGr2.Is_Control_Group__c = false;
		insert audGr2;
		
		CW_Audience_Group__c audGr5 = TestDataUtil.createAudienceGroup(camp.Id);
		audGr5.Name = group5;
		audGr5.Is_Control_Group__c = true;
		insert audGr5;
		
		system.assertEquals(2,[select count() from CW_Audience_Group__c where Campaign__c = :camp.Id]);
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		
		Test.startTest();
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.Id;
		uc.csvFile = Blob.valueOf(groupCSVString.replace(',',':'));	// replace commas with colons
		uc.filename='Somefile.csv';
		uc.uploadCSV();
		Test.stopTest();
		
		// 3 new records were added because of the new separator
		system.assertEquals(5,[select count() from CW_Audience_Group__c where Campaign__c = :camp.Id]);
		// group 2 wasn't added again since was previously created
		system.assertEquals(1,[select count() from CW_Audience_Group__c 
								where Campaign__c = :camp.Id and Name = :group2]);
		// group 5 wasn't added again since was previously created
		system.assertEquals(1,[select count() from CW_Audience_Group__c 
								where Campaign__c = :camp.Id and Name = :group5]);
	}
	
	static testMethod void TestErrors_FileMising()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_OBJECTTYPE,ConstantUtil.PAGEPARAMVAL_AUDIENCE_GROUP);
		
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.Id;
		system.assertEquals(null,uc.uploadCSV());
	  	system.assertEquals(ApexPages.getMessages()[0].getSummary(),System.Label.CW_Error_FileNameMissing);
	}
	
 	static testMethod void TestErrors_FileBinary()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_OBJECTTYPE,ConstantUtil.PAGEPARAMVAL_AUDIENCE_GROUP);
		
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.Id;
		uc.csvFile =Blob.valueOf(String.fromCharArray(new List<Integer>{ 80,75,3,34,1,1,1,1,1,11,1}));
		uc.filename='Somefile.csv';
		
		system.assertEquals(null,uc.uploadCSV());
		system.assertEquals(System.Label.CW_Error_BinaryFile,ApexPages.getMessages()[0].getSummary());

	}
	
	static testMethod void TestErrors_InvalidChar()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
		insert camp;
		CW_Schedule__c sch = TestDataUtil.createSchedule(camp);
		insert sch;
		
		Test.setCurrentPage(Page.CW_AudienceCSVUpload);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_OBJECTTYPE,ConstantUtil.PAGEPARAMVAL_AUDIENCE_GROUP);
	
		CW_AudienceCSVUploadController uc = new CW_AudienceCSVUploadController();
		uc.selectedSchId = sch.Id;
		uc.csvFile =Blob.valueOf(groupCSVString+String.fromCharArray(new List<Integer>{ 2,17,25}));
		uc.filename='Somefile.csv';
	
		system.assertEquals(null,uc.uploadCSV());

	}
	/*** helper variables/methods ***/
	
	static final String group1 = 'Group1';
	static final String group2 = 'Group2';
	static final String group3 = 'Group3';
	static final String group4 = 'Group4';
	static final String group5 = 'Group5';
	
	static final String groupCSVString = 'Group Name,Account Name' + CSVReader.lineTerminator	// header
				+ group1 + ',Member1' + CSVReader.lineTerminator	
				+ group1 + ',Member2' + CSVReader.lineTerminator	
				+ group2 + ',Member3' + CSVReader.lineTerminator	
				+ group3 + ',Member4' + CSVReader.lineTerminator	
				+ group4 + ',Member5' + CSVReader.lineTerminator	
				+ group5 + ',Member6';	
}