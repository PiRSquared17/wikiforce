/**
*@author Bruno Fagundez @ 06/09/2008
*/
public with sharing class WikiDetailsController {
	
	Wiki__c teamspace = new Wiki__c();
	 
    boolean noImage; 
    boolean emailTeamspace;
    String  error = '';
    boolean showError = false;
	
	public static UserPermissions userPermission = new UserPermissions();
	
	String teamIdParam = System.currentPageReference().getParameters().get('id'); 
	
	/**
	* Constructor
	*/
	public WikiDetailsController(){
		if(teamIdParam != null)
			getTeamDetail();		
		genPermissions();
	}	
	
	/**
	*@param String team id
	*/
	public void setTeamIdParam (String idTeam){ 
		teamIdParam = idTeam;
	}
	
	/**
	* Check if is TeamsSuscription page
	*@return Boolean 
	*/
	public Boolean getInTeamSubscription () {
		String currentPageUrl = System.currentPageReference().getUrl();
		return (currentPageUrl != null && currentPageUrl.indexOf('TeamsSubscription') != -1);
	} 
	
	public String USERID =  UserInfo.getUserId();
	
	public UserPermissions userPermissionsTeam = new UserPermissions();
	
	public UserPermissions userPermissionsWiki = new UserPermissions();
	
	/**
	*@return UserPermission
	*/
	public UserPermissions getUserPermissionsWiki () {
		return userPermissionsWiki;
	}
	
	/**
	* Load permission for current user
	*/
	public void genPermissions () {
		userPermission.setId(UserInfo.getUserId());
		userPermission.setTeam(teamIdParam);
		userPermission.setObjectType('Wiki');
		userPermission.setPermissions();
		userPermissionsWiki = userPermission;
		
		userPermissionsTeam.setId(UserInfo.getUserId());
		userPermissionsTeam.setTeam(teamIdParam);
		userPermissionsTeam.setObjectType('Team');
		userPermissionsTeam.setPermissions();					
	}

	/**
	*@return UserPermission
	*/
	public UserPermissions getUserPermission () {
		return userPermission;
	}	
	/* ---------------------------- */		
	
	
	/**
	* @return String teamIdParam The Id of the team
	*/
	public String getTeamIdParam(){
		return teamIdParam;
	}

	/**
	* Read Team
	*@throws Exception
	*/
	public void getTeamDetail(){
		try {
			teamspace = [Select  t.SystemModstamp, 
							t.OwnerId, t.Name,						
							t.LastModifiedDate,
							t.LastModifiedById, 
							t.NewMemberProfile__c,
							t.PublicProfile__c,
							t.IsDeleted,
							t.Id, 
							t.Description__c, 
							t.CreatedDate, 
							t.CreatedById
							From Wiki__c t 
							where id =: teamIdParam];
			teamIsOpen = showJoinEvent();
		} catch(Exception e ){
			throw e;
		}	
	}
	
	/**
	* Boolean to determine if show buttons.
	*/
	Boolean teamIsOpen = false;
	
	/**
	* Returns true if team is open
	*@return Boolean
	*/
	public Boolean getTeamIsOpen(){
		List<WikiMember__c> member = [select Id from WikiMember__c where User__c =: UserInfo.getUserId() and Wiki__c =: teamspace.Id limit 1];
		teamIsOpen = (member.size() == 0);
		return teamIsOpen;
	}
	
	/**
	* Show join event
	*@return Boolean
	*/
	public Boolean showJoinEvent(){
		Boolean canShow = false;
		List<WikiMember__c> members = [select Id from WikiMember__c where User__c =: UserInfo.getUserId() and Wiki__c =: teamspace.Id limit 1];
		
		canShow = (members.size() == 0) && ((teamspace.PublicProfile__c != null && teamspace.NewMemberProfile__c != null) ||
											(userPermissionsTeam.getCanManage()));
		
		return canShow;
	}
	
	/**
   	* For show join button
   	*@void
   	*/
   	public void refreshJoinEvent(){
   		teamIsOpen = showJoinEvent();
   	}
	
	/**
	* Join Team
	*/
	public void joinTeam(){
		 WikiMember__c newUserJoin = new WikiMember__c();
		 if(teamIsOpen){
			 newUserJoin.User__c = USERID;
			 newUserJoin.Name = UserInfo.getName();
			 newUserJoin.Wiki__c = teamspace.Id;
			 newUserJoin.WikiProfile__c = teamspace.NewMemberProfile__c;		 
			 teamIsOpen = false;
			 			 
			 insert newUserJoin;
		 }
	}
	
	
	/**
	* Perform the remove from the team
	*@throws Exception
	*/		
	public void leaveTeam(){
		 List<WikiMember__c> userRow = new List<WikiMember__c>();
		
		 try {
		 	userRow = [Select Id, User__c, Wiki__c from WikiMember__c where User__c =: USERID and Wiki__c =: teamspace.Id];
		 } catch(Exception e){ 
		 
		 }
		 		 
		 if (userRow.size() == 1) {
		 	delete userRow;
		 	teamIsOpen = true;
		 }
	}
	
	/**
	* Get Teamspace
	*@return Wiki__c
	*/
	public Wiki__c getTeamspace() {
         teamspace = [select Name, Description__c, NewMemberProfile__c from Wiki__c
                     where id=: teamIdParam];
         if(teamspace == null) {
         	return null;
         }else {
    		return teamspace;
         }
    }
    
    /**
    * Get Teamspace image
    *@return String
    */
    public String getTeamspaceImage() {
    
    /**    List<Wiki__c> teamAvatar = [select PictureId__c
        								from Wiki__c
        								where Id =:System.currentPageReference().getParameters().get('id')];
        if(teamAvatar.size() == 0) 
        	return '';
        return '/servlet/servlet.FileDownload?file=' + teamAvatar[0].PictureId__c;*/
        return '';
    }  
    
 
   	/**
   	* Refresh wiki list for widgets
   	*@void
   	*/
   	public void refreshWikis () {}
   	
   	//public static ProjectTask__c taskT;

}