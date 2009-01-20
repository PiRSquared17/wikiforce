/**
*@author German Barrios @ 01-15-2009
*/
public class WikiMemberController {
	private String wikiId;
	
	/**
	*@constructor
	*/
	public void WikiMemberController(){
		
	}
	
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
	* Return current user id
	*@return String
	*/
	public String getUserId(){
		return UserInfo.getUserId();
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
	
	public String getWikiProfileId(){
		List<WikiProfile__c> wikiProfile = [select Id from WikiProfile__c where Name = 'Public Profile' ];
		return wikiProfile[0].Id;
	}
	
}