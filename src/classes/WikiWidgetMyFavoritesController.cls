/**
*@author Gabriel Rilo @ 18/12/2008
*/
public class WikiWidgetMyFavoritesController {
	
	public List<FavoriteWikis__c> favorites;
	//public List<FavoriteWikis__c> favorites = new List<FavoriteWikis__c>();
	
	/**
	* Costructor
	*/
	public WikiWidgetMyFavoritesController () {
		readFavorites();
	}
	
	/**
	*@return List<FavoriteWikis__c> 
	*/
   	public List<FavoriteWikis__c> getFavorite () {
   		return favorites;
   	}    	
   	
	/**
	* Read 5 favorites (A-Z order) for current user
	*/
	public void readFavorites(){
		//Empty favorites list
		this.favorites = new List<FavoriteWikis__c>();
		
		List<FavoriteWikis__c> aux = new List<FavoriteWikis__c>();
		aux =	[SELECT WikiPage__r.Wiki__r.Id, WikiPage__r.Wiki__r.Name, WikiPage__r.Name, WikiPage__r.Id FROM 
						FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() order by WikiPage__r.Name LIMIT 5];	
						
		for (FavoriteWikis__c item : aux) {
			FavoriteWikis__c favWiki = item.clone();
			favWiki.WikiPage__r.Wiki__r.Name = TeamUtil.chopWords( TeamUtil.chopPhrase( item.WikiPage__r.Wiki__r.Name ,25));
			favWiki.WikiPage__r.Name = TeamUtil.chopWords( TeamUtil.chopPhrase( item.WikiPage__r.Name ,20));
			favorites.add(favWiki);
		}	
	}

   	/**
   	*@return Integer
   	*/
   	public Integer getCntFav () {
   		return [select count() from FavoriteWikis__c where User__c = :UserInfo.getUserId()];
   	} 
}