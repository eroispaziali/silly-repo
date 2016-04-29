/**
* File Name   :    GroupUtilTest.cls
* Description :    Test Class for GroupUtil.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 07/04/2014 Chris Yorkston	Initial version
*
*
*/

@isTest
private class GroupUtilTest {
	
	@isTest static void getQueueTest() {
		
		User u = TestDataUtil.createStandardUser();
		Group g = TestDataUtil.createQueue();
		GroupMember gm = TestDataUtil.getGroupMember();
		gm.GroupId = g.Id;
		gm.UserOrGroupId = u.Id;
		insert gm;
		
		Group grp = GroupUtil.getQueue(g.Name);
		system.assertEquals(true, grp!=null);
		system.assertEquals(g.Name, grp.Name);	
	}
	
}