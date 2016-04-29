public with sharing class StringUtil {
/**
* File Name   :    StringUtil.cls
* Description :    PEN-082
*                  must have be able to be guided through a Sports campaign - wizard creation
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 04/03/2014 Chris Yorkston Initial version
*
*
*/

	// get page name from partial URL
	public static String getPageName(String pageName) {
		pageName = pageName.replaceFirst('/apex/','');
		pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
		List<String> pageNameExtra = pageName.split('%3F',0);
		pageName = pageNameExtra[0];
		return pageName;
	}
	
	// correctly capitalise page names - using Page.PageName will return the url in all lowercase
	// e.g. cw_campaign_information > CW_Campaign_Information
	public static String standardisePageName(String pageName)
	{
		// for CW namespace
		if(pageName.startsWith(ConstantUtil.CW_PREFIX.toLowerCase()))
		{
			pageName = pageName.replaceFirst(ConstantUtil.CW_PREFIX.toLowerCase(),ConstantUtil.CW_PREFIX.toUpperCase());
		}
		
		List<String> strList = pageName.split(ConstantUtil.CW_PAGE_DELIMITER);
		for(Integer i=0; i<strList.size(); i++)
		{
			String str = strList.get(i);
			if(str.length() > 0)
			{
				strList.set(i,str.substring(0,1).toUpperCase() + (str.length() > 1 ? str.substring(1) : ''));
			}
		}
		return String.join(strList,ConstantUtil.CW_PAGE_DELIMITER);
	}
	
	// check if the rewardType contains freebet and determine what type of free bet it is
	// required for Promo API callout
	public static String parseFreebetType(String rewardType) {
		String result;
		
		if ( rewardType.contains(ConstantUtil.REWARD_LIBRARY_AMOUNT_TYPE) ) {
			result = ConstantUtil.REWARD_TYPE_FREEBET_FIXED_AMOUNT;
		}
		else if ( rewardType.contains(ConstantUtil.REWARD_LIBRARY_PERCENTAGE_TYPE) ) {
			result = ConstantUtil.REWARD_TYPE_FREEBET_PERCENTAGE;
		}
		
		return result;
	}
	
	// join sorted values from set using semicolon
	public static String delimitStrings(Set<String> codeSet)
	{
		final String sep = ConstantUtil.SEMICOLON;
		
		List<String> codeList = new List<String>();
		codeList.addAll(codeSet);
		codeList.sort();
		String retStr = String.join(codeList,sep);
		return retStr.length() > 255 ? retStr.substring(0,255) : retStr;
	}
	
}