public class WikiCreateWikiController {
  
	List<Group> allowCustomerActivated = new List<Group>();
	List<Group> allowPartnetActivated = new List<Group>();
	public static Boolean allowCustomer = false;
	public static Boolean allowPartner = false;  

	/**
	*@param Boolean
	*/
	public static Boolean getAllowCustomerStatic(){ 
		return allowCustomer ;
	}
	/**
	*@param Boolean
	*/
	public static Boolean getAllowPartnerStatic(){ 
		return allowPartner ;
	}

	/**
	*@param Boolean
	*/
	public void setAllowCustomer( Boolean value ){
		WikiCreateWikiController.allowCustomer = value;
	}
	/** 
	*@param Boolean
	*/
	public void setAllowPartner( Boolean value ){
		WikiCreateWikiController.allowPartner = value;
	}
	/**
	*@return Boolean
	*/
	public Boolean getAllowCustomer(){
		return WikiCreateWikiController.allowCustomer;
	}
	/**
	*@return Boolean 
	*/
	public Boolean getAllowPartner(){
		return WikiCreateWikiController.allowPartner;
	} 
	/**
	*@return Boolean
	*/
	public Boolean getAllowCustomerActivated(){
		return allowCustomerActivated.size() > 0;
	}
	/**
	*@return Boolean
	*/
	public Boolean getAllowPartnerActivated(){
		return allowPartnetActivated.size() > 0;
	}
























    //Get id from team item
    String param = System.currentPageReference().getParameters().get('id');
    
    // max picture size bytes
    public final Integer MAX_SIZE = 524288;
    
    Wiki__c theWiki = new Wiki__c();
    String wikiPicture = '';
    
	//Valid size picture
	public Boolean validSizePicture = true; 
	
	//Valid Type Image (.jpe?g | .gif | .png)
	public Boolean validTypePicture = true;

	//Does a wiki with the same name aread exists?
	public Boolean errWikiNameAlreadyExists = false;

   
    public Attachment document = new Attachment();  
   
   /**
    * Constructor
    */
    public WikiCreateWikiController(){
    	
		allowCustomerActivated = [ SELECT Id FROM Group WHERE Type = 'AllCustomerPortal' ];
		allowPartnetActivated = [ SELECT Id FROM Group WHERE Type = 'PRMOrganization' ]; 
 
        if (param != null){
        	setWiki(param);
        	genPermissions();
        	if(!userPermissions.getCanManage())
        		throw new CustomException('Insufficient Privileges');
        	genMembers();
			List<GroupMember> gm = new List<GroupMember>();
			Group instance = new Group();
			String instanceName = 'wikiSharing' + param;
			if(allowCustomerActivated.size() > 0 ){
				instance = [ SELECT Id FROM Group WHERE Name =: instanceName LIMIT 1 ];
				gm = [ SELECT Id FROM GroupMember WHERE GroupId =: instance.Id AND UserOrGroupId =: allowCustomerActivated[0].Id ];
				WikiCreateWikiController.allowCustomer = (gm.size() > 0) ? true : false;
			}
			if(allowPartnetActivated.size() > 0 ){
				instance = [ SELECT Id FROM Group WHERE Name =: instanceName LIMIT 1 ];
				gm = [ SELECT Id FROM GroupMember WHERE GroupId =: instance.Id AND UserOrGroupId =: allowPartnetActivated[0].Id ];
				WikiCreateWikiController.allowPartner = (gm.size() > 0) ? true : false;
			}        	
        }
    }
    
   //Flag to determine if the Members tab will be available.
    Boolean hasMembers = false;
   
   	public void switchTabsController(){
   	
   	}
   
    /**
    *@return hasMembers
    */
    public Boolean getHasMembers(){
    	hasMembers = false;
    	if(param!=null){
    		String Id = [select Id from Wiki__c where Id=:param limit 1].Id;
			if((Id != null) && (Id != '')){
				hasMembers = true;
			}		    	
    	}
    	return hasMembers;
    }

	//Flag to determine if is in edition.
    Boolean inEdition = false; 
    
