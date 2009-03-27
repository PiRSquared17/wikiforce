/**
*@author Gabriel Rilo @ 01/06/2009
*/
public class TeamUtil { 
	
	public static Boolean currentlyExeTrigger = false;
	public static Boolean isTest = false;
	public static Boolean alreadyGenEnv = false;
	public static Boolean DeletingWiki = false;
	public static Integer MAX_SIZE = 4194304;
	public static String hostName = null;
	
	
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
	
	/**
	* Get host form PageReference.
	*@return host
	*/
	public static String getHost (PageReference pr){
		String newPath = '';
		//In Gannt Page Reference is null
		if(pr !=  null){
			String props = '';
			if(pr.getHeaders() != null){
				props = (pr.getHeaders()).get('Host');
			}
			//Remove HTML tag of Path
			if(props == '' || props == null){
				newPath = '';	
			}else{
				String [] path = props.split('</?[a-z][a-z0-9]*[^<>]*>');
				if(path.size() == 0){
					newPath = path[0];
				}else{
					for(Integer i = 0; i < path.size(); i++){	
						newPath += path[i];
					}
				}
			}
		}
		return newPath;	
	}
	
	/**
	* Deletes a GroupMember record 
	*@param gmToDelete String that represents the id of the groupMember record to delete
	* Used at WikiAfterUpdate.trigger to avoid an Error
	* MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object
	*/
	@future
	public static void deleteGroupMembers(List<String> gmToDelete){
	    List<GroupMember> gm = [select UserOrGroupId, GroupId, id from GroupMember where id in : gmToDelete];
		delete gm;
	}
	
}