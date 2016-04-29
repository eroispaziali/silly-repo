public with sharing class ConstantUtil {

    // page actions in wizard
    public static final String INIT_ACTION = 'init';
    public static final String SAVE_ACTION = 'save';
    public static final String DEST_ACTION = 'dest';

    // sobject field names
    public static final String SOBJECT_NAME = 'Name';
    public static final String SOBJECT_ID = 'Id';

    // relationships on CW_Site_Catalogue__c
    public static final String CW_SC_REL_LABEL = 'Label__r';
    public static final String CW_SC_REL_PRODUCT = 'Product__r';
    public static final String CW_SC_REL_COUNTRY = 'Country__r';
    public static final String CW_CS_REL_SITECATALOGUE = 'Site_Catalogue__r';
    public static final String CW_CS_REL_LANGUAGE = 'Language__r';
    public static final String CW_CAT_REL_ASSETTYPE = 'Asset_Type__r';

    // page parameters names
    public static final String PAGEPARAM_CAMPAIGNID = 'campaignId';
    public static final String PAGEPARAM_CAMPASSETID = 'campAssetId';
    public static final String PAGEPARAM_BATCHJOBID = 'batchJobId';
    public static final String PAGEPARAM_OBJECTTYPE = 'objectType';
    public static final String PAGEPARAM_ID = 'id';
    public static final String PAGEPARAM_CAMPAIGNNAME = 'campaignName';
    public static final String PAGEPARAM_TASKTYPE = 'taskType';
    public static final String PAGEPARAM_TASK_ID = 'taskId';
    public static final String PAGEPARAM_MODALFLAG = 'loadModal';
    public static final String PAGEPARAM_BRIEF = 'Brief ';
    public static final String PAGEPARAM_CAMP = 'Campaign ';
    public static final String PAGEPARAM_ASSETTAB = 'tab';
    public static final String PAGEPARAM_ISBRIEFVIEWMODE ='isBriefViewMode';
    public static final String PAGEPARAM_QUEUE = 'Queue';

    // page parameters values
    public static final String PAGEPARAMVAL_AUDIENCE_GROUP = 'ag';
    public static final String PAGEPARAMVAL_AUDIENCE_GROUP_MEMBER = 'agm';

    // page naming conventions
    public static final String CW_PREFIX = 'CW';
    public static final String CW_PAGE_DELIMITER = '_';

    // campaign asset fieldsets
    public static final String CAMPAIGN_ASSET_DEFAULT_FS = 'Default_Fields';
    public static final String CAMPAIGN_ASSET_FS_SUFFIX = '_FieldSet';

    // campaign offer fieldsets
    public static final String CAMPAIGN_OFFER_DEFAULT_FS = 'Default_Fields';
    public static final String CAMPAIGN_OFFER_FS_SUFFIX = '_FieldSet';

    // schedule fieldsets
    public static final String SCHEDULE_TABLEVIEW_FS = 'TableView';

    //campaign reward messages
    public static final String CAMPAIGN_REWARD_SAVED_SUCCESFULLY = 'Campaign Reward created succesfuly.';

    // campaign task fieldset
    public static final String CAMPAIGN_TASK_FIELDSET_NAME = 'Task';
    public static final String NEW_CAMPAIGN_TASK_FIELDSET_NAME = 'Create_Edit_Task';

    // campaign save messages
    public static final STRING CAMPAIGN_SAVE_ERROR = 'You must enter a value for the campaign name.';
    public static final STRING CAMPAIGN_SAVE_CONFIRMATION = 'Campaign saved succesfully.';
    public static final STRING CAMPAIGN_SAVE_COST_ERROR = 'The campaign cost cannot be changed while waiting for approval';
    public static final STRING DUPLICATE_CAMPAIGN_NAME = 'A campaign with this name exists already';
    public static final STRING DUPLICATE_NAME_ERROR = 'duplicate value found:';
    public static final STRING POINTS_SAVED_SUCCESFULLY = 'Marcom points saved succesfully.';
    public static final STRING CAMP_ASSET_LABEL_ERROR = 'Messaging label does not match campaign asset labels already selected.';
    public static final STRING POINTS_CANNOT_BE_UPDATED = 'Marcom points cannot be changed if roadmap is approved or in approval';
	public static final STRING CAMP_NOT_SAVED = 'Error saving campaign';
	
    // Labels for approval process button
    public static final STRING APPROVAL_BTN_LABEL_SUBMIT_CAMP_FOR_APPROVAL = 'Submit Campaign for Approval';
    public static final STRING APPROVAL_BTN_LABEL_SUBMIT_BRIEF_FOR_APPROVAL = 'Submit Brief for Approval';
    public static final STRING APPROVAL_BTN_LABEL_AUTO_APPROVAL = 'Campaign Auto Approved';
    public static final STRING APPROVAL_BTN_LABEL_CRITERIA_NOT_MET = 'Criteria not met for ';

    public static final STRING APPROVAL_PROCESS_IN_APPROVAL = 'In Approval';
    public static final STRING APPROVAL_PROCESS_APPROVED = 'Approved';
    public static final STRING APPROVAL_PROCESS_REJECTED = 'Rejected';
    public static final STRING APPROVAL_PROCESS_NOT_SUBMITTED = 'Not Submitted';

    //custom settings variables
    public static final STRING AUDIENCE_GROUP_PAGE_SIZE = 'Audience Group Page Size';
    public static final STRING REWARD_PAGE_SIZE = 'Reward Page Size';
    public static final STRING APPROVER_TYPE = 'Roadmappers';
    public static final STRING APPROVER_TYPE_BRIEF = 'Brief';
    public static final STRING BATCH_RUN_DATE = 'Batch Run Date';
    public static final STRING APEX_CALLOUT_PROMO_API_FREEBET_CREATION_MOCK = 'freebet_mock';
    public static final STRING APEX_CALLOUT_PROMO_API_PROMOTION_CREATION_MOCK = 'promotion_mock';
    public static final STRING APEX_CALLOUT_PROMO_API_FREEBET_CREATION_QA = 'freebet_qa';
    public static final STRING APEX_CALLOUT_PROMO_API_PROMOTION_CREATION_QA = 'promotion_qa';
    public static final STRING AUDIENCE_CONTROL_GROUP_SUFFIX_NAME = 'Audience control group suffix';
    public static final STRING AUDIENCE_TARGET_GROUP_SUFFIX_NAME = 'Audience target group suffix';
    public static final STRING AUDIENCE_GROUP_SUFFIX_SEPARATOR_NAME = 'Audience group suffix separator';
    public static final STRING AUDIENCE_CONTROL_GROUP_SUFFIX_VALUE = 'C';
    public static final STRING AUDIENCE_TARGET_GROUP_SUFFIX_VALUE = 'T';
    public static final STRING AUDIENCE_GROUP_SUFFIX_SEPARATOR_VALUE  = '_';


    // Labels for approval process error messages
    public static final String SUBMIT_FOR_APPROVAL_WITHOUT_COST = 'The campaign cannot be submited for approval without a cost!';
    public static final String SUBMIT_FOR_APPROVAL_SUCCESFULLY = 'Submission Succeeded';
    public static final String SUBMIT_FOR_APPROVAL_FAILED = 'Submission Failed';
    public static final String SUBMIT_FOR_APPROVAL_MESSAGE = 'Submitting request for approval.';
    public static final String SUBMIT_FOR_APPROVAL_WITH_0_COST = 'The campaign does not need to be approved when the cost is 0.';
    public static final String SUBMIT_FOR_APPROVAL_NO_ROLE_SPECIFIED = 'There is no role specified for this user. Please contact the system administrator.';
    public static final String SUBMIT_FOR_APPROVAL_NON_ROADMAPPER = 'Only a roadmapper user can submit for approval. Please contact your system administrator.';
    public static final String SUBMIT_FOR_APPROVAL_NO_ROADMAP_APPROVER = 'There is no approver defined for the roadmap. Please contact your system administrator.';
    public static final String SUBMIT_FOR_APPROVAL_ROADMAP_NULL_FIELDS = ' has some blank fields. The roadmap cannot be submitted if any of the required fields are blank.';
    public static final String SUBMIT_FOR_APPROVAL_ROADMAP_NO_CAMPS = 'A roadmap with no campaigns cannot be submitted for approval';
    public static final String SUBMIT_FOR_APPROVAL_NULL_REQUIRED_FIELDS = 'Some of the required fields are null.';
    public static final String SUBMIT_FOR_APPROVAL_BRIEF_NO_CAMP_SITE = 'The Campaign Brief cannot be submitted for approval without an associated campaign site.';
    public static final String SUBMIT_FOR_APPROVAL_BRIEF_NO_ROADMAP_APPROVED = 'Roadmap ';
    public static final String SUBMIT_FOR_APPROVAL_BRIEF_NO_ROADMAP = 'As your campaign is not urgent, it must be part of an approved roadmap before you submit your concept brief to Marcom.';
    public static final String SUBMIT_FOR_APPROVAL_NO_BRIEF_APPROVER = 'There is no approver defined for brief approval process. Please contact your system administrator.';
    public static final String SUBMIT_FOR_APPROVAL_ROADMAP_IN_APPROVAL = 'Roadmap already in approval process.';
    public static final String SUBMIT_FOR_APPROVAL_BRIEF_SUBMISSION = 'Brief Submission';
    public static final String SUBMIT_FOR_APPROVAL_COST_SUBMISSION = 'Campaign Submission';

    // parser constants
    public static final String COMMA = ',';
    public static final String COLON = ':';
    public static final String SEMICOLON = ';';
    public static final String CR = '\r';
    public static final String LF = '\n';
    public static final String CRLF = CR + LF;
    public static final String DQUOTE = '\"';
    public static final String DQUOTEDQUOTE = DQUOTE + DQUOTE;

    // csv positioning
    public static final Integer CSV_GROUP_NAME_COLUMN = 0;
    public static final Integer CSV_ACCOUNT_PLAYER_ID_COLUMN = 1;
    public static final Integer CSV_IS_CONTROL_COLUMN = 1;
    public static final Integer CSV_UNICA_ID_COLUMN = 2;
    public static final Integer CSV_DESCRIPTION_COLUMN = 3;
    public static final Integer CSV_CONTROL_GROUP_COLUMN = 4;
    public static final String CSV_CONTROL_STRING = 'true';

    public static final Integer CSV_FREEBET_ID_COLUMN = 2;
    public static final Integer CSV_AMOUNT_COLUMN = 3;
    public static final Integer CSV_CURRENCY_COLUMN = 4;

    // record types to process in batch
    public static final String BATCH_OBJECT_TYPE_AUDIENCE_GROUP = 'CW_Audience_Group__c';
    public static final String BATCH_OBJECT_TYPE_AUDIENCE_GROUP_MEMBER = 'CW_Audience_Group_Member__c';

    // batch job statuses
    public static final String BATCH_JOB_STATUS_COMPLETED = 'Completed';
    public static final String BATCH_JOB_STATUS_ABORTED = 'Aborted';
    public static final String BATCH_JOB_STATUS_FAILED = 'Failed';

    //audience group delete messages
    public static final STRING AUDIENCE_GROUP_SINGLE_CONTROL_GROUP = ' is a controlling group.';
    public static final STRING AUDIENCE_GROUP_MULTIPLE_CONTROL_GROUPS = ' are controlling groups.';
    public static final STRING AUDIENCE_GROUP_NO_CONTROL_GROUP = 'Are you sure you want to delete the selected groups?';
    public static final STRING DUPLICATE_AUDIENCE_GROUP_NAME = ' already exists. Group name must be unique.';
    public static final STRING CREATE_AUDIENCE_GROUP_NO_NAME = 'Audience Group Name is required.';

    // Queue names
    public static final STRING QUEUE_SPORTS_BI = 'Sports BI';
    public static final STRING QUEUE_SPORTS_CIM = 'Sports CIM';
    public static final STRING QUEUE_SPORT_BI = 'Sport BI';
    public static final STRING QUEUE_SPORT_CIM = 'Sport CIM';
    public static final STRING TASK_QUEUE = 'Task Queue';

    //lock related records when roadmap is in approval or approved
    public static final STRING BLOCKED_CAMPAIGN_ASSET_TYPE = 'You cannot add or update Campaign Asset Type if the Roadmap Status is In Approval or Approved';
    public static final STRING BLOCKED_NEW_CAMPAIGN = 'You cannot add a new Campaign to a Roadmap that is In Approval or Approved';
    public static final STRING ASSET_INSERT_ERROR = 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ';
    public static final STRING REMOVE_ROADMAP_ERROR = 'Campaign Roadmap cannot be changed or removed once approved or in approval';

    // batch apex job name
    public static final STRING BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_MEMBER = 'CW_BatchUpdateAudienceGroupMember';
    public static final STRING BATCH_APEX_JOB_NAME_UPDATE_AUDIENCE_GROUP_RELATION = 'CW_BatchAudienceGroupRelationAssign';

    // schedule string for batch apex job
    public static final STRING BATCH_APEX_SCHEDULE_UPDATE_AUDIENCE_GROUP_MEMBER = '0 0 1 * * ?'; // Run every day at 1am (01:00)

    // audience group parameter
    public static final STRING RETURN_URL = 'retURL';
    public static final STRING RETURN_URL_PARAMETER = '/apex/CW_Audience_Group?id=';
    public static final STRING SAVE_URL = 'saveURL';
    public static final STRING SAVE_URL_PARAMETER = '/apex/CW_Audience_Group?id=';

    //fieldset names for locking records
    public static final STRING MARCOM_BRIEF_LOCKED_FIELDSET_NAME = 'Marcom_Brief_Locked_Fields';
    // 20140501 - CY removed
    //public static final STRING MARCOM_BRIEF_FIELDSET_NAME = 'Marcom_Brief_Fields';

    // reward library parameter
    public static final STRING REWARD_LIBRARY_AMOUNT_TYPE = 'FreeBet Amount';
    public static final STRING REWARD_LIBRARY_PERCENTAGE_TYPE = 'FreeBet Percentage';
    public static final STRING REWARD_LIBRARY_AMOUNT_ERROR = 'Amount and Currency fields are required when selecting Amount FreeBet type.';
    public static final STRING REWARD_LIBRARY_PERCENTAGE_ERROR = 'Percentage field is required when selecting Percentage FreeBet type.';
    public static final STRING REWARD_BONUS = 'Bonus';
    public static final STRING REWARD_BONUS_CIM_REQUEST = ' CIM Request';
    public static final STRING REWARD_BONUS_CIM_HELP_REQUIRED = 'CIM help is required to add bonus code to campaign reward ';
    public static final STRING REWARD_TASK_CREATED = 'Campaign Reward and Bonus Task created succesfully.';
    public static final STRING REWARD_TASK_NO_DESCRIPTION = 'Description field is required in order to create a task.';
    public static final STRING REWARD_WITHOUT_LIBRARY = 'Required field is missing: Reward Library';
    public static final STRING REWARD_LIBRARY_ALL_FIELDS_REQUIRED = 'All fields are required in order to save the library';
    public static final STRING REWARD_SAVED_WITHOUT_REWARD_LIBRARY = 'You must either add a reward library or delete the record, it cannot be left blank.';
    public static final STRING REWARD_AMOUNT_CURRENCY_REQUIRED = 'Amount and Currency are required fields to save the reward.';
    public static final STRING REWARD_NOT_SAVED = 'Reward not saved.';
    public static final STRING REWARD_TYPE_MISSING = 'Required field is missing: Reward Type.';

    // Campaign Asset field sef suffixes
    public static final String CA_FS_DETAILVIEW_SUF = 'DV';
    public static final String CA_FS_EDITVIEW_SUF = 'EV';
    public static final String CA_FS_QUICKCREATE_SUF = 'QC';
    public static final String CA_FS_TABLEVIEW_SUF = 'TV';

    // api key value pair names
    public static final String REWARD_TYPE_FREEBET_FIXED_AMOUNT = 'FixedValue';
    public static final String REWARD_TYPE_FREEBET_PERCENTAGE = 'Percentage';

    //asset type approval process messages
    public static final String MAILER_DATE_SUBMITTED_SUCCESSFULLY = 'The Mailer Dispatch Date has been successfully submitted for approval';
    public static final String TEASER_DATES_SUBMITTED_SUCCESSFULLY = 'The Teaser Dates have been successfully submitted for approval';

    // schedules
    public static final Integer EVALUATION_DATE_OFFSET = 60;
    public static final String CAMPAIGN_RECURRENCE_TYPE_RECURRING = 'Recurring';
    public static final String CAMPAIGN_RECURRENCE_TYPE_LIFECYCLE = 'Lifecycle';
    public static final String CAMPAIGN_RECURRENCE_TYPE_SINGLE = 'Single';

    //
    public static final String RECORDS_IN_APPROVAL = ' cannot be deleted or edited while is in approval';
    public static final String RECORDS_SAVED = ' have been successfully saved .';

    //roles name
    public static final String CIM_ROLE = 'CIM';
    public static final String SPORT_BI_ROLE = 'Sports BI';

    //marcom brief fieldset names
    public static final String MARCOM_CAMP_INFO_BV = 'Campaign_Information_BV';
    public static final String MARCOM_BUSINESS_CASE_BV = 'Business_Case_BV';
    public static final String MARCOM_CREATIVE_CONCEPT_BV = 'Creative_Concept_BV';
    public static final String MARCOM_LEGAL_INFO_BV = 'Legal_Information_BV';
    public static final String MARCOM_REWARD_BV = 'Reward';

    //profiles name
    public static final String MARCOM_PROFILE = 'Marcom';
    public static final String MARKETING_PROFILE = 'Marketing Ops';
    
    //marcom brief recall action
    public static final String MARCOM_BRIEF_RECALL_SUCCESFULLY = 'Marcom Brief Recalled';
    public static final String MARCOM_BRIEF_RECALL_FAILED = 'Recall failed';
    public static final String RECALL_ACTION = 'Removed';
    
    //campaign stage name
    public static final String CAMP_STAGE_DRAFT = 'Draft'; 
    public static final String CAMP_STAGE_ROADMAP_APPROVED = 'Roadmap Approved';
    public static final String CAMP_STAGE_PRODUCTION = 'Production';
    
    //campaign offer 
    public static final String CAMP_OFFER_SAVED_SUCCESSFULL = 'Campaign Offer saved successfuly';
    public static final String CAMP_OFFER_DELETED_SUCCESSFULL = 'Campaign Offer deleted successfuly';
    public static final String CAMP_OFFER_SAVE_ERROR = 'Offer Type is a required field to save the Campaign Offer';
    
	//messaging approval
    public static final String MAILER_APPROVAL_MESSAGING_FIELDSET = 'Mailer_Approval';
    public static final String TEASER_APPROVAL_MESSAGING_FIELDSET = 'Teaser_Approval';
    public static final String SMS_APPROVAL_MESSAGING_FIELDSET = 'SMS_Approval';
    public static final String MAILER_APPROVAL_FIELDSET = 'Mailer Approval';
    public static final String TEASER_APPROVAL_FIELDSET = 'Teaser Approval';
    public static final String SMS_APPROVAL_FIELDSET = 'SMS Approval';

   	//new statuses for messaging
    public static final STRING APPROVAL_PROCESS_ALL_APPROVED = 'All Approved';
    public static final STRING APPROVAL_PROCESS_SOME_REJECTED = 'Some Rejected';
    public static final STRING APPROVAL_PROCESS_NEEDS_SUBMISSION = 'Needs Submission';

  	public static final STRING ASSET_TYPE_NAME = 'Mailer';
  	public static final STRING TEASER_ASSET_TYPE_NAME = 'Teaser';
  	public static final STRING SMS_ASSET_TYPE_NAME = 'SMS';
  	public static final STRING MAILER_APPROVER_QUEUE_NAME = 'CIM';
  	public static final STRING TEASER_APPROVER_QUEUE_NAME = 'Editorial';
  	public static final STRING SMS_APPROVER_QUEUE_NAME = 'CIM';
 	public static final STRING UNDERSCORE_APPROVAL='_Approval';
  	public static final STRING MESSAGING_APPROVAL_PROCESS=' Messaging Approval Status';

    //csv reader errors
    public static final String CSV_CONTAINS_NULL_FIELDS = 'CSV file contains null values. Groups and members name are required for upload.';
}