    /**
    *@return inEdition
    */
    public Boolean getInEdition(){
    	inEdition = false;
    	if(param!=null){
    		String Id = [select Id from Wiki__c where Id=:param limit 1].Id;
    		if((Id != null) && (Id != '')){
    			inEdition = true;
    		}
    	}
    	return inEdition;
    }
	
	/**
	*@param Attachment
	*/
	public void setdocument (Attachment attach) {
		this.document = attach;
	}
	 
	/**
	*@return Attachment
	*/
	public Attachment getdocument () {     
		return document;
	}
    
    /**
	*@ Return Valid size picture
	*/
     public Boolean getValidSizePicture(){
    	return validSizePicture;
    }	
    
    /**
	*@ Return Valid type picture
	*/
     public Boolean getValidTypePicture(){
    	return validTypePicture;
    }

    public boolean getErrWikiNameAlreadyExists() {
    	return errWikiNameAlreadyExists;
    }
    

    /**
    * Set String param
    *@param String p
    *@void
    */
    public void setParam(String p){
    	param = p;
    }
    
    /**
    * Get team instance
    *@return Team__c
    */
    public Wiki__c getWiki(){
        return theWiki;
    }
    
    /**
    * Set Team
    *@param Team__c t
    */
    public void setWiki(Wiki__c t){
    	theWiki = t;
    }
    
    /**
    * Get picture
    *@return String pic
    */
    public String getWikiPicture (){
        return wikiPicture;
    }

	public UserPermissions userPermissions = null;
	
	/**
	* Load permission for cuerrent user
	*/
	public void genPermissions () {
		userPermissions = new UserPermissions();
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(param);
		userPermissions.setObjectType('Wiki');
		userPermissions.setPermissions();
	}
	
	public String WikiType {get; set;}
	
    /**
    * Get Team
    *@param String team id
    *@void
    */
    public void setWiki (String tId){
	    theWiki = [Select t.Type__c,  
	                t.PublicProfile__c,
	                t.NewMemberProfile__c,
	                t.Name,
	                t.PictureId__c, 
	                t.Id, 
	                t.Description__c 
	                From Wiki__c t Where t.Id =:tId];
	    if(theWiki.Type__c != null){
	    	WikiType = theWiki.Type__c;
	    }
	    if(theWiki.Id != null){
            getWikiImage();
    		if(theWiki.PublicProfile__c != null && theWiki.NewMemberProfile__c != null){
	    		newProfile.newProfileOpen = theWiki.NewMemberProfile__c;
	    		newProfile.publicProfileOpen = theWiki.PublicProfile__c;
    		}else if (theWiki.PublicProfile__c != null){
    			newProfile.publicProfileClosed = theWiki.PublicProfile__c;
    		}
	    } 
    }
    /**
    * Team Profile Select
    *@return List<SelectOption>
    */
    public List<SelectOption> getProfiles(){
        List<WikiProfile__c> profiles = new List<WikiProfile__c>();
        List<SelectOption> options = new List<SelectOption>();
        profiles = [select p.Id, p.Name from WikiProfile__c p order by p.Name asc];
        for (WikiProfile__c tp : profiles){
            options.add(new SelectOption(tp.Id, tp.Name));
        }
        return options;
    }
        
    
    /**
    * Get Team Picture
    *@void
    */
    public void getWikiImage() {
        if(theWiki.PictureId__c != null) wikiPicture = '/servlet/servlet.FileDownload?file=' + theWiki.PictureId__c;
    }
    
    
    /**
    *Remove wiki's avatar if exist
    *@return PageReference
    */
	public PageReference removeAvatar()
	{
		if(theWiki.PictureId__c != null && getInEdition())
		{
			Attachment avatar = new Attachment();
			Wiki__c wiki = new Wiki__c();
			
			avatar = [ SELECT Id             FROM Attachment WHERE Id =: theWiki.PictureId__c  ];
			wiki   = [ SELECT id, PictureId__c FROM Wiki__c    WHERE Id =: theWiki.Id ];
			
			delete avatar;
			
			wiki.PictureId__c = null;
			upsert wiki;
			this.wikiPicture = '';
			
			
		}

		PageReference pageRef = new PageReference('/apex/WikiCreateWiki?id=' + theWiki.Id );
		pageRef.setRedirect(true);
		return pageRef;
	}
    /**
    * Class teamProfile
    */
    public class wikiProfile {
    	public String publicProfileOpen { set; get; }
    	public String newProfileOpen { set; get; }
    	public String publicProfileClosed { set; get; }
    	public String openOrClosed { set; get; }     	
    }
    
