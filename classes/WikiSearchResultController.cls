/**
*@author Gabriel Rilo @ 18-12-2008
*/
public  with sharing class WikiSearchResultController {

	public String criteria;
	
	/**
	* Constructor
	*/
	public WikiSearchResultController(){
		criteria = System.currentPageReference().getParameters().get('key');
	}
	
	/**
	*@return String
	*/
	public String getCriteria () {
		return criteria;
	}
	
	/**
	*@param String
	*/
	public void setCriteria (String criteria) {
		this.criteria = criteria;
	}
	
	public Integer totalItemsNumber= 0;

	/**
	*@return Integer
	*/
	public Integer getTotalItemsNumber () {
		return totalItemsNumber;
	}
	
	public Boolean noMatches;
	
	/**
	*@return Boolean
	*/
	public Boolean getNoMatches () {
		return noMatches;	
	}	
	
	public List<sr> srList = new List<sr>();	
	
	/**
	*@return List<sr>
	*/
	public List<sr> getsrList () {
		return srList;
	}
	
	public List<WikiPage__c> results = new List<WikiPage__c>();
	
	/**
	*@return List<sr>
	*/
	public List<WikiPage__c> getResults () {
		return results; 
	}
	
	
	/**
	* Make the Search
	*/
	public void search () {
		
		List<sr> srList2 = new List<sr>();
			 
		List<WikiMember__c> wikisMembers = new List<WikiMember__c>();

		wikisMembers = [select Id, Wiki__r.Id from WikiMember__c where Wiki__r.Type__c = 'private' and User__c =: UserInfo.getUserId()];
				
		List<Wiki__c> myWikis = new List<Wiki__c>();
		for( WikiMember__c wm: wikisMembers)
			myWikis.add(wm.Wiki__r);
		
		
		if (criteria == null || criteria == '')               
			results= [select Name, Id from WikiPage__c where Wiki__r.Type__c != 'private' OR Wiki__c in:myWikis ORDER By Name]; 
		else
		{
			String cad = '';
			for( WikiMember__c wm: wikisMembers)
			cad +=' OR Wiki__c = \'' + wm.Wiki__r.Id + '\'';
			
			String namespace = TeamUtil.getNamespace(); 
			String prefix = (namespace != '') ? namespace + '__' : '';			
			
			results = (List<WikiPage__c>) search.query( 'FIND \'' + criteria + '*\' IN ALL FIELDS RETURNING '+ prefix +'WikiPage__c (Id, Name  where Wiki__r.Type__c != \'private\'' + cad + ' ORDER By Name)')[0];	
		}
		 
		for(WikiPage__c l: results){
			sr searchResult = new sr();
			searchResult.setWikiPageName(l.Name, criteria);
			searchResult.setWikiPageId(l.Id); 
			srList2.add(searchResult);
			
		}
		
			srList = srList2;
		
		totalItemsNumber = results.size();
		if (totalItemsNumber == 0 ) {
			noMatches = true;
			cntPagination = 0;	
			firstRow = 0;
			currentPagination = 1;
			jumpPage = 1;
		}else {
			noMatches = false;
			firstRow = 0;
			currentPagination = 1;
			jumpPage = 1;
			genCntPagination();	
		}
		
	}
   	
   	// Set of Integers to control pagination
   	public Integer numberOfItemsToShow = 10;
   	public Integer cntPagination;
   	public Integer currentPagination = 1;
   	public Integer firstRow = 0;
   	
   	// Set of Booleans to show or not prev / next links
   	public boolean prevPageLinkShow = false;
   	public boolean prevPageShow  = false;
   	public boolean nextPageLinkShow  = false;
   	public boolean nextPageShow  = false;
   	
   	/**
   	* Count number of result pages
   	*@void
   	*/
   	public void genCntPagination () {
   		cntPagination = (totalItemsNumber - (Math.mod(totalItemsNumber, numberOfItemsToShow)))/ numberOfItemsToShow;	
   		if (Math.mod(totalItemsNumber, numberOfItemsToShow) != 0 ) {
   			cntPagination++;
   		} 	
   	}
   	
   	/**
   	* Go next result page
   	*/
   	public void nextPage () {
   		currentPagination++;
   		jumpPage = currentPagination;
   		firstRow = firstRow + numberOfItemsToShow;   		
   	}
   	
   	/**
   	* Go previus result page
   	*/
   	public void prevPage () {
   		currentPagination--;
   		jumpPage = currentPagination;
   		firstRow = firstRow - numberOfItemsToShow;	
   	}

	/**
   	* Go last result page
   	*/
   	public void lastPage () {
   		currentPagination = cntPagination;
		jumpPage = cntPagination;
		firstRow = (jumpPage - 1)* numberOfItemsToShow;		
   	}
   	
   	/**
   	* Go first result page
   	*/
   	public void firstPage () {
   		currentPagination = 1;
   		jumpPage = 1;
   		firstRow = (jumpPage - 1)* numberOfItemsToShow;	
   	}

	/**
	* Empty function for refresh result list
	*/
   	public void refreshPages () {
   		
   	}
   	
   	/**
   	* Pagination Integer Getters
   	*@return Integer
   	*/
   	public Integer getFirstItem () {
		return (firstRow + 1);
	}
	
	/**
	* Assign a number to the last page's result
	*@return Integer
	*/
	public Integer getLastItem () {
		Integer lastItem;
		if ((currentPagination == cntPagination) || (currentPagination == 1 && (totalItemsNumber < numberOfItemsToShow))) {
			lastItem = firstRow + Math.mod(totalItemsNumber, numberOfItemsToShow);
		}else {
			lastItem = firstRow + 10;
		}
		return lastItem;
	}
   	
   	/**
   	* Return current page number
   	*@return Integer
   	*/
   	public Integer getCurrentPagination () {
   		return currentPagination;
   	}
   	
   	/**
   	* Return number of result pages
   	*@return Integer
   	*/
   	public Integer getCntPagination () {
   		return cntPagination;
   	}
   	
   	/**
   	* Return number of results
   	*@return Integer
   	*/
   	public Integer getNumberOfItemsToShow () {
   		return numberOfItemsToShow;
   	}
   	
   	/**
   	* Return the number of the first item of page
   	*@return Integer
   	*/
   	public Integer getFirstRow () {
   		return firstRow;
   	}
   	
   	/**
   	* Return if show Prev Link
   	*@return boolean
   	*/
	public boolean getPrevPageLinkShow () {
		if(currentPagination == 1){ 
			prevPageLinkShow = false;		
		}else {
			prevPageLinkShow = true;
		}
   		return prevPageLinkShow;
   	}
   	
   	/**
   	* Return if show Prev Link
   	*@return boolean
   	*/
   	public boolean getPrevPageShow () {
   		
   		if(currentPagination == 1){	
   			prevPageShow = true; 
   		}else {
   			prevPageShow = false;
   		}
   		return prevPageShow;
   	}
   	
   	/**
   	* Return if show Next Link
   	*@return boolean
   	*/
   	public boolean getNextPageLinkShow () {
   		if((currentPagination == cntPagination) || (cntPagination == 0)){	
   			nextPageLinkShow = false; 
		} else { 
			nextPageLinkShow = true;
		}   		
   		return nextPageLinkShow;
   	}
   	
   	/**
   	* Return if show Next Link
   	*@return boolean
   	*/
   	public boolean getNextPageShow () {
   		if((currentPagination == cntPagination) || (cntPagination == 0)){ 
   			nextPageShow = true; 
		} else { 
			nextPageShow = false;
		} 
   		return nextPageShow;
   	}
	
	public Integer jumpPage = 1;
	
	/**
	* Jump to page
	*@return Integer jumpPage
	*/   
	public Integer getJumpPage () {
		return jumpPage;
	}
	
    /**
    * Set jumpo to page
    *@param Integer jumpPage
    */
	public void setJumpPage (Integer jumpPage) {
		this.jumpPage = jumpPage;
	}
	
    /**
    * Jump to page
    */
	public void JumpToPage () {
		if (jumpPage > cntPagination) {
			currentPagination = cntPagination;
			jumpPage = cntPagination;
		}else {
			if (jumpPage < 1) {
				currentPagination = 1;
				jumpPage = 1;
			}else {	
				currentPagination = jumpPage;
			}
		}
		firstRow = (jumpPage - 1)* numberOfItemsToShow;
	}
	
	/**
	* Inner class for sr type
	*@class
	*/
	public class sr{
		String wikiPageName;
		String matches;
		String url;
		String wikiPageId = '';
				
		/**
		*@param String
		*/
		public void setWikiPageId (String wikiPageId) {
			this.wikiPageId = wikiPageId;
		} 
			
		/**
		*@param String name
		*@param String criteria
		*/
		public void setWikiPageName (String name, String criteria) {
			String highlight = '';
			if (name != null) {
				String nameLow = name.toLowerCase();
				String criteriaLow = criteria.toLowerCase();
				
				if (criteria != null && criteria != '' && nameLow.indexOf(criteriaLow) != -1) {
					highlight = name.replaceAll('(?i)' + criteria, '<span class="highlight">$0</span>');
				}else{
					highlight = name;
				}
			}
			this.wikiPageName = highlight;	
		}	
		
		/**
		*@param String matches
		*@param String criteria
		*/
		public void setMatches (String matches, String criteria) {
			String highlight = '';
			Integer maxLength = 50;
			if (matches != null) {
				String matchesLow = matches.toLowerCase();
				String criteriaLow = criteria.toLowerCase();
				matches = matches.replaceAll('(?i)<[^>]*>', '');
				if (criteria != null && criteria != '' && matchesLow.indexOf(criteriaLow) != -1) {
					Integer msjLength = matches.length();
					Integer iniHighLight = matchesLow.indexOf(criteriaLow) - 50;
					Integer criteriaLength = criteria.length();
					Integer endHighLight = matchesLow.indexOf(criteriaLow) + criteriaLength + 50;
					if (iniHighLight < 0) {
						if (endHighLight > msjLength) {
							highlight = matches.substring(0,msjLength);	
						}else {
							highlight = matches.substring(0,endHighLight) + '...';	
						}
					}else {
						if (endHighLight > msjLength) {
							highlight = '...' + matches.substring(iniHighLight,msjLength);	
						}else {
							highlight = '...' + matches.substring(iniHighLight,endHighLight) + '...';	
						}		
					}
					
					highlight = highlight.replaceAll('(?i)' + criteria, '<span class="highlight">$0</span>');
				}else {
					if(matches.length() <= maxLength*2) {
						highlight = matches;	
					}else {
						highlight = matches.substring(0,maxLength*2) + '...';	
					}	
				}
			}
			this.matches = highlight;
		}
		
		/**
		*@return String
		*/
		public String getMatches () {
			return matches;
		}
		
		/**
		*@return String
		*/
		public String getUrl () {
			return url;
		}		
		
		/**
		*@return String
		*/
		public String getWikiPageName () {
			return wikiPageName; 
		}		
		
		public String getWikiPageId(){
			return wikiPageId;
		}	
	}
}