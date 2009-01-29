@isTest private class WikiMemberControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            WikiMemberController wm = new WikiMemberController();
            wm.setUserId( GenerateEnvironmentTest.newUser.Id );
            wm.setWikiId( GenerateEnvironmentTest.wiki.Id );
            
            wm.getUserId();
            wm.getWikiProfileId();
            
            wm.isLastMemberAdmin();
            
            wm.joinWiki();
            wm.unjoinWiki();
            
            Test.stopTest();
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}