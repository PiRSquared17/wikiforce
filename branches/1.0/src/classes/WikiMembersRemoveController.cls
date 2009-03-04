/** 
* @author dgadola @ 01-21-09
*/

public class WikiMembersRemoveController {
	
	public String idWiki = System.currentPageReference().getParameters().get('id');
	public String removeMemberId = WikiCreateWikiController.removeMemberId;
	public WikiMemberController wmc = new WikiMemberController();

	/**
	* Constructor
	*/
	public WikiMembersRemoveController() {}
	
	/**
	* @return wikiName
	*/
	public String getWikiName() {
		String name;
		if(idWiki != null){
			Wiki__c currentWiki = [select Name from Wiki__c where Id =: idWiki];
			name = currentWiki.Name;
		}
		return name;
	}
	
	/**
	* @return delName
	*/
	public String getDelName() {
		String delName = '';
		if (WikiCreateWikiController.removeMemberId != null 
				&& WikiCreateWikiController.removeMemberId != '') {
			removeMemberId = WikiCreateWikiController.removeMemberId;
			
			delName = [select User__r.Name from WikiMember__c 
						where User__c =: removeMemberId and Wiki__c =: idWiki].User__r.Name;
		}
		return delName;
	}
	
	/**
	* return if the member to remove is the last admin
	*/
	public Boolean getIsLastMemberAdmin() {
		if (WikiCreateWikiController.removeMemberId != null 
				&& WikiCreateWikiController.removeMemberId != '') {
			removeMemberId = WikiCreateWikiController.removeMemberId;
		}
		wmc.setUserId(removeMemberId);
		wmc.setWikiId(idWiki);
		return wmc.isLastMemberAdmin();	 
	}
	

	/**
	* Delete selected member
	*/
	public void removeMember () {
		if (!getIsLastMemberAdmin()) {
			wmc.setUserId(removeMemberId);
			wmc.setWikiId(idWiki);
			wmc.unjoinWiki();	
		}
	}
}