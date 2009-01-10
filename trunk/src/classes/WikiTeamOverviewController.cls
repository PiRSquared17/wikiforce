/**
*@author Gabriel Rilo @ 01/06/2009
*/
public with sharing class WikiTeamOverviewController {
	
	// Wiki__c given in the url
	public String TEAMID = System.currentPageReference().getParameters().get('tid');

	/**
	* Costructor
	*/
	public WikiTeamOverviewController () {
		genContructor();
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
			if(!userPermissionsTeam.getCanView()) 
				throw new CustomException('Insufficient Privileges');	
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
		userPermissions.setPermissions();		
	}
	
	/**  
	*@return UserPermissions
	*/
	public UserPermissions getUserPermissions () {
		return userPermissions;
	}
	
	
	public UserPermissions userPermissionsTeam = new UserPermissions();
		
	/** FIX
	* Read user permission for Team obj
	*/
	public void genPermissionsTeam () {
		userPermissionsTeam.setId(UserInfo.getUserId());
		userPermissionsTeam.setTeam(TEAMID);
		userPermissionsTeam.setObjectType('Team');
		userPermissionsTeam.setPermissions();		
	}
	
	
	/** FIX
	*@return UserPermissions
	*/	
	public UserPermissions getUserPermissionsTeam () {
		return userPermissionsTeam;
	}
	
	
		
	Wiki__c currentTeam = new Wiki__c();
	
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
		if(TEAMID != null)
			currentTeam = [select Id, Name from Wiki__c where id =: TEAMID];
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
   		String modifiedByPicture;
   		
		/** FIX
		*@param String
		
		public void setModifiedByPicture (String modById) {
			String PictureId = '';
			
			List<PeopleProfile__c> itemProfile = new List<PeopleProfile__c>();
			itemProfile = [SELECT Picture__c FROM PeopleProfile__c WHERE User__c =:modById];
			if (itemProfile != null) {
				if (itemProfile.size() > 0) {
					PeopleProfile__c picture = new PeopleProfile__c();
					picture = itemProfile.get(0);
			        if(picture.Picture__c == '' || picture.Picture__c == null) {                	                                          	 
				     	PictureId = '';
					}else {
						PictureId = picture.Picture__c;
					} 
				}else {
					PictureId = '';
				}
			}
   			this.modifiedByPicture = PictureId ;
   		}
   		*/
   		
   		
   		/**
   		*@return String
   		*/
   		public String getModifiedByPicture () {
   			return modifiedByPicture;
   		}
   		
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
   			//wiki.setModifiedByPicture(item.LastModifiedById);
   			wiki.setLastModifiedDate(item.LastModifiedDate);
   			wiki.setParentName(item.Wiki__r.Name);
   			wiki.setParentId(item.Wiki__r.Id);
   			wiki.setShortDescription(item.ShortDescription__c);
   			wikis.add(wiki);
   		}
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