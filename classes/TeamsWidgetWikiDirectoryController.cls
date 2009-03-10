/**
*@author Gabriel Rilo @ 01/06/2009
*/
public with sharing class TeamsWidgetWikiDirectoryController {

 	List<Wikis> resultWikis = new List<Wikis>();
	
	/**
	* Constructor
	*/
	public TeamsWidgetWikiDirectoryController (){}	
	
	// Get Team Id Attribute 
	String teamId;
	
    /**
    *@param String
    */
	public void setTeamId(String tID) {
		if (teamId == null || teamId != tID) {
			teamId = tID;
			readWikis();	
			genPermissions();	
		}
	}
	
	/**
	*@return String
	*/
	public String getTeamId(){
		return teamId;
	}
	
	public Boolean sidebar = false;
	
	/**
	* Set Sidebar
	*@param Boolean
	*/
	public void setSidebar (Boolean b){
		sidebar = b;
	}
	
	/**
	* Get Sidebar
	*@return Boolean
	*/
	public Boolean getSidebar(){
		return sidebar;
	}		

	Integer wikiPagesCount;
    
	public UserPermissions userPermissions = new UserPermissions();

	/**
	* Read user psrmissions
	*/
	public void genPermissions () {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(teamId);
		userPermissions.setObjectType('Wiki');
		userPermissions.setPermissions();		
	}
	
	/**
	*@return UserPermissions
	*/
	public UserPermissions getUserPermissions () {
		return userPermissions;
	}

	/**
	* Class Wikis
	*/
	public class Wikis {
	
		WikiPage__c wikiPage;
		String name;
		String createdByName;
		
		/**
		* Constructor
		*@param WikiPage__c
		*/
		public Wikis (WikiPage__c wiki) {
			wikiPage = wiki;
		}
		
		/**
		*@return WikiPage__c
		*/
		public WikiPage__c getWikiPage () {
			return wikiPage;
		}
		
		/**
		*@return String
		*/
		public String getName () {
			String trunkName = wikiPage.Name;
			if(wikiPage.Name.length() > 17) {
				trunkName = wikiPage.Name.substring(0,17) + '..';
			}
			return trunkName; 
		}
		
		/**
		*@return String
		*/
		public String getCreatedByName () {
			String trunkCreatedByName = '';
			if (wikiPage.CreatedBy != null) {
				trunkCreatedByName = wikiPage.CreatedBy.Name;
				if(wikiPage.CreatedBy.Name.length() > 17) {
					trunkCreatedByName = wikiPage.CreatedBy.Name.substring(0,17) + '..';
				}
			}
			return trunkCreatedByName; 
		}
	}

    
    
    /**
    * Load wiki pages
    */
    public void readWikis() {
		List<WikiPage__c> wikis = new List<WikiPage__c>();
	   	
	   	wikis =  [select Wiki__c,
					 LastModifiedDate ,
					 Name, Id, 
					 CreatedBy.Name, 
					 CreatedBy.Id, 
					 CreatedById
					 from WikiPage__c  
					 where Wiki__c =: teamId and Parent__c = ''
					 order by Name ASC limit 100];
 		resultWikis.clear();
 		for (WikiPage__c item: wikis) {
 			Wikis itemWiki = new Wikis(item);
 			resultWikis.add(itemWiki);
 		}
 		setWikiPagesCount(wikis.size());
    }
    
    /**
    *@return List<Wikis>
    */
    public List<Wikis> getWikis(){
    	return resultWikis;
    } 
    
    /**
    *@return Integer
    */
    public Integer getWikiPagesCount(){
    	return wikiPagesCount;
    }
    
    /**
    *@param Integer
    */
    public void setWikiPagesCount(Integer count){
    	wikiPagesCount = count;
    }
    
    /**
    * For rerender use
    */
    public void refresh() {
    	readWikis();
    }
    	
}