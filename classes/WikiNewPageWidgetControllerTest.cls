@isTest private class WikiNewPageWidgetControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            WikiNewPageWidgetController wn = new WikiNewPageWidgetController();
            
            wn.setIdTeam( GenerateEnvironmentTest.wiki.id );
            wn.setIdWikiPage( GenerateEnvironmentTest.wikiPage.id );
            wn.setIdTeamOverview( GenerateEnvironmentTest.wikiPage.id );
            
            wn.getNamespace();
            wn.getIdTeam();
            wn.getIdTeamOverview();
            wn.getIdWikiPage();
            wn.getNewWikiPage();
            
            wn.saveWiki();
            wn.saveWikiAndEdit();
            
            wn.refreshWikis();
            
            
            
            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}