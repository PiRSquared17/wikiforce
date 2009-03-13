/**
*@author Yuri Alvarez @ 05/02/2008
*/
public class WikiPageController {

	public String idWikiSite = '';
	
	public String idWikiPage = '';
	public String wikiPageName = '';
	public String wikiPageShortDescription = '';
	WikiPage__c	wikiPageBody;
	public List<WikiPage__c> results;
	public String theParent = '';
	public String parent = ''; 
	public Integer first = 0;
	public Integer maxView = 5;	  

   	public Info infoWP = new Info();
		
	public String linkpart1 = 'switchOverlay(true);;A4J.AJAX.Submit(\'_viewRoot\',\'WikiPage:auxForm\',event,{\'parameters\':{\'WikiPage:auxForm:auxLink\':\'WikiPage:auxForm:auxLink\',\'idWP2\':\'';
	public String linkpart2 = '\'} ,\'actionUrl\':\'/apex/WikiPage?javax.portlet.faces.DirectLink=true\',\'oncomplete\':function(request,event,data){switchOverlay(false);}} );return false;\" name=\"WikiPage:auxForm:auxLink\" id=\"WikiPage:auxForm:auxLink\" href=\"#\">';

	public String paramIdWP = System.currentPageReference().getParameters().get('idWP');
	
	public Boolean currentUsCanManage = false;
	public Boolean currentUsIsOwner = false;
	/**
	* Costructor
	*/
	public WikiPageController () {
		contructMethods();
		// Evaluatin "can manage" and "owner"
		currentUsIsOwner = infoWP.getCreatedById() == UserInfo.getUserId() ;
		currentUsCanManage = userPermissions.getCanManage();
	}
	
	/**
	*@return bool is instance owner
	*/
	public Boolean getCurrentUsIsOwner(){
		return currentUsIsOwner;
	}
		
	/**
	*@param String
	*/
	public void setParamIdWP (String paramIdWP){
		this.paramIdWP = paramIdWP;
	}
	
	/**
	*@param String
	*/
	public void setIdWikiPage (String idWikiPage) {
		this.idWikiPage = idWikiPage;
	}
	
	
	/**
	*@param String
	*/
	public void setWikiPageName (String wikiPageName) {
		this.wikiPageName = wikiPageName;
	}
	
	/**
	*@return String
	*/
	public String getWikiPageName () {
		String trunkName;
		if (wikiPageName.length() > 25) {
			trunkName = wikiPageName.substring(0,23) + '..';
		}
		else {
			trunkName = wikiPageName;
		}
		return '<strong>' + trunkName + '</strong>';	
	}

	/**
	*@param String Wiki Page short description property
	*/
	public void setWikiPageshortDescription( String shortDescription )
	{
		wikiPageShortDescription = shortDescription;
	}
	
	/**
	*@return String Wiki Page short description property
	*/
	public String getWikiPageshortDescription()
	{
		return wikiPageShortDescription;
	}
	
			
	public List<WikiPage__c> wikiPageBodyList = new List<WikiPage__c>();
	
