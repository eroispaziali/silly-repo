/**
* File Name   :    StringUtilTest.cls
* Description :    Test Class for StringUtil.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 12/03/2014 Chris Yorkston	Initial version
*
*
*/

@isTest
private class StringUtilTest {
	
	@isTest static void getPageNameTest() {
		String pageName = TestDataUtil.getRandomString(10);
		String result = StringUtil.getPageName('/apex/' + pageName);
		System.assertEquals(pageName, result);
	}
	
	@isTest static void parseFreebetTypeTest() {
		String rt1 = TestDataUtil.getRandomString(10);
		String res1 = StringUtil.parseFreebetType(rt1);
		System.assertEquals(null, res1);
		
		String rt2 = ConstantUtil.REWARD_LIBRARY_AMOUNT_TYPE;
		String res2 = StringUtil.parseFreebetType(rt2);
		System.assertEquals(ConstantUtil.REWARD_TYPE_FREEBET_FIXED_AMOUNT, res2);
		
		String rt3 = ConstantUtil.REWARD_LIBRARY_PERCENTAGE_TYPE;
		String res3 = StringUtil.parseFreebetType(rt3);
		System.assertEquals(ConstantUtil.REWARD_TYPE_FREEBET_PERCENTAGE, res3);
	}
	
	@isTest static void testDelimitString() {
		
		String result = '';
		
		Set<String> stringSet = new Set<String>();
		String s1 = 'abc';
		String s2 = 'xyz';
		String s3 = 'lmn';
		
		stringSet.add(s1);
		stringSet.add(s2);
		stringSet.add(s3);
		
		result = StringUtil.delimitStrings(stringSet);
		
		system.assertEquals(s1+ConstantUtil.SEMICOLON+s3+ConstantUtil.SEMICOLON+s2, result);
	}
	
}