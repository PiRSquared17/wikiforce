@isTest private class SearchControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            Test.stopTest();
            
            SearchController sc = new SearchController();
            sc.setKey( 'key' );
            sc.setTeamId( GenerateEnvironmentTest.wiki.Id );
            sc.getModule();
            sc.getKey();
            sc.getTeamId();
            sc.getLabel();
            sc.getDefaultText();
            sc.searchKey();
            
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}