	/**
	* Gets the first wikipage whose id is paramIdWp, stores its name and id,
	* parses the page and generates the relates information.
	*@throws CustomException
	*/
	public void contructMethods () {
		if(paramIdWP != null) {
			wikiPageBodyList = [SELECT Id, 
									   Name, 
									   ShortDescription__c, 
									   Body__c, 
									   Parent__c, 
									   LastModifiedDate,
									   PageCreatedBy__c,
									   Wiki__c,
									   Wiki__r.Name,
									   Wiki__r.Id 
							    From WikiPage__c WHERE id =:paramIdWP];
			if (wikiPageBodyList.size() > 0) {
				wikiPageBody = wikiPageBodyList[0];
			}
			else {
				throw new CustomException('Insufficient Privileges');	
			}
			
			wikiPageName = wikiPageBody.Name;
			idWikiPage = paramIdWP; // no reason for this var...clean it up!
			
			idWikiSite = wikiPageBody.Wiki__r.Id;
			
			parseHTML();
			infoGen();
			
			genPermissions(wikiPageBody.PageCreatedBy__c);
			
		}
	}
	
	
	/* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = new UserPermissions();
	
	/**
	* Generates the user permissions
	*@param Id
	*/
	public void genPermissions (Id OwnerId) {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(idWikiSite);
		userPermissions.setOwnerId(OwnerId);
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
	*@param String
	*/
	public void setIdWikiSite (String idWikiSite) {
		this.idWikiSite = idWikiSite;
	}
	
	/**
	*@return String
	*/
	public String getWikiHome () {
		return [select Id from WikiPage__c where Wiki__c =:idWikiSite limit 1].Id;
	}
	
	/**
	*@return String
	*/
	public String getWikiSiteName () {
		String teamName = '';
		if (idWikiSite != null) {
			Wiki__c teamNameResult = [select id, Name from Wiki__c where id=:idWikiSite];
			Schema.DescribeSObjectResult dsor = Wiki__c.sObjectType.getDescribe();
			if (teamNameResult != null) {
				teamName = '<a href="/apex/WikiOverview?save_new=1">' + dsor.labelPlural + '</a> > <a href="/apex/WikiTeamOverview?tid=' + teamNameResult.Id + '">' + teamNameResult.name + '</a> > ';	
			}
		}
		return teamName;
	}
	
	/**
	*@return String
	*/
	public String getidWikiPage () {
		return idWikiPage;
	}
	
  	/* ---------------------------- */
   	/*   	 SHOW WIKI PAGES		*/
   	/* ---------------------------- */	

	/**
	*@return WikiPage__c
	*/
	public WikiPage__c getWikiBody () {
		return wikiPageBody;	
	}

	
	/**
	* Gets the wiki page and stores it in wikiPageBody
	*/
    public void getWiki() {
    	
    	WikiPage__c wiki;
    	
    	if (System.currentPageReference().getParameters().get('idWP2') == '' || System.currentPageReference().getParameters().get('idWP2') == null || System.currentPageReference().getParameters().get('idWP2') == '0') {
    		idWikiPage = getWikiHome();
    	}
    	else {
    		idWikiPage = System.currentPageReference().getParameters().get('idWP2');
    	}
    	  	
    	wiki = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];
		
		Integer cntTempView = [select count() from WikiRecentlyViewed__c where User__c =:UserInfo.getUserId() AND WikiPage__c =:idWikiPage];
		if (cntTempView == 0 ) {
    		WikiRecentlyViewed__c wikiView = new WikiRecentlyViewed__c();
    		wikiView.User__c = UserInfo.getUserId();
    		wikiView.WikiPage__c = idWikiPage;
    		wikiView.Name = wiki.Name;
    		insert wikiView;
    		
    		Integer totalCnt = getCntViews(); 
			if ( totalCnt > maxView) {
				Integer delNum = totalCnt - maxView; 
				List<WikiRecentlyViewed__c> delView = [SELECT Id, Name FROM WikiRecentlyViewed__c WHERE User__c = :UserInfo.getUserId() ORDER BY LastModifiedDate limit :delNum];
				delete delView;	
			}
		}
		else {
			WikiRecentlyViewed__c tempView;
			tempView = [select User__c, WikiPage__c from WikiRecentlyViewed__c where User__c =:UserInfo.getUserId() AND WikiPage__c =:idWikiPage limit 1];
			update tempView;
		}
     	
    	wikiPageBody = wiki;
    	
    }
	
   	/* ---------------------------- */
   	/*   	  PARSE WIKI PAGE		*/
   	/* ---------------------------- */	 
 	public String html = null;
 	
 	/**
	* Parses the wikipage and stores its HTML code in the html attribute
	*/
 	public void parseHTML() {
		WikiPage__c wikiHTML = new WikiPage__c();
    	
    	
    	if (idWikiPage != null && idWikiPage != '') {
    		wikiHTML = [SELECT Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];		
    	}
 		
  		html = wikiHTML.Body__c;
 		ParseHtml ph =new ParseHtml();
 		ph.setHtml(html);
 		ph.setIdWikiPage(idWikiPage);
 		
 		ph.parseHtml();
 		html=ph.html;
 	}   
 	
 	/**
	*@return String
	*/
 	public String getHtml () {
 		return html;	
 	}
 	
 	/**
	*@return String
	*/
 	public String getHtml2 () {
 		String html2;
 		html2 = html;
 		html2 = html2.replaceAll('&nbsp;','  ');
 		html2 = html2.replaceAll('<br>','\n');
 		html2 = html2.replaceAll('\"','"');
		html = html.replaceAll('&gt;','>');
		html = html.replaceAll('&lt;','<');
 		return html2;	
 	}


   	/* ---------------------------- */
   	/*   CHILDREN OF A WIKI PAGE	*/
   	/* ---------------------------- */
   
	/**
	*@return List<WikiPage__c>
	*/   
   	public List<WikiPage__c> getChilds () {
   		
   		List<WikiPage__c> childs = new List<WikiPage__c>();
	   	childs = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c FROM WikiPage__c WHERE Parent__c = :idWikiPage order by Name];
	
