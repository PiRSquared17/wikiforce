/**
*@author Yuri Alvarez @ 05/02/2008
*/
public with sharing class WikiOverviewController {
//public class WikiOverviewController {
	
	public String allTeams = 'false';
	List<Letters> letterFilter = new List<Letters>();
   	List<Wiki__c> teamList = new List<Wiki__c>();
   	Letters currentLetter = new Letters();
   	List<Wiki> wikis = new List<Wiki>();
   	String USERID = UserInfo.getUserId();
   	public WikiMemberController wmc = new WikiMemberController();
    public Boolean isLastMemberAdmin = false;
	public Boolean isTeamAdmin = false;
	
    /**
	* Costructor
	*/
	public WikiOverviewController () {
		genMyTeams();
		genWikiSites();
		setSiteCount();
		genCntPagination();
		genIsTeamAdmin();
		system.debug( 'debuging ...' );
	}
	
	/**
    *@return bool is last member admin
    */
    public Boolean getIsLastMemberAdmin (){
        return isLastMemberAdmin;
    }
	
	/**
    *@return bool is team admin
    */
    public Boolean getIsTeamAdmin (){
        return isTeamAdmin;
    }
	
	/**
    * sets the value of isTeamAdmin
    */
	public void setIsTeamAdmin (Boolean b){
		this.isTeamAdmin = b;
	}
	
	/**
    * generates the value of isTeamAdmin
    */
    public void genIsTeamAdmin (){
        List<User> teamAdmin = [Select Id, Profile.PermissionsModifyAllData From User where id =:USERID limit 1];
        setIsTeamAdmin(teamAdmin[0].Profile.PermissionsModifyAllData);
    }
	
	
	
	/**
	* Verify if profiles exist if not create them
	*/
	public void genProfiles(){
		Integer cnt;
		cnt = [select count() from WikiProfile__c where Name = 'Member Profile'];
		if(cnt == 0){
			WikiProfile__c wikiProfile = new WikiProfile__c();
			wikiProfile.Name = 'Member Profile';
			wikiProfile.PostWikiComments__c = true;
			wikiProfile.ManageWikis__c = false;
			wikiProfile.CreateWikiPages__c = true;
			insert wikiProfile;
		}
		cnt = [select count() from WikiProfile__c where Name = 'Public Profile'];
		if(cnt == 0){
			WikiProfile__c wikiProfile = new WikiProfile__c();
			wikiProfile.Name = 'Public Profile';
			wikiProfile.PostWikiComments__c = true;
			wikiProfile.ManageWikis__c = false;
			wikiProfile.CreateWikiPages__c = false;
			insert wikiProfile;
		}
		cnt = [select count() from WikiProfile__c where Name = 'Wiki Administrator'];
		if(cnt == 0){
			WikiProfile__c wikiProfile = new WikiProfile__c();
			wikiProfile.Name = 'Wiki Administrator';
			wikiProfile.PostWikiComments__c = true;
			wikiProfile.ManageWikis__c = true;
			wikiProfile.CreateWikiPages__c = true;
			insert wikiProfile;
		}
	}
	
	List<Id> tmp = new List<Id>();
	/**
	* Load my teams
	*/
	public void genMyTeams() {
		tmp = new List<Id>();
		for(WikiMember__c tm : [Select Wiki__c From WikiMember__c WHERE User__c =: USERID ] ) { 
			tmp.add(tm.Wiki__c);
		}
		System.debug('\n\n\tMy teams... ==> ' + tmp.size() + '\n\n');
	}
	
	/**
	* Returns my teams list id
	*@return List<Id>
	*/
	public List<Id> myTeams(){
		return tmp;
	}	
	
	public List<TeamWikis> wikiSites = new List<TeamWikis>();
	
	/**
	*@return List<TeamWikis>
	*/
	public List<TeamWikis> getWikiSites () {
		System.debug('\n\n\tThe wikiSites = ' + wikiSites.size() + '\n\n');
		return wikiSites;
	}
	/**
	* For rerender use
	*/
	public void refreshTab(){
		numSitesRows = 7;
   		currentPagination = 1;
   		firstRow = 0;
   		letter = '';
   		genMyTeams();
		genWikiSites();
		setSiteCount();
		genCntPagination();
	}
	
	/**
	* Load all wikis list (all and mine)
	*/
	public void genWikiSites () {
		List<Wiki__c> sites;
		List<WikiMember__c> listMembers;
		Map<String, String> mapMembers;
		
		if (System.currentPageReference().getParameters().get('allTeams') != null) 
    		allTeams = System.currentPageReference().getParameters().get('allTeams');
    	
    	if(allTeams == '') 
    		allTeams = 'false';
    	
    	if(allTeams == 'true'){
        	if(getIsTeamAdmin()) {
            	sites = [select Id, Name, Description__c, PictureId__c, PublicProfile__c, Type__c from Wiki__c order by Name];
        	}
        	else {
        		sites = [select Id, Name, Description__c, PictureId__c, PublicProfile__c, Type__c from Wiki__c where Id in: myTeams() or Type__c !='private' order by Name];
        	}
        }else{
        	sites = [select Id, Name, Description__c, PictureId__c, PublicProfile__c, Type__c from Wiki__c where Id in: myTeams() order by Name];
        }
        List<String> wikiIds = new List<String>();
    	for(Wiki__c s : sites){
    		wikiIds.add(s.Id);
    		System.debug(' DB ' + s.Name + ' ' + s.Type__c);
    	}
    	
    	listMembers = [select Id, Wiki__c from WikiMember__c where Wiki__c in: wikiIds and User__c =: USERID];
    	System.debug('\n\n listMembers.size()[' + listMembers.size() + ']');
    	System.debug('\n\n listMembers[' + listMembers + ']');
    	mapMembers = new Map<String, String>();
    	for(WikiMember__c m : listMembers){
    		mapMembers.put(m.Wiki__c, m.Id);
    	}
    	
    	List<User> teamAdmin = [Select Id, Profile.PermissionsModifyAllData From User where id =:USERID limit 1];
		
		Map<Id, String> wAdmin = this.getWikisAdmin();
		List<TeamWikis> teamWikiList = new List<TeamWikis>();
		for (Wiki__c item : sites) {
			System.debug('wikiName : ' + item.Name);
			System.debug('is member? ' + mapMembers.containsKey(item.Id));
			TeamWikis teamWikiItem = new TeamWikis();
			teamWikiItem.setIsPublic(item.PublicProfile__c != null);
			teamWikiItem.setIsMember(mapMembers.containsKey(item.Id));
			teamWikiItem.setId(item.Id);
			teamWikiItem.setName(item.Name);
			String nameProfileAdmin = 'Wiki Administrator';
			teamWikiItem.setIsAdmin(teamAdmin[0].Profile.PermissionsModifyAllData || nameProfileAdmin.equals(wAdmin.get(item.Id)));
			teamWikiItem.setDescription(item.Description__c);
			teamWikiItem.setPicture(item.PictureId__c);
			teamWikiItem.setStateWiki(item.Type__c);
			teamWikiList.add(teamWikiItem);
		}
		wikiSites.clear();
		wikiSites = teamWikiList;
	}
	
	/**
	* Join to wiki
	*/
	public void joinWiki(){
		isLastMemberAdmin = false;
		wmc.setWikiId(System.currentPageReference().getParameters().get('wid'));
		wmc.joinWiki();
	}
	
	/**
	* Unjoin to wiki
	*/
	public void unjoinWiki(){
		wmc.setWikiId(System.currentPageReference().getParameters().get('wid'));
        if(!wmc.isLastMemberAdmin()){
            wmc.unjoinWiki();
            isLastMemberAdmin = false;
        }else{
            isLastMemberAdmin = true;
        }
	}
	
	/**
	* Return a map with a grop of wikis id where the user is admin
	*@return Map with user memberships <wiki id, profile name>
	*/	
	private Map<Id, String> getWikisAdmin(){
		Map<Id, String> wikis = new Map<Id, String>();
		for(WikiMember__c m : [select Wiki__c, WikiProfile__r.Name from WikiMember__c where User__c =: USERID]){
			wikis.put(m.Wiki__c, m.WikiProfile__r.Name);
		}
		
		return wikis;
	}
	
   	public Integer cntLetterSites;

   	/**
   	* Returns sites count
   	*/
   	public void setSiteCount(){
   		if (System.currentPageReference().getParameters().get('allTeams') != null) 
   			allTeams = System.currentPageReference().getParameters().get('allTeams');
	   	if(allTeams == '' || allTeams == 'false' || allTeams == null ){
	   		cntLetterSites = [select count() from Wiki__c where Id in: myTeams() ];	   		
	   	}else{
	   		cntLetterSites = [select count() from Wiki__c where Id in: myTeams() or Type__c !='private'];
	   		//cntLetterSites = [select count() from Wiki__c];
	   	}
	   	System.debug('\n\n\tThe tcntLetterSites = ' + cntLetterSites + '\n\n');
   	}
   	
   	public Integer numSitesRows = 7;
   	public Integer cntPagination;
   	public Integer currentPagination = 1;
   	public Integer firstRow = 0;
   	
   	/**
   	* Set total num of pages
   	*/
   	public void genCntPagination () {
   		cntPagination = (cntLetterSites - (Math.mod(cntLetterSites, numSitesRows)))/ numSitesRows;	
   		if (Math.mod(cntLetterSites, numSitesRows) != 0 ) 
   			cntPagination++;
   	}
   	
   	/**
   	*@return num of sites
   	*/
   	public Integer getNumSitesRows () {
   		return numSitesRows;
   	}
   	
   	/**
   	*@return paginator first row
   	*/
   	public Integer getFirstRow () {
   		return firstRow;
   	}
   	
   	/**
   	* Move to next page
   	*/
   	public void nextPage () {
   		currentPagination++;
   		firstRow = firstRow + numSitesRows;	
   	}
   	
   	/**
   	* Move to previus page
   	*/
   	public void prevPage () {
   		currentPagination--;
   		firstRow = firstRow - numSitesRows;	
   	}
   	
   	/**
   	* Move to last page
   	*/
   	public void lastPage () {
   		currentPagination = cntPagination;
   		Integer lastPageElementsCnt = Math.mod(cntLetterSites, numSitesRows);
   		if (lastPageElementsCnt == 0){
   			lastPageElementsCnt = numSitesRows;
   		}
   		firstRow = cntLetterSites - lastPageElementsCnt;   		
   	}
   	
   	/**
   	* Move to first page
   	*/
   	public void firstPage () {
   		currentPagination = 1;
   		firstRow = 0;   		
   	}
   	
   	/**
   	*@return current page num
   	*/
   	public Integer getCurrentPagination () {
   		return currentPagination;
   	}
   	
   	/**
   	* Get total num of pages
   	*@return Integer
   	*/
   	public Integer getCntPagination () {
   		return cntPagination;
   	}


	public List<String> lettersList = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};	

	/**
	* Class Letters
	*/
	public class Letters {
		String letter;
		Boolean containSites;
		Integer cntSites;
		
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
		public void setContainSites (Integer cntSites) {
			if (cntSites == 0) {
				this.containSites = false;
			}else {
				this.containSites = true;
			}
		}
		
		/**
		*@return Boolean
		*/
		public Boolean getContainSites () {
			return containSites;
		}
		
		/**
		*@return Integer
		*/
		public Integer getCntSites () {
			return cntSites;
		}
		
		/**
		*@param Integer
		*/
		public void setCntSites (Integer cntSites) {
			this.cntSites = cntSites;
		}	
	}
	
	/**
	*@return list of letters for filter
	*/
	public List<Letters> getLetterFilter(){
		setLetterFilter();
		return  letterFilter;
	}
	   	
	/**
	* Set letter filer with matches
	*/
	public void setLetterFilter () {
   		letterFilter = new List<Letters>();
   		teamList = new List<Wiki__c>();
   		currentLetter = new Letters();
   		
   		if (System.currentPageReference().getParameters().get('allTeams') != null) 
    		allTeams = System.currentPageReference().getParameters().get('allTeams');

    	if(allTeams == '') 
    		allTeams = 'false';
    	
    	if(allTeams == 'true'){
    		if (getIsTeamAdmin()) {
    			teamList = [select Name from Wiki__c];
    		}
    		else {
    			teamList = [select Name from Wiki__c where Type__c != 'private' or Id in:myTeams()];
    		}
    	}else{
			teamList = [select Name from Wiki__c where Id in:  myTeams() ];
    	}

   		for (String item : lettersList) {
   			currentLetter = new Letters();
   			Integer cntSites = 0;
   			
   			for (Wiki__c teamItem: teamList) {
   				if (teamItem.Name.startsWith(item) || teamItem.Name.startsWith(item.toLowerCase())) 
   					cntSites++;
   			}
   			
   			currentLetter.setCntSites(cntSites);
   			currentLetter.setLetter(item);
   			currentLetter.setContainSites(cntSites);
   			letterFilter.add(currentLetter);
   		}	
	}
	
	/**
	* Class TeamWikis
	*/   	
   	public class TeamWikis  {
   		String id;
   		String name;
   		String description;
   		String picture;
   		Boolean isAdmin;
   		Boolean isPublic;
   		Boolean isMember;
   		String stateWiki;
   		
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
   		*@return Boolean
   		*/
   		public Boolean getIsAdmin(){
   			return isAdmin;
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
   			if(description != null){
    			 if(description.length() > 70){
    			 	this.description = description.substring(0,67) + '...';	
    			 	//Set full description for span title
    			 	fullDescription = description;
    			 }else{
    			 	this.description = description;
    			 }
        	}else{
    			this.description  = '';
    		}
   		}
   		
   		public String fullDescription {get; set;}
   		
		/**
		*@param String
		*/
		public void setPicture (String image) {
   			if(image != null) {	
	        	this.picture = image;
	        }else {
	        	this.picture = '';
	        }
   		}
   		
   		/**
   		*@param Boolean
   		*/
   		public void setIsAdmin(Boolean is){
   			isAdmin = is;
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
   		public Boolean getIsPublic(){
   			return this.isPublic;
   		}
   		
   		/**
   		*@param Boolean
   		*/
   		public void setIsMember(Boolean ism){
   			this.isMember = ism;
   		}
   		
   		/**
   		*@return Boolean
   		*/
   		public Boolean getIsMember(){
   			return this.isMember;
   		}
   		
        /**
        *@param String
        */   		
   		public void setStateWiki(String stateWiki) {
   			this.stateWiki = stateWiki;
   		}
        /**
        *@return String
        */
        public String getStateWiki() {
            return this.stateWiki;
        }
   	}
   	
   	public String letter = '';
   	
   	/**
   	*@param String
   	*/
   	public void setLetter (String letter) {
   		this.letter = letter;
   	}
   	
	/**
	* List filter
	*/
	public void filterSites () {
		List<Id> myTeamsList = myTeams();
		List<Wiki__c> sites;
		List<WikiMember__c> listMembers;
		Map<String, String> mapMembers;
		
		if (System.currentPageReference().getParameters().get('ltr') != null && System.currentPageReference().getParameters().get('ltr') != '') {
			letter = System.currentPageReference().getParameters().get('ltr');
		}
		
		if (letter == 'ALL' || letter == null || letter == '') {
			Integer allTeamCount;
			if (allTeams == 'true') {
				if(getIsTeamAdmin()) {
						sites = [select Id, Name, Description__c, PictureId__c, PublicProfile__c, Type__c from Wiki__c];
				}
				else {
					sites = [select Id, Name, Description__c, PictureId__c, PublicProfile__c, Type__c from Wiki__c where Type__c != 'private' or Id in:myTeamsList order by Name];
				}
			}else {
				sites = [select Id, Name, Description__c, PictureId__c, PublicProfile__c, Type__c from Wiki__c where id in:myTeamsList order by Name];
			}
			allTeamCount = sites.size();
			cntPagination = (allTeamCount - (Math.mod(allTeamCount, numSitesRows)))/ numSitesRows;
			if (Math.mod(allTeamCount, numSitesRows) != 0 ) {
   				cntPagination++;
   			}
		}else {
			Integer lrtTeamCount;
			if (allTeams == 'true') {
				if (getIsTeamAdmin()) {
					sites = [select Id, Name, Description__c, PictureId__c, PublicProfile__c, Type__c from Wiki__c where Name like :(letter + '%') order by Name];
				}
				else {
					sites = [select Id, Name, Description__c, PictureId__c, PublicProfile__c, Type__c from Wiki__c where Name like :(letter + '%') and (Type__c != 'private' or Id in:myTeamsList) order by Name];
				}
			}else {
				sites = [select Id, Name, Description__c, PictureId__c, PublicProfile__c, Type__c from Wiki__c where Name like :(letter + '%') and id in:myTeamsList order by Name];
			}
			
			lrtTeamCount = sites.size();
			cntPagination = (lrtTeamCount - (Math.mod(lrtTeamCount, numSitesRows)))/ numSitesRows;
			
			if (Math.mod(lrtTeamCount, numSitesRows) != 0 ) 
   				cntPagination++;
		}
		
		
    	List<String> wikiIds = new List<String>();
    	for(Wiki__c s : sites){
    		wikiIds.add(s.Id);
    	}
    	
    	listMembers = [select Id, Wiki__c from WikiMember__c where Wiki__c in: wikiIds and User__c =: USERID];
    	System.debug('\n\n listMembers.size()[' + listMembers.size() + ']');
    	System.debug('\n\n listMembers[' + listMembers + ']');
    	mapMembers = new Map<String, String>();
    	for(WikiMember__c m : listMembers){
    		mapMembers.put(m.Wiki__c, m.Id);
    	}
    	
		Map<Id, String> wAdmin = this.getWikisAdmin();
		List<TeamWikis> teamWikiList = new List<TeamWikis>();
		for (Wiki__c item : sites) {
			TeamWikis teamWikiItem = new TeamWikis();			
			teamWikiItem.setIsPublic(item.PublicProfile__c != null);
			teamWikiItem.setIsMember(mapMembers.containsKey(item.Id));
			teamWikiItem.setId(item.Id);
			teamWikiItem.setName(item.Name);
			String nameProfileAdmin = 'Wiki Administrator';
			teamWikiItem.setIsAdmin(getIsTeamAdmin() || nameProfileAdmin.equals(wAdmin.get(item.Id)));
			teamWikiItem.setDescription(item.Description__c);
			teamWikiItem.setPicture(item.PictureId__c);
			teamWikiItem.setStateWiki(item.Type__c);
			teamWikiList.add(teamWikiItem);
		}
		
		currentPagination = 1;
		firstRow = 0;
		wikiSites = teamWikiList;
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
   		
   		/**
   		*@param String
   		*/
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
   			User modBy = [select Name from User where id=: modById];
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
   	
   	/**
   	*@return List<Wiki>
   	*/
   	public List<Wiki> getRecentlyUpdated () {
   		setRecentlyUpdated();
		return wikis;
   	}
   	
   	/**
   	* Load recently updated
   	*/
   	public void setRecentlyUpdated () {
   		wikis = new List<Wiki>();
   		List<WikiPage__c> wikiPages = new List<WikiPage__c>();
   		
   		if (System.currentPageReference().getParameters().get('allTeams') != null) 
    		allTeams = System.currentPageReference().getParameters().get('allTeams');
   		
    	if(allTeams == '') 
    		allTeams = 'false';
    		
    	if(allTeams == 'true'){
	   		wikiPages = [ SELECT Wiki__r.Name, Id, Name, ShortDescription__c, LastModifiedById, LastModifiedDate FROM WikiPage__c ORDER BY LastModifiedDate desc limit 10];    	
    	}else{
			wikiPages  = [ SELECT Wiki__r.Name, Id, Name, ShortDescription__c, LastModifiedById, LastModifiedDate FROM WikiPage__c where Wiki__c in:  myTeams() order by LastModifiedDate desc limit 10];
    	}
    	
   		for (WikiPage__c item: wikiPages) {
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
   	}
   	
   	public Boolean getrecentlyUpdatedIsEmpty(){
   		return wikis.size()<=0;
   	}
   	


	/**
	*@return List<FavoriteWikis__c> 
	*/
   	public List<FavoriteWikis__c> getFavorite () {
   		return	[select WikiPage__c from FavoriteWikis__c where User__c = :UserInfo.getUserId() limit 5];
   	}    	
   	
   	/**
   	*@return Integer
   	*/
   	public Integer getCntFav () {
   		return [select count() from FavoriteWikis__c where User__c = :UserInfo.getUserId()];
   	} 
  	
   	/**
   	*@return List<Wiki>
   	*/
   	public List<Wiki> getMyRecentChanges () {
   		List<Wiki> wikis = new List<Wiki>();
   		for (WikiPage__c item: [ SELECT Id, Name, ShortDescription__c, LastModifiedById, LastModifiedDate FROM WikiPage__c WHERE LastModifiedById =: UserInfo.getUserId() ORDER BY LastModifiedDate desc limit 5]) {
   			Wiki wiki = new Wiki();
   			wiki.setId(item.Id);
   			wiki.setName(item.Name);
   			wiki.setLastModifiedBy(item.LastModifiedById);
   			wiki.setLastModifiedDate(item.LastModifiedDate);
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