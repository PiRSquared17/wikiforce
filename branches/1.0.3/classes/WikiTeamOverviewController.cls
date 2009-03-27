/**
*@author Gabriel Rilo @ 01/06/2009
*/
//public with sharing class WikiTeamOverviewController {
public with sharing class WikiTeamOverviewController {
	
	// Wiki__c given in the url
	public String TEAMID = System.currentPageReference().getParameters().get('tid');
   	public WikiMemberController wmc = new WikiMemberController();
	public Boolean isLastMemberAdmin = wmc.isLastMemberAdmin();
	//Lcosta added feb 10
	public Boolean isPrivate;
	public Boolean pagesUpdates = false;
	/**
	* Costructor
	*/
	public WikiTeamOverviewController () {
		genContructor();
	}
	
	public Boolean getPagesUpdates(){
		return this.pagesUpdates;
	}
	/**
	*@retrun bool is last member admin
	*/
	public Boolean getIsLastMemberAdmin (){
		return isLastMemberAdmin;
	}
	
	/**
	*@param b is lasta member admin
	*/
	public void setIsLastMemberAdmin(Boolean b){
		isLastMemberAdmin = b;
	}	
	
	/**
	* Return the Namespace Prefix
	*@return String
	*/
	public String getNamespace () {
        return TeamUtil.getNamespace();
    } 
	
	/**
	*@param String
	*/
	public void setTEAMID(String sTeam){
		TEAMID = sTeam;		
	}
	
	// List of wiki pages
	List<wikiPageInfo> wikiPagesList = new List<wikiPageInfo>();
	// List of Wiki childs 
	List<wikiPageInfo> wikiPagesChildList = new List<wikiPageInfo>();
	
	/**
	*@return String
	*/
	public String getTEAMID (){
		return TEAMID;
	}

	/** FIX
	* Executes on constructor
	*@throws CustomException
	*/
	public void genContructor () {
		if (TEAMID != null && TEAMID != '') {
			genWikiTree();
			genTeamData();
			genWikiSites();
			genPermissions();
			genPermissionsTeam();
			genIsAdmin();
			if(!userPermissionsTeam.getCanView()) 
				throw new CustomException('Insufficient Privileges');
			//lcosta added feb 10
			genIsPrivate();
		}
	}


	public Boolean getIsPrivate(){
		return isPrivate;
	}
	
	public void setIsPrivate(Boolean b){
		isPrivate = b;
	}
	
	/**
	* Set the attribute isPrivate
	* true if the wiki is private
	*/
	//lcosta added feb 10
	public void genIsPrivate(){
		 Wiki__c currentWiki = [select PublicProfile__c, NewMemberProfile__c from Wiki__c where Id =: TEAMID];
		 if (currentWiki.PublicProfile__c == null && currentWiki.NewMemberProfile__c == null) {
		 	this.setIsPrivate(true);
		 }
		 else {
		 	this.setIsPrivate(false);
		 }
	}	
	
	
	public UserPermissions userPermissions = new UserPermissions();
		
	/**
	* Read user permissions for wiki obj
	*/
	public void genPermissions () {
		
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(TEAMID);
		userPermissions.setObjectType('Wiki');
		userPermissions.setReadAgain(true);
		userPermissions.setPermissions();	
		
		System.debug( '###' + UserInfo.getUserId() + ':' + TEAMID + ':' + userPermissions.getCanCreate() );		
	}
	
	/**  
	*@return UserPermissions
	*/
	public UserPermissions getUserPermissions () {
		genPermissions();
		return userPermissions;
	}
	
	/**
	* Redirect after delete wiki
	*@return PageReference
	*/
	public PageReference redirectAfterDelete(){
		PageReference wikiOverview = Page.WikiOverview;
		wikiOverview.setRedirect(true);
		return wikiOverview;
	}
	
	public UserPermissions userPermissionsTeam = new UserPermissions();
		
	/** FIX
	* Read user permission for Team obj
	*/
	public void genPermissionsTeam () {
		userPermissionsTeam.setId(UserInfo.getUserId());
		userPermissionsTeam.setTeam(TEAMID);
		userPermissionsTeam.setObjectType('Wiki');
		userPermissionsTeam.setPermissions();		
	}
	
	
	/** FIX
	*@return UserPermissions
	*/	
	public UserPermissions getUserPermissionsTeam () {
		return userPermissionsTeam;
	}
	
	Wiki__c currentTeam = new Wiki__c();
	private Boolean isMember;
	private Boolean isPublic;
	
	/**
	* Join to wiki
	*/
	public void joinWiki(){
		wmc.setWikiId(System.currentPageReference().getParameters().get('wid'));
		isMember = true;
		wmc.joinWiki();
	}
	
	/**
	* Unjoin to wiki
	*/
	
	public void unjoinWiki(){
		wmc.setWikiId(System.currentPageReference().getParameters().get('wid'));
		if(!wmc.isLastMemberAdmin()){
			wmc.unjoinWiki();
			isMember = false;
			isLastMemberAdmin = false;
		}else{
			isLastMemberAdmin = true;
		}
	}
	
	/**
	*@param Boolean
	*/
	public void setIsMember(Boolean ism){
		this.isMember = ism;
	}
	
	/**
	*@param Boolean
	*/
	public void setIsPublic(Boolean isp){
		this.isPublic = isp;
	}
	
	/**
	*@return Boolean
	*/
	public Boolean getIsMember(){
		return this.isMember;
	}
	
	/**
	*@return Boolean
	*/
	public Boolean getIsPublic(){
		return this.isPublic;
	}
	
	private Boolean isAdmin;
	
    /**
    *@param Boolean
    */
    public void setIsAdmin(Boolean isa){
    	this.isAdmin = isa;
    }
    
    /**
    *@return Boolean
    */
    public Boolean getIsAdmin(){
    	return this.isAdmin;
    }
    
    /**
    * Verify if current user is admin
    */
    private void genIsAdmin(){
    	List<User> teamAdmin = [Select Id, Profile.PermissionsModifyAllData From User where id =: UserInfo.getUserId() limit 1];
    	List<WikiMember__c> wiki = [select WikiProfile__r.Name from WikiMember__c where Wiki__c =: TEAMID and User__c =: UserInfo.getUserId() limit 1];
    	String nameProfileAdmin = 'Wiki Administrator';
    	if(teamAdmin[0].Profile.PermissionsModifyAllData) {
    	   this.setIsAdmin(teamAdmin[0].Profile.PermissionsModifyAllData || nameProfileAdmin.equals(wiki[0].WikiProfile__r.Name));
    	} else {
    	   this.setIsAdmin(false);
    	}
    }
    
	/**
	*@return Wiki__c
	*/
	public Wiki__c getCurrentTeam(){
		return currentTeam;
	}
	
	/**
	* Load team for current teamid
	*/
	public void genTeamData(){
		if(TEAMID != null){
			currentTeam = [select Id, Name, PublicProfile__c from Wiki__c where id =: TEAMID];
			if(currentTeam.PublicProfile__c != null)
				this.setIsPublic(true);
			else 
				this.setIsPublic(false);
			
			List<WikiMember__c> member = [select Id from WikiMember__c where Wiki__c =: TEAMID and User__c =: UserInfo.getUserId() ];
			if(member.size() > 0)
				this.setIsMember(true);
			else 
				this.setIsMember(false);
		}
	}
	
	/** FIX
	* Create wiki tree
	*/	
	public void genWikiTree(){
		wikiPagesList.clear();
		List<WikiPage__c> wpl = new List<WikiPage__c>();
		
	   	wpl = [ Select Id, Parent__c,  Name, (Select Parent__c , Name , Id From WikiPages__r) From WikiPage__c where Wiki__c =: TEAMID and Parent__c = ''];
		
		List <WikiPage__c> wpchildListSecondLevel = [ Select Id, Parent__c,  Name, (Select Parent__c , Name , Id From WikiPages__r) From WikiPage__c where Parent__c in :wpl];
		
		for(WikiPage__c wp: wpl){
			wikiPageInfo wpage = new wikiPageInfo();
			wpage.Id = wp.Id; 
			wpage.Parent = wp.Parent__c;
			wpage.Name = trunkText(wp.Name);
			if(wp.WikiPages__r.size() != 0 ){
				wpage.HasChilds = true;
				List<wikiPageChild> wikiChilds = new List<wikiPageChild>();
				for(WikiPage__c wpchild: wpchildListSecondLevel){
					if(wpchild.Parent__c == wp.Id){
						wikiPageChild wikiChildItem = new wikiPageChild();
						
						wikiChildItem.Id = wpchild.Id;
						wikiChildItem.Parent = wpchild.Parent__c;
						wikiChildItem.Name = trunkText(wpchild.Name);
						
						if(wpchild.WikiPages__r.size() != 0){
							wikiChildItem.HasChilds = true;
						} else {
							wikiChildItem.HasChilds = false;
						}					
						wikiChilds.add(wikiChildItem);
					}
				}			
				wpage.childs = wikiChilds;
			} else {
				wpage.HasChilds = false;
			}	
			wikiPagesList.add(wpage);
		}		
	}
	
	/**
	* Tunk text, util method
	*@param t text
	*@return trunkated text
	*/
	public String trunkText(String t){
		String text = '';
		if(t.length() > 30){
			text = t.substring(0, 30 );
			text = text + '...';
		} else {
			text = t;
		}
		return text;		
	}
	
	/**
	* Class wikiPageInfo
	*/
	public class wikiPageInfo {
		public String Id {set; get;}
		public String Parent { set; get; }
		public String Name { set; get; }
		public Boolean HasChilds { set; get; }
		public List<wikiPageChild> childs { set; get; }
	}
	
	/**
	* Class wikiPageChild
	*/
	public class wikiPageChild {
		public String Id {set; get;}
		public String Parent { set; get; }
		public String Name { set; get; }
		public Boolean HasChilds { set; get; }
	}
	
	/**
	* Returns wiki page list
	*@return List<wikiPageInfo>
	*/
	public List<wikiPageInfo> getWpl(){
		return wikiPagesList;
	}
   	
	public List<TeamWikis> wikiSites;
	
	/**
	*@return List<TeamWikis>
	*/
	public List<TeamWikis> getWikiSites () {
		return wikiSites;
	}
	
	/**
	* Read wikis for 10 teams
	*/
	public void genWikiSites () {
		List<Wiki__c> sites;
		sites = [select Id, Name, Description__c from Wiki__c order by Name limit 10];
		
		
		List<TeamWikis> teamWikiList = new List<TeamWikis>();
		for (Wiki__c item : sites) {
			TeamWikis teamWikiItem = new TeamWikis();
			teamWikiItem.setId(item.Id);
			teamWikiItem.setName(item.Name);
			teamWikiItem.setDescription(item.Description__c);
			teamWikiItem.setPicture(item.Id);
			teamWikiList.add(teamWikiItem);
		}
		wikiSites = teamWikiList;
	}
	
   	
   	/**
   	* Class TeamWikis 
   	*/
   	public class TeamWikis  {
   		String id;
   		String name;
   		String description;
   		String picture;
   		
   		/**
   		*@return String
   		*/
   		public String getId () {
   			return id;
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
   		public String getDescription () {
   			return description;
   		}
   		
   		/**
   		*@return String
   		*/
   		public String getPicture () {
   			return picture;
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
   		public void setName (String name) {
   			this.name = name;
   		}
   		
   		/**
   		*@param String
   		*/
   		public void setDescription (String description) {
   			this.description = description;
   		}
   		
   		/**
   		*@param String
   		*/
   		public void setPicture (String picture) {
   			List<Attachment> attach = new List<Attachment>();
	    	attach = [select Id from Attachment where ParentId =:picture limit 1];
	        if(attach.size() > 0) {	
	        	this.picture = attach[0].Id;
	        }else {
	        	this.picture = '';
	        }
   		}  
   	}
   	
	/**
	* Class Wiki
	*/
   	public class Wiki {
   		String name; 
   		String id;
   		String lastModifiedBy;
   		String lastModifiedById;
   		String lastModifiedDate;
   		String parentName;
   		String parentId;
   		String shortDescription;
   		
   		/**
   		*@param String
   		*/
   		public void setParentName (String parentName) {
   			this.parentName = parentName;
   		}
   		
   		/**
   		*@return String
   		*/
   		public String getParentName () {
   			return parentName;
   		}
   		
   		/**
   		*@param String
   		*/
   		public void setParentId (String parentId) {
   			this.parentId = parentId;
   		}
   		
		/**
		*@return String
		*/   		
		public String getParentId () {
   			return parentId;
   		}
   		
   		/**
   		*@param String
   		*/
   		public void setName (String Name) {
   			this.name = Name;
   		}
   		
   		/**
   		*@return String
   		*/
   		public String getName () {
   			return name;
   		}
   		
   		public void setId (String Id) {
   			this.id = Id;
   		}
   		
   		/**
   		*@return String
   		*/
   		public String getId () {
   			return id;
   		}
   		
   		/**
   		*@param String
   		*/
   		public void setLastModifiedBy (String modById) {
   			User modBy = [select Name from User where id=:modById];
   			this.lastModifiedBy = modBy.Name;
   		}
   		
   		/**
   		*@return String
   		*/
   		public String getLastModifiedBy () {
   			return lastModifiedBy;
   		}
   		
   		/**
   		*@param String
   		*/
   		public void setLastModifiedById (String modById) {
   			this.lastModifiedById = modById;
   		}
   		
   		/**
   		*@return String
   		*/
   		public String getLastModifiedById () {
   			return lastModifiedById;
   		}
   		   		
   		/**
   		*@param Datetime
   		*/
   		public void setLastModifiedDate (DateTime dateMod) {
   			this.lastModifiedDate = dateMod.format();
   		}
   		
   		/**
   		*@return String
   		*/
   		public String getLastModifiedDate () {
   			return LastModifiedDate;
   		}
   		
   		/**
   		*@param String
   		*/
   		public void setShortDescription (String shortDescription) {
   			this.shortDescription = shortDescription;
   		}
   		
   		/**
   		*@return String
   		*/
   		public String getShortDescription () {
   			return shortDescription;
   		}   		
   	}	
   	
   	/** FIX
   	*@return List<Wiki>
   	*/
   	public List<Wiki> getRecentlyUpdated () {
   		List<Wiki> wikis = new List<Wiki>();
   		for (WikiPage__c item: [ SELECT Wiki__r.Name, Id, Name, ShortDescription__c, LastModifiedById, LastModifiedDate FROM WikiPage__c WHERE Wiki__c =: TEAMID ORDER BY LastModifiedDate desc limit 10]) {
   			Wiki wiki = new Wiki();
   			wiki.setId(item.Id);
   			wiki.setName(item.Name);
   			wiki.setLastModifiedBy(item.LastModifiedById);
   			wiki.setLastModifiedById(item.LastModifiedById);
   			wiki.setLastModifiedDate(item.LastModifiedDate);
   			wiki.setParentName(item.Wiki__r.Name);
   			wiki.setParentId(item.Wiki__r.Id);
   			wiki.setShortDescription(item.ShortDescription__c);
   			wikis.add(wiki);
   		}
   		this.pagesUpdates = ( wikis.size() > 0 );
   		return wikis;
   	}
   	
   	

   	/** FIX
   	*@return List<FavoriteWikis__c>
   	*/
   	public List<FavoriteWikis__c> getFavorite () {
   		return	[ SELECT WikiPage__r.Wiki__r.Id, WikiPage__r.Wiki__r.Name, WikiPage__r.Name, WikiPage__r.Id FROM FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() order by WikiPage__r.Name LIMIT 5];
   	} 
   	
   	   	
   	
   	/**
   	*@return Integer
   	*/
   	public Integer getCntFav () {
   		return [select count() from FavoriteWikis__c where User__c = :UserInfo.getUserId()];
   	} 

	/** FIX 	
	*@return List<Wiki>
	*/
   	public List<Wiki> getMyRecentChanges () {
   		List<Wiki> wikis = new List<Wiki>();
   		for (WikiPage__c item: [ SELECT Wiki__r.Id , Wiki__r.Name, Id, Name, ShortDescription__c, LastModifiedById, LastModifiedDate FROM WikiPage__c WHERE LastModifiedById =:UserInfo.getUserId() ORDER BY LastModifiedDate desc limit 5]) {
   			Wiki wiki = new Wiki();
   			wiki.setId(item.Id);
   			wiki.setName(item.Name);
   			wiki.setLastModifiedBy(item.LastModifiedById);
   			wiki.setLastModifiedDate(item.LastModifiedDate);
   			wiki.setParentName(item.Wiki__r.Name);
   			wiki.setParentId(item.Wiki__r.Id);
   			wiki.setShortDescription(item.ShortDescription__c);
   			wikis.add(wiki);
   		}
   		return wikis;
   	}
   
   	
   	/**
   	*@return Integer
   	*/
   	public Integer getCntMyRecentChanges () {
   		return [ SELECT count() FROM WikiPage__c WHERE LastModifiedById =:UserInfo.getUserId()];
   	}
 
}