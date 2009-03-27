public class WikiPageLinksControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            System.currentPageReference().getParameters().put('idWP', GenerateEnvironmentTest.wikiPage.Id );
            WikiPageLinksController wp = new WikiPageLinksController();
            
            
            wp.setIdWikiPage( GenerateEnvironmentTest.wikiPage.Id );
            
            
            wp.genTeamId();
            wp.getAttachments();
            wp.getCntAttachments();
            wp.getWikiPagesTeam();
            wp.getCntTeamWikis();
            wp.getWikiPagesAll();
            wp.getCntAllWikis();
            wp.getWikiChilds();
            wp.getCntWikiChilds();
            
            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}