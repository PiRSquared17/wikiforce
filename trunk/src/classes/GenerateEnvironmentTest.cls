public class GenerateEnvironmentTest {

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

	public static Attachment attach = new Attachment();

    //Boolen for run minimal date gen
    public static Boolean runLite = false;
    
    public static testMethod void gen(){

        TeamUtil.isTest = true;
        
        if (!TeamUtil.alreadyGenEnv) {

            // Create a new User
            /*
            Profile p = [select id from profile where name='Standard User'];
            User newUser = new User(alias = 'standt', email='standarduser@testorg.com', 
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = p.Id, 
                                    timezonesidkey='America/Los_Angeles', username='standarduser2@testorg.com');
            insert newUser;
            */
            newUser = [ SELECT Id, Name FROM User LIMIT 1 ];


            // Create a new Wiki Administrator Profile
            profile.Name = 'Wiki Administrator';
            profile.CreateWikiPages__c = true; 
            profile.ManageWikis__c = true; 
            profile.PostWikiComments__c = true; 
            upsert profile;
            
			//Create Others profiles
			WikiProfile__c newWikiProfilePublic = new WikiProfile__c(); 
            newWikiProfilePublic.Name = 'Public Profile';
            newWikiProfilePublic.PostWikiComments__c = true; 
            upsert newWikiProfilePublic;            
            
			WikiProfile__c newWikiProfileMember = new WikiProfile__c(); 
            newWikiProfileMember.Name = 'Member Profile';
            newWikiProfileMember.CreateWikiPages__c = true;
            newWikiProfileMember.PostWikiComments__c = true; 
			
			// Create a attachment
            attach.Name = 'Test';
            attach.Body = Blob.valueOf('Content');
            attach.ParentId = profile.Id;
            insert attach;            

            // Create a new wiki
            wiki.Name = 'Test class Wiki';
            wiki.NewMemberProfile__c = profile.Id;
            wiki.PictureId__c = attach.Id;
            wiki.Description__c = 'Discussion description';
            upsert wiki;  

            // Create a new WikiPage
            wikiPage.Wiki__c = wiki.Id;
            upsert wikiPage;
            
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
            upsert member;
            
            
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
            
            //
            TeamUtil.alreadyGenEnv = true;
            
        }
    }


}