/**
*@author Gabriel Rilo @ 01/06/2009
*/
public class TeamUtil { 
	
	public static Integer maxLongWord = 60;
	public static Integer maxLongPhrase = 128;	
	public static Boolean currentlyExeTrigger = false;
	public static Boolean isTest = false;
	public static Boolean alreadyGenEnv = false;
	public static Boolean DeletingWiki = false;
	public static Integer MAX_SIZE = 4194304;
	public static String hostName = null;
	//true if it must send emails
	//false when a wiki is deleted
	//this is to avoid that WikiPageBeforeDelete sends an email
	private static Boolean sendsEmailTriggerWikiPageBeforeDelete = true;
	
	//true if it must send emails
	//false when a wiki is deleted
	//this is to avoid that WikiMemberBeforeDelete sends an email
	private static Boolean sendsEmailTriggerWikiMemberBeforeDelete = true;
	
	/**
	* Returns sendsEmailTriggerWikiPageBeforeDelete value
	*@return Boolean sendsEmailTriggerWikiPageBeforeDelete
	*/
	public static Boolean getSendsEmailTriggerWikiPageBeforeDelete(){
		return sendsEmailTriggerWikiPageBeforeDelete;
	}
	
	/**
	* Returns sendsEmailTriggerWikiMemberBeforeDelete value
	*@return Boolean sendsEmailTriggerWikiMemberBeforeDelete
	*/
	public static Boolean getSendsEmailTriggerWikiMemberBeforeDelete(){
		return sendsEmailTriggerWikiMemberBeforeDelete;
	}
	
	/**
	* Sets sendsEmailTriggerWikiPageBeforeDelete value
	*/
	public static void setSendsEmailTriggerWikiPageBeforeDelete(Boolean b){
		sendsEmailTriggerWikiPageBeforeDelete = b;
	}
	
	/**
	* Sets sendsEmailTriggerWikiMembersBeforeDelete value
	*/
	public static void setSendsEmailTriggerWikiMemberBeforeDelete(Boolean b){
		sendsEmailTriggerWikiMemberBeforeDelete = b;
	}
	
	
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
	
	/**
    *
    * Get the organization Domain
    */  
    public static String getDomain () {
        String domain = '';
        PageReference PR =  ApexPages.currentPage();
      
        String props = '';
        if(PR.getHeaders() != null){
            props = (PR.getHeaders()).get('Host');
        }
        if (props == '' || props == null) {
            domain = '';  
        }else {
            String [] path = props.split('</?[a-z][a-z0-9]*[^<>]*>');
            if(path.size() == 0){
                domain = path[0];
            }else{
                for(Integer i = 0; i < path.size(); i++){  
                    domain += path[i];
                }
            }
        }
        return domain;  
    }
    
    /**
    *@return String
    */
    public static String joinStrListByToken( List<String> listToJoin, String token ){
 		String joinedStr = '';
 		Integer listSize = listToJoin.size();
 		
		if( listSize > 0 ){ 	
	 		for( Integer k = 0; k < listSize - 1; k++ )
	 			joinedStr += listToJoin[ k ] + token;
	 			
			joinedStr += listToJoin[ listSize - 1 ];
		}
		
		return joinedStr;
 		   	
    }
    
    public static String chopWords( String words ){
    	return TeamUtil.chopWords( words, TeamUtil.maxLongWord );
    }
    public static String chopWords( String words, Integer len ){
    	String strToReturn = '';
    	if( words != null && words.length() > 0 ){
	    	List<String> listOfWords = new List<String>();
	    	listOfWords = words.split( ' ' );
	    	
	    	for( Integer k = 0; k < listOfWords.size(); k++ )
	    		if( listOfWords[ k ].length() > len )
	    			listOfWords[ k ] = listOfWords[ k ].substring( 0, len ) + '.';
	    			
	    	strToReturn = TeamUtil.joinStrListByToken( listOfWords, ' ' );
    	}
    	
    	return strToReturn;
    }
    
    public static String chopPhrase( String phrase ){
    	return TeamUtil.chopPhrase( phrase, TeamUtil.maxLongPhrase );
    }
    
    public static String chopPhrase( String phrase, Integer len ){
    	
    	List<String> cPhrase = new List<String>();
    	String rPhrase = '';
    	if( phrase != null ){
	    	if( phrase.length() > len ){
		    	cPhrase = phrase.substring( 0, len ).split( ' ' );

		    	rPhrase = TeamUtil.joinStrListByToken( cPhrase, ' ' ) + '...';
	    	}else
	    		rPhrase = phrase;
    	}
    	return rPhrase;
    }
}