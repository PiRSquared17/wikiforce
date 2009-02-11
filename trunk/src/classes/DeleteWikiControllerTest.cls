@isTest private class DeleteWikiControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            DeleteWikiController t = new DeleteWikiController();
            t.setWikiId( GenerateEnvironmentTest.wiki.Id );
            t.getWikiId();
            //t.deleteWiki();
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            throw e;
        }
    }
}