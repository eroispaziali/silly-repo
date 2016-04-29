/**
* File Name   :    CW_TaskControllerTest.cls
* Description :    Test Class for CW_TaskController.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 07/04/2014 Chris Yorkston	Initial version
* 0.2 31/07/2014 Cristina P		Help Center
*
*
*/

@isTest
private class CW_TaskControllerTest
{
	@isTest static void testCreateTask()
	{

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		Group taskQueue = [SELECT Id FROM Group WHERE Name = :ConstantUtil.TASK_QUEUE AND Type =: ConstantUtil.PAGEPARAM_QUEUE];

		System.runAs(thisUser){

			CW_Campaign__c camp = TestDataUtil.createCampaign();
			insert camp;

			CW_Task__c newTask = new CW_Task__c();

			PageReference pageRef = Page.CW_New_Task; //Use the PageReference Apex class to instantiate a page

			Test.setCurrentPage(pageRef); //In this case, the Visualforce page named 'success' is the starting point of this test method.
			Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID, camp.Id);
			CW_TaskController controller = new CW_TaskController();
			controller.getNewCampTask();

	        controller.newTask.Name = 'Test Task Name';
	        controller.newTask.Details__c = TestDataUtil.getRandomAlphaString(10);
	        controller.newTask.Due_Date__c = Date.today() + (Integer)TestDataUtil.getRandomNumber();

	        //system.assertEquals(false, controller.closeDialog); // assert false, only close modal when task saved
	        system.assertEquals(camp.Id, controller.newTask.Marketing_Campaign__c); // assert task associated to a campaign
	        system.assertEquals(taskQueue.Id, controller.newTask.OwnerId); // default owner should be relevant queue
	        system.assertEquals(thisUser.Id, controller.newTask.Requestor__c); // default requestor should be the logged in user

	        // save task
	        controller.saveTask();

	        system.assertEquals(true, controller.closeDialog); // assert true, close modal when task saved
	        CW_Task__c insertedTask = [select Id, Name, Status__c from CW_Task__c where Marketing_Campaign__c = :camp.Id];
	        system.assertEquals(true, insertedTask!=null);
	        system.assertEquals('Not Started', insertedTask.Status__c); // assert Not Started as task is new
	        system.assertEquals('Test Task Name', insertedTask.Name); // assert 'Test Task Name' as task NAME
		}
	}

	// campaign exists, edit existing tasks linked to campaign
	@isTest static void testEditTask() {

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		Group taskQueue = [SELECT Id FROM Group WHERE Name = :ConstantUtil.TASK_QUEUE AND Type =: ConstantUtil.PAGEPARAM_QUEUE];

		System.runAs(thisUser)
		{
			CW_Campaign__c camp = TestDataUtil.createCampaign();
			insert camp;

			List<CW_Task__c> campTasks = new List<CW_Task__c>();
			for (Integer i=0;i<3;i++)
			{
				campTasks.add(TestDataUtil.createTask(camp.Id, taskQueue.Id, thisUser.Id));
			}
			insert campTasks;

			PageReference pageRef = Page.CW_New_Task; //Use the PageReference Apex class to instantiate a page

			Test.setCurrentPage(pageRef); //In this case, the Visualforce page named 'success' is the starting point of this test method.

			Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID, camp.Id);
			Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_TASK_ID, campTasks[0].Id);
	        CW_TaskController controller = new CW_TaskController();
	        controller.getFields();

	        system.assertEquals(campTasks[0].Status__c, controller.taskToEdit.Status__c); // status should be not started
	        system.assertEquals(campTasks[0].Details__c, controller.taskToEdit.Details__c); // description field should refrect on edit mode page

	        controller.taskToEdit.Details__c = 'Details have been changed';
	        controller.taskToEdit.Status__c = 'In Progress';

	        // update task
	        controller.updateTask();

	        system.assertEquals(true, controller.closeDialog); // assert true, close modal when task saved
	        CW_Task__c updatedTask = [select Id, Name, Status__c,Details__c from CW_Task__c where Id = :Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_TASK_ID)];
	        system.assertEquals(true, updatedTask!=null);
	        system.assertEquals('In Progress', updatedTask.Status__c); // assert Not Started as task is new
	        system.assertEquals('Details have been changed', updatedTask.Details__c); // assert Not Started as task is new

	        controller.taskId = campTasks[1].Id;
	        controller.cancelTask();

	        CW_Task__c canceledTask = [select Id, Name, Status__c from CW_Task__c where Id = :controller.taskId];
	        system.assertEquals('Cancel', canceledTask.Status__c); // assert Not Started as task is new
		}
	}


	// campaign exists, edit existing tasks linked to campaign
	@isTest static void testDownloadTemplates() {

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		Group taskQueue = [SELECT Id FROM Group WHERE Name = :ConstantUtil.TASK_QUEUE AND Type =: ConstantUtil.PAGEPARAM_QUEUE];
    	User cimUser = new User();

		System.runAs(thisUser)
		{
			UserRole cimRole = TestDataUtil.createRole('CIM');

	    	cimUser = TestDataUtil.getUserWithProfileName('System Administrator');
	    	cimUser.UserRoleId = cimRole.Id;
	    	cimUser.Department = 'Sport';
	    	insert cimUser;
		}

		System.runAs(cimUser)
		{
			HelpCentreUsefulLinks__c templates = new HelpCentreUsefulLinks__c();
			templates.Name = 'Audience Template';
			templates.URL__c = '/';
			templates.Description__c = 'Template description';
			insert templates;

			CW_Campaign__c camp = TestDataUtil.createCampaign();
			insert camp;

			List<CW_Task__c> campTasks = new List<CW_Task__c>();
			for (Integer i=0;i<3;i++)
			{
				campTasks.add(TestDataUtil.createTask(camp.Id, taskQueue.Id, thisUser.Id));
			}
			insert campTasks;

			PageReference pageRef = Page.CW_Help_Centre; //Use the PageReference Apex class to instantiate a page

			Test.setCurrentPage(pageRef); //In this case, the Visualforce page named 'success' is the starting point of this test method.

			Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID, camp.Id);
	        CW_TaskController controller = new CW_TaskController();

	        controller.URL = templates.URL__c;
	        controller.downloadTemplates();

	        List<HelpCentreUsefulLinks__c> temps = new List<HelpCentreUsefulLinks__c>();
	        temps = controller.getUsefulTemplates();

	        system.assertEquals(false,controller.canUserCreate);//cim or Bi user cannot create new tasks from wizard
	       	system.assertEquals(1,temps.size());
		}
	}

	@isTest static void testUploadAttachment()
	{
		CW_Campaign__c camp = TestDataUtil.createCampaign();
        insert camp;

        Test.setCurrentPage(Page.CW_Upload_Campaign_Attachment);

        Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPAIGNID,camp.Id);
		CW_WizardController wizRu = new CW_WizardController();

    	wizRU.attachment.Name = 'test attachment';
    	wizRU.attachment.Body = Blob.valueOf(file);
    	wizRU.attachment.Description = 'test attach';

    	wizRU.uploadFile();

    	List<Attachment> attachments = [SELECT id, name FROM Attachment WHERE parent.id =: camp.Id];
        system.assertEquals(1, attachments.size());

        Test.setCurrentPage(Page.CW_Help_Centre);

        Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID,camp.Id);
		CW_TaskController taskCtrl = new CW_TaskController();

		taskCtrl.getCampaignAttach(camp.Id);
		system.assertEquals(1,taskCtrl.campAttachs.size());

		taskCtrl.attachId = attachments[0].Id;
		taskCtrl.deleteAttach();
		attachments = [SELECT id, name FROM Attachment WHERE parent.id =: camp.Id];
       	system.assertEquals(0,attachments.size());
	}
	@isTest static void testsubmitForMessagingDatesApproval()
	{

		   if(Schema.sObjectType.CW_Messaging__c.FieldSets.getMap().containsKey(TestDataUtil.MAILER))
        	{
            	CW_WizardBrandLabelUtilTest.dataSetup();
            	CW_WizardAssetUtilTest.dataSetup();
	            CW_Campaign__c camp = TestDataUtil.createCampaign();
    	        insert camp;
        	    CW_WizardAssetUtilTest.associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
            	CW_WizardAssetUtilTest.addAllAssetTypesToCampaign(camp.Id);

            	// create asset selection on campaign

            	CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c();
            	ca.Campaign__c = camp.Id;

            	ca.Asset__c = [select id from CW_Asset__c where Name = :(TestDataUtil.MAILER+' '+TestDataUtil.BASIC) limit 1].id;
           		 insert ca;

	          	  List<CW_Localised_Asset__c> loc = new List<CW_Localised_Asset__c>();
	           	  Id enId = [select id from CW_Language__c where Name = :TestDataUtil.EN limit 1].id;

	           	  for(CW_Asset_Catalogue__c ac : [select id from CW_Asset_Catalogue__c where Asset__c = :ca.Asset__c])
	           		 {
		                CW_Localised_Asset__c la = new CW_Localised_Asset__c();
		                la.Campaign_Asset__c = ca.Id;
		                la.Asset_Catalogue__c = ac.Id;
		                la.Language__c = enId;
		                loc.add(la);
	           		 }
	            	insert loc;

	            // pre add messaging object
	            CW_Messaging__c msg1 = new CW_Messaging__c(Campaign__c=camp.Id,Campaign_Asset__c = ca.Id, Dispatch_Date__c = Date.Today().addDays(2));
	            insert msg1;
	            msg1.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED;
	            update msg1;


	            Test.setCurrentPage(Page.CW_Campaign_Asset_Details);
	            Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPASSETID,ca.Id);
	            Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE,'false');
				 ApexPages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID,camp.Id);

	            Test.startTest();
	  		 	CW_TaskController taskController=new CW_TaskController();
	  		 		taskController.assetType=ConstantUtil.ASSET_TYPE_NAME;
	 		  	taskController.submitForMessagingDatesApproval();

	 		 	Test.stopTest();
	    	  	system.assertEquals(1, [select count()  from CW_Campaign__c where Id  =:camp.Id and Mailer_Messaging_Approval_Status__c=:ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL]);
	    	  	Integer count= [select count()  from CW_Messaging__c where Campaign__c=:camp.Id and Id=:msg1.Id and Campaign_Asset__c =: ca.Id ];
		      	system.assertEquals(count, [select count()  from CW_Messaging__c where Campaign__c=:camp.Id and Id=:msg1.Id and Campaign_Asset__c =: ca.Id and Approval_Status__c=:ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL]);
        	}
	}
	@isTest static void testrecallMessagingDatesApproval()
	{

		   if(Schema.sObjectType.CW_Messaging__c.FieldSets.getMap().containsKey(TestDataUtil.MAILER))
        	{
            	CW_WizardBrandLabelUtilTest.dataSetup();
            	CW_WizardAssetUtilTest.dataSetup();
	            CW_Campaign__c camp = TestDataUtil.createCampaign();
    	        insert camp;
        	    CW_WizardAssetUtilTest.associateSiteCataloguesToCampaign(TestDataUtil.getAssetTypeList(), camp.Id);
            	CW_WizardAssetUtilTest.addAllAssetTypesToCampaign(camp.Id);

            	// create asset selection on campaign

            	CW_Campaign_Asset__c ca = new CW_Campaign_Asset__c();
            	ca.Campaign__c = camp.Id;

            	ca.Asset__c = [select id from CW_Asset__c where Name = :(TestDataUtil.MAILER+' '+TestDataUtil.BASIC) limit 1].id;
           		 insert ca;

	          	  List<CW_Localised_Asset__c> loc = new List<CW_Localised_Asset__c>();
	           	  Id enId = [select id from CW_Language__c where Name = :TestDataUtil.EN limit 1].id;

	           	  for(CW_Asset_Catalogue__c ac : [select id from CW_Asset_Catalogue__c where Asset__c = :ca.Asset__c])
	           		 {
		                CW_Localised_Asset__c la = new CW_Localised_Asset__c();
		                la.Campaign_Asset__c = ca.Id;
		                la.Asset_Catalogue__c = ac.Id;
		                la.Language__c = enId;
		                loc.add(la);
	           		 }
	            	insert loc;

	            // pre add messaging object
	            CW_Messaging__c msg1 = new CW_Messaging__c(Campaign__c=camp.Id,Campaign_Asset__c = ca.Id, Dispatch_Date__c = Date.Today().addDays(2));
	            insert msg1;
					msg1.Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
					update msg1;
					camp.Mailer_Messaging_Approval_Status__c=ConstantUtil.APPROVAL_PROCESS_IN_APPROVAL;
					update camp;

	            Test.setCurrentPage(Page.CW_Campaign_Asset_Details);
	            Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CAMPASSETID,ca.Id);
	            Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ISBRIEFVIEWMODE,'false');
				 ApexPages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_ID,camp.Id);

	            Test.startTest();
	  		 	CW_TaskController taskController=new CW_TaskController();
	  		 	taskController.assetType=ConstantUtil.ASSET_TYPE_NAME;
	 		  	taskController.recallMessagingDatesApproval();
	 		 	Test.stopTest();
	    	  	system.assertEquals(1, [select count()  from CW_Campaign__c where Id  =:camp.Id and Mailer_Messaging_Approval_Status__c=:ConstantUtil.APPROVAL_PROCESS_NEEDS_SUBMISSION]);
	    	  	Integer count= [select count()  from CW_Messaging__c where Campaign__c=:camp.Id and Id=:msg1.Id and Campaign_Asset__c =: ca.Id ];
		      	system.assertEquals(count, [select count()  from CW_Messaging__c where Campaign__c=:camp.Id and Id=:msg1.Id and Campaign_Asset__c =: ca.Id and Approval_Status__c=:ConstantUtil.APPROVAL_PROCESS_NOT_SUBMITTED]);
        	}
	}
	static final String file = 'field1,field2,field3\n' +
					   		  + '1value1,1value2,1value3\n' +
					   		  + '2value1,2value2,2value3';

}