    wikiProfile newProfile = new wikiProfile();
    
    /**
    *@return new wiki profile
    */
    public wikiProfile getnewProfile(){
    	return newProfile;
    }
    
    
    /**
    * Save Wiki
    *@return wiki detail page reference
    *@throws Exception
    */    
    public PageReference saveWiki(){
    	try{
	    	validSizePicture = true;
			validTypePicture = true; 
			
			if (document.name == null || document.name == '' || document.BodyLength > MAX_SIZE || 
					!(document.ContentType == 'image/jpeg' || document.ContentType == 'image/pjpeg' || document.ContentType == 'image/gif' 
					|| document.ContentType == 'image/png')) {

				if (document.BodyLength > MAX_SIZE) {
					validSizePicture = false;
				}

				if (!(document.name == null || document.name == '') && !(document.ContentType == 'image/jpeg' || document.ContentType == 'image/pjpeg' ||  
						document.ContentType == 'image/gif' || document.ContentType == 'image/png')) {
					validTypePicture = false;
				} 
				document = new Attachment();

				if (!validSizePicture || !validTypePicture) {
					return null;
				}	
			} 

			if (theWiki.Id == null) {
				Wiki__c[] wikis= [ SELECT id FROM Wiki__c WHERE Name =: theWiki.Name ];
				
				if (wikis != null && wikis.size() > 0) {
					errWikiNameAlreadyExists = true;
					return null;
				}
			}
		 			
			if(theWiki.Type__c == 'open'){
    			List<WikiProfile__c> wp = [SELECT Name, Id 
    										FROM WikiProfile__c 
    										WHERE Name = 'Public Profile' 
    										LIMIT 1];
    			theWiki.PublicProfile__c = wp[0].Id;
    			theWiki.NewMemberProfile__c = newProfile.newProfileOpen;	    			
    		}else if (theWiki.Type__c == 'close') {
                List<WikiProfile__c> wp = [SELECT Name, Id 
                							FROM WikiProfile__c 
                							WHERE Name = 'Member Profile' 
                							LIMIT 1];
                theWiki.PublicProfile__c = null;
                theWiki.NewMemberProfile__c = wp[0].Id;
    		}else if (theWiki.Type__c == 'private'){
    			theWiki.PublicProfile__c = null;
    			theWiki.NewMemberProfile__c = null;
    		}
			
			if(theWiki.Id == null){
	    		insert theWiki;	
			}else {
	    		update theWiki;
	    	}
			
			if(document.name != null && document.name != ''){
	    		document.ParentId = theWiki.Id;
		    	insert document;
	    		theWiki.PictureId__c = document.Id;	
	    		update theWiki;
			}	
	    	
			PageReference pageRef = new PageReference('/apex/WikiTeamOverview?tid=' + theWiki.Id);
			pageRef.setRedirect(true);
			return pageRef;
    	}catch(Exception e){
    		throw e;
    	}  
    }
    
  	/**
  	*@return reload the page and open add members overlay
  	*/
  	public PageReference saveWikiAndAddMembers(){
		try{
			PageReference nextAction = saveWiki();
			PageReference pageRef = new PageReference('/apex/WikiCreateWiki?id=' + theWiki.Id + '&add=true');
			pageRef.setRedirect(true);
			if (nextAction == null) {
				return null;
			}
			else {
				return pageRef;
			}
		}catch(Exception e){
			throw e;
		}
		
  	}
  	
  	
  	/**
	*@return page reference to wiki topics view
	*/
	public pageReference saveAndRedirect(){
		pageReference nextAction = saveWiki();
        if(nextAction != null) {
        	nextAction.setRedirect(true);
        }
        return nextAction;
	}
  	
  	
  	/********************************
  	***** WikiMembersList logic 
  	*********************************
  	*/
  	
