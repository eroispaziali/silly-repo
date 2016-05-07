/**
* File Name   :    CW_CampaignListSettingHelper.cls
* Description :   Class for getting and filling CW_CampaignListSetting__c with default values
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 08/05/2014 Alex Panka	  Initial
*/

public with sharing class CW_CampaignListSettingHelper {
	
	//private static CW_CampaignListSetting__c
	
	public static DateTime getDateTimeValue(String sName , DateTime defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			campSetting= new CW_CampaignListSetting__c();
			campSetting.Name=sName;
			campSetting.DateTime_Value__c=defaultVal;
			insert campSetting;
		}
		return campSetting.DateTime_Value__c;
	}
	
	public static Date getDateValue(String sName , Date defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			campSetting= new CW_CampaignListSetting__c();
			campSetting.Name=sName;
			campSetting.Date_Value__c=defaultVal;
			insert campSetting;
		}
		return campSetting.Date_Value__c;
	}
	
	public static Integer getIntegerValue(String sName , integer defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			campSetting= new CW_CampaignListSetting__c();
			campSetting.Name=sName;
			campSetting.Integer_Value__c=defaultVal;
			insert campSetting;
		}
		return Integer.ValueOf(campSetting.Integer_Value__c);
	}

	public static String getTextValue(String sName , String defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			campSetting= new CW_CampaignListSetting__c();
			campSetting.Name=sName;
			campSetting.Text_Value__c=defaultVal;
			insert campSetting;
		}
		return campSetting.Text_Value__c;
	}
	
	public static void setDateTimeValue(String sName , DateTime defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			campSetting= new CW_CampaignListSetting__c();
			campSetting.Name=sName;
		}
		campSetting.DateTime_Value__c=defaultVal;
		upsert campSetting;
		
	}
	
	public static void setDateValue(String sName , Date defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			campSetting= new CW_CampaignListSetting__c();
			campSetting.Name=sName;
		}
		campSetting.Date_Value__c=defaultVal;
		upsert campSetting;
	
	}
	
	public static void setIntegerValue(String sName , integer defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			campSetting= new CW_CampaignListSetting__c();
			campSetting.Name=sName;
		}
		campSetting.Integer_Value__c=defaultVal;
		upsert campSetting;

	}

	public static void setTextValue(String sName , String defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			campSetting= new CW_CampaignListSetting__c();
			campSetting.Name=sName;
		}
		campSetting.Text_Value__c=defaultVal;
		upsert campSetting;
	}
	
	public static DateTime DateTimeValue(String sName , DateTime defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			return defaultVal;
		}
		return campSetting.DateTime_Value__c;
	}
	
	public static Date DateValue(String sName , Date defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
			if(campSetting==null){
			return defaultVal;
		}
		return campSetting.Date_Value__c;
	}
	
	public static Integer IntegerValue(String sName , integer defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			return defaultVal;
		}
		return Integer.ValueOf(campSetting.Integer_Value__c);
	}

	public static String TextValue(String sName , String defaultVal){
		CW_CampaignListSetting__c campSetting=CW_CampaignListSetting__c.getValues(sName);
		if(campSetting==null){
			return defaultVal;
		}
		return campSetting.Text_Value__c;
	}
}