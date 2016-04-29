/**
* File Name   :    UserUtilTest.cls
* Description :    Test Class for UserUtil.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 27/03/2014 Chris Yorkston	Initial version
*
*
*/

@isTest
private class UserUtilTest {

	@isTest static void getUserIdTest() {
		User u = TestDataUtil.createStandardUser();
		
		String userId = UserUtil.getUserId(u.Username);
		system.assertEquals(u.Id, userId);
	}
	
	@isTest static void getCurrentRoleNameTest() {
		User u = TestDataUtil.getStandardUser();
		UserRole userRole = TestDataUtil.createRole( TestDataUtil.getRandomAlphaString(10) );
		u.UserRoleId = userRole.Id;
		insert u;
		
		String userRoleName = UserUtil.getCurrentRoleName(u.Id);
		system.assertEquals(userRole.Name, userRoleName);
	}

}