  	public String idWiki = System.currentPageReference().getParameters().get('id');
	public static String removeMemberId = System.currentPageReference().getParameters().get('delId');
	
	/** public String delName; */
	
	/**
	* Return the Namespace Prefix
	*@return String
	*/
	/**public String getNamespace () {
        return WikiUtil.getNamespace();
    } **/
	
	/**
	*@param String idWiki
	*/
	public void setIdWiki(String Wiki){
		idWiki = Wiki; 
	}
	
	/**
	* Set memberId to remove
	*@param String memberId
	*/
	public void setRemoveMemberId (String memberId){
		removeMemberId = memberId; 
	}
	
	public String getRemoveMemberId() {
	   return removeMemberId;	
	}
	
	/**
	* Refresh member list
	*@void
	*/
	public void refresh() {genMembers();}
	
	//public UserPermissions userPermissions = new UserPermissions();
	
	/**
	* Generate user permissions
	*@void
	*/
	/**public void genPermissions() {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setWiki(idWiki);
		userPermissions.setObjectType('Wiki');
		userPermissions.setPermissions();		
	}**/
	
	/**
	* Return user permissions
	*@return UserPermissions
	*/
	public UserPermissions getUserPermissions () {
		return userPermissions;
	}	
	
	/**
	*@return String Name
	*/	
	public String getWikiName () {
		String ret;
		if(idWiki != null){
			Wiki__c currentWiki = [select Name from Wiki__c where Id =: idWiki];
			ret = currentWiki.Name;
		}
		return ret;
	}

	/**
	*@return String ID
	*/	
	public String getWikiId () {
		return idWiki;	
	}
	
	/**
	* Return number of admin(s) in the Wiki
	*@return Integer
	*/	
	public Integer getAdminCount () {
		Integer countAdmin = [select count() from WikiMember__c where Wiki__c = :idWiki and WikiProfile__r.ManageWikis__c = true];
		return countAdmin;	
	}
	
	/**
	* Return user id from Wiki Member
	*@return String ID
	*/	
	public String getUserMemberId () {
		List<WikiMember__c> userMember = new List<WikiMember__c>();
		userMember = [select id from WikiMember__c where Wiki__c =:idWiki and User__c =:UserInfo.getUserId() limit 1];
		String userMemberId = '';
		if (userMember.size() > 0) {
			userMemberId = userMember[0].Id;	
		}
		return userMemberId;
	}
	
	/**
	* Return the current user's ID
	*@return String ID
	*/
	public String getCurrentUser () {
		return UserInfo.getUserId();
	}
	
	/**
	* Return if show the Remove Message
	*@return Boolean
	*/	
	public Boolean getRemoveMessage () {
		String removeParam = System.currentPageReference().getParameters().get('remMsg');
		return (removeParam == 'true');
	}
	
	/**
	* Asign the Name of the user to remove
	*@void
	*/
	public void assignRemoveId () {
		if (System.currentPageReference().getParameters().get('delId') != null) {
			removeMemberId = System.currentPageReference().getParameters().get('delId');	
		}
	}
	
	// Edit Members
	public String editMemberId = System.currentPageReference().getParameters().get('editId');
	public WikiMember__c editMember;
	public String imgEditMember = '';
	public Boolean itsLastAdmin = false;
	
	/**
	* Return if the user to delette is the last admin
	*@return Boolean
	*/
	public Boolean getItsLastAdmin () {
		return itsLastAdmin;	
	}
	
	/**
	* Return if the user to delette is the last admin
	*@param s member id
	*/
	public void setEditMemberId (String s){
		editMemberId = s;	
	}
	
	public String editMemberRole;
	
	/**
	* Get role from edit member
	*@return String
	*/
	public String getEditMemberRole () {
		return editMemberRole;
	}
	
	/**
	* Set role to edit member
	*@param String role
	*/
	public void setEditMemberRole (String role) {
		this.editMemberRole = role;
	}

	public String editMemberProfile;
	
	/**
	* Return idProfile from edit member
	*@return String
	*/
	public String getEditMemberProfile () {
		return editMemberProfile;
	}
	
	/**
	* Set idProfile to edit member
	*@param String
	*/
	public void setEditMemberProfile (String profile) {
		this.editMemberProfile = profile;
	}
	
