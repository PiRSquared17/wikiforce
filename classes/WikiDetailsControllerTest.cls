@isTest private class WikiDetailsControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            System.currentPageReference().getParameters().put( 'id', GenerateEnvironmentTest.wiki.id );
            WikiDetailsController wd = new WikiDetailsController();
            
            // Setters
            wd.setTeamIdParam( GenerateEnvironmentTest.wiki.id );
            
            //Getters
            wd.getInTeamSubscription();
            wd.getUserPermissionsWiki();
            wd.getTeamIdParam();
            wd.getTeamDetail();
            wd.getTeamIsOpen();
            wd.getTeamspace();
            wd.getTeamspaceImage();
            wd.refreshJoinEvent();
            
            wd.refreshWikis();
            
            wd.joinTeam();
            wd.leaveTeam();
            
            
            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}