   		return childs;
   	} 
   	 	
   	/**
	*@return Integer
	*/   	
   	public Integer getChildsCount () {
   		Integer count;
		count = [select count() from WikiPage__c where Parent__c = :idWikiPage];
   		return count;
   	}   	

   	/* ---------------------------- */
   	/*   	 EDIT WIKI PAGE			*/
   	/* ---------------------------- */
   	
	public WikiPage__c editWP;
	WikiVersions__c editWV;
	
	
   	/* ---------------------------- */
   	/*   	   NEW WIKI PAGE		*/
   	/* ---------------------------- */	
	WikiPage__c newWP = new WikiPage__c();
	WikiVersions__c newWV = new WikiVersions__c();
	
	public Boolean newPage = false;
	
	/**
	*@return Boolean
	*/  
	public Boolean getNewPage () {
		return this.newPage;
	}
	 
	/**
	* Sets the newPage status to false
	*/ 
	public void cancelNew () {
		newPage = false;
	}
	
	/**
	* Sets the newPage status to true
	*/ 
	public void newWiki () {
		newPage = true;
		newWP = null;	
		newWV = null;
	}

	/**
	*@param WikiPage__c
	*/  
	public void setnewWP (WikiPage__c newWP) {
		this.newWP = newWP;
	}

	/**
	*@param WikiVersions__c
	*/ 
	public void setnewWV (WikiVersions__c newWV) {
		this.newWV = newWV;
	}		
	
	/**
	* Saves the new wiki page and sets ints newPage status to false.
	*/ 
	public void SaveNew () {
		TeamUtil.hostName = TeamUtil.getHost(ApexPages.currentPage());
		System.debug( ')))>' + TeamUtil.hostName );
		newWP.Parent__c = idWikiPage;
		newWP.Wiki__c = idWikiSite; 
		newWP.Body__c = '=== Congratulations! === \n You created a new wiki page for your team. Begin by clicking the "Edit" button above to modify this page.';
		insert newWP;	
		newWV = new WikiVersions__c();
		newWV.revisionCount__c = 1;
		newWV.WikiPageId__c = newWP.Id;
		newWV.Name = newWP.Name;
		newWV.Body__c = '=== Congratulations! === \n You created a new wiki page for your team. Begin by clicking the "Edit" button above to modify this page.';
		insert newWV;
		
		newPage = false;	
	}   	
	
	/**
	* Update Name and shortDescription__c fields for cuurrent Wiki Page
	*/
	public void updateWikiInfo(){
	
				
		if( currentUsCanManage || currentUsIsOwner )
		{
			WikiPage__c currentWP = new WikiPage__c();
			Info currentInfo = new Info();
			
			currentInfo = getInfoWiki();
					
			currentWP = [ SELECT Name, ShortDescription__c FROM wikiPage__c WHERE Id =: paramIdWP ];
			currentWP.Name = currentInfo.Name;
			currentWP.ShortDescription__c = currentInfo.ShortDescription; 
			
			update currentWP;
			
			redirectToThis();
		}
		else
			throw new CustomException( 'Insufient privilegies' );
				
	}

	public PageReference redirectToThis()
	{
		PageReference pg = new PageReference('/apex/WikiPage?idWP=' + paramIdWP);
		pg.setRedirect(true);
		
		return pg; 
		
	}
	
	/**
	*@return WikiPage__c
	*/
	public WikiPage__c getnewWP () {
		if (newWP == null) {
			newWP = new WikiPage__c();
		}		
		return newWP;	
	}    	   	

	/**
	*@return WikiVersions__c
	*/
	public WikiVersions__c getnewWV () {
		if (newWV == null) {
			newWV = new WikiVersions__c();
		}		
		return newWV;	
	}
	
   	
	/**
	* Class Info
	*/
	public class Info {
        
        String name;
        String createdBy;
        String createdById;
        String createdDate;
        String lastModifiedBy;
        String lastModifiedDate;
        String shortDescription;
        String lastModifiedById;
        
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
                if (name.length() > 60) {
	            	this.name = name.substring(0,58) + '..';
	            }
	            else {
	            	this.name = name;
	            }
        }  
        
        /**
        *@return String
        */
        public String getShortDescription() {
                return shortDescription;
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
        public String getCreatedBy() {
                return createdBy;
        }

		/**
        *@param Id
        */
        public void setCreatedBy(Id id) {
                User user;
                user = [select Name from User where id = :id];
                this.createdBy = user.Name;
        }  
        
        /**
        *@return String
        */
        public String getCreatedById() {
                return createdById;
        }

		/**
        *@param	Id
        */
        public void setCreatedById(Id id) {
                this.createdById = id;
        }
        
        /**
        *@return String
        */
        public String getLastModifiedBy() {
                return lastModifiedBy;
        }

		/**
        *@param Id
        */
        public void setLastModifiedBy (Id id) {
                User user;
                user = [select Name from User where id = :id];
                this.lastModifiedBy = user.Name;
        } 
        
        /**
        *@param Id
        */
        public void setLastModifiedById (Id id) {
        	this.lastModifiedById = id;	
        }	
		
		/**
        *@return String
        */
		public String getLastModifiedById () {
			return lastModifiedById;	
		}
		
		/**
        *@return String
        */
        public String getCreatedDate() {
                return createdDate;
        }

		/**
        *@param Datetime
        */
        public void setCreatedDate(Datetime createdDate) {
                this.createdDate = createdDate.format();
        } 
        
        /**
        *@return String
        */
        public String getLastModifiedDate() {
                return lastModifiedDate;
        }

		/**
        *@param Datetime
        */
        public void setLastModifiedDate(Datetime lastModifiedDate) {
                this.lastModifiedDate = lastModifiedDate.format();
        }                
                                        
	} // end of the class	
   	

    /**
    * Stores the wike page info in infoWP.
    */  	
   	public void infoGen () {
   		
   		WikiPage__c wiki;
		String idInfo = idWikiPage;	
    	if (idInfo == '0' || idInfo == null) {
    		wiki = [SELECT Name, ShortDescription__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate  From WikiPage__c WHERE Wiki__c =: idWikiSite  limit 1];	
    	}
    	else {
    		wiki = [SELECT Name, ShortDescription__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate From WikiPage__c WHERE id = : idInfo ];
    	}
		
		infoWP.setName(wiki.Name);
		infoWP.setCreatedBy(wiki.CreatedById);
		infoWP.setCreatedById(wiki.CreatedById);
		infoWP.setCreatedDate(wiki.CreatedDate);
		infoWP.setLastModifiedById(wiki.LastModifiedById);
		infoWP.setLastModifiedBy(wiki.LastModifiedById);
		infoWP.setLastModifiedDate(wiki.LastModifiedDate);
		infoWP.setShortDescription(wiki.ShortDescription__c);  
		
	}    		
   		
   	/**
	*@return Info
	*/
 	public Info getInfoWiki () {
 		return infoWP;
 	}


   	/* ---------------------------- */
   	/*   	  ATTACH WIKI PAGE		*/
   	/* ---------------------------- */	  	  
	
	public Attachment wikiAttach = new Attachment();
	
	/**
	*@param Attachment
	*/
	public void setWikiPage (Attachment attach) {
		this.wikiAttach = attach;
	}
	 
	/**
	*@return Attachment
	*/
	public Attachment getWikiAttach () {     
		return wikiAttach;
	}
	
	/**
	*@return PageReference
	*/
	public PageReference saveWikiAttach () {
		wikiAttach.ParentId = idWikiPage;
		insert wikiAttach;		
		PageReference pageRef = Page.WikiPage;
		pageRef.getParameters().put('idWP', idWikiPage);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/**
	* Class AttachmentInfo
	*/
	public class AttachmentInfo {
        
        String name;
        String attachImage;
		String id;
        String lastModifiedDate;
        String lastModifiedBy;
        String createdDate;
        String lastModifiedById;
        
        /**
        *@return String
        */
        public String getCreatedDate () {
        	return createdDate;
        }
        
        /**
        *@param String
        */
        public void setCreatedDate (String createdDate) {
        	this.createdDate = createdDate;
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
        public void setId (String id) {
        	this.id = id;
        }
        
        /**
        *@return String
        */
        public String getLastModifiedDate () {
        	return lastModifiedDate;
        }
        
        /**
        *@param String
        */
        public void setLastModifiedDate (String lastModifiedDate) {
        	this.lastModifiedDate = lastModifiedDate;
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

		/**
        *@param String
        */
        public void setAttachImage (String attachImage) {
                this.attachImage = attachImage;
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
        public void setLastModifiedBy (String lastModifiedBy) {
        	this.lastModifiedBy = lastModifiedBy;
        }
        
        /**
        *@return String
        */
        public String getLastModifiedById () {
        	return lastModifiedById;
        }
        
        /**
        *@param String
        */
        public void setLastModifiedById (String lastModifiedById) {
        	this.lastModifiedById = lastModifiedById;
        }
                                        
	}
	   
	/**
	*@return List<AttachmentInfo>
	*/
    public List<AttachmentInfo> getAttachments() {
    	
    	List<Attachment> Attachments = [select name, id, parentid, ContentType, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, CreatedDate from Attachment where parentid=:idWikiPage order by name];		
		List<AttachmentInfo> infos = new List<AttachmentInfo>();

		for (Attachment item: Attachments){	
            AttachmentInfo info = new AttachmentInfo();
            info.setId(item.Id);
            info.setName(item.Name);
            info.setCreatedDate(item.CreatedDate.format());
            info.setLastModifiedDate(item.LastModifiedDate.format());
            info.setLastModifiedBy(item.LastModifiedBy.Name);
            info.setLastModifiedById(item.LastModifiedBy.Id);
            
            String ContentType = item.ContentType;
            String image = '';
            
       		if (ContentType == null || ContentType == '') {
            	// Using extension
            	Integer extPos = item.Name.lastIndexOf('.') + 1;
            	String extension = item.Name.substring(extPos);
            	// containsKey does a case sensitive comparison
            	extension = extension.toLowerCase();
            	Map<String, String> typesExt = new Map<String, String>{
           			'png' => 'images.gif',
           			'jpg' => 'images.gif',
           			'gif' => 'images.gif', 
           			'rar' => 'rar.gif', 
           			'xls' => 'xls.gif', 
           			'ppt' => 'ppt.gif', 
           			'avi' => 'video.gif', 
           			'mpg' => 'video.gif', 
           			'mpeg' => 'video.gif', 
           			'flv' => 'video.gif', 
           			'mp3' => 'audio.gif', 
           			'doc' => 'doc.gif'
       			};
           		if(typesExt.containsKey(extension)) {
           			image = typesExt.get(extension);
           		}
           		else {
           			image = 'generic.gif';
           		}
            }
            else {
           		// Using mime type
           		Map<String, String> typesMime = new Map<String, String>{
           			'image/jpeg' => 'images.gif', 
           			'image/pjpeg' => 'images.gif', 
           			'image/png' => 'images.gif', 
           			'image/x-png' => 'images.gif', 
           			'image/gif' => 'images.gif', 
           			'image/bmp' => 'images.gif', 
           			'text/plain' => 'txt.gif', 
           			'application/pdf' => 'pdf.gif', 
           			'application/msword' => 'doc.gif', 
           			'application/x-zip-compressed' => 'zip.gif', 
           			'audio/wav' => 'audio.gif', 
           			'audio/mpeg' => 'audio.gif', 
           			'video/mpeg' => 'video.gif', 
           			'video/avi' => 'video.gif'
       			};	
           		if(typesMime.containsKey(ContentType)) {
           			image = typesMime.get(ContentType);
           		}
           		else {
           			image = 'generic.gif';
           		}
            }
            
            info.setAttachImage(image);
            infos.add(info);
        }	
		return infos;   	    									
    }     
    
    /**
	*@return Integer
	*/
    public Integer getAttachCount () {
    	return [select count() from attachment where parentid=:idWikiPage];
    }
    
    public void refreshAttachs () {
    	
    }

   	/* ---------------------------- */
   	/*   	  DELETE ATTACH			*/
   	/* ---------------------------- */  
   	
   	public void DeleteAttach () { 

		if( currentUsCanManage || currentUsIsOwner )
		{
	   		String idAttach = System.currentPageReference().getParameters().get('idAttach');
	   		Attachment delAttach;
	   		delAttach = [select Id, Name from Attachment where id =: idAttach ];
	   		delete delAttach; 
		}
		else
			throw new CustomException( 'Insufient privilegies' );
   	}
 
   	/* ---------------------------- */
   	/*   	  BREADCRUMBING			*/
   	/* ---------------------------- */ 
	  	
	/**
	*@return String
	*/
	public String getBreadCrumbing () {
	   	WikiPage__c wikiBC;
	   	String breadCrumbing = '';
	   	String parentBC = null;
		Integer crumbingLength = 1;
		Integer crumbingMaxLength = 2;
		
		if (idWikiPage == null) {
			idWikiPage = getWikiHome();
		}
   		wikiBC = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];
   		
   		parentBC = wikiBC.Parent__c;
	   	while (parentBC != null) {
	   		
	   		wikiBC = [select Name, Id, Parent__c from WikiPage__c where id =:parentBC];
	   		parentBC = wikiBC.Parent__c;
	   		
	   		String trunkName;
	   		if (wikiBC.Name.length() > 25) {
	   			trunkName = wikiBC.Name.substring(0,23) + '..';
	   		}
	   		else {
	   			trunkName = wikiBC.Name; 	
	   		}
	   		
	   		if (crumbingLength < crumbingMaxLength) {
	   			breadCrumbing = '<a href=\"/apex/WikiPage?idWP=' + wikiBC.Id + '\">' + trunkName + '</a> >'; 
	   		}
	   		else {
	   			if (parentBC == null) {
	   				breadCrumbing = '<a href=\"/apex/WikiPage?idWP=' + wikiBC.Id + '\">' + trunkName + '</a> >'; 
	   			}
	   			else {
	   				if (crumbingLength == crumbingMaxLength) {
	   					breadCrumbing = ' .. > ' + breadCrumbing;
	   				}
	   			}
	   		}
	   		crumbingLength++;
	   	} 
	   	return breadCrumbing;
	}
 
   	/* ---------------------------- */
   	/*   	OUTGOING / INCOMING		*/
   	/* ---------------------------- */  
   	
   	/**
	*@return List<WikiLink__c>
	*/
    public List<WikiLink__c> getOutgoing() {		
		return [select ToLink__r.ShortDescription__c, ToLink__r.Name, ToLink__r.Id from WikiLink__c where FromLink__c =:idWikiPage order by Name];   	    									
    }    	

	/**
	*@return Integer
	*/
    public Integer getCntOutgoing() {		
		return [select count() from WikiLink__c where FromLink__c =:idWikiPage];   	    									
    } 
       	
    /**
	*@return List<WikiLink__c>
	*/
    public List<WikiLink__c> getIncoming() {		
		return [select FromLink__r.ShortDescription__c, FromLink__r.Name, FromLink__r.Id from WikiLink__c where ToLink__c =:idWikiPage order by Name];   	    									
    }  

	/**
	*@return Integer
	*/
    public Integer getCntIncoming() {		
		return [select count() from WikiLink__c where ToLink__c =:idWikiPage];   	    									
    }
    
   	/* ---------------------------- */
   	/*   	RECENTLY UPDATED		*/
   	/* ---------------------------- */
   	
   	/**
	*@return List<WikiPage__c>
	*/
   	public List<WikiPage__c> getRecentlyUpdated () {
   		return	[ SELECT Id, Name, ShortDescription__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE Wiki__c =: idWikiSite ORDER BY LastModifiedDate desc limit 5];
   	}
   	    
   	/* ---------------------------- */
   	/*   	     TAG CLOUD			*/
   	/* ---------------------------- */
   	public Integer linksNum = 0;
   	
   	/**
	* Class Links
	*/
 	public class Links {
 		String linkName;
 		Integer linkCount;
 		String linkId;
 		String linkClass;
 		
 		/**
        *@return String
        */
        public String getLinkName () {
        	return linkName;
        }
        
        /**
        *@return String
        */
        public String getLinkId () {
        	return linkId;
        }
        
        /**
        *@return Integer
        */
        public Integer getLinkCount () {
        	return linkCount;
        } 
        
        /**
        *@return String
        */
        public String getLinkClass () {
        	return linkClass;
        }    
        
        /**
        *@param String
        */
        public void setLinkName (String linkName) {
        	this.linkName = linkName;
        }
        
        /**
        *@param String
        */
        public void setLinkClass (String linkClass) {
        	this.linkClass = linkClass;
        }   
        
        /**
        *@param String
        */     
        public void setLinkId (String linkId) {
        	this.linkId = linkId;
        }        
        
        /**
        *@param Integer
        */
        public void setLinkCount (Integer linkCount) {
        	this.linkCount = linkCount;
        }                              		
 	
 	}
	
	/**
	*@param List<Links>
	*@return List<WikiPage__c>
	*/
	public List<Links> upsetting (List<Links> result) {
	    Integer resultSize = result.size() - 1;
	    Integer i;
	    for (i = 0; i <= resultSize; i++) {
	        Integer alea = Integer.valueOf(String.valueOf(Math.roundToLong(Math.ceil(Math.random() * resultSize))));
	        Links tempLink;
	 		tempLink = result.get(i);
	 		result.set(i, result.get(alea));
	 		result.set(alea, tempLink); 
	    }		
		return result;
	} 
	
	/**
	*@return List<Links>
	*/
 	public List<Links> getLinkCount () {
 		
 		List<Links> popularLinks = new List<Links>();
 		
 		for (WikiPage__c item: [select Name, id, linkCount__c from WikiPage__c where Wiki__c =:idWikiSite order by Name desc limit 15]) {
 			Links link = new Links();
 			if (item.linkCount__c != 0 && item.linkCount__c != null) {
 				Integer intCount = Integer.valueOf(String.valueOf(Math.roundToLong(item.linkCount__c)));
	 			if (intCount < 2) { link.setLinkClass('tag1');}
	 			if (intCount == 2 || intCount == 3) { link.setLinkClass('tag2');}
	 			if (intCount > 3 && intCount <= 5) { link.setLinkClass('tag3');}
	 			if (intCount > 5 && intCount <= 7) { link.setLinkClass('tag4');}
	 			if (intCount > 7 && intCount <= 10) { link.setLinkClass('tag5');}
	 			if (intCount > 10 && intCount <= 13) { link.setLinkClass('tag6');}
	 			if (intCount > 13 && intCount <= 17) { link.setLinkClass('tag7');}
	 			if (intCount > 17 && intCount <= 21) { link.setLinkClass('tag8');}
	 			if (intCount > 21 && intCount <= 25) { link.setLinkClass('tag9');}
	 			if (intCount > 25) { link.setLinkClass('tag10');}
	 			
	 			link.setLinkCount(intCount);
	 			link.setLinkName(item.Name);
	 			link.setLinkId(item.Id);
	 			popularLinks.add(link);
 			}		
 		}	
 		linksNum = popularLinks.size(); 
 		return upsetting(popularLinks);	
 	}  
 	
 	/**
	*@return Integer
	*/
 	public Integer getLinksNum () {
 		return linksNum;
 	}	   	
   	/* ---------------------------- */
   	/*   	   MY FAVOURITES		*/
   	/* ---------------------------- */
   	
   	/**
	*@return List<FavoriteWikis__c>
	*/
   	public List<FavoriteWikis__c> getFavorite () {
   		return	[ SELECT WikiPage__r.Name, WikiPage__r.Id FROM FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() and WikiPage__r.Wiki__c =:idWikiSite order by WikiPage__r.Name];
   	}   	
   	
   	
   	/**
	* Class FavoriteSharing
	*/
   	public without sharing class FavoriteSharing {
   		
   		/**
		*@param String
		*@param String
		*/
   		public void setFavorites (String idWikiPage, String userId) {
   			Integer countFav = [ SELECT count() FROM FavoriteWikis__c WHERE User__c = :userId AND WikiPage__r.Id =: idWikiPage];	
	   		if (countFav == 0 ) {
	   			FavoriteWikis__c  newFav = new FavoriteWikis__c();
	   			WikiPage__c favWiki = [Select Name, Wiki__c from WikiPage__c where Id = :idWikiPage];
	   			newFav.User__c = userId;
	   			newFav.Wiki__c = favWiki.Wiki__c;
	   			newFav.WikiPage__c = idWikiPage;
	   			newFav.Name = favWiki.Name;
	   			insert newFav;
	   		}
	   		else {
	   			FavoriteWikis__c favWiki;
				favWiki = [ SELECT WikiPage__r.Name, WikiPage__r.Id FROM FavoriteWikis__c WHERE User__c = :userId AND WikiPage__r.Id =: idWikiPage];  
				delete favWiki; 			
	   		}
	   				
   		}
   		
   	}
   	 

   	public void save_del_fav () {
   		FavoriteSharing favClass = new FavoriteSharing();
   		favClass.setFavorites(idWikiPage, UserInfo.getUserId());
   	} 
   	
   	/**
	*@return Boolean
	*/
   	public Boolean getIsFav () {
   		Integer countFav = [ SELECT count() FROM FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() AND WikiPage__r.Id =: idWikiPage];
   		if (countFav == 0 ) {
   			return false;
   		}
   		else {
   			return true;
   		}
   	}  
   	
   	/**
	*@return Integer
	*/
   	public Integer getCntFav () {
   		return [select count() from FavoriteWikis__c where User__c = :UserInfo.getUserId() and WikiPage__r.Wiki__c =:idWikiSite];
   	} 
   	
   	
   	/**
	* Class RecentlyView
	*/
	public class RecentlyView {
		String wikiId;
		String wikiName;
		String parentName;
		Boolean belong;
		
		/**
		*@param String
		*/
		public void setWikiId (String wikiId) {
			this.wikiId = wikiId;
		}
		
		/**
		*@param String
		*/
		public void setWikiName (String wikiName) {
			this.wikiName = wikiName;
		}
		
		/**
		*@param String
		*/
		public void setParentName (String parentName) {
			this.parentName = parentName;
		}
		
		/**
		*@param Boolean
		*/
		public void setBelong (Boolean belong) {
	   		this.belong = belong;			
		}
		
		/**
		*@return String
		*/
		public String getWikiId () {
			return wikiId;
		}
		
		/**
		*@return String
		*/
		public String getWikiName () {
			return wikiName;
		}
		
		/**
		*@return String
		*/
		public String getParentName () {
			return parentName;
		}
		
		/**
		*@return Boolean
		*/
		public Boolean getBelong () {
			return belong;
		}	
		
	}
	 
	/**
	* Returns a list of the recently viewed wikies.
	*@return List<RecentlyView>
	*/
   	public List<RecentlyView> getRecentlyView () {
   		List<RecentlyView> views = new List<RecentlyView>();
   		for (WikiRecentlyViewed__c item :	[ SELECT WikiPage__r.Wiki__r.Id, WikiPage__r.Wiki__r.Name , WikiPage__r.Name, WikiPage__r.Id FROM WikiRecentlyViewed__c WHERE User__c = :UserInfo.getUserId()  ORDER BY LastModifiedDate desc limit :maxView]) { //and WikiId__r.WikiSpace__c =:idWikiSite
   			RecentlyView view = new RecentlyView();
   			view.setWikiId(item.WikiPage__r.Id);
   			view.setWikiName(item.WikiPage__r.Name);
   			view.setParentName(item.WikiPage__r.Wiki__r.Name);
   			if (item.WikiPage__r.Wiki__r.Id == idWikiSite) {
   				view.setBelong(true);
   			}
   			else {
   				view.setBelong(false);
   			}
   			views.add(view);
   		} 
   		return views;  	
   	}    	
   	
   	
   	/**
	*@return Integer
	*/
   	public Integer getCntViews () {
   		return	[ SELECT count() FROM WikiRecentlyViewed__c WHERE User__c = :UserInfo.getUserId()];
   	}
   	
   	
   	/* ---------------------------- */
   	/*   		 COMMENTS			*/
   	/* ---------------------------- */
	public Boolean addComment = false;
   	public String commentName = '';
   	public String commentBody = '';
	
	
	/**
	* Class Comments
	*/
   	public class Comments {
   		String commentDate;
   		String comment;
   		String commentName;
   		String commentBy;
   		
   		/**
		*@param String
		*/
   		public void setCommentName (String commentName) {
   			this.commentName = commentName;
   		}
   		
   		/**
		*@param String
		*/
	   	public void setComment (String comment) { 
	   		this.comment = comment;
	   	}
	   	
	   	/**
		*@param Datetime
		*/
	   	public void setCommentDate (Datetime commentDate) {
	   		this.commentDate = commentDate.format(); 
	   	}
	   	
	   	/**
		*@param String
		*/
	   	public void setCommentBy (String name) {
	   		this.commentBy = name;
	   	}
	   	
	   	/**
		*@return String
		*/
	   	public String getCommentName () {
	   		return commentName;
	   	}
	   	
	   	/**
		*@return String
		*/
	   	public String getCommentDate () {
	   		return commentDate;
	   	}
	   	
	   	/**
		*@return String
		*/
	   	public String getCommentBy () {
	   		return commentBy;
	   	}
	   	
	   	/**
		*@return String
		*/
	   	public String getComment () {
	   		return comment;
	   	}
	   	
	   	/**
		*@return String
		*/
		public String getShowShortCommentBy(){
			Integer charDisplayed = 20;
	        		
			if(commentBy.length() > charDisplayed){
	           return commentBy.substring(0,charDisplayed-1) + '...';            	
	        }else{
	        	return commentBy;
	        }
		}
   	}
   	   	
   	/**
	*@return String
	*/
   	public String getCommentName () {
   		return commentName;
   	}
   	
   	/**
	*@param String
	*/
   	public void setCommentName (String commentName) {
   		this.commentName = commentName;
   	}
   	
   	/**
	*@return String
	*/
   	public String getCommentBody () {
   		return commentBody;
   	}
   	
   	/**
	*@param String
	*/
   	public void setCommentBody (String commentBody) {
   		this.commentBody = commentBody;
   	}   
   	
   	/**
	*@return List<Comments>
	*/
   	public List<Comments> getComments () {
   		List<Comments> commentsList = new List<Comments>();
      		
   		List<String> userComment = new List<String>(); 
   		
   		for (Comment__c item: [ SELECT Message__c, CreatedBy.Name, CreatedById, LastModifiedDate FROM Comment__c WHERE ParentWikiPage__c =:idWikiPage ORDER BY LastModifiedDate desc]){
   			userComment.add(item.CreatedById);
   		}
		List<Wiki__c> pictureId = [SELECT PictureId__c FROM Wiki__c WHERE Id =: idWikiPage limit 1];
		Integer countComment = [select count() from Comment__c WHERE ParentWikiPage__c =:idWikiPage];
   		if (countComment != 0) {
	   		for (Comment__c item: [ SELECT Message__c, CreatedBy.Name,CreatedById, LastModifiedDate FROM Comment__c WHERE ParentWikiPage__c =:idWikiPage ORDER BY LastModifiedDate desc]) {
	   			Comments itemComment = new Comments();
	   			itemComment.setCommentBy(item.CreatedBy.Name);
	   			itemComment.setComment(item.Message__c);
	   			itemComment.setCommentDate(item.LastModifiedDate);
	   			//itemComment.setCommentPicture(pictureId[0]);
	   			commentsList.add(itemComment);
	   		}	
   		}
   		return	commentsList;
   	}
   	 
   	/**
	*@return Integer
	*/   	
   	public Integer getCntComments () {
   		return	[ SELECT count() FROM Comment__c WHERE ParentWikiPage__c =: idWikiPage];
   	}  
   	  
   	/**
	*@return Boolean
	*/ 
   	public Boolean getAddComment () {
   		return addComment;	
   	}
   	 
    /**
	* Sets addComent to true
	*/ 
   	public void addCommentLink () {
   		addComment = true;
   	}
   	
   	/**
	* Saves the current comment
	*/ 
   	public void saveComment () {
   		Comment__c newComment = new Comment__c();
   		newComment.Message__c = commentBody;
   		newComment.ParentWikiPage__c = idWikiPage;
   		insert newComment;
   		commentBody = '';
   		addComment = false;
   	}
   	
   	/**
	* Cancels the current coment
	*/
   	public void cancelComment () {
   		commentBody = '';
   		addComment = false;
   	}
   	
   	/* ---------------------------- */
   	/*   		REVISIONS			*/
   	/* ---------------------------- */   	
   	
   	/**
	*@return String
	*/ 
	public String getCurrentRevision () {
   		Integer revCount;
   		Integer resultCount = [select count() from WikiVersions__c where WikiPageId__c =:idWikiPage];
	   	if (resultCount != 0) {	
	   		WikiVersions__c wikiVersion = [select Name from WikiVersions__c where WikiPageId__c =:idWikiPage order by CreatedDate desc limit 1];
	   		
	   		revCount = 1;
	   	}
	   	else {
	   		revCount = 1;
	   	} 
   		return ('Revision v' + revCount);
   		
   	}
   	
   	/* ---------------------------- */
   	/*   		DELETE PAGE			*/
   	/* ---------------------------- */  
   	
   	/**
	* Class DeleteWiki
	*/
   	public without sharing class DeleteWiki {
   		
   		/**
		*@return PageReference
		*@throws CustomException
		*/
   		public PageReference deleteWikiPage (List<WikiPage__c> wikiPageBodyList, UserPermissions userPermissions) {
   			PageReference pageRef;
   			if (userPermissions.getCanManage()) {
		   		String wikiParent = '';
		   		String idWikiSite = '';
		   		if (wikiPageBodyList.size() > 0) {
		   			if (wikiPageBodyList[0].Parent__c != null) {
		   				wikiParent = wikiPageBodyList[0].Parent__c;	
		   			}
		   			idWikiSite = wikiPageBodyList[0].Wiki__c;
		   			delete wikiPageBodyList;
		   		}
		   		if (wikiParent != '') {
		   			pageRef = Page.WikiPage;
		   			pageRef.getParameters().put('idWP', wikiParent);
		   		}
		   		else {
		   			pageRef = Page.WikiTeamOverview;
		   			pageRef.getParameters().put('tid', idWikiSite);
		   		}
	   		}
	   		else {
	   			throw new CustomException('Insufficient Privileges');		
	   		}
	   		pageRef.setRedirect(true);
			return pageRef;
   		}	
   	}
   	
   	/**
	*@return PageReference
	*/ 
   	public PageReference deletePage () {
   		DeleteWiki delW = new DeleteWiki();
   		return delW.deleteWikiPage(wikiPageBodyList,userPermissions);
   	}

}