	/**
	*@return WikiMember__c
	*/
	public WikiMember__c getEditMember () {
		return editMember;
	}
	
	/**
	* Return idImg from edit member
	*@return String
	*/
	public String getImgEditMember () {
		return imgEditMember;
	}
	
	/**
	*@return profiles select option list
	*/
	public List<SelectOption> getProfilesOptions () {
		List<SelectOption> options = new List<SelectOption>();
		for (WikiProfile__c item: [select id, Name from WikiProfile__c order by Name]) {
			options.add(new SelectOption(item.id,item.Name));
		}
		return options;
	}
	
	/**
	*@return profile list option filter
	*/
	public List<SelectOption> getProfilesOptionsFilter () {
		List<SelectOption> options = new List<SelectOption>();
		for (WikiProfile__c item: [select id, Name from WikiProfile__c where ManageWikis__c = true order by Name]) {
			options.add(new SelectOption(item.id,item.Name));
		}
		return options;
	}
	
	/** 
	* Return all Profiles
	*@return List<WikiProfile__c>
	*/
	public List<WikiProfile__c> getWikiEditProfiles () {
		return [select Name, id from WikiProfile__c order by Name];
	} 
	
	public List<Member> members = new List<Member>();
	
	/**
	* Return list of members
	*@return List<Member>
	*/
	public List<Member> getMembers () {
		return members;
	}
	
	/**
	* Inner class for Member class
	*@class
	*/
	public class Member {
		String memberImg;
		String alias;
		String username;
		String profile;
		String role; 
		String name;
		String userId;
		String WikiMemberId;
		Boolean admin;
		String yahoo;
		String skype;
		
		/**
		*@return String
		*/
		public String getYahoo () {
			return yahoo;
		}
		
		/**
		*@return String
		*/
		public String getSkype () {
			return skype;	
		}
		
		/**
		*@return String ID
		*/
		public String getUserId (){
			return userId;
		}
		
		/**
		*@return String ID
		*/
		public String getWikiMemberId (){
			return WikiMemberId;
		}
		
		/**
		*@param String ID
		*/
		public void setWikiMemberId (String WikiMemberId){
			this.WikiMemberId = WikiMemberId;
		}
		
		/**
		*@return String
		*/
		public String getName () {
			return name;
		}
		
		/**
		*@return String
		*/
		public String getMemberImg () {
			return memberImg;
		}
		
		/**
		*@return String
		*/
		public String getAlias () {
			return alias;
		}
		
		/**
		*@return String
		*/
		public String getUsername () {
			return username;
		}
		
		/**
		*@return String
		*/
		public String getProfile () {
			return profile;
		}
		
		/**
		*@return String
		*/
		public String getRole () {
			return role;
		}
		
		/**
		*@param String ID
		*/
		public void setUserId (String userId) {
			this.userId = userId;
		}
		
		/**
		*@param String alias
		*/
		public void setAlias (String alias) {
			this.alias = alias;
		}
		
		/**
		*@param String name
		*/
		public void setName (String name) {
			this.name = name;
		}
		
		/**
		*@param String
		*/
		public void setProfile (String profile) {
			this.profile = profile;
		}
		
		/**
		*@param String
		*/
		public void setRole (String role) {
			this.role = role;
		}
		
		/**
		*@param String
		*/
		public void setUsername (String username) {
			this.username = username;
		}
		
		/**
		*@param Boolean
		*/
		public void setAdmin (Boolean admin) {
			this.admin = admin;	
		}
		
		/**
		*@return Boolean
		*/
		public Boolean getAdmin () {
			return admin;
		}
	}
	
	public String letter;// = System.currentPageReference().getParameters().get('ltr');
	
	/**
	* Set letter value
	*@param String
	*/
	public void setLetter(String s){
		letter = s;	
	} 

