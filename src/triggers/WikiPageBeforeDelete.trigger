trigger WikiPageBeforeDelete on WikiPage__c bulk (before delete) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;

        	WikiSubscribersEmailServices wEmail = new WikiSubscribersEmailServices();
            for ( WikiPage__c wp : Trigger.old ) 
            {
            	wEmail.sendNewPageMessage( 'updatePage',  wp.Id );  
            	wEmail.sendModifiedPageMessage( wp.Id, 'update' );
            }			
			
			List<WikiPage__c> wikiObj = [Select 
											id,
											(Select Id From WikiVersions__r), 
											(Select Id From RecentlyViewed__r), 
											(Select Id From ToLink__r),
											(Select Id From FromLink__r), 
											(Select Id From FavoriteWikis__r),
											(Select Id From Comments__r) 
										From WikiPage__c w where id in: Trigger.old];
		 
			if( !TeamUtil.DeletingWiki )
			{
				List<WikiPage__c> wikiChilds = [Select 
												id,
												(Select Id From WikiVersions__r), 
												(Select Id From RecentlyViewed__r), 
												(Select Id From ToLink__r),
												(Select Id From FromLink__r), 
												(Select Id From FavoriteWikis__r),
												(Select Id From Comments__r) 
											From WikiPage__c w where Parent__c in: Trigger.old];
				
				delete wikiChilds;
			}

			TeamUtil.currentlyExeTrigger = false;
			
			List<WikiVersions__c> wikiVersions = new List<WikiVersions__c>();
			List<WikiRecentlyViewed__c> wikiRecentlyViewed = new List<WikiRecentlyViewed__c>();
			List<WikiLink__c> wikiLinksTo = new List<WikiLink__c>();
			List<WikiLink__c> wikiLinksFrom = new List<WikiLink__c>();
			List<FavoriteWikis__c> wikiFavorites = new List<FavoriteWikis__c>();
			List<Comment__c> wikiComments = new List<Comment__c>();
			
			for (WikiPage__c oldWiki : Trigger.old) {
				Boolean findWiki = false;
				Integer countWiki = 0;
				while (!findWiki && countWiki < wikiObj.size()) {
					if (wikiObj[countWiki].id == oldWiki.Id) {
						findWiki = true;
						if(wikiObj[countWiki].WikiVersions__r.size() > 0) {
							wikiVersions.addAll(wikiObj[countWiki].WikiVersions__r);
						}
						if (wikiObj[countWiki].RecentlyViewed__r.size() > 0) {
							wikiRecentlyViewed.addAll(wikiObj[countWiki].RecentlyViewed__r);
						}
						if (wikiObj[countWiki].ToLink__r.size() > 0) {
							wikiLinksTo.addAll(wikiObj[countWiki].ToLink__r);
						}
						if (wikiObj[countWiki].FromLink__r.size() > 0) {
							wikiLinksFrom.addAll(wikiObj[countWiki].FromLink__r);
						}
						if (wikiObj[countWiki].FavoriteWikis__r.size() > 0) {
							wikiFavorites.addAll(wikiObj[countWiki].FavoriteWikis__r);
						}
						if (wikiObj[countWiki].Comments__r.size() > 0) {
							wikiComments.addAll(wikiObj[countWiki].Comments__r);	
						}
					}
					countWiki++;	
				}
			}
			
			delete wikiVersions;
			delete wikiRecentlyViewed;
			delete wikiLinksTo;
			delete wikiLinksFrom;
			delete wikiFavorites;
			delete wikiComments;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 			
}