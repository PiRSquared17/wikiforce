@isTest private class TriggersTest {

    public static User newUser = new User();		
	public static Wiki__c wiki = new Wiki__c();
	public static WikiPage__c wikiPage = new WikiPage__c();
	public static Comment__c comment = new Comment__c(); 
	public static WikiLink__c wikiLinkFrom = new WikiLink__c(); 
	public static WikiLink__c wikiLinkTo = new WikiLink__c(); 
	public static WikiProfile__c profile = new WikiProfile__c();
	public static WikiMember__c member = new WikiMember__c();
	public static WikiRecentlyViewed__c recentlyViewed = new WikiRecentlyViewed__c();
	public static FavoriteWikis__c favorites = new FavoriteWikis__c();
	public static WikiVersions__c version = new WikiVersions__c();

	public static testMethod void test() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();

	
            
            newUser = [ SELECT Id, Name FROM User LIMIT 1 ];


            // Create a new Wiki Administrator Profile
            profile.Name = 'Wiki Administrator';
            profile.CreateWikiPages__c = true; 
            profile.ManageWikis__c = true; 
            profile.PostWikiComments__c = true; 
            insert profile;
			

            // Create a new wiki
            wiki.Name = 'Test class Wiki';
            wiki.NewMemberProfile__c = profile.Id;
            wiki.Description__c = 'Discussion description';
            insert wiki;  

            // Create a new WikiPage
            wikiPage.Wiki__c = wiki.Id;
            insert wikiPage;
            
            // Create a new Comment
            comment.WikiPage__c = wikiPage.Id;
            insert comment;
            
            // Crete a new Wiki Link
            wikiLinkFrom.Name= 'test Wiki Link (from)';
            wikiLinkFrom.FromLink__c = wikiPage.Id;
            wikiLinkTo.Name= 'test Wiki Link (to)';
            wikiLinkTo.ToLink__c = wikiPage.Id;
            insert wikiLinkFrom;
            insert wikiLinkTo;
            
            // Create a new Wiki Member
            member.WikiProfile__c = profile.Id;
            member.User__c = newUser.Id;
            member.Wiki__c = wiki.Id;
            insert member;
            
            
			// Wiki Recently Viewed
            recentlyViewed.Name = 'test Wiki Recently Viewed Obj';
            recentlyViewed.User__c = newUser.Id;
            recentlyViewed.Wiki__c = wiki.Id;
            recentlyViewed.WikiPage__c = wikiPage.Id;
            insert recentlyViewed;

           
            // Favorites Wikis Obj
            favorites.Name = wiki.Name;
            favorites.User__c = newUser.Id;
            favorites.Wiki__c = wiki.Id;
            favorites.WikiPage__c = wikiPage.Id;
            insert favorites; 
             
            // Wiki Version
            version.Name = 'Wiki Version test name';
            version.Body__c = 'Is a Long Text Area field';
            version.RevisionCount__c = 1;
            version.WikiPageId__c = wikiPage.Id;
            insert version;

            delete member;
            delete profile;
            delete wikiPage;
            delete wiki;


 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
    
}