	/**
	* Get letter value
	*@return String
	*/
	public String getLetter(){
		return letter;	
	}	
	/**
	* Search members
	*@void
	*/
	public void genMembers () {
		List<Member> membersList = new List<Member>();
		
		sortByDesc = false;
		sortBy = 'User__r.Name'; 
		
		if(System.currentPageReference().getParameters().get('ltr') != null){
			letter = System.currentPageReference().getParameters().get('ltr');
		}
		else{
			letter = 'ALL';
		}
				
		if (letter == null || letter == '' || letter== 'ALL') {
			for (WikiMember__c item: [select id, Name, WikiProfile__r.Name, WikiProfile__r.ManageWikis__c, User__r.Name, User__r.Username, User__r.Id, User__r.Alias from WikiMember__c where Wiki__c =:idWiki and User__r.IsActive != false order by User__r.Name]) {
				Member memberItem = new Member();
				memberItem.setName(item.User__r.Name);
				//memberItem.setRole(item.WikiRole__c);
				memberItem.setProfile(item.WikiProfile__r.Name);
				memberItem.setUsername(item.User__r.Username);
				memberItem.setUserId(item.User__r.Id);
				memberItem.setWikiMemberId(item.id);
				//memberItem.setMemberImg(item.User__r.Id);
				memberItem.setAdmin(item.WikiProfile__r.ManageWikis__c);
				memberItem.setAlias(item.User__r.Alias);
				membersList.add(memberItem);
			}
		}else {
			for (WikiMember__c item: [select id, Name, WikiProfile__r.Name, WikiProfile__r.ManageWikis__c, User__r.Name, User__r.Username, User__r.Id, User__r.Alias from WikiMember__c where User__r.Name like :(letter + '%') and User__r.IsActive != false and Wiki__c =:idWiki order by User__r.Name]) {
				Member memberItem = new Member();
				memberItem.setName(item.User__r.Name);
				//memberItem.setRole(item.WikiRole__c);
				memberItem.setProfile(item.WikiProfile__r.Name);
				memberItem.setUsername(item.User__r.Username);
				memberItem.setUserId(item.User__r.Id);
				memberItem.setWikiMemberId(item.id);	
				//memberItem.setMemberImg(item.User__r.Id);
				memberItem.setAdmin(item.WikiProfile__r.ManageWikis__c);
				memberItem.setAlias(item.User__r.Alias);
				membersList.add(memberItem);
			}
		}	
		totalItemsNumber = membersList.size();
		if (totalItemsNumber == 0 ) {
			cntPagination = 0;	
			firstRow = 0;
			currentPagination = 1;
		}else {
			firstRow = 0;
			currentPagination = 1;
			genCntPagination();	
		}
		members = membersList;
	}
   	
   	// Set of Integers to control pagination
   	public Integer numberOfItemsToShow = 10;
   	public Integer cntPagination;
   	public Integer currentPagination = 1;
   	public Integer firstRow = 0;
   	
   	// Set of Booleans to show or not prev / next links
   	public boolean prevPageLinkShow = false;
   	public boolean prevPageShow  = false;
   	public boolean nextPageLinkShow  = false;
   	public boolean nextPageShow  = false;
   	
   	/**
   	* Count number of result pages
   	*@void
   	*/
   	public void genCntPagination () {
   		cntPagination = (totalItemsNumber - (Math.mod(totalItemsNumber, numberOfItemsToShow)))/ numberOfItemsToShow;	
   		if (Math.mod(totalItemsNumber, numberOfItemsToShow) != 0 ) {
   			cntPagination++;
   		} 	
   	}
   	
   	/**
   	* Go next result page
   	*/
   	public void nextPage () {
   		currentPagination++;
   		firstRow = firstRow + numberOfItemsToShow;   		
   	}
   	
   	/**
   	* Go previus result page
   	*/
   	public void prevPage () {
   		currentPagination--;
   		firstRow = firstRow - numberOfItemsToShow;	
   	}

   	// Pagination Integer Getters
	public Integer totalItemsNumber= 0;
	
	/**
	*@return Integer
	*/
	public Integer getTotalItemsNumber () {
		return totalItemsNumber;
	}
	
   	/**
   	* Pagination Integer Getters
   	*@return Integer
   	*/
   	public Integer getFirstItem () {
		return (firstRow + 1);
	}
	
