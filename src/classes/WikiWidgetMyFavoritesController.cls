/**
*@author Gabriel Rilo @ 18/12/2008
*/
public class WikiWidgetMyFavoritesController {
	
	public List<FavoriteWikis__c> favorites = new List<FavoriteWikis__c>();
	
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
		favorites =	[SELECT WikiPage__r.Wiki__r.Id, WikiPage__r.Wiki__r.Name, WikiPage__r.Name, WikiPage__r.Id FROM 
						FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() order by WikiPage__r.Name LIMIT 5];	
	}

   	/**
   	*@return Integer
   	*/
   	public Integer getCntFav () {
   		return [select count() from FavoriteWikis__c where User__c = :UserInfo.getUserId()];
   	} 
  	

}