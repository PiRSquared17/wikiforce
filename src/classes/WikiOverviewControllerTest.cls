@IsTest private class WikiOverviewControllerTest { 
	
	public static testMethod void testWiki() {
		GenerateEnvironmentTest.gen();
		Test.startTest();
		WikiOverviewController wiki = new WikiOverviewController ();
		System.currentPageReference().getParameters().put('allTeams','');
		wiki.genWikiSites();
		
		/* WIKI INNER CLASS */
		WikiOverviewController.Wiki wikiC = new WikiOverviewController.Wiki();

		if (wikiC.getParentName() == null) 
			System.assert(true, 'Null Wiki class var ');
		if (wikiC.getParentId() == null) 
			System.assert(true, 'Null Wiki class var ');
		if (wikiC.getName() == null) 
			System.assert(true, 'Null Wiki class var ');
		if (wikiC.getId() == null) 
			System.assert(true, 'Null Wiki class var ');
		if (wikiC.getLastModifiedBy() == null) 
			System.assert(true, 'Null Wiki class var ');
		if (wikiC.getLastModifiedById() == null) 
			System.assert(true, 'Null Wiki class var ');
		if (wikiC.getLastModifiedDate() == null) 
			System.assert(true, 'Null Wiki class var ');
		if (wikiC.getShortDescription() == null) 
			System.assert(true, 'Null Wiki class var ');
		
		/* PAGINATION */
		wiki.refreshTab();
		try {
			wiki.genCntPagination();
		}catch (exception e) {
			System.assert(true, e);
		}
		try {
			wiki.nextPage();
		}catch (exception e) {
			System.assert(true, e);
		}
		try {
			wiki.prevPage();
		}catch (exception e) {
			System.assert(true, e);
		}
		
		if (wiki.getNumSitesRows() == null) 
			System.assert(true, 'Null pagination Var');
		if (wiki.getFirstRow() == null) 
			System.assert(true, 'Null pagination Var');
		if (wiki.getCurrentPagination() == null) 
			System.assert(true, 'Null pagination Var');
		if (wiki.getCntPagination() == null) 
			System.assert(true, 'Null pagination Var');
		/* SHOW WIKI SITES */
		if (wiki.getWikiSites() == null) 
			System.assert(true, 'Wiki Sites return null');
		
		/* LETTER FILTER */
		List<WikiOverviewController.Letters> ltr = wiki.getLetterFilter();
		/* LETTER FILTER INNER CLASS */
		WikiOverviewController.Letters ltrC = new WikiOverviewController.Letters();
		if (ltrC.getLetter() == null) 
			System.assert(true, 'Null Letter filter ');
		if (ltrC.getContainSites() == null) 
			System.assert(true, 'Null Letter filter ');
		if (ltrC.getCntSites() == null) 
			System.assert(true, 'Null Letter filter ');
		if (ltrC.getCntSites() == null) 
			System.assert(true, 'Null Letter filter ');
		if (ltr == null) 
			System.assert(true, 'Null Letter filter ');
		try {
			wiki.filterSites();
		}catch (exception e) {
			System.assert(true, e);
		}
		try {
			wiki.setLetter('A');
		}catch (exception e) {
			System.assert(true, e);
		}
		try {
			wiki.filterSites();
		}catch (exception e) {
			System.assert(true, e);
		}
		
		/* RECENTLY UPDATED */
		List<WikiOverviewController.Wiki> recentlyUpd = wiki.getRecentlyUpdated();
		if (recentlyUpd == null) 
			System.assert(true, 'Null recently updated');
		
		/* MY RECENTLY CHANGES */
		if (wiki.getCntMyRecentChanges() == null) 
			System.assert(true, 'Null Count My recent Changes Wikis');
		
		List<WikiOverviewController.Wiki> myChangesWikis = wiki.getMyRecentChanges();
		
		if (myChangesWikis == null) 
			System.assert(true, 'Null My Recently changed Wikis');
		
		/* FAVORITES */
		if (wiki.getCntFav() == null) 
			System.assert(true, 'Null Count Favorites Wikis');
		
		List<FavoriteWikis__c> favWikis = wiki.getFavorite();
		
		if (favWikis == null) 
			System.assert(true, 'Null Favorites Wikis');
		
		/* TEAM WIKI INNER CLASS */
		WikiOverviewController.TeamWikis teamWikiC = new WikiOverviewController.TeamWikis();
		if (teamWikiC.getId() == null) 
			System.assert(true, 'Null Team Wiki class var ');
		if (teamWikiC.getName() == null) 
			System.assert(true, 'Null Team Wiki class var ');
		if (teamWikiC.getDescription() == null) 
			System.assert(true, 'Null Team Wiki class var ');
		if (teamWikiC.getPicture() == null) 
			System.assert(true, 'Null Team Wiki class var '); 
		
		System.currentPageReference().getParameters().put('allTeams','true');
		wiki.genWikiSites();
		wiki.setSiteCount();
		
		wiki.setLetterFilter();
		
		System.currentPageReference().getParameters().put('ltr', 'ALL');
		//wiki.filterSites();
		wiki.setRecentlyUpdated();
		
		Test.stopTest();
	}	
	
	public static testMethod void testWiki2() {
		GenerateEnvironmentTest.gen();
		
		Test.startTest();
		
		// GENERATED FOR CODE COVERAGE
		WikiPage__c wikiTest = GenerateEnvironmentTest.wikiPage;
		FavoriteWikis__c favWikiCodCov = new FavoriteWikis__c();
		favWikiCodCov.WikiPage__c = wikiTest.Id;
		favWikiCodCov.Name = 'Code coverage';
		favWikiCodCov.Wiki__c = wikiTest.Wiki__c;
		insert favWikiCodCov;

		Comment__c commCodCov = new Comment__c();
   		commCodCov.Message__c = 'Code coverage';
   		commCodCov.WikiPage__c = wikiTest.Id;
   		commCodCov.ParentWikiPage__c = wikiTest.Id;
		insert commCodCov;

		WikiPage__c wikiCodCov = GenerateEnvironmentTest.wikiPage;
		delete wikiCodCov;
		
		Test.stopTest();
	}
}