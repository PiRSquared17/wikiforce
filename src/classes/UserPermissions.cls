/**
*@author Gabriel Rilo @ 01/06/2009
*/
public class UserPermissions {

	/* Vars */
	String id;
	String team;
	String objectType;
	String ownerId;
	
	User teamAdmin = null;
	List<WikiMember__c> members = null;
	List<Wiki__c> currentTeam = null;
	WikiProfile__c profile = null;
	
	/* Booleans */
	Boolean canCreate = false;
	Boolean canManage = false;
	Boolean canComment = false;
	Boolean canView = true;
	
	/**
	* Costructor
	*/
	public UserPermissions (){
		
	}
	
	/**
	*@return String
	*/
	public String getId () {
		return id;
	}
	
	/**
	*@return String
	*/
	public String getTeam () {
		return team;
	}
	
	/**
	*@return String
	*/
	public String getObjectType () {
		return objectType;
	}
	
	/**
	*@return Boolean
	*/
	public Boolean getCanCreate () {
		return canCreate;
	}
	
	
	/**
	*@return Boolean
	*/
	public Boolean getCanManage () {
		return canManage;
	}
	
	/**
	*@return Boolean
	*/
	public Boolean getCanComment () {
		return canComment;
	}
	
	/**
	*@return Boolean
	*/
	public Boolean getCanView () {
		return canView;
	}
	
	/**
	*@param String
	*/
	public void setId (String id) {
		this.id = id;
	}
	
	/**
	*@param String
	*/ 	
 	public void setOwnerId (String ownerId) {
		this.ownerId = ownerId;
	}
	
	/**
	*@param String
	*/	
	public void setTeam (String team) {
		this.team = team;
	}
	
	/**
	*@param String
	*/	
	public void setObjectType (String objectType) {
		this.objectType = objectType;
	}
	
	/**
	* Get permissions for current user
	*@throws Exception
	*/
	public void setPermissions () {
		try{
			canManage = false;
			canCreate = false;
			canComment = false;
			Boolean isAdmin = false;			
			
			if(teamAdmin == null || teamAdmin.Id != UserInfo.getUserId())
				teamAdmin = [Select id, Profile.PermissionsModifyAllData, ProfileId, Name From User where id =: id limit 1];

			if(teamAdmin.Profile.PermissionsModifyAllData){
				canManage = true;
				canCreate = true;
				canView = true;
				canComment = true;
				isAdmin = true;
			}
			if(!isAdmin){
				if(members == null){
					members = new List<WikiMember__c>();
					members = [select WikiProfile__r.PostWikiComments__c, 
	 								  WikiProfile__r.ManageWikis__c,
		    						  WikiProfile__r.CreateWikiPages__c, 
									  User__c
							  from WikiMember__c 
							  where User__c =:id 
							  and Wiki__c=:Team 
							  limit 1];
				}
				
				List<Wiki__c> myWiki = new List<Wiki__c>();
				myWiki = [select Type__c from Wiki__c where id=:Team limit 1];
				// If the Wiki is open everyone will be able to Create Pages.
				if(myWiki[0].Type__c == 'open'){
				
					canCreate = true;
					canComment = true;
				
				} 
				
				
				// If the user is a member of the team we should use the profile assigned to that user
				else if (members.size() > 0) {
					profile = members[0].WikiProfile__r;
				
				// If the user is not a member of the team then we have to go to the public profile of the team
				// to figure out the permissions.
				}else{
					if(currentTeam == null){
						currentTeam = new List<Wiki__c>();
						List<Wiki__c> currentTeam = [select PublicProfile__c, 
													 	Id,
													 	PublicProfile__r.PostWikiComments__c, 
													 	PublicProfile__r.ManageWikis__c,
													 	PublicProfile__r.CreateWikiPages__c 
											  		 from Wiki__c
											  		 where Id =: Team];
										
						if(currentTeam.size() > 0) 
							profile = currentTeam[0].PublicProfile__r;
					}
				}				
				if (profile != null) {
					/*		WIKI		*/
					if (objectType == 'Wiki') {
						if(profile.CreateWikiPages__c) 	
							canCreate = true;
						if(profile.PostWikiComments__c) 
							canComment = true;
						if(profile.ManageWikis__c){ 
							canManage = true; 
							canCreate = true; 
							canComment = true; 
						}
					}
				}
			}
			
			String canManageStr = (canManage) ? 'true' : 'false';
			System.debug('\n\n User Permissions Results: \n\tObject: ' + objectType + '\n\tCan Manage: ' + canManage + '\n\tCan Create: ' + canCreate+ '\n\tCan Comment: ' + canComment + '\n\tCan View: ' + canView + '\n\n');
			
			if(ownerId == id) 
				canManage = true;  // Shouldnt this be called user UserId?
		}catch(Exception e){
			throw e;
		}
	}
}