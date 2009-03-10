/**
*@author German Barrios @ 01-15-2009
*/
public without sharing class WikiMemberController {
	private String wikiId;
	private String userId = null;
	
	/**
	*@constructor
	*/
	public void WikiMemberController(){}
	
	/**
	* Add user in a wiki group
	*/
	public void joinWiki(){
		WikiMember__c wikiMember = new WikiMember__c();
		wikiMember.User__c = this.getUserId();
		wikiMember.WikiProfile__c = this.getWikiProfileId();
		wikiMember.Wiki__c = this.getWikiId();
		
		insert wikiMember;
	}
	
	/**
	* Quit member of team
	*/
	public void unjoinWiki(){
		List<WikiMember__c> member = [select Id, User__c from WikiMember__c where User__c =: this.getUserId() and Wiki__c =: this.getWikiId()];
		if(member.size() > 0){
			delete member[0];
		}
	}
	
    /**
    * Check if current user is the last member admin
    *@return bool is last member
    */
    public Boolean isLastMemberAdmin (){
        List<WikiMember__c> members = new List<WikiMember__c>();
        members = [Select d.Name, User__c From WikiMember__c d where WikiProfile__r.Name = 'Wiki Administrator' and Wiki__c =: wikiId];
        if(members.size() == 1 && members[0].User__c == getUserId())
            return true;
        else
            return false;       
    }
    
	/**
	* Return current user id
	*@return String
	*/
	public String getUserId(){
		if(userId == null)
			return UserInfo.getUserId();
		else
			return userId;
	}
	
	/**
	*@param id user id
	*/
	public void setUserId(String id){
		userId = id;
	}
	
	/**
	* Set id of wiki
	*@param String
	*/
	public void setWikiId(String id){
		this.wikiId = id;
	}
	
	/**
	*@return String wiki ID
	*/
	public String getWikiId(){
		return this.wikiId;
	}
	
	/**
	*@return public profile id
	*/
	public String getWikiProfileId(){
		List<WikiProfile__c> wikiProfile = [select Id from WikiProfile__c where Name = 'Member Profile' ];
		return wikiProfile[0].Id;
	}
}