/**
*@author German Barrios @ 16/01/2009
*/
public class DeleteWikiController {
	
	/**
	* Construct
	*/
	public DeleteWikiController (){}
	
	String pageFrom = '';
	/**
	* Get Page from which delete function has 
	* been called from
	*@return String
	*/
	public String getPageFrom() {	
		return pageFrom;
	}
	
	/**
	* Set page from which delete function has 
	* been called from
	*@param String
	*/
	public void setPageFrom(String page) {	
		pageFrom = page;
	}
	
	
	String wikiId = '';
	/**
	* Get Topic Id
	*@return String
	*/
	public String getWikiId() {	
		return wikiId;
	}
	
	/**
	* Set Topic Id
	*@param String
	*/
	public void setWikiId(String wID) {	
		wikiId = wID;
	}

	/**
	* Delete Topic by Id
	*/
	public PageReference deleteWiki(){
		List<Wiki__c> wikiToDelete = [select Id from Wiki__c where Id =: WIKIID];
		if (wikiToDelete.size() > 0) {
			delete wikiToDelete[0];
			if(this.pageFrom == 'WikiTeamOverview'){
				System.debug('With PR' + this.pageFrom);
				PageReference pr=new PageReference('/apex/WikiOverview');
				pr.setRedirect(true);
				return pr;
			}
			else{
				System.debug('Without PR' + this.pageFrom);
				return null;
			}
			
		}	
		return null;
	}

}