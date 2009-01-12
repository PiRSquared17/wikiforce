public class WikiMembersListController {

	public String idWiki = System.currentPageReference().getParameters().get('id');
	public String removeMemberId = System.currentPageReference().getParameters().get('delId');
	public String delName;
 
	/**
	* Constructor
	*/
	public WikiMembersListController () {
		//genPermissions();
		genMembers();
	}
	
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
	public void setRemoveMemberId (String mamberId){
		removeMemberId = mamberId; 
	}
	
	/**
	* Refresh member list
	*@void
	*/
	public void refresh() {genMembers();}
	
	public UserPermissions userPermissions = new UserPermissions();
	
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
		Wiki__c currentWiki = [select Name from Wiki__c where id=: idWiki];
		return currentWiki.Name;	 
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
		
		delName = [select User__r.Name from WikiMember__c where User__c =: removeMemberId and Wiki__c =: idWiki].User__r.Name;
	}
	
	/**
	* Return the Name of the user to remove
	*@return String
	*/
	public String getDelName () {
		return delName;
	}
	
	/**
	* Redirect after remove a member
	*@return PageReference
	*/
	public PageReference removeMember () {
		if (removeMemberId != UserInfo.getUserId()) {
			WikiMember__c delMember = [select User__r.Name from WikiMember__c where User__c =: removeMemberId and Wiki__c =: idWiki];
			delete delMember;
		}
		PageReference pageRef = Page.WikiMembersList;
		pageRef.getParameters().put('remMsg', 'true');
		pageRef.getParameters().put('id', idWiki);
		pageRef.setRedirect(true);
		return pageRef;	
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
	
	/**
	* Stuff before edit
	*@void
	*/
/**	public void assignEditId () {
		if (System.currentPageReference().getParameters().get('editId') != null) {
			editMemberId = 	System.currentPageReference().getParameters().get('editId');
		}
		editMember = [select id, User__r.name, WikiRole__c, WikiProfile__c, User__r.companyName, User__r.Title  from WikiMember__c where User__c =: editMemberId and Wiki__c =: idWiki];
		PeopleProfile__c img = [SELECT Picture__c from PeopleProfile__c WHERE User__c =: editMemberId LIMIT 1];
		if (img == null) {
			imgEditMember = '';
		}else {
			imgEditMember = img.Picture__c;
		}
		
		Integer countAdmin = [select count() from WikiMember__c where Wiki__c = :idWiki];
		Boolean isAdmin = [select WikiProfile__r.ManageWikis__c from WikiMember__c where Wiki__c =:idWiki and User__c=:editMemberId].WikiProfile__r.ManageWikis__c;
		
		itsLastAdmin = (editMemberId == UserInfo.getUserId()) && isAdmin;
		
		editMemberRole = editmember.WikiRole__c;
		editMemberProfile = editmember.WikiProfile__c;
	}
	*/
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
	* Redirect after edit a member
	*@return PageReference
	*/
	public PageReference editMemberAction () {	
		editMember.WikiProfile__c = editMemberProfile;
		//editMember.WikiRole__c = editMemberRole;
		update editMember;
		PageReference pageRef = Page.WikiMembersList;
		pageRef.getParameters().put('id', idWiki);
		pageRef.setRedirect(true);
		return pageRef;
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
		String company;
		String title;
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
		public String getCompany () {
			return company;
		}
		
		/**
		*@return String
		*/
		public String getTitle () {
			return title;
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
		*@param String company
		*/
		public void setCompany (String company) {
			this.company = company;
		}
		
		/**
		*@param String name
		*/
		public void setName (String name) {
			this.name = name;
		}
		
		/**
		*@param String idMember
		*/
	/**	public void setMemberImg (String memberId) {
			
			List<PeopleProfile__c> imgs = new List<PeopleProfile__c>();
			try {
				imgs = [SELECT Id, YahooIM__c, Skype__c, Picture__c from PeopleProfile__c WHERE User__c =: memberId LIMIT 1];
			} catch(Exception e){
				throw e;
			}
			PeopleProfile__c img = new PeopleProfile__c();
			if(imgs.size() > 0){
				img = imgs[0];
			} 
			
			if (img == null) {
				this.memberImg = '';
				this.yahoo = '';
				this.skype = '';
			}else {
				this.memberImg = img.Picture__c;
				if(img.YahooIM__c != null){
	            	this.yahoo = img.YahooIM__c;
	            }else {
	            	this.yahoo = '';
	            }
	            if(img.Skype__c != null){
	            	this.skype = img.Skype__c;
	            }else {
	            	this.skype = '';
	            }
			}
		}**/
		
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
		public void setTitle (String title) {
			this.title = title;
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
	
	public String letter = System.currentPageReference().getParameters().get('ltr');
	
	/**
	* Set letter value
	*@param String
	*/
	public void setLetter(String s){
		letter = s;	
	}
	
	/**
	* Search members
	*@void
	*/
	public void genMembers () {
		List<Member> membersList = new List<Member>();
		
		sortByDesc = false;
		sortBy = 'User__r.Name'; 
		
		if(System.currentPageReference().getParameters().get('ltr') != null)
			letter = System.currentPageReference().getParameters().get('ltr');
				
		if (letter == null || letter == '' || letter== 'ALL') {
			for (WikiMember__c item: [select id, Name, WikiProfile__r.Name, WikiProfile__r.ManageWikis__c, User__r.Name, User__r.Title, User__r.Id, User__r.CompanyName from WikiMember__c where Wiki__c =:idWiki and User__r.IsActive != false order by User__r.Name]) {
				Member memberItem = new Member();
				memberItem.setName(item.User__r.Name);
				//memberItem.setRole(item.WikiRole__c);
				memberItem.setProfile(item.WikiProfile__r.Name);
				memberItem.setTitle(item.User__r.Title);
				memberItem.setUserId(item.User__r.Id);
				memberItem.setWikiMemberId(item.id);
				//memberItem.setMemberImg(item.User__r.Id);
				memberItem.setAdmin(item.WikiProfile__r.ManageWikis__c);
				memberItem.setCompany(item.User__r.CompanyName);
				membersList.add(memberItem);
			}
		}else {
			for (WikiMember__c item: [select id, Name, WikiProfile__r.Name, WikiProfile__r.ManageWikis__c, User__r.Name, User__r.Title, User__r.Id, User__r.CompanyName from WikiMember__c where User__r.Name like :(letter + '%') and User__r.IsActive != false and Wiki__c =:idWiki order by User__r.Name]) {
				Member memberItem = new Member();
				memberItem.setName(item.User__r.Name);
				//memberItem.setRole(item.WikiRole__c);
				memberItem.setProfile(item.WikiProfile__r.Name);
				memberItem.setTitle(item.User__r.Title);
				memberItem.setUserId(item.User__r.Id);
				memberItem.setWikiMemberId(item.id);	
				//memberItem.setMemberImg(item.User__r.Id);
				memberItem.setAdmin(item.WikiProfile__r.ManageWikis__c);
				memberItem.setCompany(item.User__r.CompanyName);
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
			this.containMembers = cntMembers == 0;
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
		if (sortBy == 'User__r.CompanyName') 
			sbCol = 'company';	
		if (sortBy == 'User__r.Title') 
			sbCol = 'title';	
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

		if (sortByDesc) {
			if (letter == null || letter == '' || letter== 'ALL') {
				if (sortBy == 'User__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   WikiProfile__r.Name, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Name desc];
				}
				if (sortBy == 'User__r.CompanyName') {
					memberResultList = [select id, 
											   Name, 
											   WikiProfile__r.Name,											    
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.CompanyName desc];						
				}	
				if (sortBy == 'User__r.Title') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Title desc];							
				}
				if (sortBy == 'WikiProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
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
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
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
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Name desc];					
				}
				if (sortBy == 'User__r.CompanyName') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.CompanyName desc];							
				}	
				if (sortBy == 'User__r.Title') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Title desc];							
				}
				if (sortBy == 'WikiProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
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
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
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
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Name];
				}
				if (sortBy == 'User__r.CompanyName') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.CompanyName asc];						
				}	
				if (sortBy == 'User__r.Title') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Title];							
				}
				if (sortBy == 'WikiProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
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
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
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
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Name];					
				}
				if (sortBy == 'User__r.CompanyName') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.CompanyName];							
				}	
				if (sortBy == 'User__r.Title') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from WikiMember__c 
										where User__r.Name like: (letter + '%') 
										and Wiki__c =: idWiki and User__r.IsActive != false
										order by User__r.Title];							
				}
				if (sortBy == 'WikiProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   //WikiRole__c, 
											   WikiProfile__r.Name,  
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
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
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
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
			memberItem.setTitle(item.User__r.Title);
			memberItem.setUserId(item.User__r.Id);	
			//memberItem.setMemberImg(item.User__r.Id);
			memberItem.setCompany(item.User__r.CompanyName);
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