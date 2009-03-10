/**
*@author Juan Bessonart @ 06/27/2008
*/
public class WikiPageImagesController {
	
	public String idWikiPage = null;
	
	// max attachment size bytes
    public final Integer MAX_SIZE = 5240000;
    
    public Boolean validAttSize = true;
    
    public WikiPageImagesController(){
    	if(idWikiPage == null)
    		idWikiPage = System.currentPageReference().getParameters().get('idWP');
    }
    
	/**
	* Set parent id for Attachment instance
	*@param String
	*/
	public void setIdWikiPage (String idWiki) {
		this.idWikiPage = idWiki;
	}
	
	/**
	*@return String
	*/
	public String getIdWikiPage () {
		return this.idWikiPage;
	}
    
	/**
	*@return Boolean
	*/
	public Boolean getValidAttSize(){
		return validAttSize;
	}	
	
	// New Attachment Object
	public Attachment newAttach = new Attachment();
	
	/**
	*@param Attachment
	*/
	public void setNewAttach (Attachment newAttach) {
		this.newAttach = newAttach;	
	}
	
	/**
	*@return Attachment
	*/
	public Attachment getNewAttach () {
		return newAttach;
	}
	
	/**
	* Save new image
	*@return PageReference
	*/
	public PageReference saveNewImage () {
		
		System.debug( '###: ' + this.idWikiPage );
		newAttach.ParentId = this.idWikiPage;
		PageReference pageRef = ApexPages.currentPage();
		if(newAttach.BodyLength <= MAX_SIZE || (newAttach.name != null || newAttach.name != '') || (this.idWikiPage != null || this.idWikiPage != '')){
			this.validAttSize = true;
			insert newAttach;
			pageRef.setRedirect(true);
			newAttach = new Attachment();
			return pageRef;
		}else{
			this.validAttSize = false;
			pageRef.setRedirect(true);
			newAttach = new Attachment();
			return pageRef;
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
           			'gif' => 'images.gif'
       			};
           		if(typesExt.containsKey(extension)) {
           			image = typesExt.get(extension);
           		}
            }else {
           		// Using mime type
           		Map<String, String> typesMime = new Map<String, String>{
           			'image/jpeg' => 'images.gif', 
           			'image/pjpeg' => 'images.gif', 
           			'image/png' => 'images.gif', 
           			'image/x-png' => 'images.gif', 
           			'image/gif' => 'images.gif', 
           			'image/bmp' => 'images.gif'
       			};	
           		if(typesMime.containsKey(ContentType)) {
           			image = typesMime.get(ContentType);
           		}
            }
       		
       		// MIME TYPE
       		
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

        /**
        *@param String
        */
        public void setAttachImage (String attachImage) {
                this.attachImage = attachImage;
        }          
                                        
	}
}