	/**
	* Assign a number to the last page's result
	*@return Integer
	*/
	public Integer getLastItem () {
		Integer lastItem;
		if ((currentPagination == cntPagination) || (currentPagination == 1 && (totalItemsNumber < numberOfItemsToShow))) {
			lastItem = firstRow + Math.mod(totalItemsNumber, numberOfItemsToShow);
		}else {
			lastItem = firstRow + 10;
		}
		return lastItem;
	}
   	
   	/**
   	* Return current page number
   	*@return Integer
   	*/
   	public Integer getCurrentPagination () {
   		return currentPagination;
   	}
   	
   	/**
   	* Return number of result pages
   	*@return Integer
   	*/
   	public Integer getCntPagination () {
   		return cntPagination;
   	}
   	
   	/**
   	* Return number of results
   	*@return Integer
   	*/
   	public Integer getNumberOfItemsToShow () {
   		return numberOfItemsToShow;
   	}
   	
   	/**
   	* Return the number of the first item of page
   	*@return Integer
   	*/
   	public Integer getFirstRow () {
   		return firstRow;
   	}
   	
   	/**
   	* Return if show Prev Link
   	*@return boolean
   	*/
	public boolean getPrevPageLinkShow () {
		return currentPagination != 1;
   	}
   	
   	/**
   	* Return if show Prev Link
   	*@return boolean
   	*/
   	public boolean getPrevPageShow () {
   		return currentPagination == 1;
   	}
   	
   	/**
   	* Return if show Next Link
   	*@return boolean
   	*/
   	public boolean getNextPageLinkShow () {
   		return !(currentPagination == cntPagination) || (cntPagination == 0);
   	}
   	
   	/**
   	* Return if show Next Link
   	*@return boolean
   	*/
   	public boolean getNextPageShow () {
   		return (currentPagination == cntPagination) || (cntPagination == 0);
   	}
	
