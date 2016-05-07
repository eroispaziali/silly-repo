public with sharing class UserUtil {
	
/**
* File Name   :    UserUtil.cls
* Description :    Various utility functions based on the User object
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 25/03/2014 Chris Yorkston	Initial version
*
*
*/
	
	// get user id from supplied username
	public static Id getUserId(String usrname) {
		Id userId;
		List<User> users = [select Id from User where Username = :usrname limit 1];
		if (users!=null && !users.isEmpty()) userId = users[0].Id;
		return userId;
	}
	
	//get campaign owner username
	public static String getUsername(Id userId)
	{
		return [select Id,Username from User where Id = :userId limit 1].UserName;
	}
	
	// get user role from supplied user id
	public static String getCurrentRoleName(Id userId)
 	{	 
 		Id userRoleId;
 		List<User> users = [SELECT UserRoleId from User where Id =: userId limit 1];
 		if (users!=null && !users.isEmpty()) userRoleId = users[0].UserRoleId;
 		
 		String roleName;
 		List<UserRole> userRoles = [SELECT Name from UserRole WHERE Id =: userRoleId limit 1];
 		if (userRoles!=null && !userRoles.isEmpty()) roleName = userRoles[0].Name;
 		
 		return roleName;
 	}
 	
 	// get user profile from supplied user id
	public static String getCurrentProfileName(Id userId)
 	{	 
 		Id userProfileId;
 		List<User> users = [SELECT ProfileId from User where Id =: userId limit 1];
 		if (users!=null && !users.isEmpty()) userProfileId = users[0].ProfileId;

 		String profileName;
 		List<Profile> userProfiles = [SELECT Name from Profile WHERE Id =: userProfileId limit 1];
 		if (userProfiles!=null && !userProfiles.isEmpty()) profileName = userProfiles[0].Name;

 		return profileName;
 	}
	
}