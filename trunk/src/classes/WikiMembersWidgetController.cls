/**
*@author Jesus Ibanez @ 1-9-2009
*/
public with sharing class WikiMembersWidgetController {

	// Get Wiki Id Attribute
	String Wiki;
	Boolean emailNotifications;
	public String WikiCompleteName;
	public Boolean errNotAllUsersAdded = false;
	public Boolean finishedAdding = false;
	
	/**
	* Constructor
	*/
	public WikiMembersWidgetController(){}

	/**
	* Return the Namespace Prefix
	*@return String
	*/
	public String getNamespace () {
        return TeamUtil.getNamespace();
    }
    
	Boolean makeMembersAdmins;
	
	public Boolean getMakeMembersAdmins(){
		return makeMembersAdmins;
	}
	
	public void setMakeMembersAdmins(Boolean makeMembersAdmins){
		this.makeMembersAdmins = makeMembersAdmins;
	}
	
	/**
	* Setter method for Wiki Id variable
	*@param String idWiki
	*/
	public void setWiki(String tID) {
		if (Wiki == null || Wiki != tID) {
			Wiki = tID;
			/**genPermissions();
			Boolean canView = userPermissions.getCanView();
			if(!canView){
				throw new CustomException('Insufficient Privileges');
			} */
			assignNewMemberVarsNewProfile();
		}
	}
	
	/**
	*@return String idUser
	*/
	public String getCurrentUser () {
		return UserInfo.getUserId();	
	}
	
	/**
	*@return String idWiki
	*/
	public String getWiki(){
		return Wiki;
	}

	public Boolean showWidget;
	
	/**
	* Setter method for Wiki Id variable
	*@param Boolean showWidget
	*/
	public void setShowWidget(Boolean s) {
		showWidget = s;		
	}
	
	/**
	*@return Boolean show widget
	*/
	public Boolean getShowWidget(){
		return showWidget;
	}
	
	public Boolean getErrNotAllUsersAdded() {
		return errNotAllUsersAdded;
	}
	
	public Boolean getFinishedAdding() {
		return finishedAdding;
	}
	
	/**
	* Get Wiki Members
	*@return List<WikiMember>
	*/
	public List<WikiMember> getWikispaceMembers() {
		List<WikiMember__c> temp = new List<WikiMember__c>();
      	
    	temp = [select User__r.Id, User__r.Name from WikiMember__c where Wiki__c =: Wiki and User__r.IsActive != false order by User__r.Name];
        
        Set<Id> users = new Set<Id>();
        for(WikiMember__c wm: temp) {
        	users.add(wm.User__c);
		}
		
		Map<Id, User> userMap = new Map<Id, User>();
        for(User u: [SELECT Id, Name FROM  User WHERE Id IN: users]) {
			userMap.put(u.Id, u);				          	
		}
                    	
        List<WikiMember> members = new List<WikiMember>();
		if(temp.size() > 0){ 
	        for(WikiMember__c w: temp) {
	            WikiMember m = new WikiMember(w, userMap.get(w.User__c));
	            m.Id = w.User__r.Id;
	            String nameAux = w.User__r.Name;
	            if(nameAux.length() > 20)
	            	nameAux = nameAux.substring(0,20);
	            m.username = nameAux;
	            members.add(m);
	        }
		}
		temp = null; 
		return members;
    }
    
     /**
    * Returns a String with Ids of the Wiki separated by '-'
    *@return String
    */
    public String getWikispaceMembersIds(){
    	String ret = '';
    	List<WikiMember> l = getWikispaceMembers();
    	for(Integer i = 0; i < l.size(); i++){
    		WikiMember tm = l.get(i);
    		if(i+1 == l.size()){//Last element
    			ret += tm.id;
    		}else{
    			ret += tm.id + '-';
    		}	
    	}
    	return ret;
    } 
    
    /**
    * Inner class for WikiMeber type
    *@class
    */
    public class WikiMember{
        
        WikiMember__c member;
        User profile = new User();
        String username = null;
        String Id = '';
        String picture = '';
        Boolean isPrivate = false;
        
		/**
		* Costructor
		*@param WikiMember__c
		*@param User__c
		*/
        public WikiMember(WikiMember__c m, User p) {
            member = m; 
            profile = p;                     
        }       
        
        /**
        *@return String idTeamMember
        */
        public String getId(){
        	return Id;
        }
		
		/**
		*@return TeamMember__c
		*/
        public WikiMember__c getMember() {
            return member;
        }
        
        /**
        *@return String
        */
        public String getUsername() { 
       		return username; 
        }
        
        /**
        *@return Boolean
        */
        public Boolean getIsPrivate() { 
       		return isPrivate; 
        }
        
        
        /**
        *@return User
        */
        public User getProfile(){         
         	 if(profile != null){
         	 	return profile;
         	 } else {
         	 	return new User();
         	 }
       	}
    }
	
	// Add new Member
	public String idWiki = System.currentPageReference().getParameters().get('id');
	
	/**
	*@param String ID
	*/
	public void setIdWiki(String s){
		idWiki = s;
	}
	
	public List<WikiMember__c> membersToInsert = new List<WikiMember__c>();
	public List<User> mailList = new List<User>();
	public Integer groupCount = 1;
	
	public String WikiName = null;
	
	/**
	* Get Wiki Name
	*@return String Wiki name
	*/
	public String getWikiName () {
		if(WikiName == null && idWiki != null)
		{	
			WikiName = [select Name from Wiki__c where Id =: idWiki].Name;
			WikiCompleteName = WikiName;
			WikiName = ( WikiName.length() > 45 ) ? WikiName.substring( 0, 44 ) + ' ...' : WikiName;
		}
		return WikiName;	
	}
	
	/**
	* Get Wiki Complete Name
	*@return String Wiki name
	*/
	public String getWikiCompleteName () {
		if(WikiCompleteName == null && idWiki != null)
		this.getWikiName();
		
		return WikiCompleteName;	
	}
	
	
	
	/**
	*@return String
	*/
	public String getWikiId () { 
		return idWiki;	
	}
	
	/**
	*@return List<SelectOption>
	*/
	public List<SelectOption> getProfilesOptions () {
		List<SelectOption> options = new List<SelectOption>();
		for (WikiProfile__c item: [select id, Name from WikiProfile__c order by Name]) {
			options.add(new SelectOption(item.id,item.Name));
		}
		return options;
	}
	

	public Member newMemberVars = new Member();
	
	/**
	* Assign new Member vars to new Profile
	*@void
	*/
	public void assignNewMemberVarsNewProfile () {
		List<Wiki__c> currentWiki = [select NewMemberProfile__c from Wiki__c where id=:idWiki];
		if (currentWiki.size() > 0 && currentWiki[0].NewMemberProfile__c != null) {	
			newMemberVars.profileId = currentWiki[0].NewMemberProfile__c;
		}
	}
	
	/**
	*@return Member
	*/	
	public Member getNewMemberVars () {
		return newMemberVars;	
	}
	
	/**
	*@param Member vars
	*/
	public void setNewMemberVars (Member vars) {
		this.newMemberVars = vars;
	}
	
	/**
	*@class
	*/
	public class Member {
		String profileId;
		String message;
		String WikiRole;
		String colleagueNames;
		
		/**
        *@return String
        */
		public String getColleagueNames () {
			return colleagueNames;
		}
		
		/**
        *@param String names
        */
		public void setColleagueNames (String names) {
			this.colleagueNames = names;
		}
		
		/**
        *@return String ID
        */
		public String getProfileId () {
			return profileId;
		}
		
		/**
        *@param String ID
        */
		public void setProfileId (String profile) {
			this.profileId = profile;
		}	
		
		/**
        *@return String Message
        */
		public String getMessage () {
			return message;
		}
		
		/**
        *@param String Message
        */
		public void setMessage (String msj) {
			this.message = msj;
		}
		
		/**
        *@return String Role
        */
		public String getWikiRole () {
			return WikiRole;
		}
		
		/**
        *@param String Role
        */
		public void setWikiRole (String tRole) {
			this.WikiRole = tRole;
		}	
		
	}
	
	public List<WikiMember__c> memberListToolkit = new List<WikiMember__c>();
	
	/**
	*@return List<WikiMember__c>
	*/
	public List<WikiMember__c> getMemberListToolkit () {
		return memberListToolkit;
	}
	
	public Integer memberListToolkitCount = 0;
	
	/**
	*@return Integer
	*/
	public Integer getMemberListToolkitCount () {
		return memberListToolkitCount;
	}
		
	Boolean already = false;
	
	/**
	*@return already exist
	*/
	public Boolean getAlready(){
		return already;
	}	
			

	/**
	* Save Members
	*@void
	*/
	public void saveMembers () {
		List<WikiMember__c> newMemberList = new List<WikiMember__c>();
		List<String> newMembers = newMemberVars.colleagueNames.split('[ ]*,[ ]*');
		List<User> userList = new List<User>();
		already = false;
		errNotAllUsersAdded = false;
		finishedAdding = false;
		
		Map<String, User> usersMap = new Map<String, User>();
		
		for (User iterUser :[select id, Name, IsActive, Email from User where Name in:newMembers]) {
			usersMap.put(iterUser.Name, iterUser);
		}
		
		if (usersMap.size() != newMembers.size())
			errNotAllUsersAdded = true;
		
		for(String item: newMembers) {
			if (usersMap.get(item) != null) {
				already = false;
				Integer listPos = 0;
				while (!already && listPos < userList.size()) {
					if(userList[listPos].Name == usersMap.get(item).Name) {
						already = true;
					}
					listPos++;
				}
				if (!already) {
					userList.add(usersMap.get(item));
				}else {
					already = true;
				}
			}
		}
		
		Map<Id, WikiMember__c> WikiMemberMap = new Map<Id, WikiMember__c>();
		for (WikiMember__c iterMember : [select id, User__c  from WikiMember__c where Wiki__c =:idWiki]) {
			WikiMemberMap.put(iterMember.User__c,iterMember);
		}
		
		//Read Member Profile
		List<WikiProfile__c> wikiMemberProfile = new List<WikiProfile__c>();
			
		//Read Admin Profile
		List<WikiProfile__c> wikiAdminProfile = new List<WikiProfile__c>();
		
		if(makeMembersAdmins){	
			wikiAdminProfile = [Select Name, Id From WikiProfile__c Where Name = 'Wiki Administrator'];
		} else {
            wikiMemberProfile = [Select Name, Id From WikiProfile__c Where Name = 'Member Profile'];	
		}
		
		for (User user : userList) {
			if (WikiMemberMap.get(user.Id) == null && usersMap.get(user.Name).IsActive != false) {
				WikiMember__c newMember = new WikiMember__c();
				newMember.User__c = user.id;
				newMember.Name = user.Name;
				newMember.Wiki__c = idWiki;
				
				//Set Profile
				if(makeMembersAdmins && wikiAdminProfile.size() > 0){
					newMember.WikiProfile__c = wikiAdminProfile[0].Id;
				}else{
					//newMember.WikiProfile__c = newMemberVars.profileId;						
					newMember.WikiProfile__c = WikiMemberProfile[0].Id;
				}
				
				//Add user to list
				newMemberList.add(newMember);
				
				//Send Email Notifications
				if(this.emailNotifications)
					mailList.add(user);
			}
		}
		
		userList.clear();
		WikiMemberMap.clear();
		usersMap.clear();
		
		memberListToolkit = newMemberList;
		memberListToolkitCount = newMemberList.size();
		
		//Insert newMemberList;
		membersToInsert = newMemberList;
		newMemberVars.colleagueNames = '';
		newMemberVars.WikiRole = '';
		newMemberVars.profileId = '';
		newMemberVars.message = '';
		
		finishedAdding = true;
	}
	
	//New save
	public Integer countSaved = 0;
	public Boolean reset = false;
	
	/**
	* Sync Save Members
	*@return PageReference
	*/
	public PageReference syncSaveMembers(){
			
			Integer endIt =  countSaved + 2;
			for(Integer it = countSaved; it <= endIt; it++){
				if(it < membersToInsert.size()){
					WikiMember__c tm = membersToInsert[it];
					for(User user: mailList){
						if(tm.User__c == user.id){
							SendMail(user,newMemberVars.message);
						}
					}
					insert tm;
					memberListToolkitCount--;
				}else{
					membersToInsert.clear();
					mailList.clear();
					groupCount = 0;
					reset = true;
				}
			}
			if(reset){
				countSaved = 0;
				reset = false;
			}else{
				countSaved += 3;
			}
			return null;
			
	}
	
	/**
	* Init save members
	*@return Boolean
	*/
	public Boolean getInitAddMembers (){
		return membersToInsert.size() > 0;
	} 
	
	public Boolean getEmailNotifications(){
		return emailNotifications;
	}
	
	public void setEmailNotifications(Boolean emailNotifications){
		this.emailNotifications = emailNotifications;
	}
	
	/**
	* Send mail to new mambers
	*@void
	*/
	public void SendMail(User user, String message) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        String[] toAddresses = new String[] {user.Email};
 		// Assign the addresses for the To and CC lists to the mail object.
		mail.setToAddresses(toAddresses);
		// Specify the address used when the recipients reply to the email.
		mail.setReplyTo('forwardtosfdc@gmail.com');
		// Specify the name used as the display name.
		mail.setSenderDisplayName(user.Name);
		// Specify the subject line for your email address.
		mail.setSubject('You Have Been Added to ' + this.getWikiName());
		// Set to True if you want to BCC yourself on the email.
		mail.setBccSender(false);
		// Optionally append the salesforce.com email signature to the email.
		// The email address of the user executing the Apex Code will be used.
		mail.setUseSignature(true);
		// Specify the html version of the content as well.
		message = (message == null) ? '' : message;
		mail.setHtmlBody(message);
		// Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }	
    
    // Sharing rules
	public UserPermissions userPermissions = WikiDetailsController.userPermission.clone();
	
	/**
	* Generate user permissions
	*/
	public void genPermissions() {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(Wiki);
		userPermissions.setObjectType('Wiki');
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
	* Rerender use only
	*/
	public void refreshMethod(){
		
	}
}