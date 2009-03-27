/**
*@author Juan Bessonart @ 07/07/2008
*/
public class WikiPageLinksController {
	
    public String idWikiPage = System.currentPageReference().getParameters().get('idWP');
    public String teamId = '';
    
	/**
	* Costructor
	*/
	public WikiPageLinksController () {
		genTeamId();
	} 	
 	
 	/**
 	* Read Team for wiki page
 	*/
    public void genTeamId () {
   		teamId = [select id, Wiki__c from WikiPage__c where id=: idWikiPage].Wiki__c;
    }
    
    /**
    *@param String
    */
    public void setIdWikiPage (String idWikiPage) {
    	this.idWikiPage = idWikiPage;	
    }

	/**
	* Class AttachmentInfo
	*/ 	 
	public class AttachmentInfo {
        
        String name;
        String attachImage;
		String id;
        
        /**
        *@return String
        */
        public String getId () {
        	return id;
        }
        
        /**
        *@param String
        */
        public void setId (String id) {
        	this.id = id;
        }
        
        /**
        *@return String
        */
        public String getName() {
        	return name;
        }

        /**
        *@param String
        */
        public void setName(String name) {
                this.name = name;
        }  
        
        /**
        *@return String
        */
        public String getAttachImage() {
                return attachImage;
        }                                
	}
	
    /**
    *@return List<AttachmentInfo>
    */
    public List<AttachmentInfo> getAttachments() {
    	List<Attachment> Attachments = new List<Attachment>();
    	if (idWikiPage == '{!idWikiPage}') {
    		Attachments = [select name, id, parentid, ContentType from attachment order by name];
    	}else {
    		Attachments = [select name, id, parentid, ContentType from attachment where parentid=:idWikiPage order by name];
    	}
    	
		List<AttachmentInfo> infos = new List<AttachmentInfo>();

		for (Attachment item: Attachments){	
            AttachmentInfo info = new AttachmentInfo();
            info.setId(item.Id);
            info.setName(item.Name);
            infos.add(info);
        }	
		return infos;   	    									
    }     
    
    /**
    *@return Integer
    */
    public Integer getCntAttachments () {
    	return [select count() from attachment where parentid=:idWikiPage];
    }
    
	/**
	*@return List<WikiPage__c>
	*/
   	public List<WikiPage__c> getWikiPagesTeam () {
   		List<WikiPage__c> wikis = new List<WikiPage__c>();
   		wikis = [select id, Name, Wiki__r.Name from WikiPage__c where Wiki__c =: teamId and Parent__c !=:idWikiPage  and id !=: idWikiPage order by Name];
   		return wikis;
   	}
   	 
   	/**
   	*@return Integer
   	*/
   	public Integer getCntTeamWikis () {
   		return [SELECT count() FROM WikiPage__c WHERE Wiki__c =: teamId and Parent__c !=:idWikiPage and id !=: idWikiPage]; 
   	}
	
   	/**
   	*@return List<WikiPage__c>
   	*/
   	public List<WikiPage__c> getWikiPagesAll () {
   		List<WikiPage__c> wikis = new List<WikiPage__c>();
   		wikis = [select id, Name, Wiki__r.Name from WikiPage__c where Wiki__c !=: teamId and Wiki__c != null order by Name];
   		return wikis;
   	}
   	
   	/**
   	*@return Integer
   	*/
   	public Integer getCntAllWikis () {
   		return [SELECT count() FROM WikiPage__c WHERE Wiki__c !=: teamId and Wiki__c != null]; 
   	}
   	 
 	/**
 	*@return List<WikiPage__c>
 	*/
 	public List<WikiPage__c> getWikiChilds () {
   		List<WikiPage__c> childs = new List<WikiPage__c>();
	   	childs = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c FROM WikiPage__c WHERE Parent__c = :idWikiPage order by Name];
		return childs;
   	}  
   	
   	/**
   	*@return Integer
   	*/
   	public Integer getCntWikiChilds () {
   		return [SELECT count() FROM WikiPage__c WHERE Parent__c = :idWikiPage]; 
   	}
}