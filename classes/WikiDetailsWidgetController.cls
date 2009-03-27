public  without sharing class WikiDetailsWidgetController {

	// Get Team Id Attribute
	String team;
	
	/**
	* Constructor
	*/
	public WikiDetailsWidgetController(){}	
	
	/**
	* Setter method for Team Id variable
	*@param String teamId
	*/
	public void setWiki(String tID) {
		team = tID;
		genPermissions();
	}
	
	/**
	* Getter method for Team Id variable
	*@return String teamId
	*/
	public String getWiki(){
		return team;
	}
	
	// Active user ID
	public String USERID =  UserInfo.getUserId();
	
	/**
	*@return String userId
	*/
	public String getCurrentUser(){
		return USERID;
	}
	
	/**
	* Return the Namespace Prefix
	*@return String
	*/
	public String getNamespace () {
        return TeamUtil.getNamespace();
    } 
	
	Wiki__c teamspace = new Wiki__c();
	
	public UserPermissions userPermissions = WikiDetailsController.userPermission.clone(); 
	
	/**
	* Generate user permissions
	*@void
	*/
	public void genPermissions() {
		userPermissions.setId(USERID);
		userPermissions.setTeam(team);
		userPermissions.setObjectType('Team');
		userPermissions.setPermissions();		
	}
	
	/**
	* Return user permissions
	*@return UserPermissions
	*/
	public UserPermissions getUserPermissions () {
		return userPermissions;
	}	
	
	/**
	* Return Team data
	*@return Wiki__c
	*@throws Exception
	*/
	public Wiki__c getTeamspace() {
		if(teamspace.Id != null)
			return teamspace;
		try {
			teamspace = [Select t.SystemModstamp,
									t.OwnerId, t.Name,						
									t.LastModifiedDate,
									t.LastModifiedById, 
									t.IsDeleted,
									t.Id, 
									t.Description__c,
									t.PictureId__c, 
									t.CreatedDate, 
									t.CreatedById 
									From Wiki__c t 
									where t.Id =: team];
			
			//teamspace = [Select t.Name, t.Description__c From Wiki__c t Where t.Id =: team];
									
			// The following is to clean text for the widget
			teamspace.Description__c = teamspace.Description__c.replaceAll('[\n\r]*','');
			teamspace.Description__c = teamspace.Description__c.replaceAll('[\n]*',''); 
												
		} catch(Exception e){
			System.debug('Falla.');
		}
		
    	return teamspace;
    }
    
	// Boolean to determine if show buttons
	Boolean teamIsOpen = false;
	
    /**
	* Boolean to determine if show buttons
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
											(userPermissions.getCanManage()));
		
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
    * Send id of teammember (if any)
    *@return String
    *@throws Exception
    */
    public String getTeamMemberId(){
    	List<WikiMember__c> tmember = new List<WikiMember__c>();
    	
    	try{
    		tmember = [Select WikiProfile__r.Name, WikiProfile__c From WikiMember__c where User__c =: USERID and Wiki__c =: team];
    	} catch(Exception e){}
    	
    	if(tmember.size() > 0){
    		Id teamMemberId = tmember[0].Id;
    		tmember.clear();	    	
	    	return teamMemberId; 	    	
    	}else {
    		tmember.clear();
    		return 'no';
    	}    	 
    }
    
    
    /**
    * Look if the user is the team admin
    *@return boolean
    *@throws Exception
    */    
    public boolean getIsTeamAdmin(){
    	WikiMember__c tmember = new WikiMember__c();    	
    	
    	try{
    		tmember = [Select WikiProfile__r.Name, WikiProfile__c From WikiMember__c where User__c =: USERID and Wiki__c =: team];
    	} catch(Exception e){}

    	return ((tmember != null) && (tmember.WikiProfile__r.Name == 'Team Administrator'));
    }
    
    /**
    * Get The list of admins to this team
    *@return String
    *@throws Exception
    */
    public String getTeamAdmins(){
    	List<WikiMember__c> tmemberList = new List<WikiMember__c>();
    	
    	try {
    		tmemberList = [Select User__r.Name, User__c From WikiMember__c where WikiProfile__r.Name = 'Team Administrator' and Wiki__c =: team];
    	} catch (Exception e){
    		throw e;
    	}
    	
    	String teamMemberList = ' ';
    	
    	if(tmemberList.size() > 0 ){ 
	    	for(WikiMember__c tm: tmemberList){
	    		teamMemberList += '<a href="/' + tm.User__c + '" >'+ tm.User__r.Name +'</a><br />';    	
	    	}     	
    	}
    	tmemberList.clear();
    	return teamMemberList;
    }
    
    /**
    * Get The count of members at the team
    *@return Integer
    *@throws Exception
    */
    public Integer getTeamCount(){
    	List<WikiMember__c> tmemberList = new List<WikiMember__c>();
    	
    	try {
    		tmemberList = [Select Id From WikiMember__c where Wiki__c =: team];
    	} catch (Exception e){
    		throw e;
    	}
    	return tmemberList.size();
    }
    
	public String getTeamspaceImage() {
    	/**if(teamspace.PictureId__c == null) 
    		return '';
    	return '/servlet/servlet.FileDownload?file=' + teamspace.PictureId__c; */
    	return '';   		
    }
    
    /**
    * Leave a Team
    *@throws Exception
    */
    public void leaveTeam (){
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
   	* For show leave link
   	*/
   	public void refreshLeaveEvent(){
		
   	}
	
}