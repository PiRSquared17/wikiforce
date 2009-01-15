public class WikiCreateWikiController {
   /**
    * Constructor
    */
    public WikiCreateWikiController(){
        if (param != null){
        	setWiki(param);
        	genPermissions();
        	
        	if(!userPermissions.getCanManage())
        		throw new CustomException('Insufficient Privileges');
        }
    }
    
   //Flag to determine if the Members tab will be available.
    Boolean hasMembers = false;
   
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

    
    //Get id from team item
    String param = System.currentPageReference().getParameters().get('id');
    
    // max picture size bytes
    public final Integer MAX_SIZE = 524288;
    
    Wiki__c theWiki = new Wiki__c();
    String wikiPicture = '';
    Boolean validSizePicture = true;
   
   
    public Attachment document = new Attachment();
	
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
    
    public Boolean getValidSizePicture(){
    	return validSizePicture;
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
    * Class teamProfile
    */
    public class wikiProfile {
    	public String publicProfileOpen { set; get; }
    	public String newProfileOpen { set; get; }
    	public String publicProfileClosed { set; get; }
    	public String wikiOpenOrClosed { set; get; }     	
    }
    
    wikiProfile newProfile = new wikiProfile();
    
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
    		System.debug('LEN:' + document.BodyLength);
    		if(document.BodyLength <= MAX_SIZE || (document.name == null || document.name == '')){
    			validSizePicture = true;
	    		if(newProfile.wikiOpenOrClosed == 'open'){
	    			theWiki.PublicProfile__c = newProfile.publicProfileOpen;
	    			theWiki.NewMemberProfile__c = newProfile.newProfileOpen;	    			
	    		}else if (newProfile.wikiOpenOrClosed == 'close') {
	    			theWiki.PublicProfile__c = newProfile.publicProfileClosed;
	    			theWiki.NewMemberProfile__c = null;
	    		}else if (newProfile.wikiOpenOrClosed == 'private'){
	    			theWiki.PublicProfile__c = null;
	    			theWiki.NewMemberProfile__c = null;
	    		}
	    		
	    		
	    		if(theWiki.Id == null){
		    		insert theWiki;
		    		if(document.name != null && document.name != ''){
			    			document.ParentId = theWiki.Id;
				    		insert document;
			    			theWiki.PictureId__c = document.Id;
				    		update theWiki;	
		    		}	
	    		}else {
	       			if(document.name != null && document.name != ''){
		    			document.ParentId = theWiki.Id;
		    			insert document;
		    			theWiki.PictureId__c = document.Id;
		    		}
		    		if(theWiki.Type__c == null){
		    			theWiki.Type__c = WikiType; 
		    		}
		    		update theWiki;
		    	}
		       	PageReference pageRef = new PageReference('/apex/WikiTeamOverview?tid=' + theWiki.Id);
	            pageRef.setRedirect(true);
	            return pageRef; 
    		}
    		else{
    			validSizePicture=false;
    			document = new Attachment();
    			return null;
    		}
    	}catch(Exception e){
    		throw e;
    	}
    }
    
  	public PageReference saveWikiAndAddMembers(){
  		    	try{
    		System.debug('LEN:' + document.BodyLength);
    		if(document.BodyLength <= MAX_SIZE || (document.name == null || document.name == '')){
    			validSizePicture = true;
	    		if(newProfile.wikiOpenOrClosed == 'open'){
	    			theWiki.PublicProfile__c = newProfile.publicProfileOpen;
	    			theWiki.NewMemberProfile__c = newProfile.newProfileOpen;	    			
	    		}else if (newProfile.wikiOpenOrClosed == 'close') {
	    			theWiki.PublicProfile__c = newProfile.publicProfileClosed;
	    			theWiki.NewMemberProfile__c = null;
	    		}else if (newProfile.wikiOpenOrClosed == 'private'){
	    			theWiki.PublicProfile__c = null;
	    			theWiki.NewMemberProfile__c = null;
	    		}
	    		
	    		
	    		if(theWiki.Id == null){
		    		insert theWiki;
		    		if(document.name != null && document.name != ''){
			    			document.ParentId = theWiki.Id;
				    		insert document;
			    			theWiki.PictureId__c = document.Id;
				    		update theWiki;	
		    		}	
	    		}else {
	       			if(document.name != null && document.name != ''){
		    			document.ParentId = theWiki.Id;
		    			insert document;
		    			theWiki.PictureId__c = document.Id;
		    		}
		    		if(theWiki.Type__c == null){
		    			theWiki.Type__c = WikiType; 
		    		}
		    		update theWiki;
		    	}
		    	PageReference pageRef = new PageReference('/apex/WikiMembersList?id=' + theWiki.Id);
			    pageRef.setRedirect(true);
			    return pageRef; 
    		}
    		else{
    			validSizePicture=false;
    			document = new Attachment();
    			return null;
    		}
    	}catch(Exception e){
    		throw e;
    	}
  	}
  	
}