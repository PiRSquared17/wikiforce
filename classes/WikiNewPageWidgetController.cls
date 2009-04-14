/**
*@author Gabriel Rilo @ 01/06/2009
*/
public with sharing class WikiNewPageWidgetController {
	
	public String idTeam = System.currentPageReference().getParameters().get('id');
	public String idWikiPage = System.currentPageReference().getParameters().get('idWP');
	public String idTeamOverview = System.currentPageReference().getParameters().get('tid');
	
	/**
	* Costructor
	*/
	public WikiNewPageWidgetController () {
		constructMethods();
	}	
	
	/**
	*@return Return the Namespace Prefix 
	*/
	public String getNamespace () {
        return TeamUtil.getNamespace();
    } 
	
	/**
	*@param String
	*/
	public void setIdTeam (String idTeam) {
		this.idTeam = idTeam;
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
	public void setIdTeamOverview (String idTeamOverview) {
		this.idTeamOverview = idTeamOverview;
	}

	/**
	* Excecutes on construct
	*/
	public void constructMethods () {
		if (idTeam != null || idWikiPage != null || idTeamOverview != null) {
			if (idTeamOverview != null && idTeamOverview != '') 
				idTeam = idTeamOverview;
			if (idWikiPage != '' && idWikiPage != null) {
				List<WikiPage__c> wikiShareList = [SELECT Wiki__c From WikiPage__c WHERE id =:idWikiPage];
				if (wikiShareList.size() > 0) {
					idTeam = wikiShareList[0].Wiki__c;
				}else{
					throw new CustomException('Insufficient Privileges');	
				}
			}
		}
	}
	
	

	/**
	*@return String
	*/
	public String getIdTeam () {
		return idTeam;
	}
	
	/**
	*@return String
	*/
	public String getIdTeamOverview () {
		return idTeamOverview;
	}
	
	/**
	*@return String
	*/
	public String getIdWikiPage () {
		return idWikiPage;	
	}
	
	/**
	* For rerende use
	*/
	public void refreshWikis () {}
	
	
	/* Save new Wiki Page */
	public WikiPage__c newWikiPage = new WikiPage__c();
	
	/**
	*@return WikiPage__c
	*/
	public WikiPage__c getNewWikiPage () {
		return newWikiPage;
	}
		
	/**
	* Save Wiki
	*@return PageReference
	*/
	public PageReference saveWiki () {
		if (idWikiPage != null && idWikiPage != '') 
			newWikiPage.Parent__c = idWikiPage;
		newWikiPage.Wiki__c = idTeam;
		newWikiPage.Body__c = '=== Congratulations! === \n You created a new wiki page. Begin by clicking the "Edit" button above to modify this page.';
		TeamUtil.hostName = TeamUtil.getHost(ApexPages.currentPage());
		insert newWikiPage;
		
		if (idWikiPage == null && idTeamOverview == null) {
			TeamsWidgetWikiDirectoryController directory = new TeamsWidgetWikiDirectoryController();
			if (directory.getWikiPagesCount() == 0) {
				directory.setWikiPagesCount(1);
			}	
		}
		newWikiPage = new WikiPage__c();
		return null;
	}
	
	/**
	* Save and New wiki page
	*@return PageReference
	*/
	public PageReference saveWikiAndEdit () {
		TeamUtil.hostName = TeamUtil.getHost(ApexPages.currentPage());
		
		if (idWikiPage != null && idWikiPage != '') 
			newWikiPage.Parent__c = idWikiPage;
		newWikiPage.Wiki__c = idTeam;
		newWikiPage.Body__c = '=== Congratulations! === \n You created a new wiki page for your team. Begin by clicking the "Edit" button above to modify this page.';
		insert newWikiPage;
		
		PageReference pageRef = Page.WikiPageEdit;
		//PageReference pageRef = Page.WikiTeamOverview;
		pageRef.getParameters().put('id', newWikiPage.Id);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
		
}