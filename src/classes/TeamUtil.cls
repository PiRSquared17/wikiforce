/**
*@author Gabriel Rilo @ 01/06/2009
*/
public class TeamUtil { 
	
	public static Boolean currentlyExeTrigger = false;
	public static Boolean isTest = false;
	public static Boolean alreadyGenEnv = false;
	
	
	public static Integer MAX_SIZE = 4194304;
	/**
	* Tests if current user belongs to the Admin Team
	*@throws CustomException message 'Insufficient privileges'
	*/
	public static void isAdminMemberUser(){
		List<User> teamAdmin = [Select id, Profile.PermissionsModifyAllData, ProfileId, Name From User where id =:UserInfo.getUserId() limit 1];
		
		if (!teamAdmin[0].Profile.PermissionsModifyAllData)
			throw new CustomException('Insufficient privileges');
	}
	
	public static Group orgGroup;
	
	/**
	* Read organizaton instance
	*@return Group
	*@throws CustomoException message 'There is no organization group'
	*/
	public static Group getOrganizationGroup() {
		if(orgGroup == null) {
				List<Group> go = [Select g.Type, g.Name from Group g where Type = 'Organization'];
				if(go.size() > 0)
					orgGroup = go[0];
				else
					throw new CustomException('TeamUtil: There is no organization group');
		}
		return orgGroup;
	}
		
	public class CustomException extends Exception {}
	
	/**
	* Return the Namespace Prefix
	*@return String
	*/
	public static String getNamespace () {
		String namespace = '';
        String fullName = Schema.SObjectType.WikiPage__c.getName();
        String localName = Schema.SObjectType.WikiPage__c.getLocalName();
        if (fullName != localName) {
           namespace = fullName.replaceAll(localName,'');
           namespace = namespace .replaceAll('__','');
        }
        return namespace;	
	}
	
	/**
	* Validate file size for attachment list
	*@param List<Attachment> 
	*@return List<Integer> Indexes list with errors
	*/
	public static List<Integer> validateFileSize(List<Attachment> attachList){
		List<Integer> errorList = new List<Integer>();
		Integer iter = 1;
		for(Attachment att: attachList){
			if(att.BodyLength > MAX_SIZE){
				errorList.add(iter);
			}
			iter++;
		}
		return errorList;
	}
}