/** 
* @author dgadola @ 01-21-09
*/

public class WikiMembersRemoveController {
	
	public String idWiki = System.currentPageReference().getParameters().get('id');
	public String removeMemberId = WikiCreateWikiController.removeMemberId;
	public WikiMemberController wmc = new WikiMemberController();
 	public String removeMemberIds = '';
 	public Boolean error = false;
 	public Boolean finish = false;

	
 
	/**
	* Constructor
	*/
	public WikiMembersRemoveController(){}
	
	public Boolean getError()
	{
		return this.error;
	}
	
	public Boolean getFinish()
	{
		return this.finish;
	}
	
	public void setRemoveMemberIds( String memberListToremove )
	{
		removeMemberIds = memberListToremove;
	}

	public String getRemoveMemberIds()
	{
		return removeMemberIds;
	}



	public void setRemoveMemberId(String memberId) {
	   removeMemberId = memberId;
	}
	
	public String getRemoveMemberId() {
	   return removeMemberId;	
	}
	

	
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
		System.debug('\n\nThe LAST TIME removeMemberId ==> ' + removeMemberId + '\n\n');
		String delName = '';
		//if (WikiCreateWikiController.removeMemberId != null && WikiCreateWikiController.removeMemberId != '') {
			//removeMemberId = WikiCreateWikiController.removeMemberId;
        if (removeMemberId != null && removeMemberId != '') {
			delName = [select User__r.Name from WikiMember__c 
						where User__c =: removeMemberId and Wiki__c =: idWiki].User__r.Name;
		}
		return delName;
	}
	
	/**
	* return if the member to remove is the last admin
	*/
	public Boolean getIsLastMemberAdmin() {
		Boolean isLastAdminMember = false;
		if (WikiCreateWikiController.removeMemberId != null 
				&& WikiCreateWikiController.removeMemberId != '') {
			removeMemberId = WikiCreateWikiController.removeMemberId;

			wmc.setUserId(removeMemberId);
			wmc.setWikiId(idWiki);
			isLastAdminMember = wmc.isLastMemberAdmin();	 
		}
		return isLastAdminMember;
	}
	
	public void doRefresh (){}

	/**
	* Delete selected member
	*/
	public void removeMember () 
	{
		TeamUtil.hostName = TeamUtil.getHost(ApexPages.currentPage());
		if (!getIsLastMemberAdmin()) 
		{
			wmc.setUserId(removeMemberId);
			wmc.setWikiId(idWiki);
			wmc.unjoinWiki();	
		}
	}
	
	public void massiveRemoveMember()
	{
		this.error = false;
		this.finish = false;
		
		if( removeMemberIds != '' )
		{
			List<String> idsList = new List<String>();
			
			idsList = removeMemberIds.split(',');
			
			List<WikiMember__c> memberListToDelete = new List<WikiMember__c>();
			memberListToDelete = [ select Id, Name from WikiMember__c where Id in: idsList ];
			
			
			List<WikiMember__c> adminList = new List<WikiMember__c>();
			adminList = [ select Id from WikiMember__c where WikiProfile__r.ManageWikis__c = true and Wiki__c =: idWiki and Id not in: memberListToDelete ];

						
			if( adminList.size() > 0 )
			{
				this.finish = true;
				this.error = false;
				System.debug('this.finish: ' + this.finish);
				delete memberListToDelete;
			}
			else
			{
				this.error = true;
				this.finish = false;
				wmc.isLastMemberAdmin();
			}
			

		}
	}
	
}