	public List<String> lettersList = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};	
	
	/**
	* Inner class for Letters type
	*
	*/
	public class Letters {
		String letter;
		Boolean containMembers;
		
		/**
		*@param String
		*/
		public void setLetter (String letter) {
			this.letter = letter;
		}
		
		/**
		*@return String
		*/
		public String getLetter () {
			return letter;
		}
		
		/**
		*@param Integer
		*/
		public void setContainMembers (Integer cntMembers) {
			this.containMembers = cntMembers != 0;
		}
		
		/**
		*@return Boolean
		*/
		public Boolean getContainMembers () {
			return containMembers;
		}
	}
	
	
	/**
	* Return list with letters and if contain Wiki Members
	*@return List<Letters>
	*/
	public List<Letters> getLetterFilter () {
		List<Letters> letterFilter = new List<Letters>();
   		for (String item : lettersList) {
   			Letters currentLetter = new Letters();
   			Integer cntMembers = [select count() from WikiMember__c where User__r.Name like :(item + '%') and Wiki__c =:idWiki];
   			currentLetter.setLetter(item);
   			currentLetter.setContainMembers(cntMembers);
   			letterFilter.add(currentLetter);
   		}
   		return letterFilter;		
	}

   	/**
   	* Admin member
   	*@return Boolean
   	*/
	public Boolean getIsWikiAdmin () {
		List<WikiMember__c> currentUser = new List<WikiMember__c>();
		currentUser = [select WikiProfile__r.ManageWikis__c from WikiMember__c where Wiki__c =:idWiki and User__c =:UserInfo.getUserId()];
		Boolean isWikiAdmin = false;
		if (currentUser.size() > 0) {
			isWikiAdmin = (currentUser[0].WikiProfile__r.ManageWikis__c);
		} 
		return isWikiAdmin;		
	}

   	// SortBy
	public Boolean sortByDesc = false;
	// Order
	public String sortBy = 'User__r.Name';
	
	/**
	*@return Boolean
	*/
	public Boolean getSortByDesc () {
		return !sortByDesc;
	}
	
	/**
	*@param s sort by field
	*/
	public void setSortBy (String s){
		sortBy = s;	
	}
	
	/**
	*@return String
	*/
	public String getSortBy () {
		String sbCol = '';
		if (sortBy == null || sortBy == 'User__r.Name') 
			sbCol = 'name';	
		if (sortBy == 'User__r.Alias') 
			sbCol = 'alias';	
		if (sortBy == 'User__r.Username') 
			sbCol = 'username';	
		if (sortBy == 'WikiProfile__r.Name') 
			sbCol = 'profile';	
		//if (sortBy == 'WikiRole__c') 
		//	sbCol = 'role';	
		return sbCol;
	}
	
	/**
	 * This is a temporary method to cover us until dynamic apex is back.  This will use hard coded
	 * SOQL statements in place of the dynamic statements
	 */
	public void sortList () {
		List<Member> membersList = new List<Member>();
		if (sortBy == System.currentPageReference().getParameters().get('sb')) {
			sortByDesc = !sortByDesc;
		}else {
			sortByDesc = false;
		}
		
		//Sort param
		if(System.currentPageReference().getParameters().get('sb') != null)
			sortBy = System.currentPageReference().getParameters().get('sb');
		
		List<WikiMember__c> memberResultList = new List<WikiMember__c>();

		System.debug( '###:' + sortByDesc );
		System.debug( 'LLL:' + letter );
		System.debug( 'sss:' + sortBy );
		if (sortByDesc) {
			if (letter == null || letter == '' || letter== 'ALL') {
				if (sortBy == 'User__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   WikiProfile__r.Name, 
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Name desc];
				}
				if (sortBy == 'User__r.Alias') {
					memberResultList = [select id, 
											   Name, 
											   WikiProfile__r.Name,											    
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Alias desc];						
				}	
				if (sortBy == 'User__r.Username') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name, 
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Username desc];							
				}
				if (sortBy == 'WikiProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by WikiProfile__r.Name desc];						
				}
				/**if (sortBy == 'WikiRole__c') {
					memberResultList = [select id, 
											   Name, 
											   WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by WikiRole__c desc];						
				}*/		
			}else {
				if (sortBy == 'User__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Name desc];					
				}
				if (sortBy == 'User__r.Alias') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Alias desc];							
				}	
				if (sortBy == 'User__r.Username') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Username desc];							
				}
				if (sortBy == 'WikiProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name, 
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by WikiProfile__r.Name desc];						
				}
				/**if (sortBy == 'WikiRole__c') {
					memberResultList = [select id, 
											   Name, 
											   WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by WikiRole__c desc];						
				}**/
			}
		}else {
			if (letter == null || letter == '' || letter== 'ALL') {
				if (sortBy == 'User__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Name];
				}
				if (sortBy == 'User__r.Alias') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name, 
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Alias asc];						
				}	
				if (sortBy == 'User__r.Username') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Username];							
				}
				if (sortBy == 'WikiProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by WikiProfile__r.Name];						
				}
				/**if (sortBy == 'WikiRole__c') {
					memberResultList = [select id, 
											   Name, 
											   WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by WikiRole__c];						
				}**/	
			}else {
				if (sortBy == 'User__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Name];					
				}
				if (sortBy == 'User__r.Alias') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Alias];							
				}	
				if (sortBy == 'User__r.Username') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Username];							
				}
				if (sortBy == 'WikiProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by WikiProfile__r.Name];						
				}
				/**if (sortBy == 'WikiRole__c') {
					memberResultList = [select id, 
											   Name, 
											   WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Username, 
											   User__r.Id, 
											   User__r.Alias 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by WikiRole__c];						
				}**/	
			}			
		}
				 
		for (WikiMember__c item: memberResultList) {
			Member memberItem = new Member();
			memberItem.setName(item.User__r.Name);
			//memberItem.setRole(item.WikiRole__c);
			memberItem.setProfile(item.WikiProfile__r.Name);
			memberItem.setUsername(item.User__r.Username);
			memberItem.setUserId(item.User__r.Id);	
			//memberItem.setMemberImg(item.User__r.Id);
			memberItem.setAlias(item.User__r.Alias);
			membersList.add(memberItem);
		}
			
		totalItemsNumber = membersList.size();
		if (totalItemsNumber == 0 ) {
			cntPagination = 0;	
			firstRow = 0;
			currentPagination = 1;
		}else {
			firstRow = 0;
			currentPagination = 1;
			genCntPagination();	
		}
		members = membersList;	
	}

}