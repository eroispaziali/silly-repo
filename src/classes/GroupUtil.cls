public with sharing class GroupUtil {
/**
* File Name   :    GroupUtil.cls
* Description :    Various utility functions based on Group object
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 07/04/2014 Chris Yorkston Initial version
*
*
*/	
	
	// get queue with supplied queue name
	public static Group getQueue(String queueName) {
		Group grp;
		List<Group> groups = [select id, name from Group where Name = :queueName AND Type = 'Queue'];
		if ( !groups.isEmpty() ) grp = groups[0];
		
		return grp;
	}
	
}